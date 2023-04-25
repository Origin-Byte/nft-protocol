module nft_protocol::bps_fee {
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::ob_transfer_request::{Self, TransferRequest, BalanceAccessCap};
    use nft_protocol::request::{Self, Policy, PolicyCap, WithNft};
    use nft_protocol::royalty;
    use nft_protocol::utils;
    use sui::transfer_policy::{TransferPolicyCap, TransferPolicy};
    use nft_protocol::witness::{Witness as DelegatedWitness};
    use originmate::balances::{Self, Balances};
    use std::fixed_point32;
    use std::option::{Self, Option};
    use sui::balance::{Self, Balance};
    use sui::object::{Self, UID};
    use sui::transfer::share_object;
    use sui::tx_context::{sender, TxContext};

    /// === Errors ===

    /// If the strategy has `is_enabled` set to false, cannot confirm any
    /// `TransferRequest`.s
    const ENotEnabled: u64 = 1;

    /// === Structs ===

    /// A shared object which can be used to add receipts of type
    /// `BpsFeeStrategyRule` to `TransferRequest`.
    struct BpsFeeStrategy<phantom T> has key {
        id: UID,
        /// Royalty charged on trades in basis points
        fee_bps: u16,
        /// Allows this middleware to touch the balance paid.
        /// The balance is deducted from the transfer request.
        /// See the docs for `BalanceAccessCap` for more info.
        access_cap: Option<BalanceAccessCap<T>>,
        /// Contains balances of various currencies.
        aggregator: Balances,
        /// If set to false, won't give receipts to `TransferRequest`.
        is_enabled: bool,
    }

    /// Rule for `TransferPolicy` to check that the fee has been paid.
    /// Only `TransferRequest` with a receipt from this rule are allowed to
    /// pass such policy.
    struct BpsFeeStrategyRule has drop {}

    /// See the `nft_protocol::witness` module for obtaining the witness.
    ///
    /// Creates a new strategy which can be then shared with `share` method.
    /// Optionally, add balance access policy
    public fun new<T>(
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        fee_bps: u16,
        ctx: &mut TxContext,
    ): BpsFeeStrategy<T> {
        let id = object::new(ctx);

        let domain = royalty::borrow_domain_mut(
            collection::borrow_uid_mut(witness, collection),
        );

        royalty::add_strategy(domain, object::uid_to_inner(&id));

        BpsFeeStrategy {
            id,
            is_enabled: true,
            fee_bps,
            access_cap: option::none(),
            aggregator: balances::new(ctx),
        }
    }

    public fun share<T>(self: BpsFeeStrategy<T>) { share_object(self) }

    public fun add_balance_access_cap<T>(
        self: &mut BpsFeeStrategy<T>,
        cap: BalanceAccessCap<T>,
    ) { self.access_cap = option::some(cap); }

    public fun drop_balance_access_cap<T>(
        _witness: DelegatedWitness<T>,
        self: &mut BpsFeeStrategy<T>,
    ) { self.access_cap = option::none(); }

    public fun enable<T>(
        _witness: DelegatedWitness<T>,
        self: &mut BpsFeeStrategy<T>,
    ) { self.is_enabled = true; }

    /// Can't issue receipts for `TransferRequest<T>` anymore.
    public fun disable<T>(
        _witness: DelegatedWitness<T>,
        self: &mut BpsFeeStrategy<T>,
    ) { self.is_enabled = false; }

    /// Registers collection to use `BpsFeeStrategy` during the transfer.
    public fun enforce<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
        ob_transfer_request::add_originbyte_rule<T, BpsFeeStrategyRule, bool>(
            BpsFeeStrategyRule {}, policy, cap, false,
        );
    }

    public fun drop<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
        ob_transfer_request::remove_originbyte_rule<T, BpsFeeStrategyRule, bool>(
            policy, cap
        );
    }

    /// Registers collection to use `BpsFeeStrategy` during the transfer.
    public fun enforce_<T, P>(policy: &mut Policy<WithNft<T, P>>, cap: &PolicyCap) {
        request::enforce_rule_no_state<WithNft<T, P>, BpsFeeStrategyRule>(policy, cap);
    }

    public fun drop_<T, P>(policy: &mut Policy<WithNft<T, P>>, cap: &PolicyCap) {
        request::drop_rule_no_state<WithNft<T, P>, BpsFeeStrategyRule>(policy, cap);
    }

    /// Transfers the royalty to the collection royalty aggregator.
    public fun collect_royalties<T, FT>(
        collection: &mut Collection<T>, strategy: &mut BpsFeeStrategy<T>,
    ) {
        let balance = balances::borrow_mut(&mut strategy.aggregator);
        let amount = balance::value(balance);
        royalty::collect_royalty<T, FT>(collection, balance, amount);
    }

    // TODO: add for generic request body
    /// Uses the balance associated with the request to deduct royalty.
    public fun confirm_transfer<T, FT>(
        self: &mut BpsFeeStrategy<T>, req: &mut TransferRequest<T>,
    ) {
        assert!(self.is_enabled, ENotEnabled);

        let cap = option::borrow(&self.access_cap);
        let (paid, _) = ob_transfer_request::paid_in_ft_mut<T, FT>(req, cap);
        let fee_amount = calculate(self, balance::value(paid));
        balances::take_from(&mut self.aggregator, paid, fee_amount);

        ob_transfer_request::add_receipt(req, BpsFeeStrategyRule {});
    }

    // TODO: add for generic request body
    /// Instead of using the balance associated with the `TransferRequest`,
    /// pay the royalty in the given token.
    public fun confirm_transfer_with_balance<T, FT>(
        self: &mut BpsFeeStrategy<T>,
        req: &mut TransferRequest<T>,
        wallet: &mut Balance<FT>,
    ) {
        assert!(self.is_enabled, ENotEnabled);

        let (paid, _) = ob_transfer_request::paid_in_ft<T, FT>(req);
        let fee_amount = calculate(self, paid);
        balances::take_from(&mut self.aggregator, wallet, fee_amount);

        ob_transfer_request::add_receipt(req, BpsFeeStrategyRule {});
    }

    public fun fee_bps<T>(self: &BpsFeeStrategy<T>): u16 {
        self.fee_bps
    }

    public fun calculate<T>(self: &BpsFeeStrategy<T>, amount: u64): u64  {
        // TODO: Need to consider implementing Decimals module for increased
        // precision, or wait for native support
        let royalty_rate = fixed_point32::create_from_rational(
            (fee_bps(self) as u64),
            (utils::bps() as u64)
        );

        fixed_point32::multiply_u64(
            amount,
            royalty_rate,
        )
    }

    // === Helpers ===

    /// 1. Creates a new `RoyaltyDomain`
    /// 2. Assigns it to the collection
    /// 3. Creates a new shared `BpsFeeStrategy`
    /// 4. Assigns it to the domain
    ///
    /// The creator is the sender.
    /// The strategy has access to `TransferRequest` balance
    public fun create_domain_and_add_strategy<T>(
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        bps: u16,
        ctx: &mut TxContext,
    ) {
        let royalty_domain = royalty::from_address(sender(ctx), ctx);
        collection::add_domain(witness, collection, royalty_domain);

        let royalty_strategy = new(witness, collection, bps, ctx);
        add_balance_access_cap(
            &mut royalty_strategy,
            ob_transfer_request::grant_balance_access_cap(witness),
        );
        share(royalty_strategy);
    }
}