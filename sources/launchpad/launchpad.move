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
module nft_protocol::launchpad {
    // TODO: Function to delete a slot
    // TODO: Reconsider permissioning model between launchpad and slots
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::object_box::{Self as obox, ObjectBox};

    struct Launchpad has key, store {
        id: UID,
        /// The address of the launchpad administrator
        admin: address,
        /// Receiver of launchpad fees
        receiver: address,
        /// Permissionless launchpads allow for anyone to create their
        /// slots, therefore being immediately approved.
        is_permissioned: bool,
        default_fee: ObjectBox,
    }

    /// Initialises a `Launchpad` object and returns it
    public fun new<F: key + store>(
        admin: address,
        receiver: address,
        is_permissioned: bool,
        default_fee: F,
        ctx: &mut TxContext,
    ): Launchpad {
        let uid = object::new(ctx);
        let default_fee = obox::new(default_fee, ctx);

        Launchpad {
            id: uid,
            admin,
            receiver,
            is_permissioned,
            default_fee,
        }
    }

    /// Initialises a `Launchpad` object and shares it
    public entry fun init_launchpad<F: key + store>(
        admin: address,
        receiver: address,
        is_permissioned: bool,
        default_fee: F,
        ctx: &mut TxContext,
    ) {
        let launchpad = new(
            admin,
            receiver,
            is_permissioned,
            default_fee,
            ctx,
        );

        transfer::share_object(launchpad);
    }

    // === Getters ===

    /// Get the Slot's `receiver` address
    public fun receiver(launchpad: &Launchpad): address {
        launchpad.receiver
    }

    /// Get the Slot's `admin` address
    public fun admin(launchpad: &Launchpad): address {
        launchpad.admin
    }

    public fun default_fee(launchpad: &Launchpad): &ObjectBox {
        &launchpad.default_fee
    }

    public fun is_permissioned(launchpad: &Launchpad): bool {
        launchpad.is_permissioned
    }

    // === Assertions ===

    public fun assert_launchpad_admin(
        launchpad: &Launchpad,
        ctx: &mut TxContext,
    ) {
        assert!(
            tx_context::sender(ctx) == launchpad.admin,
            err::wrong_launchpad_admin()
        );
    }
}
