/// Module for an NFT `Listing`
///
/// A `Listing` allows creators to sell their NFTs to the primary market using
/// bespoke market primitives, such as Fixed Price Sales and Dutch Auctions.
/// `Listings` can be standalone or be attached to Marketplace, in which case
/// they will pay fees to it.
///
/// Whilst the associated `Marketplace` object stipulates a default fee policy,
/// the marketplace admin can decide to create a custom fee policy for each
/// `Listing`.
///
/// The listing acts as the object that configures the primary NFT listing
/// strategy, that is the primary market sale. Primary market sales can take
/// many shapes, depending on the business level requirements.
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
    use nft_protocol::object_box::{Self as obox, ObjectBox};
    use nft_protocol::inventory::{Self, Inventory};

    // === WhitelistCertificate ===

    /// Within a `Listing`, each market has its own whitelist policy.
    /// As an example, creators can create tiered sales based on the NFT rarity,
    /// and then whitelist only the rare NFT sale. They can then emit whitelist
    /// tokens and send them to users who have completed a set of defined actions.
    struct WhitelistCertificate has key, store {
        id: UID,
        /// `Listing` from which this certificate can withdraw an `Nft`
        listing_id: ID,
        /// `Inventory` from which this certificate can withdraw an `Nft`
        market_id: ID,
    }

    public fun issue_whitelist_certificate(
        listing: &Listing,
        market_id: ID,
        ctx: &mut TxContext,
    ): WhitelistCertificate {
        assert_listing_admin(listing, ctx);

        let certificate = WhitelistCertificate {
            id: object::new(ctx),
            listing_id: object::id(listing),
            market_id,
        };

        certificate
    }

    public entry fun transfer_whitelist_certificate(
        listing: &Listing,
        market_id: ID,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let certificate = issue_whitelist_certificate(
            listing,
            market_id,
            ctx,
        );
        transfer::transfer(certificate, recipient);
    }

    public fun burn_whitelist_certificate(
        certificate: WhitelistCertificate,
    ) {
        let WhitelistCertificate {
            id,
            listing_id: _,
            market_id: _,
        } = certificate;

        object::delete(id);
    }

    // === Listing ===

    struct Listing has key, store {
        id: UID,
        /// The ID of the marketplace if any
        marketplace_id: Option<TypedID<Marketplace>>,
        /// The address of the `Listing` administrator
        admin: address,
        /// The address of the receiver of funds
        receiver: address,
        inventories: ObjectTable<ID, Inventory>,
        /// Proceeds object holds the balance of Fungible Tokens acquired from
        /// the sale of the Listing
        proceeds: Proceeds,
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

    /// Event signalling that a `Listing` was created
    struct CreateListingEvent has copy, drop {
        object_id: ID,
    }

    /// Event signalling that a `Listing` was deleted
    struct DeleteListingEvent has copy, drop {
        object_id: ID,
    }

    /// Initialises a `Listing` object and returns it.
    public fun new(
        listing_admin: address,
        receiver: address,
        ctx: &mut TxContext,
    ): Listing {
        let id = object::new(ctx);
        let inventories = object_table::new<ID, Inventory>(ctx);

        event::emit(CreateListingEvent {
            object_id: object::uid_to_inner(&id)
        });

        Listing {
            id,
            marketplace_id: option::none(),
            admin: listing_admin,
            receiver,
            inventories,
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

    /// Initializes an empty `Inventory` on `Listing`
    public entry fun init_inventory(
        listing: &mut Listing,
        ctx: &mut TxContext,
    ) {
        create_inventory(listing, ctx);
    }

    public fun create_inventory(
        listing: &mut Listing,
        ctx: &mut TxContext,
    ): ID {
        let inventory = inventory::new(ctx);
        let inventory_id = object::id(&inventory);

        add_inventory(listing, inventory, ctx);

        inventory_id
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

    public entry fun add_inventory(
        listing: &mut Listing,
        inventory: Inventory,
        ctx: &mut TxContext,
    ) {
        assert_listing_admin(listing, ctx);

        object_table::add<ID, Inventory>(
            &mut listing.inventories,
            object::id(&inventory),
            inventory,
        );
    }

    /// Adds a new Market to `markets` and Inventory to `inventories` tables
    public entry fun add_market<Market: key + store>(
        listing: &mut Listing,
        inventory_id: ID,
        is_whitelisted: bool,
        market: Market,
        ctx: &mut TxContext,
    ) {
        assert_listing_admin(listing, ctx);

        let inventory = inventory_mut(listing, inventory_id);
        inventory::add_market(inventory, is_whitelisted, market);
    }

    /// Adds NFT as a dynamic child object with its ID as key
    public entry fun add_nft<C>(
        listing: &mut Listing,
        inventory_id: ID,
        nft: Nft<C>,
        ctx: &mut TxContext,
    ) {
        assert_listing_admin(listing, ctx);

        let inventory = inventory_mut(listing, inventory_id);
        inventory::deposit_nft(inventory, nft);
    }

    /// Set market's live status to `true` therefore making the NFT sale live.
    /// To be called by the `Listing` admin.
    public entry fun sale_on(
        listing: &mut Listing,
        inventory_id: ID,
        market_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_listing_admin(listing, ctx);

        inventory::set_live(
            inventory_mut(listing, inventory_id),
            market_id,
            true,
        );
    }

    /// Set market's live status to `false` therefore pausing or stopping the
    /// NFT sale. To be called by the `Listing` admin.
    public entry fun sale_off(
        listing: &mut Listing,
        inventory_id: ID,
        market_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_listing_admin(listing, ctx);

        inventory::set_live(
            inventory_mut(listing, inventory_id),
            market_id,
            false,
        );
    }

    /// Set market's live status to `true` therefore making the NFT sale live.
    /// To be called by the `Marketplace` admin.
    public entry fun sale_on_delegated(
        marketplace: &Marketplace,
        listing: &mut Listing,
        inventory_id: ID,
        market_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_listing_marketplace_match(marketplace, listing);
        mkt::assert_marketplace_admin(marketplace, ctx);

        inventory::set_live(
            inventory_mut(listing, inventory_id),
            market_id,
            true,
        );
    }

    /// Set market's live status to `false` therefore pausing or stopping the
    /// NFT sale. To be called by the `Marketplace` admin.
    public entry fun sale_off_delegated(
        marketplace: &Marketplace,
        listing: &mut Listing,
        inventory_id: ID,
        market_id: ID,
        ctx: &mut TxContext,
    ) {
        assert_listing_marketplace_match(marketplace, listing);
        mkt::assert_marketplace_admin(marketplace, ctx);

        inventory::set_live(
            inventory_mut(listing, inventory_id),
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

    /// Get the Listing's `Inventory`
    public fun inventory(listing: &Listing, inventory_id: ID): &Inventory {
        assert_inventory(listing, inventory_id);
        object_table::borrow(&listing.inventories, inventory_id)
    }

    /// Get the Listing's `Inventory` mutably
    fun inventory_mut(listing: &mut Listing, inventory_id: ID): &mut Inventory {
        assert_inventory(listing, inventory_id);
        object_table::borrow_mut(&mut listing.inventories, inventory_id)
    }

    /// Get the Listing's `Inventory` mutably
    ///
    /// `Inventory` is unprotected therefore only market modules registered
    /// on an `Inventory` can gain mutable access to it.
    public fun inventory_internal_mut<Market: key + store, Witness: drop>(
        _witness: Witness,
        listing: &mut Listing,
        inventory_id: ID,
        market_id: ID,
    ): &mut Inventory {
        utils::assert_same_module_as_witness<Market, Witness>();

        let inventory = inventory_mut(listing, inventory_id);
        inventory::assert_market<Market>(inventory, market_id);

        inventory
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

    public fun assert_inventory(listing: &Listing, inventory_id: ID) {
        assert!(
            object_table::contains(&listing.inventories, inventory_id),
            err::undefined_inventory(),
        );
    }

    public fun assert_whitelist_certificate_market(
        market_id: ID,
        certificate: &WhitelistCertificate,
    ) {
        // Infer that whitelist token corresponds to correct sale inventory
        assert!(
            certificate.market_id == market_id,
            err::incorrect_whitelist_certificate()
        );
    }
}
