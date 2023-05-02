/// Module for an NFT `Listing`
///
/// A `Listing` allows creators to sell their NFTs to the primary market using
/// bespoke market primitives, such as `FixedPriceMarket` and
/// `DutchAuctionMarket`.
/// `Listing` can be standalone or be attached to `Marketplace`.
///
/// Associated `Marketplace` objects may stipulate a fee policy, the
/// marketplace admin can decide to create a custom fee policy for each
/// `Listing`.
///
/// `Listing` may define multiple `Inventory` objects which themselves can
/// define multiple markets.
/// In consequence, each `Listing` may tier it's sales into different NFT
/// rarities, but may also want to sell one NFT inventory through different
/// sales channels.
/// For example, a creator might want to auction a rare tier of their
/// collection or provide an instant-buy option for users not wanting to
/// participate in the auction.
/// Alternatively, an inventory listing may want to sell NFTs for multiple
/// fungible tokens.
///
/// In essence, `Listing` is a shared object that provides a safe API to the
/// underlying inventories which are unprotected.
module ob_launchpad::listing {
    use std::ascii::String;
    use std::option::{Self, Option};
    use std::type_name;

    use sui::event;
    use sui::transfer;
    use sui::balance::{Self, Balance};
    use sui::object::{Self, ID , UID};
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::object_table::{Self, ObjectTable};
    use sui::object_bag::{Self, ObjectBag};

    use originmate::typed_id::{Self, TypedID};
    use originmate::object_box::{Self as obox, ObjectBox};

    use ob_launchpad::inventory::{Self, Inventory};
    use ob_launchpad::warehouse::{Self, Warehouse, RedeemCommitment};
    use ob_launchpad::marketplace::{Self as mkt, Marketplace};
    use ob_launchpad::proceeds::{Self, Proceeds};
    use ob_launchpad::venue::{Self, Venue};

    friend ob_launchpad::flat_fee;
    friend ob_launchpad::dutch_auction;
    friend ob_launchpad::fixed_price;
    friend ob_launchpad::limited_fixed_price;
    friend ob_launchpad::english_auction;

    #[test_only]
    friend ob_launchpad::test_fees;

    // Track the current version of the module
    const VERSION: u64 = 1;

    const ENotUpgrade: u64 = 999;
    const EWrongVersion: u64 = 1000;

    /// `Venue` was not defined on `Listing`
    ///
    /// Call `Listing::init_venue` to initialize a `Venue`
    const EUndefinedVenue: u64 = 1;

    /// `Warehouse` or `Factory` was not defined on `Listing`
    ///
    /// Initialize `Warehouse` using `Listing::init_warehouse` or insert one
    /// using `Listing::add_warehouse`.
    const EUndefinedInventory: u64 = 2;

    /// Transaction sender was not `Listing` admin when calling protected
    /// endpoint
    const EWrongAdmin: u64 = 3;

    const EWrongListingOrMarketplaceAdmin: u64 = 4;

    const EMarketplaceListingMismatch: u64 = 5;

    const EListingAlreadyAttached: u64 = 6;

    const EListingHasNotApplied: u64 = 7;

    const EActionExclusiveToStandaloneListing: u64 = 8;

    const EHasCustomFeePolicy: u64 = 9;

    struct Listing has key, store {
        id: UID,
        version: u64,
        /// The ID of the marketplace if any
        marketplace_id: Option<TypedID<Marketplace>>,
        /// The address of the `Listing` administrator
        admin: address,
        /// The address of the receiver of funds
        receiver: address,
        /// Proceeds object holds the balance of fungible tokens acquired from
        /// the sale of the listing
        proceeds: Proceeds,
        /// Main object that holds all venues part of the listing
        venues: ObjectTable<ID, Venue>,
        /// Main object that holds all inventories part of the listing
        inventories: ObjectBag,
        /// Field with Object Box holding a Custom Fee implementation if any.
        /// In case this box is empty the calculation will applied on the
        /// default fee object in the associated Marketplace
        custom_fee: ObjectBox,
    }

