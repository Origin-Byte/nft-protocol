/// This contract helps you generate some events and txs.
/// It can be used to test client logic.
///
/// It also contains examples on how to use certain aspects of the protocol,
/// especially trading.
/// See `generate_bidding_events`.
///
/// It's written such that a single sender calls the entry functions in the same
/// order that they are declared.
/// Read the created objects from those txs as you'll need some as inputs to the
/// next transactions.
/// We start the module with a `test_example_testract` test which shows how those txs should
/// be called in order.
module examples::testract {
    use nft_protocol::bidding;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::display_info;
    use nft_protocol::fixed_price;
    use nft_protocol::inventory;
    use nft_protocol::limited_fixed_price;
    use nft_protocol::listing;
    use nft_protocol::mint_cap::MintCap;
    use nft_protocol::mint_event;
    use nft_protocol::ob_kiosk;
    use nft_protocol::ob_transfer_request;
    use nft_protocol::orderbook::{Self, Orderbook};
    use nft_protocol::royalty_strategy_bps::{Self, BpsRoyaltyStrategy};
    use nft_protocol::royalty;
    use nft_protocol::symbol;
    use nft_protocol::tags;
    use nft_protocol::transfer_allowlist_domain;
    use nft_protocol::transfer_allowlist::{Self, Allowlist};
    use nft_protocol::warehouse;
    use nft_protocol::witness::{Self, Witness as DelegatedWitness};
    use std::option;
    use std::string::{String, utf8};
    use sui::coin::Coin;
    use sui::object::{Self, UID};
    use sui::package::{Self, Publisher};
    use sui::sui::SUI;
    use sui::transfer_policy::{Self, TransferPolicy};
    use sui::transfer::{public_transfer, public_share_object};
    use sui::tx_context::{sender, TxContext};
    use sui::url::{Self, Url};

    /// OTW for constructing publisher
    struct TESTRACT has drop {}

    /// An auth type for actions within nft-protocol
    struct Witness has drop {}

    /// The actual NFT type of `Collection<TestNft>`
    struct TestNft has key, store {
        id: UID,
        name: String,
        description: String,
        url: Url,
    }

    /// Store publisher, mint_cap and collection object IDs.
    /// You'll need those for subsequent txs.
    fun init(witness: TESTRACT, ctx: &mut TxContext) {
        let (collection, mint_cap) = collection::create_with_mint_cap<TESTRACT, TestNft>(
            &witness, option::none(), ctx
        );

        add_domains(&mut collection, ctx);

        let publisher = package::claim(witness, ctx);

        public_transfer(publisher, sender(ctx));
        public_transfer(mint_cap, sender(ctx));
        public_share_object(collection);
    }

    /// Mint new NFTs and transfer them to sender.
    /// Allows us to test `mint_event::MintEvent`.
    public entry fun mint_nfts(
        mint_cap: &mut MintCap<TestNft>, ctx: &mut TxContext,
    ) {
        let i = 0;
        while (i < 5) {
            let nft = TestNft {
                id: object::new(ctx),
                name: utf8(b"NFT of mint_nfts"),
                description: utf8(b"A description indeed"),
                url: url::new_unsafe_from_bytes(b"http://example.com"),
            };
            mint_event::mint_unlimited(mint_cap, &nft);
            public_transfer(nft, sender(ctx));

            i = i + 1;
        };
    }

    /// Used to authorize actions as an entity who controls allowlist.
    struct AllowlistAdmin {}

    /// While normally we'd expect to see allowlists managed by some 3rd entity
    /// who the creators trust, for the purposes of the test we'll just use
    /// a dedicated allowlist for our specific collection.
    ///
    /// As of this stage, the allowlist is _not enforced_.
    /// See `register_allowlist_and_royalty_strategy` (comes later).
    ///
    /// Store allowlist object ID.
    public entry fun create_allowlist(
        collection: &mut Collection<TestNft>, ctx: &mut TxContext,
    ) {
        // the `AllowlistAdmin` is used as a type in `DeletegatedWitness<T>`
        // to authorize admin actions on the allowlist
        let al = transfer_allowlist::create(allowlist_wit(), ctx);

        // orderbooks can perform trades with our allowlist
        transfer_allowlist::insert_authority<AllowlistAdmin, orderbook::Witness>(allowlist_wit(), &mut al);
        // bidding contract can perform trades too
        transfer_allowlist::insert_authority<AllowlistAdmin, bidding::Witness>(allowlist_wit(), &mut al);
        // our allowlist can authorize on behalf of the collection TestNft
        transfer_allowlist::insert_collection(
            allowlist_wit(),
            col_wit(),
            &mut al,
        );

        // stores the information about the allowlist in the collection for
        // off-chain clients
        transfer_allowlist_domain::add_id(col_wit(), collection, &al);

        public_share_object(al);
    }

