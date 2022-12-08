module nft_protocol::restricted_safe {
    use std::type_name::{Self, TypeName};

    use sui::object::{Self, ID, UID};
    use sui::vec_set::{Self, VecSet};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer::{share_object, transfer};

    use nft_protocol::err;
    use nft_protocol::nft::NFT;
    use nft_protocol::transfer_whitelist::Whitelist;
    use nft_protocol::safe::{Self, Safe, TransferCap, OwnerCap};

    struct RestrictedSafe has key, store {
        id: UID,
        inner: Safe,
        /// Enables depositing any collection, bypassing enabled deposits
        enable_any_deposit: bool,
        /// Collections which can be deposited into the `RestrictedSafe`
        collections_with_enabled_deposits: VecSet<TypeName>,
    }

    public fun new(ctx: &mut TxContext): (RestrictedSafe, OwnerCap) {
        let (inner, cap) = safe::new(ctx);
        let safe = RestrictedSafe {
            id: object::new(ctx),
            inner,
            enable_any_deposit: false,
            collections_with_enabled_deposits: vec_set::empty(),
        };

        (safe, cap)
    }

    /// Instantiates a new shared object `RestrictedSafe` and transfer
    /// `OwnerCap` to the tx sender.
    public entry fun create_for_sender(ctx: &mut TxContext) {
        let (safe, cap) = new(ctx);
        share_object(safe);

        transfer(cap, tx_context::sender(ctx));
    }

    /// Creates a new `RestrictedSafe` shared object and returns the
    /// authority capability that grants authority over this safe.
    public fun create_safe(ctx: &mut TxContext): OwnerCap {
        let (safe, cap) = new(ctx);
        share_object(safe);

        cap
    }

    /// Creates a `TransferCap` which must be claimed atomically.
    ///
    /// Otherwise, there's a risk of a race condition as multiple non-exclusive
    /// transfer caps can be created.
    public fun create_transfer_cap(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut RestrictedSafe,
        ctx: &mut TxContext,
    ): TransferCap {
        safe::create_transfer_cap(nft, owner_cap, &mut safe.inner, ctx)
    }

    /// Creates an irrevocable and exclusive transfer cap.
    ///
    /// Useful for trading contracts which cannot claim an NFT atomically.
    public fun create_exclusive_transfer_cap(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut RestrictedSafe,
        ctx: &mut TxContext,
    ): TransferCap {
        safe::create_exclusive_transfer_cap(
            nft, owner_cap, &mut safe.inner, ctx
        )
    }

    /// Only owner or whitelisted collections can deposit.
    public entry fun restrict_deposits(
        owner_cap: &OwnerCap,
        safe: &mut RestrictedSafe,
    ) {
        assert_owner_cap(owner_cap, safe);
        safe.enable_any_deposit = false;
    }

    /// No restriction on deposits.
    public entry fun enable_any_deposit(
        owner_cap: &OwnerCap,
        safe: &mut RestrictedSafe,
    ) {
        assert_owner_cap(owner_cap, safe);
        safe.enable_any_deposit = true;
    }

    /// The owner can restrict deposits into the `RestrictedSafe` from given
    /// collection.
    ///
    /// However, if the flag `RestrictedSafe::enable_any_deposit` is set to
    /// true, then it takes precedence.
    public entry fun disable_deposits_of_collection<C>(
        owner_cap: &OwnerCap,
        safe: &mut RestrictedSafe,
    ) {
        assert_owner_cap(owner_cap, safe);

        let col_type = type_name::get<C>();
        vec_set::remove(&mut safe.collections_with_enabled_deposits, &col_type);
    }

    /// The owner can enable deposits into the `RestrictedSafe` from given
    /// collection.
    ///
    /// However, if the flag `RestrictedSafe::enable_any_deposit` is set to
    /// true, then it takes precedence anyway.
    public entry fun enable_deposits_of_collection<C>(
        owner_cap: &OwnerCap,
        safe: &mut RestrictedSafe,
    ) {
        assert_owner_cap(owner_cap, safe);

        let col_type = type_name::get<C>();
        vec_set::insert(&mut safe.collections_with_enabled_deposits, col_type);
    }

    /// Transfer an NFT into the `RestrictedSafe`.
    ///
    /// Requires that `enable_any_deposit` flag is set to true, or that the
    /// `RestrictedSafe` owner enabled NFTs of given collection to be inserted.
    public entry fun deposit_nft<T>(
        nft: NFT<T>,
        safe: &mut RestrictedSafe,
        ctx: &mut TxContext,
    ) {
        assert_can_deposit<T>(safe);
        safe::deposit_nft(nft, &mut safe.inner, ctx);
    }

    /// Transfer an NFT from owner to the `RestrictedSafe`.
    public entry fun deposit_nft_priviledged<T>(
        nft: NFT<T>,
        owner_cap: &OwnerCap,
        safe: &mut RestrictedSafe,
        ctx: &mut TxContext,
    ) {
        assert_owner_cap(owner_cap, safe);
        safe::deposit_nft(nft, &mut safe.inner, ctx);
    }

    /// Use a transfer cap to get an NFT out of the `RestrictedSafe`.
    ///
    /// If the NFT is not exclusively listed, it can happen that the transfer
    /// cap is no longer valid. The NFT could've been traded or the trading cap
    /// revoked.
    public fun transfer_nft_to_recipient<T, Auth: drop>(
        transfer_cap: TransferCap,
        recipient: address,
        authority: Auth,
        whitelist: &Whitelist,
        safe: &mut Safe,
    ) {
        safe::transfer_nft_to_recipient<T, Auth>(
            transfer_cap, recipient, authority, whitelist, safe
        )
    }

    /// Use a transfer cap to get an NFT out of the `RestrictedSafe`.
    ///
    /// If the NFT is not exclusively listed, it can happen that the transfer
    /// cap is no longer valid. The NFT could've been traded or the trading cap
    /// revoked.
    public fun transfer_nft_to_restricted_recipient<T, Auth: drop>(
        transfer_cap: TransferCap,
        recipient: address,
        authority: Auth,
        whitelist: &Whitelist,
        safe: &mut RestrictedSafe,
    ) {
        safe::transfer_nft_to_recipient<T, Auth>(
            transfer_cap, recipient, authority, whitelist, &mut safe.inner
        )
    }

    /// Use a transfer cap to get an NFT out of source `RestrictedSafe` and
    /// deposit it to the target `Safe`. The recipient address should match the
    /// owner of the target `Safe`.
    ///
    /// If the NFT is not exclusively listed, it can happen that the transfer
    /// cap is no longer valid. The NFT could've been traded or the trading cap
    /// revoked.
    public fun transfer_nft_to_safe<T, Auth: drop>(
        transfer_cap: TransferCap,
        recipient: address,
        authority: Auth,
        whitelist: &Whitelist,
        source: &mut RestrictedSafe,
        target: &mut Safe,
        ctx: &mut TxContext,
    ) {
        safe::transfer_nft_to_safe<T, Auth>(
            transfer_cap,
            recipient,
            authority,
            whitelist,
            &mut source.inner,
            target,
            ctx,
        )
    }

    /// Use a transfer cap to get an NFT out of source `RestrictedSafe` and
    /// deposit it to the target `RestrictedSafe`. The recipient address
    /// should match the owner of the target `RestrictedSafe`.
    ///
    /// If the NFT is not exclusively listed, it can happen that the transfer
    /// cap is no longer valid. The NFT could've been traded or the trading cap
    /// revoked.
    public fun transfer_nft_to_restricted_safe<T, Auth: drop>(
        transfer_cap: TransferCap,
        recipient: address,
        authority: Auth,
        whitelist: &Whitelist,
        source: &mut RestrictedSafe,
        target: &mut RestrictedSafe,
        ctx: &mut TxContext,
    ) {
        safe::transfer_nft_to_safe<T, Auth>(
            transfer_cap,
            recipient,
            authority,
            whitelist,
            &mut source.inner,
            &mut target.inner,
            ctx,
        )
    }

    /// Destroys given transfer cap. This is mainly useful for exclusively listed
    /// NFTs.
    public entry fun burn_transfer_cap(
        transfer_cap: TransferCap,
        safe: &mut RestrictedSafe,
    ) {
        safe::burn_transfer_cap(transfer_cap, &mut safe.inner)
    }

    /// Changes the transfer ref version, thereby invalidating all existing
    /// `TransferCap` objects.
    ///
    /// Can happen only if the NFT is not listed exclusively.
    public entry fun delist_nft(
        nft: ID,
        owner_cap: &OwnerCap,
        safe: &mut RestrictedSafe,
        ctx: &mut TxContext,
    ) {
        safe::delist_nft(nft, owner_cap, &mut safe.inner, ctx)
    }

    // === Getters ===

    public fun has_nft<C>(nft: ID, safe: &RestrictedSafe): bool {
        safe::has_nft<C>(nft, &safe.inner)
    }

    public fun are_all_deposits_enabled(safe: &RestrictedSafe): bool {
        safe.enable_any_deposit
    }

    // === Assertions ===

    public fun assert_owner_cap(cap: &OwnerCap, safe: &RestrictedSafe) {
        safe::assert_owner_cap(cap, &safe.inner)
    }

    public fun assert_transfer_cap_of_safe(cap: &TransferCap, safe: &RestrictedSafe) {
        safe::assert_transfer_cap_of_safe(cap, &safe.inner)
    }

    public fun assert_contains_nft(nft: &ID, safe: &RestrictedSafe) {
        safe::assert_contains_nft(nft, &safe.inner)
    }

    public fun assert_can_deposit<T>(safe: &RestrictedSafe) {
        if (!safe.enable_any_deposit) {
            assert!(
                vec_set::contains(&safe.collections_with_enabled_deposits, &type_name::get<T>()),
                err::safe_does_not_accept_deposits(),
            );
        }
    }

    public fun assert_id(safe: &RestrictedSafe, id: ID) {
        assert!(object::id(&safe.inner) == id, err::safe_id_mismatch());
    }
}
