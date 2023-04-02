/// The rolling hot potato pattern was designed by us in conjunction with
/// Mysten team.
///
/// To lower the barrier to entry, we mimic those APIs where relevant.
/// See the `sui::transfer_policy` module in the https://github.com/MystenLabs/sui
/// We interoperate with the sui ecosystem by allowing our `TransferRequest` to
/// be converted into the sui version.
/// This is only possible for the cases where the payment is done in SUI token.
///
/// Our transfer request offers generics over fungible token.
/// We are no longer limited to SUI token.
/// Royalty policies can decide whether they charge a fee in other tokens.
///
/// Our transfer request associates paid balance with the request.
/// This enables us to do permissionless transfers of NFTs.
/// That's because we store the beneficiary address (e.g. NFT seller) with the
/// paid balance.
/// Then when confirming a transfer, we transfer this balance to the seller.
/// With special capability, the policies which act as a middleware can access
/// the balance and charge royalty from it.
/// Therefore, a 3rd party to a trade can send a tx to finish it.
/// This is helpful for reducing # of txs users have to send for trading
/// logic which requires multiple steps.
/// With our protocol, automation can be set up by marketplaces.
module nft_protocol::ob_transfer_request {
    use std::type_name::{Self, TypeName};
    use std::vector;
    use sui::balance::{Self, Balance};
    use sui::coin;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::sui::SUI;
    use sui::transfer_policy::{Self, TransferPolicy, TransferPolicyCap, TransferRequest as SuiTransferRequest};
    use sui::transfer::public_transfer;
    use sui::tx_context::TxContext;
    use sui::vec_set::{Self, VecSet};

    // === Errors ===

    /// A completed rule is not set in the `TransferPolicy`.
    const EIllegalRule: u64 = 1;
    /// Conversion of our transfer request to the one exposed by the sui library
    /// is only permitted for SUI token.
    const EOnlyTransferRequestOfSuiToken: u64 = 2;
    /// The number of receipts does not match the `TransferPolicy` requirement.
    const EPolicyNotSatisfied: u64 = 3;

    // === Structs ===

    /// A "Hot Potato" forcing the buyer to get a transfer permission
    /// from the item type (`T`) owner on purchase attempt.
    ///
    /// We create some helper methods for SUI token, but also support any
    /// fungible token.
    ///
    /// See the module docs for a comparison between this and `SuiTransferRequest`.
    struct TransferRequest<phantom T> {
        nft: ID,
        /// For entities which authorize with `ID`, we convert the `ID` to
        /// address.
        originator: address,
        /// Who's to receive the payment which we wrap as dyn field in metadata.
        beneficiary: address,
        /// Collected Receipts.
        ///
        /// Used to verify that all of the rules were followed and
        /// `TransferRequest` can be confirmed.
        receipts: VecSet<TypeName>,
        /// Optional metadata can be attached to the request.
        /// The metadata are dropped at the destruction of the request.
        /// It doesn't have to be emptied out.
        metadata: UID,
    }

    /// Policies which own this capability get mutable access the balance of
    /// `TransferRequest<T>`.
    ///
    /// This is useful for policies which charge a fee from the payment.
    /// E.g., the fee can be deducted from the balance and the rest transferred
    /// to the beneficiary (NFT seller).
    ///
    /// Note that thorough review of the policy code is required because it
    /// gets access to all the funds used for trading.
    ///
    /// We don't consider a malicious policy by the creator to be a security
    /// risk because it is equivalent to charging a 100% royalty.
    /// This isn't prevented in the standard Sui implementation either.
    /// The best prevention is a client side condition which fails the trade
    /// if royalty is too high.
    struct BalanceAccessCap<phantom T> has store, drop {}

    /// Stores balance on `TransferRequest` as dynamic field in the metadata.
    struct BalanceDfKey has copy, store, drop {}
    /// Stores `VecSet<TypeName>` on `TransferPolicy`.
    /// Works similarly to `TransferPolicy::rules`.
    struct OringinbyteRulesDfKey has copy, store, drop {}

    // === TransferRequest ===

    /// Construct a new `TransferRequest` hot potato which requires an
    /// approving action from the creator to be destroyed / resolved.
    ///
    /// `set_paid` MUST be called to set the paid amount.
    /// Without calling `set_paid`, the tx will always abort.
    public fun new<T>(
        nft: ID, originator: address, ctx: &mut TxContext,
    ): TransferRequest<T> {
        TransferRequest {
            metadata: object::new(ctx),
            nft,
            originator,
            // is overwritten in `set_paid`
            beneficiary: @0x0,
            receipts: vec_set::empty(),
        }
    }

    /// Aborts unless called exactly once.
    public fun set_paid<T, FT>(
        self: &mut TransferRequest<T>, paid: Balance<FT>, beneficiary: address,
    ) {
        self.beneficiary = beneficiary;
        df::add(&mut self.metadata, BalanceDfKey {}, paid);
    }

