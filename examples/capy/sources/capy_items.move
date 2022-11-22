// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// Items for Capys.
/// Every capy can have up to X items at the same time.
module capy::capy_items {
    use sui::event::emit;
    use sui::url::{Self, Url};
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use std::string::{Self, String};
    use std::vector as vec;
    use sui::transfer::transfer;

    use capy::hex;
    use capy::capy::{CAPY, CapyManagerCap};

    use nft_protocol::nft::{Self, NFT};

    /// Base path for `CapyItem.url` attribute. Is temporary and improves
    /// explorer / wallet display. Always points to the dev/testnet server.
    const IMAGE_URL: vector<u8> = b"https://api.capy.art/items/";

    const MAX_ITEMS: u64 = 255;

    struct Witness has drop {}

    struct CapyInventoryDomain has store {
        items: vector<CapyItem>,
    }

    /// Need a way to submit actual items.
    /// Perhaps, we could categorize them or change types.
    struct CapyItem has key, store {
        id: UID,
        url: Url,
        type: String,
        name: String,
    }


    // ======== Events =========

    /// Emitted when new item is created.
    struct ItemCreated has copy, drop {
        id: ID,
        type: vector<u8>,
        name: vector<u8>,
    }

    /// Event. Emitted when a new item is added to a capy.
    struct ItemAdded<phantom T> has copy, drop {
        capy_id: ID,
        item_id: ID
    }

    /// Event. Emitted when an item is taken off.
    struct ItemRemoved<phantom T> has copy, drop {
        capy_id: ID,
        item_id: ID,
    }


    // ======== Functions =========

    /// Attach an Item to a Capy. Function is generic and allows any app to attach items to
    /// Capys but the total count of items has to be lower than 255.
    entry fun add_item<T: key + store>(capy: &mut NFT<CAPY>, item: CapyItem) {
        emit(ItemAdded<T> {
            capy_id: object::id(capy),
            item_id: object::id(&item)
        });

        if (!nft::has_domain<CAPY, CapyInventoryDomain>(capy)) {
            nft::add_domain(capy, CapyInventoryDomain {
                items: vec::singleton(item),
            });
        } else {
            let inventory: &mut CapyInventoryDomain =
                nft::borrow_domain_mut(Witness {}, capy);
            assert!(vec::length(&inventory.items) < MAX_ITEMS, 0);

            vec::push_back(&mut inventory.items, item);
        }
    }

    /// Remove item from the Capy.
    entry fun remove_item<T: key + store>(capy: &mut NFT<CAPY>, item_id: ID, ctx: &mut TxContext) {
        emit(ItemRemoved<T> {
            capy_id: object::id(capy),
            item_id: *&item_id
        });

        let inventory: &mut CapyInventoryDomain =
                nft::borrow_domain_mut(Witness {}, capy);

        let i = 0;
        while (i < vec::length(&inventory.items)) {
            if (object::id(vec::borrow(&inventory.items, i)) == item_id) {
                break
            };
            i = i + 1;
        };
        assert!(i < vec::length(&inventory.items), 0);
        let item = vec::swap_remove(&mut inventory.items, i);

        transfer(item, tx_context::sender(ctx));
    }

    /// Create new item and send it to sender. Only available to Capy Admin.
    public entry fun create_and_take(
        cap: &CapyManagerCap,
        type: vector<u8>,
        name: vector<u8>,
        ctx: &mut TxContext
    ) {
        sui::transfer::transfer(
            create_item(cap, type, name, ctx),
            sui::tx_context::sender(ctx)
        );
    }

    /// Admin-only action - create an item. Ideally to place it later to the marketplace or send to someone.
    public fun create_item(
        _: &CapyManagerCap,
        type: vector<u8>,
        name: vector<u8>,
        ctx: &mut TxContext
    ): CapyItem {
        let id = object::new(ctx);
        let id_copy = object::uid_to_inner(&id);

        emit(ItemCreated { id: id_copy, type, name });

        CapyItem {
            url: img_url(&id),
            id,
            type: string::utf8(type),
            name: string::utf8(name)
        }
    }

    /// Construct an image URL for the `CapyItem`.
    fun img_url(c: &UID): Url {
        let capy_url = *&IMAGE_URL;
        vec::append(&mut capy_url, hex::to_hex(object::uid_to_bytes(c)));
        vec::append(&mut capy_url, b"/svg");

        url::new_unsafe_from_bytes(capy_url)
    }
}
