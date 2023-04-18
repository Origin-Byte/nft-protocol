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
module nft_protocol::request {
    use std::type_name::{Self, TypeName};
    use std::vector;
    use sui::balance::{Self, Balance};
    use sui::coin;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::sui::SUI;
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
    struct RequestBody has store {
        /// ID of the Object whose's authorization refers to
        object: ID,
        /// Originator of the request. For entities which authorize with `ID`,
        /// we convert the `ID` to address.
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

    /// TLDR:
    /// * + easier interface
    /// * + pay royalties from what's been paid
    /// * + permissionless trade resolution
    /// * - less client control
    ///
    /// Policies which own this capability get mutable access the balance of
    /// `RequestBody`.
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

    // === TransferRequest ===

    /// Construct a new `TransferRequest` hot potato which requires an
    /// approving action from the creator to be destroyed / resolved.
    ///
    /// `set_paid` MUST be called to set the paid amount.
    /// Without calling `set_paid`, the tx will always abort.
    public fun new(
        object: ID, originator: address, ctx: &mut TxContext,
    ): RequestBody {
        RequestBody {
            metadata: object::new(ctx),
            object,
            originator,
            // is overwritten in `set_paid` if any balance is associated with
            beneficiary: @0x0,
            receipts: vec_set::empty(),
        }
    }

    /// Aborts unless called exactly once.
    public fun set_paid<FT>(
        self: &mut RequestBody, paid: Balance<FT>, beneficiary: address,
    ) {
        self.beneficiary = beneficiary;
        df::add(&mut self.metadata, BalanceDfKey {}, paid);
    }

    /// Sets empty SUI token balance.
    ///
    /// Useful for apps which are not payment based.
    public fun set_nothing_paid(self: &mut RequestBody) {
        df::add(&mut self.metadata, BalanceDfKey {}, balance::zero<SUI>());
    }

    /// Adds a `Receipt` to the `TransferRequest`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<Rule>(self: &mut RequestBody, _rule: &Rule) {
        vec_set::insert(&mut self.receipts, type_name::get<Rule>())
    }

    public fun metadata_mut(self: &mut RequestBody): &mut UID { &mut self.metadata }

    public fun destruct(self: RequestBody): (ID, address, address, VecSet<TypeName>, UID) {
        let RequestBody { object, originator, beneficiary, receipts, metadata } = self;

        (object, originator, beneficiary, receipts, metadata)
    }

    // /// The transfer request can be converted to the sui lib version if the
    // /// payment was done in SUI and there's no other currency used.
    // ///
    // /// Note that after this, the royalty enforcement is modelled after the
    // /// sui ecosystem settings.
    // /// This means that the rules for closing the `SuiTransferRequest` must
    // /// be met according to `sui::transfer_policy::confirm_request`.
    // ///
    // /// The creator has to opt into that (Sui) ecosystem.
    // /// All the receipts are reset and must be collected anew.
    // /// Therefore, it really makes sense to call this function immediately.
    // public fun into_sui<T>(
    //     self: RequestBody, ctx: &mut TxContext,
    // ): SuiTransferRequest<T> {
    //     let (paid_amount, _) = paid_in_sui(&self);
    //     // the sui transfer policy doesn't support our balance association
    //     // and therefore just send the coin to the beneficiary directly
    //     distribute_balance_to_beneficiary<T, SUI>(&mut self, ctx);

    //     let TransferRequest {
    //         nft,
    //         originator,
    //         receipts: _,
    //         beneficiary: _,
    //         metadata,
    //     } = self;
    //     object::delete(metadata);

    //     transfer_policy::new_request(
    //         nft, paid_amount, object::id_from_address(originator),
    //     )
    // }

    // === Request confirmation ===

    /// Allow a `TransferRequest` for the type `T`.
    /// The call is protected by the type constraint, as only the publisher of
    /// the `T` can get `TransferPolicy<T>`.
    ///
    /// Note: unless there's a policy for `T` to allow transfers,
    /// Kiosk trades will not be possible.
    /// If there is no transfer policy in the OB ecosystem, try using
    /// `into_sui` to convert the `TransferRequest` to the SUI ecosystem.
    public fun confirm(
        self: RequestBody,
        rules: &VecSet<TypeName>,
    ) {
        // TODO: Add an assertion here that checks that no funds are inside
        // dynamic fields - since we are no longer calling distribute_balance_to_beneficiary here
        let RequestBody {
            metadata,
            object: _,
            originator: _,
            beneficiary: _,
            receipts,
        } = self;
        object::delete(metadata);

        let completed = vec_set::into_keys(receipts);
        let total = vector::length(&completed);
        assert!(total == vec_set::size(rules), EPolicyNotSatisfied);
        while (total > 0) {
            let rule_type = vector::pop_back(&mut completed);
            assert!(vec_set::contains(rules, &rule_type), EIllegalRule);
            total = total - 1;
        };
    }

    /// Takes out the funds from the transfer request and sends them to the
    /// originator.
    /// This is useful if permissionless trade resolution is not necessary
    /// and the royalties can be deducted from a specific `Balance` rather than
    /// using `BalanceAccessCap`.
    ///
    /// Is idempotent.
    public fun distribute_balance_to_beneficiary<FT>(
        self: &mut RequestBody, ctx: &mut TxContext,
    ) {
        if (!df::exists_(&self.metadata, BalanceDfKey {})) {
            return
        };

        let balance: Balance<FT> = df::remove(&mut self.metadata, BalanceDfKey {});
        if (balance::value(&balance) > 0) {
            public_transfer(coin::from_balance(balance, ctx), self.beneficiary);
        } else {
            balance::destroy_zero(balance);
        };
    }

    // === Getters ===

    public fun paid_in_ft_mut<FT>(
        self: &mut RequestBody,
    ): (&mut Balance<FT>, address) {
        let balance = df::borrow_mut(&mut self.metadata, BalanceDfKey {});
        (balance, self.beneficiary)
    }

    public fun paid_in_sui_mut(
        self: &mut RequestBody
    ): (&mut Balance<SUI>, address) {
        let balance = df::borrow_mut(&mut self.metadata, BalanceDfKey {});
        (balance, self.beneficiary)
    }

    /// Returns the amount and beneficiary.
    public fun paid_in_ft<FT>(self: &RequestBody): (u64, address) {
        let paid = df::borrow(&self.metadata, BalanceDfKey {});
        (balance::value<FT>(paid), self.beneficiary)
    }

    /// Panics if the `TransferRequest` is not for SUI token.
    public fun paid_in_sui(self: &RequestBody): (u64, address) {
        paid_in_ft<SUI>(self)
    }

    /// Which entity started the trade.
    public fun originator(self: &RequestBody): address { self.originator }

    /// What's the object that's being authorised over.
    public fun object(self: &RequestBody): ID { self.object }

    public fun receipts(self: &RequestBody): &VecSet<TypeName> {
        &self.receipts
    }
}