    /// Creates a royalty strategy which charges 1% on trades.
    ///
    /// As of this stage, the strategy is _not enforced_.
    /// See `register_allowlist_and_royalty_strategy`.
    ///
    /// Store strategy object ID.
    public entry fun create_royalty_strategy(
        collection: &mut Collection<TestNft>, ctx: &mut TxContext,
    ) {
        let one_percent = nft_protocol::utils::bps() / 100;

        let royalty_strategy = royalty_strategy_bps::new(
            col_wit(), collection, one_percent, ctx,
        );
        // this means that we get mutable access to the traded amount and deduct
        // from it
        // see `ob_transfer_request::BalanceCap` for more info
        royalty_strategy_bps::add_balance_access_cap(
            &mut royalty_strategy,
            ob_transfer_request::grant_balance_access_cap(col_wit()),
        );

        royalty_strategy_bps::share(royalty_strategy);
    }

    /// Registers the allowlist and royalty strategy by creating a
    /// `sui::transfer_policy::TransferPolicy` and attaching the rules to it.
    /// Now these two rules are enforced on transfers.
    ///
    /// Store policy object ID.
    ///
    /// #### Important
    /// We use special rules for OB ecosystem.
    /// We assume that the NFTs live in OB ecosystem.
    public entry fun register_allowlist_and_royalty_strategy(
        publisher: &Publisher, ctx: &mut TxContext,
    ) {
        let (policy, cap) = transfer_policy::new<TestNft>(publisher, ctx);

        royalty_strategy_bps::add_policy_rule(&mut policy, &cap);
        transfer_allowlist::add_policy_rule(&mut policy, &cap);

        public_share_object(policy);
        public_transfer(cap, sender(ctx));
    }

    /// To avoid messing with type parameters in the CLI call.
    ///
    /// Store orderbook object ID.
    public entry fun create_orderbook(ctx: &mut TxContext) {
        orderbook::create_unprotected<TestNft, SUI>(ctx);
    }

    /// Adds a few bids bid and asks.
    /// Some will result in trades.
    /// The trades only create `TradeIntermediary` objects which are yet to be
    /// resolved into actual NFT transfer.
    /// That's why we don't need allowlist, policy and strategy here.
    public entry fun generate_orderbook_events(
        orderbook: &mut Orderbook<TestNft, SUI>,
        mint_cap: &MintCap<TestNft>,
        wallet: &mut Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        let sender = sender(ctx);

        let i = 0;
        while(i < 5) {
            let price = 1000 + i * 100;

            let kiosk = ob_kiosk::new(ctx);
            orderbook::create_bid(
                orderbook,
                &mut kiosk,
                price,
                wallet,
                ctx,
            );
            public_transfer(kiosk, sender);

            i = i + 1;
        };


        let i = 0;
        while(i < 5) {
            let price = 1300 + i * 100;

            let kiosk = ob_kiosk::new(ctx);
            let nft = TestNft {
                id: object::new(ctx),
                name: utf8(b"generate_orderbook_events"),
                description: utf8(b"Created to test Orderbook events"),
                url: url::new_unsafe_from_bytes(b"http://example.com"),
            };
            let nft_id = object::id(&nft);
            mint_event::mint_unlimited(mint_cap, &nft);
            ob_kiosk::deposit(&mut kiosk, nft, ctx);
            orderbook::create_ask(
                orderbook,
                &mut kiosk,
                price,
                nft_id,
                ctx,
            );
            public_transfer(kiosk, sender);
            i = i + 1;
        };
    }

