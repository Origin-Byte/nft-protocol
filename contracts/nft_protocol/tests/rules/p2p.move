#[test_only]
module nft_protocol::test_p2p {
    use std::vector;

    use sui::sui::SUI;
    use sui::object::{Self, UID};
    use sui::tx_context;
    use sui::package;
    use sui::transfer;
    use sui::test_scenario::{Self, ctx};

    use ob_authlist::authlist::{Self, Authlist};

    use ob_request::transfer_request;

    use ob_kiosk::ob_kiosk;

    use nft_protocol::p2p_list;
    use nft_protocol::nft_protocol;

    const CREATOR: address = @0xA1C04;
    const USER: address = @0xA1C067;

    struct Foo has key, store {
        id: UID,
    }

    struct TEST_P2P has drop {}

    #[lint_allow(share_owned)]
    #[test]
    fun enforce_policy() {
        let scenario = test_scenario::begin(CREATOR);

        let publisher = package::claim(TEST_P2P {}, ctx(&mut scenario));

        let (policy, policy_cap) = transfer_request::init_policy<Foo>(
            &publisher, ctx(&mut scenario),
        );

        p2p_list::enforce(&mut policy, &policy_cap);

        transfer::public_transfer(publisher, CREATOR);
        transfer::public_transfer(policy_cap, CREATOR);
        transfer::public_share_object(policy);
        test_scenario::end(scenario);
    }

    #[lint_allow(share_owned)]
    #[test]
    fun transfer() {
        let scenario = test_scenario::begin(CREATOR);

        nft_protocol::init_authlist(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, CREATOR);

        // Setup policy
        let publisher = package::claim(TEST_P2P {}, ctx(&mut scenario));
        let (policy, policy_cap) = transfer_request::init_policy<Foo>(
            &publisher, ctx(&mut scenario),
        );
        p2p_list::enforce(&mut policy, &policy_cap);

        // Setup authlist
        let authlist = test_scenario::take_shared<Authlist>(&scenario);
        authlist::insert_collection<Foo>(&mut authlist, &publisher);

        let (kiosk_0, _) = ob_kiosk::new(ctx(&mut scenario));
        let (kiosk_1, _) = ob_kiosk::new_for_address(USER, ctx(&mut scenario));

        // We are relying on determinism of generated IDs
        let nft = Foo { id: object::new(&mut tx_context::dummy()) };
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk_0, nft, ctx(&mut scenario));

        // Generate signature
        //
        // Signature must sign the following concatenation of properties:
        // `nft_id | source | destination | tx_context::epoch`
        // `0x381dd9078c322a4663c392761a0211b527c127b29583851217f948d62131f409 | CREATOR | USER | 0`

        let p1 = @0xebcfa82c9c20e26c7eb351ca183964baea1cccd8b32271724cf5a145232395b2;
        let p2 = @0x730897eaf91af6724231728ba85fc5a92d681b6962d3fe89b7726584c991b108;

        let signature = vector::empty();
        vector::append(&mut signature, authlist::address_to_bytes(p1));
        vector::append(&mut signature, authlist::address_to_bytes(p2));

        // Try trade P2P
        let request = p2p_list::transfer(
            &authlist,
            &authlist::address_to_bytes(
                nft_protocol::permissionless_public_key(),
            ),
            nft_id,
            &mut kiosk_0,
            &mut kiosk_1,
            &signature,
            vector::empty(), // Use empty nonce to sign permissionless
            ctx(&mut scenario),
        );

        transfer_request::confirm<Foo, SUI>(
            request, &policy, ctx(&mut scenario),
        );

        transfer::public_transfer(publisher, CREATOR);
        transfer::public_transfer(policy_cap, CREATOR);
        transfer::public_share_object(policy);
        transfer::public_share_object(kiosk_0);
        transfer::public_share_object(kiosk_1);
        test_scenario::return_shared(authlist);
        test_scenario::end(scenario);
    }
}
