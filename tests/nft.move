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
    use nft_protocol::fake_witness::{Self, FakeWitness};
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::utils;

    use sui::object::{Self, UID};
    use sui::test_scenario::{Self, ctx};
    use sui::transfer::transfer;

    struct Foo has drop {}
    struct Witness has drop {}

    struct DomainA has key, store {
        id: UID
    }

    const OWNER: address = @0xA1C05;
    const FAKE_OWNER: address = @0xA1C11;

    #[test]
    fun creates_nft() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::test_mint<Foo>(OWNER, ctx);

        assert!(nft::logical_owner(&nft) == OWNER, 0);

        transfer(nft, OWNER);
        test_scenario::end(scenario);
    }

    #[test]
    fun adds_domain() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::test_mint<Foo>(OWNER, ctx);

        nft::add_domain(
            &Witness {},
            &mut nft,
            DomainA { id: object::new(ctx) },
        );

        // If domain does not exist this function call will fail
        nft::borrow_domain<Foo, DomainA>(&nft);

        transfer(nft, OWNER);
        test_scenario::end(scenario);
    }

    #[test]
    fun borrows_domain_mut() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::test_mint<Foo>(OWNER, ctx);

        nft::add_domain(
            &Witness {},
            &mut nft,
            DomainA { id: object::new(ctx) },
        );

        nft::borrow_domain_mut<Foo, DomainA, Witness>(
            Witness {}, &mut nft
        );

        transfer(nft, OWNER);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft::EEXISTING_DOMAIN)]
    fun fails_adding_duplicate_domain() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::test_mint<Foo>(OWNER, ctx);

        nft::add_domain(
            &Witness {},
            &mut nft,
            DomainA { id: object::new(ctx) },
        );

        // This second call will fail
        nft::add_domain(
            &Witness {},
            &mut nft,
            DomainA { id: object::new(ctx) },
        );

        transfer(nft, OWNER);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 13370600, location = nft_protocol::utils)]
    fun fails_borrowing_domain_mut_if_wrong_witness() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::test_mint<Foo>(OWNER, ctx);

        nft::add_domain(
            &Witness {},
            &mut nft,
            DomainA { id: object::new(ctx) },
        );

        nft::borrow_domain<Foo, DomainA>(&nft);
        nft::borrow_domain_mut<Foo, DomainA, FakeWitness>(
            fake_witness::new(), &mut nft
        );

        transfer(nft, OWNER);
        test_scenario::end(scenario);
    }

    #[test]
    fun it_recognizes_nft_type() {
        assert!(utils::is_nft_protocol_nft_type<Nft<sui::object::ID>>(), 0);
        assert!(!utils::is_nft_protocol_nft_type<sui::object::ID>(), 1);
        assert!(!utils::is_nft_protocol_nft_type<utils::Marker<sui::object::ID>>(), 2);
        assert!(!utils::is_nft_protocol_nft_type<nft::MintNftEvent>(), 2);
    }
}
