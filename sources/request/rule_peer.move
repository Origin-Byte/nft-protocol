/// Module implements peer to peer transactions via `Authlist`
module nft_protocol::rule_peer {
    use nft_protocol::transfer_allowlist;
    use nft_protocol::request::{Self, RequestBody, Policy, PolicyCap, WithNft};
    use nft_protocol::ob_transfer_request::{Self, TransferRequest};
    use nft_protocol::authlist::Authlist;
    use nft_protocol::rule_deposit;
    use nft_protocol::rule_withdraw;

    struct PeerReceipt has copy, drop, store {}

    // === Transfers ===

    /// Use `Allowlist` to validate authorities during transfer
    ///
    /// `DepositRule` authority will be validated
    public fun enforce<T, P>(
        policy: &mut Policy<WithNft<T, P>>,
        cap: &PolicyCap,
    ) {
        request::enforce_rule_no_state<WithNft<T, P>, PeerReceipt>(policy, cap);
    }

    /// Don't use `Allowlist` to validate authorities during transfer
    ///
    /// `DepositRule` authority will be validated
    public fun drop<T, P>(
        policy: &mut Policy<WithNft<T, P>>,
        cap: &PolicyCap,
    ) {
        request::drop_rule_no_state<WithNft<T, P>, PeerReceipt>(policy, cap);
    }

    /// Authorize transfer between source and destination given that a pubkey
    /// authority can determine that both locations are eligible for peer
    /// transfers.
    ///
    /// #### Panics
    ///
    /// * `AllowlistReceipt` was not issued
    public fun confirm_transfer<T>(
        req: &mut TransferRequest<T>,
        self: &Authlist,
        pub_key: vector<u8>,
        signature: vector<u8>,
    ) {
        confirm_transfer_(
            ob_transfer_request::inner_mut(req),
            self,
            pub_key,
            signature,
        )
    }

    /// Authorize transfer between source and destination given that a pubkey
    /// authority can determine that both locations are eligible for peer
    /// transfers.
    ///
    /// #### Panics
    ///
    /// * `AllowlistReceipt` was not issued
    public fun confirm_transfer_<T, P>(
        req: &mut RequestBody<WithNft<T, P>>,
        _self: &Authlist,
        _pub_key: vector<u8>,
        _signature: vector<u8>,
    ) {
        let metadata = request::metadata(req);

        // Verifies that transaction has true source and destination
        transfer_allowlist::assert_allowlist_receipt(req);

        // If `AllowlistReceipt` was issued then `WithdrawRule` and
        // `DepositRule` exist.
        let withdraw_rule = rule_withdraw::borrow_metadata(metadata);
        let deposit_rule = rule_deposit::borrow_metadata(metadata);

        // Assert that we have withdrawn and deposited the same NFT
        rule_deposit::assert_matching_withdrawal(withdraw_rule, deposit_rule);

        // TODO: `signature` should contain a signed digest of source and
        // destination addresses, signed by one of the pubkeys in `Authlist`
        //
        // `sign(source_address | destination_address)`
        //
        // Assert this...

        request::add_receipt(req, PeerReceipt {});
    }
}
