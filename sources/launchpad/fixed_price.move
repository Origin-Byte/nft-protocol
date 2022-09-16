/// Module of a Fixed Initial NFT Offering `Config` type.
module nft_protocol::fixed_price {
    use sui::event;
    use sui::transfer::{Self};
    use sui::sui::{Self, SUI};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use nft_protocol::launcher::{Self, Launcher};
    use nft_protocol::nft::{Self, NftOwned};

    struct FixedInitalOffer has drop {}

    struct LauncherConfig has key, store {
        id: UID,
        price: u64,
    }

    struct InitFixedPricelOffer has drop {
        collection: ID,
        go_live_date: u64,
        receiver: address,
        price: u64,
    }

    struct NftCertificate has key, store {
        id: UID,
        nft_id: ID,
    }

    struct CreateLauncherEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    struct DropLauncherEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    public entry fun create(
        collection_id: ID,
        go_live_date: u64,
        receiver: address,
        price: u64,
        ctx: &mut TxContext,
    ) {

        let args = init_args(
            collection_id,
            go_live_date,
            receiver,
            price,
        );

        let config = LauncherConfig {
            id: object::new(ctx),
            price: args.price,
        };

        let launcher_args = launcher::init_args(
            collection_id,
            go_live_date,
            receiver,
        );

        let launcher = launcher::create(
            FixedInitalOffer {},
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

    public entry fun buy_nft_certificate(
        coin: Coin<SUI>,
        launcher: &mut Launcher<FixedInitalOffer, LauncherConfig>,
        ctx: &mut TxContext,
    ) {
        // TODO: If current timestap is below launcher go_live_date then
        // it should fail

        let price = price(launcher::config(launcher));
        assert!(coin::value(&coin) > price, 0);

        // Split coin into price and change, then transfer 
        // the price and keep the change
        let balance = coin::into_balance(coin);

        let price = coin::take(
            &mut balance,
            price,
            ctx,
        );

        let change = coin::from_balance(balance, ctx);
        coin::keep(change, ctx);

        // Transfer Sui to pay for the mint
        sui::transfer(
            price,
            launcher::receiver(launcher),
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
    
    public entry fun redeem_nft<T, Meta: store>(
        _launcher: &mut Launcher<FixedInitalOffer, LauncherConfig>,
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
        go_live_date: u64,
        receiver: address,
        price: u64,
    ): InitFixedPricelOffer {
        InitFixedPricelOffer {
            collection,
            go_live_date,
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