/// This modules exports `NftSafe` and transfer related primitives.
///
/// # Listing
///
/// `NftSafe` is a storage for NFTs which can be traded.
/// There are three ways NFTs can be listed:
/// 1. Publicly - anyone can buy the NFT for a given price.
/// 2. Privately - a specific entity can buy the NFT for a given price.
/// 3. Exclusively - only a specific entity can buy the NFT for a given price.
///
/// Exclusive listing cannot be revoked by the owner of the safe without
/// approval of the entity that has been granted exclusive listing rights.
///
/// An entity uses their `&UID` as a token.
/// Based on this token the safe owner grants redeem rights for specific NFT.
/// An entity that has been granted redeem rights can call `get_nft`.
///
/// # Transfer rules
///
/// Using `TransferPolicy<T>` and `TransferCap<T>` objects, a creator can
/// establish conditions upon which NFTs of their collection can be traded.
///
/// Simplest `TransferPolicy<T>` will require 0 holders of `TransferCap<T>`
/// to sign a `TransferRequest<T>`.
/// This is useful for collections which don't require any special conditions
/// such as royalties.
///
/// A royalty focused `TransferPolicy<T>` will require 1 holder of
/// `TransferCap<T>` to sign.
/// For example, that can be `sui::royalty::RoyaltyPolicy`.
///
/// With the pattern of `TransferCap<T>` signing, a pipeline of independent
/// `TransferCap<T>` holders can be chained together.
/// For example, a `sui::royalty::RoyaltyPolicy` can be chained with an
/// allowlist of sorts to enable only certain entities to trade the NFT.
module nft_protocol::nft_safe {
    use std::option::{Self, Option};

    use sui::dynamic_object_field::{Self as dof};
    use sui::transfer_policy::{Self, TransferRequest};
    use sui::object::{Self, ID, UID};
    use nft_protocol::package::{Self, Publisher};
    use sui::tx_context::TxContext;
    use sui::vec_map::{Self, VecMap};
    use sui::vec_set::{Self, VecSet};

    use nft_protocol::utils;

    // === Errors ===

    /// Incorrect owner for the given Safe
    const ESafeOwnerMismatch: u64 = 0;
    /// Safe does not contain the NFT
    const ESafeDoesNotContainNft: u64 = 1;
    /// NFT is already exclusively listed
    const ENftAlreadyExclusivelyListed: u64 = 2;
    /// NFT is already listed
    const ENftAlreadyListed: u64 = 3;
    /// The logic requires that no NFTs are stored in the safe.
    const EMustBeEmpty: u64 = 4;
    /// Publisher does not match the expected type.
    const EPublisherMismatch: u64 = 5;
    /// The amount provided is not enough.
    const ENotEnough: u64 = 6;
    /// The `TransferRequest` has not been signed by enough `TransferCap`s.
    const ENotEnoughSignatures: u64 = 7;

    /// A capability handed off to middleware.
    /// The creator (access to the `Publisher` object) can define how many
    /// unique `TransferCap` objects must sign a `TransferCap` before it can
    /// be consumed with `allow_transfer`.
    ///
    /// Can only be created with the `Publisher` object.
    struct TransferCap<phantom T> has key, store {
        id: UID
    }

    /// Whoever owns this object can perform some admin actions against the
    /// `NftSafe` object with the corresponding id.
    struct OwnerCap has key, store {
        id: UID,
        safe: ID,
    }

    struct NftSafe<I: key + store> has key, store {
        id: UID,
        // TODO: Make this dynamic field
        /// Accounting for deposited NFTs. Each NFT in the object bag is
        /// represented in this map.
        refs: VecMap<ID, NftRef>,
        inner: I,
    }

    /// Inner accounting type.
    ///
    /// Holds info about NFT listing which is used to determine if an entity
    /// is allowed to redeem the NFT.
    struct NftRef has store, drop {
        /// Entities which can use their `&UID` to redeem the NFT.
        auths: VecSet<ID>,
        /// If set to true, then `listed_with` must have length of 1 and
        /// listed_for must be "none".
        is_exclusively_listed: bool,
        /// How much is the NFT _publicly_ listed for.
        ///
        /// Anyone can come to the safe and buy the NFT for this price.
        listed_for: Option<u64>,
    }

    // === Events ===

    struct NftPubliclyListedEvent has copy, drop {
        safe: ID,
        nft: ID,
        price: u64,
    }

    // === Transfer Caps ===

    /// Register a type in the `NftSafe` system and receive an`TransferCap`
    /// which is required to confirm `NftSafe` deals for the `T`.
    public fun new_transfer_cap<NFT: key + store>(
        publisher: &Publisher, ctx: &mut TxContext,
    ): TransferCap<NFT> {
        assert!(package::from_package<NFT>(publisher), EPublisherMismatch);
        let id = object::new(ctx);
        TransferCap { id }
    }

    /// Destroy a `TransferCap`.
    public fun destroy_transfer_cap<NFT: key + store>(cap: TransferCap<NFT>) {
        let TransferCap { id } = cap;
        object::delete(id);
    }

