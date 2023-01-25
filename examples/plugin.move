module nft_protocol::plugin_pattern_base_contract {
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::creators;
    use nft_protocol::multisig::{Self, Multisig, FromCreatorsDomain};
    use nft_protocol::plugins;
    use sui::transfer::{transfer, share_object};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set;

    /// Simulates one-time-witness
    struct Foo has drop {}

    struct Witness has drop {}

    const SECOND_CREATOR: address = @0xA1C06;

    public fun second_creator(): address {
        SECOND_CREATOR
    }

    /// Simulates init function
    public fun init_(ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        assert!(sender != SECOND_CREATOR, 0);

        let (mint_cap, collection) = collection::create<Foo>(
            &Foo {},
            ctx,
        );

        let creators_addrs = vec_set::singleton(tx_context::sender(ctx));
        vec_set::insert(&mut creators_addrs, SECOND_CREATOR);
        collection::add_domain(
            &mut collection,
            &mut mint_cap,
            creators::from_creators(creators_addrs, ctx)
        );

        collection::add_domain(
            &mut collection,
            &mut mint_cap,
            plugins::empty(ctx),
        );

        transfer(mint_cap, sender);
        share_object(collection);
    }

    public fun witness_for_plugin<PluginWitness: drop>(
        _plugin_witness: PluginWitness,
        collection: &Collection<Foo>,
    ): Witness {
        let plugins_domain = plugins::borrow_plugin_domain(collection);
        plugins::assert_has_plugin<PluginWitness>(plugins_domain);

        Witness {}
    }

    struct AddPlugin<phantom PluginWitness> has drop, store {}

    public entry fun create_multisig_to_add_plugin<PluginWitness>(
        collection: &Collection<Foo>,
        ctx: &mut TxContext,
    ) {
        creators::assert_collection_has_creator(
            collection, &tx_context::sender(ctx)
        );

        share_object(multisig::from_creators_domain(
            AddPlugin<PluginWitness>{},
            collection,
            ctx,
        ));
    }

    public entry fun add_plugin<PluginWitness>(
        multisig: &mut Multisig<FromCreatorsDomain<AddPlugin<PluginWitness>>>,
        collection: &mut Collection<Foo>,
    ) {
        // both creators must sign
        multisig::consume_from_creators_domain<AddPlugin<PluginWitness>, Foo>(2, multisig);

        let d = plugins::borrow_plugin_domain_mut(Witness{}, collection);
        plugins::add_plugin<PluginWitness>(d);
    }
}

module nft_protocol::plugin_pattern_plugin_contract {
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::collection::{Collection};
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::plugin_pattern_base_contract::{Self, Foo};

    struct Witness has drop {}

    public fun mint_nft(
        collection: &mut Collection<Foo>,
        ctx: &mut TxContext,
    ): Nft<Foo> {
        let og_witness =
            plugin_pattern_base_contract::witness_for_plugin(Witness {}, collection);

        nft::new(&og_witness, tx_context::sender(ctx), ctx)
    }
}

#[test_only]
module nft_protocol::test_plugin_pattern {
    use nft_protocol::collection::Collection;
    use nft_protocol::multisig::{Self, Multisig};
    use nft_protocol::plugin_pattern_base_contract::{Self, Foo, AddPlugin};
    use nft_protocol::plugin_pattern_plugin_contract::{Self, Witness as PWitness};
    use sui::test_scenario::{Self, ctx};
    use sui::transfer::transfer;

    const USER: address = @0xA1C03;
    const THIRD_PARTY: address = @0xA1C04;

    #[test]
    #[expected_failure(abort_code = 13370804, location = nft_protocol::plugins)]
    fun it_cannot_grab_witness_if_not_plugin() {
        let scenario = test_scenario::begin(USER);

        plugin_pattern_base_contract::init_(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);

        let col = test_scenario::take_shared<Collection<Foo>>(&scenario);

        let nft =
            plugin_pattern_plugin_contract::mint_nft(&mut col, ctx(&mut scenario));

        transfer(nft, USER);
        test_scenario::return_shared(col);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370604, location = nft_protocol::multisig)]
    fun it_cannot_add_plugin_if_not_signed() {
        let scenario = test_scenario::begin(USER);

        plugin_pattern_base_contract::init_(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);

        let col = test_scenario::take_shared<Collection<Foo>>(&scenario);

        plugin_pattern_base_contract::create_multisig_to_add_plugin<PWitness>(
            &col,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, USER);

        let multisig = test_scenario::take_shared<
            Multisig<multisig::FromCreatorsDomain<AddPlugin<PWitness>>>
        >(&scenario);
        plugin_pattern_base_contract::add_plugin(
            &mut multisig,
            &mut col,
        );

        test_scenario::next_tx(&mut scenario, USER);

        let nft =
            plugin_pattern_plugin_contract::mint_nft(&mut col, ctx(&mut scenario));

        transfer(nft, USER);
        test_scenario::return_shared(multisig);
        test_scenario::return_shared(col);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370604, location = nft_protocol::multisig)]
    fun it_cannot_add_plugin_if_signed_only_by_one_creator() {
        let scenario = test_scenario::begin(USER);

        plugin_pattern_base_contract::init_(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);

        let col = test_scenario::take_shared<Collection<Foo>>(&scenario);

        plugin_pattern_base_contract::create_multisig_to_add_plugin<PWitness>(
            &col,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, USER);

        let multisig = test_scenario::take_shared<
            Multisig<multisig::FromCreatorsDomain<AddPlugin<PWitness>>>
        >(&scenario);

        test_scenario::next_tx(&mut scenario, USER);
        multisig::sign(&mut multisig, ctx(&mut scenario));

        plugin_pattern_base_contract::add_plugin(
            &mut multisig,
            &mut col,
        );

        test_scenario::next_tx(&mut scenario, USER);

        let nft =
            plugin_pattern_plugin_contract::mint_nft(&mut col, ctx(&mut scenario));

        transfer(nft, USER);
        test_scenario::return_shared(multisig);
        test_scenario::return_shared(col);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_works() {
        let scenario = test_scenario::begin(USER);

        plugin_pattern_base_contract::init_(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER);

        let col = test_scenario::take_shared<Collection<Foo>>(&scenario);

        plugin_pattern_base_contract::create_multisig_to_add_plugin<PWitness>(
            &col,
            ctx(&mut scenario),
        );

        test_scenario::next_tx(&mut scenario, USER);

        let multisig = test_scenario::take_shared<
            Multisig<multisig::FromCreatorsDomain<AddPlugin<PWitness>>>
        >(&scenario);

        test_scenario::next_tx(&mut scenario, USER);
        multisig::sign(&mut multisig, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, plugin_pattern_base_contract::second_creator());
        multisig::sign(&mut multisig, ctx(&mut scenario));

        plugin_pattern_base_contract::add_plugin(
            &mut multisig,
            &mut col,
        );

        test_scenario::next_tx(&mut scenario, USER);

        let nft =
            plugin_pattern_plugin_contract::mint_nft(&mut col, ctx(&mut scenario));

        transfer(nft, USER);
        test_scenario::return_shared(multisig);
        test_scenario::return_shared(col);
        test_scenario::end(scenario);
    }
}
