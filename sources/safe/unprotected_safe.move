/// Module of `UnprotectedSafe` type.
///
/// `UnprotectedSafe` is an abstraction meant to hold NFTs in it.
/// A user that transfers its NFTs to its Safe is able to delegate the power
/// of transferability.
/// One typical issue with on-chain trading is that by sending one's assets
/// to a shared object (the trading primitive), one looses the ability to
/// see them in their wallet, even though one has still technical ownership
/// of such assets, until a trade is effectively executed.
/// To solve for this, we use `UnprotectedSafe` to hold the user's assets
/// and then instead of transferring the assets to the shared object
/// (trading primitive), the user transfers a `TransferCap`
/// `TransferCap` is an object that delegates the ability to transfer a
/// given NFT out of the seller's `Safe`.
///
/// The ownership model of the `Safe` relies on the object `OwnerCap` whose
/// holder is the effective owner of the `Safe` and subsequently the owner of
/// the assets within it.
///
/// # Two NFT kinds
/// We support two kinds of NFTs in this safe implementation.
/// 1. Our protocol `nft_protocol::nft::Nft` which is guarded with allowlist.
/// This enables creators to have certain guarantees around royalty
/// enforcement.
/// 2. Arbitrary type of NFTs.
/// Those are not guarded with allowlist.
/// They can be freely transferred between users and safes.
module nft_protocol::unprotected_safe {
    use std::type_name::{Self, TypeName};

    use nft_protocol::err;
    use nft_protocol::transfer_allowlist::{Self, Allowlist};

    use sui::event;
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::vec_map::{Self, VecMap};
    use sui::dynamic_object_field::{Self as dof};

    // === Errors ===

    /// NFT type is not what the user expected
    const ENFT_TYPE_MISMATCH: u64 = 0;

    struct UnprotectedSafe has key, store {
        id: UID,
        /// Accounting for deposited NFTs. Each NFT in the object bag is
        /// represented in this map.
        refs: VecMap<ID, NftRef>,
    }

    /// Keeps info about an NFT which enables us to issue transfer caps etc.
    struct NftRef has store, drop {
        /// Is generated anew every time a counter is incremented from zero to
        /// one.
        ///
        /// We don't use monotonically increasing integer so that we can remove
        /// withdrawn NFTs from the map.
        version: ID,
        /// Only one `TransferCap` of the latest version can exist.
        /// An exclusively listed NFT cannot have its `TransferCap` revoked.
        is_exclusively_listed: bool,
        /// What's the NFT type.
        ///
        /// If it's not generic, it will contain the `Nft<C>` wrapper.
        object_type: TypeName,
    }

    /// Whoever owns this object can perform some admin actions against the
    /// `Safe` shared object with the corresponding id.
    struct OwnerCap has key, store {
        /// `OwnerCap` ID
        id: UID,
        /// `Safe` ID in which the NFT belonging to this `OwnerCap` is
        /// deposited
        safe: ID,
        /// NFT ID that is associated with this `OwnerCap`
        nft_id: ID,
    }

    /// Enables the owner to transfer given NFT out of the `Safe`.
    struct TransferCap has key, store {
        /// `TransferCap` ID
        id: UID,
        /// `Safe` ID that can be withdrawn from using this `TransferCap`
        safe: ID,
        /// ID of `OwnerCap` that was used to create this `TransferCap`
        owner_cap_id: ID,
        /// `TransferCap` version
        ///
        /// Used to invalidate `TransferCap` should exclusive `TransferCap` be
        /// created.
        version: ID,
        /// If set to true, only one `TransferCap` can be issued for this NFT.
        /// It also cannot be revoked without burning this object.
        ///
        /// This is useful for trading flows that cannot guarantee that the NFT
        /// is claimed atomically.
        ///
        /// If an NFT is listed exclusively, it cannot be revoked without
        /// burning the `TransferCap` first.
        is_exclusive: bool,
        /// NFT type
        object_type: TypeName,
    }