    /// An ephemeral object representing the intention of a `Listing` admin
    /// to join a given Marketplace.
    struct RequestToJoin has key, store {
        id: UID,
        marketplace_id: TypedID<Marketplace>,
    }

    struct RequestToJoinDfKey has store, copy, drop {}

    // === Events ===

    /// Event signalling that a `Listing` was created
    struct CreateListingEvent has copy, drop {
        listing_id: ID,
    }

    /// Event signalling that a `Listing` was deleted
    struct DeleteListingEvent has copy, drop {
        listing_id: ID,
    }

    /// Event signalling that `Nft` was sold by `Listing`
    struct NftSoldEvent has copy, drop {
        nft: ID,
        price: u64,
        ft_type: String,
        nft_type: String,
        buyer: address,
    }

    /// Initialises a `Listing` object and returns it.
    public fun new(
        listing_admin: address,
        receiver: address,
        ctx: &mut TxContext,
    ): Listing {
        let id = object::new(ctx);

        event::emit(CreateListingEvent {
            listing_id: object::uid_to_inner(&id),
        });

        Listing {
            id,
            version: VERSION,
            marketplace_id: option::none(),
            admin: listing_admin,
            receiver,
            proceeds: proceeds::empty(ctx),
            venues: object_table::new(ctx),
            inventories: object_bag::new(ctx),
            custom_fee: obox::empty(ctx),
        }
    }

    /// Initialises a standalone `Listing` object.
    public entry fun init_listing(
        listing_admin: address,
        receiver: address,
        ctx: &mut TxContext,
    ) {
        let listing = new(
            listing_admin,
            receiver,
            ctx,
        );

        transfer::public_share_object(listing);
    }

    /// Initializes a `Venue` on `Listing`
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not listing admin.
    public entry fun init_venue<Market: store, MarketKey: copy + drop + store>(
        listing: &mut Listing,
        key: MarketKey,
        market: Market,
        is_whitelisted: bool,
        ctx: &mut TxContext,
    ) {
        // Version asserted in `create_venue`
        create_venue(listing, key, market, is_whitelisted, ctx);
    }

    /// Creates a `Venue` on `Listing` and returns it's ID
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not listing admin.
    public fun create_venue<Market: store, MarketKey: copy + drop + store>(
        listing: &mut Listing,
        key: MarketKey,
        market: Market,
        is_whitelisted: bool,
        ctx: &mut TxContext,
    ): ID {
        assert_version(listing);

        let venue = venue::new(key, market, is_whitelisted, ctx);
        let venue_id = object::id(&venue);
        add_venue(listing, venue, ctx);
        venue_id
    }

    /// Initializes an empty `Warehouse` on `Listing`
    ///
    /// Requires that transaction sender is collection creator registered in
    /// `CreatorsDomain`.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not listing admin or creator.
    public entry fun init_warehouse<T: key + store>(
        listing: &mut Listing,
        ctx: &mut TxContext,
    ) {
        create_warehouse<T>(listing, ctx);
    }

    /// Creates an empty `Warehouse` on `Listing` and returns it's ID
    ///
    /// Function transparently wraps `Warehouse` in `Inventory`, therefore, the
    /// returned ID is that of the `Inventory` not the `Warehouse`.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not listing admin.
    public fun create_warehouse<T: key + store>(
        listing: &mut Listing,
        ctx: &mut TxContext,
    ): ID {
        assert_version(listing);

        let inventory = inventory::from_warehouse(warehouse::new<T>(ctx), ctx);
        let inventory_id = object::id(&inventory);
        add_inventory(listing, inventory, ctx);
        inventory_id
    }

    /// Pay for `Nft` sale and direct funds to `Listing` proceeds
    public(friend) fun pay<FT>(
        listing: &mut Listing,
        balance: Balance<FT>,
        quantity: u64,
    ) {
        assert_version(listing);

        let proceeds = borrow_proceeds_mut(listing);
        proceeds::add(proceeds, balance, quantity);
    }

    /// Emits `NftSoldEvent` for provided `Nft`
    public(friend) fun emit_sold_event<FT, T: key>(
        nft: &T,
        price: u64,
        buyer: address,
    ) {
        event::emit(NftSoldEvent {
            nft: object::id(nft),
            price,
            ft_type: *type_name::borrow_string(&type_name::get<FT>()),
            nft_type: *type_name::borrow_string(&type_name::get<T>()),
            buyer,
        });
    }

