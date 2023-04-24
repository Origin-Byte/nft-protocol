module nft_protocol::rule_deposit {
    use std::type_name::{Self, TypeName};

    use sui::object::{Self, UID, ID};
    use sui::dynamic_field as df;

    use nft_protocol::request::{Self, RequestBody, WithNft};
    use nft_protocol::rule_withdraw::{Self, WithdrawRule};

    /// `DepositRule` metadata was not registered on `TransferRequest`
    const EUndefinedMetadata: u64 = 1;

    /// `DepositRule` metadata was already registered on `TransferRequest`
    const EExistingMetadata: u64 = 2;

    /// `WithdrawRule` metadata did not match the `DepositRule` metadata
    const EInvalidWithdrawMetadata: u64 = 3;

    struct DepositRule has drop, store {
        /// NFT `ID` that was deposited
        nft_id: ID,
        /// Type of NFT that was deposited
        nft_type: TypeName,
        /// Address from which the NFT was deposited
        ///
        /// This can be an object `ID` converted into an `address` or a user pubkey.
        source: address,
        /// `TypeName` of authority that withdrew the NFT
        ///
        /// This must be an authority authorized to perform transactions on
        /// NFTs of `nft_type` by an `Allowlist`.
        authority: TypeName,
    }

    struct DepositKey has copy, drop, store {}

    public fun new<T: key, Auth: drop>(
        _auth: Auth,
        nft: &T,
        source: address,
    ): DepositRule {
        DepositRule {
            nft_id: object::id(nft),
            nft_type: type_name::get<T>(),
            source,
            authority: type_name::get<Auth>(),
        }
    }

    public fun borrow_nft_id(rule: &DepositRule): &ID {
        &rule.nft_id
    }

    public fun borrow_nft_type(rule: &DepositRule): &TypeName {
        &rule.nft_type
    }

    public fun borrow_source(rule: &DepositRule): &address {
        &rule.source
    }

    public fun borrow_authority(rule: &DepositRule): &TypeName {
        &rule.authority
    }

    // === Transfers ===

    /// Register `DepositRule` metadata on request
    public fun register_metadata<T, P>(
        req: &mut RequestBody<WithNft<T, P>>,
        rule: DepositRule,
    ) {
        let metadata = request::metadata_mut(req);
        add_metadata(metadata, rule)
    }

     /// Check whether `DepositRule` metadata is registered on object
    public fun contains_metadata(metadata: &UID): bool {
        df::exists_(metadata, DepositKey {})
    }

    /// Register `DepositRule` metadata on object
    public fun add_metadata(metadata: &mut UID, rule: DepositRule) {
        assert!(!contains_metadata(metadata), EExistingMetadata);
        df::add(metadata, DepositKey {}, rule)
    }

    /// Borrow `DepositRule` metadata from object
    public fun borrow_metadata(metadata: &UID): &DepositRule {
        assert_metadata(metadata);
        df::borrow(metadata, DepositKey {})
    }

    // === Assertions ===

    /// Assert matching `WithdrawRule`
    ///
    /// #### Panics
    ///
    /// Panics if matching `WithdrawRule` is not registered as metadata.
    public fun assert_matching_withdrawal<T, P>(
        withdraw_rule: &WithdrawRule,
        rule: &DepositRule,
    ) {
        assert!(
            rule_withdraw::borrow_nft_id(withdraw_rule) == &rule.nft_id,
            EInvalidWithdrawMetadata,
        );
        assert!(
            rule_withdraw::borrow_nft_type(withdraw_rule) == &rule.nft_type,
            EInvalidWithdrawMetadata,
        );
    }

    /// Assert `DepositRule` is registered on object
    public fun assert_metadata(metadata: &UID) {
        assert!(contains_metadata(metadata), EUndefinedMetadata)
    }
}