    struct DepositEvent has copy, drop {
        safe: ID,
        nft: ID,
    }

    struct TransferEvent has copy, drop {
        safe: ID,
        nft: ID,
    }

    /// Create a new `UnprotectedSafe`
    public fun new(ctx: &mut TxContext): UnprotectedSafe {
        UnprotectedSafe {
            id: object::new(ctx),
            refs: vec_map::empty(),
        }
    }

    /// Create a new `UnprotectedSafe` and share it
    public entry fun init_safe(ctx: &mut TxContext) {
        transfer::share_object(new(ctx))
    }

    /// Creates a revocable `TransferCap`
    ///
    /// Multiple non-exclusive transfer caps may be created resulting in a risk
    /// of a race condition. In order to create an exclusive `TransferCap`,
    /// call `create_exclusive_transfer_cap`.
    ///
    /// To re-list an NFT that has been exclusively listed call
    /// `burn_transfer_cap` with the exclusive `TransferCap`.
    ///
    /// #### Panics
    ///
    /// - `OwnerCap` does not match `UnprotectedSafe`
    /// - `UnprotectedSafe` does not contain NFT
    /// - NFT is exclusively listed
    public fun create_transfer_cap(
        owner_cap: &OwnerCap,
        safe: &mut UnprotectedSafe,
        ctx: &mut TxContext,
    ): TransferCap {
        let ref = borrow_ref_from_owner_cap_mut(owner_cap, safe);
        assert_not_exclusively_listed_internal(ref);

        TransferCap {
            id: object::new(ctx),
            is_exclusive: false,
            owner_cap_id: object::id(owner_cap),
            safe: object::id(safe),
            version: ref.version,
            object_type: ref.object_type,
        }
    }

    /// Creates an irrevocable and exclusive `TransferCap`
    ///
    /// Will invalidate all previously issued `TransferCap` assuming that NFT
    /// is not already exclusively listed.
    ///
    /// Useful for trading contracts which cannot claim an NFT atomically.
    ///
    /// To re-list an NFT that has been exclusively listed call
    /// `burn_transfer_cap` with the exclusive `TransferCap`.
    ///
    /// #### Panics
    ///
    /// - `OwnerCap` does not match `UnprotectedSafe`
    /// - `UnprotectedSafe` does not contain NFT
    /// - NFT is exclusively listed
    public fun create_exclusive_transfer_cap(
        owner_cap: &OwnerCap,
        safe: &mut UnprotectedSafe,
        ctx: &mut TxContext,
    ): TransferCap {
        let ref = borrow_ref_from_owner_cap_mut(owner_cap, safe);
        assert_not_exclusively_listed_internal(ref);

        ref.is_exclusively_listed = true;
        // Invalidate all previously issued `TransferCap`
        ref.version = new_id(ctx);

        TransferCap {
            id: object::new(ctx),
            is_exclusive: true,
            owner_cap_id: object::id(owner_cap),
            safe: object::id(safe),
            version: ref.version,
            object_type: ref.object_type,
        }
    }

    /// Transfer an NFT into the `Safe`
    public fun deposit_nft<T: key + store>(
        nft: T,
        safe: &mut UnprotectedSafe,
        ctx: &mut TxContext,
    ): OwnerCap {
        // Deposits NFT into a dynamic field whose ID corresponds to the ID of
        // the `OwnerCap` object.
        //
        // Should NFT ever be withdrawn or a new `OwnerCap` issued for the same
        // NFT (due to a transfer of ownership) then all previous owner
        // capabilities will be invalidated.
        let owner_cap_id = object::new(ctx);
        let nft_id = object::id(&nft);

        let version = object::uid_to_inner(&owner_cap_id);
        vec_map::insert(&mut safe.refs, version, NftRef {
            // Use `OwnerCap` ID as the initial version to avoid generating a
            // new ID.
            version,
            is_exclusively_listed: false,
            object_type: type_name::get<T>(),
        });

        // Deposit NFT under `OwnerCap` ID
        dof::add(&mut safe.id, version, nft);

        event::emit(
            DepositEvent {
                safe: object::id(safe),
                nft: nft_id,
            }
        );

        OwnerCap {
            id: owner_cap_id,
            safe: object::uid_to_inner(&safe.id),
            nft_id,
        }
    }

