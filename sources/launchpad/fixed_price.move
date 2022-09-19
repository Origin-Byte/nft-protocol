/// Module of a Fixed Initial NFT Offering `Config` type.
/// 
/// It implments a fixed price launchpad configuration.
/// 
/// TODO: When deleting the launcher, we should guarantee that no nft is still
/// owned by the launcher object. the fact that the vector `nfts` does not 
/// mean the launcher has no ownership of nfts since there may be certificates 
/// to be claimed. We should therefore consider an alternative approach
module nft_protocol::fixed_price {
    use std::vector;
    use sui::event;
    use sui::transfer::{Self};
    use sui::sui::{SUI};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use nft_protocol::launcher::{Self, Launcher};
    use nft_protocol::nft::{Self, NftOwned};

    struct FixedPriceSale has drop {}

    struct LauncherConfig has key, store {
        id: UID,
        price: u64,
    }

    /// This object acts as an intermediate step between the payment
    /// and the transfer of the NFT. The user first has to call 
    /// `buy_nft_certificate` which mints and transfers the `NftCertificate` to
    /// the user. This object will dictate which NFT the userwill receive by
    /// calling the endpoint `claim_nft`
    struct NftCertificate has key, store {
        id: UID,
        nft_id: ID,
    }

    /// Aggregates all arguments for the creation of a `Launcher` object
    /// with a `LauncherConfig` as the configuration object
    struct InitFixedPriceLauncher has drop {
        collection: ID,
        receiver: address,
        price: u64,
    }

    struct CreateLauncherEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    struct DeleteLauncherEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    /// Creates a `Launcher` with `FixedInitalOffer` as witness and a fixed
    /// price launchpad configuration via `LauncherConfig`.
    public entry fun create(
        collection_id: ID,
        admin: address,
        receiver: address,
        price: u64,
        ctx: &mut TxContext,
    ) {

        let args = init_args(
            collection_id,
            receiver,
            price,
        );

        let config = LauncherConfig {
            id: object::new(ctx),
            price: args.price,
        };

        let launcher_args = launcher::init_args(
            collection_id,
            admin,
            receiver,
        );

        let launcher = launcher::create(
            FixedPriceSale {},
            launcher_args,
            config,
            ctx,
        );

        event::emit(
            CreateLauncherEvent {
                object_id: object::id(&launcher),
                collection_id: collection_id,
            }
        );

        transfer::share_object(launcher);
    }

    /// To buy an NFT a user will first buy an NFT certificate. This guarantees
    /// that the launcher object is in full control of the selection process.
    /// A `NftCertificate` object will be minted and transfered to the sender
    /// of transaction. The sender can then use this certificate to call
    /// `claim_nft` and claim the NFT that has been allocated by the launcher
    public entry fun buy_nft_certificate(
        wallet: &mut Coin<SUI>,
        launcher: &mut Launcher<FixedPriceSale, LauncherConfig>,
        ctx: &mut TxContext,
    ) {
        // One can only buy NFT certificates if the launcher is live
        assert!(launcher::live(launcher) == true, 0);

        let price = price(launcher::config(launcher));
        assert!(coin::value(wallet) > price, 0);

        // Split coin into price and change, then transfer 
        // the price and keep the change
        coin::split_and_transfer<SUI>(
            wallet,
            price,
            launcher::receiver(launcher),
            ctx
        );

        let nft_id = launcher::pop_nft(launcher);

        let certificate = NftCertificate {
            id: object::new(ctx),
            nft_id: nft_id,
        };

        transfer::transfer(
            certificate,
            tx_context::sender(ctx),
        );
    }
    
    /// Once the user has bought an NFT certificate, this method can be called
    /// to claim/redeem the NFT that has been allocated by the launcher. The
    /// `NFTOwned` object in the function signature should correspond to the 
    /// NFT ID mentioned in the certificate.
    /// 
    /// We add the launcher as a phantom parameter since it is the parent object
    /// of the NFT. Since the launcher is a shared object anyone can mention it
    /// in the function signature and therefore be able to mention its child
    /// objects as well, the NFTs owned by it.
    public entry fun claim_nft<T, Meta: store>(
        _launcher: &Launcher<FixedPriceSale, LauncherConfig>,
        nft: NftOwned<T, Meta>,
        certificate: NftCertificate,
        recipient: address,
    ) {
        assert!(nft::id(&nft) == certificate.nft_id, 0);

        burn_certificate(certificate);

        transfer::transfer(
            nft,
            recipient,
        );
    }

    /// Deletes the `Launcher` and `LauncherConfig` if the object
    /// does not own any child object
    public fun delete<T: drop, Meta: store>(
        launcher: Launcher<FixedPriceSale, LauncherConfig>,
        ctx: &mut TxContext,
    ) {
        // TODO: the fact that the vector `nfts` does not mean the launcher
        // has no ownership of nfts since there may be certificates to be 
        // claimed. We should therefore consider an alternative approach

        // Assert that nfts vector is empty, meaning that
        // the launcher does not residually own any NFT
        assert!(vector::length(launcher::nfts(&launcher)) == 0, 0);

        event::emit(
            DeleteLauncherEvent {
                object_id: object::id(&launcher),
                collection_id: launcher::collection_id(&launcher),
            }
        );

        // Delete generic Collection object
        let config = launcher::delete(
            launcher,
            ctx,
        );

        let LauncherConfig {
            id,
            price: _,
        } = config;

        object::delete(id);
    }

    // === Modifier Functions ===

    /// Permissioned endpoint to be called by `admin` to edit the fixed price 
    /// of the launchpad configuration.
    public entry fun new_price<T, Config>(
        launcher: &mut Launcher<FixedPriceSale ,LauncherConfig>,
        new_price: u64,
        ctx: &mut TxContext,
    ) {
        assert!(launcher::admin(launcher) == tx_context::sender(ctx), 0);

        let config = launcher::config_mut(launcher);

        config.price = new_price;
    }

    // === Getter Functions ===

    /// Get the Launcher Configs's `price`
    public fun price(
        launcher: &LauncherConfig,
    ): u64 {
        launcher.price
    }

    // === Private Functions ===

    fun init_args(
        collection: ID,
        receiver: address,
        price: u64,
    ): InitFixedPriceLauncher {
        InitFixedPriceLauncher {
            collection,
            receiver,
            price,
        }
    }

    fun burn_certificate(
        certificate: NftCertificate,
    ) {
        let NftCertificate {
            id,
            nft_id: _,
        } = certificate;

        object::delete(id);
    }
}