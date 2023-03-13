/// Module of `NftSafe` type.
///
/// `NftSafe` is an abstraction meant to hold NFTs in it.
///
/// We are defining here an NFT as any owned non-fungible object type that has
/// `key + store` ability, however in practice the `NftSafe` is generic enough
/// to hold any object with any degree of fungibility as long as the object type
/// has the aforementioned abilities and is Single-Writer.
///
/// A user that transfers its NFTs to its Safe is able to delegate the power
/// of transferability.
///
/// The ownership model of the `NftSafe` relies on the object `OwnerCap` whose
/// holder is the effective owner of the `NftSafe` and subsequently the owner of
/// the assets within it.
///
/// The `NftSafe` solves for the following problems:
///
/// 1. Discoverability:
///
/// One typical issue with on-chain trading is that by sending one's assets
/// to a shared object (the trading primitive), one looses the ability to
/// see them in their wallet, even though one has still technical ownership
/// of such assets, until a trade is effectively executed.
///
/// By holding NFTs in the `NftSafe`, users can list them for sale and still
/// be able to see them in their wallets until the point that they're
/// effectively sold and transferred out.
///
/// Instead of transferring the assets to the shared object (trading primitive),
/// the `NftSafe` registers a Transfer Authorisation that allows for the trading
/// primitive to withdraw the NFT at a later stage when the settlement is executed.
/// The settlement can occur immediately after the trade execution, in the same
/// transaction, or at a later stage, it's up to the trading primitive.
///
/// The registration of transfer authorisations is done through `NftRef`, namely
/// in the fields `auths` and `exclusive_auth`. This structure represents an
/// accounting item, and as a whole the `NftSafe` maintains a coherent accounting
/// of the NFTs it owns and their respective transfer authorisations
///
/// Transfer authorisations are registered in `NftRef`s which function as the
/// `NftSafe` accounting items. When a transfer occurs, all the `TransferAuth`s for
/// the respective NFT get cleared.
///
/// 2. Isomorphic control over transfers:
///
/// Objects with `key + store` ability have access to polymorphic transfer
/// functions, making these objects freely transferrable. Whilst this is useful
/// in a great deal of use-cases, creators often want build custom
/// transferrability rules (e.g. Royalty protection mechanisms, NFT with
/// expiration dates, among others).
///
/// `NftSafe` has a generic inner type `I` which regulates access to the outer
/// type. We guarantee this by having the parameter `inner_witness: IW` in
/// the funtion signatures and by calling
/// `assert_same_module_as_witness<I, IW>()`, where `IW` is a witness struct
/// defined in the inner safe module.
///
/// In effect, this allows creators and developers to create `NftSafe`s
/// with custom transferrability rules.
///
/// 3. Mutable access to NFTs:
///
/// The inner safe patter described above also allows for creators and developers
/// to define custom NFT write access rules. This is a usefule feature for
/// dynamic NFTs.
///
///
/// This module uses the following witnesses:
/// I: Inner `NftSafe` type
/// IW: Inner Witness type
/// E: Entinty Witness type of the entity requesting transfer authorisation
/// NFT: NFT type of a given NFT in the `NftSafe`
module nft_protocol::nft_safe {
    use std::option::{Self, Option};
    use std::type_name::{Self, TypeName};

    use sui::event;
    use sui::tx_context::TxContext;
    use sui::vec_set::{Self, VecSet};
    use sui::vec_map::{Self, VecMap};
    use sui::object::{Self, ID, UID};
    use sui::transfer::{share_object, transfer};
    use sui::dynamic_object_field::{Self as dof};

    use nft_protocol::utils;

    // === Errors ===

    /// NFT type is not what the user expected
    const ENFT_TYPE_MISMATCH: u64 = 0;

    /// Incorrect owner for the given Safe
    const ESAFE_OWNER_MISMATCH: u64 = 1;

    /// Safe does not containt the NFT
    const ESAFE_DOES_NOT_CONTAIN_NFT: u64 = 2;

