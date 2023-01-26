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
module nft_protocol::marketplace {
    // TODO: Function to delete a listing
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use originmate::object_box::{Self as obox, ObjectBox};

    struct Marketplace has key, store {
        id: UID,
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

        transfer::share_object(marketplace);
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
            err::wrong_marketplace_admin()
        );
    }
}
