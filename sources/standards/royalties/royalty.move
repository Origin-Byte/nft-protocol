module nft_protocol::royalty {
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use sui::bag::{Self, Bag};

    use nft_protocol::collection::{Self, Collection, MintCap};

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::attribution;
    use nft_protocol::royalty_strategy_bps::{Self, BpsRoyaltyStrategy};
    use nft_protocol::royalty_strategy_constant::{
        Self, ConstantRoyaltyStrategy
    };

    struct RoyaltyDomain has store {
        /// Royalty strategies
        strategies: Bag,
        /// Aggregates received royalties across different coins
        aggregations: Bag,
    }

    /// Creates a `RoyaltyDomain` object with a single creator attribution.
    public fun new(ctx: &mut TxContext): RoyaltyDomain {
        RoyaltyDomain {
            strategies: bag::new(ctx),
            aggregations: bag::new(ctx),
        }
    }

    // === Royalties ===

    /// Add a royalty strategy
    public fun add_royalty_strategy<Strategy: store>(
        domain: &mut RoyaltyDomain,
        strategy: Strategy,
    ) {
        bag::add(
            &mut domain.strategies,
            utils::marker<Strategy>(),
            strategy,
        );
    }

    /// Remove a royalty strategy
    public fun remove_royalty_strategy<Strategy: store>(
        domain: &mut RoyaltyDomain,
    ): Strategy {
        bag::remove(&mut domain.strategies, utils::marker<Strategy>())
    }

    /// Check whether a royalty strategy is defined
    public fun contains_royalty_strategy<Strategy: store>(
        domain: &RoyaltyDomain,
    ): bool {
        bag::contains_with_type<Marker<Strategy>, Strategy>(
            &domain.strategies, utils::marker<Strategy>()
        )
    }

    /// Borrow a royalty strategy
    public fun borrow_royalty_strategy<Strategy: store>(
        domain: &RoyaltyDomain,
    ): &Strategy {
        bag::borrow(
            &domain.strategies,
            utils::marker<Strategy>(),
        )
    }

    /// Mutably borrow a royalty strategy
    public fun borrow_royalty_strategy_mut<Strategy: store>(
        domain: &mut RoyaltyDomain,
    ): &Strategy {
        bag::borrow_mut(&mut domain.strategies, utils::marker<Strategy>())
    }

    // === Standard royalty domains ===

    /// Add proportional royalty policy
    public fun add_proportional_royalty(
        domain: &mut RoyaltyDomain,
        strategy: BpsRoyaltyStrategy,
    ) {
        add_royalty_strategy(domain, strategy);
    }

    /// Add constant royalty policy
    public fun add_constant_royalty(
        domain: &mut RoyaltyDomain,
        strategy: ConstantRoyaltyStrategy,
    ) {
        add_royalty_strategy(domain, strategy);
    }

    /// Remove proportional royalty policy
    public fun remove_proportional_royalty(
        domain: &mut RoyaltyDomain,
    ): BpsRoyaltyStrategy {
        remove_royalty_strategy<BpsRoyaltyStrategy>(domain)
    }

    /// Remove constant royalty policy
    public fun remove_constant_royalty(
        domain: &mut RoyaltyDomain,
    ): ConstantRoyaltyStrategy {
        remove_royalty_strategy<ConstantRoyaltyStrategy>(domain)
    }

    /// Calculate how many tokens are due for the defined proportional royalty
    /// strategy.
    ///
    /// Zero if strategy is undefined.
    public fun calculate_proportional_royalty(
        domain: &RoyaltyDomain,
        amount: u64,
    ): u64 {
        if (!contains_royalty_strategy<BpsRoyaltyStrategy>(domain)) {
            return 0
        };

        let strategy = borrow_royalty_strategy<BpsRoyaltyStrategy>(domain);
        royalty_strategy_bps::calculate(strategy, amount)
    }

    /// Calculate how many tokens are due for the defined constant royalty
    /// strategy.
    ///
    /// Zero if strategy is undefined.
    public fun calculate_constant_royalty(
        domain: &RoyaltyDomain,
    ): u64 {
        if (!contains_royalty_strategy<ConstantRoyaltyStrategy>(domain)) {
            return 0
        };

        let strategy = borrow_royalty_strategy<ConstantRoyaltyStrategy>(domain);
        royalty_strategy_constant::calculate(strategy)
    }

    /// === Utils ===

    struct Witness has drop {}

    /// Collects an `amount` of tokens from the provided balance into the
    /// aggregate balance of the `RoyaltyDomain` registered on the `Collection`
    ///
    /// Requires that a `RoyaltyDomain` is registered on the collection
    public fun collect_royalty<C, FT>(
        collection: &mut Collection<C>,
        source: &mut Balance<FT>,
        amount: u64,
    ) {
        // Bypass creator check as anyone should be able to transfer royalties
        // to the collection.
        let domain: &mut RoyaltyDomain =
            collection::borrow_domain_mut(Witness {}, collection);
        let aggregations = &mut domain.aggregations;

        let b = balance::split(source, amount);

        if (!bag::contains_with_type<Marker<Balance<FT>>, Balance<FT>>(
            aggregations, utils::marker<Balance<FT>>()
        )) {
            bag::add(
                aggregations,
                utils::marker<Balance<FT>>(),
                balance::zero<FT>(),
            );
        };

        let aggregate = bag::borrow_mut(
            aggregations,
            utils::marker<Balance<FT>>()
        );

        balance::join(aggregate, b);
    }

    /// Distribute aggregated royalties among creators
    public entry fun distribute_royalties<C, FT>(
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ) {
        let attributions = *attribution::attribution_domain(collection);

        let domain: &mut RoyaltyDomain =
            collection::borrow_domain_mut(Witness {}, collection);
        let aggregate: &mut Balance<FT> = bag::borrow_mut(
            &mut domain.aggregations,
            utils::marker<Balance<FT>>(),
        );

        attribution::distribute_royalties(
            &attributions,
            aggregate,
            ctx,
        );
    }

    /// === Interoperability ===

    /// Get reference to `RoyaltyDomain`
    public fun royalty_domain<C>(
        collection: &Collection<C>,
    ): &RoyaltyDomain {
        collection::borrow_domain(collection)
    }

    /// Get mutable reference to `RoyaltyDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun royalty_domain_mut<C>(
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ): &mut RoyaltyDomain {
        attribution::assert_collection_has_creator(
            collection, tx_context::sender(ctx)
        );

        collection::borrow_domain_mut(Witness {}, collection)
    }

    /// Registers `RoyaltyDomain` on the given `Collection`
    public fun add_royalty_domain<C>(
        collection: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        domain: RoyaltyDomain,
    ) {
        collection::add_domain(collection, mint_cap, domain);
    }
}
