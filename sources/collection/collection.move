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
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use nft_protocol::tags::{Self, Tags};

    /// The phantom type T links the Collection with a smart contract which
    /// implements a standard interface for Collections.
    ///
    /// The meta data is a type exported by the same contract which is used to
    /// store additional information about the NFT.
    struct Collection<phantom T, Meta> has key, store {
        id: UID,
        name: String,
        // TODO: Should symbol be limited to x number of chars?
        symbol: String,
        // The current number of instantiated NFT objects
        current_supply: u64,
        // The maximum number of instantiated NFT objects
        total_supply: u64,
        // Initial mint price in Sui
        initial_price: u64,
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
        metadata: Meta,
    }

    struct InitCollection has drop {
        name: String,
        symbol: String,
        total_supply: u64,
        initial_price: u64,
        receiver: address,
        tags: vector<String>,
        is_mutable: bool, 
    }

    /// Initialises a `Collection` object and returns it
    public fun create<T: drop, Meta: store>(
        _witness: T,
        args: InitCollection,
        metadata: Meta,
        ctx: &mut TxContext,
    ): Collection<T, Meta> {
        let id = object::new(ctx);

        Collection {
            id,
            name: args.name,
            symbol: args.symbol,
            current_supply: 0,
            initial_price: args.initial_price,
            receiver: args.receiver,
            total_supply: args.total_supply,
            tags: tags::from_vec_string(&mut args.tags),
            is_mutable: args.is_mutable,
            metadata: metadata,
        }
    }

    public fun init_args(
        name: String,
        symbol: String,
        total_supply: u64,
        initial_price: u64,
        receiver: address,
        tags: vector<String>,
        is_mutable: bool,
    ): InitCollection {

        InitCollection {
            name,
            symbol,
            total_supply,
            initial_price,
            receiver,
            tags,
            is_mutable,
        }
    }

    /// Increments current supply of `Collection` object. This function should
    /// be called everytime an NFT is minted. It serves to keep track
    public fun increase_supply<T: drop, Meta: store>(
        collection: &mut Collection<T, Meta>,
    ) {
        // We can only add an nft to the collection supply if 
        // current supply not bigger than max supply
        assert!(collection.current_supply < collection.total_supply, 0);

        collection.current_supply = collection.current_supply + 1;
    }

    /// Decrements current supply
    public fun decrease_supply<T: drop, Meta: store>(
        collection: &mut Collection<T, Meta>,
    ) {
        // We can only remove an nft from the collection if current supply
        // is bigger than zero
        assert!(collection.current_supply > 0, 0);

        collection.current_supply = collection.current_supply - 1;
    }

    /// Burn the collection and return the Metadata object
    public fun burn<T: drop, Meta: store>(
        collection: Collection<T, Meta>,
        _: &mut TxContext
    ): Meta {
        assert!(collection.current_supply == 0, 0);

        let Collection {
            id,
            name: _,
            symbol: _,
            current_supply: _,
            total_supply: _,
            initial_price: _,
            receiver: _,
            tags: _,
            is_mutable: _,
            metadata,
        } = collection;

        object::delete(id);

        metadata
    }

    // === Mutability Functions ===

    /// Modify the Collections's `name`
    public fun rename<T, Meta>(
        collection: &mut Collection<T,Meta>,
        name: String,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.name = name;
    }

    /// Modify the Collections's `symbol`
    public fun change_symbol<T, Meta>(
        collection: &mut Collection<T,Meta>,
        symbol: String,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.symbol = symbol;
    }

    /// Modify the Collections's `total_supply`
    public fun change_total_supply<T, Meta>(
        collection: &mut Collection<T,Meta>,
        supply: u64,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        // New total supply cannot be smaller than current supply
        assert!(supply >= collection.current_supply, 0);

        collection.total_supply = supply;
    }

    /// Modify the Collections's `initial_price`
    public fun change_initial_price<T, Meta>(
        collection: &mut Collection<T,Meta>,
        price: u64,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.initial_price = price;
    }

    /// Modify the Collections's `receiver`
    public fun change_receiver<T, Meta>(
        collection: &mut Collection<T,Meta>,
        receiver: address,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.receiver = receiver;
    }

    /// Make Collections immutable
    /// WARNING: this is irreversible, use with care
    public fun freeze_collection<T, Meta>(
        collection: &mut Collection<T,Meta>,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.is_mutable = false;
    }

    /// Get the mutable reference to Collections's `metadata`
    public fun metadata_mut<T, Meta>(
        collection: &mut Collection<T, Meta>,
    ): &mut Meta {
        // Only return mutable reference if collection is mutable
        assert!(collection.is_mutable == true, 0);

        &mut collection.metadata
    }

    /// Add a tag to the Collections's `tags`
    /// Contrary to other fields, tags can be always added by
    /// the collection owner, even if the collection is marked
    /// as immutable.
    public fun push_tag<T, Meta>(
        collection: &mut Collection<T,Meta>,
        tag: String,
    ) {
        tags::push_tag(
            &mut collection.tags,
            tag,
        );
    }

    // === Getter Functions ===

    /// Get the Collections's `name`
    public fun name<T, Meta>(
        coll: &Collection<T,Meta>
    ): &String {
        &coll.name
    }

    /// Get the Collections's `symbol`
    public fun symbol<T, Meta>(
        coll: &Collection<T, Meta>
    ): &String {
        &coll.symbol
    }

    /// Get the Collections's `current_supply`
    public fun current_supply<T, Meta>(
        collection: &Collection<T, Meta>,
    ): u64 {
        collection.current_supply
    }

    /// Get the Collections's `total_supply`
    public fun total_supply<T, Meta>(
        collection: &Collection<T, Meta>,
    ): u64 {
        collection.total_supply
    }

    /// Get the Collections's `max_supply`
    public fun tags<T, Meta>(
        collection: &Collection<T, Meta>,
    ): Tags {
        collection.tags
    }

    /// Get the immutable reference to Collections's `metadata`
    public fun metadata<T, Meta>(
        collection: &Collection<T, Meta>,
    ): &Meta {
        &collection.metadata
    }

    /// Get the Collection's `initial_price`
    public fun initial_price<T, Meta>(
        collection: &Collection<T, Meta>,
    ): u64 {
        collection.initial_price
    }

    /// Get the Collection's `receiver`
    public fun receiver<T, Meta>(
        collection: &Collection<T, Meta>,
    ): address {
        collection.receiver
    }

    /// Get the Collection's `is_mutable`
    public fun is_mutable<T, Meta>(
        collection: &Collection<T, Meta>,
    ): bool {
        collection.is_mutable
    }

    /// Get the Collection's `ID`
    public fun id<T, Meta>(
        collection: &Collection<T, Meta>,
    ): ID {
        object::uid_to_inner(&collection.id)
    }

    /// Get the Collection's `ID` as reference
    public fun id_ref<T, Meta>(
        collection: &Collection<T, Meta>,
    ): &ID {
        object::uid_as_inner(&collection.id)
    }
}


