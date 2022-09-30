// /// Module of a Fixed Initial NFT Offering `Config` type.
// /// 
// /// It implments a fixed price launchpad configuration.
// /// 
// /// TODO: When deleting the slingshot, we should guarantee that no nft is still
// /// owned by the slingshot object. the fact that the vector `nfts` does not 
// /// mean the slingshot has no ownership of nfts since there may be certificates 
// /// to be claimed. We should therefore consider an alternative approach
// module nft_protocol::fixed_price {
//     use std::vector;
//     use sui::event;
//     use sui::transfer::{Self};
//     use sui::sui::{SUI};
//     use sui::coin::{Self, Coin};
//     use sui::object::{Self, UID, ID};
//     use sui::tx_context::{Self, TxContext};
//     use nft_protocol::slingshot::{Self, Slingshot};
//     use nft_protocol::nft::{Self, NftOwned};
//     use nft_protocol::collection::{Self, Collection};

//     struct FixedPriceSale has drop {}

//     struct LaunchpadConfig has key, store {
//         id: UID,
//         price: u64,
//     }

//     /// This object acts as an intermediate step between the payment
//     /// and the transfer of the NFT. The user first has to call 
//     /// `buy_nft_certificate` which mints and transfers the `NftCertificate` to
//     /// the user. This object will dictate which NFT the userwill receive by
//     /// calling the endpoint `claim_nft`
//     struct NftCertificate has key, store {
//         id: UID,
//         nft_id: ID,
//     }

//     /// Aggregates all arguments for the creation of a `Slingshot` object
//     /// with a `LaunchpadConfig` as the configuration object
//     struct InitFixedPriceSlingshot has drop {
//         collection: ID,
//         receiver: address,
//         price: u64,
//     }

//     struct CreateSlingshotEvent has copy, drop {
//         object_id: ID,
//         collection_id: ID,
//     }

//     struct DeleteSlingshotEvent has copy, drop {
//         object_id: ID,
//         collection_id: ID,
//     }

//     /// Creates a `Slingshot` with `FixedInitalOffer` as witness and a fixed
//     /// price launchpad configuration via `LaunchpadConfig`.
//     public entry fun create<T: drop, Meta: store>(
//         collection: &Collection<T, Meta>,
//         admin: address,
//         receiver: address,
//         price: u64,
//         ctx: &mut TxContext,
//     ) {

//         let collection_id = collection::id(collection);

//         let args = init_args(
//             collection_id,
//             receiver,
//             price,
//         );

//         let config = LaunchpadConfig {
//             id: object::new(ctx),
//             price: args.price,
//         };

//         let slingshot_args = slingshot::init_args(
//             collection_id,
//             admin,
//             receiver,
//         );

//         let slingshot = slingshot::create(
//             FixedPriceSale {},
//             slingshot_args,
//             config,
//             ctx,
//         );

//         event::emit(
//             CreateSlingshotEvent {
//                 object_id: object::id(&slingshot),
//                 collection_id: collection_id,
//             }
//         );

//         transfer::share_object(slingshot);
//     }

//     /// To buy an NFT a user will first buy an NFT certificate. This guarantees
//     /// that the slingshot object is in full control of the selection process.
//     /// A `NftCertificate` object will be minted and transfered to the sender
//     /// of transaction. The sender can then use this certificate to call
//     /// `claim_nft` and claim the NFT that has been allocated by the slingshot
//     public entry fun buy_nft_certificate(
//         wallet: &mut Coin<SUI>,
//         slingshot: &mut Slingshot<FixedPriceSale, LaunchpadConfig>,
//         ctx: &mut TxContext,
//     ) {
//         // One can only buy NFT certificates if the slingshot is live
//         assert!(slingshot::live(slingshot) == true, 0);

//         let price = price(slingshot::config(slingshot));
//         assert!(coin::value(wallet) > price, 0);

//         // Split coin into price and change, then transfer 
//         // the price and keep the change
//         coin::split_and_transfer<SUI>(
//             wallet,
//             price,
//             slingshot::receiver(slingshot),
//             ctx
//         );

//         let nft_id = slingshot::pop_nft(slingshot);

//         let certificate = NftCertificate {
//             id: object::new(ctx),
//             nft_id: nft_id,
//         };

//         transfer::transfer(
//             certificate,
//             tx_context::sender(ctx),
//         );
//     }
    
//     /// Once the user has bought an NFT certificate, this method can be called
//     /// to claim/redeem the NFT that has been allocated by the launchpad. The
//     /// `NFTOwned` object in the function signature should correspond to the 
//     /// NFT ID mentioned in the certificate.
//     /// 
//     /// We add the slingshot as a phantom parameter since it is the parent object
//     /// of the NFT. Since the slingshot is a shared object anyone can mention it
//     /// in the function signature and therefore be able to mention its child
//     /// objects as well, the NFTs owned by it.
//     public entry fun claim_nft<T, Meta: store>(
//         _slingshot: &Slingshot<FixedPriceSale, LaunchpadConfig>,
//         nft: NftOwned<T, Meta>,
//         certificate: NftCertificate,
//         recipient: address,
//     ) {
//         assert!(nft::id(&nft) == certificate.nft_id, 0);

//         burn_certificate(certificate);

//         transfer::transfer(
//             nft,
//             recipient,
//         );
//     }

//     /// Deletes the `Slingshot` and `LaunchpadConfig` if the object
//     /// does not own any child object
//     public fun delete<T: drop, Meta: store>(
//         slingshot: Slingshot<FixedPriceSale, LaunchpadConfig>,
//         ctx: &mut TxContext,
//     ) {
//         // TODO: the fact that the vector `nfts` does not mean the slingshot
//         // has no ownership of nfts since there may be certificates to be 
//         // claimed. We should therefore consider an alternative approach

//         // Assert that nfts vector is empty, meaning that
//         // the slingshot does not residually own any NFT
//         assert!(vector::length(slingshot::nfts(&slingshot)) == 0, 0);

//         event::emit(
//             DeleteSlingshotEvent {
//                 object_id: object::id(&slingshot),
//                 collection_id: slingshot::collection_id(&slingshot),
//             }
//         );

//         // Delete generic Collection object
//         let config = slingshot::delete(
//             slingshot,
//             ctx,
//         );

//         let LaunchpadConfig {
//             id,
//             price: _,
//         } = config;

//         object::delete(id);
//     }

//     // === Modifier Functions ===

//     /// Permissioned endpoint to be called by `admin` to edit the fixed price 
//     /// of the launchpad configuration.
//     public entry fun new_price<T, Config>(
//         slingshot: &mut Slingshot<FixedPriceSale, LaunchpadConfig>,
//         new_price: u64,
//         ctx: &mut TxContext,
//     ) {
//         assert!(slingshot::admin(slingshot) == tx_context::sender(ctx), 0);

//         let config = slingshot::config_mut(slingshot);

//         config.price = new_price;
//     }

//     // === Getter Functions ===

//     /// Get the Slingshot Configs's `price`
//     public fun price(
//         slingshot: &LaunchpadConfig,
//     ): u64 {
//         slingshot.price
//     }

//     // === Private Functions ===

//     fun init_args(
//         collection: ID,
//         receiver: address,
//         price: u64,
//     ): InitFixedPriceSlingshot {
//         InitFixedPriceSlingshot {
//             collection,
//             receiver,
//             price,
//         }
//     }

//     fun burn_certificate(
//         certificate: NftCertificate,
//     ) {
//         let NftCertificate {
//             id,
//             nft_id: _,
//         } = certificate;

//         object::delete(id);
//     }
// }