    /// Pay for `Nft` sale, direct fund to `Listing` proceeds, and emit sale
    /// events.
    ///
    /// Will charge `price` from the provided `Balance` object.
    ///
    /// #### Panics
    ///
    /// Panics if balance is not enough to fund price
    public(friend) fun pay_and_emit_sold_event<FT, T: key>(
        listing: &mut Listing,
        nft: &T,
        funds: Balance<FT>,
        buyer: address,
    ) {
        assert_version(listing);

        emit_sold_event<FT, T>(nft, balance::value(&funds), buyer);
        pay(listing, funds, 1);
    }

    /// Buys an NFT from an `Inventory`
    ///
    /// Only venues registered on the `Listing` have authorization to withdraw
    /// from an `Inventory`, therefore this operation must be authorized using
    /// a witness that corresponds to the market contract.
    ///
    /// Endpoint will redeem NFTs sequentially, if you need random withdrawal
    /// use `buy_pseudorandom_nft` or `buy_random_nft`.
    ///
    /// #### Panics
    ///
    /// - `Market` type does not correspond to `venue_id` on the `Listing`
    /// - No supply is available from underlying `Inventory`
    public(friend) fun buy_nft<T: key + store, FT, Market: store, MarketKey: copy + drop + store>(
        listing: &mut Listing,
        key: MarketKey,
        inventory_id: ID,
        venue_id: ID,
        buyer: address,
        funds: Balance<FT>,
    ): T {
        assert_version(listing);

        let inventory = inventory_internal_mut<T, Market, MarketKey>(
            listing, key, venue_id, inventory_id,
        );
        let nft = inventory::redeem_nft(inventory);
        pay_and_emit_sold_event(listing, &nft, funds, buyer);
        nft
    }

    /// Buys a pseudo-random NFT from an `Inventory`
    ///
    /// Only venues registered on the `Listing` have authorization to withdraw
    /// from an `Inventory`, therefore this operation must be authorized using
    /// a witness that corresponds to the market contract.
    ///
    /// Endpoint is susceptible to validator prediction of the resulting index,
    /// use `buy_random_nft` instead.
    ///
    /// #### Panics
    ///
    /// - `Market` type does not correspond to `venue_id` on the `Listing`
    /// - Underlying `Inventory` is not a `Warehouse` and there is no supply
    public(friend) fun buy_pseudorandom_nft<T: key + store, FT, Market: store, MarketKey: copy + drop + store>(
        listing: &mut Listing,
        key: MarketKey,
        inventory_id: ID,
        venue_id: ID,
        buyer: address,
        funds: Balance<FT>,
        ctx: &mut TxContext,
    ): T {
        assert_version(listing);

        let inventory = inventory_internal_mut<T, Market, MarketKey>(
            listing, key, venue_id, inventory_id,
        );
        let nft = inventory::redeem_pseudorandom_nft(inventory, ctx);
        pay_and_emit_sold_event(listing, &nft, funds, buyer);
        nft
    }

    /// Buys a random NFT from `Inventory`
    ///
    /// Requires a `RedeemCommitment` created by the user in a separate
    /// transaction to ensure that validators may not bias results favorably.
    /// You can obtain a `RedeemCommitment` by calling
    /// `warehouse::init_redeem_commitment`.
    ///
    /// Only venues registered on the `Listing` have authorization to withdraw
    /// from an `Inventory`, therefore this operation must be authorized using
    /// a witness that corresponds to the market contract.
    ///
    /// #### Panics
    ///
    /// - `Market` type does not correspond to `venue_id` on the `Listing`
    /// - Underlying `Inventory` is not a `Warehouse` and there is no supply
    /// - `user_commitment` does not match the hashed commitment in
    /// `RedeemCommitment`
    public(friend) fun buy_random_nft<T: key + store, FT, Market: store, MarketKey: copy + drop + store>(
        listing: &mut Listing,
        key: MarketKey,
        commitment: RedeemCommitment,
        user_commitment: vector<u8>,
        inventory_id: ID,
        venue_id: ID,
        buyer: address,
        funds: Balance<FT>,
        ctx: &mut TxContext,
    ): T {
        assert_version(listing);

        let inventory = inventory_internal_mut<T, Market, MarketKey>(
            listing, key, venue_id, inventory_id,
        );
        let nft = inventory::redeem_random_nft(
            inventory, commitment, user_commitment, ctx,
        );
        pay_and_emit_sold_event(listing, &nft, funds, buyer);
        nft
    }

