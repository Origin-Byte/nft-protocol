/// Allowlists NFT transfers.
///
/// This module is a set of functions for implementing and managing a
/// allowlist for NFT (non-fungible token) transfers.
/// The allowlist is used to authorize which contracts are allowed to
/// transfer NFTs of a particular collection.
/// The module includes functions for creating and managing the allowlist,
/// adding and removing collections from the allowlist, and checking whether
/// a contract is authorized to transfer a particular NFT.
/// The module uses generics and reflection to allow for flexibility in
/// implementing and managing the allowlist.
///
/// Generics at play:
/// 1. Admin (allowlist witness) enables any organization to start their own
///     allowlist and manage it according to their own rules;
/// 2. Auth (3rd party witness) is used to authorize contracts via their
///     witness types. If e.g. an orderbook trading contract wants to be
///     included in a allowlist, the allowlist admin adds the stringified
///     version of their witness type. The OB then uses this witness type
///     to authorize transfers.
module nft_protocol::transfer_allowlist {
    use std::type_name;

    use sui::transfer_policy::{TransferPolicyCap, TransferPolicy};

    use request::request::{Self, RequestBody, Policy, PolicyCap, WithNft};
    use request::ob_kiosk;
    use request::ob_transfer_request::{Self, TransferRequest};

    use allowlist::allowlist::{Self, Allowlist};

    // === Errors ===

    /// Package publisher mismatch
    const EInvalidPublisher: u64 = 0;

    /// Invalid admin
    ///
    /// Create new `Allowlist` using `create` with desired admin.
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
    /// that only allowlisted contracts can transfer NFTs.
    ///
    /// Note that this rule depends on `ob_kiosk::get_transfer_request_auth`
    /// and only works with `ob_transfer_request::TransferRequest`.
    ///
    /// That's because the sui implementation of `TransferRequest` is simplified
    /// and does not support safe metadata about the originator of the transfer.
    struct AllowlistRule has drop {}

    // === Transfers ===

    /// Registers collection to use `Allowlist` during the transfer.
    public fun enforce<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
        ob_transfer_request::add_originbyte_rule<T, AllowlistRule, bool>(
            AllowlistRule {}, policy, cap, false,
        );
    }

    public fun drop<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
        ob_transfer_request::remove_originbyte_rule<T, AllowlistRule, bool>(
            policy, cap,
        );
    }

    public fun enforce_<T, P>(
        policy: &mut Policy<WithNft<T, P>>,
        cap: &PolicyCap,
    ) {
        request::enforce_rule_no_state<WithNft<T, P>, AllowlistRule>(
            policy, cap,
        );
    }

    public fun drop_<T, P>(
        policy: &mut Policy<WithNft<T, P>>,
        cap: &PolicyCap,
    ) {
        request::drop_rule_no_state<WithNft<T, P>, AllowlistRule>(policy, cap);
    }

    /// Confirms that the transfer is allowed by the `Allowlist`.
    /// It adds a signature to the request.
    /// In the end, if the allowlist rule is included in the transfer policy,
    /// the transfer request can only be finished if this rule is present.
    public fun confirm_transfer<T>(
        self: &Allowlist,
        req: &mut TransferRequest<T>,
    ) {
        let auth = ob_kiosk::get_transfer_request_auth(req);
        allowlist::assert_transferable(self, type_name::get<T>(), auth);
        ob_transfer_request::add_receipt(req, AllowlistRule {});
    }

    /// Confirms that the transfer is allowed by the `Allowlist`.
    /// It adds a signature to the request.
    /// In the end, if the allowlist rule is included in the transfer policy,
    /// the transfer request can only be finished if this rule is present.
    public fun confirm_transfer_<T, P>(
        self: &Allowlist,
        req: &mut RequestBody<WithNft<T, P>>,
    ) {
        let auth = ob_kiosk::get_transfer_request_auth_(req);
        allowlist::assert_transferable(self, type_name::get<T>(), auth);
        request::add_receipt(req, &AllowlistRule {});
    }
}
