module nft_protocol::tags {
    use std::option::{Self, Option};

    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::object_bag::{Self, ObjectBag};
    use sui::tx_context::{TxContext};

    use nft_protocol::err;

    struct Tags has key, store {
        id: UID,
        bag: ObjectBag,
    }

    struct Art has store, drop {} // 1
    struct PFP has store {} // 2
    struct Collectible has store, drop {} // 3
    struct GameAsset has store, drop {} // 4
    struct TokenisedAsset has store, drop {} // 5
    struct Ticker has store, drop {} // 6
    struct DomainName has store, drop {} // 7
    struct Gif has store, drop {} // 8
    struct Music has store, drop {} // 9
    struct Video has store, drop {} // 10
    struct Ticket has store, drop {} // 11
    struct License has store, drop {} // 12

    struct MintEvent has copy, drop {
        id: ID,
    }

    struct BurnEvent has copy, drop {
        id: ID,
    }

    /// Create a `Tags` object and returns it.
    public fun create<D: store>(
        ctx: &mut TxContext,
        tags: vector<u64>,
    ): Tags {
        let id = object::new(ctx);
        let bag = object_bag::new(ctx);

        let i = 0;
        let len = vector::length(tags);
        while (i < len) {
            let num = vector::borrow(v, i);
            add_tag(&mut bag, num);
            i = i +1;
        };

        event::emit(
            MintEvent {
                id: object::uid_to_inner(&id),
            }
        );

        Tags {
            id,
            bag,
        }
    }

    pub fun push_tag(&mut bag: ObjectBag, num: u64) {
        add_tag(bag, num);
    }

    pub fun pop_tag(&mut bag: ObjectBag, num: u64) {
        remove_tag(&mut bag, num);
    }

    // === Getter Functions  ===

    public fun id<D: store>(
        core: &CoreData<D>,
    ): ID {
        object::uid_to_inner(&core.id)
    }

    public fun id_ref<D: store>(
        core: &CoreData<D>,
    ): &ID {
        object::uid_as_inner(&core.id)
    }

    public fun data<D: store>(
        core: &CoreData<D>,
    ): &D {
        &core.data
    }

    public fun data_mut<D: store>(
        core: &mut CoreData<D>,
    ): &mut D {
        &mut core.data
    }


    fun add_tag(&mut bag: ObjectBag, num: u64) {
        if (num == 1) {
            let tag = Art {};
            object_bag::add<u64, Art>(bag, num, tag);
        }
        if (num == 2) {
            let tag = PFP {};
            object_bag::add<u64, PFP>(bag, num, tag);
        }
        if (num == 3) {
            let tag = Collectible {};
            object_bag::add<u64, Collectible>(bag, num, tag);
        }
        if (num == 4) {
            let tag = GameAsset {};
            object_bag::add<u64, GameAsset>(bag, num, tag);
        }
        if (num == 5) {
            let tag = TokenisedAsset {};
            object_bag::add<u64, TokenisedAsset>(bag, num, tag);
        }
        if (num == 6) {
            let tag = Ticker {};
            object_bag::add<u64, Ticker>(bag, num, tag);
        }
        if (num == 7) {
            let tag = DomainName {};
            object_bag::add<u64, DomainName>(bag, num, tag);
        }
        if (num == 8) {
            let tag = Gif {};
            object_bag::add<u64, Gif>(bag, num, tag);
        }
        if (num == 9) {
            let tag = Music {};
            object_bag::add<u64, Music>(bag, num, tag);
        }
        if (num == 10) {
            let tag = Video {};
            object_bag::add<u64, Video>(bag, num, tag);
        }
        if (num == 11) {
            let tag = Ticket {};
            object_bag::add<u64, Ticket>(bag, num, tag);
        }
        if (num == 12) {
            let tag = License {};
            object_bag::add<u64, License>(bag, num, tag);
        }
    }

    fun remove_tag(&mut bag: ObjectBag, num: u64) {
        if (num == 1) {
            let tag = Art {};
            object_bag::remove<u64, Art>(bag, num);
        }
        if (num == 2) {
            let tag = PFP {};
            object_bag::remove<u64, PFP>(bag, num);
        }
        if (num == 3) {
            let tag = Collectible {};
            object_bag::remove<u64, Collectible>(bag, num);
        }
        if (num == 4) {
            let tag = GameAsset {};
            object_bag::remove<u64, GameAsset>(bag, num);
        }
        if (num == 5) {
            let tag = TokenisedAsset {};
            object_bag::remove<u64, TokenisedAsset>(bag, num);
        }
        if (num == 6) {
            let tag = Ticker {};
            object_bag::remove<u64, Ticker>(bag, num);
        }
        if (num == 7) {
            let tag = DomainName {};
            object_bag::remove<u64, DomainName>(bag, num);
        }
        if (num == 8) {
            let tag = Gif {};
            object_bag::remove<u64, Gif>(bag, num);
        }
        if (num == 9) {
            let tag = Music {};
            object_bag::remove<u64, Music>(bag, num);
        }
        if (num == 10) {
            let tag = Video {};
            object_bag::remove<u64, Video>(bag, num);
        }
        if (num == 11) {
            let tag = Ticket {};
            object_bag::remove<u64, Ticket>(bag, num);
        }
        if (num == 12) {
            let tag = License {};
            object_bag::remove<u64, License>(bag, num);
        }
    }
}
