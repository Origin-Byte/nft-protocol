/// P2PLists NFT transfers.
///
/// This module is a set of functions for implementing and managing a
/// AuthList for NFT (non-fungible token) transfers.
/// The AuthList is used to authorize which contracts are allowed to
/// transfer NFTs of a particular collection.
/// The module includes functions for creating and managing the AuthList,
/// adding and removing collections from the AuthList, and checking whether
/// a contract is authorized to transfer a particular NFT.
/// The module uses generics and reflection to allow for flexibility in
/// implementing and managing the AuthList.
///
/// Generics at play:
/// 1. Admin (AuthList witness) enables any organization to start their own
///     AuthList and manage it according to their own rules;
/// 2. Auth (3rd party witness) is used to authorize contracts via their
///     witness types. If e.g. an orderbook trading contract wants to be
///     included in a AuthList, the AuthList admin adds the stringified
///     version of their witness type. The OB then uses this witness type
///     to authorize transfers.
module nft_protocol::p2p_list {
    use std::vector;

    use sui::bcs;
    use sui::transfer_policy::{TransferPolicy, TransferPolicyCap};

    use nft_protocol::authlist::{Self, AuthList};
    use nft_protocol::request::{Self, RequestBody, Policy, PolicyCap, WithNft};
    use nft_protocol::ob_kiosk;
    use nft_protocol::ob_transfer_request::{Self, TransferRequest};

    // === Errors ===

    /// Package publisher mismatch
    const EPackagePublisherMismatch: u64 = 0;

    /// Invalid admin
    ///
    /// Create new `AuthList` using `create` with desired admin.
    const EInvalidAdmin: u64 = 1;

    /// Invalid collection
    ///
    /// Call `insert_collection` to insert a collection.
    const EInvalidCollection: u64 = 2;

    /// Collection was already registered
    const EExistingCollection: u64 = 3;

    /// Invalid transfer authority
    ///
    /// Call `insert_authority` to insert an authority.
    const EInvalidAuthority: u64 = 4;

    /// Transfer authority was already registered
    const EExistingAuthority: u64 = 5;

    // === Structs ===

    /// `sui::transfer_policy::TransferPolicy` can have this rule to enforce
    /// that only P2PListed contracts can transfer NFTs.
    ///
    /// Note that this rule depends on `ob_kiosk::get_transfer_request_auth`
    /// and only works with `ob_transfer_request::TransferRequest`.
    ///
    /// That's because the sui implementation of `TransferRequest` is simplified
    /// and does not support safe metadata about the originator of the transfer.
    struct P2PListRule has drop {}

    // === Transfers ===

    /// Registers collection to use `AuthList` during the transfer.
    public fun enforce<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
        ob_transfer_request::add_originbyte_rule<T, P2PListRule, bool>(
            P2PListRule {}, policy, cap, false,
        );
    }

    public fun drop<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
        ob_transfer_request::remove_originbyte_rule<T, P2PListRule, bool>(
            policy, cap,
        );
    }

    public fun enforce_<T, P>(
        policy: &mut Policy<WithNft<T, P>>,
        cap: &PolicyCap,
    ) {
        request::enforce_rule_no_state<WithNft<T, P>, P2PListRule>(
            policy, cap,
        );
    }

    public fun drop_<T, P>(
        policy: &mut Policy<WithNft<T, P>>,
        cap: &PolicyCap,
    ) {
        request::drop_rule_no_state<WithNft<T, P>, P2PListRule>(policy, cap);
    }

    /// Confirms that the transfer is allowed by the `AuthList`.
    /// It adds a signature to the request.
    /// In the end, if the AuthList rule is included in the transfer policy,
    /// the transfer request can only be finished if this rule is present.
    public fun confirm_transfer<T>(
        self: &AuthList,
        req: &mut TransferRequest<T>,
        authority: &vector<u8>,
        nonce: vector<u8>,
        signature: &vector<u8>,
    ) {
        let _auth = ob_kiosk::get_transfer_request_auth(req);
        let source = @0xAAAA;
        let destination = @0xAAAA;
        confirm_<T>(self, authority, source, destination, nonce, signature);
        ob_transfer_request::add_receipt(req, P2PListRule {});
    }

    /// Confirms that the transfer is allowed by the `AuthList`.
    /// It adds a signature to the request.
    /// In the end, if the AuthList rule is included in the transfer policy,
    /// the transfer request can only be finished if this rule is present.
    public fun confirm_transfer_<T, P>(
        self: &AuthList,
        req: &mut RequestBody<WithNft<T, P>>,
        authority: &vector<u8>,
        nonce: vector<u8>,
        signature: &vector<u8>,
    ) {
        let _auth = ob_kiosk::get_transfer_request_auth_(req);
        let source = @0xAAAA;
        let destination = @0xAAAA;
        confirm_<T>(self, authority, source, destination, nonce, signature);
        request::add_receipt(req, &P2PListRule {});
    }

    fun confirm_<T>(
        self: &AuthList,
        authority: &vector<u8>,
        source: address,
        destination: address,
        nonce: vector<u8>,
        signature: &vector<u8>,
    ) {
        let msg = vector::empty();
        vector::append(&mut msg, bcs::to_bytes(&source));
        vector::append(&mut msg, bcs::to_bytes(&destination));
        vector::append(&mut msg, nonce);

        authlist::assert_transferable<T>(self, authority, &msg, signature);
    }
}