    /// Entity not authotised to transfer the given NFT
    const EENTITY_NOT_AUTHORISED_FOR_TRANSFER: u64 = 3;

    /// NFT is already exclusively listed
    const ENFT_ALREADY_EXCLUSIVELY_LISTED: u64 = 4;

    /// NFT is already listed
    const ENFT_ALREADY_LISTED: u64 = 5;


    struct NftSafe<I: key + store> has key, store {
        id: UID,
        /// Accounting for deposited NFTs. Each NFT in the object bag is
        /// represented in this map.
        refs: VecMap<ID, NftRef>,
        inner: I,
    }

    struct NftRef has store, drop {
        auths: VecSet<ID>,
        // Certain trading primitives, such as orderbooks, require exclusive
        // auths, since heuristic transfer access to NFTs would render these
        // primivies unusable. When traders interact with an orderbook, they
        // expect NFTs sold it in to be available for transfer.
        exclusive_auth: Option<ID>,
        object_type: TypeName,
    }

    /// Whoever owns this object can perform some admin actions against the
    /// `NftSafe` shared object with the corresponding id.
    struct OwnerCap has key, store {
        id: UID,
        safe: ID,
    }

    struct DepositEvent has copy, drop {
        safe: ID,
        nft: ID,
    }

    struct TransferEvent has copy, drop {
        safe: ID,
        nft: ID,
    }

    public fun new<I: key + store>(
        inner: I,
        ctx: &mut TxContext
    ): (NftSafe<I>, OwnerCap) {
        let safe = NftSafe {
            id: object::new(ctx),
            refs: vec_map::empty(),
            inner,
        };

        let cap = OwnerCap {
            id: object::new(ctx),
            safe: object::id(&safe),
        };

        (safe, cap)
    }

    /// Creates a new `NftSafe` shared object and returns the authority
    /// capability that grants authority over this safe.
    public fun create_safe<I: key + store>(
        inner: I,
        ctx: &mut TxContext
    ): OwnerCap {
        let (safe, cap) = new<I>(inner, ctx);
        share_object(safe);

        cap
    }

    /// Authorises a certain
    public fun auth_transfer<I: key + store, IW: drop>(
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
        assert_not_exclusively_listed(ref);

        vec_set::insert(&mut ref.auths, object::uid_to_inner(entity_id));
    }

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
        // Assert that there are no transfer authorisations
        assert_not_listed(ref);

