/// Module of a Fixed Initial NFT Offering `Config` type.
/// 
/// It implments a fixed price launchpad configuration.
/// 
/// TODO: When deleting the slingshot, we should guarantee that no nft is still
/// owned by the slingshot object. the fact that the vector `nfts` does not 
/// mean the slingshot has no ownership of nfts since there may be certificates 
/// to be claimed. We should therefore consider an alternative approach
module nft_protocol::fixed_price {
    use std::vector;
    
    use sui::sui::{SUI};
    use sui::transfer::{Self};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::slingshot::{Self, Slingshot};
    use nft_protocol::sale::{Self, NftCertificate};

    struct FixedPriceMarket has drop {}
    
    struct Market has key, store {
        id: UID,
        price: u64,
    }

    public entry fun create_single_market(
        collection_id: ID,
        admin: address,
        receiver: address,
        is_embedded: bool,
        whitelist: bool,
        price: u64,
        ctx: &mut TxContext,
    ) {
        let market = Market {
            id: object::new(ctx),
            price,
        };

        let sale = vector::singleton(
            sale::create(
                FixedPriceMarket {},
                0,
                whitelist,
                market,
                ctx,
            )
        );

        let args = slingshot::init_args(
            collection_id,
            admin,
            receiver,
            is_embedded
        );
        
        slingshot::create<FixedPriceMarket, Market>(
            FixedPriceMarket {},
            sale,
            args,
            ctx,
        );
    }

    public entry fun create_multi_market(
        collection_id: ID,
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

            let market = Market {
                id: object::new(ctx),
                price,
            };

            let sale = sale::create(
                FixedPriceMarket {},
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
            collection_id,
            admin,
            receiver,
            is_embedded,
        );
        
        slingshot::create<FixedPriceMarket, Market>(
            FixedPriceMarket {},
            sales,
            args,
            ctx,
        );
    }

    /// To buy an NFT a user will first buy an NFT certificate. This guarantees
    /// that the slingshot object is in full control of the selection process.
    /// A `NftCertificate` object will be minted and transfered to the sender
    /// of transaction. The sender can then use this certificate to call
    /// `claim_nft` and claim the NFT that has been allocated by the slingshot
    public entry fun buy_nft_certificate(
        wallet: &mut Coin<SUI>,
        slingshot: &mut Slingshot<FixedPriceMarket, Market>,
        tier_index: u64,
        ctx: &mut TxContext,
    ) {
        let receiver = slingshot::receiver(slingshot);

        // One can only buy NFT certificates if the slingshot is live
        assert!(slingshot::live(slingshot) == true, 0);

        let sale = slingshot::sale_mut(slingshot, tier_index);
        let market = sale::market(sale);

        let price = market.price;

        assert!(coin::value(wallet) > price, 0);

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
    
    /// Once the user has bought an NFT certificate, this method can be called
    /// to claim/redeem the NFT that has been allocated by the launchpad. The
    /// `NFTOwned` object in the function signature should correspond to the 
    /// NFT ID mentioned in the certificate.
    /// 
    /// We add the slingshot as a phantom parameter since it is the parent object
    /// of the NFT. Since the slingshot is a shared object anyone can mention it
    /// in the function signature and therefore be able to mention its child
    /// objects as well, the NFTs owned by it.
    public entry fun claim_nft_embedded<D: store>(
        slingshot: &Slingshot<FixedPriceMarket, Market>,
        nft: Nft<D>,
        certificate: NftCertificate,
        recipient: address,
    ) {
        assert!(nft::id(&nft) == sale::nft_id(&certificate), 0);

        sale::burn_certificate(certificate);

        assert!(slingshot::is_embedded(slingshot), 0);

        transfer::transfer(
            nft,
            recipient,
        );
    }

    /// Once the user has bought an NFT certificate, this method can be called
    /// to claim/redeem the NFT that has been allocated by the launchpad. The
    /// `NFTOwned` object in the function signature should correspond to the 
    /// NFT ID mentioned in the certificate.
    /// 
    /// We add the slingshot as a phantom parameter since it is the parent object
    /// of the NFT. Since the slingshot is a shared object anyone can mention it
    /// in the function signature and therefore be able to mention its child
    /// objects as well, the NFTs owned by it.
    public entry fun claim_nft_loose<D: key + store>(
        slingshot: &Slingshot<FixedPriceMarket, Market>,
        nft_data: D,
        certificate: NftCertificate,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        assert!(object::id(&nft_data) == sale::nft_id(&certificate), 0);

        sale::burn_certificate(certificate);

        assert!(!slingshot::is_embedded(slingshot), 0);

        let nft = nft::mint_nft_embedded(
            object::id(&nft_data),
            nft_data,
            ctx,
        );

        transfer::transfer(
            nft,
            recipient,
        );

    }

    // /// Deletes the `Slingshot` and `LaunchpadConfig` if the object
    // /// does not own any child object
    // public fun delete<T: drop, Meta: store>(
    //     slingshot: Slingshot<FixedPriceSale, LaunchpadConfig>,
    //     ctx: &mut TxContext,
    // ) {
    //     // TODO: the fact that the vector `nfts` does not mean the slingshot
    //     // has no ownership of nfts since there may be certificates to be 
    //     // claimed. We should therefore consider an alternative approach

    //     // Assert that nfts vector is empty, meaning that
    //     // the slingshot does not residually own any NFT
    //     assert!(vector::length(slingshot::nfts(&slingshot)) == 0, 0);

    //     event::emit(
    //         DeleteSlingshotEvent {
    //             object_id: object::id(&slingshot),
    //             collection_id: slingshot::collection_id(&slingshot),
    //         }
    //     );

    //     // Delete generic Collection object
    //     let config = slingshot::delete(
    //         slingshot,
    //         ctx,
    //     );

    //     let LaunchpadConfig {
    //         id,
    //         price: _,
    //     } = config;

    //     object::delete(id);
    // }

    // // === Modifier Functions ===

    // /// Permissioned endpoint to be called by `admin` to edit the fixed price 
    // /// of the launchpad configuration.
    // public entry fun new_price<T, Config>(
    //     slingshot: &mut Slingshot<FixedPriceSale, LaunchpadConfig>,
    //     new_price: u64,
    //     ctx: &mut TxContext,
    // ) {
    //     assert!(slingshot::admin(slingshot) == tx_context::sender(ctx), 0);

    //     let config = slingshot::config_mut(slingshot);

    //     config.price = new_price;
    // }

    // // === Getter Functions ===

    // /// Get the Slingshot Configs's `price`
    // public fun price(
    //     slingshot: &LaunchpadConfig,
    // ): u64 {
    //     slingshot.price
    // }

    // // === Private Functions ===

    // fun init_args(
    //     collection: ID,
    //     receiver: address,
    //     price: u64,
    // ): InitFixedPriceSlingshot {
    //     InitFixedPriceSlingshot {
    //         collection,
    //         receiver,
    //         price,
    //     }
    // }
}