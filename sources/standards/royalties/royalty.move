/// Module of Collection `RoyaltyDomain`
///
/// `RoyaltyDomain` allows creators to define custom royalty strategies,
/// collect royalties for their collections. Additionally, creators and their
/// respective royalty share are tracked.
///
/// `royalty` does not provide a generic `calculate` function that takes into
/// account all royalty strategies defined on the domain, as the OriginByte
/// standard does not know how to read strategies not otherwise defined by it.
///
/// The module relies on an external contract to drive the royalty gathering
/// and dirtribution flow.
module nft_protocol::royalty {
    use std::fixed_point32;

    use sui::coin;
    use sui::transfer;
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use sui::bag::{Self, Bag};
    use sui::vec_map::{Self, VecMap};
    use sui::object::{Self, UID};

    use nft_protocol::err;
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::creators;
    use nft_protocol::royalty_strategy_bps::{Self, BpsRoyaltyStrategy};
    use nft_protocol::collection::{Self, Collection, MintCap};
    use nft_protocol::royalty_strategy_constant::{
        Self, ConstantRoyaltyStrategy
    };

    // === RoyaltyDomain ===

    /// `RoyaltyDomain` stores royalty strategies for `Collection` and
    /// distributes them among creators
    ///
    /// ##### Usage
    ///
    /// `RoyaltyDomain` can only calculate royalties owed and distribute them
    /// to shareholders, as a result, it relies on trusted price execution.
    ///
    /// The usage example shows how to derive the owed royalties from the
    /// example collection, `Suimarines`, which uses `TradePayment` as the
    /// price oracle, but is also responsible for deconstructing it. For more
    /// information read [royalties](./royalties.html).
    ///
    /// ```
    /// module nft_protocol::suimarines {
    ///     struct Witness has drop {}
    ///
    ///     public entry fun collect_royalty<FT>(
    ///         payment: &mut TradePayment<SUIMARINES, FT>,
    ///         collection: &mut Collection<SUIMARINES>,
    ///         ctx: &mut TxContext,
    ///     ) {
    ///         let b = royalties::balance_mut(Witness {}, payment);
    ///
    ///         let domain = royalty::royalty_domain(collection);
    ///         let royalty_owed =
    ///             royalty::calculate_proportional_royalty(domain, balance::value(b));
    ///
    ///         royalty::collect_royalty(collection, b, royalty_owed);
    ///         royalties::transfer_remaining_to_beneficiary(Witness {}, payment, ctx);
    ///     }
    /// }
    /// ```
    struct RoyaltyDomain has key, store {
        /// `RoyaltyDomain` ID
        id: UID,
        /// Royalty strategies
        strategies: Bag,
        /// Aggregates received royalties across different coins
        aggregations: Bag,
        /// Royalty share received by addresses
        royalty_shares_bps: VecMap<address, u16>,
    }

    /// Creates an empty `RoyaltyDomain` object
    ///
    /// By not attributing any addresses, nobody will ever be able to claim
    /// royalties from this `RoyaltyDomain` object.
    public fun new_empty(ctx: &mut TxContext): RoyaltyDomain {
        from_shares(vec_map::empty(), ctx)
    }

    /// Creates a `RoyaltyDomain` object with only one address attribution
    ///
    /// Only the single address will be able to claim royalties from this
    /// `RoyaltyDomain` object.
    public fun from_address(who: address, ctx: &mut TxContext): RoyaltyDomain {
        let shares = vec_map::empty();
        vec_map::insert(&mut shares, who, utils::bps());

        from_shares(shares, ctx)
    }

    /// Creates a `RoyaltyDomain` with multiple attributions
    ///
    /// Attributed addresses will be able to claim royalties weighted by their
    /// share in the total royalties.
    ///
    /// ##### Panics
    ///
    /// Panics if total sum of creator basis point share is not equal to 10000
    public fun from_shares(
        royalty_shares_bps: VecMap<address, u16>,
        ctx: &mut TxContext,
    ): RoyaltyDomain {
        assert_total_shares(&royalty_shares_bps);
        RoyaltyDomain {
            id: object::new(ctx),
            strategies: bag::new(ctx),
            aggregations: bag::new(ctx),
            royalty_shares_bps,
        }
    }

