//! Module of a Fixed Price Sale `Market` type.
//!
//! It implments a fixed price launchpad configuration.
//!
//! NFT creators can decide if they want to create a simple primary market sale
//! via `create_single_market` or if they want to create a tiered market sale
//! by segregating NFTs by different sale segments (e.g. based on rarity).
//!
//! Each sale segment can have a whitelisting process, each with their own
//! whitelist tokens.
//!
//! TODO: Consider if we want to be able to delete the launchpad object
//! TODO: Remove code duplication between `buy_nft_certificate` and
//! `buy_whitelisted_nft_certificate`
module nft_protocol::fixed_price {
    use sui::coin::{Self, Coin};
    use sui::transfer::{Self};
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::object_box;
    use nft_protocol::outlet::{Self, Outlet};
    use nft_protocol::whitelist::{Self, Whitelist};
    use nft_protocol::launchpad::{Self, Launchpad, Slot};

    struct FixedPriceMarket has key, store {
        id: UID,
        live: bool,
        outlet: Outlet,
        price: u64,
    }

    // === Functions exposed to Witness Module ===

    /// Creates a fixed price `Launchpad` sale. A sale can be simple or tiered,
    /// that is, a tiered sale `Launchpad` has multiple `Sale` outlets in its
    /// field `sales`. This funcitonality allows for the creation of tiered
    /// market sales by segregating NFTs by different sale segments
    /// (e.g. based on rarity, or preciousness).
    ///
    /// Lauchpad is set as a shared object with an `admin` that can
    /// call privelleged endpoints.
    ///
    /// To be called by the Witness Module deployed by NFT creator.
    public fun create_market(
        launchpad: &Launchpad,
        slot: &mut Slot,
        is_whitelisted: bool,
        price: u64,
        ctx: &mut TxContext,
    ) {
        let outlet = outlet::create(
            is_whitelisted,
            ctx,
        );

        let market = object_box::empty(ctx);

        object_box::add(
            &mut market,
            FixedPriceMarket {
                id: object::new(ctx),
                live: false,
                outlet,
                price,
            }
        );

        launchpad::add_market(
            launchpad,
            slot,
            market,
            ctx,
        );
    }

    // === Entrypoints ===

    /// Permissionless endpoint to buy NFT certificates for non-whitelisted sales.
    /// To buy an NFT a user will first buy an NFT certificate. This guarantees
    /// that the slingshot object is in full control of the selection process.
    /// A `NftCertificate` object will be minted and transfered to the sender
    /// of transaction. The sender can then use this certificate to call
    /// `claim_nft` and claim the NFT that has been allocated by the slingshot
    public entry fun buy_nft_certificate<FT>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        funds: Coin<FT>,
        market: &mut FixedPriceMarket,
        ctx: &mut TxContext,
    ) {
        // One can only buy NFT certificates if the slingshot is live
        assert!(launchpad::live(slot) == true, err::launchpad_not_live());

        // Infer that sales is NOT whitelisted
        assert!(
            !outlet::whitelisted(&market.outlet),
            err::sale_is_not_whitelisted()
        );

        let change = coin::split<FT>(
            &mut funds,
            market.price,
            ctx,
        );

        transfer::transfer(change, tx_context::sender(ctx));

        launchpad::pay(
            launchpad,
            slot,
            funds,
            1,
            ctx,
        );

        let certificate = outlet::issue_nft_certificate(
            &mut market.outlet,
            launchpad::launchpad_id(launchpad),
            launchpad::slot_id(slot),
            ctx
        );

        transfer::transfer(
            certificate,
            tx_context::sender(ctx),
        );
    }

    /// Permissioned endpoint to buy NFT certificates for whitelisted sales.
    /// To buy an NFT a user will first buy an NFT certificate. This guarantees
    /// that the slingshot object is in full control of the selection process.
    /// A `NftCertificate` object will be minted and transfered to the sender
    /// of transaction. The sender can then use this certificate to call
    /// `claim_nft` and claim the NFT that has been allocated by the slingshot
    public entry fun buy_whitelisted_nft_certificate<FT>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        funds: Coin<FT>,
        market: &mut FixedPriceMarket,
        whitelist_token: Whitelist,
        ctx: &mut TxContext,
    ) {
        // One can only buy NFT certificates if the slingshot is live
        assert!(launchpad::live(slot) == true, err::launchpad_not_live());

        let launchpad_id = launchpad::slot_id(slot);

        // Infer that sales is whitelisted
        assert!(
            outlet::whitelisted(&market.outlet),
            err::sale_is_whitelisted(),
        );

        // Infer that whitelist token corresponds to correct sale outlet
        assert!(
            whitelist::sale_id(&whitelist_token) == outlet::id(&market.outlet),
            err::incorrect_whitelist_token()
        );

        let change = coin::split<FT>(
            &mut funds,
            market.price,
            ctx,
        );

        transfer::transfer(change, tx_context::sender(ctx));

        launchpad::pay(
            launchpad,
            slot,
            funds,
            1,
            ctx,
        );

        whitelist::burn_whitelist_token(whitelist_token);

        let certificate = outlet::issue_nft_certificate(
            &mut market.outlet,
            launchpad_id,
            launchpad::slot_id(slot),
            ctx
        );

        transfer::transfer(
            certificate,
            tx_context::sender(ctx),
        );
    }

    // // === Modifier Functions ===

    /// Toggle the Slingshot's `live` to `true` therefore
    /// making the NFT sale live. Permissioned endpoint to be called by `admin`.
    public entry fun sale_on(
        slot: &mut Slot,
        ctx: &mut TxContext
    ) {
        assert!(
            launchpad::admin(slot) == tx_context::sender(ctx),
            err::wrong_launchpad_admin()
        );
        launchpad::sale_on(slot, ctx);
    }

    /// Toggle the Slingshot's `live` to `false` therefore
    /// pausing or stopping the NFT sale. Permissioned endpoint to be called by `admin`.
    public entry fun sale_off(
        slot: &mut Slot,
        ctx: &mut TxContext
    ) {
        assert!(
            launchpad::admin(slot) == tx_context::sender(ctx),
            err::wrong_launchpad_admin()
        );
        launchpad::sale_off(slot, ctx);
    }

    /// Permissioned endpoint to be called by `admin` to edit the fixed price
    /// of the launchpad configuration.
    public entry fun new_price(
        slot: &mut Slot,
        market: &mut FixedPriceMarket,
        new_price: u64,
        ctx: &mut TxContext,
    ) {
        assert!(
            launchpad::admin(slot) == tx_context::sender(ctx),
            err::wrong_launchpad_admin()
        );

        market.price = new_price;
    }

    // // === Getter Functions ===

    /// Get the Slingshot Configs's `price`
    public fun price(
        market: &FixedPriceMarket,
    ): u64 {
        market.price
    }
}
