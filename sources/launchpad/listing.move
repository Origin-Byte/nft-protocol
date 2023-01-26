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
module nft_protocol::listing {
    // TODO: Currently, to issue whitelist token one has to call a function
    // times the number of whitelist addresses. Let us consider more gas efficient
    // ways of mass emiting whitelist tokens.
    use std::option::{Self, Option};
    use std::type_name::{Self, TypeName};

    use sui::event;
    use sui::transfer;
    use sui::balance::Balance;
    use sui::object::{Self, ID , UID};
    use sui::typed_id::{Self, TypedID};
    use sui::dynamic_object_field as dof;
    use sui::tx_context::{Self, TxContext};
    use sui::object_table::{Self, ObjectTable};

    use nft_protocol::err;
    use nft_protocol::utils;
    use nft_protocol::nft::Nft;
    use nft_protocol::marketplace::{Self as mkt, Marketplace};
    use nft_protocol::proceeds::{Self, Proceeds};
    use nft_protocol::venue::{Self, Venue};
    use originmate::object_box::{Self as obox, ObjectBox};

    struct Listing has key, store {
        id: UID,
        /// The ID of the marketplace if any
        marketplace_id: Option<TypedID<Marketplace>>,
        /// The address of the `Listing` administrator
        admin: address,
        /// The address of the receiver of funds
        receiver: address,
        /// Main object that holds all venues part of the listing
        venues: ObjectTable<ID, Venue>,
        /// Proceeds object holds the balance of fungible tokens acquired from
        /// the sale of the listing
        proceeds: Proceeds,
        /// Field with Object Box holding a Custom Fee implementation if any.
        /// In case this box is empty the calculation will applied on the
        /// default fee object in the associated Marketplace
        //
        // TODO: Turn into dynamic field like RequestToJoin
        custom_fee: ObjectBox,
    }

    /// An ephemeral object representing the intention of a `Listing` admin
    /// to join a given Marketplace.
    struct RequestToJoin has key, store {
        id: UID,
        marketplace_id: TypedID<Marketplace>,
    }

    /// Event signalling that a `Listing` was created
    struct CreateListingEvent has copy, drop {
        listing_id: ID,
    }

    /// Event signalling that a `Listing` was deleted
    struct DeleteListingEvent has copy, drop {
        listing_id: ID,
    }

