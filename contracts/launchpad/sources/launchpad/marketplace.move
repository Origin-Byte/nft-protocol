/// Module of a `Marketplace` type.
///
/// Marketplaces are platforms that facilitate the listing of NFT collections
/// to the public, by facilitating a primary market UI. NFT Creators can create
/// Listings to sell their NFTs to the public and can decide to partner with
/// a Marketplace such that these are sold through the Marketplace UI. In order
/// for the Marketplace to be remunerated, the `Listing` must be attached to
/// a `Marketplace`.
///
/// Marketplaces and dApps that want to offer a launchpad service should create
/// a `Marketplace` object.
///
/// After the creation of the `Marketplace` a `Listing` for the NFT listing needs
/// to be created by the creator of the NFT Collection. Then, the `Listing` admin
/// should request to join the marketplace launchpad, pending acceptance.
///
/// Whilst the `Marketplace` stipulates a default fee policy, the marketplace
/// admin can decide to create a custom fee policy for each `Listing`.
///
/// The `Listing` acts as the object that configures the primary NFT listing
/// strategy, that is the primary market sale. Primary market sales can take
/// many shapes, depending on the business level requirements.
module ob_launchpad::marketplace {
    use sui::transfer;
    use sui::vec_set;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_field as df;

    use originmate::object_box::{Self as obox, ObjectBox};

    friend ob_launchpad::listing;

    // Track the current version of the module
    const VERSION: u64 = 2;

    const ENotUpgraded: u64 = 999;
    const EWrongVersion: u64 = 1000;

    /// Transaction sender was not admin of marketplace
    const EInvalidAdmin: u64 = 1;

    const ENotAMemberNorAdmin: u64 = 2;

    struct MembersDfKey has store, copy, drop {}

    struct Marketplace has key, store {
        id: UID,
        version: u64,
        /// The address of the marketplace administrator
        admin: address,
        /// Receiver of marketplace fees
        receiver: address,
        default_fee: ObjectBox,
    }

    /// Initialises a `Marketplace` object and returns it
    public fun new<F: key + store>(
        admin: address,
        receiver: address,
        default_fee: F,
        ctx: &mut TxContext,
    ): Marketplace {
        let uid = object::new(ctx);
        let default_fee = obox::new(default_fee, ctx);

        Marketplace {
            id: uid,
            version: VERSION,
            admin,
            receiver,
            default_fee,
        }
    }

    /// Initialises a `Marketplace` object and shares it
    public entry fun init_marketplace<F: key + store>(
        admin: address,
        receiver: address,
        default_fee: F,
        ctx: &mut TxContext,
    ) {
        let marketplace = new(
            admin,
            receiver,
            default_fee,
            ctx,
        );

        transfer::public_share_object(marketplace);
    }

    public entry fun add_member(
        marketplace: &mut Marketplace,
        member: address,
        ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(marketplace);
        assert_marketplace_admin(marketplace, ctx);

        if (df::exists_(&mut marketplace.id, MembersDfKey {})) {
            let members = df::borrow_mut(&mut marketplace.id, MembersDfKey {});
            vec_set::insert(members, member);
        } else {
            let members = vec_set::singleton(member);
            vec_set::insert(&mut members, member);
        };
    }

    public entry fun remove_member(
        marketplace: &mut Marketplace,
        member: address,
        ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(marketplace);
        assert_marketplace_admin(marketplace, ctx);

        let members = df::borrow_mut(&mut marketplace.id, MembersDfKey {});
        vec_set::remove(members, &member);
    }

    // === Getters ===

    /// Get the Marketplace's `receiver` address
    public fun receiver(marketplace: &Marketplace): address {
        marketplace.receiver
    }

    /// Get the Marketplace's `admin` address
    public fun admin(marketplace: &Marketplace): address {
        marketplace.admin
    }

    /// Get the Marketplace's `default_fee`
    public fun default_fee(marketplace: &Marketplace): &ObjectBox {
        &marketplace.default_fee
    }

    // === Assertions ===

    public fun assert_marketplace_admin(
        marketplace: &Marketplace,
        ctx: &mut TxContext,
    ) {
        assert!(
            tx_context::sender(ctx) == marketplace.admin,
            EInvalidAdmin,
        );
    }

    public fun assert_listing_admin_or_member(marketplace: &Marketplace, ctx: &mut TxContext) {
        let is_admin = tx_context::sender(ctx) == marketplace.admin;

        if (is_admin == false) {
            assert!(df::exists_(&marketplace.id, MembersDfKey {}), ENotAMemberNorAdmin);

            let members = df::borrow(&marketplace.id, MembersDfKey {});
            assert!(vec_set::contains(members, &tx_context::sender(ctx)), ENotAMemberNorAdmin);
        }
    }

    public fun is_admin_or_member(marketplace: &Marketplace, ctx: &mut TxContext): bool {
        let is_admin_or_member = tx_context::sender(ctx) == marketplace.admin;

        if (is_admin_or_member == false && df::exists_(&marketplace.id, MembersDfKey {})) {
            let members = df::borrow(&marketplace.id, MembersDfKey {});
            is_admin_or_member = vec_set::contains(members, &tx_context::sender(ctx))
        };

        is_admin_or_member
    }

    // === Upgradeability ===

    public (friend) fun assert_version(marketplace: &Marketplace) {
        assert!(marketplace.version == VERSION, EWrongVersion);
    }

    fun assert_version_and_upgrade(self: &mut Marketplace) {
        if (self.version < VERSION) {
            self.version = VERSION;
        };
        assert_version(self);
    }

    entry fun migrate(marketplace: &mut Marketplace, ctx: &mut TxContext) {
        assert_marketplace_admin(marketplace, ctx);

        assert!(marketplace.version < VERSION, ENotUpgraded);
        marketplace.version = VERSION;
    }
}
