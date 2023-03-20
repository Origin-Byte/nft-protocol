// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

// NOTE: This is a placeholder, we are temporarily adding this file to this
// branch to make it easier to import, but will be removed as soon as devnet-0.28.0
// is released.
module nft_protocol::kiosk {
    use std::option::{Self, Option};
    use sui::object::{Self, UID, ID};
    use sui::dynamic_object_field as dof;
    use sui::dynamic_field as df;
    use nft_protocol::transfer_policy::{Self, TransferRequest};
    use sui::tx_context::{TxContext, sender};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::event;

    /// Trying to withdraw profits and sender is not owner.
    const ENotOwner: u64 = 0;
    /// Coin paid does not match the offer price.
    const EIncorrectAmount: u64 = 1;
    /// Trying to withdraw higher amount than stored.
    const ENotEnough: u64 = 2;
    /// Trying to close a Kiosk and it has items in it.
    const ENotEmpty: u64 = 3;
    /// Attempt to take an item that has a `PurchaseCap` issued.
    const EListedExclusively: u64 = 4;
    /// `PurchaseCap` does not match the `Kiosk`.
    const EWrongKiosk: u64 = 5;
    /// Tryng to exclusively list an already listed item.
    const EAlreadyListed: u64 = 6;
    /// Trying to call `uid_mut` when extensions disabled
    const EExtensionsDisabled: u64 = 7;

    /// An object which allows selling collectibles within "kiosk" ecosystem.
    /// By default gives the functionality to list an item openly - for anyone
    /// to purchase providing the guarantees for creators that every transfer
    /// needs to be approved via the `TransferPolicy`.
    struct Kiosk has key, store {
        id: UID,
        /// Balance of the Kiosk - all profits from sales go here.
        profits: Balance<SUI>,
        /// Always point to `sender` of the transaction.
        /// Can be changed by calling `set_owner` with Cap.
        owner: address,
        /// Number of items stored in a Kiosk. Used to allow unpacking
        /// an empty Kiosk if it was wrapped or has a single owner.
        item_count: u32,
        /// Whether to open the UID to public. Set to `true` by default
        /// but the owner can switch the state if necessary.
        allow_extensions: bool
    }

    /// A Capability granting the bearer a right to `place` and `take` items
    /// from the `Kiosk` as well as to `list` them and `list_with_purchase_cap`.
    struct KioskOwnerCap has key, store {
        id: UID,
        for: ID
    }

    /// A capability which locks an item and gives a permission to
    /// purchase it from a `Kiosk` for any price no less than `min_price`.
    ///
    /// Allows exclusive listing: only bearer of the `PurchaseCap` can
    /// purchase the asset. However, the capablity should be used
    /// carefully as losing it would lock the asset in the `Kiosk`.
    ///
    /// The main application for the `PurchaseCap` is building extensions
    /// on top of the `Kiosk`.
    struct PurchaseCap<phantom T: key + store> has key, store {
        id: UID,
        /// ID of the `Kiosk` the cap belongs to.
        kiosk_id: ID,
        /// ID of the listed item.
        item_id: ID,
        /// Minimum price for which the item can be purchased.
        min_price: u64
    }

    // === Dynamic Field keys ===

    /// Dynamic field key for an item placed into the kiosk.
    struct Item has store, copy, drop { id: ID }

    /// Dynamic field key for an active offer to purchase the T. If an
    /// item is listed without a `PurchaseCap`, exclusive is set to `false`.
    struct Listing has store, copy, drop { id: ID, is_exclusive: bool }

    // === Events ===

    /// Emitted when an item was listed by the safe owner. Can be used
    /// to track available offers anywhere on the network; the event is
    /// type-indexed which allows for searching for offers of a specific `T`
    struct ItemListed<phantom T: key + store> has copy, drop {
        kiosk: ID,
        id: ID,
        price: u64
    }

    // === Kiosk packing and unpacking ===

    /// Creates a new `Kiosk` with a matching `KioskOwnerCap`.
    public fun new(ctx: &mut TxContext): (Kiosk, KioskOwnerCap) {
        let kiosk = Kiosk {
            id: object::new(ctx),
            profits: balance::zero(),
            owner: sender(ctx),
            item_count: 0,
            allow_extensions: true
        };

        let cap = KioskOwnerCap {
            id: object::new(ctx),
            for: object::id(&kiosk)
        };

        (kiosk, cap)
    }

