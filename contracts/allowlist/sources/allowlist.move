module allowlist::allowlist {
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::bidding;
    use nft_protocol::orderbook;
    use nft_protocol::transfer_allowlist;
    use nft_protocol::ob_kiosk;

    struct ALLOWLIST has drop {}

    fun init(_otw: ALLOWLIST, ctx: &mut TxContext) {
        let (al, al_cap) = transfer_allowlist::new(ctx);

        // OB Kiosk is a trusted type for receiving NFTs
        transfer_allowlist::insert_authority<ob_kiosk::Witness>(&al_cap, &mut al);
        transfer_allowlist::insert_authority<orderbook::Witness>(&al_cap, &mut al);
        transfer_allowlist::insert_authority<bidding::Witness>(&al_cap, &mut al);

        // Delete `AllowlistOwnerCap` to guarantee that each release of
        // `OriginByte` always has a fixed set of trading contracts
        transfer::public_transfer(al_cap, tx_context::sender(ctx));
        transfer::public_share_object(al);
    }

    #[test_only]
    use sui::object::{Self, UID};
    #[test_only]
    use sui::test_scenario::{Self, ctx};

    #[test_only]
    use nft_protocol::ob_transfer_request;

    #[test_only]
    const USER: address = @0xA1C04;

    #[test_only]
    struct Foo has key, store {
        id: UID,
    }

    #[test_only]
    struct FOO {}

    #[test]
    fun test_peer_to_peer_flow() {
        let scenario = test_scenario::begin(USER);

        init(ALLOWLIST {}, ctx(&mut scenario));

        let (policy, cap) =
            ob_transfer_request::init_policy<Foo>(publisher, ctx);
    }

    #[test]
    fun test_bidding_flow() {

    }
}
