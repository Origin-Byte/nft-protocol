/// Module of a standard collection `CollectionMeta` type.
/// 
/// It acts as a standard domain-specific implementation of an Nft 
/// collection.
/// 
/// TODO: Implement functionality to verify creators
module nft_protocol::std_collection {
    use std::vector;
    use std::string::{Self, String};
    use sui::transfer;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{TxContext};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::utils::{to_string_vector};

    use sui::event;

    struct StdCollection has drop {}

    struct CollectionMeta has key, store {
        id: UID,
        royalty_fee_bps: u64,
        creators: vector<Creator>,
        data: String,
    }

    struct Creator has store, copy, drop {
        id: address,
        /// The creator needs to sign a transaction in order to be verified.
        /// Otherwise anyone could just spoof the creator's identity
        verified: bool,
        share_of_royalty: u8,
    }

    struct InitStandardCollection has drop {
        name: String,
        symbol: String,
        max_supply: u64,
        initial_price: u64,
        receiver: address,
        tags: vector<String>,
        royalty_fee_bps: u64,
        is_mutable: bool,
        data: String
    }

    struct InitEvent has copy, drop { object_id: ID }

    // === Entrypoints ===

    /// Mint one `Collection` with `Metadata` and send it to `recipient`.
    public entry fun mint_and_transfer(
        // Name of the Nft Collection. This parameter is a
        // vector of bytes that encondes to utf8
        name: vector<u8>,
        // Symbol of the Nft Collection. This parameter is a
        // vector of bytes that should enconde to utf8
        symbol: vector<u8>,
        max_supply: u64,
        initial_price: u64,
        receiver: address,
        tags: vector<vector<u8>>,
        royalty_fee_bps: u64,
        is_mutable: bool,
        // This is a vector of bytes that encodes to utf8. This fields allows
        // project owners to add any arbitrary string data to the Collection
        // object.
        data: vector<u8>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let args = init_args(
            string::utf8(name),
            string::utf8(symbol),
            max_supply,
            initial_price,
            receiver,
            to_string_vector(&mut tags),
            royalty_fee_bps,
            is_mutable,
            string::utf8(data),
        );

        let metadata = CollectionMeta {
            id: object::new(ctx),
            royalty_fee_bps: args.royalty_fee_bps,
            creators: vector::empty(),
            data: args.data,
        };

        let collection_args = collection::init_args(
            args.name,
            args.symbol,
            args.max_supply,
            args.initial_price,
            args.receiver,
            args.tags,
            args.is_mutable,
        );

        let collection = collection::create(
            StdCollection {},
            collection_args,
            metadata,
            ctx,
        );

        event::emit(
            InitEvent {
                object_id: object::id(&collection),
            }
        );

        transfer::transfer(
            collection,
            recipient,
        )
    }

    /// Mint one `Collection` with `Metadata` object and share collection 
    /// object. With the current implementation, that is without the Launchpad
    /// module, the NFTs are minted to the public directly from the NFT
    /// contract. This is suboptimal because the metadata has to be given as
    /// parameters to the function call.
    /// 
    /// In the near future we will separate the minting action of the Nft from
    /// the sale of the Nft to the public via primary market modules. For the
    /// timebeing however, we allow the collection to be shared and let the 
    /// front end perform the function call with the metadata.
    public entry fun mint_and_share(
        name: vector<u8>,
        symbol: vector<u8>,
        max_supply: u64,
        initial_price: u64,
        receiver_address: address,
        tags: vector<vector<u8>>,
        royalty_fee_bps: u64,
        is_mutable: bool,
        data: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let args = init_args(
            string::utf8(name),
            string::utf8(symbol),
            max_supply,
            initial_price,
            receiver_address,
            to_string_vector(&mut tags),
            royalty_fee_bps,
            is_mutable,
            string::utf8(data),
        );

        let metadata = CollectionMeta {
            id: object::new(ctx),
            royalty_fee_bps: args.royalty_fee_bps,
            creators: vector::empty(),
            data: args.data,
        };

        let collection_args = collection::init_args(
            args.name,
            args.symbol,
            args.max_supply,
            args.initial_price,
            args.receiver,
            args.tags,
            args.is_mutable,
        );

        let collection = collection::create(
            StdCollection {},
            collection_args,
            metadata,
            ctx,
        );

        event::emit(
            InitEvent {
                object_id: object::id(&collection),
            }
        );

        transfer::share_object(collection);
    }

    /// Burn a Standard Collection. Invokes `burn()`.
    public entry fun burn(
        coll: Collection<StdCollection, CollectionMeta>,
        ctx: &mut TxContext,
        ) {
        // Delete generic Collection object
        let metadata = collection::burn(
            coll,
            ctx,
        );

        let CollectionMeta {
            id,
            royalty_fee_bps: _,
            creators: _,
            data: _,
        } = metadata;

        // Delete collection metadata
        object::delete(id);
    }

