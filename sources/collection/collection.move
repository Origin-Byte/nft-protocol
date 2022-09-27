/// Module of a generic `Collection` type.
/// 
/// It acts as a generic interface for NFT Collections and it allows for
/// the creation of arbitrary domain specific implementations.
/// 
/// TODO: We need to consider that there are two types of supply, 
/// vertical (Collection Width) and horizontal supply (Collection Depth).
/// Collection Width stands for how many different NFTs are there in a 
/// collection whilst Collection Depth stands for how many are there of each NFT
/// 
/// TODO: add a `pop_tag` function
/// TODO: function to make collection `shared`
module nft_protocol::collection {
    use std::string::String;
    use std::vector;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use nft_protocol::tags::{Self, Tags};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::collection_cap::{Self, Capped, Uncapped};
    use std::option::{Self, Option};

    /// The phantom type T links the Collection with a smart contract which
    /// implements a standard interface for Collections.
    ///
    /// The meta data is a type exported by the same contract which is used to
    /// store additional information about the NFT.
    struct Collection<Meta: store, Cap: store> has key, store {
        id: UID,
        name: String,
        description: String,
        // TODO: Should symbol be limited to x number of chars?
        symbol: String,
        // Address that receives the mint price in Sui
        receiver: address,
        // Nft Collection Tags is an enumeration of tags, represented
        // as strings. An Nft Tag is a string that categorises the domain 
        // in which the Nft operates (i.e. Art, Profile Picture, Gaming, etc.)
        // This allows wallets and marketplaces to organise Nfts by its
        // domain specificity.
        tags: Tags,
        // Determines if the collection and its associated NFTs are 
        // mutable. Once turned `false` it cannot be reversed. Collection
        // owners however will still be able to push and pop tags to the
        // `tags` field.
        is_mutable: bool,
        royalty_fee_bps: u64,
        creators: vector<Creator>,
        // Supply object that holds information on supply cap and 
        // current supply
        collection_cap: Cap,
        metadata: Meta,
    }

    struct Creator has store, copy, drop {
        id: address,
        /// The creator needs to sign a transaction in order to be verified.
        /// Otherwise anyone could just spoof the creator's identity
        verified: bool,
        share_of_royalty: u8,
    }

    struct InitCollection has drop {
        name: String,
        description: String,
        symbol: String,
        receiver: address,
        tags: vector<String>,
        is_mutable: bool, 
        royalty_fee_bps: u64,
    }

    /// Initialises a `Collection` object and returns it
    public fun create_capped<Meta: store>(
        args: InitCollection,
        max_supply: u64,
        metadata: Meta,
        ctx: &mut TxContext,
    ): Collection<Meta, Capped> {
        let id = object::new(ctx);

        Collection {
            id,
            name: args.name,
            description: args.description,
            symbol: args.symbol,
            receiver: args.receiver,
            tags: tags::from_vec_string(&mut args.tags),
            is_mutable: args.is_mutable,
            royalty_fee_bps: args.royalty_fee_bps,
            creators: vector::empty(),
            collection_cap: collection_cap::create_capped(max_supply),
            metadata: metadata,
        }
    }

    /// Initialises a `Collection` object and returns it
    public fun create_uncapped<Meta: store>(
        args: InitCollection,
        metadata: Meta,
        ctx: &mut TxContext,
    ): Collection<Meta, Uncapped> {
        let id = object::new(ctx);

        Collection {
            id,
            name: args.name,
            description: args.description,
            symbol: args.symbol,
            receiver: args.receiver,
            tags: tags::from_vec_string(&mut args.tags),
            is_mutable: args.is_mutable,
            royalty_fee_bps: args.royalty_fee_bps,
            creators: vector::empty(),
            collection_cap: collection_cap::create_uncapped(),
            metadata: metadata,
        }
    }

    public fun init_args(
        name: String,
        description: String,
        symbol: String,
        receiver: address,
        tags: vector<String>,
        is_mutable: bool,
        royalty_fee_bps: u64,
    ): InitCollection {

        InitCollection {
            name,
            description,
            symbol,
            receiver,
            tags,
            is_mutable,
            royalty_fee_bps,
        }
    }

