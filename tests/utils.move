#[test_only]
module nft_protocol::test_utils {
    use nft_protocol::collection;
    use nft_protocol::witness;
    use nft_protocol::orderbook::{Self as ob, Orderbook};
    use nft_protocol::safe::{Self, Safe, OwnerCap};
    use nft_protocol::transfer_allowlist::{Self, Allowlist};

    use std::option;
    use std::vector;

    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use sui::sui::SUI;
    use sui::test_scenario::{Self, Scenario, ctx};
    use sui::transfer::{public_transfer, public_share_object};
    use sui::tx_context;

    struct Foo has key, store {
        id: UID,
    }

    struct Witness has drop {}

    public fun witness(): Witness {
        Witness {}
    }

    public fun create_collection_and_allowlist(
        creator: address,
        scenario: &mut Scenario,
    ): (ID, ID, ID) {
        let (cap, col) =
            collection::create<Witness, Foo>(&Witness {}, ctx(scenario));

        let col_id = object::id(&col);
        let cap_id = object::id(&cap);

        public_share_object(col);
        test_scenario::next_tx(scenario, creator);

        transfer_allowlist::init_allowlist(&Witness {}, ctx(scenario));

        test_scenario::next_tx(scenario, creator);

        let wl: Allowlist = test_scenario::take_shared(scenario);
        let wl_id = object::id(&wl);

        transfer_allowlist::insert_collection<Foo, Witness>(
            &Witness {},
            witness::from_witness(&Witness {}),
            &mut wl,
        );

        public_transfer(cap, creator);
        test_scenario::return_shared(wl);

        (col_id, cap_id, wl_id)
    }

    public fun create_ob(scenario: &mut Scenario): ID {
        let ob = ob::new_unprotected<Foo, SUI>(ctx(scenario));
        let ob_id = object::id(&ob);

        ob::share(ob);

        let sender = tx_context::sender(ctx(scenario));
        test_scenario::next_tx(scenario, sender);

        ob_id
    }

    public fun create_safe(
        scenario: &mut Scenario,
        owner: address,
    ): (ID, ID) {
        test_scenario::next_tx(scenario, owner);

        let owner_cap = safe::create_safe(ctx(scenario));
        test_scenario::next_tx(scenario, owner);

        let safe: Safe = test_scenario::take_shared(scenario);

        let safe_id = object::id(&safe);
        let owner_cap_id = object::id(&owner_cap);

        test_scenario::return_shared(safe);
        public_transfer(owner_cap, owner);

        test_scenario::next_tx(scenario, owner);

        (safe_id, owner_cap_id)
    }

    public fun mint_and_deposit_nft_sender(
        scenario: &mut Scenario,
    ): ID {
        let sender = tx_context::sender(ctx(scenario));
        mint_and_deposit_nft(scenario, sender)
    }

    public fun mint_and_deposit_nft(
        scenario: &mut Scenario,
        user: address,
    ): ID {
        test_scenario::next_tx(scenario, user);
        let (owner_cap, safe) = owner_cap_and_safe(scenario, user);

        let nft = Foo { id: object::new(ctx(scenario)) };

        let nft_id = object::id(&nft);
        safe::deposit_nft(nft, &mut safe, ctx(scenario));

        test_scenario::return_shared(safe);
        public_transfer(owner_cap, user);

        test_scenario::next_tx(scenario, user);

        nft_id
    }

    public fun create_ask(
        scenario: &mut Scenario,
        nft_id: ID,
        price: u64,
    ): ID {
        let seller = tx_context::sender(ctx(scenario));
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
        public_transfer(owner_cap, seller);

        test_scenario::next_tx(scenario, seller);

        transfer_cap_id
    }

