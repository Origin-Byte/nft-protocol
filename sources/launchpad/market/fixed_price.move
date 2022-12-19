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
module nft_protocol::fixed_price {
    use sui::balance;
    use sui::coin::{Self, Coin};
    use sui::transfer::{Self};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::slot::{Self, Slot, WhitelistCertificate};
    use nft_protocol::launchpad::Launchpad;

    struct FixedPriceMarket<phantom FT> has key, store {
        id: UID,
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
        let market = new<FT>(price, ctx);
        slot::add_market(slot, market, ctx);
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
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        slot::assert_market_is_not_whitelisted(slot, market_id);

        buy_nft_certificate_(
            launchpad,
            slot,
            market_id,
            wallet,
            ctx,
        )
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
        wallet: &mut Coin<FT>,
        whitelist_token: WhitelistCertificate,
        ctx: &mut TxContext,
    ) {
        slot::assert_market_is_whitelisted(slot, market_id);
        slot::assert_whitelist_certificate_market(market_id, &whitelist_token);
        
        slot::burn_whitelist_certificate(whitelist_token);

        buy_nft_certificate_(
            launchpad,
            slot,
            market_id,
            wallet,
            ctx,
        )
    }

    fun buy_nft_certificate_<FT>(
        launchpad: &Launchpad,
        slot: &mut Slot,
        market_id: ID,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        slot::assert_market<FixedPriceMarket<FT>>(slot, market_id);
        slot::assert_is_live(slot);

        let market: &FixedPriceMarket<FT> = slot::market(slot, market_id);

        let funds = balance::split(coin::balance_mut(wallet), market.price);
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
        slot::assert_market<FixedPriceMarket<FT>>(slot, market_id);

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
        slot::assert_market<FixedPriceMarket<FT>>(slot, market_id);

        let market: &FixedPriceMarket<FT> = slot::market(slot, market_id);
        market.price
    }
}
