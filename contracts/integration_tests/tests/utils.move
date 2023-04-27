#[test_only]
module ob_tests::test_utils {
    use std::option;

    use sui::sui::SUI;
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID, ID};
    use sui::package::{Self, Publisher};
    use sui::transfer_policy::{TransferPolicy, TransferPolicyCap};
    use sui::test_scenario::{Scenario, ctx};

    use ob_witness::witness::Witness as DelegatedWitness;
    use liquidity_layer::bidding;
    use liquidity_layer::orderbook;
    use nft_protocol::mint_cap::MintCap;
    use nft_protocol::collection::{Self, Collection};
    use ob_request::request::{Policy, PolicyCap, WithNft};
    use ob_request::withdraw_request::{Self, WITHDRAW_REQ};
    use ob_request::ob_transfer_request;

    use ob_allowlist::allowlist::{Self, Allowlist, AllowlistOwnerCap};

    const MARKETPLACE: address = @0xA1C08;
    const CREATOR: address = @0xA1C04;
    const BUYER: address = @0xA1C10;
    const SELLER: address = @0xA1C15;
    const FAKE_ADDRESS: address = @0xA1C45;

    struct Foo has key, store {
        id: UID,
    }

    // Mock OTW
    struct TEST_UTILS has drop {}

    struct Witness has drop {}

    public fun witness(): Witness { Witness {} }

    public fun marketplace(): address { MARKETPLACE }
    public fun creator(): address { CREATOR }
    public fun buyer(): address { BUYER }
    public fun seller(): address { SELLER }
    public fun fake_address(): address { FAKE_ADDRESS }

    #[test_only]
    public fun init_collection_foo(
        ctx: &mut TxContext
    ): (Collection<Foo>, MintCap<Foo>) {
        collection::create_with_mint_cap<TEST_UTILS, Foo>(
            &TEST_UTILS {}, option::none(), ctx
        )
    }

    #[test_only]
    public fun get_foo_nft(ctx: &mut TxContext): Foo {
        Foo { id: object::new(ctx)}
    }

    #[test_only]
    public fun get_publisher(ctx: &mut TxContext): Publisher {
        package::test_claim<TEST_UTILS>(TEST_UTILS {}, ctx)
    }

    #[test_only]
    public fun init_transfer_policy(publisher: &Publisher, ctx: &mut TxContext): (TransferPolicy<Foo>, TransferPolicyCap<Foo>) {
        ob_transfer_request::init_policy<Foo>(publisher, ctx)
    }

    #[test_only]
    public fun init_withdrawable_policy(publisher: &Publisher, ctx: &mut TxContext): (Policy<WithNft<Foo, WITHDRAW_REQ>>, PolicyCap) {
        withdraw_request::init_policy<Foo>(publisher, ctx)
    }

    #[test_only]
    public fun create_orderbook<T: key + store>(
        witness: DelegatedWitness<T>,
        transfer_policy: &TransferPolicy<T>,
        scenario: &mut Scenario
    ): ID {
        let ob = orderbook::new_unprotected<T, SUI>(witness, transfer_policy, ctx(scenario));
        let ob_id = object::id(&ob);

        orderbook::share(ob);

        ob_id
    }

    #[test_only]
    public fun create_external_orderbook<T: key + store>(
        transfer_policy: &TransferPolicy<T>,
        scenario: &mut Scenario
    ) {
        orderbook::create_for_external<T, SUI>(transfer_policy, ctx(scenario));
    }

    #[test_only]
    public fun create_allowlist(scenario: &mut Scenario): (Allowlist, AllowlistOwnerCap) {
        let (al, al_cap) = allowlist::new(ctx(scenario));

        // orderbooks can perform trades with our allowlist
        allowlist::insert_authority<orderbook::Witness>(&al_cap, &mut al);
        // bidding contract can perform trades too
        allowlist::insert_authority<bidding::Witness>(&al_cap, &mut al);

        (al, al_cap)
    }
}
