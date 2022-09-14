/// Module of a Fixed Initial NFT Offering `Config` type.
module nft_protocol::fixed_ino {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use sui::transfer::{Self};
    use nft_protocol::launcher::{Self};

    struct FixedInitalOffer has drop {}

    struct LauncherConfig has key, store {
        id: UID,
        price: u64,
    }

    struct InitFixedInitalOffer has drop {
        collection: ID,
        go_live_date: u64,
        price: u64,
    }

    public entry fun create(
        collection: ID,
        go_live_date: u64,
        price: u64,
        ctx: &mut TxContext,
    ) {

        let args = init_args(
            collection,
            go_live_date,
            price,
        );

        let config = LauncherConfig {
            id: object::new(ctx),
            price: args.price,
        };

        let launcher_args = launcher::init_args(
            collection,
            go_live_date,
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
    
    // public entry fun buy_nft() {}
    
    
    // public entry fun buy_nft() {}



    // === Private Functions ===

    fun init_args(
        collection: ID,
        go_live_date: u64,
        price: u64,
    ): InitFixedInitalOffer {
        InitFixedInitalOffer {
            collection,
            go_live_date,
            price,
        }
    }
}