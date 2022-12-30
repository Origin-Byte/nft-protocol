/// Module of a `Launchpad` type.
///
/// Launchpads are platforms that facilitate the release of NFT collections
/// to the public, via primary market. Whilst NFT creators can emit NFTs
/// directly and thus bypass the `Launchpad`, the `Launchpad` offers a myriad
/// of bespoke emission strategies.
///
/// Launchapds can either be Permissioned or Permissionless. Marketplaces and
/// dApps that want to offer a launchpad service can create a Permissioned
/// Launchpad. In a permissioned model, the Marketplace or dApp is responsible
/// for making and signing all the RPC calls to configure and implement the
/// release strategy. If the launchpad is permissionless, then the creators
/// are the ones responsible for configuring and implementing it themselves.
/// In other words, permissioned launchpads allow for the creation of
/// fully manager services, whilst permissionless launchpads always require
/// the creator's signature.
///
/// After the creation of the `Launchpad` a `Slot` for the NFT release needs
/// to be created. Whilst the `Launchpad` stipulates a default fee policy,
/// the launchpad admin can decide to create a custom fee policy for each
/// release `Slot`.
///
/// The slot acts as the object that configures the primary NFT release
/// strategy, that is the primary market sale. Primary market sales can take
/// many shapes, depending on the business level requirements.
module nft_protocol::marketplace {
    // TODO: Function to delete a slot
    // TODO: Reconsider permissioning model between launchpad and slots
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::object_box::{Self as obox, ObjectBox};

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
