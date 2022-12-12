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
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::inventory;
    use nft_protocol::launchpad_whitelist::{Self as lp_whitelist, Whitelist};
    use nft_protocol::launchpad::{Self as lp, Launchpad, Slot};

    struct FixedPriceMarket has key, store {
        id: UID,
        live: bool,
        price: u64,
    }

    // === Init functions ===

    /// Creates a fixed price `Launchpad` sale. A sale can be simple or tiered,
    /// that is, a tiered sale `Launchpad` has multiple `Sale` inventorys in its
    /// field `sales`. This funcitonality allows for the creation of tiered
    /// market sales by segregating NFTs by different sale segments
    /// (e.g. based on rarity, or preciousness).
    ///
    /// Lauchpad is set as a shared object with an `admin` that can
    /// call privelleged endpoints.
    ///
    /// To be called by the Witness Module deployed by NFT creator.
    public entry fun create_market(
        launchpad: &Launchpad,
        slot: &mut Slot,
        is_whitelisted: bool,
        price: u64,
        ctx: &mut TxContext,
    ) {
        let inventory = inventory::create(
            is_whitelisted,
            ctx,
        );

        let market = FixedPriceMarket {
            id: object::new(ctx),
            live: false,
            price,
        };

        lp::add_market(
            launchpad,
            slot,
            market,
            inventory,
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
        market_id: ID,
        funds: Coin<FT>,
        ctx: &mut TxContext,
    ) {
        // One can only buy NFT certificates if the slingshot is live
        assert!(lp::live(slot) == true, err::slot_not_live());
        lp::assert_market_is_not_whitelisted(slot, market_id);

        let market: &FixedPriceMarket = lp::market(slot, market_id);
        let change = coin::split<FT>(
            &mut funds,
            market.price,
            ctx,
        );

        transfer::transfer(change, tx_context::sender(ctx));

        lp::pay(
            launchpad,
            slot,
            funds,
            1,
        );

        let certificate = lp::issue_nft_certificate(
            launchpad,
            slot,
            market_id,
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
        market_id: ID,
        funds: Coin<FT>,
        whitelist_token: Whitelist,
        ctx: &mut TxContext,
    ) {
        // One can only buy NFT certificates if the slingshot is live
        assert!(lp::live(slot) == true, err::slot_not_live());

        lp::assert_market_is_whitelisted(slot, market_id);
        lp_whitelist::assert_whitelist_token_market(
            slot,
            market_id,
            &whitelist_token
        );

        let market: &FixedPriceMarket = lp::market(slot, market_id);
        let change = coin::split<FT>(
            &mut funds,
            market.price,
            ctx,
        );

        transfer::transfer(change, tx_context::sender(ctx));

        lp::pay(
            launchpad,
            slot,
            funds,
            1,
        );

        lp_whitelist::burn_whitelist_token(whitelist_token);

        let certificate = lp::issue_nft_certificate(
            launchpad,
            slot,
            market_id,
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
            lp::slot_admin(slot) == tx_context::sender(ctx),
            err::wrong_launchpad_admin()
        );
        lp::sale_on(slot, ctx);
    }

    /// Toggle the Slingshot's `live` to `false` therefore
    /// pausing or stopping the NFT sale. Permissioned endpoint to be called by `admin`.
    public entry fun sale_off(
        slot: &mut Slot,
        ctx: &mut TxContext
    ) {
        assert!(
            lp::slot_admin(slot) == tx_context::sender(ctx),
            err::wrong_launchpad_admin()
        );
        lp::sale_off(slot, ctx);
    }

    /// Permissioned endpoint to be called by `admin` to edit the fixed price
    /// of the launchpad configuration.
    public entry fun new_price(
        slot: &mut Slot,
        market_id: ID,
        new_price: u64,
        ctx: &mut TxContext,
    ) {
        let market = lp::market_mut<FixedPriceMarket>(slot, market_id, ctx);
        market.price = new_price;
    }

    // // === Getter Functions ===

    /// Get the Slingshot Configs's `price`
    public fun price(
        slot: &Slot,
        market_id: ID,
    ): u64 {
        let market: &FixedPriceMarket = lp::market(slot, market_id);
        market.price
    }
}
