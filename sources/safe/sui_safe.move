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
    use std::ascii;
    use std::option::{Self, Option};

    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::dynamic_object_field::{Self as dof};
    use sui::transfer_policy::{Self, TransferRequest};
    use sui::object::{Self, ID, UID};
    use nft_protocol::package::{Self, Publisher};
    use sui::sui::SUI;
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
        ///
        /// We also configure min listing price.
        /// The item must be bought by the entity by _at least_ this many SUI.
        listed_with: VecMap<ID, u64>,
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
    public fun new_transfer_cap<T: key + store>(
        publisher: &Publisher, ctx: &mut TxContext,
    ): TransferCap<T> {
        assert!(package::from_package<T>(publisher), EPublisherMismatch);
        let id = object::new(ctx);
        TransferCap { id }
    }

    /// Destroy a `TransferCap`.
    public fun destroy_transfer_cap<T: key + store>(cap: TransferCap<T>) {
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
    public fun deposit_nft<I: key + store, T: key + store>(
        self: &mut NftSafe<I>, _owner_cap: &OwnerCap, nft: T,
    ) {
        let nft_id = object::id(&nft);

        vec_map::insert(&mut self.refs, nft_id, NftRef {
            listed_with: vec_map::empty(),
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
        assert_not_exclusively_listed(ref);

        vec_set::insert(&mut ref.auths, object::uid_to_inner(entity_id));
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

        vec_map::insert(
            &mut ref.listed_with, object::uid_to_inner(entity_id), min_price,
        );
        ref.is_exclusively_listed = true;
    }

    public fun get_nft_as_owner<I: key + store, IW: drop, T: key + store>(
        self: &mut NftSafe<I>,
        owner_cap: &OwnerCap,
        nft_id: ID,
        price: u64,
        _inner_witness: IW,
        ctx: &mut TxContext,
    ): (T, TransferRequest<T>) {
        utils::assert_same_module_as_witness<I, IW>();
        assert_owner_cap(self, owner_cap);
        assert_has_nft(self, &nft_id);

        // Need to clean up entity auths if any..
        let nft = dof::remove<ID, T>(&mut self.id, nft_id);
        let request = transfer_policy::new_request<T>(price, object::uid_to_inner(&self.id), ctx);

        (nft, request)
    }

    /// An entity uses the `&UID` as a token which has been granted a permission
    /// for transfer of the specific NFT.
    /// With this token, a transfer can be performed.
    ///
    /// This function returns a hot potato which must be passed around and
    /// finally destroyed in `allow_transfer`.
    public fun get_nft_as_entity<I: key + store, IW: drop, T: key + store>(
        self: &mut NftSafe<I>,
        entity_id: &UID,
        nft_id: ID,
        price: u64,
        _inner_witness: IW,
        ctx: &mut TxContext,
    ): (T, TransferRequest<T>) {
        utils::assert_same_module_as_witness<I, IW>();
        assert_has_nft(self, &nft_id);

        // NFT is being transferred - destroy the ref
        let (_, ref) = vec_map::remove(&mut self.refs, &nft_id);
        let listed_for = *option::borrow(&ref.listed_for);

        // aborts if entity is not included in the map
        let entity_auth = object::uid_to_inner(entity_id);
        vec_map::remove(&mut ref.listed_with, &entity_auth);

        let nft = dof::remove<ID, T>(&mut self.id, nft_id);
        let request = transfer_policy::new_request<T>(price, object::uid_to_inner(&self.id), ctx);

        (nft, request)
    }

    /// An entity can remove itself from accessing (ie. delist) an NFT.
    ///
    /// This method is the only way an exclusive listing can be delisted.
    ///
    /// # Aborts
    /// * If the entity is not listed as an auth for this NFT.
    public fun remove_entity_from_nft_listing(
        self: &mut NftSafe,
        entity_id: &UID,
        nft_id: &ID,
    ) {
        assert_has_nft(self, nft_id);

        let ref = vec_map::get_mut(&mut self.refs, nft_id);
        // aborts if the entity is not in the map
        let entity_auth = object::uid_to_inner(entity_id);
        vec_map::remove(&mut ref.listed_with, &entity_auth);
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
    public fun remove_entity_from_nft_listing_as_owner(
        self: &mut NftSafe,
        owner_cap: &OwnerCap,
        entity_id: &ID,
        nft_id: &ID,
    ) {
        assert_owner_cap(self, owner_cap);
        assert_has_nft(self, nft_id);

        let ref = vec_map::get_mut(&mut self.refs, nft_id);
        assert_ref_not_exclusively_listed(ref);
        // aborts if the entity is not in the map
        vec_map::remove(&mut ref.listed_with, entity_id);
    }

    /// Removes all access to an NFT.
    /// An exclusive listing can be canceled only via
    /// `remove_auth_from_nft_listing`.
    ///
    /// # Aborts
    /// * If the NFT is exclusively listed.
   public fun delist_nft(
        self: &mut NftSafe,
        owner_cap: &OwnerCap,
        nft_id: &ID,
    ) {
        assert_owner_cap(self, owner_cap);
        assert_has_nft(self, nft_id);

        let ref = vec_map::get_mut(&mut self.refs, nft_id);
        assert_ref_not_exclusively_listed(ref);
        ref.listed_with = vec_map::empty();
    }

    /// If there are no deposited NFTs in the safe, the safe is destroyed.
    /// Only works for non-shared safes.
    public fun destroy_empty(
        self: NftSafe, owner_cap: OwnerCap, ctx: &mut TxContext,
    ): Coin<SUI> {
        assert_owner_cap(&self, &owner_cap);
        assert!(vec_map::is_empty(&self.refs), EMustBeEmpty);

        let NftSafe {
            id, refs, profits, ecosystem: _, owner_cap_id: _,
        } = self;
        let OwnerCap { id: cap_id, safe: _ } = owner_cap;
        vec_map::destroy_empty(refs);
        object::delete(id);
        object::delete(cap_id);

        coin::from_balance(profits, ctx)
    }

    /// Withdraws profits from the safe.
    /// If `amount` is `none`, withdraws all profits.
    /// Otherwise attempts to withdraw the specified amount.
    /// Fails if there are not enough token.
    public fun withdraw_profits(
        self: &mut NftSafe,
        owner_cap: &OwnerCap,
        amount: Option<u64>,
        ctx: &mut TxContext,
    ): Coin<SUI> {
        assert_owner_cap(self, owner_cap);

        let amount = if (option::is_some(&amount)) {
            let amt = option::destroy_some(amount);
            assert!(amt <= balance::value(&self.profits), ENotEnough);
            amt
        } else {
            balance::value(&self.profits)
        };

        coin::take(&mut self.profits, amount, ctx)
    }

    // === Getters ===

    public fun ecosystem(self: &NftSafe): &Option<ascii::String> { &self.ecosystem }

    public fun nfts_count(self: &NftSafe): u64 { vec_map::size(&self.refs) }

    public fun borrow_nft<T: key + store>(self: &NftSafe, nft_id: ID): &T {
        assert_has_nft(self, &nft_id);
        dof::borrow<ID, T>(&self.id, nft_id)
    }

    public fun has_nft<T: key + store>(self: &NftSafe, nft_id: ID): bool {
        dof::exists_with_type<ID, T>(&self.id, nft_id)
    }

    public fun owner_cap_safe(cap: &OwnerCap): ID { cap.safe }

    public fun transfer_request_paid<T>(req: &TransferRequest<T>): u64 { req.paid }

    public fun transfer_request_safe<T>(req: &TransferRequest<T>): ID { req.safe }

    public fun transfer_request_entity<T>(req: &TransferRequest<T>): Option<ID> { req.entity }

    public fun transfer_request_signatures<T>(req: &TransferRequest<T>): VecSet<ID> {
        req.signatures
    }

    // === Assertions ===

    public fun assert_owner_cap(self: &NftSafe, cap: &OwnerCap) {
        assert!(cap.safe == object::id(self), ESafeOwnerMismatch);
    }

    public fun assert_has_nft(self: &NftSafe, nft: &ID) {
        assert!(vec_map::contains(&self.refs, nft), ESafeDoesNotContainNft);
    }

    public fun assert_not_exclusively_listed(
        self: &NftSafe, nft: &ID
    ) {
        let ref = vec_map::get(&self.refs, nft);
        assert_ref_not_exclusively_listed(ref);
    }

    fun assert_ref_not_exclusively_listed(ref: &NftRef) {
        assert!(!ref.is_exclusively_listed, ENftAlreadyExclusivelyListed);
    }

    fun assert_not_listed(ref: &NftRef) {
        assert!(vec_map::size(&ref.listed_with) == 0, ENftAlreadyListed);
        assert!(option::is_none(&ref.listed_for), ENftAlreadyListed);
    }
}