    // === Safe interface ===

    public fun new<I: key + store, IW: drop>(
        inner: I,
        ctx: &mut TxContext
    ): (NftSafe<I>, OwnerCap) {
        utils::assert_same_module_as_witness<I, IW>();

        let cap_uid = object::new(ctx);
        let safe = NftSafe {
            id: object::new(ctx),
            refs: vec_map::empty(),
            inner: inner,
        };
        let cap = OwnerCap {
            id: cap_uid,
            safe: object::id(&safe),
        };
        (safe, cap)
    }

    /// Given object is added to the safe and can be listed from now on.
    public fun deposit_nft<I: key + store, NFT: key + store>(
        self: &mut NftSafe<I>, _owner_cap: &OwnerCap, nft: NFT,
    ) {
        let nft_id = object::id(&nft);

        vec_map::insert(&mut self.refs, nft_id, NftRef {
            auths: vec_set::empty(),
            is_exclusively_listed: false,
            listed_for: option::none(),
        });

        dof::add(&mut self.id, nft_id, nft);
    }

    /// Multiple entities can have redeem rights for the same NFT.
    /// Additionally, the owner can remove redeem rights for a specific entity
    /// at any time.
    ///
    /// # Aborts
    /// * If the NFT has already given exclusive redeem rights.
    public fun auth_transfer<I: key + store, IW: drop>(
        self: &mut NftSafe<I>,
        owner_cap: &OwnerCap,
        entity_id: ID,
        nft_id: ID,
        _inner_witness: IW,
    ) {
        utils::assert_same_module_as_witness<I, IW>();
        assert_owner_cap(self, owner_cap);
        assert_has_nft(self, &nft_id);

        let ref = vec_map::get_mut(&mut self.refs, &nft_id);
        assert_ref_not_exclusively_listed(ref);

        vec_set::insert(&mut ref.auths, entity_id);
    }

    /// One only entity can have exclusive redeem rights for the same NFT.
    /// Only the same entity can then give up their rights.
    /// Use carefully, if the entity is malicious, they can lock the NFT.
    ///
    /// # Note
    /// Unlike with `auth_entity_for_nft_transfer`, we require that the entity
    /// approves this action `&UID`.
    /// This gives the owner some sort of warranty that the implementation of
    /// the entity took into account the exclusive listing.
    ///
    /// # Aborts
    /// * If the NFT already has given up redeem rights (not necessarily exclusive)
    public fun auth_exclusive_transfer<I: key + store, IW: drop>(
        self: &mut NftSafe<I>,
        owner_cap: &OwnerCap,
        nft_id: ID,
        entity_id: &UID,
        _inner_witness: IW,
    ) {
        utils::assert_same_module_as_witness<I, IW>();
        assert_owner_cap(self, owner_cap);
        assert_has_nft(self, &nft_id);

        let ref = vec_map::get_mut(&mut self.refs, &nft_id);
        assert_not_listed(ref);

        vec_set::insert(
            &mut ref.auths, object::uid_to_inner(entity_id),
        );
        ref.is_exclusively_listed = true;
    }

    public fun get_nft_as_owner<I: key + store, IW: drop, NFT: key + store>(
        self: &mut NftSafe<I>,
        owner_cap: &OwnerCap,
        nft_id: ID,
        price: u64,
        _inner_witness: IW,
        ctx: &mut TxContext,
    ): (NFT, TransferRequest<NFT>) {
        utils::assert_same_module_as_witness<I, IW>();
        assert_owner_cap(self, owner_cap);
        assert_has_nft(self, &nft_id);

        // Need to clean up entity auths if any..
        let nft = dof::remove<ID, NFT>(&mut self.id, nft_id);
        let request = transfer_policy::new_request<NFT>(
            price,
            object::uid_to_inner(&self.id),
            ctx,
        );

        (nft, request)
    }

    /// An entity uses the `&UID` as a token which has been granted a permission
    /// for transfer of the specific NFT.
    /// With this token, a transfer can be performed.
    ///
    /// This function returns a hot potato which must be passed around and
    /// finally destroyed in `allow_transfer`.
    public fun get_nft_as_entity<I: key + store, IW: drop, NFT: key + store>(
        self: &mut NftSafe<I>,
        entity_id: &UID,
        nft_id: ID,
        price: u64,
        _inner_witness: IW,
        ctx: &mut TxContext,
    ): (NFT, TransferRequest<NFT>) {
        utils::assert_same_module_as_witness<I, IW>();
        assert_has_nft(self, &nft_id);

        // NFT is being transferred - destroy the ref
        let (_, ref) = vec_map::remove(&mut self.refs, &nft_id);
        let listed_for = *option::borrow(&ref.listed_for);

        // aborts if entity is not included in the map
        let entity_auth = object::uid_to_inner(entity_id);
        vec_set::remove(&mut ref.auths, &entity_auth);

        let nft = dof::remove<ID, NFT>(&mut self.id, nft_id);
        let request = transfer_policy::new_request<NFT>(
            price,
            object::uid_to_inner(&self.id),
            ctx
        );

        (nft, request)
    }

