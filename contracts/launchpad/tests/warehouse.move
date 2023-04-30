#[test_only]
module ob_launchpad::test_warehouse {
    use std::vector;

    use sui::transfer;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::TxContext;
    use sui::test_scenario::{Self, ctx};

    use ob_launchpad::warehouse::{Self, Warehouse};

    const CREATOR: address = @0xA1C05;

    struct Foo has key, store {
        id: UID,
    }

    #[test]
    fun init_warehouse() {
        let scenario = test_scenario::begin(CREATOR);

        warehouse::init_warehouse<Foo>(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, CREATOR);

        assert!(test_scenario::has_most_recent_for_address<Warehouse<Foo>>(CREATOR), 0);

        test_scenario::end(scenario);
    }

    #[test]
    fun deposit_warehouse() {
        let scenario = test_scenario::begin(CREATOR);

        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));
        assert!(warehouse::has_chunk(&warehouse, 0), 0);

        // Deposit up to `Warehouse` single-vector limit
        deposit_many(7998, &mut warehouse, ctx(&mut scenario));

        assert!(!warehouse::has_chunk(&warehouse, 1), 0);

        // Fill up as many as test limitations will allow us
        deposit_many(7999, &mut warehouse, ctx(&mut scenario));

        assert!(vector::length(warehouse::borrow_chunk(&warehouse, 1)) == 7998, 0);
        assert!(vector::length(warehouse::borrow_chunk(&warehouse, 2)) == 1, 0);

        // Redeem all NFTs
        redeem_many(7998 + 7999, &mut warehouse);

        warehouse::destroy(warehouse);
        test_scenario::end(scenario);
    }

    #[test]
    fun redeem_at_index_within_last() {
        let scenario = test_scenario::begin(CREATOR);

        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));

        let _nft_0 = deposit(&mut warehouse, ctx(&mut scenario));
        let nft_1 = deposit(&mut warehouse, ctx(&mut scenario));
        let _nft_2 = deposit(&mut warehouse, ctx(&mut scenario));

        let nft = warehouse::redeem_nft_at_index(&mut warehouse, 1);
        assert!(object::id(&nft) == nft_1, 0);

        transfer::public_transfer(nft, CREATOR);
        transfer::public_transfer(warehouse, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun redeem_at_index_within_last_chunk() {
        let scenario = test_scenario::begin(CREATOR);

        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));

        // Deposit up to `Warehouse` single-vector limit
        deposit_many(7998, &mut warehouse, ctx(&mut scenario));

        let _nft_0 = deposit(&mut warehouse, ctx(&mut scenario));
        let nft_1 = deposit(&mut warehouse, ctx(&mut scenario));
        let _nft_2 = deposit(&mut warehouse, ctx(&mut scenario));

        let nft = warehouse::redeem_nft_at_index(&mut warehouse, 7998 + 1);
        assert!(object::id(&nft) == nft_1, 0);

        transfer::public_transfer(nft, CREATOR);
        transfer::public_transfer(warehouse, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun redeem_at_index_within_last_only() {
        let scenario = test_scenario::begin(CREATOR);

        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));

        let nft_0 = deposit(&mut warehouse, ctx(&mut scenario));

        let nft = warehouse::redeem_nft_at_index(&mut warehouse, 0);
        assert!(object::id(&nft) == nft_0, 0);

        transfer::public_transfer(nft, CREATOR);
        transfer::public_transfer(warehouse, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun redeem_at_index_within_last_only_chunk() {
        let scenario = test_scenario::begin(CREATOR);

        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));

        // Deposit up to `Warehouse` single-vector limit
        deposit_many(7998, &mut warehouse, ctx(&mut scenario));
        let nft_0 = deposit(&mut warehouse, ctx(&mut scenario));

        let nft = warehouse::redeem_nft_at_index(&mut warehouse, 7998 + 0);
        assert!(object::id(&nft) == nft_0, 0);

        assert!(!warehouse::has_chunk(&warehouse, 1), 0);

        transfer::public_transfer(nft, CREATOR);
        transfer::public_transfer(warehouse, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun redeem_at_index() {
        let scenario = test_scenario::begin(CREATOR);

        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));

        let nft_0 = deposit(&mut warehouse, ctx(&mut scenario));

        // Deposit up to `Warehouse` single-vector limit and some extra
        deposit_many(7998 - 1 + 3, &mut warehouse, ctx(&mut scenario));

        assert!(vector::length(warehouse::borrow_chunk(&warehouse, 0)) == 7998, 0);
        assert!(vector::length(warehouse::borrow_chunk(&warehouse, 1)) == 3, 0);

        let nft = warehouse::redeem_nft_at_index(&mut warehouse, 0);
        assert!(object::id(&nft) == nft_0, 0);

        assert!(vector::length(warehouse::borrow_chunk(&warehouse, 0)) == 7998, 0);
        assert!(vector::length(warehouse::borrow_chunk(&warehouse, 1)) == 2, 0);

        transfer::public_transfer(nft, CREATOR);
        transfer::public_transfer(warehouse, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun redeem_at_index_last() {
        let scenario = test_scenario::begin(CREATOR);

        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));

        let nft_0 = deposit(&mut warehouse, ctx(&mut scenario));

        // Deposit up to `Warehouse` single-vector limit and some extra
        deposit_many(7998, &mut warehouse, ctx(&mut scenario));

        let nft = warehouse::redeem_nft_at_index(&mut warehouse, 0);
        assert!(object::id(&nft) == nft_0, 0);

        assert!(!warehouse::has_chunk(&warehouse, 1), 0);

        transfer::public_transfer(nft, CREATOR);
        transfer::public_transfer(warehouse, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun redeem_pseudorandom() {
        let scenario = test_scenario::begin(CREATOR);

        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));
        assert!(warehouse::has_chunk(&warehouse, 0), 0);

        // Deposit up to `Warehouse` single-vector limit
        deposit_many(2 * 7998, &mut warehouse, ctx(&mut scenario));

        // Redeem all NFTs
        redeem_pseudorandom_many(2 * 7998, &mut warehouse, ctx(&mut scenario));

        warehouse::destroy(warehouse);
        test_scenario::end(scenario);
    }

    #[test]
    fun redeem_with_id() {
        let scenario = test_scenario::begin(CREATOR);

        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));

        let _nft_0 = deposit(&mut warehouse, ctx(&mut scenario));
        let nft_1 = deposit(&mut warehouse, ctx(&mut scenario));
        let _nft_2 = deposit(&mut warehouse, ctx(&mut scenario));

        let nft = warehouse::redeem_nft_with_id(&mut warehouse, nft_1);
        assert!(object::id(&nft) == nft_1, 0);

        transfer::public_transfer(nft, CREATOR);
        transfer::public_transfer(warehouse, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    fun redeem_with_id_chunk() {
        let scenario = test_scenario::begin(CREATOR);

        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));

        // Deposit up to `Warehouse` single-vector limit and some extra
        deposit_many(7998, &mut warehouse, ctx(&mut scenario));

        let _nft_0 = deposit(&mut warehouse, ctx(&mut scenario));
        let nft_1 = deposit(&mut warehouse, ctx(&mut scenario));
        let _nft_2 = deposit(&mut warehouse, ctx(&mut scenario));

        let nft = warehouse::redeem_nft_with_id(&mut warehouse, nft_1);
        assert!(object::id(&nft) == nft_1, 0);

        transfer::public_transfer(nft, CREATOR);
        transfer::public_transfer(warehouse, CREATOR);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_launchpad::warehouse::EInvalidNftId)]
    fun try_redeem_with_id_chunk() {
        let scenario = test_scenario::begin(CREATOR);

        let warehouse = warehouse::new<Foo>(ctx(&mut scenario));

        // Deposit up to `Warehouse` single-vector limit and some extra
        deposit_many(2 * 7998, &mut warehouse, ctx(&mut scenario));

        let fake_nft = object::new(ctx(&mut scenario));
        let fake_nft_id = object::uid_to_inner(&fake_nft);
        object::delete(fake_nft);

        let nft = warehouse::redeem_nft_with_id(&mut warehouse, fake_nft_id);

        transfer::public_transfer(nft, CREATOR);
        transfer::public_transfer(warehouse, CREATOR);
        test_scenario::end(scenario);
    }

    // === Utils ===

    fun deposit(warehouse: &mut Warehouse<Foo>, ctx: &mut TxContext): ID {
        let nft = Foo { id: object::new(ctx) };
        let nft_id = object::id(&nft);
        warehouse::deposit_nft(warehouse, nft);
        nft_id
    }

    fun deposit_many(
        amount: u64,
        warehouse: &mut Warehouse<Foo>,
        ctx: &mut TxContext,
    ) {
        let i = 0;
        while (i < amount) {
            deposit(warehouse, ctx);
            i = i + 1;
        };
    }

    fun redeem_many(amount: u64, warehouse: &mut Warehouse<Foo>) {
        let i = 0;
        while (i < amount) {
            let nft = warehouse::redeem_nft(warehouse);
            let Foo { id } = nft;
            object::delete(id);

            i = i + 1;
        };
    }

    fun redeem_pseudorandom_many(
        amount: u64,
        warehouse: &mut Warehouse<Foo>,
        ctx: &mut TxContext,
    ) {
        let i = 0;
        while (i < amount) {
            let nft = warehouse::redeem_pseudorandom_nft(warehouse, ctx);
            let Foo { id } = nft;
            object::delete(id);

            i = i + 1;
        };
    }
}