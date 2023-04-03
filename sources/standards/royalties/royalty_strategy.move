module nft_protocol::royalty_strategy_bps {
    use nft_protocol::collection::Collection;
    use nft_protocol::ob_transfer_request::{Self, TransferRequest, BalanceAccessCap};
    use nft_protocol::royalty;
    use nft_protocol::utils;
    use nft_protocol::witness::Witness as DelegatedWitness;
    use originmate::balances::{Self, Balances};
    use std::fixed_point32;
    use std::option::{Self, Option};
    use sui::balance;
    use sui::balance::Balance;
    use sui::object::{Self, UID};
    use sui::transfer_policy::{Self, TransferPolicyCap};
    use sui::transfer::share_object;
    use sui::tx_context::{sender, TxContext};

    /// A shared object which can be used to add receipts of type
    /// `BpsRoyaltyStrategyRule` to `TransferRequest`.
    struct BpsRoyaltyStrategy<phantom T> has key {
        id: UID,
        /// Royalty charged on trades in basis points
        royalty_fee_bps: u64,
        /// Allows this middleware to touch the balance paid.
        /// The balance is deducted from the transfer request.
        /// See the docs for `BalanceAccessCap` for more info.
        access_cap: Option<BalanceAccessCap<T>>,
        /// Contains balances of various currencies.
        aggregator: Balances,
    }

    /// Rule for `TransferPolicy` to check that the royalty has been paid.
    /// Only `TransferRequest` with a receipt from this rule are allowed to
    /// pass such policy.
    struct BpsRoyaltyStrategyRule has drop {}

    /// See the `nft_protocol::witness` module for obtaining the witness.
    ///
    /// Creates a new strategy which can be then shared with `share` method.
    /// Optionally, add balance access policy
    public fun new<T>(
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        royalty_fee_bps: u64,
        ctx: &mut TxContext,
    ): BpsRoyaltyStrategy<T> {
        let id = object::new(ctx);
        let domain = royalty::royalty_domain_mut(witness, collection);
        royalty::add_strategy(domain, object::uid_to_inner(&id));

        BpsRoyaltyStrategy {
            id,
            royalty_fee_bps,
            access_cap: option::none(),
            aggregator: balances::new(ctx),
        }
    }

    public fun share<T>(self: BpsRoyaltyStrategy<T>) { share_object(self) }

    public fun add_balance_access_cap<T>(
        self: &mut BpsRoyaltyStrategy<T>,
        cap: BalanceAccessCap<T>,
    ) { self.access_cap = option::some(cap); }

    public fun drop_balance_access_cap<T>(
        self: &mut BpsRoyaltyStrategy<T>,
        _cap: &TransferPolicyCap<T>,
    ) { self.access_cap = option::none(); }

    /// Registers collection to use `Allowlist` during the transfer.
    public fun add_policy_rule<T>(
        policy: &mut transfer_policy::TransferPolicy<T>,
        cap: &transfer_policy::TransferPolicyCap<T>,
    ) {
        transfer_policy::add_rule<T, BpsRoyaltyStrategyRule, bool>(
            BpsRoyaltyStrategyRule {}, policy, cap, false,
        );
        ob_transfer_request::add_rule_to_originbyte_ecosystem<T, BpsRoyaltyStrategyRule>(policy, cap);
    }

    /// Transfers the royalty to the collection royalty aggregator.
    public fun collect_royalties<T, FT>(
        collection: &mut Collection<T>,
        strategy: &mut BpsRoyaltyStrategy<T>,
    ) {
        let balance = balances::borrow_mut(&mut strategy.aggregator);
        let amount = balance::value(balance);
        royalty::collect_royalty<T, FT>(collection, balance, amount);
    }

    /// Uses the balance associated with the request to deduct royalty.
    public fun confirm_transfer<T, FT>(
        self: &mut BpsRoyaltyStrategy<T>,
        req: &mut TransferRequest<T>,
    ) {
        let cap = option::borrow(&self.access_cap);
        let (paid, _) = ob_transfer_request::paid_in_ft_mut<T, FT>(req, cap);
        let fee_amount = calculate(self, balance::value(paid));
        balances::take_from(&mut self.aggregator, paid, fee_amount);

        ob_transfer_request::add_receipt(req, &BpsRoyaltyStrategyRule {});
    }

    /// Instead of using the balance associated with the `TransferRequest`,
    /// pay the royalty in the given token.
    public fun confirm_transfer_with_balance<T, FT>(
        self: &mut BpsRoyaltyStrategy<T>,
        req: &mut TransferRequest<T>,
        wallet: &mut Balance<FT>,
    ) {
        let (paid, _) = ob_transfer_request::paid_in_ft<T, FT>(req);
        let fee_amount = calculate(self, paid);
        balances::take_from(&mut self.aggregator, wallet, fee_amount);

        ob_transfer_request::add_receipt(req, &BpsRoyaltyStrategyRule {});
    }

    public fun royalty_fee_bps<T>(self: &BpsRoyaltyStrategy<T>): u64 {
        self.royalty_fee_bps
    }

    public fun calculate<T>(self: &BpsRoyaltyStrategy<T>, amount: u64): u64  {
        // TODO: Need to consider implementing Decimals module for increased
        // precision, or wait for native support
        let royalty_rate = fixed_point32::create_from_rational(
            royalty_fee_bps(self),
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
    /// 3. Creates a new shared `BpsRoyaltyStrategy`
    /// 4. Assigns it to the domain
    ///
    /// The creator is the sender.
    /// The strategy has access to `TransferRequest` balance
    public fun create_domain_and_add_strategy<T, W>(
        witness: &W,
        collection: &mut Collection<T>,
        bps: u64,
        ctx: &mut TxContext,
    ) {
        let delegated_witness = nft_protocol::witness::from_witness(witness);
        let royalty_domain = royalty::from_address(sender(ctx), ctx);
        royalty::add_royalty_domain(
            witness,
            collection,
            royalty_domain,
        );

        let royalty_strategy = new<T>(
            delegated_witness, collection, bps, ctx,
        );
        add_balance_access_cap(
            &mut royalty_strategy,
            ob_transfer_request::grant_balance_access_cap(delegated_witness),
        );
        share(royalty_strategy);
    }
}
