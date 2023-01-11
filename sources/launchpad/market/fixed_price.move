/// Module of a Fixed Price Sale `Market` type.
///
/// It implements a fixed price sale configuration, where all NFTs in the sale
/// warehouse get sold at a fixed price.
///
/// NFT creators can decide if they want to create a simple primary market sale
/// or if they want to create a tiered market sale by segregating NFTs by
/// different sale segments (e.g. based on rarity).
///
/// To create a market sale the administrator can simply call `create_market`.
/// Each sale segment can have a whitelisting process, each with their own
/// whitelist tokens.
module nft_protocol::fixed_price {
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    use nft_protocol::warehouse::{Self, Warehouse};
    use nft_protocol::listing::{Self, Listing, WhitelistCertificate};

    struct FixedPriceMarket<phantom FT> has key, store {
        id: UID,
        price: u64,
    }

    /// Witness used to authenticate witness protected endpoints
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

    /// Creates a `FixedPriceMarket<FT>` and transfers to transaction sender
    public entry fun init_market<FT>(
        price: u64,
        ctx: &mut TxContext,
    ) {
        let market = new<FT>(price, ctx);
        transfer::transfer(market, tx_context::sender(ctx));
    }

    /// Creates a `FixedPriceMarket<FT>` on `Warehouse`
    public entry fun create_market_on_warehouse<FT>(
        warehouse: &mut Warehouse,
        is_whitelisted: bool,
        price: u64,
        ctx: &mut TxContext,
    ) {
        let market = new<FT>(price, ctx);
        warehouse::add_market(warehouse, is_whitelisted, market);
    }

    /// Creates a `FixedPriceMarket<FT>` on `Listing`
    public entry fun create_market_on_listing<FT>(
        listing: &mut Listing,
        warehouse_id: ID,
        is_whitelisted: bool,
        price: u64,
        ctx: &mut TxContext,
    ) {
        let market = new<FT>(price, ctx);
        listing::add_market(listing, warehouse_id, is_whitelisted, market, ctx);
    }

    // === Entrypoints ===

    /// Permissionless endpoint to buy NFT certificates for non-whitelisted sales.
    /// To buy an NFT a user will first buy an NFT certificate. This guarantees
    /// that the slingshot object is in full control of the selection process.
    /// A `NftCertificate` object will be minted and transfered to the sender
    /// of transaction. The sender can then use this certificate to call
    /// `claim_nft` and claim the NFT that has been allocated by the slingshot
    public entry fun buy_nft<C, FT>(
        listing: &mut Listing,
        warehouse_id: ID,
        market_id: ID,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let warehouse =
            listing::warehouse_internal_mut<FixedPriceMarket<FT>, Witness>(
                Witness {}, listing, warehouse_id, market_id
            );

        warehouse::assert_is_not_whitelisted(warehouse, &market_id);

        let funds = buy_nft_<C, FT>(
            warehouse,
            market_id,
            wallet,
            ctx,
        );

        listing::pay(listing, funds, 1);
    }

    /// Permissioned endpoint to buy NFT certificates for whitelisted sales.
    /// To buy an NFT a user will first buy an NFT certificate. This guarantees
    /// that the slingshot object is in full control of the selection process.
    /// A `NftCertificate` object will be minted and transfered to the sender
    /// of transaction. The sender can then use this certificate to call
    /// `claim_nft` and claim the NFT that has been allocated by the slingshot
    public entry fun buy_whitelisted_nft<C, FT>(
        listing: &mut Listing,
        warehouse_id: ID,
        market_id: ID,
        wallet: &mut Coin<FT>,
        whitelist_token: WhitelistCertificate,
        ctx: &mut TxContext,
    ) {
        let warehouse =
            listing::warehouse_internal_mut<FixedPriceMarket<FT>, Witness>(
                Witness {}, listing, warehouse_id, market_id
            );

        warehouse::assert_is_whitelisted(warehouse, &market_id);
        listing::assert_whitelist_certificate_market(market_id, &whitelist_token);

        listing::burn_whitelist_certificate(whitelist_token);

        let funds = buy_nft_<C, FT>(
            warehouse,
            market_id,
            wallet,
            ctx,
        );

        listing::pay(listing, funds, 1);
    }

    fun buy_nft_<C, FT>(
        warehouse: &mut Warehouse,
        market_id: ID,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Balance<FT> {
        warehouse::assert_is_live(warehouse, &market_id);

        let market =
            warehouse::market<FixedPriceMarket<FT>>(warehouse, market_id);
        let funds = balance::split(coin::balance_mut(wallet), market.price);

        let nft = warehouse::redeem_nft<C>(warehouse);
        transfer::transfer(nft, tx_context::sender(ctx));

        funds
    }

    // === Modifier Functions ===

    /// Permissioned endpoint to be called by `admin` to edit the fixed price
    /// of the Listing configuration.
    public entry fun set_price<FT>(
        listing: &mut Listing,
        warehouse_id: ID,
        market_id: ID,
        new_price: u64,
        ctx: &mut TxContext,
    ) {
        listing::assert_listing_admin(listing, ctx);

        let warehouse =
            listing::warehouse_internal_mut<FixedPriceMarket<FT>, Witness>(
                Witness {}, listing, warehouse_id, market_id
            );

        let market = warehouse::market_mut<FixedPriceMarket<FT>>(
            warehouse, market_id,
        );

        market.price = new_price;
    }

    // === Getter Functions ===

    /// Get the market's fixed price
    public fun price<FT>(market: &FixedPriceMarket<FT>): u64 {
        market.price
    }
}