    /// Withdraw NFT out of `UnprotectedSafe` to an address
    ///
    /// Performing this action will invalidate any `OwnerCap` or `TransferCap`.
    ///
    /// If the NFT is not exclusively listed, it can happen that the
    /// `TransferCap` is no longer valid.
    /// The NFT could have already been traded or the trading cap revoked.
    public fun withdraw_nft<T: key + store, Auth: drop>(
        transfer_cap: TransferCap,
        safe: &mut UnprotectedSafe,
        allowlist: &Allowlist,
        authority: Auth,
    ): T {
        // TODO: Cannot take `T`
        transfer_allowlist::assert_collection<T>(allowlist);
        transfer_allowlist::assert_authority<Auth>(allowlist);

        // Assert that `TransferCap` is allowed to withdraw from
        // `UnprotectedSafe`
        assert_valid_transfer_cap(&transfer_cap, safe);

        let (_, ref) =
            vec_map::remove(&mut safe.refs, &transfer_cap.owner_cap_id);
        assert_version_match(&ref, &transfer_cap);

        let nft = dof::remove<ID, T>(&mut safe.id, transfer_cap.owner_cap_id);

        event::emit(
            TransferEvent {
                safe: object::id(safe),
                nft: object::id(&nft),
            }
        );

        burn_transfer_cap(transfer_cap, safe);

        nft
    }

    /// Transfer NFT out of `UnprotectedSafe` to an address
    ///
    /// See `withdraw_nft` for more info.
    public fun transfer_nft_to_recipient<T: key + store, Auth: drop>(
        transfer_cap: TransferCap,
        safe: &mut UnprotectedSafe,
        allowlist: &Allowlist,
        authority: Auth,
        recipient: address,
    ) {
        let nft =
            withdraw_nft<T, Auth>(transfer_cap, safe, allowlist, authority);
        transfer::transfer(nft, recipient);
    }

    /// Transfer NFT out of `UnprotectedSafe` to another `UnprotectedSafe`
    ///
    /// See `withdraw_nft` for more info.
    public fun transfer_nft_to_safe<T: key + store, Auth: drop>(
        transfer_cap: TransferCap,
        source: &mut UnprotectedSafe,
        target: &mut UnprotectedSafe,
        allowlist: &Allowlist,
        authority: Auth,
        ctx: &mut TxContext,
    ): OwnerCap {
        let nft =
            withdraw_nft<T, Auth>(transfer_cap, source, allowlist, authority);
        deposit_nft(nft, target, ctx)
    }

    /// Destroys `TransferCap`
    ///
    /// Necessary for destroying exclusive `TransferCap` such that future
    /// transfer capabilities may be issued.
    ///
    /// #### Panics
    ///
    /// Panics if `TransferCap` does not match `UnprotectedSafe`
    public entry fun burn_transfer_cap(
        transfer_cap: TransferCap,
        safe: &mut UnprotectedSafe,
    ) {
        // Check that `TransferCap` is exclusive and latest so that we can
        // disable the exclusive lock on the NFT.
        //
        // Don't need to regenerate version as no other `TransferCap` may exist
        // when an exclusive `TransferCap` is issued.
        //
        // Burning non-exclusive `TransferCap` is a no-op eitherway.
        let ref = borrow_ref_from_transfer_cap_mut(&transfer_cap, safe);
        if (transfer_cap.is_exclusive && ref.version == transfer_cap.version) {
            ref.is_exclusively_listed = false;
        };

        let TransferCap {
            id,
            is_exclusive,
            owner_cap_id,
            safe,
            version,
            object_type,
        } = transfer_cap;

        object::delete(id);
    }