    /// Initialises a `Listing` object and returns it.
    public fun new(
        listing_admin: address,
        receiver: address,
        ctx: &mut TxContext,
    ): Listing {
        let id = object::new(ctx);
        let venues = object_table::new<ID, Venue>(ctx);

        event::emit(CreateListingEvent {
            listing_id: object::uid_to_inner(&id),
        });

        Listing {
            id,
            marketplace_id: option::none(),
            admin: listing_admin,
            receiver,
            venues,
            proceeds: proceeds::empty(ctx),
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

        transfer::share_object(listing);
    }

    /// Initializes an empty `Venue` on `Listing`
    public entry fun init_venue(
        listing: &mut Listing,
        ctx: &mut TxContext,
    ) {
        create_venue(listing, ctx);
    }

    public fun create_venue(
        listing: &mut Listing,
        ctx: &mut TxContext,
    ): ID {
        let venue = venue::new(ctx);
        let venue_id = object::id(&venue);

        add_venue(listing, venue, ctx);

        venue_id
    }

    public fun pay<FT>(
        listing: &mut Listing,
        balance: Balance<FT>,
        qty_sold: u64,
    ) {
        let proceeds = proceeds_mut(listing);
        proceeds::add(proceeds, balance, qty_sold);
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
        assert_listing_admin(listing, ctx);

        assert!(
            option::is_none(&listing.marketplace_id),
            err::listing_already_attached_to_marketplace(),
        );

        let marketplace_id = typed_id::new(marketplace);

        let request = RequestToJoin {
            id: object::new(ctx),
            marketplace_id,
        };

        dof::add(
            &mut listing.id, type_name::get<RequestToJoin>(), request
        );
    }

    /// To be called by the `Marketpalce` administrator, to accept the `Listing`
    /// request to join. This is the second step to join a marketplace.
    /// Joining a `Marketplace` is a two step process in which both the
    /// `Listing` admin and the `Marketplace` admin need to declare their
    /// intention to partner up.
    public entry fun accept_listing_request(
        marketplace: &Marketplace,
        listing: &mut Listing,
        ctx: &mut TxContext,
    ) {
        mkt::assert_marketplace_admin(marketplace, ctx);

        assert!(
            option::is_none(&listing.marketplace_id),
            err::listing_already_attached_to_marketplace(),
        );

        let marketplace_id = typed_id::new(marketplace);

        let request = dof::remove<TypeName, RequestToJoin>(
            &mut listing.id, type_name::get<RequestToJoin>()
        );

        assert!(
            marketplace_id == request.marketplace_id,
            err::listing_has_not_applied_to_this_marketplace()
        );

        let RequestToJoin {
            id, marketplace_id: _,
        } = request;
        object::delete(id);

        option::fill(&mut listing.marketplace_id, marketplace_id);
    }

    /// Adds a fee object to the Listing's `custom_fee`
    ///
    /// Can only be called by the `Marketplace` admin
    public entry fun add_fee<FeeType: key + store>(
        marketplace: &Marketplace,
        listing: &mut Listing,
        fee: FeeType,
        ctx: &mut TxContext,
    ) {
        assert_listing_marketplace_match(marketplace, listing);

        // This function should be called by the marketplace.
        // If there the listing is not attached to a marketplace
        // then if does not make sense to pay fees.
        mkt::assert_marketplace_admin(marketplace, ctx);

        assert!(
            obox::is_empty(&listing.custom_fee),
            err::generic_box_full(),
        );

        obox::add<FeeType>(&mut listing.custom_fee, fee);
    }

    public entry fun add_venue(
        listing: &mut Listing,
        venue: Venue,
        ctx: &mut TxContext,
    ) {
        assert_listing_admin(listing, ctx);

        object_table::add<ID, Venue>(
            &mut listing.venues,
            object::id(&venue),
            venue,
        );
    }

    /// Adds a new Market to `markets` and Warehouse to `warehouses` tables
    public entry fun add_market<Market: key + store>(
        listing: &mut Listing,
        venue_id: ID,
        is_whitelisted: bool,
        market: Market,
        ctx: &mut TxContext,
    ) {
        assert_listing_admin(listing, ctx);

        let inventory = venue_mut(listing, venue_id);
        venue::add_market(inventory, is_whitelisted, market);
    }

    /// Adds NFT as a dynamic child object with its ID as key
    public entry fun add_nft<C>(
        listing: &mut Listing,
        venue_id: ID,
        nft: Nft<C>,
        ctx: &mut TxContext,
    ) {
        assert_listing_admin(listing, ctx);

        let inventory = venue_mut(listing, venue_id);
        venue::deposit_nft(inventory, nft);
    }

    /// Set market's live status to `true` therefore making the NFT sale live.
    /// To be called by the `Listing` admin.
    public entry fun sale_on(
        listing: &mut Listing,
        venue_id: ID,
        market_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_listing_admin(listing, ctx);

        venue::set_live(
            venue_mut(listing, venue_id),
            market_id,
            true,
        );
    }

    /// Set market's live status to `false` therefore pausing or stopping the
    /// NFT sale. To be called by the `Listing` admin.
    public entry fun sale_off(
        listing: &mut Listing,
        venue_id: ID,
        market_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_listing_admin(listing, ctx);

        venue::set_live(
            venue_mut(listing, venue_id),
            market_id,
            false,
        );
    }

    /// Set market's live status to `true` therefore making the NFT sale live.
    /// To be called by the `Marketplace` admin.
    public entry fun sale_on_delegated(
        marketplace: &Marketplace,
        listing: &mut Listing,
        venue_id: ID,
        market_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_listing_marketplace_match(marketplace, listing);
        mkt::assert_marketplace_admin(marketplace, ctx);

        venue::set_live(
            venue_mut(listing, venue_id),
            market_id,
            true,
        );
    }

    /// Set market's live status to `false` therefore pausing or stopping the
    /// NFT sale. To be called by the `Marketplace` admin.
    public entry fun sale_off_delegated(
        marketplace: &Marketplace,
        listing: &mut Listing,
        venue_id: ID,
        market_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_listing_marketplace_match(marketplace, listing);
        mkt::assert_marketplace_admin(marketplace, ctx);

        venue::set_live(
            venue_mut(listing, venue_id),
            market_id,
            false,
        );
    }

    /// To be called by `Listing` admins for standalone `Listings`.
    /// Standalone Listings do not envolve marketplace fees, and therefore
    /// the listing admin can freely call this entrypoint.
    public entry fun collect_proceeds<FT>(
        listing: &mut Listing,
        ctx: &mut TxContext,
    ) {
        assert!(
            option::is_none(&listing.marketplace_id),
            err::action_exclusive_to_standalone_listings(),
        );

        let receiver = listing.receiver;

        proceeds::collect_without_fees<FT>(
            proceeds_mut(listing),
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

    public fun proceeds(listing: &Listing): &Proceeds {
        &listing.proceeds
    }

    public fun proceeds_mut(listing: &mut Listing): &mut Proceeds {
        &mut listing.proceeds
    }

    /// Get the Listing's `Venue`
    public fun venue(listing: &Listing, venue_id: ID): &Venue {
        assert_venue(listing, venue_id);
        object_table::borrow(&listing.venues, venue_id)
    }

    /// Get the Listing's `Venue` mutably
    fun venue_mut(listing: &mut Listing, venue_id: ID): &mut Venue {
        assert_venue(listing, venue_id);
        object_table::borrow_mut(&mut listing.venues, venue_id)
    }

    /// Get the Listing's `Warehouse` mutably
    ///
    /// `Venue` is unprotected therefore only market modules registered
    /// on an `Venue` can gain mutable access to it.
    public fun venue_internal_mut<Market: key + store, Witness: drop>(
        _witness: Witness,
        listing: &mut Listing,
        venue_id: ID,
        market_id: ID,
    ): &mut Venue {
        utils::assert_same_module_as_witness<Market, Witness>();

        let venue = venue_mut(listing, venue_id);
        venue::assert_market<Market>(venue, market_id);

        venue
    }

    // === Assertions ===

    public fun assert_listing_marketplace_match(marketplace: &Marketplace, listing: &Listing) {
        assert!(
            object::id(marketplace) == *typed_id::as_id(
                option::borrow<TypedID<Marketplace>>(&listing.marketplace_id)
                ),
            err::marketplace_listing_mismatch()
        );
    }

    public fun assert_listing_admin(listing: &Listing, ctx: &mut TxContext) {
        assert!(
            tx_context::sender(ctx) == listing.admin,
            err::wrong_listing_admin()
        );
    }

    public fun assert_correct_admin(
        marketplace: &Marketplace,
        listing: &Listing,
        ctx: &mut TxContext,
    ) {
        let is_listing_admin = tx_context::sender(ctx) == listing.admin;
        let is_market_admin = tx_context::sender(ctx) == mkt::admin(marketplace);

        assert!(
            is_listing_admin || is_market_admin,
            err::wrong_marketplace_or_listing_admin()
        );
    }

    public fun assert_default_fee(listing: &Listing) {
        assert!(
            !obox::is_empty(&listing.custom_fee),
            err::has_custom_fee_policy(),
        );
    }

    public fun assert_venue(listing: &Listing, venue_id: ID) {
        assert!(
            object_table::contains(&listing.venues, venue_id),
            err::undefined_venue(),
        );
    }
}