    /// Creates a bid with bidding contract and then sells an nft.
    ///
    /// Uses the whole process of royalty enforcement.
    ///
    /// 1. Initiate trade via a contract `bidding` (deposits NFT to buyer kiosk)
    /// 2. The returned hotpotato `TransferRequest` (not the Sui FW version!)
    /// is sent through allowlist to check that `bidding` is authorized
    /// 3. Then sent through royalty strategy to charge fee on trade
    /// 4. Then request is destroyed ok because it went through all the rules
    public entry fun generate_bidding_events(
        mint_cap: &MintCap<TestNft>,
        transfer_policy: &TransferPolicy<TestNft>,
        allowlist: &Allowlist,
        royalty_strategy: &mut BpsRoyaltyStrategy<TestNft>,
        wallet: &mut Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        let nft = TestNft {
            id: object::new(ctx),
            name: utf8(b"generate_bidding_events"),
            description: utf8(b"Created to test bidding events"),
            url: url::new_unsafe_from_bytes(b"http://example.com"),
        };
        let nft_id = object::id(&nft);
        mint_event::mint_unlimited(mint_cap, &nft);

        let buyer_kiosk = ob_kiosk::new(ctx);

        let bid = nft_protocol::bidding::new_bid(
            object::id(&buyer_kiosk),
            nft_id,
            333,
            option::none(),
            wallet,
            ctx,
        );

        let transfer_req = bidding::sell_nft<TestNft, SUI>(
            &mut bid, &mut buyer_kiosk, nft, ctx,
        );

        // and now for confirming transfer
        // (see `register_allowlist_and_royalty_strategy` and `create_allowlist`)

        transfer_allowlist::confirm_transfer(allowlist, &mut transfer_req);
        royalty_strategy_bps::confirm_transfer<TestNft, SUI>(royalty_strategy, &mut transfer_req);

        // only if both rules are OK can we destroy the hot potato
        ob_transfer_request::confirm<TestNft, SUI>(transfer_req, transfer_policy, ctx);

        bidding::share(bid);
        public_transfer(buyer_kiosk, sender(ctx));
    }

    /// Generate some launchpad events for
    /// * fixed_market
    /// * limited_fixed_market
    public entry fun generate_launchpad_events(
        mint_cap: &MintCap<TestNft>,
        wallet: &mut Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        let listing = listing::new(sender(ctx), sender(ctx), ctx);

        let inventory = inventory::from_warehouse(warehouse::new(ctx), ctx);
        let i = 0;
        while(i < 6) {
            let nft = TestNft {
                id: object::new(ctx),
                name: utf8(b"generate_bidding_events"),
                description: utf8(b"Created to test bidding events"),
                url: url::new_unsafe_from_bytes(b"http://example.com"),
            };
            mint_event::mint_unlimited(mint_cap, &nft);

            inventory::deposit_nft(&mut inventory, nft);

            i = i + 1;
        };
        let inventory_id = object::id(&inventory);
        listing::add_inventory(&mut listing, inventory, ctx);

        let venue_id = fixed_price::create_venue<TestNft, SUI>(
            &mut listing,
            inventory_id,
            false, // is whitelisted
            500, // price
            ctx,
        );
        listing::sale_on(&mut listing, venue_id, ctx);
        let i = 0;
        while(i < 3) {
            fixed_price::buy_nft<TestNft, SUI>(
                &mut listing,
                venue_id,
                wallet,
                ctx,
            );

            i = i + 1;
        };

        let venue_id = limited_fixed_price::create_venue<TestNft, SUI>(
            &mut listing,
            inventory_id,
            false, // is whitelisted
            10, // limit
            500, // price
            ctx,
        );
        listing::sale_on(&mut listing, venue_id, ctx);
        let i = 0;
        while(i < 3) {
            limited_fixed_price::buy_nft<TestNft, SUI>(
                &mut listing,
                venue_id,
                wallet,
                ctx,
            );

            i = i + 1;
        };

        public_transfer(listing, sender(ctx));
    }

    /// Creates a bid with bidding contract and then cancels it.
    public entry fun generate_closed_bid_bidding_event(
        mint_cap: &MintCap<TestNft>,
        wallet: &mut Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        let nft = TestNft {
            id: object::new(ctx),
            name: utf8(b"generate_bidding_events"),
            description: utf8(b"Created to test bidding events"),
            url: url::new_unsafe_from_bytes(b"http://example.com"),
        };
        let nft_id = object::id(&nft);
        mint_event::mint_unlimited(mint_cap, &nft);

        let kiosk = ob_kiosk::new(ctx);

        let bid = nft_protocol::bidding::new_bid(
            object::id(&kiosk),
            nft_id,
            777,
            option::none(),
            wallet,
            ctx,
        );
        bidding::close_bid(&mut bid, ctx);

        ob_kiosk::deposit(&mut kiosk, nft, ctx);
        public_transfer(kiosk, sender(ctx));
        bidding::share(bid);
    }

    /// Creates a bid and closes it.
    /// Creates an ask and closes it.
    public entry fun generate_orderbook_close_events(
        mint_cap: &MintCap<TestNft>,
        orderbook: &mut Orderbook<TestNft, SUI>,
        wallet: &mut Coin<SUI>,
        ctx: &mut TxContext,
    ) {
        let kiosk = ob_kiosk::new(ctx);
        orderbook::create_bid(
            orderbook,
            &mut kiosk,
            456,
            wallet,
            ctx,
        );
        public_transfer(kiosk, sender(ctx));
        orderbook::cancel_bid(orderbook, 456, wallet, ctx);

        let kiosk = ob_kiosk::new(ctx);
        let nft = TestNft {
            id: object::new(ctx),
            name: utf8(b"generate_orderbook_close_events"),
            description: utf8(b"Created to test Orderbook close events"),
            url: url::new_unsafe_from_bytes(b"http://example.com"),
        };
        let nft_id = object::id(&nft);
        mint_event::mint_unlimited(mint_cap, &nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx);

        orderbook::create_ask(orderbook, &mut kiosk, 3_654, nft_id, ctx);
        orderbook::cancel_ask(orderbook, &mut kiosk, 3_654, nft_id, ctx);

        public_transfer(kiosk, sender(ctx));
    }