    // === Admin functions ===

    /// To be called by the `Listing` administrator, to declare the intention
    /// of joining a Marketplace. This is the first step to join a marketplace.
    /// Joining a `Marketplace` is a two step process in which both the
    /// `Listing` admin and the `Marketplace` admin need to declare their
    /// intention to partner up.
    public entry fun request_to_join_marketplace(
        marketplace: &Marketplace,
        listing: &mut Listing,
        ctx: &mut TxContext,
    ) {
        mkt::assert_version(marketplace);
        assert_version(listing);
        assert_listing_admin(listing, ctx);

        assert!(
            option::is_none(&listing.marketplace_id),
            EListingAlreadyAttached,
        );

        let marketplace_id = typed_id::new(marketplace);

        let request = RequestToJoin {
            id: object::new(ctx),
            marketplace_id,
        };

        dof::add(
            &mut listing.id, RequestToJoinDfKey {}, request
        );
    }

    /// To be called by the `Marketplace` administrator, to accept the `Listing`
    /// request to join. This is the second step to join a marketplace.
    /// Joining a `Marketplace` is a two step process in which both the
    /// `Listing` admin and the `Marketplace` admin need to declare their
    /// intention to partner up.
    public entry fun accept_listing_request(
        marketplace: &Marketplace,
        listing: &mut Listing,
        ctx: &mut TxContext,
    ) {
        mkt::assert_version(marketplace);
        assert_version(listing);
        mkt::assert_marketplace_admin(marketplace, ctx);

        assert!(
            option::is_none(&listing.marketplace_id),
            EListingAlreadyAttached,
        );

        let marketplace_id = typed_id::new(marketplace);

        let request = dof::remove<RequestToJoinDfKey, RequestToJoin>(
            &mut listing.id, RequestToJoinDfKey {}
        );

        assert!(
            marketplace_id == request.marketplace_id,
            EListingHasNotApplied,
        );

        let RequestToJoin {
            id, marketplace_id: _,
        } = request;
        object::delete(id);

        option::fill(&mut listing.marketplace_id, marketplace_id);
    }

    /// Adds a fee object to the Listing's `custom_fee`
    ///
    /// This function should be called by the marketplace.
    /// If there the listing is not attached to a marketplace
    /// then if does not make sense to pay fees.
    ///
    /// Can only be called by the `Marketplace` admin
    public entry fun add_fee<FeeType: key + store>(
        marketplace: &Marketplace,
        listing: &mut Listing,
        fee: FeeType,
        ctx: &mut TxContext,
    ) {
        mkt::assert_version(marketplace);
        assert_version(listing);

        assert_listing_marketplace_match(marketplace, listing);
        mkt::assert_marketplace_admin(marketplace, ctx);

        obox::add<FeeType>(&mut listing.custom_fee, fee);
    }

    /// Adds a `Venue` to the `Listing`
    ///
    /// #### Panics
    ///
    /// Panics if inventory that `Venue` is assigned to does not exist or if
    /// transaction sender is not the listing admin.
    public entry fun add_venue(
        listing: &mut Listing,
        venue: Venue,
        ctx: &mut TxContext,
    ) {
        assert_version(listing);
        assert_listing_admin(listing, ctx);

        object_table::add(
            &mut listing.venues,
            object::id(&venue),
            venue,
        );
    }