    // === Shares ===

    /// Returns the `Creator` type for the given address
    ///
    /// ##### Panics
    ///
    /// Panics if the provided address is not an attributed creator
    public fun borrow_share(domain: &RoyaltyDomain, who: &address): &u16 {
        assert!(
            vec_map::contains(&domain.royalty_shares_bps, who),
            err::address_not_attributed()
        );
        vec_map::get(&domain.royalty_shares_bps, who)
    }

    /// Returns a mutable reference to the `Creator` type for the given address
    ///
    /// ##### Panics
    ///
    /// Panics if the provided address is not an attributed creator
    fun borrow_share_mut(domain: &mut RoyaltyDomain, who: &address): &mut u16 {
        assert!(
            vec_map::contains(&domain.royalty_shares_bps, who),
            err::address_not_attributed()
        );
        vec_map::get_mut(&mut domain.royalty_shares_bps, who)
    }

    /// Returns true when address is a defined creator
    public fun contains_share(domain: &RoyaltyDomain, who: &address): bool {
        vec_map::contains(&domain.royalty_shares_bps, who)
    }

    /// Returns true when a share attribution exists
    public fun contains_shares(domain: &RoyaltyDomain): bool {
        !vec_map::is_empty(&domain.royalty_shares_bps)
    }

    /// Returns the list of creators defined on the `CreatorsDomain`
    public fun borrow_shares(domain: &RoyaltyDomain): &VecMap<address, u16> {
        &domain.royalty_shares_bps
    }

    /// Attribute a share of royalties to an address
    ///
    /// This must be done by an address which already has an attribution and
    /// partially gives up a share of their royalties for the benefit of the
    /// new attribution. Ensures that the total sum of shares remains constant.
    ///
    /// ##### Panics
    ///
    /// Panics if the transaction sender does not have a large enough royalty
    /// share to transfer to the new creator or is not attributed in the first
    /// place.
    //
    // TODO: Add share method for empty RoyaltyDomain controlled by
    // CreatorsDomain
    public fun add_share(
        domain: &mut RoyaltyDomain,
        who: address,
        share: u16,
        ctx: &mut TxContext,
    ) {
        // Asserts that sender is a creator
        let creator = tx_context::sender(ctx);
        let creator_share = borrow_share_mut(domain, &creator);

        assert!(
            *creator_share >= share,
            err::address_does_not_have_enough_shares()
        );

        *creator_share = *creator_share - share;

        if (*creator_share == 0) {
            vec_map::remove(&mut domain.royalty_shares_bps, &who);
        };

        if (contains_share(domain, &who)) {
            let beneficiary_share = borrow_share_mut(domain, &who);
            *beneficiary_share = *beneficiary_share + share;
        } else {
            vec_map::insert(&mut domain.royalty_shares_bps, who, share);
        }
    }

    /// Attribute royalties to an address
    ///
    /// ##### Panics
    ///
    /// Panics if a share attribution already exists
    public fun add_share_to_empty(
        domain: &mut RoyaltyDomain,
        who: address,
    ) {
        assert_empty(domain);

        let shares = vec_map::empty();
        vec_map::insert(&mut shares, who, utils::bps());

        domain.royalty_shares_bps = shares;
    }

    /// Attribute royalties to addresses
    ///
    /// ##### Panics
    ///
    /// Panics if a share attribution already exists
    public fun add_shares_to_empty(
        domain: &mut RoyaltyDomain,
        royalty_shares_bps: VecMap<address, u16>,
    ) {
        assert_empty(domain);
        assert_total_shares(&royalty_shares_bps);
        domain.royalty_shares_bps = royalty_shares_bps;
    }

