// TODO: Constant Royalty domain
// TODO: Another royalty domain type mechanism could be such that the domain
// has a dynamic objects with relevant Balance<FT> into which these are stored.
module nft_protocol::royalty {
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use sui::bag::{Self, Bag};

    use nft_protocol::nft::{Self, NFT};
    use nft_protocol::collection::{Self, Collection};

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::attribution::{Self, AttributionDomain, Creator};
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

    /// Calculate owed royalties from all the strategies defined on the domain
    fun calculate(domain: &RoyaltyDomain, amount: u64): u64 {
        let royalty = 0;

        let bps_strategy = utils::marker<BpsRoyaltyStrategy>();
        if (
            bag::contains_with_type<
                Marker<BpsRoyaltyStrategy>, BpsRoyaltyStrategy
            >(&domain.strategies, bps_strategy)
        ) {
            let strategy: &BpsRoyaltyStrategy = bag::borrow(
                &domain.strategies,
                bps_strategy,
            );
            royalty = royalty +
                royalty_strategy_bps::calculate(strategy, amount);
        };

        let constant_strategy = utils::marker<ConstantRoyaltyStrategy>();
        if (
            bag::contains_with_type<
                Marker<ConstantRoyaltyStrategy>, ConstantRoyaltyStrategy
            >(&domain.strategies, constant_strategy)
        ) {
            let strategy: &ConstantRoyaltyStrategy = bag::borrow(
                &domain.strategies,
                constant_strategy
            );
            royalty = royalty + royalty_strategy_constant::calculate(strategy);
        };

        royalty
    }

    public fun transfer_royalties<FT>(
        domain: &mut RoyaltyDomain,
        source: &mut Balance<FT>,
        amount: u64,
    ) {
        let royalty_owed = calculate(domain, amount);
        let b = balance::split(source, royalty_owed);

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
        nft: &NFT<C>,
    ): &RoyaltyDomain {
        nft::borrow_domain(nft)
    }

    public fun collection_royalty_domain<C>(
        nft: &Collection<C>,
    ): &RoyaltyDomain {
        collection::borrow_domain(nft)
    }

    public fun royalty_domain_mut<C>(
        nft: &mut NFT<C>,
    ): &mut RoyaltyDomain {
        nft::borrow_domain_mut(Witness {}, nft)
    }

    public fun collection_royalty_domain_mut<C>(
        nft: &mut Collection<C>,
    ): &mut RoyaltyDomain {
        collection::borrow_domain_mut(Witness {}, nft)
    }

    public fun add_royalty_domain<C>(
        nft: &mut NFT<C>,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(nft, new(ctx), ctx);
    }

    public fun add_collection_royalty_domain<C>(
        nft: &mut Collection<C>,
        ctx: &mut TxContext,
    ) {
        collection::add_domain(nft, new(ctx));
    }
}
