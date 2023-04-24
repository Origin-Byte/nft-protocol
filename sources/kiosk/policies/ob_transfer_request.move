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
///
/// #### `Policy<WithNft<T, OB_TRANSFER_REQUEST>>`
/// To be able to authorize transfers, create a policy with
/// `nft_protocol::ob_transfer_request::init_policy`.
/// This creates a new transfer request policy to which rules can be attached.
/// Some common rules:
/// * `nft_protocol::allowlist::enforce`
/// * `nft_protocol::royalty_strategy_bps::enforce`
module nft_protocol::ob_transfer_request {
    use nft_protocol::witness::{Witness as DelegatedWitness};
    use sui::balance::{Self, Balance};
    use sui::coin;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::package::Publisher;
    use sui::sui::SUI;
    use sui::transfer_policy::{
        Self,
        TransferRequest as SuiTransferRequest,
        TransferPolicy, TransferPolicyCap
    };
    use sui::transfer::public_transfer;
    use sui::tx_context::TxContext;

    // === Errors ===

    /// A completed rule is not set in the `TransferPolicy`.
    const EIllegalRule: u64 = 1;
    /// Conversion of our transfer request to the one exposed by the sui library
    /// is only permitted for SUI token.
    const EOnlyTransferRequestOfSuiToken: u64 = 2;
    /// The number of receipts does not match the `TransferPolicy` requirement.
    const EPolicyNotSatisfied: u64 = 3;
    /// A custom policy action cannot be converted to from `TransferRequest` to `SuiTransferRequest`
    const ECannotConvertCustomPolicy: u64 = 3;

    // === Structs ===

