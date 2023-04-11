// TODO: Functions to test:
// new
// create_for_sender
// new_permissionless
// set_permissionless_to_permissioned
// deposit
// auth_transfer
// auth_exclusive_transfer
// transfer_delegated
// transfer_signed
// withdraw_nft
// withdraw_nft_signed
// withdraw_nft_
// transfer_between_owned
// set_transfer_request_auth
// get_transfer_request_auth
// delist_nft_as_owner
// remove_auth_transfer_as_owner
// remove_auth_transfer
// restrict_deposits
// enable_any_deposit
// disable_deposits_of_collection
// enable_deposits_of_collection
// borrow_nft_field_mut
// borrow_nft_mut
// return_nft
// borrow
#[test_only]
module nft_protocol::test_ob_kiosk {
    use sui::test_scenario::{Self, ctx};
    use sui::kiosk::{Self, Kiosk};
    use sui::transfer;
    use sui::sui::SUI;
    use sui::object;
    use sui::table;
    // use std::debug;
    // use std::string;

    use nft_protocol::ob_transfer_request;
    use nft_protocol::ob_kiosk::{Self, OwnerToken};
    use nft_protocol::test_utils::{Self, Foo, seller, fake_address};

    #[test]
    public fun test_kiosk_new() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let kiosk = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Check honorary owner token
        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // Check NFT was transferred with correct logical owner
        // TODO: Maybe add test accessors to assert private fields
        let owner_token = test_scenario::take_from_address<OwnerToken>(
            &scenario, kiosk_owner
        );

        // 5. Make kiosk shared
        test_scenario::return_to_address(kiosk_owner, owner_token);
        test_scenario::end(scenario);
    }

    #[test]
    public fun test_kiosk_deposit() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let kiosk = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3.Deposit NFT
        let nft = test_utils::get_random_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        // 4. Check deposited NFT
        // Indirectly asserts that NftRef has been created, otherwise
        // this function call will fail
        ob_kiosk::assert_not_listed<Foo>(&mut kiosk, nft_id);
        ob_kiosk::assert_not_exclusively_listed<Foo>(&mut kiosk, nft_id);

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 5. Make kiosk shared
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft_protocol::ob_kiosk::ECannotDeposit)]
    public fun test_kiosk_permissioned_deposits() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let kiosk = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // Need to share in the same transaction, otherwise it errs
        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);
        ob_kiosk::restrict_deposits(&mut kiosk, ctx(&mut scenario));

        // 3. Fake Address tries to deposit NFT in kiosk - but fails
        test_scenario::next_tx(&mut scenario, fake_address());

        let nft = test_utils::get_random_nft(ctx(&mut scenario));
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        // 4. Return Kiosk shared
        test_scenario::return_shared(kiosk);
        test_scenario::end(scenario);
    }

    #[test]
    public fun test_kiosk_transfer_auth() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let kiosk = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_random_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 4. Insert a TransferAuth for an entity
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        let rand_entity = object::new(ctx(&mut scenario));
        ob_kiosk::auth_transfer(&mut kiosk, nft_id, object::uid_to_address(&rand_entity), ctx(&mut scenario));

        // 5. Assert listing
        ob_kiosk::assert_listed(&mut kiosk, nft_id);

        // 6. Create TransferPolicy
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));
        // 7. Assert NFT can be transferred..

        // Fetch empty TransferPolicy
        // Init Buyer's Kiosk
        let buyer_kiosk = ob_kiosk::new(ctx(&mut scenario));
        // Transfer NFT and get
        let request = ob_kiosk::transfer_delegated<Foo>(
            &mut kiosk,
            &mut buyer_kiosk,
            nft_id,
            &rand_entity,
            ctx(&mut scenario)
        );

        // Consumer the TransferReceipt<Foo>
        ob_transfer_request::set_nothing_paid(&mut request);
        ob_transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

        // 8. Return objects and end tx
        transfer::public_share_object(buyer_kiosk);
        transfer::public_share_object(tx_policy);
        transfer::public_transfer(publisher, seller());
        transfer::public_transfer(policy_cap, seller());
        object::delete(rand_entity);
        test_scenario::return_shared(kiosk);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft_protocol::ob_kiosk::ENotAuthorized)]
    public fun test_kiosk_transfer_without_auth() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let kiosk = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_random_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 6. Create TransferPolicy
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));
        // 7. Assert NFT cannot be transferred..

        // Fetch empty TransferPolicy
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);
        // Init Buyer's Kiosk
        let buyer_kiosk = ob_kiosk::new(ctx(&mut scenario));
        // Transfer NFT and get
        let rand_entity = object::new(ctx(&mut scenario));

        let request = ob_kiosk::transfer_delegated<Foo>(
            &mut kiosk,
            &mut buyer_kiosk,
            nft_id,
            &rand_entity,
            ctx(&mut scenario)
        );

        // Consumer the TransferReceipt<Foo>
        ob_transfer_request::set_nothing_paid(&mut request);
        ob_transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

        // 8. Return objects and end tx
        transfer::public_share_object(buyer_kiosk);
        transfer::public_share_object(tx_policy);
        transfer::public_transfer(publisher, seller());
        transfer::public_transfer(policy_cap, seller());
        object::delete(rand_entity);
        test_scenario::return_shared(kiosk);

        test_scenario::end(scenario);
    }

    fun check_new_kiosk(kiosk: &mut Kiosk, kiosk_owner: address) {
        // 1. Check all static fields
        assert!(kiosk::owner(kiosk) == kiosk_owner, 0);
        assert!(kiosk::item_count(kiosk) == 0, 0);
        assert!(kiosk::profits_amount(kiosk) == 0, 0);
        // Checks that `allow_extensions == true`
        kiosk::uid_mut(kiosk);

        // 2. Check all dynamic fields
        assert!(table::is_empty(ob_kiosk::nft_refs(kiosk)), 0);
        ob_kiosk::assert_kiosk_owner_cap(kiosk);
        ob_kiosk::assert_deposit_setting_permissionless(kiosk);
    }
}
