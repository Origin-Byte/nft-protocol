#[test_only]
module nft_protocol::example_free_for_all {
    //! A whitelist which permits any collection to add itself and any authority
    //! to use it to transfer.
    //!
    //! Basically any collection which adds itself to this whitelist is saying:
    //! we're ok with anyone transferring NFTs.

    use nft_protocol::transfer_whitelist::{Self, Whitelist};
    use sui::transfer::{transfer, share_object};
    use sui::tx_context::TxContext;

    struct Witness has drop {}

    fun init(ctx: &mut TxContext) {
        init_(ctx)
    }
    fun init_(ctx: &mut TxContext) {
        share_object(transfer_whitelist::create(Witness {}, ctx));
    }

    /// Only the creator is allowed to insert their collection.
    ///
    /// However, any creator can insert their collection into simple whitelist.
    public entry fun insert_collection<T>(
        col_cap: &transfer_whitelist::CollectionControlCap<T>,
        list: &mut Whitelist,
    ) {
        transfer_whitelist::insert_collection(
            Witness {},
            col_cap,
            list,
        );
    }

    // --- Tests ---

    use sui::test_scenario::{Self, ctx};

    const USER: address = @0xA1C04;

    struct Foo has drop {}

    #[test]
    fun it_inserts_collection() {
        let scenario = test_scenario::begin(USER);

        init_(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, USER);

        let wl: Whitelist = test_scenario::take_shared(&scenario);

        let col_cap = transfer_whitelist::create_collection_cap<Foo, Witness>(
            &Witness {}, ctx(&mut scenario),
        );

        insert_collection(&col_cap, &mut wl);

        transfer(col_cap, USER);
        test_scenario::return_shared(wl);
        test_scenario::end(scenario);
    }
}
