// TODO: Constant Royalty domain
// TODO: Another royalty domain type mechanism could be such that the domain
// has a dynamic objects with relevant Balance<FT> into which these are stored.
module nft_protocol::royalty {
    use std::option;

    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use sui::bag::{Self, Bag};

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::attribution::{Self, Attributions, Creator};
    use nft_protocol::royalty_strategy_bps::{Self, BpsRoyaltyStrategy};
    use nft_protocol::royalty_strategy_constant::{
        Self, ConstantRoyaltyStrategy
    };

    struct RoyaltyDomain has store {
        /// Royalty attributions
        attributions: Attributions,
        /// Royalty strategies
        strategies: Bag,
        /// Aggregates received royalties across different coins
        aggregations: Bag,
    }

    public fun attributions(domain: &RoyaltyDomain): &Attributions {
        &domain.attributions
    }

    public fun attributions_mut(domain: &mut RoyaltyDomain): &mut Attributions {
        &mut domain.attributions
    }

    public fun contains_attribution(domain: &RoyaltyDomain, who: address): bool {
        option::is_some(&attribution::index(&domain.attributions, who))
    }

    // TODO: Discuss empty attributions
    // /// Creates a `RoyaltyDomain` object with no creator attributions.
    // ///
    // /// By not attributing any `Creators`, nobody will ever be able to claim
    // /// royalties from this `Attributions` object.
    // public fun unattributed(ctx: &mut TxContext): RoyaltyDomain {
    //     RoyaltyDomain {
    //         id: object::new(ctx),
    //         aggregator: balance::zero(),
    //         attributions: attribution::empty(),
    //     }
    // }

    /// Creates a `RoyaltyDomain` object with a single creator attribution.
    public fun from_address(who: address, ctx: &mut TxContext): RoyaltyDomain {
        RoyaltyDomain {
            attributions: attribution::from_address(who),
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
            attributions: attribution::from_creators(creators),
            strategies: bag::new(ctx),
            aggregations: bag::new(ctx),
        }
    }

    /// === Royalties ===

    public fun add_proportional_royalty(
        domain: &mut RoyaltyDomain,
        strategy: BpsRoyaltyStrategy,
        ctx: &mut TxContext,
    ) {
        assert_is_creator(domain, tx_context::sender(ctx));

        bag::add(
            &mut domain.strategies,
            utils::marker<BpsRoyaltyStrategy>(),
            strategy
        );
    }

    public fun add_constant_royalty<FT>(
        domain: &mut RoyaltyDomain,
        strategy: ConstantRoyaltyStrategy,
        ctx: &mut TxContext,
    ) {
        assert_is_creator(domain, tx_context::sender(ctx));

        bag::add(
            &mut domain.strategies,
            utils::marker<ConstantRoyaltyStrategy>(),
            strategy
        );
    }

    // Take owned value to only allow calling during construction
    public fun remove_proportional_royalty(
        domain: &mut RoyaltyDomain,
        ctx: &mut TxContext,
    ) {
        assert_is_creator(domain, tx_context::sender(ctx));

        bag::remove<Marker<BpsRoyaltyStrategy>, BpsRoyaltyStrategy>(
            &mut domain.strategies,
            utils::marker<BpsRoyaltyStrategy>()
        );
    }

    // Take owned value to only allow calling during construction
    public fun remove_constant_royalty<FT>(
        domain: &mut RoyaltyDomain,
        ctx: &mut TxContext,
    ) {
        assert_is_creator(domain, tx_context::sender(ctx));

        bag::remove<Marker<ConstantRoyaltyStrategy>, ConstantRoyaltyStrategy>(
            &mut domain.strategies,
            utils::marker<ConstantRoyaltyStrategy>()
        );
    }

    /// === Interoperability ===

    /// Calculate owed royalties from all the strategies defined on the domain
    public fun calculate(domain: &RoyaltyDomain, amount: u64): u64 {
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

    /// === Utils ===

    public fun assert_is_creator(domain: &RoyaltyDomain, who: address ) {
        attribution::assert_is_creator(&domain.attributions, who);
    }

    struct Witness has drop {}

    // `RoyaltyDomain` handles mutable access safely
    public fun witness(): Witness {
        Witness {}
    }
}
