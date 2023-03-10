module nft_protocol::sui_safe {
    use std::option::{Self, Option};
    use std::type_name::{Self, TypeName};


    use nft_protocol::err;

    use sui::event;
    use sui::object::{Self, ID, UID};
    use sui::transfer::{share_object, transfer};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::dynamic_object_field::{Self as dof};

    // === Errors ===

    /// NFT type is not what the user expected
    const ENFT_TYPE_MISMATCH: u64 = 0;

    struct SuiSafe has key, store {
        id: UID,
        /// Accounting for deposited NFTs. Each NFT in the object bag is
        /// represented in this map.
        refs: VecMap<ID, NftRef>,
    }

    struct NftRef has store, copy, drop {
        // TODO: It only needs VecMap<ID, TypeName>
        auths: VecMap<ID, TransferAuth>,
        exclusive_auth: Option<TransferAuth>,
        object_type: TypeName,
    }

    struct TransferAuth has store, copy, drop {
        witness: TypeName,
        object_id: ID,
    }

    struct Request<phantom W> has copy, drop {
        object_id: ID
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

    public fun new(ctx: &mut TxContext): (SuiSafe, OwnerCap) {
        let safe = SuiSafe {
            id: object::new(ctx),
            refs: vec_map::empty(),
        };

        let cap = OwnerCap {
            id: object::new(ctx),
            safe: object::id(&safe),
        };

        (safe, cap)
    }

    /// Instantiates a new shared object `Safe` and transfer `OwnerCap` to the
    /// tx sender.
    public entry fun create_for_sender(ctx: &mut TxContext) {
        let (safe, cap) = new(ctx);
        share_object(safe);

        transfer(cap, tx_context::sender(ctx));
    }

    /// Creates a new `Safe` shared object and returns the authority capability
    /// that grants authority over this safe.
    public fun create_safe(ctx: &mut TxContext): OwnerCap {
        let (safe, cap) = new(ctx);
        share_object(safe);

        cap
    }


    public fun auth_transfer<W: drop>(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut SuiSafe,
        request: Request<W>,
    ) {
        // TODO: Assert that contract_witness and object ID correspond? How can we even do that?
        assert_owner_cap(owner_cap, safe);
        assert_has_nft(&nft, safe);

        let ref = vec_map::get_mut(&mut safe.refs, &nft);
        assert_not_exclusively_listed(ref);

        let transfer_auth = TransferAuth {
            witness: type_name::get<W>(),
            object_id: request.object_id,
        };

        vec_map::insert(&mut ref.auths, request.object_id, transfer_auth);
    }

    public fun auth_exclusive_transfer<W>(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut SuiSafe,
        request: Request<W>,
    ) {
        assert_owner_cap(owner_cap, safe);
        assert_has_nft(&nft, safe);

        let ref = vec_map::get_mut(&mut safe.refs, &nft);
        // Assert that there are no transfer authorisations
        assert_not_listed(ref);

        let transfer_auth = TransferAuth {
            witness: type_name::get<W>(),
            object_id: request.object_id,
        };

        option::fill(&mut ref.exclusive_auth, transfer_auth);
    }

    /// Transfer an NFT into the `Safe`.
    public fun deposit_nft<T: key + store>(
        nft: T,
        safe: &mut SuiSafe,
    ) {
        let nft_id = object::id(&nft);

        vec_map::insert(&mut safe.refs, nft_id, NftRef {
            auths: vec_map::empty(),
            exclusive_auth: option::none(),
            object_type: type_name::get<T>(),
        });

        dof::add(&mut safe.id, nft_id, nft);

        event::emit(
            DepositEvent {
                safe: object::id(safe),
                nft: nft_id,
            }
        );
    }

    /// Use a transfer auth to get an NFT out of the `Safe`.
    public fun transfer_nft_to_recipient<W, T: key + store>(
        request: Request<W>,
        nft_id: ID,
        recipient: address,
        safe: &mut SuiSafe,
    ) {
        let nft = get_nft_for_transfer_<W, T>(nft_id, request, safe);

        transfer(nft, recipient)
    }


    public fun transfer_nft_to_safe<W, T: key + store>(
        request: Request<W>,
        nft_id: ID,
        source: &mut SuiSafe,
        target: &mut SuiSafe,
    ) {
        let nft = get_nft_for_transfer_<W, T>(nft_id, request, source);

        deposit_nft(nft, target);
    }

    public entry fun delist_nft<W>(
        request: Request<W>,
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut SuiSafe,
    ) {
        assert_owner_cap(owner_cap, safe);
        assert_has_nft(&nft, safe);

        let ref = vec_map::get_mut(&mut safe.refs, &nft);

        // get nft_ref
        let auth;

        // pop transfer authorisation
        if (!option::is_some(&ref.exclusive_auth)) {
            (_, auth) = vec_map::remove(&mut ref.auths, &request.object_id);
        } else {
            auth = option::extract(&mut ref.exclusive_auth);
        };

        // check if request has auth to transfer
        // This seems to be redundant on the object_id side
        assert_authorised_entity(&request, &auth);
    }

    // === Private functions ===

    fun get_nft_for_transfer_<W, T: key + store>(
        nft_id: ID,
        request: Request<W>,
        safe: &mut SuiSafe,
    ): T {
        event::emit(
            TransferEvent {
                safe: object::id(safe),
                nft: nft_id,
            }
        );

        // pop nft_ref
        let (_, ref) = vec_map::remove(&mut safe.refs, &nft_id);
        let auth;

        // pop transfer authorisation
        if (!option::is_some(&ref.exclusive_auth)) {
            (_, auth) = vec_map::remove(&mut ref.auths, &request.object_id);
        } else {
            auth = option::extract(&mut ref.exclusive_auth);
        };

        // check if request has auth to transfer
        // This seems to be redundant on the object_id side
        assert_authorised_entity(&request, &auth);
        assert_has_nft(&nft_id, safe);

        dof::remove<ID, T>(&mut safe.id, nft_id)
    }

    // // === Getters ===

    public fun check_auth<W>(request: &Request<W>, auth: &TransferAuth): bool {
        let check_1 = request.object_id == auth.object_id;
        let check_2 = type_name::get<W>() == auth.witness;

        check_1 || check_2
    }

    // TODO: Should this not be protected?
    public fun borrow_nft<C: key + store>(nft: ID, safe: &SuiSafe): &C {
        dof::borrow<ID, C>(&safe.id, nft)
    }

    public fun has_nft<T: key + store>(nft: ID, safe: &SuiSafe): bool {
        dof::exists_with_type<ID, T>(&safe.id, nft)
    }

    // Getter for OwnerCap's Safe ID
    public fun owner_cap_safe(cap: &OwnerCap): ID {
        cap.safe
    }

    public fun nft_object_type(nft_id: ID, safe: &SuiSafe): TypeName {
        let ref = vec_map::get(&safe.refs, &nft_id);
        ref.object_type
    }


    // === Assertions ===

    public fun assert_owner_cap(cap: &OwnerCap, safe: &SuiSafe) {
        assert!(cap.safe == object::id(safe), err::safe_cap_mismatch());
    }

    public fun assert_has_nft(nft: &ID, safe: &SuiSafe) {
        assert!(
            vec_map::contains(&safe.refs, nft), err::safe_does_not_contain_nft()
        );
    }

    fun assert_authorised_entity<W>(request: &Request<W>, auth: &TransferAuth) {
        assert!(check_auth(request, auth), err::entity_not_authorised_for_transfer());
    }

    fun assert_not_exclusively_listed(ref: &NftRef) {
        assert!(!option::is_some(&ref.exclusive_auth), err::nft_exclusively_listed());
    }

    fun assert_not_listed(ref: &NftRef) {
        assert_not_exclusively_listed(ref);

        assert!(vec_map::size(&ref.auths) == 0, err::nft_listed())
    }
}
