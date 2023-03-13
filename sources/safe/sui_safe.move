/// This contract uses the following witnesses:
/// I: Inner Type of the Safe
/// E: Entinty Witness of the entity request transfer authorisation
/// NFT: NFT Type of a given NFT in the Safe
/// IW: Inner Witness type
module nft_protocol::sui_safe {
    use std::ascii;
    use std::vector;
    use std::option::{Self, Option};
    use std::type_name::{Self, TypeName};

    use sui::hash;
    use sui::event;
    use sui::tx_context::TxContext;
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


    struct SuiSafe<I: key + store> has key, store {
        id: UID,
        /// Accounting for deposited NFTs. Each NFT in the object bag is
        /// represented in this map.
        refs: VecMap<ID, NftRef>,
        inner: I,
    }

    struct NftRef has store, copy, drop {
        // Auth ID from hash of entity typename and entity ID if any.
        auths: VecMap<ID, TransferAuth>,
        exclusive_auth: Option<TransferAuth>,
        object_type: TypeName,
    }

    // TODO: Consider removing copy from TransferAuth and NftRef
    struct TransferAuth has store, copy, drop {
        entity: TypeName,
        entity_id: ID,
    }

    /// Whoever owns this object can perform some admin actions against the
    /// `Safe` shared object with the corresponding id.
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