    /// Adds an `Nft` to a `Warehouse` on the `Listing`
    ///
    /// To avoid shared consensus during mass minting, `Warehouse` can be
    /// constructed as a private object and later inserted into the `Listing`.
    ///
    /// #### Panics
    ///
    /// - `Inventory` with the given ID does not exist
    /// - `Inventory` with the given ID is not a `Warehouse`
    /// - Transaction sender is not the listing admin
    public entry fun add_nft<T: key + store>(
        listing: &mut Listing,
        inventory_id: ID,
        nft: T,
        ctx: &mut TxContext,
    ) {
        assert_version(listing);
        assert_listing_admin(listing, ctx);

        let inventory = borrow_inventory_mut(listing, inventory_id);
        inventory::deposit_nft(inventory, nft);
    }

    /// Adds `Inventory` to `Listing`
    ///
    /// `Inventory` is a type-erased wrapper around `Warehouse` or `Factory`.
    ///
    /// To create a new inventory call `inventory::from_warehouse` or
    /// `inventory::from_factory`.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not the listing admin
    public entry fun add_inventory<T>(
        listing: &mut Listing,
        inventory: Inventory<T>,
        ctx: &mut TxContext,
    ) {
        assert_version(listing);
        assert_listing_admin(listing, ctx);

        let inventory_id = object::id(&inventory);
        object_bag::add(&mut listing.inventories, inventory_id, inventory);
    }

    /// Adds `Warehouse` to `Listing`
    ///
    /// Function transparently wraps `Warehouse` in `Inventory`, therefore, the
    /// returned ID is that of the `Inventory` not the `Warehouse`.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not listing admin or creator registered
    /// in `CreatorsDomain`.
    public entry fun add_warehouse<T: key + store>(
        listing: &mut Listing,
        warehouse: Warehouse<T>,
        ctx: &mut TxContext,
    ) {
        assert_version(listing);
        // We are asserting that the caller is the listing admin in
        // the call `add_inventory`

        insert_warehouse(listing, warehouse, ctx);
    }

    /// Adds `Warehouse` to `Listing` and returns it's ID
    ///
    /// Function transparently wraps `Warehouse` in `Inventory`, therefore, the
    /// returned ID is that of the `Inventory` not the `Warehouse`.
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not listing admin.
    public fun insert_warehouse<T: key + store>(
        listing: &mut Listing,
        warehouse: Warehouse<T>,
        ctx: &mut TxContext,
    ): ID {
        assert_version(listing);
        // We are asserting that the caller is the listing admin in
        // the call `add_inventory`

        let inventory = inventory::from_warehouse(warehouse, ctx);
        let inventory_id = object::id(&inventory);
        add_inventory(listing, inventory, ctx);
        inventory_id
    }

    /// Set market's live status to `true` therefore making the NFT sale live.
    /// To be called by the `Listing` admin.
    public entry fun sale_on(
        listing: &mut Listing,
        venue_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_version(listing);
        assert_listing_admin(listing, ctx);
        venue::set_live(borrow_venue_mut(listing, venue_id), true);
    }

    /// Set market's live status to `false` therefore pausing or stopping the
    /// NFT sale. To be called by the `Listing` admin.
    public entry fun sale_off(
        listing: &mut Listing,
        venue_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_version(listing);
        assert_listing_admin(listing, ctx);
        venue::set_live(borrow_venue_mut(listing, venue_id), false);
    }

    /// Set market's live status to `true` therefore making the NFT sale live.
    /// To be called by the `Marketplace` admin.
    public entry fun sale_on_delegated(
        marketplace: &Marketplace,
        listing: &mut Listing,
        venue_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_version(listing);
        assert_listing_marketplace_match(marketplace, listing);
        mkt::assert_version(marketplace);
        mkt::assert_marketplace_admin(marketplace, ctx);

        venue::set_live(
            borrow_venue_mut(listing, venue_id),
            true,
        );
    }

    /// Set market's live status to `false` therefore pausing or stopping the
    /// NFT sale. To be called by the `Marketplace` admin.
    public entry fun sale_off_delegated(
        marketplace: &Marketplace,
        listing: &mut Listing,
        venue_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_version(listing);
        assert_listing_marketplace_match(marketplace, listing);
        mkt::assert_version(marketplace);
        mkt::assert_marketplace_admin(marketplace, ctx);

        venue::set_live(
            borrow_venue_mut(listing, venue_id),
            false,
        );
    }

