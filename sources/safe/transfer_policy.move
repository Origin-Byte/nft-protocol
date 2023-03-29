/// The rolling hot potato pattern was designed by us in conjunction with
/// Mysten team.
///
/// To lower the barrier to entry, we mimic their APIs where relevant.
/// See the `sui::transfer_policy` module in the https://github.com/MystenLabs/sui
///
/// Our transfer policy offers generics over fungible token and a builder pattern.
///
/// We interoperate with the sui ecosystem by allowing our `TransferRequest` to
/// be converted into the sui version.
/// This is only possible if the payment was done in SUI token.
module nft_protocol::transfer_policy {
    use std::option::{Self, Option};
    use std::type_name::{Self, TypeName};
    use std::vector;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::dynamic_field as df;
    use sui::event;
    use sui::object::{Self, ID, UID};
    use sui::package::{Self, Publisher};
    use sui::sui::SUI;
    use sui::transfer_policy as sui_transfer_policy;
    use sui::tx_context::TxContext;
    use sui::vec_map::{Self, VecMap};
    use sui::vec_set::{Self, VecSet};

    /// The number of receipts does not match the `TransferPolicy` requirement.
    const EPolicyNotSatisfied: u64 = 0;
    /// A completed rule is not set in the `TransferPolicy`.
    const EIllegalRule: u64 = 1;
    /// A Rule is not set.
    const EUnknownRequrement: u64 = 2;
    /// Attempting to create a Rule that is already set.
    const ERuleAlreadySet: u64 = 3;
    /// Trying to `withdraw` or `close_and_withdraw` with a wrong Cap.
    const ENotOwner: u64 = 4;
    /// Trying to `withdraw` more than there is.
    const ENotEnough: u64 = 5;
    /// Conversion of our transfer request to the one exposed by the sui library
    /// is only permitted for SUI token.
    const EOnlyTransferRequestOfSuiToken: u64 = 6;

    /// A "Hot Potato" forcing the buyer to get a transfer permission
    /// from the item type (`T`) owner on purchase attempt.
    struct TransferRequest<phantom T> {
        nft: ID,
        /// For entities which authorize with `ID`, we convert the `ID` to
        /// address.
        originator: address,
        /// List of fungible token amounts that have been paid for the NFT.
        /// We create some helper methods for SUI token, but also support any.
        ///
        /// The key is the type of the token, ie. OTW (e.g. `sui::sui::SUI`)
        ft_paid_amounts: VecMap<TypeName, u64>,
        /// Collected Receipts.
        ///
        /// Used to verify that all of the rules were followed and
        /// `TransferRequest` can be confirmed.
        receipts: VecSet<TypeName>,
    }

    /// Convenience struct to build a `TransferRequest` hot potato.
    ///
    /// This struct can be edited and used to create a `TransferRequest`.
    /// Since it's a hot potato, it must be used.
    /// The only way to destroy it is to exchange it for `TransferRequest`.
    struct TransferRequestBuilder<phantom T> {
        nft: ID,
        originator: address,
        ft_paid_amounts: VecMap<TypeName, u64>,
    }

    /// A unique capability that allows owner of the `T` to authorize
    /// transfers.
    /// Can only be created with the `Publisher` object.
    struct TransferPolicy<phantom T> has key, store {
        id: UID,
        /// Set of types of attached rules.
        rules: VecSet<TypeName>
    }

    /// A Capability granting the owner permission to add/remove rules as well
    /// as to `withdraw` and `destroy_and_withdraw` the `TransferPolicy`.
    struct TransferPolicyCap<phantom T> has key, store {
        id: UID,
        policy_id: ID
    }

    /// Event that is emitted when a publisher creates a new `TransferPolicyCap`
    /// making the discoverability and tracking the supported types easier.
    struct TransferPolicyCreated<phantom T> has copy, drop { id: ID }

    /// Key to store "Rule" configuration for a specific `TransferPolicy`.
    struct RuleKey<phantom T: drop> has copy, store, drop {}

