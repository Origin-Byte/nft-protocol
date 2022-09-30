/// Module of a standard collection `CollectionMeta` type.
/// 
/// It acts as a standard domain-specific implementation of an Nft 
/// collection.
/// TODO: Do we want to allow json to be modified?
module nft_protocol::std_collection {
    use std::string::{Self, String};
    use std::option::{Self, Option};

    use sui::transfer;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{TxContext};
    use sui::event;

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::utils::{to_string_vector};
    use nft_protocol::cap::{Limited};

    // TODO: Does it make sense for this to be key? I don't think so
    struct StdMeta has key, store {
        id: UID,
        json: String,
    }

    struct InitStandardCollection has drop {
        name: String,
        description: String,
        symbol: String,
        max_supply: Option<u64>,
        receiver: address,
        tags: vector<String>,
        royalty_fee_bps: u64,
        is_mutable: bool,
        json: String
    }

    struct MintEvent has copy, drop { object_id: ID }
    struct BurnEvent has copy, drop { object_id: ID }

    // === Entrypoints ===

    /// Mint one `Collection` with `Metadata` and send it to `recipient`.
    public entry fun mint_and_transfer(
        // Name of the Nft Collection. This parameter is a
        // vector of bytes that encondes to utf8
        name: vector<u8>,
        description: vector<u8>,
        // Symbol of the Nft Collection. This parameter is a
        // vector of bytes that should enconde to utf8
        symbol: vector<u8>,
        max_supply: Option<u64>,
        receiver: address,
        // TODO: When will we be able to pass vector<String>?
        // https://github.com/MystenLabs/sui/pull/4627
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
            string::utf8(description),
            string::utf8(symbol),
            max_supply,
            receiver,
            to_string_vector(&mut tags),
            royalty_fee_bps,
            is_mutable,
            string::utf8(data),
        );

        let metadata = StdMeta {
            id: object::new(ctx),
            json: args.json,
        };

        let collection_args = collection::init_args(
            args.name,
            args.description,
            args.symbol,
            args.receiver,
            args.tags,
            args.is_mutable,
            args.royalty_fee_bps,
        );

        if (option::is_none(&max_supply)) {
            let collection = collection::mint_uncapped(
                collection_args,
                metadata,
                ctx,
            );

            event::emit(
                MintEvent {
                    object_id: object::id(&collection),
                }
            );

            transfer::transfer(collection, recipient);

        } else {
            let collection = collection::mint_capped(
                collection_args,
                *option::borrow(&max_supply),
                metadata,
                ctx,
            );

            event::emit(
                MintEvent {
                    object_id: object::id(&collection),
                }
            );

            transfer::transfer(collection, recipient);
        };
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
        description: vector<u8>,
        symbol: vector<u8>,
        max_supply: Option<u64>,
        receiver: address,
        // TODO: When will we be able to pass vector<String>?
        // https://github.com/MystenLabs/sui/pull/4627
        tags: vector<vector<u8>>,
        royalty_fee_bps: u64,
        is_mutable: bool,
        json: vector<u8>,
        ctx: &mut TxContext,
    ) {
        let args = init_args(
            string::utf8(name),
            string::utf8(description),
            string::utf8(symbol),
            max_supply,
            receiver,
            to_string_vector(&mut tags),
            royalty_fee_bps,
            is_mutable,
            string::utf8(json),
        );

        let metadata = StdMeta {
            id: object::new(ctx),
            json: args.json,
        };

        let collection_args = collection::init_args(
            args.name,
            args.description,
            args.symbol,
            args.receiver,
            args.tags,
            args.is_mutable,
            args.royalty_fee_bps,
        );

        if (option::is_none(&max_supply)) {
            let collection = collection::mint_uncapped(
                collection_args,
                metadata,
                ctx,
            );

            event::emit(
                MintEvent {
                    object_id: object::id(&collection),
                }
            );

            transfer::share_object(collection);

        } else {
            let collection = collection::mint_capped(
                collection_args,
                *option::borrow(&max_supply),
                metadata,
                ctx,
            );

            event::emit(
                MintEvent {
                    object_id: object::id(&collection),
                }
            );

            transfer::share_object(collection);
        };
    }

    /// Burn a Standard Collection. Invokes `burn()`.
    public entry fun burn_limited_collection(
        collection: Collection<StdMeta, Limited>,
    ) {

        event::emit(
            BurnEvent {
                object_id: object::id(&collection),
            }
        );

        // Delete generic Collection object
        let metadata = collection::burn_capped(
            collection,
        );

        let StdMeta {
            id,
            json: _,
        } = metadata;

        // Delete collection metadata
        object::delete(id);
    }

    // // === Getter Functions ===

    /// Get the Collections Meta's `id`
    public fun id(
        meta: &StdMeta,
    ): ID {
        object::uid_to_inner(&meta.id)
    }

    /// Get the Collections Meta's `id` as reference
    public fun id_ref(
        meta: &StdMeta,
    ): &ID {
        object::uid_as_inner(&meta.id)
    }

    /// Get the Collections Meta's `json` as reference
    public fun json(
        meta: &StdMeta,
    ): &String {
        &meta.json
    }

    // // === Private Functions ===

    fun init_args(
        name: String,
        description: String,
        symbol: String,
        max_supply: Option<u64>,
        receiver: address,
        tags: vector<String>,
        royalty_fee_bps: u64,
        is_mutable: bool,
        json: String,
    ): InitStandardCollection {
        InitStandardCollection {
            name,
            description,
            symbol,
            max_supply,
            receiver,
            tags,
            royalty_fee_bps,
            is_mutable,
            json,
        }
    }
}

