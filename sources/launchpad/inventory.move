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
    use sui::vec_map::{Self, VecMap};
    use sui::object::{Self, ID , UID};
    use sui::object_bag::{Self, ObjectBag};

    use nft_protocol::nft::Nft;
    use nft_protocol::err;

    friend nft_protocol::slot;

    // The `Inventory` of a sale performs the bookeeping of all the NFTs that
    // are currently on sale as well as the NFTs whose certificates have been
    // sold and currently waiting to be redeemed
    struct Inventory has key, store {
        id: UID,
        /// Track which markets are live
        live: VecMap<ID, bool>,
        /// Track which markets are whitelisted
        whitelisted: VecMap<ID, bool>,
        /// Vector of all markets outlets that, each outles holding IDs
        /// owned by the slot
        markets: ObjectBag,
        // NFTs that are currently on sale. When a `NftCertificate` is sold,
        // its corresponding NFT ID will be flushed from `nfts` and will be
        // added to `queue`.
        nfts_on_sale: vector<ID>,
    }

    public fun new(
        ctx: &mut TxContext,
    ): Inventory {
        Inventory {
            id: object::new(ctx),
            live: vec_map::empty(),
            whitelisted: vec_map::empty(),
            markets: object_bag::new(ctx),
            nfts_on_sale: vector::empty(),
        }
    }

    /// Creates a `Inventory` and transfers to transaction sender
    public entry fun init_inventory(ctx: &mut TxContext) {
        let inventory = new(ctx);
        transfer::transfer(inventory, tx_context::sender(ctx));
    }

    /// Adds a new market to `Inventory` allowing NFTs deposited to the 
    /// inventory to be sold.
    /// 
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    public entry fun add_market<Market: key + store>(
        inventory: &mut Inventory,
        is_whitelisted: bool,
        market: Market,
    ) {
        let market_id = object::id(&market);

        vec_map::insert(&mut inventory.live, market_id, false);
        vec_map::insert(&mut inventory.whitelisted, market_id, is_whitelisted);

        object_bag::add<ID, Market>(
            &mut inventory.markets,
            market_id,
            market,
        );
    }

    /// Adds NFT as a dynamic child object with its ID as key and
    /// adds an NFT's ID to the `nfts` field in `Inventory` object.
    ///
    /// This should only be callable when Inventory is private and not
    /// owned by the Slot. The function call will fail otherwise, because
    /// one would have to refer to the Slot, the parent shared object, in order
    /// for the bytecode verifier not to fail.
    /// 
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    public entry fun deposit_nft<C>(
        inventory: &mut Inventory,
        nft: Nft<C>,
    ) {
        let nft_id = object::id(&nft);
        vector::push_back(&mut inventory.nfts_on_sale, nft_id);

        dof::add(&mut inventory.id, nft_id, nft);
    }

    /// Redeems NFT from `Inventory`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    public fun redeem_nft<C>(
        inventory: &mut Inventory,
    ): Nft<C> {
        let nfts = &mut inventory.nfts_on_sale;
        assert!(!vector::is_empty(nfts), err::no_nfts_left());

        dof::remove(&mut inventory.id, vector::pop_back(nfts))
    }

    /// Set market's live status to `true` therefore making the NFT sale live
    public entry fun set_live(
        inventory: &mut Inventory,
        market_id: ID,
        is_live: bool,
    ) {
        *vec_map::get_mut(&mut inventory.live, &market_id) = is_live;
    }

    /// Set market's live status to `false` therefore pausing or stopping the
    /// NFT sale
    ///
    /// Can also be turned off by the Launchpad admin
    public entry fun set_whitelisted(
        inventory: &mut Inventory,
        market_id: ID,
        is_whitelisted: bool,
    ) {
        *vec_map::get_mut(&mut inventory.whitelisted, &market_id) =
            is_whitelisted;
    }

    // === Getter Functions ===

    /// Check how many `nfts` there are to sell
    public fun length(inventory: &Inventory): u64 {
        vector::length(&inventory.nfts_on_sale)
    }

    /// Get the market's `live` status
    public fun is_live(inventory: &Inventory, market_id: &ID): bool {
        *vec_map::get(&inventory.live, market_id)
    }


    public fun is_empty(inventory: &Inventory): bool {
        vector::is_empty(&inventory.nfts_on_sale)
    }

    public fun is_whitelisted(inventory: &Inventory, market_id: &ID): bool {
        *vec_map::get(&inventory.whitelisted, market_id)
    }

    /// Get the `Inventory` markets
    public fun markets(inventory: &Inventory): &ObjectBag {
        &inventory.markets
    }

    /// Get specific `Inventory` market
    public fun market<Market: key + store>(
        inventory: &Inventory,
        market_id: ID,
    ): &Market {
        assert_market<Market>(inventory, market_id);
        object_bag::borrow<ID, Market>(&inventory.markets, market_id)
    }

    /// Get specific `Inventory` market mutably
    /// 
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Inventory`.
    public fun market_mut<Market: key + store>(
        inventory: &mut Inventory,
        market_id: ID,
    ): &mut Market {
        assert_market<Market>(inventory, market_id);
        object_bag::borrow_mut<ID, Market>(&mut inventory.markets, market_id)
    }

    // === Assertions ===

    public fun assert_is_live(inventory: &Inventory, market_id: &ID) {
        assert!(is_live(inventory, market_id), err::slot_not_live());
    }

    public fun assert_is_whitelisted(inventory: &Inventory, market_id: &ID) {
        assert!(
            is_whitelisted(inventory, market_id),
            err::sale_is_not_whitelisted()
        );
    }

    public fun assert_is_not_whitelisted(inventory: &Inventory, market_id: &ID) {
        assert!(
            !is_whitelisted(inventory, market_id),
            err::sale_is_whitelisted()
        );
    }

    public fun assert_market<Market: key + store>(
        inventory: &Inventory,
        market_id: ID,
    ) {
        assert!(
            object_bag::contains_with_type<ID, Market>(
                &inventory.markets, market_id
            ),
            err::undefined_market(),
        );
    }
}