    /// Construct a new `TransferRequest` hot potato which requires an
    /// approving action from the creator to be destroyed / resolved.
    public fun builder<T>(nft: ID, originator: address): TransferRequestBuilder<T> {
        TransferRequestBuilder {
            nft,
            originator,
            ft_paid_amounts: vec_map::empty(),
        }
    }

    public fun builder_add_ft<T, FT>(builder: &mut TransferRequestBuilder<T>, paid: u64) {
        vec_map::insert(&mut builder.ft_paid_amounts, type_name::get<FT>(), paid);
    }

    public fun builder_add_ft_by_type<T>(builder: &mut TransferRequestBuilder<T>, ft: TypeName, paid: u64) {
        vec_map::insert(&mut builder.ft_paid_amounts, ft, paid);
    }

    public fun build<T>(builder: TransferRequestBuilder<T>): TransferRequest<T> {
        let TransferRequestBuilder { nft, originator, ft_paid_amounts } = builder;
        TransferRequest {
            nft,
            originator,
            ft_paid_amounts,
            receipts: vec_set::empty(),
        }
    }

    /// The transfer request can be converted to the sui lib version if the
    /// payment was done in SUI and there's no other currency used.
    ///
    /// Note that after this, the royalty enforcement is modelled after the
    /// sui ecosystem settings.
    ///
    /// The creator has to opt into that ecosystem.
    public fun into_sui<T>(
        request: TransferRequest<T>,
    ): sui_transfer_policy::TransferRequest<T> {
        let paid = paid_in_sui_unwrapped(&request);

        let TransferRequest {
            nft,
            originator,
            receipts: _,
            ft_paid_amounts,
        } = request;
        // since we unwrap above to get the SUI amount, we know that there're no
        // other currencies
        assert!(vec_map::size(&ft_paid_amounts) == 1, EOnlyTransferRequestOfSuiToken);

        sui_transfer_policy::new_request(
            nft, paid, object::id_from_address(originator)
        )
    }

    /// Register a type in the Kiosk system and receive an `TransferPolicyCap`
    /// which is required to confirm kiosk deals for the `T`. If there's no
    /// `TransferPolicyCap` available for use, the type can not be traded in
    /// kiosks.
    public fun new<T>(
        pub: &Publisher, ctx: &mut TxContext
    ): (TransferPolicy<T>, TransferPolicyCap<T>) {
        assert!(package::from_package<T>(pub), 0);
        let id = object::new(ctx);
        let policy_id = object::uid_to_inner(&id);

        event::emit(TransferPolicyCreated<T> { id: policy_id });

        (
            TransferPolicy { id, rules: vec_set::empty() },
            TransferPolicyCap { id: object::new(ctx), policy_id },
        )
    }

    /// Withdraw some amount of profits from the `TransferPolicy`.
    /// If amount is not specified, all profits are withdrawn.
    public fun withdraw<T, FT>(
        self: &mut TransferPolicy<T>,
        cap: &TransferPolicyCap<T>,
        amount: Option<u64>,
        ctx: &mut TxContext,
    ): Coin<FT> {
        assert!(object::id(self) == cap.policy_id, ENotOwner);

        let ft_balance: &mut Balance<FT> =
            df::borrow_mut(&mut self.id, type_name::get<T>());

        let amount = if (option::is_some(&amount)) {
            let amt = option::destroy_some(amount);
            assert!(amt <= balance::value(ft_balance), ENotEnough);
            amt
        } else {
            balance::value(ft_balance)
        };

        coin::take(ft_balance, amount, ctx)
    }

    /// Allow a `TransferRequest` for the type `T`. The call is protected
    /// by the type constraint, as only the publisher of the `T` can get
    /// `TransferPolicy<T>`.
    ///
    /// Note: unless there's a policy for `T` to allow transfers,
    /// Kiosk trades will not be possible.
    public fun confirm_request<T>(
        self: &TransferPolicy<T>, request: TransferRequest<T>
    ): address {
        let TransferRequest {
            nft: _,
            originator,
            receipts,
            ft_paid_amounts: _,
        } = request;
        let completed = vec_set::into_keys(receipts);
        let total = vector::length(&completed);

        assert!(total == vec_set::size(&self.rules), EPolicyNotSatisfied);

        while (total > 0) {
            let rule_type = vector::pop_back(&mut completed);
            assert!(vec_set::contains(&self.rules, &rule_type), EIllegalRule);
            total = total - 1;
        };

        originator
    }

