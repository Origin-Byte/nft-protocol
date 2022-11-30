/// Nft Collection Tags is an enumeration of tags, represented
/// as Types. An NFT Tag is a type that categorises the domain
/// in which the NFT operates (i.e. Art, Profile Picture, Gaming, etc.)
/// This allows wallets and marketplaces to organise NFTs by its
/// domain specificity.
module nft_protocol::tags {
    // TODO: Consider using `VecSet` instead of `VecMap` since
    // keys are simply indices
    use std::vector;
    use std::string::String;
    use std::option::{Self, Option};

    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::bag::{Self, Bag};

    use nft_protocol::err;
    use nft_protocol::utils::to_string_vector;

    struct Tags has key, store {
        id: UID,
        bag: Bag,
    }

    struct Art has store, drop {} // 1
    struct PFP has store, drop {} // 2
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
        let bag = bag::new(ctx);

        let i = 0;
        let len = vector::length(&tags);
        while (i < len) {
            let num = vector::borrow(&tags, i);
            add_tag(&mut bag, *num);
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

    /// Add a tag to the Collections's `tags`
    /// Contrary to other fields, tags can be always added by
    /// the collection owner, even if the collection is marked
    /// as immutable.
    public fun push_tag(bag: &mut Bag, num: u64) {
        add_tag(bag, num);
    }

    /// Removes a tag to the Collections's `tags`
    /// Contrary to other fields, tags can be always removed by
    /// the collection owner, even if the collection is marked
    /// as immutable.
    public fun pop_tag(bag: &mut Bag, num: u64) {
        remove_tag(bag, num);
    }

    // === Getter Functions  ===

    public fun id(
        tags: &Tags,
    ): ID {
        object::uid_to_inner(&tags.id)
    }

    public fun id_ref(
        tags: &Tags,
    ): &ID {
        object::uid_as_inner(&tags.id)
    }


    fun add_tag(bag: &mut Bag, num: u64) {
        if (num == 1) {
            let tag = Art {};
            bag::add<u64, Art>(bag, num, tag);
        };
        if (num == 2) {
            let tag = PFP {};
            bag::add<u64, PFP>(bag, num, tag);
        };
        if (num == 3) {
            let tag = Collectible {};
            bag::add<u64, Collectible>(bag, num, tag);
        };
        if (num == 4) {
            let tag = GameAsset {};
            bag::add<u64, GameAsset>(bag, num, tag);
        };
        if (num == 5) {
            let tag = TokenisedAsset {};
            bag::add<u64, TokenisedAsset>(bag, num, tag);
        };
        if (num == 6) {
            let tag = Ticker {};
            bag::add<u64, Ticker>(bag, num, tag);
        };
        if (num == 7) {
            let tag = DomainName {};
            bag::add<u64, DomainName>(bag, num, tag);
        };
        if (num == 8) {
            let tag = Gif {};
            bag::add<u64, Gif>(bag, num, tag);
        };
        if (num == 9) {
            let tag = Music {};
            bag::add<u64, Music>(bag, num, tag);
        };
        if (num == 10) {
            let tag = Video {};
            bag::add<u64, Video>(bag, num, tag);
        };
        if (num == 11) {
            let tag = Ticket {};
            bag::add<u64, Ticket>(bag, num, tag);
        };
        if (num == 12) {
            let tag = License {};
            bag::add<u64, License>(bag, num, tag);
        };
    }

    fun remove_tag(bag: &mut Bag, num: u64) {
        if (num == 1) {
            let tag = Art {};
            bag::remove<u64, Art>(bag, num);
        };
        if (num == 2) {
            let tag = PFP {};
            bag::remove<u64, PFP>(bag, num);
        };
        if (num == 3) {
            let tag = Collectible {};
            bag::remove<u64, Collectible>(bag, num);
        };
        if (num == 4) {
            let tag = GameAsset {};
            bag::remove<u64, GameAsset>(bag, num);
        };
        if (num == 5) {
            let tag = TokenisedAsset {};
            bag::remove<u64, TokenisedAsset>(bag, num);
        };
        if (num == 6) {
            let tag = Ticker {};
            bag::remove<u64, Ticker>(bag, num);
        };
        if (num == 7) {
            let tag = DomainName {};
            bag::remove<u64, DomainName>(bag, num);
        };
        if (num == 8) {
            let tag = Gif {};
            bag::remove<u64, Gif>(bag, num);
        };
        if (num == 9) {
            let tag = Music {};
            bag::remove<u64, Music>(bag, num);
        };
        if (num == 10) {
            let tag = Video {};
            bag::remove<u64, Video>(bag, num);
        };
        if (num == 11) {
            let tag = Ticket {};
            bag::remove<u64, Ticket>(bag, num);
        };
        if (num == 12) {
            let tag = License {};
            bag::remove<u64, License>(bag, num);
        };
    }
}