    /// Adds a `Receipt` to the `TransferRequest`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<T, Rule>(self: &mut TransferRequest<T>, _rule: &Rule) {
        vec_set::insert(&mut self.receipts, type_name::get<Rule>())
    }

    /// Anyone can attach any metadata (dynamic fields).
    /// The UID is eventually dropped when the `TransferRequest` is destroyed.
    ///
    /// There are some standard metadata are
    /// * `ob_kiosk::set_transfer_request_auth`
    /// * `transfer_request::set_paid`
    public fun metadata_mut<T>(self: &mut TransferRequest<T>): &mut UID { &mut self.metadata }

    /// The transfer request can be converted to the sui lib version if the
    /// payment was done in SUI and there's no other currency used.
    ///
    /// Note that after this, the royalty enforcement is modelled after the
    /// sui ecosystem settings.
    ///
    /// The creator has to opt into that (Sui) ecosystem.
    /// All the receipts are reset and must be collected anew.
    /// Therefore, it really makes sense to call this function immediately.
    public fun into_sui<T>(
        self: TransferRequest<T>, ctx: &mut TxContext,
    ): SuiTransferRequest<T> {
        let TransferRequest {
            nft,
            originator,
            receipts: _,
            beneficiary,
            metadata,
        } = self;

        // the sui transfer policy doesn't support our balance association
        // and therefore just send the coin to the beneficiary directly
        let balance: Balance<SUI> = df::remove(&mut metadata, BalanceDfKey {});
        let paid_amount = balance::value<SUI>(&balance);
        public_transfer(coin::from_balance(balance, ctx), beneficiary);
        object::delete(metadata);

        transfer_policy::new_request(
            nft, paid_amount, object::id_from_address(originator),
        )
    }

    // === TransferPolicy ===

    /// We extend the functionality of `TransferPolicy` by inserting our
    /// Originbyte `VecSet<TypeName>` into it.
    /// These rules work with our custom `TransferRequest`.
    public fun add_rule_to_originbyte_ecosystem<T, Rule>(
        self: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>,
    ) {
        let ext = transfer_policy::uid_mut_as_owner(self, cap);
        if (!df::exists_(ext, OringinbyteRulesDfKey {})) {
            df::add(ext, OringinbyteRulesDfKey {}, vec_set::empty<TypeName>());
        };

        let rules = df::borrow_mut(ext, OringinbyteRulesDfKey {});
        vec_set::insert(rules, type_name::get<Rule>());
    }

    /// Allows us to modify the rules.
    public fun remove_rule_from_originbyte_ecosystem<T, Rule>(
        self: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>,
    ) {
        let ext = transfer_policy::uid_mut_as_owner(self, cap);
        let rules = df::borrow_mut(ext, OringinbyteRulesDfKey {});
        vec_set::remove(rules, &type_name::get<Rule>());
    }

    /// Creates a new capability which enables the holder to get `&mut` access
    /// to a balance paid for an NFT.
    public fun grant_balance_access_cap<T>(
        _cap: &TransferPolicyCap<T>,
    ): BalanceAccessCap<T> { BalanceAccessCap {} }

    // === Request confirmation ===

    /// Same as `confirm_request<T, SUI>`.
    public fun confirm_request_in_sui<T>(
        policy: &TransferPolicy<T>, self: TransferRequest<T>, ctx: &mut TxContext,
    ) { confirm_request<T, SUI>(policy, self, ctx) }

    /// Allow a `TransferRequest` for the type `T`.
    /// The call is protected by the type constraint, as only the publisher of
    /// the `T` can get `TransferPolicy<T>`.
    ///
    /// Note: unless there's a policy for `T` to allow transfers,
    /// Kiosk trades will not be possible.
    /// If there is no transfer policy in the OB ecosystem, try using
    /// `into_sui` to convert the `TransferRequest` to the SUI ecosystem.
    public fun confirm_request<T, FT>(
        policy: &TransferPolicy<T>, self: TransferRequest<T>, ctx: &mut TxContext,
    ) {
        let TransferRequest {
            metadata,
            nft: _,
            originator: _,
            beneficiary,
            receipts,
        } = self;
        let rules = df::borrow(transfer_policy::uid(policy), OringinbyteRulesDfKey {});
        let completed = vec_set::into_keys(receipts);
        let total = vector::length(&completed);

        assert!(total == vec_set::size(rules), EPolicyNotSatisfied);

        while (total > 0) {
            let rule_type = vector::pop_back(&mut completed);
            assert!(vec_set::contains(rules, &rule_type), EIllegalRule);
            total = total - 1;
        };

        let balance: Balance<FT> = df::remove(&mut metadata, BalanceDfKey {});
        if (balance::value(&balance) > 0) {
            public_transfer(coin::from_balance(balance, ctx), beneficiary);
        } else {
            balance::destroy_zero(balance);
        };
        object::delete(metadata);
    }

    // === Getters ===

    public fun paid_in_ft_mut<T, FT>(
        self: &mut TransferRequest<T>, _cap: &BalanceAccessCap<T>,
    ): (&mut Balance<FT>, address) {
        let balance = df::borrow_mut(&mut self.metadata, BalanceDfKey {});
        (balance, self.beneficiary)
    }

    public fun paid_in_sui_mut<T>(
        self: &mut TransferRequest<T>, _cap: &BalanceAccessCap<T>,
    ): (&mut Balance<SUI>, address) {
        let balance = df::borrow_mut(&mut self.metadata, BalanceDfKey {});
        (balance, self.beneficiary)
    }

    /// Returns the amount and beneficiary.
    public fun paid_in_ft<T, FT>(self: &TransferRequest<T>): (u64, address) {
        let paid = df::borrow(&self.metadata, BalanceDfKey {});
        (balance::value<FT>(paid), self.beneficiary)
    }

    /// Panics if the `TransferRequest` is not for SUI token.
    public fun paid_in_sui<T>(self: &TransferRequest<T>): (u64, address) {
        paid_in_ft<T, SUI>(self)
    }

    /// Which entity started the trade.
    public fun originator<T>(self: &TransferRequest<T>): address { self.originator }

    /// What's the NFT that's being transferred.
    public fun nft<T>(self: &TransferRequest<T>): ID { self.nft }
}
