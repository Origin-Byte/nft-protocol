#[test_only]
module nft_protocol::example_free_for_all {
    //! A whitelist which permits any collection to add itself and any authority
    //! to use it to transfer.
    //!
    //! Basically any collection which adds itself to this whitelist is saying:
    //! we're ok with anyone transferring NFTs.

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::transfer_whitelist::{Self, Whitelist};
    use sui::transfer::share_object;
    use sui::tx_context::TxContext;

    struct Witness has drop {}

    fun init(ctx: &mut TxContext) {
        init_(ctx)
    }
    public fun init_(ctx: &mut TxContext) {
        share_object(transfer_whitelist::create(Witness {}, ctx));
    }

    /// Only the creator is allowed to insert their collection.
    ///
    /// However, any creator can insert their collection into simple whitelist.
    public entry fun insert_collection<T>(
        collection: &Collection<T>,
        list: &mut Whitelist,
        ctx: &mut TxContext,
    ) {
        transfer_whitelist::insert_collection(
            Witness {},
            collection,
            list,
            ctx,
        );
    }

    // --- Tests ---

    use sui::test_scenario::{Self, Scenario, ctx};

    const USER: address = @0xA1C04;

    #[test]
    fun it_inserts_collection() {
        let scenario = test_scenario::begin(USER);

        init_(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let wl: Whitelist = test_scenario::take_shared(&scenario);

        let col = dummy_collection(&mut scenario);

        insert_collection(&col, &mut wl, ctx(&mut scenario));

        test_scenario::return_shared(wl);
        test_scenario::return_shared(col);
        test_scenario::end(scenario);
    }

    struct Foo has drop {}
    fun dummy_collection(scenario: &mut Scenario): Collection<Foo> {
        collection::dummy_collection(USER, scenario)
    }
}
