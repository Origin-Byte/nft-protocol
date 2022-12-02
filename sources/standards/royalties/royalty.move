// TODO: Constant Royalty domain
// TODO: Another royalty domain type mechanism could be such that the domain
// has a dynamic objects with relevant Balance<FT> into which these are stored.
module nft_protocol::royalty {
    use std::option;

    use sui::balance::{Self, Balance};
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::dynamic_field::{Self as df};

    use nft_protocol::attribution::{Self, Attributions, Creator};
    use nft_protocol::royalty_strategy_bps::{Self, BpsRoyaltyStrategy};
    use nft_protocol::royalty_strategy_constant::{
        Self, ConstantRoyaltyStrategy
    };

    struct RoyaltyDomain<phantom FT> has key, store {
        id: UID,
        /// Aggregates received royalties
        aggregator: Balance<FT>,
        /// Royalty attributions
        attributions: Attributions,
    }

    public fun attributions<FT>(domain: &RoyaltyDomain<FT>): &Attributions {
        &domain.attributions
    }

    public fun attributions_mut<FT>(domain: &mut RoyaltyDomain<FT>): &mut Attributions {
        &mut domain.attributions
    }

    public fun contains_attribution<FT>(domain: &RoyaltyDomain<FT>, who: address): bool {
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
    public fun from_address<FT>(who: address, ctx: &mut TxContext): RoyaltyDomain<FT> {
        RoyaltyDomain {
            id: object::new(ctx),
            aggregator: balance::zero(),
            attributions: attribution::from_address(who),
        }
    }

    /// Creates a `RoyaltyDomain` object with provided creator attributions.
    public fun from_creators<FT>(
        creators: vector<Creator>,
        ctx: &mut TxContext
    ): RoyaltyDomain<FT> {
        RoyaltyDomain {
            id: object::new(ctx),
            aggregator: balance::zero(),
            attributions: attribution::from_creators(creators),
        }
    }

    /// === Royalties ===

    // Take owned value to only allow calling during construction
    public fun use_proportional_royalty<FT>(
        domain: RoyaltyDomain<FT>,
        strategy: BpsRoyaltyStrategy
    ): RoyaltyDomain<FT> {
        df::add(&mut domain.id, royalty_strategy_bps::name(), strategy);
        domain
    }

    // Take owned value to only allow calling during construction
    public fun use_constant_royalty<FT>(
        domain: RoyaltyDomain<FT>,
        strategy: ConstantRoyaltyStrategy
    ): RoyaltyDomain<FT> {
        df::add(&mut domain.id, royalty_strategy_constant::name(), strategy);
        domain
    }

    /// Calculate owed royalties from all the strategies defined on the domain
    public fun calculate<FT>(domain: &RoyaltyDomain<FT>, amount: u64): u64 {
        let royalty = 0;

        let bps_strategy_name = royalty_strategy_bps::name();
        if (df::exists_with_type<vector<u8>, BpsRoyaltyStrategy>(
            &domain.id,
            bps_strategy_name
        )) {
            let strategy = df::borrow<vector<u8>, BpsRoyaltyStrategy>(
                &domain.id,
                bps_strategy_name
            );
            royalty = royalty +
                royalty_strategy_bps::calculate(strategy, amount);
        };

        let constant_strategy_name = royalty_strategy_constant::name();
        if (df::exists_with_type<vector<u8>, ConstantRoyaltyStrategy>(
            &domain.id,
            constant_strategy_name
        )) {
            let strategy = df::borrow<vector<u8>, ConstantRoyaltyStrategy>(
                &domain.id,
                constant_strategy_name
            );
            royalty = royalty + royalty_strategy_constant::calculate(strategy);
        };

        royalty
    }

    public fun transfer_royalties<FT>(
        domain: &mut RoyaltyDomain<FT>,
        source: &mut Balance<FT>,
        amount: u64,
    ) {
        let royalty_owed = calculate(domain, amount);
        let b = balance::split(source, royalty_owed);
        balance::join(&mut domain.aggregator, b);
    }

    /// === Interoperability ===

    struct Witness has drop {}

    // `RoyaltyDomain` handles mutable access safely
    public fun witness(): Witness {
        Witness {}
    }
}