    public fun new<I: key + store>(inner: I, ctx: &mut TxContext): (SuiSafe<I>, OwnerCap) {
        let safe = SuiSafe {
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

    /// Creates a new `Safe` shared object and returns the authority capability
    /// that grants authority over this safe.
    public fun create_safe<I: key + store>(inner: I, ctx: &mut TxContext): OwnerCap {
        let (safe, cap) = new<I>(inner, ctx);
        share_object(safe);

        cap
    }

    public fun auth_transfer<I: key + store, IW: drop, E: drop>(
        nft_id: ID,
        owner_cap: &OwnerCap,
        self: &mut SuiSafe<I>,
        _entity_witness: E,
        entity_id: &UID,
        _inner_witness: IW,
    ) {
        utils::assert_same_module_as_witness<I, IW>();
        assert_owner_cap(owner_cap, self);
        assert_has_nft(&nft_id, self);

        let ref = vec_map::get_mut(&mut self.refs, &nft_id);
        assert_not_exclusively_listed(ref);

        let transfer_auth = TransferAuth {
            entity: type_name::get<E>(),
            entity_id: object::uid_to_inner(entity_id),
        };

        vec_map::insert(&mut ref.auths, get_auth_id(&transfer_auth), transfer_auth);
    }

    public fun auth_exclusive_transfer<I: key + store, IW: drop, E: drop>(
        nft_id: ID,
        owner_cap: &OwnerCap,
        self: &mut SuiSafe<I>,
        _entity_witness: E,
        entity_id: &UID,
        _inner_witness: IW,
    ) {
        utils::assert_same_module_as_witness<I, IW>();
        assert_owner_cap(owner_cap, self);
        assert_has_nft(&nft_id, self);

        let ref = vec_map::get_mut(&mut self.refs, &nft_id);
        // Assert that there are no transfer authorisations
        assert_not_listed(ref);

        let transfer_auth = TransferAuth {
            entity: type_name::get<E>(),
            entity_id: object::uid_to_inner(entity_id),
        };

        option::fill(&mut ref.exclusive_auth, transfer_auth);
    }

    /// Transfer an NFT into the `Safe`.
    public fun deposit_nft<I: key + store, IW: drop, T: key + store>(
        nft: T,
        self: &mut SuiSafe<I>,
        _inner_witness: IW,
    ) {
        utils::assert_same_module_as_witness<I, IW>();

        let nft_id = object::id(&nft);

        vec_map::insert(&mut self.refs, nft_id, NftRef {
            auths: vec_map::empty(),
            exclusive_auth: option::none(),
            object_type: type_name::get<T>(),
        });

        dof::add(&mut self.id, nft_id, nft);

        event::emit(
            DepositEvent {
                safe: object::id(self),
                nft: nft_id,
            }
        );
    }

    /// Use a transfer auth to get an NFT out of the `Safe`.
    public fun transfer_nft_to_recipient<I: key + store, IW: drop, E: drop, T: key + store>(
        entity_witness: E,
        entity_id: &UID,
        nft_id: ID,
        recipient: address,
        self: &mut SuiSafe<I>,
        _inner_witness: IW,
    ) {
        utils::assert_same_module_as_witness<I, IW>();

        let nft = get_nft_for_transfer_<I, E, T>(entity_witness, entity_id, nft_id, self);

        transfer(nft, recipient)
    }


    public fun transfer_nft_to_safe<I: key + store, IW: drop, E: drop, T: key + store>(
        entity_witness: E,
        entity_id: &UID,
        nft_id: ID,
        source: &mut SuiSafe<I>,
        target: &mut SuiSafe<I>,
        inner_witness: IW,
    ) {
        utils::assert_same_module_as_witness<I, IW>();

        let nft = get_nft_for_transfer_<I, E, T>(entity_witness, entity_id, nft_id, source);

        deposit_nft(nft, target, inner_witness);
    }

    public fun get_nft<I: key + store, IW: drop, E: drop, T: key + store>(
        entity_witness: E,
        entity_id: &UID,
        nft_id: ID,
        self: &mut SuiSafe<I>,
        _inner_witness: IW,
    ): T {
        utils::assert_same_module_as_witness<I, IW>();

        let nft = get_nft_for_transfer_<I, E, T>(entity_witness, entity_id, nft_id, self);

        nft
    }

    public fun delist_nft<I: key + store, IW: drop, E: drop>(
        entity_witness: E,
        entity_id: &UID,
        nft_id: ID,
        owner_cap: &OwnerCap,
        self: &mut SuiSafe<I>,
        _inner_witness: IW,
    ) {
        utils::assert_same_module_as_witness<I, IW>();
        assert_owner_cap(owner_cap, self);
        assert_has_nft(&nft_id, self);

        let ref = vec_map::get_mut(&mut self.refs, &nft_id);

        // get nft_ref
        let auth;

        // pop transfer authorisation
        if (!option::is_some(&ref.exclusive_auth)) {
            (_, auth) = vec_map::remove(&mut ref.auths, &get_auth_id_(entity_witness, entity_id));
        } else {
            auth = option::extract(&mut ref.exclusive_auth);
        };

        // check if request has auth to transfer
        // This seems to be redundant on the object_id side
        assert_authorised_entity(type_name::get<E>(), object::uid_to_inner(entity_id), &auth);
    }

    // === Private functions ===

    fun get_nft_for_transfer_<I: key + store, E: drop, T: key + store>(
        entity_witness: E,
        entity_id: &UID,
        nft_id: ID,
        self: &mut SuiSafe<I>,
    ): T {
        event::emit(
            TransferEvent {
                safe: object::id(self),
                nft: nft_id,
            }
        );

        // This pops the NFT reference, which means that it gets rid of all
        // transfer auths, which is desired because it avoids lingering auths
        let (_, ref) = vec_map::remove(&mut self.refs, &nft_id);
        let auth;

        // pop transfer authorisation
        if (!option::is_some(&ref.exclusive_auth)) {
            (_, auth) = vec_map::remove(&mut ref.auths, &get_auth_id_(entity_witness, entity_id));
        } else {
            auth = option::extract(&mut ref.exclusive_auth);
        };

        // check if request has auth to transfer
        // This seems to be redundant on the object_id side
        assert_authorised_entity(type_name::get<E>(), object::uid_to_inner(entity_id), &auth);
        assert_has_nft(&nft_id, self);

        dof::remove<ID, T>(&mut self.id, nft_id)
    }

    fun get_auth_id(auth: &TransferAuth): ID {
        let bytes = ascii::into_bytes(type_name::into_string(auth.entity));

        vector::append(
            &mut bytes,
            object::id_to_bytes(&auth.entity_id)
        );

        object::id_from_bytes(hash::keccak256(&bytes))
    }

    fun get_auth_id_<E: drop>(
        _entity_witness: E,
        entity_id: &UID,
    ): ID {
        let bytes = ascii::into_bytes(
            type_name::into_string(type_name::get<E>())
        );

        vector::append(
            &mut bytes,
            object::uid_to_bytes(entity_id)
        );

        object::id_from_bytes(hash::keccak256(&bytes))
    }

    // // === Getters ===

    public fun check_auth(
        entity_witness: TypeName,
        entity_id: ID,
        auth: &TransferAuth
    ): bool {
        let check_1 = entity_id == auth.entity_id;
        let check_2 = entity_witness == auth.entity;

        check_1 || check_2
    }

    public fun borrow_nft<I: key + store, NFT: key + store>(nft_id: ID, self: &SuiSafe<I>): &NFT {
        dof::borrow<ID, NFT>(&self.id, nft_id)
    }

    public fun has_nft<I: key + store, NFT: key + store>(nft_id: ID, self: &SuiSafe<I>): bool {
        dof::exists_with_type<ID, NFT>(&self.id, nft_id)
    }

    // Getter for OwnerCap's Safe ID
    public fun owner_cap_safe(cap: &OwnerCap): ID {
        cap.safe
    }

    public fun nft_object_type<I: key + store>(nft_id: ID, self: &SuiSafe<I>): TypeName {
        let ref = vec_map::get(&self.refs, &nft_id);
        ref.object_type
    }

    // === Assertions ===

    public fun assert_owner_cap<I: key + store>(cap: &OwnerCap, self: &SuiSafe<I>) {
        assert!(cap.safe == object::id(self), ESAFE_OWNER_MISMATCH);
    }

    public fun assert_has_nft<I: key + store>(nft: &ID, self: &SuiSafe<I>) {
        assert!(vec_map::contains(&self.refs, nft), ESAFE_DOES_NOT_CONTAIN_NFT);
    }

    fun assert_authorised_entity(
        entity_witness: TypeName,
        entity_id: ID,
        auth: &TransferAuth,
    ) {
        assert!(check_auth(entity_witness, entity_id, auth), EENTITY_NOT_AUTHORISED_FOR_TRANSFER);
    }

    fun assert_not_exclusively_listed(ref: &NftRef) {
        assert!(!option::is_some(&ref.exclusive_auth), ENFT_ALREADY_EXCLUSIVELY_LISTED);
    }

    fun assert_not_listed(ref: &NftRef) {
        assert!(vec_map::size(&ref.auths) == 0, ENFT_ALREADY_LISTED);

        assert_not_exclusively_listed(ref);
    }
}
