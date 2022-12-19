#[test_only]
module nft_protocol::test_bidding_safe_to_safe_trade {
    //! This test focuses on integration between bidding contract, Safe,
    //! a whitelist and royalty collection.
    //!
    //! We simulate a trade between two Safes, end to end, including royalty
    //! collection.

    use nft_protocol::nft;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::bidding;
    use nft_protocol::safe::{Self, Safe};
    use nft_protocol::transfer_whitelist::{Self, Whitelist};
    use sui::sui::SUI;
    use sui::coin;
    use std::vector;
    use sui::object::{Self, ID};
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::transfer::{transfer, share_object};

    const BUYER: address = @0xA1C06;
    const CREATOR: address = @0xA1C05;
    const SELLER: address = @0xA1C04;

    const OFFER_SUI: u64 = 100;

    struct Foo has drop {} // collection
    struct Witness has drop {} // collection witness, must be named witness
    struct WhitelistWitness has drop {}

    #[test]
    fun it_works() {
        let scenario = test_scenario::begin(CREATOR);

        create_collection_and_whitelist(&mut scenario);

        let transfer_cap = create_seller_safe_and_nft(&mut scenario);

        bid_for_nft(&mut scenario, safe::transfer_cap_nft(&transfer_cap));

        sell_nft(&mut scenario, transfer_cap);

        // TODO: royalties

        test_scenario::end(scenario);
    }

    fun create_collection_and_whitelist(scenario: &mut Scenario) {
        let (cap, col) =
            collection::dummy_collection<Foo>(&Foo {}, CREATOR, scenario);
        share_object(col);
        test_scenario::next_tx(scenario, CREATOR);

        let col: Collection<Foo> = test_scenario::take_shared(scenario);
        nft_protocol::example_free_for_all::init_(ctx(scenario));
        test_scenario::next_tx(scenario, CREATOR);

        let col_control_cap = transfer_whitelist::create_collection_cap<Foo, Witness>(
            &Witness {}, ctx(scenario),
        );

        let wl: Whitelist = test_scenario::take_shared(scenario);
        nft_protocol::example_free_for_all::insert_collection(
            &col_control_cap,
            &mut wl,
        );

        transfer(cap, CREATOR);
        transfer(col_control_cap, CREATOR);
        test_scenario::return_shared(col);
        test_scenario::return_shared(wl);
    }

    fun create_seller_safe_and_nft(
        scenario: &mut Scenario,
    ): safe::TransferCap {
        let seller_owner_cap = safe::create_safe(ctx(scenario));
        test_scenario::next_tx(scenario, SELLER);

        let seller_safe: Safe = test_scenario::take_shared_by_id(
            scenario,
            safe::owner_cap_safe(&seller_owner_cap),
        );

        let nft = nft::new<Foo>(SELLER, ctx(scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft<Foo>(
            nft,
            &mut seller_safe,
            ctx(scenario),
        );

        let transfer_cap = safe::create_transfer_cap(
            nft_id,
            &seller_owner_cap,
            &mut seller_safe,
            ctx(scenario),
        );

        test_scenario::return_shared(seller_safe);
        transfer(seller_owner_cap, SELLER);

        test_scenario::next_tx(scenario, SELLER);

        transfer_cap
    }

    fun bid_for_nft(scenario: &mut Scenario, nft_id: ID) {
        let buyer_owner_cap = safe::create_safe(ctx(scenario));

        test_scenario::next_tx(scenario, BUYER);

        let wallet = coin::mint_for_testing(OFFER_SUI, ctx(scenario));

        bidding::create_bid<SUI>(
            nft_id,
            safe::owner_cap_safe(&buyer_owner_cap),
            OFFER_SUI,
            &mut wallet,
            ctx(scenario),
        );

        coin::destroy_zero(wallet);
        transfer(buyer_owner_cap, BUYER);
    }

    fun sell_nft(scenario: &mut Scenario, transfer_cap: safe::TransferCap) {
        let nft_id = safe::transfer_cap_nft(&transfer_cap);

        test_scenario::next_tx(scenario, SELLER);

        let bid: bidding::Bid<SUI> = test_scenario::take_shared(scenario);

        let seller_safe_id = user_safe_id(scenario, SELLER);
        let seller_safe: Safe = test_scenario::take_shared_by_id(
            scenario,
            seller_safe_id,
        );

        let buyer_safe_id = user_safe_id(scenario, BUYER);
        let buyer_safe: Safe = test_scenario::take_shared_by_id(
            scenario,
            buyer_safe_id,
        );

        let wl: Whitelist = test_scenario::take_shared(scenario);

        assert!(!safe::has_nft<Foo>(nft_id, &buyer_safe), 0);
        assert!(safe::has_nft<Foo>(nft_id, &seller_safe), 0);

        bidding::sell_nft<Foo, SUI>(
            &mut bid,
            transfer_cap,
            &mut seller_safe,
            &mut buyer_safe,
            &wl,
            ctx(scenario),
        );

        assert!(safe::has_nft<Foo>(nft_id, &buyer_safe), 0);
        assert!(!safe::has_nft<Foo>(nft_id, &seller_safe), 0);

        test_scenario::return_shared(buyer_safe);
        test_scenario::return_shared(seller_safe);
        test_scenario::return_shared(wl);
        test_scenario::return_shared(bid);

        test_scenario::next_tx(scenario, SELLER);
    }

    fun user_safe_id(scenario: &Scenario, user: address): ID {
        let owner_cap_id = vector::pop_back(
            &mut test_scenario::ids_for_address<safe::OwnerCap>(user)
        );
        let owner_cap: safe::OwnerCap =
            test_scenario::take_from_address_by_id(scenario, user, owner_cap_id);

        let safe_id = safe::owner_cap_safe(&owner_cap);

        test_scenario::return_to_address(user, owner_cap);

        safe_id
    }
}
