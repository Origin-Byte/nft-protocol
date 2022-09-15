/// Module of a Fixed Initial NFT Offering `Config` type.
module nft_protocol::fixed_ino {
    use sui::transfer::{Self};
    use sui::sui::{Self, SUI};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use nft_protocol::launcher::{Self, Launcher};

    struct FixedInitalOffer has drop {}

    struct LauncherConfig has key, store {
        id: UID,
        price: u64,
    }

    struct InitFixedInitalOffer has drop {
        collection: ID,
        go_live_date: u64,
        receiver: address,
        price: u64,
    }

    struct NftCertificate has key, store {
        id: UID,
        nft_id: ID,
    }

    public entry fun create(
        collection: ID,
        go_live_date: u64,
        receiver: address,
        price: u64,
        ctx: &mut TxContext,
    ) {

        let args = init_args(
            collection,
            go_live_date,
            receiver,
            price,
        );

        let config = LauncherConfig {
            id: object::new(ctx),
            price: args.price,
        };

        let launcher_args = launcher::init_args(
            collection,
            go_live_date,
            receiver,
        );

        let launcher = launcher::create(
            FixedInitalOffer {},
            launcher_args,
            config,
            ctx,
        );

        // TODO: Emit event

        transfer::share_object(launcher);
    }

    public entry fun buy_nft_certificate(
        coin: Coin<SUI>,
        launcher: &mut Launcher<FixedInitalOffer, LauncherConfig>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
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
            certificate, // This should be the ID of the object
            recipient,
        );
    }

    
    // public entry fun buy_nft(
    //     coin: Coin<SUI>,
    //     launcher: &mut Launcher<FixedInitalOffer, LauncherConfig>,
    //     ctx: &mut TxContext,
    // ) {
    //     let price = price(launcher::config(launcher));
    //     assert!(coin::value(&coin) > price, 0);

    //     // Split coin into price and change, then transfer 
    //     // the price and keep the change
    //     let balance = coin::into_balance(coin);

    //     let price = coin::take(
    //         &mut balance,
    //         price,
    //         ctx,
    //     );

    //     let change = coin::from_balance(balance, ctx);
    //     coin::keep(change, ctx);

    //     // Transfer Sui to pay for the mint
    //     sui::transfer(
    //         price,
    //         launcher::receiver(launcher),
    //     );

    //     let nft_id = launcher::pop_nft(launcher);

    //     transfer::transfer(
    //         nft_id, // This should be the ID of the object
    //         recipient,
    //     );

    //     public entry fun remove_child(parent: &mut Parent, child: Child, ctx: &mut TxContext) {
    //     let child_id = option::extract(&mut parent.child);
    //     assert!(object::id(&child) == child_id, 0);
    //     transfer::transfer(child, tx_context::sender(ctx));
    //     }


    // }

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
    ): InitFixedInitalOffer {
        InitFixedInitalOffer {
            collection,
            go_live_date,
            receiver,
            price,
        }
    }
}