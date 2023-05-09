module nft_protocol::royalty_strategy_bps {
    use std::option::{Self, Option};

    use sui::balance::{Self, Balance};
    use sui::package::{Self, Publisher};
    use sui::object::{Self, UID};
    use sui::transfer::share_object;
    use sui::tx_context::TxContext;

    use ob_request::transfer_request::{Self, TransferRequest, BalanceAccessCap};
    use ob_request::request::{Self, Policy, PolicyCap, WithNft};
    use sui::transfer_policy::{TransferPolicyCap, TransferPolicy};
    use ob_permissions::witness::{Witness as DelegatedWitness};
    use originmate::balances::{Self, Balances};

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::nft_protocol::NFT_PROTOCOL;
    use nft_protocol::royalty::{Self, RoyaltyDomain};
    use ob_utils::utils;
    use ob_utils::math;

    // Track the current version of the module
    const VERSION: u64 = 1;

    const ENotUpgraded: u64 = 999;
    const EWrongVersion: u64 = 1000;

    /// === Errors ===

    /// If the strategy has `is_enabled` set to false, cannot confirm any
    /// `TransferRequest`.s
    const ENotEnabled: u64 = 1;

    /// === Structs ===

    /// A shared object which can be used to add receipts of type
    /// `BpsRoyaltyStrategyRule` to `TransferRequest`.
    struct BpsRoyaltyStrategy<phantom T> has key {
        id: UID,
        version: u64,
        /// Royalty charged on trades in basis points
        royalty_fee_bps: u16,
        /// Allows this middleware to touch the balance paid.
        /// The balance is deducted from the transfer request.
        /// See the docs for `BalanceAccessCap` for more info.
        access_cap: Option<BalanceAccessCap<T>>,
        /// Contains balances of various currencies.
        aggregator: Balances,
        /// If set to false, won't give receipts to `TransferRequest`.
        is_enabled: bool,
    }

    /// Rule for `TransferPolicy` to check that the royalty has been paid.
    /// Only `TransferRequest` with a receipt from this rule are allowed to
    /// pass such policy.
    struct BpsRoyaltyStrategyRule has drop {}

    /// See the `witness::witness` module for obtaining the witness.
    ///
    /// Creates a new strategy which can be then shared with `share` method.
    /// Optionally, add balance access policy
    public fun new<T>(
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        royalty_fee_bps: u16,
        ctx: &mut TxContext,
    ): BpsRoyaltyStrategy<T> {
        let id = object::new(ctx);

        let domain = royalty::borrow_domain_mut(
            collection::borrow_uid_mut(witness, collection),
        );

        royalty::add_strategy(domain, object::uid_to_inner(&id));

        BpsRoyaltyStrategy {
            id,
            version: VERSION,
            is_enabled: true,
            royalty_fee_bps,
            access_cap: option::none(),
            aggregator: balances::new(ctx),
        }
    }

    public fun share<T>(self: BpsRoyaltyStrategy<T>) { share_object(self) }

    public fun add_balance_access_cap<T>(
        self: &mut BpsRoyaltyStrategy<T>,
        cap: BalanceAccessCap<T>,
    ) {
        assert_version(self);

        self.access_cap = option::some(cap);
    }

    public fun drop_balance_access_cap<T>(
        _witness: DelegatedWitness<T>,
        self: &mut BpsRoyaltyStrategy<T>,
    ) {
        assert_version(self);
        self.access_cap = option::none();
    }

    public fun enable<T>(
        _witness: DelegatedWitness<T>,
        self: &mut BpsRoyaltyStrategy<T>,
    ) {
        assert_version(self);
        self.is_enabled = true;
    }

    /// Can't issue receipts for `TransferRequest<T>` anymore.
    public fun disable<T>(
        _witness: DelegatedWitness<T>,
        self: &mut BpsRoyaltyStrategy<T>,
    ) {
        assert_version(self);
        self.is_enabled = false;
    }

    /// Registers collection to use `BpsRoyaltyStrategy` during the transfer.
    public fun enforce<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
        transfer_request::add_originbyte_rule<T, BpsRoyaltyStrategyRule, bool>(
            BpsRoyaltyStrategyRule {}, policy, cap, false,
        );
    }

    public fun drop<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
        transfer_request::remove_originbyte_rule<T, BpsRoyaltyStrategyRule, bool>(
            policy, cap
        );
    }

    /// Registers collection to use `BpsRoyaltyStrategy` during the transfer.
    public fun enforce_<T, P>(policy: &mut Policy<WithNft<T, P>>, cap: &PolicyCap) {
        request::enforce_rule_no_state<WithNft<T, P>, BpsRoyaltyStrategyRule>(policy, cap);
    }

    public fun drop_<T, P>(policy: &mut Policy<WithNft<T, P>>, cap: &PolicyCap) {
        request::drop_rule_no_state<WithNft<T, P>, BpsRoyaltyStrategyRule>(policy, cap);
    }

    /// Transfers the royalty to the collection royalty aggregator.
    public fun collect_royalties<T, FT>(
        collection: &mut Collection<T>, strategy: &mut BpsRoyaltyStrategy<T>,
    ) {
        assert_version(strategy);

        let balance = balances::borrow_mut(&mut strategy.aggregator);
        let amount = balance::value(balance);
        royalty::collect_royalty<T, FT>(collection, balance, amount);
    }

    /// Uses the balance associated with the request to deduct royalty.
    public fun confirm_transfer<T, FT>(
        self: &mut BpsRoyaltyStrategy<T>,
        req: &mut TransferRequest<T>,
        ctx: &mut TxContext,
    ) {
        assert_version(self);
        assert!(self.is_enabled, ENotEnabled);

        let cap = option::borrow(&self.access_cap);
        let (paid, _) = transfer_request::paid_in_ft_mut<T, FT>(req, cap);
        let royalty_amount = calculate(self, balance::value(paid));
        balances::take_from(&mut self.aggregator, paid, royalty_amount);

        // Deduct royalty from fees if any
        if (fee_balance::has_fees<T>(req)) {
            let (fee_paid , _) = fee_balance::paid_in_fees_mut<T, FT>(req, cap);
            let royalty_amount = calculate(self, balance::value(fee_paid));
            balances::take_from(&mut self.aggregator, fee_paid, royalty_amount);

            fee_balance::distribute_fee_to_intermediary<T, FT>(req, ctx);
        };

        transfer_request::add_receipt(req, BpsRoyaltyStrategyRule {});
    }

    /// Instead of using the balance associated with the `TransferRequest`,
    /// pay the royalty in the given token.
    public fun confirm_transfer_with_balance<T, FT>(
        self: &mut BpsRoyaltyStrategy<T>,
        req: &mut TransferRequest<T>,
        wallet: &mut Balance<FT>,
        ctx: &mut TxContext,
    ) {
        assert_version(self);
        assert!(self.is_enabled, ENotEnabled);

        let (paid, _) = transfer_request::paid_in_ft<T, FT>(req);
        let fee_amount = calculate(self, paid);
        balances::take_from(&mut self.aggregator, wallet, fee_amount);

        // Deduct royalty from fees if any
        if (fee_balance::has_fees<T>(req)) {
            let cap = option::borrow(&self.access_cap);
            let (fee_paid , _) = fee_balance::paid_in_fees_mut<T, FT>(req, cap);
            let royalty_amount = calculate(self, balance::value(fee_paid));
            balances::take_from(&mut self.aggregator, fee_paid, royalty_amount);

            fee_balance::distribute_fee_to_intermediary<T, FT>(req, ctx);
        };

        transfer_request::add_receipt(req, BpsRoyaltyStrategyRule {});
    }

    public fun royalty_fee_bps<T>(self: &BpsRoyaltyStrategy<T>): u16 {
        self.royalty_fee_bps
    }

    public fun calculate<T>(self: &BpsRoyaltyStrategy<T>, amount: u64): u64 {
        compute_(royalty_fee_bps(self), amount)
    }

    fun compute_(bps: u16, amount: u64): u64 {
        // Royalty BPS has a cap of 10_777
        let (_, royalty_rate) = math::div_round(
            (bps as u64), (utils::bps() as u64)
        );
        let (_, royalties) = math::mul_round(
            amount, royalty_rate,
        );

        royalties
    }

    // === Helpers ===

    /// 1. Creates a new `RoyaltyDomain`
    /// 2. Assigns it to the collection
    /// 3. Creates a new shared `BpsRoyaltyStrategy`
    /// 4. Assigns it to the domain
    ///
    /// The creator is the sender.
    /// The strategy has access to `TransferRequest` balance
    public fun create_domain_and_add_strategy<T>(
        witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
        royalty_domain: RoyaltyDomain,
        bps: u16,
        ctx: &mut TxContext,
    ) {
        collection::add_domain(witness, collection, royalty_domain);

        let royalty_strategy = new(witness, collection, bps, ctx);
        add_balance_access_cap(
            &mut royalty_strategy,
            transfer_request::grant_balance_access_cap(witness),
        );
        share(royalty_strategy);
    }

    // === Upgradeability ===

    fun assert_version<T>(self: &BpsRoyaltyStrategy<T>) {
        assert!(self.version == VERSION, EWrongVersion);
    }

    // Only the publisher of type `T` can upgrade
    entry fun migrate_as_creator<T>(
        self: &mut BpsRoyaltyStrategy<T>, pub: &Publisher,
    ) {
        assert!(package::from_package<T>(pub), 0);
        self.version = VERSION;
    }

    entry fun migrate_as_pub<T>(
        self: &mut BpsRoyaltyStrategy<T>, pub: &Publisher
    ) {
        assert!(package::from_package<NFT_PROTOCOL>(pub), 0);
        self.version = VERSION;
    }

    // === Tests ===

    #[test]
    fun test_royalties() {
        let trade = 1_000_000;

        let (_, royalty_rate) = math::div_round(
            (1_000 as u64), (utils::bps() as u64)
        );

        let (_, _) = math::mul_round(
            trade, royalty_rate,
        );
    }

    #[test]
    fun test_precision_1_000_bps() {
        // Round 1
        let trade = 1;

        let royalties = compute_(1_000, trade);
        assert!(royalties == 0, 0);

        // Round 2
        let trade = 10;

        let royalties = compute_(1, trade);
        assert!(royalties == 0, 0);

        // Round 3
        let trade = 100;

        let royalties = compute_(1, trade);
        assert!(royalties == 0, 0);

        // Round 4
        let trade = 1_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 0, 0);

        // Round 5
        let trade = 10_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 1, 0);

        // Round 6
        let trade = 100_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 10, 0);
    }


    #[test]
    fun test_precision() {
        // Round 1
        let trade = 10_000_000_000_000_000_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 1_000_000_000_000_000, 0);

        // Round 2
        let trade = 1_000_000_000_000_000_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 100_000_000_000_000, 0);

        // Round 3
        let trade = 100_000_000_000_000_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 10_000_000_000_000, 0);

        // Round 4
        let trade = 10_000_000_000_000_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 1_000_000_000_000, 0);

        // Round 5
        let trade = 1_000_000_000_000_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 100_000_000_000, 0);

        // Round 6
        let trade = 100_000_000_000_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 10_000_000_000, 0);

        // Round 7
        let trade = 10_000_000_000_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 1_000_000_000, 0);

        // Round 8
        let trade = 1_000_000_000_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 100_000_000, 0);

        // Round 9
        let trade = 100_000_000_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 10_000_000, 0);

        // Round 10
        let trade = 10_000_000_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 1_000_000, 0);

        // Round 11
        let trade = 1_000_000_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 100_000, 0);

        // Round 12
        let trade = 100_000_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 10_000, 0);

        // Round 13
        let trade = 10_000_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 1_000, 0);

        // Round 14
        let trade = 1_000_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 100, 0);

        // Round 15
        let trade = 100_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 10, 0);

        // Round 16
        let trade = 10_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 1, 0);

        // Round 17
        let trade = 1_000;

        let royalties = compute_(1, trade);
        assert!(royalties == 0, 0);
    }

    #[test]
    fun test_precision_() {
        // Round 1
        let trade = 7_777_777_777_777_777_777;
        let rate = 555;

        assert!(compute_(555, trade) == 431_666_666_666_666_666, 0);

        // Round 2
        let trade = 777_777_777_777_777_777;
        assert!(compute_(rate, trade) == 431_666_666_666_666_66, 0);

        // Round 3
        let trade = 777_777_777_777_777_77;
        assert!(compute_(rate, trade) == 431_666_666_666_666_6, 0);

        // Round 4
        let trade = 777_777_777_777_777_7;
        assert!(compute_(rate, trade) == 431_666_666_666_666, 0);

        // Round 5
        let trade = 777_777_777_777;
        assert!(compute_(rate, trade) == 431_666_666_66, 0);

        // Round 6
        let trade = 777_777_777;
        assert!(compute_(rate, trade) == 431_666_66, 0);

        // Round 7
        let trade = 777_777;
        assert!(compute_(rate, trade) == 431_66, 0);
    }
}