    /// To be called by `Listing` admins for standalone `Listings`.
    /// Standalone Listings do not involve marketplace fees, and therefore
    /// the listing admin can freely call this entrypoint.
    public entry fun collect_proceeds<FT>(
        listing: &mut Listing,
        ctx: &mut TxContext,
    ) {
        assert_version(listing);
        assert_listing_admin(listing, ctx);

        assert!(
            option::is_none(&listing.marketplace_id),
            EActionExclusiveToStandaloneListing,
        );

        let receiver = listing.receiver;

        proceeds::collect_without_fees<FT>(
            borrow_proceeds_mut(listing),
            receiver,
            ctx,
        );
    }

    // === Getter functions ===

    /// Get the Listing's `receiver` address
    public fun receiver(listing: &Listing): address {
        listing.receiver
    }

    /// Get the Listing's `admin` address
    public fun admin(listing: &Listing): address {
        listing.admin
    }

    public fun contains_custom_fee(listing: &Listing): bool {
        !obox::is_empty(&listing.custom_fee)
    }

    public fun custom_fee(listing: &Listing): &ObjectBox {
        &listing.custom_fee
    }

    /// Borrow the Listing's `Proceeds`
    public fun borrow_proceeds(listing: &Listing): &Proceeds {
        &listing.proceeds
    }

    /// Mutably borrow the Listing's `Proceeds`
    public(friend) fun borrow_proceeds_mut(listing: &mut Listing): &mut Proceeds {
        &mut listing.proceeds
    }

    /// Returns whether `Venue` with given ID exists
    public fun contains_venue(listing: &Listing, venue_id: ID): bool {
        object_table::contains(&listing.venues, venue_id)
    }

    /// Borrow the listing's `Venue`
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` does not exist.
    public fun borrow_venue(listing: &Listing, venue_id: ID): &Venue {
        assert_venue(listing, venue_id);
        object_table::borrow(&listing.venues, venue_id)
    }

    /// Mutably borrow the listing's `Venue`
    ///
    /// #### Panics
    ///
    /// Panics if `Venue` does not exist.
    fun borrow_venue_mut(
        listing: &mut Listing,
        venue_id: ID,
    ): &mut Venue {
        assert_venue(listing, venue_id);
        object_table::borrow_mut(&mut listing.venues, venue_id)
    }

    /// Mutably borrow the listing's `Venue`
    ///
    /// `Venue` and inventories are unprotected therefore only market modules
    /// registered on a `Venue` can gain mutable access to it.
    public(friend) fun venue_internal_mut<Market: store, MarketKey: copy + drop + store>(
        listing: &mut Listing,
        key: MarketKey,
        venue_id: ID,
    ): &mut Venue {
        let venue = borrow_venue_mut(listing, venue_id);
        venue::assert_market<Market, MarketKey>(key, venue);

        venue
    }

    /// Mutably borrow the Listing's `Market`
    ///
    /// `Market` is unprotected therefore only market modules registered
    /// on a `Venue` can gain mutable access to it.
    public(friend) fun market_internal_mut<Market: store, MarketKey: copy + drop + store>(
        listing: &mut Listing,
        key: MarketKey,
        venue_id: ID,
    ): &mut Market {
        let venue =
            venue_internal_mut<Market, MarketKey>(listing, key, venue_id);
        venue::borrow_market_mut(key, venue)
    }

    /// Remove venue from `Listing`
    ///
    /// #### Panics
    ///
    /// Panics if the `Venue` did not exist or delegated witness did not match
    /// the market being removed.
    public(friend) fun remove_venue<Market: store, MarketKey: copy + drop + store>(
        listing: &mut Listing,
        key: MarketKey,
        venue_id: ID,
    ): Venue {
        let venue = object_table::remove(&mut listing.venues, venue_id);
        venue::assert_market<Market, MarketKey>(key, &venue);
        venue
    }

    /// Returns whether `Inventory` with given ID exists
    public fun contains_inventory<T>(
        listing: &Listing,
        inventory_id: ID,
    ): bool {
        object_bag::contains_with_type<ID, Inventory<T>>(
            &listing.inventories,
            inventory_id,
        )
    }

    /// Borrow the listing's `Inventory`
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` does not exist.
    public fun borrow_inventory<T>(
        listing: &Listing,
        inventory_id: ID,
    ): &Inventory<T> {
        assert_inventory<T>(listing, inventory_id);
        object_bag::borrow(&listing.inventories, inventory_id)
    }

