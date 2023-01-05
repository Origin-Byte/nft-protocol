#[test_only]
module nft_protocol::fake_witness {
    // TODO: To move to utils
    struct FakeWitness has drop {}

    public fun new(): FakeWitness {
        FakeWitness {}
    }
}

#[test_only]
module nft_protocol::test_nft {
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::fake_witness::{Self, FakeWitness};
    use sui::transfer::transfer;
    use sui::object;
    use sui::test_scenario::{Self, ctx};

    struct Witness has drop {}

    struct Foo has drop {}

    struct DomainA has store {}

    const OWNER: address = @0xA1C05;
    const FAKE_OWNER: address = @0xA1C11;

    #[test]
    fun creates_nft() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::new<Foo, Witness>(&Witness {}, OWNER, ctx);

        assert!(nft::logical_owner(&nft) == OWNER, 0);

        transfer(nft, OWNER);
        test_scenario::end(scenario);
    }

    #[test]
    fun adds_domain() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::new(&Witness {}, OWNER, ctx);

        nft::add_domain(&mut nft, DomainA {}, ctx);

        // If domain does not exist this function call will fail
        nft::borrow_domain<Foo, DomainA>(&nft);

        transfer(nft, OWNER);

        test_scenario::end(scenario);
    }

    #[test]
    fun borrows_domain_mut() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::new(&Witness {}, OWNER, ctx);

        nft::add_domain(&mut nft, DomainA {}, ctx);

        nft::borrow_domain_mut<Foo, DomainA, Witness>(
            Witness {}, &mut nft
        );

        transfer(nft, OWNER);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370001, location = nft_protocol::nft)]
    fun fails_adding_duplicate_domain() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::new<Foo, Witness>(&Witness {}, OWNER, ctx);

        nft::add_domain(&mut nft, DomainA {}, ctx);

        // This second call will fail
        nft::add_domain(&mut nft, DomainA {}, ctx);

        transfer(nft, OWNER);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370002, location = nft_protocol::nft)]
    fun fails_adding_domain_if_not_owner() {
        let scenario = test_scenario::begin(OWNER);

        let nft_id = {
            let ctx = ctx(&mut scenario);

            let nft = nft::new<Foo, Witness>(&Witness {}, OWNER, ctx);

            let nft_id = object::id(&nft);

            transfer(nft, OWNER);
            nft_id
        };

        test_scenario::next_tx(&mut scenario, FAKE_OWNER);

        let nft = test_scenario::take_from_address_by_id<Nft<Foo>>(
            &scenario, OWNER, nft_id,
        );

        let ctx = ctx(&mut scenario);
        nft::add_domain(&mut nft, DomainA {}, ctx);

        transfer(nft, OWNER);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370600, location = nft_protocol::utils)]
    fun fails_borrowing_domain_mut_if_wrong_witness() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);


        let nft = nft::new(&Witness {}, OWNER, ctx);

        nft::add_domain(&mut nft, DomainA {}, ctx);

        nft::borrow_domain<Foo, DomainA>(&nft);


        nft::borrow_domain_mut<Foo, DomainA, FakeWitness>(
            fake_witness::new(), &mut nft
        );

        transfer(nft, OWNER);
        test_scenario::end(scenario);
    }
}
