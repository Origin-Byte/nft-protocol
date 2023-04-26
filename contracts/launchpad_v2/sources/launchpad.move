module launchpad_v2::launchpad {
    use std::ascii::String;

    use sui::event;
    use sui::transfer;
    use sui::vec_set::{Self, VecSet};
    use sui::object::{Self, ID , UID};
    use sui::tx_context::{Self, TxContext};

    /// The `LaunchCap` provided does not correspond to the `Listing` provided.
    const ELauchCapListingMismatch: u64 = 1;

    /// The `LaunchCap` provided cannot be cloned.
    const ELauchCapNotClonable: u64 = 2;


    /// `Listing` is an abstraction for grouping information about
    /// an NFT primary sale. It consolidates all the information about
    /// sale `Venues` and inventories, whether those are `Warehouse`s or
    /// `Factory`s.
    struct Listing has key, store {
        id: UID,
        // List of all `LaunchCap`s, for discoverability purposes.
        launch_caps: VecSet<ID>,
        // List of all associated sale `Venue`s
        venues: VecSet<ID>,
        // List of all associated inventories, whether those are `Warehouse`s or
        // `Factory`s.
        inventories: VecSet<ID>,
    }

    /// A primary sale can have multiple stakeholders, such as creators
    /// and marketplaces. `LaunchCap` is an administrative object that
    /// allows its holders to perform admin-only actions. Furthermore, the
    /// LaunchCap can be clonable, allowing for mutiple partners to work
    /// and collaborate on the creation and management of a primary sale.
    ///
    /// An example of the usefulness of having multiple LaunchCaps is to
    /// allow for the Proceeds withdraw process to occur in a multi-sig
    /// fashion.
    struct LaunchCap has key, store {
        id: UID,
        listing_id: ID,
        clonable: bool,
    }

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


    // === Instantiators ===

    /// Initialises a launchpad `Listing` by creating an object and returns it,
    /// along with a clonable `LaunchCap` object.
    public fun new(
        ctx: &mut TxContext,
    ): (Listing, LaunchCap) {

        new_(ctx)
    }

    /// Initialises a `Listing` object, shares it, and transfers a
    /// cloanble `LaunchCap` to the transaction caller.
    public entry fun init_listing(
        ctx: &mut TxContext,
    ) {
        let (launch_cap, listing) = new_(ctx);

        transfer::public_share_object(listing);
        transfer::public_transfer(launch_cap, tx_context::sender(ctx));
    }

    // === Admin functions ===

    /// Clones a `LaunchCap` object and returns a newly created one.
    public fun clone_launch_cap(
        listing: &mut Listing,
        cap: &LaunchCap,
        clonable: bool,
        ctx: &mut TxContext,
    ): LaunchCap {
        assert_launch_cap(cap, listing);
        assert_is_clonable(cap);

        new_launch_cap_(listing, clonable, ctx)
    }

    /// Clones a `LaunchCap` object and transfers a newly created one to
    /// the receiver address.
    public fun clone_launch_cap_and_transfer(
        listing: &mut Listing,
        cap: &LaunchCap,
        clonable: bool,
        receiver: address,
        ctx: &mut TxContext,
    ) {
        assert_launch_cap(cap, listing);
        assert_is_clonable(cap);

        let new_cap = new_launch_cap_(listing, clonable, ctx);
        transfer::public_transfer(new_cap, receiver);
    }

    public fun subscribe_venue(
        listing: &mut Listing,
        cap: &LaunchCap,
        venue: ID,
    ) {
        assert_launch_cap(cap, listing);

        vec_set::insert(&mut listing.venues, venue);
    }

    // === Getter Functions ===

    public fun listing_id(launch_cap: &LaunchCap): ID {
        object::uid_to_inner(&launch_cap.id)
    }

    public fun clonable(launch_cap: &LaunchCap): bool {
        launch_cap.clonable
    }

    public fun launch_caps(listing: &Listing): &VecSet<ID> {
        &listing.launch_caps
    }

    public fun venues(listing: &Listing): &VecSet<ID> {
        &listing.venues
    }

    public fun inventories(listing: &Listing): &VecSet<ID> {
        &listing.inventories
    }


    // === Private Functions ===

    fun new_(
        ctx: &mut TxContext,
    ): (Listing, LaunchCap) {
        let cap_id = object::new(ctx);
        let listing_uid = object::new(ctx);
        let listing_id = object::uid_to_inner(&listing_uid);

        event::emit(CreateListingEvent {listing_id});

        let launch_caps = vec_set::singleton(object::uid_to_inner(&cap_id));

        let cap = LaunchCap {
            id: cap_id,
            listing_id,
            clonable: true,
        };

        let listing = Listing {
            id: listing_uid,
            launch_caps,
            venues: vec_set::empty(),
            inventories: vec_set::empty(),
        };

        (listing, cap)
    }


    fun new_launch_cap_(
        listing: &mut Listing,
        clonable: bool,
        ctx: &mut TxContext,
    ): LaunchCap {
        let cap_id = object::new(ctx);

        vec_set::insert(&mut listing.launch_caps, object::uid_to_inner(&cap_id));

        LaunchCap {
            id: cap_id,
            listing_id: object::id(listing),
            clonable,
        }
    }


    // === Assertions ===

    public fun assert_launch_cap(cap: &LaunchCap, listing: &Listing) {
        assert!(cap.listing_id == object::id(listing), ELauchCapListingMismatch);
    }

    public fun assert_is_clonable(cap: &LaunchCap) {
        assert!(cap.clonable, ELauchCapNotClonable);
    }
}