    /// Remove a share attribution from an address and transfer attribution to
    /// another address
    ///
    /// Shares of the removed attribution are allocated to the provided
    /// address, ensures that the total sum of shares remains constant.
    ///
    /// ##### Panics
    ///
    /// Panics if attempting to remove attribution which doesn't belong to the
    /// transaction sender
    public fun remove_creator_by_transfer(
        domain: &mut RoyaltyDomain,
        to: address,
        ctx: &mut TxContext,
    ) {
        // Asserts that sender is a creator
        let (_, share) = vec_map::remove(
            &mut domain.royalty_shares_bps,
            &tx_context::sender(ctx)
        );

        // Get creator to which shares will be transfered
        if (contains_share(domain, &to)) {
            let beneficiary_share = borrow_share_mut(domain, &to);
            *beneficiary_share = *beneficiary_share + share;
        } else {
            vec_map::insert(&mut domain.royalty_shares_bps, to, share);
        }
    }

    // === Royalties ===

    /// Add a generic royalty strategy
    ///
    /// Royalty strategies which are not part of the OriginByte standard must
    /// implement their own calculation methods. Prefer using
    /// `add_proportional_royalty` and `add_constant_royalty` if only adding
    /// standard royalty strategies.
    ///
    /// ##### Panics
    ///
    /// Panics if royalty strategy of the same type was already registered
    public fun add_royalty_strategy<Strategy: drop + store>(
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
    ///
    /// Prefer using `remove_proportional_royalty` and
    /// `remove_constant_royalty` if only removing standard royalty strategies.
    ///
    /// ##### Panics
    ///
    /// Panics if strategy was not defined
    public fun remove_strategy<Strategy: drop + store>(
        domain: &mut RoyaltyDomain,
    ): Strategy {
        bag::remove(&mut domain.strategies, utils::marker<Strategy>())
    }

    /// Check whether a royalty strategy is defined
    public fun contains_strategy<Strategy: drop + store>(
        domain: &RoyaltyDomain,
    ): bool {
        bag::contains_with_type<Marker<Strategy>, Strategy>(
            &domain.strategies, utils::marker<Strategy>()
        )
    }

    /// Borrow a royalty strategy
    ///
    /// ##### Panics
    ///
    /// Panics if strategy was not defined
    public fun borrow_strategy<Strategy: drop + store>(
        domain: &RoyaltyDomain,
    ): &Strategy {
        bag::borrow(
            &domain.strategies,
            utils::marker<Strategy>(),
        )
    }

    /// Mutably borrow a royalty strategy
    ///
    /// ##### Panics
    ///
    /// Panics if strategy was not defined
    public fun borrow_strategy_mut<Strategy: drop + store>(
        domain: &mut RoyaltyDomain,
    ): &mut Strategy {
        bag::borrow_mut(&mut domain.strategies, utils::marker<Strategy>())
    }

    // === Standard royalty domains ===

    /// Add proportional royalty policy
    public fun add_proportional_royalty(
        domain: &mut RoyaltyDomain,
        royalty_fee_bps: u64,
    ) {
        let strategy = royalty_strategy_bps::new(royalty_fee_bps);
        add_royalty_strategy(domain, strategy);
    }

    /// Add constant royalty policy
    public fun add_constant_royalty(
        domain: &mut RoyaltyDomain,
        royalty_fee: u64,
    ) {
        let strategy = royalty_strategy_constant::new(royalty_fee);
        add_royalty_strategy(domain, strategy);
    }

    /// Remove proportional royalty policy
    public fun remove_proportional_royalty(
        domain: &mut RoyaltyDomain,
    ): BpsRoyaltyStrategy {
        remove_strategy<BpsRoyaltyStrategy>(domain)
    }

    /// Remove constant royalty policy
    public fun remove_constant_royalty(
        domain: &mut RoyaltyDomain,
    ): ConstantRoyaltyStrategy {
        remove_strategy<ConstantRoyaltyStrategy>(domain)
    }

    /// Calculate how many tokens are due for the defined proportional royalty
    /// strategy.
    ///
    /// Zero if strategy is undefined.
    public fun calculate_proportional_royalty(
        domain: &RoyaltyDomain,
        amount: u64,
    ): u64 {
        let strategy = borrow_strategy<BpsRoyaltyStrategy>(domain);
        royalty_strategy_bps::calculate(strategy, amount)
    }

    /// Calculate how many tokens are due for the defined constant royalty
    /// strategy.
    ///
    /// Zero if strategy is undefined.
    public fun calculate_constant_royalty(
        domain: &RoyaltyDomain,
    ): u64 {
        let strategy = borrow_strategy<ConstantRoyaltyStrategy>(domain);
        royalty_strategy_constant::calculate(strategy)
    }

    // === Utils ===

    /// Witness used to authenticate witness protected endpoints
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

    /// Distributes the aggregated royalties for fungible token, `FT`, among
    /// the creators defined in `CreatorsDomain`.
    ///
    /// This endpoint is permissionless and can be called by anyone.
    ///
    /// ##### Panics
    ///
    /// Panics if there is no aggregate for token `FT`.
    public entry fun distribute_royalties<C, FT>(
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ) {
        let domain: &mut RoyaltyDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        let shares = &domain.royalty_shares_bps;
        let aggregate: &mut Balance<FT> = bag::borrow_mut(
            &mut domain.aggregations,
            utils::marker<Balance<FT>>(),
        );

        distribute_balance(shares, aggregate, ctx);
    }

    /// Distributes the contents of a `Balance<FT>` among the addresses defined
    /// in `VecMap<address, u16>`
    ///
    /// `VecMap<address, u16>` is treated as the basis point share in total
    /// royalties due to the address.
    public fun distribute_balance<FT>(
        shares: &VecMap<address, u16>,
        aggregate: &mut Balance<FT>,
        ctx: &mut TxContext,
    ) {
        // balance * share_of_royalty_bps / BPS
        let total = fixed_point32::create_from_rational(
            balance::value(aggregate),
            (utils::bps() as u64)
        );

        let i = 0;
        while (i < vec_map::size(shares)) {
            let (who, share) = vec_map::get_entry_by_idx(shares, i);

            // Truncates fractional part of the result thus ensuring that sum
            // of royalty shares is not greater than total balance.
            let owed_royalty = fixed_point32::multiply_u64(
                (*share as u64),
                total,
            );

            if (owed_royalty != 0) {
                let wallet = coin::from_balance(
                    balance::split(aggregate, owed_royalty),
                    ctx,
                );

                transfer::transfer(wallet, *who);
            };

            i = i + 1;
        };
    }

    // === Interoperability ===

    /// Get reference to `RoyaltyDomain`
    public fun royalty_domain<C>(
        collection: &Collection<C>,
    ): &RoyaltyDomain {
        collection::borrow_domain(collection)
    }

    /// Get mutable reference to `RoyaltyDomain`
    ///
    /// Requires that `CreatorsDomain` is defined and sender is a creator
    public fun royalty_domain_mut<C>(
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ): &mut RoyaltyDomain {
        creators::assert_collection_has_creator(
            collection, &tx_context::sender(ctx)
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

    // === Utils ===

    /// Asserts that no share attributions exist
    fun assert_empty(domain: &RoyaltyDomain) {
        assert!(!contains_shares(domain), err::share_attribution_already_exists())
    }

    /// Asserts that total shares add up to 10000 basis points or no shares
    /// exist
    ///
    /// ##### Panics
    ///
    /// Panics if shares do not add up to 10000 basis points
    fun assert_total_shares(shares: &VecMap<address, u16>) {
        let bps_total = 0;

        if (vec_map::is_empty(shares)) {
            return
        };

        let i = 0;
        while (i < vec_map::size(shares)) {
            let (_, share) = vec_map::get_entry_by_idx(shares, i);
            bps_total = bps_total + *share;
            i = i + 1;
        };

        assert!(bps_total == utils::bps(), err::invalid_total_share_of_royalties());
    }
}