    /// Burn the collection and return the Metadata object
    public fun burn_capped<Meta: store>(
        collection: Collection<Meta, Capped>,
    ): Meta {
        assert!(supply::current(
            collection_cap::supply(&collection.collection_cap)
        ) == 0, 0);

        let Collection {
            id,
            name: _,
            description: _,
            symbol: _,
            receiver: _,
            tags: _,
            is_mutable: _,
            royalty_fee_bps: _,
            creators: _,
            collection_cap,
            metadata,
        } = collection;

        collection_cap::destroy_capped(collection_cap);

        object::delete(id);

        metadata
    }

    // === Mutability Functions ===

    /// Modify the Collections's `name`
    public fun rename<Meta: store, Cap: store>(
        collection: &mut Collection<Meta, Cap>,
        name: String,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.name = name;
    }

    /// Modify the Collections's `symbol`
    public fun change_symbol<Meta: store, Cap: store>(
        collection: &mut Collection<Meta, Cap>,
        symbol: String,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.symbol = symbol;
    }

    /// Modify the Collections's `receiver`
    public fun change_receiver<Meta: store, Cap: store>(
        collection: &mut Collection<Meta, Cap>,
        receiver: address,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.receiver = receiver;
    }

    /// Make Collections immutable
    /// WARNING: this is irreversible, use with care
    public fun freeze_collection<Meta: store, Cap: store>(
        collection: &mut Collection<Meta, Cap>,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.is_mutable = false;
    }

    /// Get the mutable reference to Collections's `metadata`
    public fun metadata_mut<Meta: store, Cap: store>(
        collection: &mut Collection<Meta, Cap>,
    ): &mut Meta {
        // Only return mutable reference if collection is mutable
        assert!(collection.is_mutable == true, 0);

        &mut collection.metadata
    }

    /// Add a tag to the Collections's `tags`
    /// Contrary to other fields, tags can be always added by
    /// the collection owner, even if the collection is marked
    /// as immutable.
    public fun push_tag<Meta: store, Cap: store>(
        collection: &mut Collection<Meta, Cap>,
        tag: String,
    ) {
        tags::push_tag(
            &mut collection.tags,
            tag,
        );
    }

    public fun cap_supply<Meta: store>(
        collection: &mut Collection<Meta, Capped>,
        value: u64
    ) {
        supply::cap_supply(
            collection_cap::supply_mut(&mut collection.collection_cap),
            value
            )
    }

    public fun increase_supply<Meta: store>(
        collection: &mut Collection<Meta, Capped>,
        value: u64
    ) {
        supply::increase_supply(
            collection_cap::supply_mut(&mut collection.collection_cap),
            value
        )
    }

    public fun decrease_supply<Meta: store>(
        collection: &mut Collection<Meta, Capped>,
        value: u64
    ) {
        supply::decrease_supply(
            collection_cap::supply_mut(&mut collection.collection_cap),
            value
        )
    }

    public fun increase_supply_cap<Meta: store>(
        collection: &mut Collection<Meta, Capped>,
        value: u64
    ) {
        supply::increase_cap(
            collection_cap::supply_mut(&mut collection.collection_cap),
            value
        )
    }

    public fun decrease_supply_cap<Meta: store>(
        collection: &mut Collection<Meta, Capped>,
        value: u64
    ) {
        supply::decrease_cap(
            collection_cap::supply_mut(&mut collection.collection_cap),
            value
        )
    }

    // === Getter Functions ===

    /// Get the Collections's `name`
    public fun name<Meta: store, Cap: store>(
        coll: &Collection<Meta, Cap>
    ): &String {
        &coll.name
    }

    /// Get the Collections's `symbol`
    public fun symbol<Meta: store, Cap: store>(
        coll: &Collection<Meta, Cap>
    ): &String {
        &coll.symbol
    }

    public fun supply<Meta: store>(collection: &Collection<Meta, Capped>): &Supply {
        collection_cap::supply(&collection.collection_cap)
    }

    public fun supply_cap<Meta: store>(collection: &Collection<Meta, Capped>): Option<u64> {
        supply::cap(
            collection_cap::supply(&collection.collection_cap)
        )
    }

