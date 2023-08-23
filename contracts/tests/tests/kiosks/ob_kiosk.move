// TODO: Functions to test:
// Use transfer_signed with Owner/Random signer to work/fail
// Try to withdraw NFT and work/fail with user and entity
// transfer_between_owned
// fails transfer_between_owned if no owner

// delist_nft_as_owner
// fails to call delist_nft_as_owner if exclusively listed

// set_transfer_request_auth
// get_transfer_request_auth
// remove_auth_transfer_as_owner
// remove_auth_transfer

// Test calling restrict_deposits and enable_any_deposit back and forth


// disable_deposits_of_collection
// enable_deposits_of_collection
// borrow_nft_field_mut
// borrow_nft_mut
// return_nft
// borrow
#[test_only]
module ob_tests::test_ob_kiosk {
    use std::option;
    use sui::test_scenario::{Self, ctx};
    use sui::kiosk::{Self, Kiosk};
    use sui::transfer;
    use sui::sui::SUI;
    use sui::object;
    use sui::table;
    use sui::tx_context;

    use ob_request::transfer_request;
    use ob_request::withdraw_request;
    use ob_kiosk::ob_kiosk::{Self, OwnerToken};

    use ob_tests::test_utils::{Self, Foo, seller, buyer, fake_address, creator};

