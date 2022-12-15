#[test_only]
module nft_protocol::test_ob_utils {
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::nft;
    use nft_protocol::ob::{Self, Orderbook};
    use nft_protocol::safe::{Self, Safe, OwnerCap};
    use nft_protocol::transfer_whitelist::{Self, Whitelist};
    use std::vector;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID};
    use sui::sui::SUI;
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::transfer::{transfer, share_object};
    use sui::tx_context;

    const CREATOR: address = @0xA1C05;

    struct Foo has drop {} // collection
    struct Witness has drop {} // collection witness, must be named witness
    struct WhitelistWitness has drop {}

    public fun create_collection_and_whitelist(scenario: &mut Scenario) {
        let (cap, col) = collection::dummy_collection<Foo>(&Foo {}, CREATOR, scenario);
        share_object(col);
        test_scenario::next_tx(scenario, CREATOR);

        let col_control_cap = transfer_whitelist::create_collection_cap<Foo, Witness>(
            &Witness {}, ctx(scenario),
        );

        let col: Collection<Foo> = test_scenario::take_shared(scenario);
        nft_protocol::example_free_for_all::init_(ctx(scenario));
        test_scenario::next_tx(scenario, CREATOR);

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

    public fun create_ob(scenario: &mut Scenario): ID {
        let ob = ob::new_protected<Witness, Foo, SUI>(
            Witness {}, ctx(scenario)
        );
        let ob_id = object::id(&ob);

        ob::share(ob);

        test_scenario::next_tx(scenario, CREATOR);

        ob_id
    }

    public fun create_safe(
        scenario: &mut Scenario,
        owner: address,
    ): (ID, ID) {
        test_scenario::next_tx(scenario, owner);

        let owner_cap = safe::create_safe(ctx(scenario));
        test_scenario::next_tx(scenario, owner);

        let safe: Safe = test_scenario::take_shared(
            scenario,
        );

        let seller_safe_id = object::id(&safe);
        let owner_cap_id = object::id(&owner_cap);

        test_scenario::return_shared(safe);
        transfer(owner_cap, owner);

        test_scenario::next_tx(scenario, owner);

        (seller_safe_id, owner_cap_id)
    }

    public fun create_and_deposit_nft(
        scenario: &mut Scenario,
        user: address,
    ): ID {
        test_scenario::next_tx(scenario, user);
        let (owner_cap, safe) = owner_cap_and_safe(scenario, user);

        let nft = nft::new<Foo>(user, ctx(scenario));
        let nft_id = object::id(&nft);
        safe::deposit_nft<Foo>(
            nft,
            &mut safe,
            ctx(scenario),
        );

        test_scenario::return_shared(safe);
        transfer(owner_cap, user);

        test_scenario::next_tx(scenario, user);

        nft_id
    }

    public fun create_ask(
        scenario: &mut Scenario,
        nft_id: ID,
        seller: address,
        price: u64,
    ): ID {
        let (owner_cap, seller_safe) = owner_cap_and_safe(scenario, seller);

        let transfer_cap = safe::create_exclusive_transfer_cap(
            nft_id,
            &owner_cap,
            &mut seller_safe,
            ctx(scenario)
        );

        let transfer_cap_id = object::id(&transfer_cap);

        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(scenario);

        ob::create_ask(
            &mut ob,
            price,
            transfer_cap,
            &mut seller_safe,
            ctx(scenario),
        );

        test_scenario::return_shared(ob);
        test_scenario::return_shared(seller_safe);
        transfer(owner_cap, seller);

        test_scenario::next_tx(scenario, seller);

        transfer_cap_id
    }

    public fun finish_trade(
        scenario: &mut Scenario,
        nft_id: ID,
        buyer: address,
        seller: address,
    ) {
        let ti: ob::TradeIntermediate<Foo, SUI> =
            test_scenario::take_shared(scenario);
        let wl: Whitelist = test_scenario::take_shared(scenario);

        let seller_safe = user_safe(scenario, seller);
        let buyer_safe = user_safe(scenario, buyer);

        assert!(!safe::has_nft<Foo>(nft_id, &buyer_safe), 0);
        assert!(safe::has_nft<Foo>(nft_id, &seller_safe), 0);

        ob::finish_trade(
            &mut ti,
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
        test_scenario::return_shared(ti);

        test_scenario::next_tx(scenario, buyer);
    }

    public fun create_bid(
        scenario: &mut Scenario,
        price: u64,
    ) {
        let buyer = tx_context::sender(ctx(scenario));

        let buyer_safe = user_safe(scenario, buyer);

        test_scenario::next_tx(scenario, buyer);

        let wallet = coin::mint_for_testing<SUI>(price, ctx(scenario));

        test_scenario::next_tx(scenario, buyer);

        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(scenario);

        ob::create_bid(
            &mut ob,
            &mut buyer_safe,
            price,
            &mut wallet,
            ctx(scenario),
        );
        test_scenario::return_shared(ob);
        coin::destroy_zero(wallet);

        test_scenario::return_shared(buyer_safe);

        test_scenario::next_tx(scenario, buyer);
    }

    public fun user_safe_id(scenario: &Scenario, user: address): ID {
        let owner_cap_id = user_owner_cap_id(user);
        let owner_cap: OwnerCap =
            test_scenario::take_from_address_by_id(scenario, user, owner_cap_id);

        let safe_id = safe::owner_cap_safe(&owner_cap);

        test_scenario::return_to_address(user, owner_cap);

        safe_id
    }

    public fun user_safe(scenario: &Scenario, user: address): Safe {
        let safe_id = user_safe_id(scenario, user);
        test_scenario::take_shared_by_id(scenario, safe_id)
    }

    public fun owner_cap_safe(scenario: &Scenario, owner_cap: &OwnerCap): Safe {
        let safe_id = safe::owner_cap_safe(owner_cap);
        test_scenario::take_shared_by_id(scenario, safe_id)
    }

    public fun owner_cap_and_safe(scenario: &Scenario, user: address): (OwnerCap, Safe) {
        let owner_cap: OwnerCap = test_scenario::take_from_address_by_id(
            scenario,
            user,
            user_owner_cap_id(user),
        );
        let safe = owner_cap_safe(scenario, &owner_cap);

        (owner_cap, safe)
    }

    public fun user_owner_cap_id(user: address): ID {
        vector::pop_back(
            &mut test_scenario::ids_for_address<OwnerCap>(user)
        )
    }

    public fun cancel_ask(
        scenario: &mut Scenario,
        nft_id: ID,
        price: u64,
    ) {
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(scenario);

        ob::cancel_ask(
            &mut ob,
            price,
            nft_id,
            ctx(scenario),
        );
        test_scenario::return_shared(ob);
    }

    public fun cancel_bid(
        scenario: &mut Scenario,
        buyer: address,
        price: u64,
    ): Coin<SUI> {
        test_scenario::next_tx(scenario, buyer);

        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(scenario);

        let wallet = coin::zero(ctx(scenario));

        ob::cancel_bid(
            &mut ob,
            price,
            &mut wallet,
            ctx(scenario),
        );
        test_scenario::return_shared(ob);
        test_scenario::next_tx(scenario, buyer);

        wallet
    }
}