    public fun create_ask_with_commission(
        scenario: &mut Scenario,
        nft_id: ID,
        price: u64,
        beneficiary: address,
        commission_ft: u64,
    ): ID {
        let seller = tx_context::sender(ctx(scenario));
        let (owner_cap, seller_safe) = owner_cap_and_safe(scenario, seller);

        let transfer_cap = safe::create_exclusive_transfer_cap(
            nft_id,
            &owner_cap,
            &mut seller_safe,
            ctx(scenario)
        );

        let transfer_cap_id = object::id(&transfer_cap);

        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(scenario);

        ob::create_ask_with_commission(
            &mut ob,
            price,
            transfer_cap,
            beneficiary,
            commission_ft,
            &mut seller_safe,
            ctx(scenario),
        );

        test_scenario::return_shared(ob);
        test_scenario::return_shared(seller_safe);
        public_transfer(owner_cap, seller);

        test_scenario::next_tx(scenario, seller);

        transfer_cap_id
    }

    public fun finish_trade(
        scenario: &mut Scenario,
        nft_id: ID,
        buyer: address,
        seller: address,
    ) {
        let id = test_scenario::most_recent_id_shared<
            ob::TradeIntermediate<Foo, SUI>
        >();

        finish_trade_id(
            scenario,
            option::destroy_some(id),
            nft_id,
            buyer,
            seller,
        )
    }

    public fun finish_trade_id(
        scenario: &mut Scenario,
        ti_id: ID,
        nft_id: ID,
        buyer: address,
        seller: address,
    ) {
        let ti: ob::TradeIntermediate<Foo, SUI> =
            test_scenario::take_shared_by_id(scenario, ti_id);
        let wl: Allowlist = test_scenario::take_shared(scenario);

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

    public fun buy_nft(
        scenario: &mut Scenario,
        nft_id: ID,
        seller: address,
        price: u64,
    ) {
        let buyer = tx_context::sender(ctx(scenario));
        let buyer_safe = user_safe(scenario, buyer);
        let seller_safe = user_safe(scenario, seller);
        let wallet = coin::mint_for_testing<SUI>(price, ctx(scenario));
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(scenario);
        let wl: Allowlist = test_scenario::take_shared(scenario);
        test_scenario::next_tx(scenario, buyer);

        ob::buy_nft(
            &mut ob,
            nft_id,
            price,
            &mut wallet,
            &mut seller_safe,
            &mut buyer_safe,
            &wl,
            ctx(scenario),
        );

        test_scenario::return_shared(ob);
        test_scenario::return_shared(wl);
        test_scenario::return_shared(buyer_safe);
        test_scenario::return_shared(seller_safe);
        coin::destroy_zero(wallet);

        test_scenario::next_tx(scenario, buyer);
    }

    public fun create_bid(
        scenario: &mut Scenario,
        price: u64,
    ) {
        let buyer = tx_context::sender(ctx(scenario));
        let buyer_safe = user_safe(scenario, buyer);
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(scenario);
        let asks = ob::borrow_asks(&ob);
        let amount = if (originmate::crit_bit_u64::is_empty(asks)) {
            // no asks, create a bid with the given price
            price
        } else {
            // we will execute at the min ask price, so don't put into the
            // wallet more than that
            let min_ask = originmate::crit_bit_u64::min_key(asks);
            sui::math::min(price, min_ask)
        };
        let wallet = coin::mint_for_testing<SUI>(amount, ctx(scenario));
        test_scenario::next_tx(scenario, buyer);

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

    public fun create_bid_with_commission(
        scenario: &mut Scenario,
        price: u64,
        beneficiary: address,
        commission_ft: u64,
    ) {
        let buyer = tx_context::sender(ctx(scenario));
        let buyer_safe = user_safe(scenario, buyer);
        let wallet = coin::mint_for_testing<SUI>(price + commission_ft, ctx(scenario));
        let ob: Orderbook<Foo, SUI> = test_scenario::take_shared(scenario);
        test_scenario::next_tx(scenario, buyer);

        ob::create_bid_with_commission(
            &mut ob,
            &mut buyer_safe,
            price,
            beneficiary,
            commission_ft,
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

        wallet
    }
}
