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

    use nft_protocol::inventory::{Self, Inventory};
    use nft_protocol::slot::{Self, Slot, WhitelistCertificate};
    use nft_protocol::launchpad::Launchpad;

    struct FixedPriceMarket<phantom FT> has key, store {
        id: UID,
        live: bool,
        price: u64,
    }

    struct Witness has drop {}

    // === Init functions ===

    public fun new<FT>(
        price: u64,
        ctx: &mut TxContext,
    ): FixedPriceMarket<FT> {
        FixedPriceMarket {
            id: object::new(ctx),
            live: false,
            price,
        }
    }

    /// Creates a fixed price `Slot` market
    public entry fun init_market<FT>(
        slot: &mut Slot,
        is_whitelisted: bool,
        price: u64,
        ctx: &mut TxContext,
    ) {
        let inventory = inventory::new(
            is_whitelisted,
            ctx,
        );

       init_market_with_inventory<FT>(slot, inventory, price, ctx);
    }

    /// Creates a fixed price `Slot` market with a prepared `Inventory`
    ///
    /// Useful for pre-minting NFTs to an `Inventory`
    //
    // TODO: Make public once Inventory contains NFT
    entry fun init_market_with_inventory<FT>(
        slot: &mut Slot,
        inventory: Inventory,
        price: u64,
        ctx: &mut TxContext,
    ) {
        let market = new<FT>(price, ctx);
        slot::add_market(slot, market, inventory, ctx);
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
        slot::assert_is_live(slot);
        slot::assert_market_is_not_whitelisted(slot, market_id);

        let market: &FixedPriceMarket<FT> = slot::market(slot, market_id);
        let change = coin::split<FT>(
            &mut funds,
            market.price,
            ctx,
        );

        transfer::transfer(change, tx_context::sender(ctx));

        slot::pay(slot, funds, 1);

        let certificate = slot::issue_nft_certificate_internal<
            FixedPriceMarket<FT>, Witness
        >(
            Witness {},
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
        whitelist_token: WhitelistCertificate,
        ctx: &mut TxContext,
    ) {
        slot::assert_is_live(slot);
        slot::assert_market_is_whitelisted(slot, market_id);
        slot::assert_whitelist_certificate_market(market_id, &whitelist_token);

        let market: &FixedPriceMarket<FT> = slot::market(slot, market_id);
        let change = coin::split<FT>(
            &mut funds,
            market.price,
            ctx,
        );

        transfer::transfer(change, tx_context::sender(ctx));

        slot::pay(slot, funds, 1);

        slot::burn_whitelist_certificate(whitelist_token);

        let certificate = slot::issue_nft_certificate_internal<
            FixedPriceMarket<FT>, Witness
        >(
            Witness {},
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

    // === Modifier Functions ===

    /// Permissioned endpoint to be called by `admin` to edit the fixed price
    /// of the launchpad configuration.
    public entry fun set_price<FT>(
        slot: &mut Slot,
        market_id: ID,
        new_price: u64,
        ctx: &mut TxContext,
    ) {
        slot::assert_slot_admin(slot, ctx);

        let market =
            slot::market_mut<FixedPriceMarket<FT>>(slot, market_id, ctx);
        market.price = new_price;
    }

    // === Getter Functions ===

    /// Get the Slingshot Configs's `price`
    public fun price<FT>(
        slot: &Slot,
        market_id: ID,
    ): u64 {
        let market: &FixedPriceMarket<FT> = slot::market(slot, market_id);
        market.price
    }
}