    /// === Helpers ====

    fun allowlist_wit(): DelegatedWitness<AllowlistAdmin> {
        witness::from_witness(Witness {})
    }

    fun col_wit(): DelegatedWitness<TestNft> {
        witness::from_witness(Witness{})
    }

    fun add_domains(
        collection: &mut Collection<TestNft>,
        ctx: &mut TxContext,
    ) {
        collection::add_domain(
            col_wit(),
            collection,
            transfer_allowlist_domain::empty(),
        );

        collection::add_domain(
            col_wit(),
            collection,
            display_info::new(
                utf8(b"Suimarines"),
                utf8(b"A unique NFT collection of Suimarines on Sui"),
            ),
        );

        collection::add_domain(
            col_wit(),
            collection,
            symbol::new(utf8(b"SUIM")),
        );

        collection::add_domain(
            col_wit(),
            collection,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        let royalty_domain = royalty::from_address(sender(ctx), ctx);
        collection::add_domain(col_wit(), collection, royalty_domain);
    }

    // === Tests ===

    #[test_only]
    use sui::test_scenario::{Self, ctx};

    // This is the creator, buyer and seller - all in one.
    #[test_only]
    const USER: address = @0xA1C04;

    // Calls all logic in this test package.
    //
    // See the function docs for more information on how they fit in.
    #[test]
    fun test_example_testract() {
        let scenario = test_scenario::begin(USER);
        let wallet = sui::coin::mint_for_testing(1_000_000, ctx(&mut scenario));

        // ---
        init(TESTRACT {}, ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let publisher = test_scenario::take_from_address<Publisher>(
            &scenario,
            USER,
        );
        let mint_cap = test_scenario::take_from_address<MintCap<TestNft>>(
            &scenario,
            USER,
        );
        let collection = test_scenario::take_shared<Collection<TestNft>>(
            &scenario,
        );

        // ---
        mint_nfts(&mut mint_cap, ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);

        // ---
        create_allowlist(&mut collection, ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let allowlist = test_scenario::take_shared<Allowlist>(&scenario);

        // ---
        create_royalty_strategy(&mut collection, ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let royalty_strategy = test_scenario::take_shared<BpsRoyaltyStrategy<TestNft>>(&scenario);

        //--
        register_allowlist_and_royalty_strategy(&publisher, ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let transfer_policy = test_scenario::take_shared<TransferPolicy<TestNft>>(&scenario);

        // ---
        create_orderbook(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);
        let orderbook = test_scenario::take_shared<Orderbook<TestNft, SUI>>(&scenario);

        // ---
        generate_orderbook_events(
            &mut orderbook,
            &mint_cap,
            &mut wallet,
            ctx(&mut scenario),
        );
        test_scenario::next_tx(&mut scenario, USER);

        // ---
        generate_bidding_events(
            &mint_cap,
            &transfer_policy,
            &allowlist,
            &mut royalty_strategy,
            &mut wallet,
            ctx(&mut scenario),
        );
        test_scenario::next_tx(&mut scenario, USER);

        // ---
        generate_launchpad_events(
            &mint_cap,
            &mut wallet,
            ctx(&mut scenario),
        );
        test_scenario::next_tx(&mut scenario, USER);

        // ---
        generate_closed_bid_bidding_event(
            &mint_cap,
            &mut wallet,
            ctx(&mut scenario),
        );
        test_scenario::next_tx(&mut scenario, USER);

        // ---
        generate_orderbook_close_events(
            &mint_cap,
            &mut orderbook,
            &mut wallet,
            ctx(&mut scenario),
        );
        test_scenario::next_tx(&mut scenario, USER);

        test_scenario::return_shared(orderbook);
        test_scenario::return_shared(transfer_policy);
        test_scenario::return_shared(royalty_strategy);
        test_scenario::return_shared(allowlist);
        test_scenario::return_shared(collection);
        test_scenario::return_to_address(USER, mint_cap);
        test_scenario::return_to_address(USER, publisher);
        sui::coin::burn_for_testing(wallet);
        test_scenario::end(scenario);
    }
}