    /// Invalidates all existing `TransferCap` objects
    ///
    /// #### Panics
    ///
    /// - `OwnerCap` does not match `UnprotectedSafe`
    /// - `UnprotectedSafe` does not contain NFT
    /// - NFT is exclusively listed
    public entry fun delist_nft(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut UnprotectedSafe,
        ctx: &mut TxContext,
    ) {
        let ref = borrow_ref_from_owner_cap_mut(owner_cap, safe);
        assert_not_exclusively_listed_internal(ref);

        ref.version = new_id(ctx);
    }

    // === Private functions ===

    /// Generates a unique ID.
    fun new_id(ctx: &mut TxContext): ID {
        let new_uid = object::new(ctx);
        let new_id = object::uid_to_inner(&new_uid);
        object::delete(new_uid);
        new_id
    }

    fun borrow_ref_from_owner_cap_mut(
        owner_cap: &OwnerCap,
        safe: &mut UnprotectedSafe,
    ): &mut NftRef {
        assert_valid_owner_cap(owner_cap, safe);
        vec_map::get_mut(&mut safe.refs, &object::id(owner_cap))
    }

    fun borrow_ref_from_transfer_cap_mut(
        transfer_cap: &TransferCap,
        safe: &mut UnprotectedSafe,
    ): &mut NftRef {
        assert_valid_transfer_cap(transfer_cap, safe);
        vec_map::get_mut(&mut safe.refs, &transfer_cap.owner_cap_id)
    }

    // === Getters ===

    public fun borrow_nft<C: key + store>(nft: ID, safe: &UnprotectedSafe): &C {
        dof::borrow<ID, C>(&safe.id, nft)
    }

    public fun has_nft<T: key + store>(nft: ID, safe: &UnprotectedSafe): bool {
        dof::exists_with_type<ID, T>(&safe.id, nft)
    }

    public fun owner_cap_safe(cap: &OwnerCap): ID {
        cap.safe
    }

    public fun transfer_cap_safe(cap: &TransferCap): ID {
        cap.safe
    }

    public fun transfer_cap_object_type(cap: &TransferCap): TypeName {
        cap.object_type
    }

    public fun transfer_cap_is_exclusive(cap: &TransferCap): bool {
        cap.is_exclusive
    }

    // === Assertions ===

    /// Asserts that `OwnerCap` is valid for this `UnprotectedSafe` and that
    /// NFT is still deposited.
    public fun assert_valid_owner_cap(
        owner_cap: &OwnerCap,
        safe: &UnprotectedSafe,
    ) {
        assert!(
            &owner_cap.safe == &object::id(safe),
            err::safe_cap_mismatch(),
        );
        assert!(
            vec_map::contains(&safe.refs, &object::id(owner_cap)),
            err::safe_does_not_contain_nft(),
        );
    }

    /// Assert that `TransferCap` is valid to redeem NFT from `UnprotectedSafe`
    public fun assert_valid_transfer_cap(
        transfer_cap: &TransferCap,
        safe: &UnprotectedSafe,
    ) {
        assert!(
            &transfer_cap.safe == &object::id(safe),
            err::safe_cap_mismatch(),
        );
        assert!(
            vec_map::contains(&safe.refs, &transfer_cap.owner_cap_id),
            err::safe_does_not_contain_nft(),
        );
    }

    public fun assert_not_exclusively_listed(cap: &TransferCap) {
        assert!(!cap.is_exclusive, err::nft_exclusively_listed());
    }

    public fun assert_id(safe: &UnprotectedSafe, id: ID) {
        assert!(object::id(safe) == id, err::safe_id_mismatch());
    }

    public fun assert_transfer_cap_exclusive(cap: &TransferCap) {
        assert!(cap.is_exclusive, err::nft_not_exclusively_listed());
    }

    fun assert_version_match(ref: &NftRef, cap: &TransferCap) {
        assert!(ref.version == cap.version, err::transfer_cap_expired());
    }

    fun assert_not_exclusively_listed_internal(ref: &NftRef) {
        assert!(!ref.is_exclusively_listed, err::nft_exclusively_listed());
    }
}
