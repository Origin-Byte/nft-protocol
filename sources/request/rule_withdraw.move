module nft_protocol::rule_withdraw {
    use std::type_name::{Self, TypeName};

    use sui::object::{Self, UID, ID};
    use sui::dynamic_field as df;

    use nft_protocol::request::{Self, RequestBody, WithNft};

    /// `WithdrawRule` metadata was not registered on `TransferRequest`
    const EUndefinedMetadata: u64 = 1;

    /// `WithdrawRule` metadata was already registered on `TransferRequest`
    const EExistingMetadata: u64 = 2;

    struct WithdrawRule has drop, store {
        /// NFT `ID` that was withdrawn
        nft_id: ID,
        /// Type of NFT that was withdrawn
        nft_type: TypeName,
        /// Address from which the NFT was withdrawn
        ///
        /// This can be an object `ID` converted into an `address` or a user pubkey.
        source: address,
        /// `TypeName` of authority that withdrew the NFT
        ///
        /// This must be an authority authorized to perform transactions on
        /// NFTs of `nft_type` by an `Allowlist`.
        authority: TypeName,
    }

    struct WithdrawKey has copy, drop, store {}

    public fun new<T: key, Auth: drop>(
        _auth: Auth,
        nft: &T,
        source: address,
    ): WithdrawRule {
        WithdrawRule {
            nft_id: object::id(nft),
            nft_type: type_name::get<T>(),
            source,
            authority: type_name::get<Auth>(),
        }
    }

    public fun borrow_nft_id(rule: &WithdrawRule): &ID {
        &rule.nft_id
    }

    public fun borrow_nft_type(rule: &WithdrawRule): &TypeName {
        &rule.nft_type
    }

    public fun borrow_source(rule: &WithdrawRule): &address {
        &rule.source
    }

    public fun borrow_authority(rule: &WithdrawRule): &TypeName {
        &rule.authority
    }

    // === Transfers ===

    /// Register `WithdrawRule` metadata on request
    public fun register_metadata<T, P>(
        req: &mut RequestBody<WithNft<T, P>>,
        rule: WithdrawRule,
    ) {
        let metadata = request::metadata_mut(req);
        add_metadata(metadata, rule)
    }

    /// Check whether `WithdrawRule` metadata is registered on object
    public fun contains_metadata(metadata: &UID): bool {
        df::exists_(metadata, WithdrawKey {})
    }

    /// Register `WithdrawRule` metadata on object
    public fun add_metadata(metadata: &mut UID, rule: WithdrawRule) {
        assert!(!contains_metadata(metadata), EExistingMetadata);
        df::add(metadata, WithdrawKey {}, rule)
    }

    /// Borrow `WithdrawRule` metadata from object
    public fun borrow_metadata(metadata: &UID): &WithdrawRule {
        assert_metadata(metadata);
        df::borrow(metadata, WithdrawKey {})
    }

    // === Assertions ===

    /// Assert `WithdrawRule` is registered on object
    public fun assert_metadata(metadata: &UID) {
        assert!(contains_metadata(metadata), EUndefinedMetadata)
    }
}
