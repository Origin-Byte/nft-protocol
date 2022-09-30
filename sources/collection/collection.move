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
/// TODO: consider adding function `destroy_uncapped`?
/// TODO: function to make collection `shared`??????
/// TODO: Verify creator in function to add creator, and new function solely to verify
/// TODO: Is there any preference on the order of fields?
/// TODO: Does it make sense to have store in Collection?
module nft_protocol::collection {
    use std::vector;
    use std::string::String;
    use std::option::{Option};

    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};

    use nft_protocol::tags::{Self, Tags};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::cap::{Self, Limited, Unlimited};

    /// The phantom type T links the Collection with a smart contract which
    /// implements a standard interface for Collections.
    ///
    /// The meta data is a type exported by the same contract which is used to
    /// store additional information about the NFT.
    /// TODO: Mention that stands for `M`eta and `C`ap
    struct Collection<M: store, C: store> has key, store {
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
        cap: C,
        metadata: M,
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

    struct MintEvent has copy, drop {
        collection_id: ID,
    }

    struct BurnEvent has copy, drop {
        collection_id: ID,
    }

    /// Initialises a `Collection` object and returns it
    public fun mint_capped<M: store>(
        args: InitCollection,
        max_supply: u64,
        metadata: M,
        ctx: &mut TxContext,
    ): Collection<M, Limited> {
        let id = object::new(ctx);

        event::emit(
            MintEvent {
                collection_id: object::uid_to_inner(&id),
            }
        );

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
            cap: cap::create_limited(max_supply, false),
            metadata: metadata,
        }
    }

    /// Initialises a `Collection` object and returns it
    public fun mint_uncapped<M: store>(
        args: InitCollection,
        metadata: M,
        ctx: &mut TxContext,
    ): Collection<M, Unlimited> {
        let id = object::new(ctx);

        event::emit(
            MintEvent {
                collection_id: object::uid_to_inner(&id),
            }
        );

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
            cap: cap::create_unlimited(),
            metadata: metadata,
        }
    }

    /// Burn the collection and return the Metadata object
    public fun burn_capped<M: store>(
        collection: Collection<M, Limited>,
    ): M {
        assert!(supply::current(
            cap::supply(&collection.cap)
        ) == 0, 0);

        event::emit(
            BurnEvent {
                collection_id: id(&collection),
            }
        );

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
            cap,
            metadata,
        } = collection;

        cap::destroy_capped(cap);

        object::delete(id);

        metadata
    }

    /// Make Collections immutable
    /// WARNING: this is irreversible, use with care
    public fun freeze_collection<M: store, C: store>(
        collection: &mut Collection<M, C>,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.is_mutable = false;
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

    // === Modifier Functions ===

    /// Modify the Collections's `name`
    public fun rename<M: store, C: store>(
        collection: &mut Collection<M, C>,
        name: String,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.name = name;
    }

    /// Modify the Collections's `description`
    public fun change_description<M: store, C: store>(
        collection: &mut Collection<M, C>,
        description: String,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.description = description;
    }

    /// Modify the Collections's `symbol`
    public fun change_symbol<M: store, C: store>(
        collection: &mut Collection<M, C>,
        symbol: String,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.symbol = symbol;
    }

    /// Modify the Collections's `receiver`
    public fun change_receiver<M: store, C: store>(
        collection: &mut Collection<M, C>,
        receiver: address,
    ) {
        // Only modify if collection is mutable
        assert!(collection.is_mutable == true, 0);

        collection.receiver = receiver;
    }

    /// Add a tag to the Collections's `tags`
    /// Contrary to other fields, tags can be always added by
    /// the collection owner, even if the collection is marked
    /// as immutable.
    public fun push_tag<M: store, C: store>(
        collection: &mut Collection<M, C>,
        tag: String,
    ) {
        tags::push_tag(
            &mut collection.tags,
            tag,
        );
    }

    // TODO: Pop tag function
    // public fun pop_tag<M: store, C: store>(
    //     collection: &mut Collection<M, C>,
    //     tag: String,
    // ) {}

    /// Change field `royalty_fee_bps` in `Collection`
    public entry fun change_royalty<M: store, C: store>(
        collection: &mut Collection<M, C>,
        royalty_fee_bps: u64,
    ) {
        collection.royalty_fee_bps = royalty_fee_bps;
    }

    /// Add a `Creator` to `Collection`
    public entry fun add_creator<M: store, C: store>(
        collection: &mut Collection<M, C>,
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
            !contains_address(&collection.creators, creator_address)
        ) {
            vector::push_back(&mut collection.creators, creator);
        }
    }

    /// Remove a `Creator` from `Collection`
    public entry fun remove_creator<M: store, C: store>(
        collection: &mut Collection<M, C>,
        creator_address: address,
    ) {
        if (!vector::is_empty(&collection.creators)) {
            remove_address(
                &mut collection.creators,
                creator_address,
            )
        }
    }

    // === Supply Functions ===

    // Explain that this function is for Limited collections
    // Limited collections can still have no supply, there is an opt-in 
    public fun cap_supply<M: store>(
        collection: &mut Collection<M, Limited>,
        value: u64
    ) {
        supply::cap_supply(
            cap::supply_mut(&mut collection.cap),
            value
        )
    }

    public fun increase_supply<M: store>(
        collection: &mut Collection<M, Limited>,
        value: u64
    ) {
        supply::increase_supply(
            cap::supply_mut(&mut collection.cap),
            value
        )
    }

    public fun decrease_supply<M: store>(
        collection: &mut Collection<M, Limited>,
        value: u64
    ) {
        supply::decrease_supply(
            cap::supply_mut(&mut collection.cap),
            value
        )
    }

    public fun increase_supply_cap<M: store>(
        collection: &mut Collection<M, Limited>,
        value: u64
    ) {
        supply::increase_cap(
            cap::supply_mut(&mut collection.cap),
            value
        )
    }

    public fun decrease_supply_cap<M: store>(
        collection: &mut Collection<M, Limited>,
        value: u64
    ) {
        supply::decrease_cap(
            cap::supply_mut(&mut collection.cap),
            value
        )
    }

    public fun supply<M: store>(collection: &Collection<M, Limited>): &Supply {
        cap::supply(&collection.cap)
    }

    public fun supply_cap<M: store>(collection: &Collection<M, Limited>): Option<u64> {
        supply::cap(
            cap::supply(&collection.cap)
        )
    }

    public fun current_supply<M: store>(collection: &Collection<M, Limited>): u64 {
        supply::current(
            cap::supply(&collection.cap)
        )
    }

    // === Getter Functions ===

    /// Get the Collections's `id`
    public fun id<M: store, C: store>(
        collection: &Collection<M, C>
    ): ID {
        object::uid_to_inner(&collection.id)
    }

    /// Get the Collections's `id` as reference
    public fun id_ref<M: store, C: store>(
        collection: &Collection<M, C>
    ): &ID {
        object::uid_as_inner(&collection.id)
    }

    /// Get the Collections's `name`
    public fun name<M: store, C: store>(
        collection: &Collection<M, C>
    ): &String {
        &collection.name
    }

    /// Get the Collections's `description`
    public fun description<M: store, C: store>(
        collection: &Collection<M, C>
    ): &String {
        &collection.description
    }

    /// Get the Collections's `symbol`
    public fun symbol<M: store, C: store>(
        collection: &Collection<M, C>
    ): &String {
        &collection.symbol
    }

    /// Get the Collections's `receiver`
    public fun receiver<M: store, C: store>(
        collection: &Collection<M, C>
    ): address {
        collection.receiver
    }

    /// Get the Collections's `tags`
    public fun tags<M: store, C: store>(
        collection: &Collection<M, C>,
    ): Tags {
        collection.tags
    }

    /// Get the Collection's `is_mutable`
    public fun is_mutable<M: store, C: store>(
        collection: &Collection<M, C>,
    ): bool {
        collection.is_mutable
    }

    /// Get the Collection's `royalty_fee_bps`
    public fun royalty<M: store, C: store>(
        collection: &Collection<M, C>,
    ): u64 {
        collection.royalty_fee_bps
    }

    /// Get the Collection's `creators`
    public fun creators<M: store, C: store>(
        collection: &Collection<M, C>,
    ): vector<Creator> {
        collection.creators
    }

    /// Get an immutable reference to Collections's `cap`
    public fun cap<M: store, C: store>(
        collection: &Collection<M, C>,
    ): &C {
        &collection.cap
    }

    /// Get a mutable reference to Collections's `cap`
    public fun cap_mut<M: store, C: store>(
        collection: &mut Collection<M, C>,
    ): &mut C {
        &mut collection.cap
    }

    /// Get an immutable reference to Collections's `Metadata`
    public fun Mdata<M: store, C: store>(
        collection: &Collection<M, C>,
    ): &M {
        &collection.metadata
    }

    /// Get a mutable reference to Collections's `metadata`
    public fun metadata_mut<M: store, C: store>(
        collection: &mut Collection<M, C>,
    ): &mut M {
        // Only return mutable reference if collection is mutable
        assert!(collection.is_mutable == true, 0);

        &mut collection.metadata
    }

    // === Private Functions ===

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