    #[test]
    public fun test_kiosk_new() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

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
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3.Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        // 4. Check deposited NFT
        // Indirectly asserts that NftRef has been created, otherwise
        // this function call will fail
        ob_kiosk::assert_not_listed(&mut kiosk, nft_id);
        ob_kiosk::assert_not_exclusively_listed(&mut kiosk, nft_id);

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 5. Make kiosk shared
        test_scenario::end(scenario);
    }

    #[test]
    public fun test_p2p_tranfer() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (source_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut source_kiosk, kiosk_owner);

        // 3.Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut source_kiosk, nft, ctx(&mut scenario));

        // 4. Check deposited NFT
        // Indirectly asserts that NftRef has been created, otherwise
        // this function call will fail
        ob_kiosk::assert_not_listed(&mut source_kiosk, nft_id);
        ob_kiosk::assert_not_exclusively_listed(&mut source_kiosk, nft_id);

        // 5. P2P Transfer
        let (target_kiosk, _) = ob_kiosk::new_for_address(buyer(), ctx(&mut scenario));
        // This is a helper for testing the entry function `p2p_transfer`
        ob_kiosk::p2p_transfer_test<Foo>(&mut source_kiosk, &mut target_kiosk, nft_id, ctx(&mut scenario));

        // 6. Assert that NFT has been sent
        ob_kiosk::assert_has_nft(&target_kiosk, nft_id);

        transfer::public_share_object(source_kiosk);
        transfer::public_share_object(target_kiosk);
        test_scenario::end(scenario);
    }

    #[test]
    public fun test_p2p_tranfer_in_new_kiosk() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (source_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut source_kiosk, kiosk_owner);

        // 3.Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut source_kiosk, nft, ctx(&mut scenario));

        // 4. Check deposited NFT
        // Indirectly asserts that NftRef has been created, otherwise
        // this function call will fail
        ob_kiosk::assert_not_listed(&mut source_kiosk, nft_id);
        ob_kiosk::assert_not_exclusively_listed(&mut source_kiosk, nft_id);

        transfer::public_share_object(source_kiosk);
        test_scenario::next_tx(&mut scenario, seller());
        let source_kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        // 5. P2P Transfer
        // This is a helper for testing the entry function `p2p_transfer`
        ob_kiosk::p2p_transfer_and_create_target_kiosk_test<Foo>(&mut source_kiosk, buyer(), nft_id, ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, buyer());
        let target_kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        // 6. Assert that NFT has been sent
        ob_kiosk::assert_has_nft(&target_kiosk, nft_id);

        test_scenario::return_shared(target_kiosk);
        test_scenario::return_shared(source_kiosk);
        test_scenario::end(scenario);
    }

    #[test]
    public fun test_kiosk_deposit_other_than_owner() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        transfer::public_share_object(kiosk);

        // 3.Deposit NFT
        test_scenario::next_tx(&mut scenario, creator());
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        // 4. Check deposited NFT
        // Indirectly asserts that NftRef has been created, otherwise
        // this function call will fail
        ob_kiosk::assert_not_listed(&mut kiosk, nft_id);
        ob_kiosk::assert_not_exclusively_listed(&mut kiosk, nft_id);

        // 5. Return kiosk shared
        test_scenario::return_shared(kiosk);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_kiosk::ob_kiosk::ECannotDeposit)]
    public fun test_kiosk_fail_permissioned_deposits() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // Need to share in the same transaction, otherwise it errs
        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);
        ob_kiosk::restrict_deposits(&mut kiosk, ctx(&mut scenario));

        // 3. Fake Address tries to deposit NFT in kiosk - but fails
        test_scenario::next_tx(&mut scenario, fake_address());

        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        // 4. Return Kiosk shared
        test_scenario::return_shared(kiosk);
        test_scenario::end(scenario);
    }

    #[test]
    public fun test_kiosk_transfer_auth_as_entity() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
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
        // Init Buyer's Kiosk
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
        // Transfer NFT and get
        let request = ob_kiosk::transfer_delegated_unlocked<Foo>(
            &mut kiosk,
            &mut buyer_kiosk,
            nft_id,
            &rand_entity,
            0,
            option::none(),
            ctx(&mut scenario)
        );

        // Consumer the TransferReceipt<Foo>
        transfer_request::set_nothing_paid(&mut request);
        transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

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
    public fun test_kiosk_exclusive_transfer_auth_as_entity() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 4. Insert a TransferAuth for an entity
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        let rand_entity = object::new(ctx(&mut scenario));
        ob_kiosk::auth_exclusive_transfer(&mut kiosk, nft_id, &rand_entity, ctx(&mut scenario));

        // 5. Assert listing
        ob_kiosk::assert_exclusively_listed(&mut kiosk, nft_id);

        // 6. Create TransferPolicy
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        // 7. Assert NFT can be transferred..
        // Init Buyer's Kiosk
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
        // Transfer NFT and get
        let request = ob_kiosk::transfer_delegated_unlocked<Foo>(
            &mut kiosk,
            &mut buyer_kiosk,
            nft_id,
            &rand_entity,
            0,
            option::none(),
            ctx(&mut scenario)
        );

        // Consumer the TransferReceipt<Foo>
        transfer_request::set_nothing_paid(&mut request);
        transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

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
    #[expected_failure(abort_code = ob_kiosk::ob_kiosk::ENotAuthorized)]
    public fun test_kiosk_fail_transfer_without_auth_as_entity() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 6. Create TransferPolicy
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 7. Assert NFT cannot be transferred..
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        // Init TransferPolicy
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        // Init Buyer's Kiosk
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));
        // Transfer NFT and get
        let rand_entity = object::new(ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, fake_address());

        let request = ob_kiosk::transfer_delegated_unlocked<Foo>(
            &mut kiosk,
            &mut buyer_kiosk,
            nft_id,
            &rand_entity,
            0,
            option::none(),
            ctx(&mut scenario)
        );

        // Consumer the TransferReceipt<Foo>
        transfer_request::set_nothing_paid(&mut request);
        transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

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
    #[expected_failure(abort_code = ob_kiosk::ob_kiosk::ENftAlreadyExclusivelyListed)]
    public fun test_kiosk_fail_list_after_exclusive() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 4. Insert a TransferAuth for an entity
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        let rand_entity = object::new(ctx(&mut scenario));
        ob_kiosk::auth_exclusive_transfer(&mut kiosk, nft_id, &rand_entity, ctx(&mut scenario));

        // 5. Assert listing
        ob_kiosk::assert_exclusively_listed(&mut kiosk, nft_id);

        // 6. Create TransferPolicy
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        let rand_entity_2 = object::new(ctx(&mut scenario));
        ob_kiosk::auth_transfer(&mut kiosk, nft_id, object::uid_to_address(&rand_entity_2), ctx(&mut scenario));

        // 5. Assert listing
        ob_kiosk::assert_listed(&mut kiosk, nft_id);

        // 8. Return objects and end tx
        object::delete(rand_entity);
        object::delete(rand_entity_2);
        test_scenario::return_shared(kiosk);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_kiosk::ob_kiosk::ENftAlreadyExclusivelyListed)]
    public fun test_kiosk_fail_try_to_list_exclusive_twice() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 4. Insert a TransferAuth for an entity
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        let rand_entity = object::new(ctx(&mut scenario));
        ob_kiosk::auth_exclusive_transfer(&mut kiosk, nft_id, &rand_entity, ctx(&mut scenario));

        // 5. Assert listing
        ob_kiosk::assert_exclusively_listed(&mut kiosk, nft_id);

        // 6. Create TransferPolicy
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        let rand_entity_2 = object::new(ctx(&mut scenario));
        ob_kiosk::auth_exclusive_transfer(&mut kiosk, nft_id, &rand_entity_2, ctx(&mut scenario));

        // 5. Assert listing
        ob_kiosk::assert_listed(&mut kiosk, nft_id);

        // 8. Return objects and end tx
        object::delete(rand_entity);
        object::delete(rand_entity_2);
        test_scenario::return_shared(kiosk);

        test_scenario::end(scenario);
    }

    #[test]
    public fun test_kiosk_transfer_signed_as_owner() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 4. Create TransferPolicy
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        // 5. Assert NFT can be transferred..

        // Init Buyer's Kiosk
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // Transfer NFT and get
        let request = ob_kiosk::transfer_signed_unlocked(
            &mut kiosk,
            &mut buyer_kiosk,
            nft_id,
            0,
            option::none(),
            ctx(&mut scenario)
        );

        // Consumer the TransferReceipt<Foo>
        transfer_request::set_nothing_paid(&mut request);
        transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

        // 6. Return objects and end tx
        transfer::public_share_object(buyer_kiosk);
        transfer::public_share_object(tx_policy);
        transfer::public_transfer(publisher, seller());
        transfer::public_transfer(policy_cap, seller());
        test_scenario::return_shared(kiosk);

        test_scenario::end(scenario);
    }

    #[test]
    public fun test_kiosk_transfer_signed_as_auth_address() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 4. Insert a TransferAuth for an authorised address other than owner
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        let authorised_address: address = @0xA2C99;
        ob_kiosk::auth_transfer(&mut kiosk, nft_id, authorised_address, ctx(&mut scenario));

        // 5. Assert listing
        ob_kiosk::assert_listed(&mut kiosk, nft_id);

        // 6. Create TransferPolicy
        test_scenario::next_tx(&mut scenario, authorised_address);

        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        // 7. Assert NFT can be transferred..

        // Init Buyer's Kiosk
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // Asserting that sender is effectively the authorised_address and not the owner
        assert!(tx_context::sender(ctx(&mut scenario)) == authorised_address, 0);

        // Transfer NFT and get
        let request = ob_kiosk::transfer_signed_unlocked(
            &mut kiosk,
            &mut buyer_kiosk,
            nft_id,
            0,
            option::none(),
            ctx(&mut scenario)
        );

        // Consumer the TransferReceipt<Foo>
        transfer_request::set_nothing_paid(&mut request);
        transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

        // 8. Return objects and end tx
        transfer::public_share_object(buyer_kiosk);
        transfer::public_share_object(tx_policy);
        transfer::public_transfer(publisher, seller());
        transfer::public_transfer(policy_cap, seller());
        test_scenario::return_shared(kiosk);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_kiosk::ob_kiosk::ENotAuthorized)]
    public fun test_kiosk_fail_transfer_signed_as_unauth_address() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 4. Insert a TransferAuth for an authorised address other than owner
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        let unauthorised_address: address = @0xA2C99;

        // 5. Create TransferPolicy
        test_scenario::next_tx(&mut scenario, unauthorised_address);

        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_transfer_policy(&publisher, ctx(&mut scenario));

        // 6. Assert NFT can be transferred..

        // Init Buyer's Kiosk
        let (buyer_kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // Asserting that sender is effectively the authorised_address and not the owner
        assert!(tx_context::sender(ctx(&mut scenario)) == unauthorised_address, 0);

        // Transfer NFT and get
        let request = ob_kiosk::transfer_signed_unlocked(
            &mut kiosk,
            &mut buyer_kiosk,
            nft_id,
            0,
            option::none(),
            ctx(&mut scenario)
        );

        // Consumer the TransferReceipt<Foo>
        transfer_request::set_nothing_paid(&mut request);
        transfer_request::confirm<Foo, SUI>(request, &tx_policy, ctx(&mut scenario));

        // 7. Return objects and end tx
        transfer::public_share_object(buyer_kiosk);
        transfer::public_share_object(tx_policy);
        transfer::public_transfer(publisher, seller());
        transfer::public_transfer(policy_cap, seller());
        test_scenario::return_shared(kiosk);

        test_scenario::end(scenario);
    }

    #[test]
    public fun test_kiosk_withdraw_as_owner() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 4. Create TransferPolicy
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);
        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_withdrawable_policy(&publisher, ctx(&mut scenario));

        // Get NFT
        let (nft, request) = ob_kiosk::withdraw_nft_signed<Foo>(
            &mut kiosk,
            nft_id,
            ctx(&mut scenario)
        );

        // Consumer the WithdrawRequest
        withdraw_request::confirm<Foo>(request, &tx_policy);

        // 6. Return objects and end tx
        transfer::public_transfer(nft, seller());
        transfer::public_share_object(tx_policy);
        transfer::public_transfer(publisher, seller());
        transfer::public_transfer(policy_cap, seller());
        test_scenario::return_shared(kiosk);

        test_scenario::end(scenario);
    }


    #[test]
    public fun test_kiosk_withdraw_as_auth_address() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 4. Insert a TransferAuth for an authorised address other than owner
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        let authorised_address: address = @0xA2C99;
        ob_kiosk::auth_transfer(&mut kiosk, nft_id, authorised_address, ctx(&mut scenario));

        // 5. Assert listing
        ob_kiosk::assert_listed(&mut kiosk, nft_id);

        // 6. Create TransferPolicy
        test_scenario::next_tx(&mut scenario, authorised_address);

        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_withdrawable_policy(&publisher, ctx(&mut scenario));

        // Asserting that sender is effectively the authorised_address and not the owner
        assert!(tx_context::sender(ctx(&mut scenario)) == authorised_address, 0);

        // Get NFT
        let (nft, request) = ob_kiosk::withdraw_nft_signed<Foo>(
            &mut kiosk,
            nft_id,
            ctx(&mut scenario)
        );

        // Consumer the TransferReceipt<Foo>
        withdraw_request::confirm<Foo>(request, &tx_policy);

        // 8. Return objects and end tx
        transfer::public_transfer(nft, seller());
        transfer::public_share_object(tx_policy);
        transfer::public_transfer(publisher, seller());
        transfer::public_transfer(policy_cap, seller());
        test_scenario::return_shared(kiosk);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_kiosk::ob_kiosk::ENotAuthorized)]
    public fun test_kiosk_fail_withdraw_as_unauth_address() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 4. Insert a TransferAuth for an authorised address other than owner
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        let unauthorised_address: address = @0xA2C99;

        // 5. Create TransferPolicy
        test_scenario::next_tx(&mut scenario, unauthorised_address);

        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_withdrawable_policy(&publisher, ctx(&mut scenario));

        // 6. Assert NFT cannot be withdrawn..

        // Asserting that sender is effectively the authorised_address and not the owner
        assert!(tx_context::sender(ctx(&mut scenario)) == unauthorised_address, 0);

        // Try getting NFT but failing
        let (nft, request) = ob_kiosk::withdraw_nft_signed<Foo>(
            &mut kiosk,
            nft_id,
            ctx(&mut scenario)
        );

        // Consumer the TransferReceipt<Foo>
        withdraw_request::confirm<Foo>(request, &tx_policy);

        // 7. Return objects and end tx
        transfer::public_transfer(nft, seller());
        transfer::public_share_object(tx_policy);
        transfer::public_transfer(publisher, seller());
        transfer::public_transfer(policy_cap, seller());
        test_scenario::return_shared(kiosk);

        test_scenario::end(scenario);
    }

    #[test]
    public fun test_kiosk_withdraw_as_auth_entity() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 4. Insert a TransferAuth for an authorised address other than owner
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        let rand_entity = object::new(ctx(&mut scenario));
        ob_kiosk::auth_transfer(&mut kiosk, nft_id, object::uid_to_address(&rand_entity), ctx(&mut scenario));

        // 5. Assert listing
        ob_kiosk::assert_listed(&mut kiosk, nft_id);

        // 6. Create TransferPolicy
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_withdrawable_policy(&publisher, ctx(&mut scenario));

        // 7. Get NFT
        let (nft, request) = ob_kiosk::withdraw_nft<Foo>(
            &mut kiosk,
            nft_id,
            &rand_entity,
            ctx(&mut scenario)
        );

        // Consumer the TransferReceipt<Foo>
        withdraw_request::confirm<Foo>(request, &tx_policy);

        // 8. Return objects and end tx
        transfer::public_transfer(nft, seller());
        transfer::public_share_object(tx_policy);
        transfer::public_transfer(publisher, seller());
        transfer::public_transfer(policy_cap, seller());
        test_scenario::return_shared(kiosk);
        object::delete(rand_entity);

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_kiosk::ob_kiosk::ENotAuthorized)]
    public fun test_kiosk_withdraw_as_unauth_entity() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        let (kiosk, _) = ob_kiosk::new(ctx(&mut scenario));

        // 2. Checks Kiosk's static and dynamic fields after creation
        check_new_kiosk(&mut kiosk, kiosk_owner);

        // 3. Deposit NFT
        let nft = test_utils::get_foo_nft(ctx(&mut scenario));
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(&mut kiosk, nft, ctx(&mut scenario));

        transfer::public_share_object(kiosk);
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 4. Insert a TransferAuth for an authorised address other than owner
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);

        let rand_entity = object::new(ctx(&mut scenario));

        // 5. Create TransferPolicy
        test_scenario::next_tx(&mut scenario, fake_address());

        let publisher = test_utils::get_publisher(ctx(&mut scenario));
        let (tx_policy, policy_cap) = test_utils::init_withdrawable_policy(&publisher, ctx(&mut scenario));

        // 6. Get NFT
        let (nft, request) = ob_kiosk::withdraw_nft<Foo>(
            &mut kiosk,
            nft_id,
            &rand_entity,
            ctx(&mut scenario)
        );

        // Consumer the TransferReceipt<Foo>
        withdraw_request::confirm<Foo>(request, &tx_policy);

        // 7. Return objects and end tx
        transfer::public_transfer(nft, seller());
        transfer::public_share_object(tx_policy);
        transfer::public_transfer(publisher, seller());
        transfer::public_transfer(policy_cap, seller());
        test_scenario::return_shared(kiosk);
        object::delete(rand_entity);

        test_scenario::end(scenario);
    }

    #[test]
    public fun test_kiosk_new_permissionless() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        // 1. Create kiosk
        ob_kiosk::create_permissionless(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        // 2. Checks Kiosk's static and dynamic fields after creation
        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);
        check_new_kiosk(&mut kiosk, @0xb);

        // 3. Checks `OwnerToken` was not created
        assert!(!test_scenario::has_most_recent_immutable<OwnerToken>(), 0);

        test_scenario::return_shared(kiosk);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = ob_kiosk::ob_kiosk::EKioskNotPermissionless)]
    public fun test_try_permissionless_to_permissioned() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        ob_kiosk::create_for_sender(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);
        ob_kiosk::set_permissionless_to_permissioned(
            &mut kiosk, creator(), ctx(&mut scenario),
        );

        check_new_kiosk(&mut kiosk, creator());

        test_scenario::return_shared(kiosk);
        test_scenario::end(scenario);
    }

    #[test]
    public fun test_permissionless_to_permissioned() {
        let kiosk_owner = seller();
        let scenario = test_scenario::begin(kiosk_owner);

        ob_kiosk::create_permissionless(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, kiosk_owner);

        let kiosk = test_scenario::take_shared<Kiosk>(&scenario);
        ob_kiosk::set_permissionless_to_permissioned(
            &mut kiosk, creator(), ctx(&mut scenario),
        );

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