    struct Witness has drop {}

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
        /// Helper for checking that transfer rules have been followed.
        /// This inner type is what interoperates with the policy.
        /// The type `Policy<WithNft<T, OB_TRANSFER_REQUEST>>`
        /// matches with this type of request.
        inner: SuiTransferRequest<T>,
        metadata: UID,
    }

    /// TLDR:
    /// * + easier interface
    /// * + pay royalties from what's been paid
    /// * + permissionless trade resolution
    /// * - less client control
    ///
    /// Policies which own this capability get mutable access the balance of
    /// `TransferRequest<T>`.
    ///
    /// This is useful for policies which charge a fee from the payment.
    /// E.g., the fee can be deducted from the balance and the rest transferred
    /// to the beneficiary (NFT seller).
    /// That's handy for orderbook trading - improves UX.
    /// Otherwise, either the seller or the buyer would have to run
    /// the trade resolution as another tx.
    ///
    /// Note that thorough review of the policy code is required because it
    /// gets access to all the funds used for trading.
    ///
    /// We don't consider a malicious policy by the creator to be a security
    /// risk because it is equivalent to charging a 100% royalty.
    /// This isn't prevented in the standard Sui implementation either.
    /// The best prevention is a client side condition which fails the trade
    /// if royalty is too high.
    ///
    /// Typically, this is optional because there's another way of paying
    /// royalties in which the strategy doesn't have to touch the
    /// balance.
    /// It's useful to avoid this for careful clients which prefer to have
    /// precise control over how much royalty is paid and fail if it's over a
    /// certain amount.
    /// Therefore, creators can avoid this field.
    struct BalanceAccessCap<phantom T> has store, drop {}

    /// Stores balance on `TransferRequest` as dynamic field in the metadata.
    struct BalanceDfKey has copy, store, drop {}

    struct OBCustomRulesDfKey has copy, store, drop {}

    // === TransferRequest ===

    /// Construct a new `TransferRequest` hot potato which requires an
    /// approving action from the creator to be destroyed / resolved.
    ///
    /// `set_paid` MUST be called to set the paid amount.
    /// Without calling `set_paid`, the tx will always abort.
    public fun new<T>(
        nft: ID, originator: address, kiosk_id: ID, price: u64, ctx: &mut TxContext,
    ): TransferRequest<T> {
        TransferRequest {
            nft,
            originator,
            // is overwritten in `set_paid` if any balance is associated with
            beneficiary: @0x0,
            inner: transfer_policy::new_request(nft, price, kiosk_id),
            metadata: object::new(ctx),
        }
    }

    /// Aborts unless called exactly once.
    public fun set_paid<T, FT>(
        self: &mut TransferRequest<T>, paid: Balance<FT>, beneficiary: address,
    ) {
        self.beneficiary = beneficiary;
        df::add(metadata_mut(self), BalanceDfKey {}, paid);
    }

    /// Sets empty SUI token balance.
    ///
    /// Useful for apps which are not payment based.
    public fun set_nothing_paid<T>(self: &mut TransferRequest<T>) {
        df::add(metadata_mut(self), BalanceDfKey {}, balance::zero<SUI>());
    }

    /// Gets mutable access to the inner type which is concerned with the
    /// receipt resolution.
    public fun inner_mut<T>(
        self: &mut TransferRequest<T>,
    ): &mut SuiTransferRequest<T> { &mut self.inner }

    /// Gets access to the inner type which is concerned with the
    /// receipt resolution.
    public fun inner<T>(
        self: &TransferRequest<T>,
    ): &SuiTransferRequest<T> { &self.inner }


    /// Adds a `Receipt` to the `TransferRequest`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<T, Rule: drop>(self: &mut TransferRequest<T>, rule: Rule) {
        transfer_policy::add_receipt(rule, &mut self.inner);
    }

    /// Anyone can attach any metadata (dynamic fields).
    /// The UID is eventually dropped when the `TransferRequest` is destroyed.
    ///
    /// There are some standard metadata are
    /// * `ob_kiosk::set_transfer_request_auth`
    /// * `transfer_request::set_paid`
    public fun metadata_mut<T>(self: &mut TransferRequest<T>): &mut UID { &mut self.metadata }

    public fun metadata<T>(self: &TransferRequest<T>): &UID { &self.metadata }

    public fun from_sui<T>(
        inner: SuiTransferRequest<T>, nft: ID, originator: address, ctx: &mut TxContext,
    ): TransferRequest<T> {
        TransferRequest {
            nft,
            originator,
            // is overwritten in `set_paid` if any balance is associated with
            beneficiary: @0x0,
            inner,
            metadata: object::new(ctx),
        }
    }

    /// The transfer request can be converted to the sui lib version if the
    /// payment was done in SUI and there's no other currency used.
    ///
    /// Note that after this, the royalty enforcement is modelled after the
    /// sui ecosystem settings.
    /// This means that the rules for closing the `SuiTransferRequest` must
    /// be met according to `sui::transfer_policy::confirm_request`.
    ///
    /// The creator has to opt into that (Sui) ecosystem.
    /// All the receipts are reset and must be collected anew.
    /// Therefore, it really makes sense to call this function immediately
    /// after one got the `TransferRequest`.
    public fun into_sui<T>(
        self: TransferRequest<T>, policy: &TransferPolicy<T>, ctx: &mut TxContext,
    ): SuiTransferRequest<T> {
        // Assert no custom rules
        assert!(
            !df::exists_(transfer_policy::uid(policy), OBCustomRulesDfKey {}),
            ECannotConvertCustomPolicy
        );
        // the sui transfer policy doesn't support our balance association
        // and therefore just send the coin to the beneficiary directly
        distribute_balance_to_beneficiary<T, SUI>(&mut self, ctx);

        let TransferRequest {
            nft: _,
            originator: _,
            inner,
            beneficiary: _,
            metadata,
        } = self;
        object::delete(metadata);

        inner
    }

    // === For creators ===

    /// Creates a new policy oriented around transfer requests for the
    /// given type.
    public fun init_policy<T>(
        publisher: &Publisher, ctx: &mut TxContext,
    ): (TransferPolicy<T>, TransferPolicyCap<T>) {
        transfer_policy::new(publisher, ctx)
    }

    /// We extend the functionality of `TransferPolicy` by inserting our
    /// Originbyte `VecSet<TypeName>` into it.
    /// These rules work with our custom `TransferRequest`.
    public fun add_originbyte_rule<T, Rule: drop, Config: store + drop>(
        rule: Rule, self: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>, cfg: Config
    ) {
        let ext = transfer_policy::uid_mut_as_owner(self, cap);
        if (!df::exists_(ext, OBCustomRulesDfKey {})) {
            let ob_rules = df::borrow_mut<OBCustomRulesDfKey, u8>(ext, OBCustomRulesDfKey {});
            *ob_rules = *ob_rules + 1;
        };

        transfer_policy::add_rule(rule, self, cap, cfg);
    }

    /// Allows us to modify the rules.
    public fun remove_originbyte_rule<T, Rule: drop, Config: store + drop>(
        self: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>,
    ) {
        let ext = transfer_policy::uid_mut_as_owner(self, cap);
        let ob_rules = df::borrow_mut<OBCustomRulesDfKey, u8>(ext, OBCustomRulesDfKey {});
        *ob_rules = *ob_rules - 1;

        if (*ob_rules == 0) {
            df::remove<OBCustomRulesDfKey, u8>(ext, OBCustomRulesDfKey {});
        };

        transfer_policy::remove_rule<T, Rule, Config>(self, cap);
    }

    /// Creates a new capability which enables the holder to get `&mut` access
    /// to a balance paid for an NFT.
    public fun grant_balance_access_cap<T>(
        _witness: DelegatedWitness<T>,
    ): BalanceAccessCap<T> { BalanceAccessCap {} }

    // === Request confirmation ===

    /// Allow a `TransferRequest` for the type `T`.
    /// The call is protected by the type constraint, as only the publisher of
    /// the `T` can get `TransferPolicy<T>`.
    ///
    /// Note: unless there's a policy for `T` to allow transfers,
    /// Kiosk trades will not be possible.
    /// If there is no transfer policy in the OB ecosystem, try using
    /// `into_sui` to convert the `TransferRequest` to the SUI ecosystem.
    public fun confirm<T, FT>(
        self: TransferRequest<T>,
        policy: &TransferPolicy<T>,
        ctx: &mut TxContext,
    ) {
        distribute_balance_to_beneficiary<T, FT>(&mut self, ctx);
        let TransferRequest {
            nft: _,
            originator: _,
            beneficiary: _,
            inner,
            metadata,
        } = self;
        object::delete(metadata);

        transfer_policy::confirm_request(policy, inner);
    }

    /// Takes out the funds from the transfer request and sends them to the
    /// originator.
    /// This is useful if permissionless trade resolution is not necessary
    /// and the royalties can be deducted from a specific `Balance` rather than
    /// using `BalanceAccessCap`.
    ///
    /// Is idempotent.
    public fun distribute_balance_to_beneficiary<T, FT>(
        self: &mut TransferRequest<T>, ctx: &mut TxContext,
    ) {
        let metadata = metadata_mut(self);
        if (!df::exists_(metadata, BalanceDfKey {})) {
            return
        };

        let balance: Balance<FT> = df::remove(metadata, BalanceDfKey {});
        if (balance::value(&balance) > 0) {
            public_transfer(coin::from_balance(balance, ctx), self.beneficiary);
        } else {
            balance::destroy_zero(balance);
        };
    }

    // === Getters ===

    public fun paid_in_ft_mut<T, FT>(
        self: &mut TransferRequest<T>, _cap: &BalanceAccessCap<T>,
    ): (&mut Balance<FT>, address) {
        let beneficiary = self.beneficiary;
        (balance_mut_(self), beneficiary)
    }

    public fun paid_in_sui_mut<T>(
        self: &mut TransferRequest<T>, _cap: &BalanceAccessCap<T>,
    ): (&mut Balance<SUI>, address) {
        let beneficiary = self.beneficiary;
        (balance_mut_(self), beneficiary)
    }

    /// Returns the amount and beneficiary.
    public fun paid_in_ft<T, FT>(self: &TransferRequest<T>): (u64, address) {
        let beneficiary = self.beneficiary;
        (balance::value<FT>(balance_(self)), beneficiary)
    }

    /// Panics if the `TransferRequest` is not for SUI token.
    public fun paid_in_sui<T>(self: &TransferRequest<T>): (u64, address) {
        paid_in_ft<T, SUI>(self)
    }

    /// Which entity started the trade.
    public fun originator<T>(self: &TransferRequest<T>): address { self.originator }

    /// What's the NFT that's being transferred.
    public fun nft<T>(self: &TransferRequest<T>): ID { self.nft }

    fun balance_mut_<T, FT>(self: &mut TransferRequest<T>): &mut Balance<FT> {
        df::borrow_mut(&mut self.metadata, BalanceDfKey {})
    }

    fun balance_<T, FT>(self: &TransferRequest<T>): &Balance<FT> {
        df::borrow(&self.metadata, BalanceDfKey {})
    }
}