    /// Unpacks and destroys a Kiosk returning the profits (even if "0").
    /// Can only be performed by the bearer of the `KioskOwnerCap` in the
    /// case where there's no items inside and a `Kiosk` is not shared.
    public fun close_and_withdraw(
        self: Kiosk, cap: KioskOwnerCap, ctx: &mut TxContext
    ): Coin<SUI> {
        let Kiosk { id, profits, owner: _, item_count, allow_extensions: _ } = self;
        let KioskOwnerCap { id: cap_id, for } = cap;

        assert!(object::uid_to_inner(&id) == for, ENotOwner);
        assert!(item_count == 0, ENotEmpty);

        object::delete(cap_id);
        object::delete(id);

        coin::from_balance(profits, ctx)
    }

    /// Change the `owner` field to the transaction sender.
    /// The change is purely cosmetical and does not affect any of the
    /// basic kiosk functions unless some logic for this is implemented
    /// in a third party module.
    public fun set_owner(
        self: &mut Kiosk, cap: &KioskOwnerCap, ctx: &TxContext
    ) {
        assert!(object::id(self) == cap.for, ENotOwner);
        self.owner = sender(ctx);
    }

    // === Place and take from the Kiosk ===

    /// Place any object into a Kiosk.
    /// Performs an authorization check to make sure only owner can do that.
    public fun place<T: key + store>(
        self: &mut Kiosk, cap: &KioskOwnerCap, item: T
    ) {
        assert!(object::id(self) == cap.for, ENotOwner);
        self.item_count = self.item_count + 1;
        dof::add(&mut self.id, Item { id: object::id(&item) }, item)
    }

    /// Take any object from the Kiosk.
    /// Performs an authorization check to make sure only owner can do that.
    public fun take<T: key + store>(
        self: &mut Kiosk, cap: &KioskOwnerCap, id: ID
    ): T {
        assert!(object::id(self) == cap.for, ENotOwner);
        assert!(!df::exists_<Listing>(&mut self.id, Listing { id, is_exclusive: true }), EListedExclusively);

        self.item_count = self.item_count - 1;
        // NOTE: This is commented out since this method is not merged in version devnet-0.27.0 yet.
        // df::remove_if_exists<Listing, u64>(&mut self.id, Listing { id, is_exclusive: false });
        dof::remove(&mut self.id, Item { id })
    }

    // === Trading functionality: List and Purchase ===

    /// List the item by setting a price and making it available for purchase.
    /// Performs an authorization check to make sure only owner can sell.
    public fun list<T: key + store>(
        self: &mut Kiosk, cap: &KioskOwnerCap, id: ID, price: u64
    ) {
        assert!(object::id(self) == cap.for, ENotOwner);
        assert!(!df::exists_<Listing>(&mut self.id, Listing { id, is_exclusive: true }), EListedExclusively);

        df::add(&mut self.id, Listing { id, is_exclusive: false }, price);
        event::emit(ItemListed<T> {
            kiosk: object::id(self), id, price
        })
    }

    /// Calls `place` and `list` together - simplifies the flow.
    public fun place_and_list<T: key + store>(
        self: &mut Kiosk, cap: &KioskOwnerCap, item: T, price: u64
    ) {
        let id = object::id(&item);
        place(self, cap, item);
        list<T>(self, cap, id, price)
    }

    /// Make a trade: pay the owner of the item and request a Transfer to the `target`
    /// kiosk (to prevent item being taken by the approving party).
    ///
    /// Received `TransferRequest` needs to be handled by the publisher of the T,
    /// if they have a method implemented that allows a trade, it is possible to
    /// request their approval (by calling some function) so that the trade can be
    /// finalized.
    public fun purchase<T: key + store>(
        self: &mut Kiosk, id: ID, payment: Coin<SUI>, ctx: &mut TxContext
    ): (T, TransferRequest<T>) {
        let price = df::remove<Listing, u64>(&mut self.id, Listing { id, is_exclusive: false });
        let inner = dof::remove<Item, T>(&mut self.id, Item { id });

        self.item_count = self.item_count - 1;
        assert!(price == coin::value(&payment), EIncorrectAmount);
        balance::join(&mut self.profits, coin::into_balance(payment));

        (inner, transfer_policy::new_request(price, object::id(self), ctx))
    }

    // === Trading Functionality: Exclusive listing with `PurchaseCap` ===

    /// Creates a `PurchaseCap` which gives the right to purchase an item
    /// for any price equal or higher than the `min_price`.
    public fun list_with_purchase_cap<T: key + store>(
        self: &mut Kiosk, cap: &KioskOwnerCap, id: ID, min_price: u64, ctx: &mut TxContext
    ): PurchaseCap<T> {
        assert!(object::id(self) == cap.for, ENotOwner);
        assert!(!df::exists_<Listing>(&mut self.id, Listing { id, is_exclusive: false }), EAlreadyListed);

        let uid = object::new(ctx);
        df::add(&mut self.id, Listing { id, is_exclusive: true }, min_price);

        PurchaseCap<T> {
            id: uid,
            item_id: id,
            kiosk_id: cap.for,
            min_price,
        }
    }

