module nft_protocol::royalty {
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use sui::bag::{Self, Bag};

    use nft_protocol::collection::{Self, Collection};

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::attribution::{Self, AttributionDomain, Creator};
    use nft_protocol::royalty_strategy_bps::BpsRoyaltyStrategy;
    use nft_protocol::royalty_strategy_constant::ConstantRoyaltyStrategy;

    struct RoyaltyDomain has store {
        /// Royalty strategies
        strategies: Bag,
        /// Aggregates received royalties across different coins
        aggregations: Bag,
    }

    struct Witness has drop {}

    /// Creates a `RoyaltyDomain` object with a single creator attribution.
    public fun new(ctx: &mut TxContext): RoyaltyDomain {
        RoyaltyDomain {
            strategies: bag::new(ctx),
            aggregations: bag::new(ctx),
        }
    }

    /// Creates a `RoyaltyDomain` object with provided creator attributions.
    public fun from_creators(
        creators: vector<Creator>,
        ctx: &mut TxContext
    ): RoyaltyDomain {
        RoyaltyDomain {
            strategies: bag::new(ctx),
            aggregations: bag::new(ctx),
        }
    }

    /// === Royalties ===

    /// Add proportional royalty policy
    ///
    /// Requires that AttributionDomain is defined and sender is a creator
    public fun add_proportional_royalty<C>(
        nft: &mut Collection<C>,
        strategy: BpsRoyaltyStrategy,
        ctx: &mut TxContext,
    ) {
        attribution::assert_is_creator(
            collection::borrow_domain<C, AttributionDomain>(nft),
            tx_context::sender(ctx)
        );

        let domain = collection::borrow_domain_mut<C, RoyaltyDomain, Witness>(Witness {}, nft);

        bag::add(
            &mut domain.strategies,
            utils::marker<BpsRoyaltyStrategy>(),
            strategy
        );
    }

    /// Add constant royalty policy
    ///
    /// Requires that AttributionDomain is defined and sender is a creator
    public fun add_constant_royalty<C>(
        nft: &mut Collection<C>,
        strategy: ConstantRoyaltyStrategy,
        ctx: &mut TxContext,
    ) {
        attribution::assert_is_creator(
            collection::borrow_domain<C, AttributionDomain>(nft),
            tx_context::sender(ctx)
        );

        let domain = collection::borrow_domain_mut<C, RoyaltyDomain, Witness>(Witness {}, nft);

        bag::add(
            &mut domain.strategies,
            utils::marker<ConstantRoyaltyStrategy>(),
            strategy
        );
    }

    /// Remove proportional royalty policy
    ///
    /// Requires that AttributionDomain is defined and sender is a creator
    public fun remove_proportional_royalty<C>(
        nft: &mut Collection<C>,
        ctx: &mut TxContext,
    ) {
        attribution::assert_is_creator(
            collection::borrow_domain<C, AttributionDomain>(nft),
            tx_context::sender(ctx)
        );

        let domain = collection::borrow_domain_mut<C, RoyaltyDomain, Witness>(Witness {}, nft);

        bag::remove<Marker<BpsRoyaltyStrategy>, BpsRoyaltyStrategy>(
            &mut domain.strategies,
            utils::marker<BpsRoyaltyStrategy>()
        );
    }

    /// Remove constant royalty policy
    ///
    /// Requires that AttributionDomain is defined and sender is a creator
    public fun remove_constant_royalty<C>(
        nft: &mut Collection<C>,
        ctx: &mut TxContext,
    ) {
        attribution::assert_is_creator(
            collection::borrow_domain<C, AttributionDomain>(nft),
            tx_context::sender(ctx)
        );

        let domain = collection::borrow_domain_mut<C, RoyaltyDomain, Witness>(Witness {}, nft);

        bag::remove<Marker<ConstantRoyaltyStrategy>, ConstantRoyaltyStrategy>(
            &mut domain.strategies,
            utils::marker<ConstantRoyaltyStrategy>()
        );
    }

    /// === Utils ===

    public fun transfer_royalties<FT>(
        domain: &mut RoyaltyDomain,
        source: &mut Balance<FT>,
        amount: u64,
    ) {
        let b = balance::split(source, amount);

        if (!bag::contains_with_type<utils::Marker<Balance<FT>>, Balance<FT>>(
            &domain.aggregations,
            utils::marker<Balance<FT>>()
        )) {
            bag::add(
                &mut domain.aggregations,
                utils::marker<Balance<FT>>(),
                balance::zero<FT>(),
            );
        };

        let aggregate = bag::borrow_mut(
            &mut domain.aggregations,
            utils::marker<Balance<FT>>()
        );

        balance::join(aggregate, b);
    }

    /// === Interoperability ===

    public fun royalty_domain<C>(
        collection: &Collection<C>,
    ): &RoyaltyDomain {
        collection::borrow_domain(collection)
    }

    public fun royalty_domain_mut<C>(
        collection: &mut Collection<C>,
    ): &mut RoyaltyDomain {
        collection::borrow_domain_mut(Witness {}, collection)
    }

    public fun add_royalty_domain<C>(
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ) {
        collection::add_domain(collection, new(ctx));
    }

    public entry fun distribute_royalties<C, FT>(
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ) {
        let royalty = royalty_domain_mut(collection);
        let attributions: &AttributionDomain =
            collection::borrow_domain(collection);

        let aggregate: &mut Balance<FT> = bag::borrow_mut(
            &mut royalty.aggregations,
            utils::marker<Balance<FT>>(),
        );

        attribution::distribute_royalties(
            attributions,
            aggregate,
            ctx
        );
    }
}