    /// An entity can remove itself from accessing (ie. delist) an NFT.
    ///
    /// This method is the only way an exclusive listing can be delisted.
    ///
    /// # Aborts
    /// * If the entity is not listed as an auth for this NFT.
    public fun remove_entity_from_nft_listing<I: key + store>(
        self: &mut NftSafe<I>,
        entity_id: &UID,
        nft_id: &ID,
    ) {
        assert_has_nft(self, nft_id);

        let ref = vec_map::get_mut(&mut self.refs, nft_id);
        // aborts if the entity is not in the map
        let entity_auth = object::uid_to_inner(entity_id);
        vec_set::remove(&mut ref.auths, &entity_auth);
        ref.is_exclusively_listed = false; // no-op unless it was exclusive
    }

    /// The safe owner can remove an entity from accessing an NFT unless
    /// it's listed exclusively.
    /// An exclusive listing can be canceled only via
    /// `remove_auth_from_nft_listing`.
    ///
    /// # Aborts
    /// * If the NFT is exclusively listed.
    /// * If the entity is not listed as an auth for this NFT.
    public fun remove_entity_from_nft_listing_as_owner<I: key + store>(
        self: &mut NftSafe<I>,
        owner_cap: &OwnerCap,
        entity_id: &ID,
        nft_id: &ID,
    ) {
        assert_owner_cap(self, owner_cap);
        assert_has_nft(self, nft_id);

        let ref = vec_map::get_mut(&mut self.refs, nft_id);
        assert_ref_not_exclusively_listed(ref);
        // aborts if the entity is not in the map
        vec_set::remove(&mut ref.auths, entity_id);
    }

    // TODO: To avoid dangling references in external trading contracts,
    // should we not constrain this call to authorised entities?
    /// Removes all access to an NFT.
    /// An exclusive listing can be canceled only via
    /// `remove_auth_from_nft_listing`.
    ///
    /// # Aborts
    /// * If the NFT is exclusively listed.
   public fun delist_nft<I: key + store>(
        self: &mut NftSafe<I>,
        owner_cap: &OwnerCap,
        nft_id: &ID,
    ) {
        assert_owner_cap(self, owner_cap);
        assert_has_nft(self, nft_id);

        let ref = vec_map::get_mut(&mut self.refs, nft_id);
        assert_ref_not_exclusively_listed(ref);
        ref.auths = vec_set::empty();
    }

    /// If there are no deposited NFTs in the safe, the safe is destroyed.
    /// Only works for non-shared safes.
    public fun destroy_empty<I: key + store>(
        self: NftSafe<I>, owner_cap: OwnerCap, ctx: &mut TxContext,
    ): I {
        assert_owner_cap(&self, &owner_cap);
        assert!(vec_map::is_empty(&self.refs), EMustBeEmpty);

        let NftSafe<I> { id, refs, inner } = self;
        let OwnerCap { id: cap_id, safe: _ } = owner_cap;
        vec_map::destroy_empty(refs);
        object::delete(id);
        object::delete(cap_id);

        inner
    }

    // === Getters ===

    public fun nfts_count<I: key + store>(self: &NftSafe<I>): u64 { vec_map::size(&self.refs) }

    public fun borrow_nft<I: key + store, NFT: key + store>(self: &NftSafe<I>, nft_id: ID): &NFT {
        assert_has_nft(self, &nft_id);
        dof::borrow<ID, NFT>(&self.id, nft_id)
    }

    public fun has_nft<I: key + store, NFT: key + store>(self: &NftSafe<I>, nft_id: ID): bool {
        dof::exists_with_type<ID, NFT>(&self.id, nft_id)
    }

    public fun owner_cap_safe(cap: &OwnerCap): ID { cap.safe }

    // === Assertions ===

    public fun assert_owner_cap<I: key + store>(self: &NftSafe<I>, cap: &OwnerCap) {
        assert!(cap.safe == object::id(self), ESafeOwnerMismatch);
    }

    public fun assert_has_nft<I: key + store>(self: &NftSafe<I>, nft: &ID) {
        assert!(vec_map::contains(&self.refs, nft), ESafeDoesNotContainNft);
    }

    public fun assert_not_exclusively_listed<I: key + store>(
        self: &NftSafe<I>, nft_id: &ID
    ) {
        let ref = vec_map::get(&self.refs, nft_id);
        assert_ref_not_exclusively_listed(ref);
    }

    fun assert_ref_not_exclusively_listed(ref: &NftRef) {
        assert!(!ref.is_exclusively_listed, ENftAlreadyExclusivelyListed);
    }

    fun assert_not_listed(ref: &NftRef) {
        assert!(vec_set::size(&ref.auths) == 0, ENftAlreadyListed);
        assert!(option::is_none(&ref.listed_for), ENftAlreadyListed);
    }
}
