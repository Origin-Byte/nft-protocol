/// This contract uses the following witnesses:
/// I: Inner Type of the Safe
/// E: Entinty Witness of the entity request transfer authorisation
/// C: NFT Type of a given NFT in the Safe
module nft_protocol::origin_byte {
    use std::option::{Self, Option};
    use std::type_name::TypeName;

    use sui::vec_set::{Self, VecSet};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer::{share_object, transfer};


    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::transfer_allowlist::Allowlist;
    use nft_protocol::sui_safe::{Self, SuiSafe, OwnerCap};

    struct Witness has drop {}

    struct OriginByte has key, store {
        id: UID,
        // TODO: This can be removed if we remove the logical owner
        owner: Option<address>,
        /// Enables depositing any collection, bypassing enabled deposits
        enable_any_deposit: bool,
        /// Collections which can be deposited into the `Safe`
        collections_with_enabled_deposits: VecSet<TypeName>,
    }

    struct DepositEvent has copy, drop {
        safe: ID,
        nft: ID,
    }

    struct TransferEvent has copy, drop {
        safe: ID,
        nft: ID,
    }

    public fun new(ctx: &mut TxContext): (SuiSafe<OriginByte>, OwnerCap) {
        let inner = OriginByte {
            id: object::new(ctx),
            // Note: This may be unsafe, since the caller can inject the wrong
            // owner address
            owner: option::none(),
            enable_any_deposit: true,
            collections_with_enabled_deposits: vec_set::empty(),
        };

        sui_safe::new(inner, ctx)
    }

    /// Instantiates a new shared object `Safe<OriginByte>` and transfer
    /// `OwnerCap` to the tx sender.
    public entry fun create_for_sender(ctx: &mut TxContext) {
        let inner = OriginByte {
            id: object::new(ctx),
            owner: option::some(tx_context::sender(ctx)),
            enable_any_deposit: true,
            collections_with_enabled_deposits: vec_set::empty(),
        };

        let (safe, cap) = sui_safe::new(inner, ctx);

        share_object(safe);
        transfer(cap, tx_context::sender(ctx));
    }

    /// Creates a new `Safe<OriginByte>` shared object and returns the authority capability
    /// that grants authority over this safe.
    public fun create_safe(ctx: &mut TxContext): OwnerCap {
        let inner = OriginByte {
            id: object::new(ctx),
            // Note: This may be unsafe, since the caller can inject the wrong
            // owner address
            owner: option::none(),
            enable_any_deposit: true,
            collections_with_enabled_deposits: vec_set::empty(),
        };

        let (safe, cap) = sui_safe::new(inner, ctx);

        share_object(safe);
        cap
    }

    public fun auth_transfer<Auth: drop, E: drop>(
        nft_id: ID,
        owner_cap: &OwnerCap,
        self: &mut SuiSafe<OriginByte>,
        entity_witness: E,
        entity_id: &UID,
        _authority: Auth,
        _allowlist: &Allowlist,
    ) {
        sui_safe::auth_transfer(nft_id, owner_cap, self, entity_witness, entity_id, Witness {});
    }

    public fun auth_exclusive_transfer<Auth: drop, E: drop>(
        nft_id: ID,
        owner_cap: &OwnerCap,
        self: &mut SuiSafe<OriginByte>,
        entity_witness: E,
        entity_id: &UID,
        _authority: Auth,
        _allowlist: &Allowlist,
    ) {
        sui_safe::auth_transfer(nft_id, owner_cap, self, entity_witness, entity_id, Witness {});
    }

    /// Transfer an NFT into the `Safe`.
    public fun deposit_nft<T: key + store>(
        nft: T,
        self: &mut SuiSafe<OriginByte>,
    ) {
        sui_safe::deposit_nft(nft, self, Witness {});
    }

    /// Use a transfer auth to get an NFT out of the `Safe`.
    public fun transfer_nft_to_recipient<Auth: drop, E: drop, C: key + store>(
        entity_witness: E,
        entity_id: &UID,
        nft_id: ID,
        recipient: address,
        self: &mut SuiSafe<OriginByte>,
        authority: Auth,
        allowlist: &Allowlist,
    ) {
        let nft = sui_safe::get_nft<OriginByte, Witness, E, Nft<C>>(
            entity_witness,
            entity_id,
            nft_id,
            self,
            Witness {},
        );

        // // TODO: Consider deprecating logical owner
        nft::change_logical_owner(&mut nft, recipient, authority, allowlist);

        transfer(nft, recipient)
    }


    public fun transfer_nft_to_safe<Auth: drop, E: drop, C: key + store>(
        entity_witness: E,
        entity_id: &UID,
        nft_id: ID,
        source: &mut SuiSafe<OriginByte>,
        target: &mut SuiSafe<OriginByte>,
        _authority: Auth,
        _allowlist: &Allowlist,
    ) {
        let nft = sui_safe::get_nft<OriginByte, Witness, E, Nft<C>>(
            entity_witness,
            entity_id,
            nft_id,
            source,
            Witness {},
        );

        // TODO: Consider deprecating logical owner
        // TODO: Uncomment this loc
        // nft::change_logical_owner(&mut nft, option::borrow(&target.inner.owner), authority, allowlist);

        deposit_nft(nft, target);
    }

    public fun delist_nft<Auth: drop, E: drop>(
        entity_witness: E,
        entity_id: &UID,
        nft_id: ID,
        owner_cap: &OwnerCap,
        self: &mut SuiSafe<OriginByte>,
        _authority: Auth,
        _allowlist: &Allowlist,
    ) {
        sui_safe::delist_nft(
            entity_witness,
            entity_id,
            nft_id,
            owner_cap,
            self,
            Witness {}
        );

    }

    // // === Getters ===

    // TODO: We need to be consistent, do we use T or C?
    public fun borrow_nft<C: key + store>(nft_id: ID, self: &SuiSafe<OriginByte>): &C {
        sui_safe::borrow_nft(nft_id, self)
    }

    public fun has_nft<T: key + store>(nft_id: ID, self: &SuiSafe<OriginByte>): bool {
        sui_safe::has_nft<OriginByte, T>(nft_id, self)
    }

    // Getter for OwnerCap's Safe ID
    public fun owner_cap_safe(cap: &OwnerCap): ID {
        sui_safe::owner_cap_safe(cap)
    }

    public fun nft_object_type(nft_id: ID, self: &SuiSafe<OriginByte>): TypeName {
        sui_safe::nft_object_type(nft_id, self)
    }
}
