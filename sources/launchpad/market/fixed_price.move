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
    use std::vector;
    
    use sui::sui::{SUI};
    use sui::transfer::{Self};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    
    use nft_protocol::err;
    use nft_protocol::slingshot::{Self, Slingshot};
    use nft_protocol::sale::{Self};
    use nft_protocol::whitelist::{Self, Whitelist};
    
    struct FixedPriceMarket has key, store {
        id: UID,
        price: u64,
    }

    // === Functions exposed to Witness Module ===

    /// Creates a fixed price single market `Launchpad`, that is, a Launchpad 
    /// with a single `Sale` outlet in its field `sales`. Lauchpad is set as 
    /// a shared object with an `admin` that can call privelleged endpoints.
    /// 
    /// To be called by the Witness Module deployed by NFT creator.
    public fun create_single_market<T: drop>(
        witness: T,
        admin: address,
        receiver: address,
        is_embedded: bool,
        whitelist: bool,
        price: u64,
        ctx: &mut TxContext,
    ) {
        let market = FixedPriceMarket {
            id: object::new(ctx),
            price,
        };

        let sale = vector::singleton(
            sale::create<T, FixedPriceMarket>(
                0,
                whitelist,
                market,
                ctx,
            )
        );

        let args = slingshot::init_args(
            admin,
            receiver,
            is_embedded
        );
        
        slingshot::create<T, FixedPriceMarket>(
            witness,
            sale,
            args,
            ctx,
        );
    }

    /// Creates a fixed price multi market `Launchpad`, that is, a Launchpad 
    /// with a multiple `Sale` outlets in its field `sales`. This funcitonality
    /// allows for the creation of tiered amrket sales by segregating NFTs 
    /// by different sale segments (e.g. based on rarity, or preciousness).
    /// 
    /// Lauchpad is set as a shared object with an `admin` that can
    /// call privelleged endpoints.
    /// 
    /// To be called by the Witness Module deployed by NFT creator.
    public fun create_multi_market<T: drop>(
        witness: T,
        admin: address,
        receiver: address,
        is_embedded: bool,
        prices: vector<u64>,
        whitelists: vector<bool>,
        ctx: &mut TxContext,
    ) {
        let len = vector::length(&prices);
        let sales = vector::empty();

        let index = 0;

        while (len > 0) {
            let price = vector::pop_back(&mut prices);
            let whitelist = vector::pop_back(&mut whitelists);

            let market = FixedPriceMarket {
                id: object::new(ctx),
                price,
            };

            let sale = sale::create<T, FixedPriceMarket>(
                0,
                whitelist,
                market,
                ctx,
            );

            vector::push_back(&mut sales, sale);
            
            len = len - 1;
            index = index + 1;
        };

        let args = slingshot::init_args(
            admin,
            receiver,
            is_embedded,
        );
        
        slingshot::create<T, FixedPriceMarket>(
            witness,
            sales,
            args,
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
    public entry fun buy_nft_certificate<T>(
        wallet: &mut Coin<SUI>,
        slingshot: &mut Slingshot<T, FixedPriceMarket>,
        tier_index: u64,
        ctx: &mut TxContext,
    ) {
        // One can only buy NFT certificates if the slingshot is live
        assert!(slingshot::live(slingshot) == true, err::launchpad_not_live());
        
        let receiver = slingshot::receiver(slingshot);
        let sale = slingshot::sale_mut(slingshot, tier_index);

        // Infer that sales is NOT whitelisted
        assert!(!sale::whitelisted(sale), err::sale_is_not_whitelisted());

        let market = sale::market(sale);

        let price = market.price;

        assert!(coin::value(wallet) > price, err::coin_amount_below_price());

        // Split coin into price and change, then transfer 
        // the price and keep the change
        coin::split_and_transfer<SUI>(
            wallet,
            price,
            receiver,
            ctx
        );

        let certificate = sale::issue_nft_certificate(sale, ctx);

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
    public entry fun buy_whitelisted_nft_certificate<T>(
        wallet: &mut Coin<SUI>,
        slingshot: &mut Slingshot<T, FixedPriceMarket>,
        tier_index: u64,
        whitelist_token: Whitelist,
        ctx: &mut TxContext,
    ) {
        // One can only buy NFT certificates if the slingshot is live
        assert!(slingshot::live(slingshot) == true, err::launchpad_not_live());

        let receiver = slingshot::receiver(slingshot);
        let sale = slingshot::sale_mut(slingshot, tier_index);

        // Infer that sales is whitelisted
        assert!(sale::whitelisted(sale), err::sale_is_whitelisted());

        // Infer that whitelist token corresponds to correct sale outlet
        assert!(
            whitelist::sale_id(&whitelist_token) == sale::id(sale),
            err::incorrect_whitelist_token()
        );

        let market = sale::market(sale);

        let price = market.price;

        assert!(coin::value(wallet) > price, err::coin_amount_below_price());

        // Split coin into price and change, then transfer 
        // the price and keep the change
        coin::split_and_transfer<SUI>(
            wallet,
            price,
            receiver,
            ctx
        );

        whitelist::burn_whitelist_token(whitelist_token);
        let certificate = sale::issue_nft_certificate(sale, ctx);

        transfer::transfer(
            certificate,
            tx_context::sender(ctx),
        );
    }

    // // === Modifier Functions ===

    /// Toggle the Slingshot's `live` to `true` therefore 
    /// making the NFT sale live.
    public entry fun sale_on<T>(
        slingshot: &mut Slingshot<T, FixedPriceMarket>,
    ) {
        slingshot::sale_on(slingshot);
    }

    /// Toggle the Slingshot's `live` to `false` therefore 
    /// pausing or stopping the NFT sale.
    public entry fun sale_off<T>(
        slingshot: &mut Slingshot<T, FixedPriceMarket>,
    ) {
        slingshot::sale_off(slingshot);
    }

    /// Permissioned endpoint to be called by `admin` to edit the fixed price 
    /// of the launchpad configuration.
    public entry fun new_price<T>(
        slingshot: &mut Slingshot<T, FixedPriceMarket>,
        sale_index: u64,
        new_price: u64,
        ctx: &mut TxContext,
    ) {
        assert!(
            slingshot::admin(slingshot) == tx_context::sender(ctx),
            err::wrong_launchpad_admin()
        );

        let sale = slingshot::sale_mut(slingshot, sale_index);

        sale::market_mut(sale).price = new_price;
    }

    // // === Getter Functions ===

    /// Get the Slingshot Configs's `price`
    public fun price(
        market: &FixedPriceMarket,
    ): u64 {
        market.price
    }
}