#[test_only]
module nft_protocol::collection_tests {
    use std::string::{Self, String};
    use std::vector::{Self};
    use sui::test_scenario;
    use sui::transfer;
    use nft_protocol::collection::{Self, Collection};

    struct WitnessTest has drop {}
    struct MetadataTest has drop, store {}

    #[test]
    fun collection() {
        let addr1 = @0xA;

        // create the Collection
        let scenario = test_scenario::begin(&addr1);
        {
            let tags: vector<String> = vector::empty();

            vector::push_back(&mut tags, string::utf8(b"Art"));

            let args = collection::init_args(
                string::utf8(b"Yellow Submarines"),
                string::utf8(b"YLSBM"),
                10,
                100,
                addr1,
                tags,
                false,
            );
            
            let metadata = MetadataTest {};

            let coll = collection::create(
                WitnessTest {},
                args,
                metadata,
                test_scenario::ctx(&mut scenario),
            );

            assert!(
                *string::bytes(collection::name(&coll)) == b"Yellow Submarines",
            0);
            assert!(
                *string::bytes(collection::symbol(&coll)) == b"YLSBM", 0
            );
            assert!(collection::initial_price(&coll) == 100, 0);
            assert!(collection::current_supply(&coll) == 0, 0);
            assert!(collection::total_supply(&coll) == 10, 0);

            transfer::transfer(coll, addr1);
        };
        // Increase supply
        test_scenario::next_tx(&mut scenario, &addr1);
        {
            let coll = test_scenario::take_owned<Collection<WitnessTest, MetadataTest>>(&mut scenario);
            
            collection::increase_supply(&mut coll);
            assert!(collection::current_supply(&coll) == 1, 0);
            
            transfer::transfer(coll, addr1);
        };
        // Decrease supply
        test_scenario::next_tx(&mut scenario, &addr1);
        {
            let coll = test_scenario::take_owned<Collection<WitnessTest, MetadataTest>>(&mut scenario);
            
            collection::decrease_supply(&mut coll);
            assert!(collection::current_supply(&coll) == 0, 0);

            transfer::transfer(coll, addr1);
        };
        // burn it
        test_scenario::next_tx(&mut scenario, &addr1);
        {
            let coll = test_scenario::take_owned<Collection<WitnessTest, MetadataTest>>(&mut scenario);
            let _meta: MetadataTest = collection::burn(
                coll, test_scenario::ctx(&mut scenario)
            );
        }
    }
}