    public fun current_supply<Meta: store>(collection: &Collection<Meta, Capped>): u64 {
        supply::current(
            collection_cap::supply(&collection.collection_cap)
        )
    }

    /// Get the Collections's `max_supply`
    public fun tags<Meta: store, Cap: store>(
        collection: &Collection<Meta, Cap>,
    ): Tags {
        collection.tags
    }

    /// Get the immutable reference to Collections's `metadata`
    public fun metadata<Meta: store, Cap: store>(
        collection: &Collection<Meta, Cap>,
    ): &Meta {
        &collection.metadata
    }

    /// Get the Collection's `receiver`
    public fun receiver<Meta: store, Cap: store>(
        collection: &Collection<Meta, Cap>,
    ): address {
        collection.receiver
    }

    /// Get the Collection's `is_mutable`
    public fun is_mutable<Meta: store, Cap: store>(
        collection: &Collection<Meta, Cap>,
    ): bool {
        collection.is_mutable
    }

    /// Get the Collection's `ID`
    public fun id<Meta: store, Cap: store>(
        collection: &Collection<Meta, Cap>,
    ): ID {
        object::uid_to_inner(&collection.id)
    }

    /// Get the Collection's `ID` as reference
    public fun id_ref<Meta: store, Cap: store>(
        collection: &Collection<Meta, Cap>,
    ): &ID {
        object::uid_as_inner(&collection.id)
    }
}


// #[test_only]
// module nft_protocol::collection_tests {
//     use std::string::{Self, String};
//     use std::vector::{Self};
//     use sui::test_scenario;
//     use sui::transfer;
//     use nft_protocol::collection::{Self, Collection};

//     struct WitnessTest has drop {}
//     struct MetadataTest has drop, store {}

//     #[test]
//     fun collection() {
//         let addr1 = @0xA;

//         // create the Collection
//         let scenario = test_scenario::begin(&addr1);
//         {
//             let tags: vector<String> = vector::empty();

//             vector::push_back(&mut tags, string::utf8(b"Art"));

//             let args = collection::init_args(
//                 string::utf8(b"Yellow Submarines"),
//                 string::utf8(b"YLSBM"),
//                 10,
//                 100,
//                 addr1,
//                 tags,
//                 false,
//             );
            
//             let metadata = MetadataTest {};

//             let coll = collection::create(
//                 WitnessTest {},
//                 args,
//                 metadata,
//                 test_scenario::ctx(&mut scenario),
//             );

//             assert!(
//                 *string::bytes(collection::name(&coll)) == b"Yellow Submarines",
//             0);
//             assert!(
//                 *string::bytes(collection::symbol(&coll)) == b"YLSBM", 0
//             );
//             assert!(collection::initial_price(&coll) == 100, 0);
//             assert!(collection::current_supply(&coll) == 0, 0);
//             assert!(collection::total_supply(&coll) == 10, 0);

//             transfer::transfer(coll, addr1);
//         };
//         // Increase supply
//         test_scenario::next_tx(&mut scenario, &addr1);
//         {
//             let coll = test_scenario::take_owned<Collection<WitnessTest, MetadataTest>>(&mut scenario);
            
//             collection::increase_supply(&mut coll);
//             assert!(collection::current_supply(&coll) == 1, 0);
            
//             transfer::transfer(coll, addr1);
//         };
//         // Decrease supply
//         test_scenario::next_tx(&mut scenario, &addr1);
//         {
//             let coll = test_scenario::take_owned<Collection<WitnessTest, MetadataTest>>(&mut scenario);
            
//             collection::decrease_supply(&mut coll);
//             assert!(collection::current_supply(&coll) == 0, 0);

//             transfer::transfer(coll, addr1);
//         };
//         // burn it
//         test_scenario::next_tx(&mut scenario, &addr1);
//         {
//             let coll = test_scenario::take_owned<Collection<WitnessTest, MetadataTest>>(&mut scenario);
//             let _meta: MetadataTest = collection::burn(
//                 coll, test_scenario::ctx(&mut scenario)
//             );
//         }
//     }
// }