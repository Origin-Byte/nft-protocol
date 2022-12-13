//! Module of a `Launchpad` type and its associated `Slot`s.
//!
//! The slot acts as the object that configures the primary NFT release
//! strategy, that is the primary market sale. Primary market sales can take
//! many shapes, depending on the business level requirements.
module nft_protocol::launchpad {
    // TODO: Function to delete a slot
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
        auto_approval: bool,
        default_fee: F,
        ctx: &mut TxContext,
    ) {
        let launchpad = new(
            admin,
            receiver,
            auto_approval,
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
