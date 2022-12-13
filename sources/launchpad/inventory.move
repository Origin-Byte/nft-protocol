//! Module representing the Nft bookeeping Inventories of `Launchpad`s.
//!
//! Launchpads can now have multiple sale outlets, repsented
//! through `sales: vector<Sale>`, which meants that NFT creators can
//! perform tiered sales. An example of this would be an Gaming NFT creator
//! separating the sale based on NFT rarity and emit whitelist tokens to
//! different users for different rarities depending on the user's game score.
//!
//! The Sale object is agnostic to the Market mechanism and instead decides to
//! outsource this logic to generic `Market` object. This way developers can
//! come up with their plug-and-play market primitives, of which some examples
//! are Dutch Auctions, Sealed-Bid Auctions, etc.
module nft_protocol::inventory {
    use std::vector;

    use sui::tx_context::{TxContext};
    use sui::object::{Self, ID , UID};

    use nft_protocol::err;

    // The `Inventory` of a sale performs the bookeeping of all the NFTs that
    // are currently on sale as well as the NFTs whose certificates have been
    // sold and currently waiting to be redeemed
    struct Inventory has key, store {
        id: UID,
        whitelisted: bool,
        // NFTs that are currently on sale
        nfts: vector<ID>,
        // NFTs whose certificates have been sold and currently waiting
        // to be redeemed
        queue: vector<ID>,
    }

    public fun create(
        whitelisted: bool,
        ctx: &mut TxContext,
    ): Inventory {
        let id = object::new(ctx);

        let nfts = vector::empty();
        let queue = vector::empty();

        Inventory {
            id,
            whitelisted,
            nfts,
            queue,
        }
    }

    /// Burn the `Inventory` and return the `Market` object
    public fun delete(
        inventory: Inventory,
    ) {
        assert!(
            vector::length(&inventory.nfts) == 0,
            err::nft_sale_incompleted()
        );
        assert!(
            vector::length(&inventory.queue) == 0,
            err::nft_redemption_incompleted()
        );

        let Inventory {
            id,
            whitelisted: _,
            nfts: _,
            queue: _,
        } = inventory;

        object::delete(id);
    }

    /// Adds an NFT's ID to the `nfts` field in `Inventory` object
    public fun add_nft(
        inventory: &mut Inventory,
        id: ID,
    ) {
        let nfts = &mut inventory.nfts;
        vector::push_back(nfts, id);
    }

    /// Pops an NFT's ID from the `nfts` field in `Inventory` object
    /// and returns respective `ID`
    /// TODO: Need to push the ID to the queue
    public fun pop_nft(
        inventory: &mut Inventory,
    ): ID {
        let nfts = &mut inventory.nfts;
        assert!(!vector::is_empty(nfts), err::no_nfts_left());
        vector::pop_back(nfts)
    }

    /// Check how many `nfts` there are to sell
    public fun length(
        inventory: &Inventory,
    ): u64 {
        vector::length(&inventory.nfts)
    }

    public fun is_whitelisted(
        inventory: &Inventory,
    ): bool {
        inventory.whitelisted
    }

    // === Assertions ===

    public fun assert_is_whitelisted(
        inventory: &Inventory,
    ) {
        assert!(
            is_whitelisted(inventory),
            err::sale_is_not_whitelisted()
        );
    }

    public fun assert_is_not_whitelisted(
        inventory: &Inventory,
    ) {
        assert!(
            !is_whitelisted(inventory),
            err::sale_is_whitelisted()
        );
    }
}