        option::fill(&mut ref.exclusive_auth, object::uid_to_inner(entity_id));
    }

    /// Transfer an NFT into the `NftSafe`.
    public fun deposit_nft<I: key + store, IW: drop, NFT: key + store>(
        self: &mut NftSafe<I>,
        nft: NFT,
        _inner_witness: IW,
    ) {
        utils::assert_same_module_as_witness<I, IW>();

        let nft_id = object::id(&nft);

        vec_map::insert(&mut self.refs, nft_id, NftRef {
            auths: vec_set::empty(),
            exclusive_auth: option::none(),
            object_type: type_name::get<NFT>(),
        });

        dof::add(&mut self.id, nft_id, nft);

        event::emit(
            DepositEvent {
                safe: object::id(self),
                nft: nft_id,
            }
        );
    }

    /// Use a transfer auth to get an NFT out of the `NftSafe`.
    public fun transfer_nft_to_recipient<I: key + store, IW: drop, NFT: key + store>(
        self: &mut NftSafe<I>,
        nft_id: ID,
        recipient: address,
        entity_id: &UID,
        _inner_witness: IW,
    ) {
        utils::assert_same_module_as_witness<I, IW>();

        let nft = get_nft_for_transfer_<I, NFT>(self, nft_id, entity_id);

        transfer(nft, recipient)
    }


    public fun transfer_nft_to_safe<I: key + store, IW: drop, NFT: key + store>(
        source: &mut NftSafe<I>,
        target: &mut NftSafe<I>,
        nft_id: ID,
        entity_id: &UID,
        inner_witness: IW,
    ) {
        utils::assert_same_module_as_witness<I, IW>();

        let nft = get_nft_for_transfer_<I, NFT>(source, nft_id, entity_id);

        deposit_nft(target, nft, inner_witness);
    }

    public fun get_nft<I: key + store, IW: drop, NFT: key + store>(
        self: &mut NftSafe<I>,
        nft_id: ID,
        entity_id: &UID,
        _inner_witness: IW,
    ): NFT {
        utils::assert_same_module_as_witness<I, IW>();

        let nft = get_nft_for_transfer_<I, NFT>(
            self, nft_id, entity_id,
        );

        nft
    }

    public fun delist_nft<I: key + store, IW: drop>(
        self: &mut NftSafe<I>,
        owner_cap: &OwnerCap,
        nft_id: ID,
        entity_id: &UID,
        _inner_witness: IW,
    ) {
        utils::assert_same_module_as_witness<I, IW>();
        assert_owner_cap(self, owner_cap);
        assert_has_nft(self, &nft_id);

        // Get NftRef
        let ref = vec_map::get_mut(&mut self.refs, &nft_id);
        let auth = object::uid_to_inner(entity_id);

        // Pops transfer authorisation if any
        // Fails if no authorisation for the given ID
        if (!option::is_some(&ref.exclusive_auth)) {
            vec_set::remove(
                &mut ref.auths, &auth
            );
        } else {
            option::extract(&mut ref.exclusive_auth);
        };
    }

    // === Private functions ===

    fun get_nft_for_transfer_<I: key + store, NFT: key + store>(
        self: &mut NftSafe<I>,
        nft_id: ID,
        entity_id: &UID,
    ): NFT {
        event::emit(
            TransferEvent {
                safe: object::id(self),
                nft: nft_id,
            }
        );

        // This pops the NFT reference, which means that it gets rid of all
        // transfer auths, which is desired because it avoids lingering auths
        let (_, ref) = vec_map::remove(&mut self.refs, &nft_id);
        let auth = object::uid_to_inner(entity_id);

        // Pops transfer authorisation if any
        // Fails if no authorisation for the given ID
        if (!option::is_some(&ref.exclusive_auth)) {
            vec_set::remove(
                &mut ref.auths, &auth
            );
        } else {
            option::extract(&mut ref.exclusive_auth);
        };

        assert_has_nft(self, &nft_id);

        dof::remove<ID, NFT>(&mut self.id, nft_id)
    }

    // // === Getters ===

    public fun borrow_nft<I: key + store, NFT: key + store>(
        self: &NftSafe<I>,
        nft_id: ID,
    ): &NFT {
        dof::borrow<ID, NFT>(&self.id, nft_id)
    }

    public fun has_nft<I: key + store, NFT: key + store>(
        self: &NftSafe<I>,
        nft_id: ID,
    ): bool {
        dof::exists_with_type<ID, NFT>(&self.id, nft_id)
    }

    // Getter for OwnerCap's Safe ID
    public fun owner_cap_safe(cap: &OwnerCap): ID {
        cap.safe
    }

    public fun nft_object_type<I: key + store>(
        self: &NftSafe<I>,
        nft_id: ID,
    ): TypeName {
        let ref = vec_map::get(&self.refs, &nft_id);
        ref.object_type
    }

    // === Assertions ===

    public fun assert_owner_cap<I: key + store>(self: &NftSafe<I>, cap: &OwnerCap) {
        assert!(cap.safe == object::id(self), ESAFE_OWNER_MISMATCH);
    }

    public fun assert_has_nft<I: key + store>(self: &NftSafe<I>, nft: &ID) {
        assert!(vec_map::contains(&self.refs, nft), ESAFE_DOES_NOT_CONTAIN_NFT);
    }

    fun assert_not_exclusively_listed(ref: &NftRef) {
        assert!(!option::is_some(&ref.exclusive_auth), ENFT_ALREADY_EXCLUSIVELY_LISTED);
    }

    fun assert_not_listed(ref: &NftRef) {
        assert!(vec_set::size(&ref.auths) == 0, ENFT_ALREADY_LISTED);

        assert_not_exclusively_listed(ref);
    }
}