    /// Unpack the `PurchaseCap` and call `purchase`. Sets the payment amount
    /// as the price for the listing making sure it's no less than `min_amount`.
    public fun purchase_with_cap<T: key + store>(
        self: &mut Kiosk, purchase_cap: PurchaseCap<T>, payment: Coin<SUI>, ctx: &mut TxContext
    ): (T, TransferRequest<T>) {
        let PurchaseCap { id, item_id, kiosk_id, min_price } = purchase_cap;
        let paid = coin::value(&payment);

        assert!(paid >= min_price, EIncorrectAmount);
        assert!(object::id(self) == kiosk_id, EWrongKiosk);

        df::remove<Listing, u64>(&mut self.id, Listing { id: item_id, is_exclusive: true });
        df::add(&mut self.id, Listing { id: item_id, is_exclusive: false }, paid);
        object::delete(id);

        purchase<T>(self, item_id, payment, ctx)
    }

    /// Return the `PurchaseCap` without making a purchase; remove an active offer and
    /// allow the item for taking. Can only be returned to its `Kiosk`, aborts otherwise.
    public fun return_purchase_cap<T: key + store>(
        self: &mut Kiosk, purchase_cap: PurchaseCap<T>
    ) {
        let PurchaseCap { id, item_id, kiosk_id, min_price: _ } = purchase_cap;

        assert!(object::id(self) == kiosk_id, EWrongKiosk);
        df::remove<Listing, u64>(&mut self.id, Listing { id: item_id, is_exclusive: true });
        object::delete(id)
    }

    /// Withdraw profits from the Kiosk.
    public fun withdraw(
        self: &mut Kiosk, cap: &KioskOwnerCap, amount: Option<u64>, ctx: &mut TxContext
    ): Coin<SUI> {
        assert!(object::id(self) == cap.for, ENotOwner);

        let amount = if (option::is_some(&amount)) {
            let amt = option::destroy_some(amount);
            assert!(amt <= balance::value(&self.profits), ENotEnough);
            amt
        } else {
            balance::value(&self.profits)
        };

        coin::take(&mut self.profits, amount, ctx)
    }

    // === Kiosk fields access ===

    /// Check whether the `KioskOwnerCap` matches the `Kiosk`.
    public fun has_access(self: &mut Kiosk, cap: &KioskOwnerCap): bool {
        object::id(self) == cap.for
    }

    /// Check whether the an item is present in the `Kiosk`.
    public fun has_item(self: &Kiosk, item_id: ID): bool {
        dof::exists_(&self.id, Item { id: item_id })
    }

    /// Access the `UID` using the `KioskOwnerCap`.
    public fun uid_mut_as_owner(self: &mut Kiosk, cap: &KioskOwnerCap): &mut UID {
        assert!(object::id(self) == cap.for, ENotOwner);
        &mut self.id
    }

    /// Get the mutable `UID` for dynamic field access and extensions.
    /// Aborts if `allow_extensions` set to `false`.
    public fun uid_mut(self: &mut Kiosk): &mut UID {
        assert!(self.allow_extensions, EExtensionsDisabled);
        &mut self.id
    }

    /// Get the owner of the Kiosk.
    public fun owner(self: &Kiosk): address {
        self.owner
    }

    /// Get the number of items stored in a Kiosk.
    public fun item_count(self: &Kiosk): u32 {
        self.item_count
    }

    /// Get the amount of profits collected by selling items.
    public fun profits_amount(self: &Kiosk): u64 {
        balance::value(&self.profits)
    }

    /// Get mutable access to `profits` - useful for extendability.
    public fun profits_mut(self: &mut Kiosk, cap: &KioskOwnerCap): &mut Balance<SUI> {
        assert!(object::id(self) == cap.for, ENotOwner);
        &mut self.profits
    }

    // === PurchaseCap fields access ===

    /// Get the `kiosk_id` from the `PurchaseCap`.
    public fun purchase_cap_kiosk<T: key + store>(self: &PurchaseCap<T>): ID {
        self.kiosk_id
    }

    /// Get the `Item_id` from the `PurchaseCap`.
    public fun purchase_cap_item<T: key + store>(self: &PurchaseCap<T>): ID {
        self.item_id
    }

    /// Get the `min_price` from the `PurchaseCap`.
    public fun purchase_cap_min_price<T: key + store>(self: &PurchaseCap<T>): u64 {
        self.min_price
    }
}
