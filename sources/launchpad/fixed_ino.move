/// Module of a Fixed Initial NFT Offering `Config` type.
module nft_protocol::fixed_ino {
    use sui::object::{UID};

    struct FixedInitalOffer has drop {}

    struct LauncherConfig has key, store {
        id: UID,
        price: u64,
    }
}