    /// Remove a `Creator` from `Collection`
    public entry fun remove_creator<T: drop, Meta: store>(
        meta: &mut CollectionMeta,
        creator_address: address,
    ) {
        if (!vector::is_empty(&meta.creators)) {
            remove_address(
                &mut meta.creators,
                creator_address,
            )
        }
    }

    /// Add a `Creator` to `Collection`
    public entry fun add_creator(
        meta: &mut CollectionMeta,
        creator_address: address,
        share_of_royalty: u8,
    ) {
        // TODO: Need to make sure sum of all Creator's `share_of_royalty` is
        // not above 100%
        let creator = Creator {
            id: creator_address,
            verified: true,
            share_of_royalty: share_of_royalty,
        };

        if (
            !contains_address(&meta.creators, creator_address)
        ) {
            vector::push_back(&mut meta.creators, creator);
        }
    }

    /// Change field `royalty_fee_bps` in `Collection`
    public entry fun change_royalty<T: drop, Meta: store>(
        meta: &mut CollectionMeta,
        new_royalty_fee_bps: u64,
    ) {
        meta.royalty_fee_bps = new_royalty_fee_bps;
    }

    // === Getter Functions ===

    /// Get the Collection Meta's `royalty_fee_bps`
    public fun royalty(
        meta: &CollectionMeta,
    ): u64 {
        meta.royalty_fee_bps
    }

    /// Get the Collection Meta's `creators`
    public fun creators(
        meta: &CollectionMeta,
    ): vector<Creator> {
        meta.creators
    }

    /// Get the Collection Meta's `data`
    public fun data(
        meta: &CollectionMeta,
    ): String {
        meta.data
    }


    // === Private Functions ===

    fun init_args(
        name: String,
        symbol: String,
        max_supply: u64,
        initial_price: u64,
        receiver: address,
        tags: vector<String>,
        royalty_fee_bps: u64,
        is_mutable: bool,
        data: String,
    ): InitStandardCollection {
        InitStandardCollection {
            name,
            symbol,
            max_supply,
            initial_price,
            receiver,
            tags,
            royalty_fee_bps,
            is_mutable,
            data,
        }
    }

    fun contains_address(
        v: &vector<Creator>, c_address: address
    ): bool {
        let i = 0;
        let len = vector::length(v);
        while (i < len) {
            let creator = vector::borrow(v, i);
            if (creator.id == c_address) return true;
            i = i +1;
        };
        false
    }

    fun remove_address(
        v: &mut vector<Creator>, c_address: address
    ) {
        let i = 0;
        let len = vector::length(v);
        while (i < len) {
            let creator = vector::borrow(v, i);

            if (creator.id == c_address) {
                vector::remove(v, i);
            }
        }
    }
}

#[test_only]
module nft_protocol::std_collection_tests {
    use std::vector::{Self};
    use std::string::{Self};
    use sui::test_scenario;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::std_collection::{Self, StdCollection, CollectionMeta};
    use nft_protocol::utils::{to_string_vector};
    use nft_protocol::tags::{from_vec_string};

    struct WitnessTest has drop {}
    struct MetadataTest has drop, store {}

    #[test]
    fun std_collection() {
        let addr1 = @0xA;
        let scenario = test_scenario::begin(&addr1);

        let tags: vector<vector<u8>> = vector::empty();
        vector::push_back(&mut tags, b"Art");

        // create the Standard Collection
        test_scenario::next_tx(&mut scenario, &addr1);
        std_collection::mint_and_share(
            b"Yellow Submarines", // name
            b"YLSBM", // symbol
            10, // total_supply
            100, // initial_price
            addr1, // receiver
            tags, // tags
            5, // royalty_fee_bps
            false, // is_mutable
            b"", // data
            test_scenario::ctx(&mut scenario)
        );

        // create the Standard Collection
        test_scenario::next_tx(&mut scenario, &addr1);

        let coll_wrapper = test_scenario::take_shared<Collection<StdCollection, CollectionMeta>>(&mut scenario);
        let coll: &mut Collection<StdCollection, CollectionMeta> = test_scenario::borrow_mut(&mut coll_wrapper);

        assert!(
            *collection::name(coll) == string::utf8(b"Yellow Submarines"),
        0);

        assert!(
            *collection::symbol(coll) == string::utf8(b"YLSBM"),
        0);

        assert!(
            collection::total_supply(coll) == 10,
        0);

        assert!(
            collection::initial_price(coll) == 100,
        0);

        assert!(
            collection::receiver(coll) == addr1,
        0);

        assert!(
            collection::tags(coll) == from_vec_string(&mut to_string_vector(&mut tags)),
        0);

        assert!(
            std_collection::royalty(collection::metadata(coll)) == 5,
        0);

        assert!(
            std_collection::data(collection::metadata(coll)) == string::utf8(b""),
        0);

        assert!(
            std_collection::creators(collection::metadata(coll)) == vector::empty(),
        0);

        test_scenario::return_shared(&mut scenario, coll_wrapper);
    }
}