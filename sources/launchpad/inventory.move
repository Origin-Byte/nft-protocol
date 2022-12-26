/// Module representing the Nft bookeeping Inventories of `Slot`s.
///
/// Release slots can have multiple concurrent markets, repsented
/// through `markets: ObjectBag`, allowing NFT creators to perform tiered sales.
/// An example of this would be an Gaming NFT creator separating the sale
/// based on NFT rarity and emit whitelist tokens to different users for
/// different rarities depending on the user's game score.
///
/// The Slot object is agnostic to the Market mechanism and instead decides to
/// outsource this logic to generic `Market` objects. This way developers can
/// come up with their plug-and-play market primitives, of which some examples
/// are Dutch Auctions, Sealed-Bid Auctions, etc.
///
/// Each market has a dedicated inventory, which tracks which NFTs are on
/// the shelves still to be sold, and which NFTs have been sold via Certificates
/// but are still waiting to be redeemed.
module nft_protocol::inventory {
    use std::vector;

    use sui::transfer;
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, ID , UID};

    use nft_protocol::nft::Nft;
    use nft_protocol::err;

    friend nft_protocol::slot;

    // The `Inventory` of a sale performs the bookeeping of all the NFTs that
    // are currently on sale as well as the NFTs whose certificates have been
    // sold and currently waiting to be redeemed
    struct Inventory has key, store {
        id: UID,
        whitelisted: bool,
        // NFTs that are currently on sale. When a `NftCertificate` is sold,
        // its corresponding NFT ID will be flushed from `nfts` and will be
        // added to `queue`.
        nfts_on_sale: vector<ID>,
        // NFTs whose certificates have been sold and currently waiting
        // to be redeemed. When a `NftCertificate` is redeemed, its respective
        // NFT ID is flushed out of `queue`
        // TODO: We can most likely deprecate this queue in favour of simply
        // having the NFTs in dynamic fields - that itself is already performing the
        // accounting
        queue: vector<ID>,
    }

    public entry fun create_for_sender(
        whitelisted: bool,
        ctx: &mut TxContext,
    ) {
        let inventory = new(whitelisted, ctx);

        transfer::transfer(inventory, tx_context::sender(ctx));
    }

    public fun new(
        whitelisted: bool,
        ctx: &mut TxContext,
    ): Inventory {
        let id = object::new(ctx);

        let nfts_on_sale = vector::empty();
        let queue = vector::empty();

        Inventory {
            id,
            whitelisted,
            nfts_on_sale,
            queue,
        }
    }

    /// Burn the `Inventory` and return the `Market` object
    public fun delete(
        inventory: Inventory,
    ) {
        assert!(
            vector::length(&inventory.nfts_on_sale) == 0,
            err::nft_sale_incompleted()
        );
        assert!(
            vector::length(&inventory.queue) == 0,
            err::nft_redemption_incompleted()
        );

        let Inventory {
            id,
            whitelisted: _,
            nfts_on_sale: _,
            queue: _,
        } = inventory;

        object::delete(id);
    }

    /// Adds NFT as a dynamic child object with its ID as key and
    /// adds an NFT's ID to the `nfts` field in `Inventory` object.
    ///
    /// This should only be callable when Inventory is private and not
    /// owned by the Slot. The function call will fail otherwise, because
    /// one would have to refer to the Slot, the parent shared object, in order
    /// for the bytecode verifier not to fail.
    public entry fun add_nft<C>(
        inventory: &mut Inventory,
        nft: Nft<C>,
    ) {
        let nft_id = object::id(&nft);
        vector::push_back(&mut inventory.nfts_on_sale, nft_id);

        dof::add(&mut inventory.id, nft_id, nft);
    }

    /// Adds NFT as a dynamic child object with its ID as key
    public(friend) fun redeem_nft<C>(
        inventory: &mut Inventory,
    ): Nft<C> {
        let nfts = &mut inventory.nfts_on_sale;
        assert!(!vector::is_empty(nfts), err::no_nfts_left());
        let nft_id = vector::pop_back(nfts);

        let nft = dof::remove<ID, Nft<C>>(
            &mut inventory.id,
            nft_id,
        );

        assert!(!vector::is_empty(&inventory.queue), err::no_nfts_left());
        vector::pop_back(&mut inventory.queue);

        nft
    }

    /// Adds an NFT's ID to the `nfts` field in `Inventory` object
    public fun register_nft_for_sale(
        inventory: &mut Inventory,
        id: ID,
    ) {
        let nfts = &mut inventory.nfts_on_sale;
        vector::push_back(nfts, id);
    }

    // /// Pops an NFT's ID from the `nfts` field in `Inventory` object
    // /// and returns respective `ID`
    // /// TODO: Need to push the ID to the queue
    // public fun pop_nft_from_sale(
    //     inventory: &mut Inventory,
    // ): ID {
    //     let nfts = &mut inventory.nfts_on_sale;
    //     assert!(!vector::is_empty(nfts), err::no_nfts_left());
    //     vector::pop_back(nfts)
    // }

    /// Check how many `nfts` there are to sell
    public fun length(
        inventory: &Inventory,
    ): u64 {
        vector::length(&inventory.nfts_on_sale)
    }

    public fun is_empty(
        inventory: &Inventory,
    ): bool {
        vector::is_empty(&inventory.nfts_on_sale)
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