// #[test_only]
// module nft_protocol::std_collection_tests {
//     use std::vector::{Self};
//     use std::string::{Self};
//     use sui::test_scenario;
//     use nft_protocol::collection::{Self, Collection};
//     use nft_protocol::std_collection::{Self, StdCollection, CollectionMeta};
//     use nft_protocol::utils::{to_string_vector};
//     use nft_protocol::tags::{from_vec_string};

//     struct WitnessTest has drop {}
//     struct MetadataTest has drop, store {}

//     #[test]
//     fun std_collection() {
//         let addr1 = @0xA;
//         let scenario = test_scenario::begin(&addr1);

//         let tags: vector<vector<u8>> = vector::empty();
//         vector::push_back(&mut tags, b"Art");

//         // create the Standard Collection
//         test_scenario::next_tx(&mut scenario, &addr1);

//         std_collection::mint_and_share(
//             b"Yellow Submarines", // name
//             b"YLSBM", // symbol
//             10, // total_supply
//             100, // initial_price
//             addr1, // receiver
//             tags, // tags
//             5, // royalty_fee_bps
//             false, // is_mutable
//             b"", // data
//             test_scenario::ctx(&mut scenario)
//         );

//         // create the Standard Collection
//         test_scenario::next_tx(&mut scenario, &addr1);

//         let coll_wrapper = test_scenario::take_shared<Collection<StdCollection, CollectionMeta>>(&mut scenario);
//         let coll: &mut Collection<StdCollection, CollectionMeta> = test_scenario::borrow_mut(&mut coll_wrapper);

//         assert!(
//             *collection::name(coll) == string::utf8(b"Yellow Submarines"),
//         0);

//         assert!(
//             *collection::symbol(coll) == string::utf8(b"YLSBM"),
//         0);

//         assert!(
//             collection::total_supply(coll) == 10,
//         0);

//         assert!(
//             collection::initial_price(coll) == 100,
//         0);

//         assert!(
//             collection::receiver(coll) == addr1,
//         0);

//         assert!(
//             collection::tags(coll) == from_vec_string(&mut to_string_vector(&mut tags)),
//         0);

//         assert!(
//             std_collection::royalty(collection::metadata(coll)) == 5,
//         0);

//         assert!(
//             std_collection::data(collection::metadata(coll)) == string::utf8(b""),
//         0);

//         assert!(
//             std_collection::creators(collection::metadata(coll)) == vector::empty(),
//         0);

//         test_scenario::return_shared(&mut scenario, coll_wrapper);
//     }
// }