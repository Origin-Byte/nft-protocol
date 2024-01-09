#[test_only]
#[lint_allow(share_owned)]
module ob_tests::test_utils {
    use std::option::{none};

    use sui::sui::SUI;
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID, ID};
    use sui::package::{Self, Publisher};
    use sui::transfer_policy::{TransferPolicy, TransferPolicyCap};
    use sui::test_scenario::{Scenario, ctx};

    use ob_permissions::witness::{Self, Witness as DelegatedWitness};
    use nft_protocol::mint_cap::MintCap;
    use nft_protocol::collection::{Self, Collection};
    use ob_request::request::{Policy, PolicyCap, WithNft};
    use ob_request::withdraw_request::{Self, WITHDRAW_REQ};
    use ob_request::transfer_request;
    use liquidity_layer_v1::bidding as bidding_v1;
    use liquidity_layer_v1::orderbook as orderbook_v1;

    use ob_allowlist::allowlist::{Self, Allowlist, AllowlistOwnerCap};

    const MARKETPLACE: address = @0xA1C08;
    const CREATOR: address = @0xA1C04;
    const BUYER: address = @0xA1C10;
    const SELLER: address = @0xA1C15;
    const FAKE_ADDRESS: address = @0xA1C45;

    struct Foo has key, store {
        id: UID,
        index: u64,
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
    public fun index(foo: &Foo): u64 {
        foo.index
    }

    #[test_only]
    public fun init_collection_foo(
        ctx: &mut TxContext
    ): (Collection<Foo>, MintCap<Foo>) {
        collection::create_with_mint_cap<TEST_UTILS, Foo>(
            &TEST_UTILS {}, none(), ctx
        )
    }

    #[test_only]
    public fun get_foo_nft(ctx: &mut TxContext): Foo {
        Foo { id: object::new(ctx), index: 0}
    }

    #[test_only]
    public fun get_foo_nft_with_index(index: u64, ctx: &mut TxContext): Foo {
        Foo { id: object::new(ctx), index }
    }


    #[test_only]
    public fun get_publisher(ctx: &mut TxContext): Publisher {
        package::test_claim<TEST_UTILS>(TEST_UTILS {}, ctx)
    }

    #[test_only]
    public fun init_transfer_policy(publisher: &Publisher, ctx: &mut TxContext): (TransferPolicy<Foo>, TransferPolicyCap<Foo>) {
        transfer_request::init_policy<Foo>(publisher, ctx)
    }

    #[test_only]
    public fun init_withdrawable_policy(publisher: &Publisher, ctx: &mut TxContext): (Policy<WithNft<Foo, WITHDRAW_REQ>>, PolicyCap) {
        withdraw_request::init_policy<Foo>(publisher, ctx)
    }

    #[test_only]
    public fun create_orderbook_v1<T: key + store>(
        witness: DelegatedWitness<T>,
        transfer_policy: &TransferPolicy<T>,
        scenario: &mut Scenario
    ): ID {
        let ob = orderbook_v1::new_unprotected<T, SUI>(witness, transfer_policy, ctx(scenario));
        orderbook_v1::change_tick_size<T, SUI>(witness::from_witness(Witness {}), &mut ob, 1);
        let ob_id = object::id(&ob);

        orderbook_v1::share(ob);

        ob_id
    }

    #[test_only]
    public fun create_external_orderbook_v1<T: key + store>(
        transfer_policy: &TransferPolicy<T>,
        scenario: &mut Scenario
    ) {
        orderbook_v1::create_for_external<T, SUI>(transfer_policy, ctx(scenario));
    }

    #[test_only]
    public fun create_allowlist_v1(scenario: &mut Scenario): (Allowlist, AllowlistOwnerCap) {
        let (al, al_cap) = allowlist::new(ctx(scenario));

        // orderbooks can perform trades with our allowlist
        allowlist::insert_authority<orderbook_v1::Witness>(&al_cap, &mut al);
        // bidding contract can perform trades too
        allowlist::insert_authority<bidding_v1::Witness>(&al_cap, &mut al);

        (al, al_cap)
    }
}