    // === Rules Logic ===

    /// Add a custom Rule to the `TransferPolicy`. Once set, `TransferRequest` must
    /// receive a confirmation of the rule executed so the hot potato can be unpacked.
    ///
    /// - T: the type to which TransferPolicy<T> is applied.
    /// - Rule: the witness type for the Custom rule
    /// - Config: a custom configuration for the rule
    ///
    /// Config requires `drop` to allow creators to remove any policy at any moment,
    /// even if graceful unpacking has not been implemented in a "rule module".
    public fun add_rule<T, Rule: drop, Config: store + drop>(
        _: Rule, policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>, cfg: Config
    ) {
        assert!(object::id(policy) == cap.policy_id, ENotOwner);
        assert!(!has_rule<T, Rule>(policy), ERuleAlreadySet);
        df::add(&mut policy.id, RuleKey<Rule> {}, cfg);
        vec_set::insert(&mut policy.rules, type_name::get<Rule>())
    }

    /// Get the custom Config for the Rule (can be only one per "Rule" type).
    public fun get_rule<T, Rule: drop, Config: store + drop>(
        _: Rule, policy: &TransferPolicy<T>)
    : &Config {
        df::borrow(&policy.id, RuleKey<Rule> {})
    }

    public fun add_to_balance<T, FT>(
       policy: &mut TransferPolicy<T>, coin: Coin<FT>
    ) {
        if (!df::exists_(&policy.id, type_name::get<FT>())) {
            df::add(&mut policy.id, type_name::get<FT>(), balance::zero<FT>());
        };

        let balance: &mut Balance<FT> =
            df::borrow_mut(&mut policy.id, type_name::get<T>());
        coin::put(balance, coin);
    }

    public fun add_sui_to_balance<T>(
       policy: &mut TransferPolicy<T>, coin: Coin<SUI>
    ) {
        add_to_balance(policy, coin)
    }

    /// Adds a `Receipt` to the `TransferRequest`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<T, Rule: drop>(
        _: Rule, request: &mut TransferRequest<T>
    ) {
        vec_set::insert(&mut request.receipts, type_name::get<Rule>())
    }

    /// Check whether a custom rule has been added to the `TransferPolicy`.
    public fun has_rule<T, Rule: drop>(policy: &TransferPolicy<T>): bool {
        df::exists_(&policy.id, RuleKey<Rule> {})
    }

    /// Remove the Rule from the `TransferPolicy`.
    public fun remove_rule<T, Rule: drop, Config: store + drop>(
        policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>
    ) {
        assert!(object::id(policy) == cap.policy_id, ENotOwner);
        let _: Config = df::remove(&mut policy.id, RuleKey<Rule> {});
    }

    // === Fields access ===

    public fun paid<T, FT>(self: &TransferRequest<T>): Option<u64> {
        if (vec_map::contains(&self.ft_paid_amounts, &type_name::get<FT>())) {
            let paid =
                vec_map::get(&self.ft_paid_amounts, &type_name::get<FT>());

            option::some(*paid)
        } else {
            option::none()
        }
    }

    public fun paid_unwrapped<T, FT>(self: &TransferRequest<T>): u64 {
        option::destroy_some(paid<T, FT>(self))
    }

    public fun paid_in_sui<T>(self: &TransferRequest<T>): Option<u64> {
        paid<T, SUI>(self)
    }

    public fun paid_in_sui_unwrapped<T>(self: &TransferRequest<T>): u64 {
        paid_unwrapped<T, SUI>(self)
    }

    public fun ft_paid_amounts<T>(self: &TransferRequest<T>): &VecMap<TypeName, u64> {
        &self.ft_paid_amounts
    }

    /// Which entity started the trade.
    public fun originator<T>(self: &TransferRequest<T>): address { self.originator }

    /// What's the NFT that's being transferred.
    public fun nft<T>(self: &TransferRequest<T>): ID { self.nft }
}
