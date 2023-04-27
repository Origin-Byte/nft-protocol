#[test_only]
module nft_protocol::test_mint_event {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::mint_event;
    use ob_witness::witness;

    struct Foo has key, store {
        id: UID,
    }

    struct Witness has drop {}

    const CREATOR: address = @0xA1C05;

    #[test]
    #[expected_failure(abort_code = mint_event::EInvalidBurnGuard)]
    fun try_burn() {
        let scenario = test_scenario::begin(CREATOR);

        let collection = object::new(ctx(&mut scenario));
        let collection_id = object::uid_to_inner(&collection);

        let delegated_witness =
            witness::from_witness<Foo, Witness>(Witness {});

        let nft = Foo { id: object::new(ctx(&mut scenario)) };

        let guard = mint_event::start_burn(delegated_witness, &nft);

        let fake_id = object::new(ctx(&mut scenario));
        mint_event::emit_burn(guard, collection_id, fake_id);

        let Foo { id } = nft;
        object::delete(id);
        object::delete(collection);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_events() {
        let scenario = test_scenario::begin(CREATOR);

        let collection = object::new(ctx(&mut scenario));
        let collection_id = object::uid_to_inner(&collection);

        let delegated_witness =
            witness::from_witness<Foo, Witness>(Witness {});

        let nft = Foo { id: object::new(ctx(&mut scenario)) };
        mint_event::emit_mint(delegated_witness, collection_id, &nft);

        transfer::public_transfer(nft, CREATOR);
        test_scenario::next_tx(&mut scenario, CREATOR);

        let nft = test_scenario::take_from_address<Foo>(
            &scenario, CREATOR,
        );

        let guard = mint_event::start_burn(delegated_witness, &nft);
        let Foo { id } = nft;

        mint_event::emit_burn(guard, collection_id, id);

        object::delete(collection);
        test_scenario::end(scenario);
    }
}
