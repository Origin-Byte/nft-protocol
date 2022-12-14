#[test_only]
module nft_protocol::test_display {
    use std::string;

    use sui::transfer::transfer;
    use sui::object;
    use sui::test_scenario::{Self, ctx};

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::display;
    use nft_protocol::fake_witness::{Self, FakeWitness};

    struct Witness has drop {}

    struct Foo has drop {}

    struct DomainA has store {}

    const OWNER: address = @0xA1C05;
    const FAKE_OWNER: address = @0xA1C11;

    #[test]
    fun add_display() {
        let scenario = test_scenario::begin(OWNER);
        let ctx = ctx(&mut scenario);

        let nft = nft::new<Foo>(OWNER, ctx);

        nft::add_domain(&mut nft, DomainA {}, ctx);

        let display = display::new_display_domain(
            string::utf8(b"Suimarines-234"),
            string::utf8(b"Collection of Suimarines"),
        );

        transfer(nft, OWNER);

        test_scenario::end(scenario);
    }
}