    /// Mutably borrow the listing's `Inventory`
    ///
    /// #### Panics
    ///
    /// Panics if `Inventory` does not exist.
    fun borrow_inventory_mut<T>(
        listing: &mut Listing,
        inventory_id: ID,
    ): &mut Inventory<T> {
        assert_inventory<T>(listing, inventory_id);
        object_bag::borrow_mut(&mut listing.inventories, inventory_id)
    }

    /// Mutably borrow an `Inventory`
    public(friend) fun inventory_internal_mut<T, Market: store, MarketKey: copy + drop + store>(
        listing: &mut Listing,
        key: MarketKey,
        venue_id: ID,
        inventory_id: ID,
    ): &mut Inventory<T> {
        venue_internal_mut<Market, MarketKey>(listing, key, venue_id);
        borrow_inventory_mut(listing, inventory_id)
    }

    /// Mutably borrow an `Inventory`
    ///
    /// This call is protected and only the administrator can call it
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not an admin or inventory does not exist.
    public fun inventory_admin_mut<T>(
        listing: &mut Listing,
        inventory_id: ID,
        ctx: &mut TxContext,
    ): &mut Inventory<T> {
        assert_listing_admin(listing, ctx);
        borrow_inventory_mut(listing, inventory_id)
    }

    /// Returns how many NFTs can be withdrawn
    ///
    /// Returns none if the supply is uncapped
    ///
    /// #### Panics
    ///
    /// Panics if `Warehouse` or `Listing` with the ID does not exist
    public fun supply<T: key + store>(
        listing: &Listing,
        inventory_id: ID,
    ): Option<u64> {
        assert_inventory<T>(listing, inventory_id);
        let inventory = borrow_inventory<T>(listing, inventory_id);
        inventory::supply(inventory)
    }

    // === Assertions ===

    public fun assert_listing_marketplace_match(marketplace: &Marketplace, listing: &Listing) {
        assert!(
            option::is_some<TypedID<Marketplace>>(&listing.marketplace_id), EMarketplaceListingMismatch
        );

        assert!(
            object::id(marketplace) == *typed_id::as_id(
                option::borrow<TypedID<Marketplace>>(&listing.marketplace_id)
            ),
            EMarketplaceListingMismatch,
        );
    }

    public fun assert_listing_admin(listing: &Listing, ctx: &mut TxContext) {
        assert!(
            tx_context::sender(ctx) == listing.admin, EWrongAdmin,
        );
    }

    public fun assert_correct_admin(
        marketplace: &Marketplace,
        listing: &Listing,
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        let is_listing_admin = sender == listing.admin;
        let is_market_admin = sender == mkt::admin(marketplace);

        assert!(
            is_listing_admin || is_market_admin,
            EWrongListingOrMarketplaceAdmin,
        );
    }

    public fun assert_default_fee(listing: &Listing) {
        assert!(
            !obox::is_empty(&listing.custom_fee),
            EHasCustomFeePolicy,
        );
    }

    public fun assert_venue(listing: &Listing, venue_id: ID) {
        assert!(contains_venue(listing, venue_id), EUndefinedVenue);
    }

    public fun assert_inventory<T>(listing: &Listing, inventory_id: ID) {
        // Inventory can be either `Warehouse` or `Factory`
        assert!(
            contains_inventory<T>(listing, inventory_id), EUndefinedInventory,
        );
    }

    // === Upgradeability ===

    fun assert_version(listing: &Listing) {
        assert!(listing.version == VERSION, EWrongVersion);
    }

    entry fun migrate(listing: &mut Listing, ctx: &mut TxContext) {
        assert_listing_admin(listing, ctx);

        assert!(listing.version < VERSION, ENotUpgrade);
        listing.version = VERSION;
    }
}
