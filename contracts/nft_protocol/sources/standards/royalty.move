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
/// The module relies on an external contract to drive the royalty gathering.
module nft_protocol::royalty {
    use sui::balance::{Self, Balance};
    use sui::coin;
    use sui::dynamic_field as df;
    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::vec_set::{Self, VecSet};

    use ob_utils::utils::{Self, marker, Marker};
    use ob_utils::math;
    use ob_permissions::witness;

    use nft_protocol::collection::{Self, Collection};

    /// Field object `RoyaltyDomain` already defined as dynamic field.
    const EExistingRoyalty: u64 = 1;

    /// Plugins was not defined on `RoyaltyDomain`
    const EUndefinedRoyalty: u64 = 2;

    /// Address was not attributed
    const EUndefinedAddress: u64 = 3;

    /// Addres was already attributed
    const EExistingAddress: u64 = 4;

    /// Address did not have enough shares
    const ENotEnoughShares: u64 = 5;

    /// Invalid total number of shares
    const EInvalidTotal: u64 = 6;

    /// `RoyaltyDomain` stores royalties for `Collection` and
    /// distributes them among creators.
    struct RoyaltyDomain has store {
        /// Royalty strategies
        strategies: VecSet<ID>,
        /// Aggregates received royalties across different coins
        aggregations: UID,
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
        royalty_shares_bps: VecMap<address, u16>, ctx: &mut TxContext,
    ): RoyaltyDomain {
        assert_total_shares(&royalty_shares_bps);
        RoyaltyDomain {
            strategies: vec_set::empty(),
            aggregations: object::new(ctx),
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
            EUndefinedAddress,
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
            EUndefinedAddress,
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

        assert!(*creator_share >= share, ENotEnoughShares);

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

    /// Informs the client about the royalty strategy.
    public fun remove_strategy(domain: &mut RoyaltyDomain, strategy: ID) {
        vec_set::remove(&mut domain.strategies, &strategy);
    }

    /// Informs the client about the royalty strategy.
    public fun add_strategy(domain: &mut RoyaltyDomain, strategy: ID) {
        vec_set::insert(&mut domain.strategies, strategy);
    }

    /// Returns the list of royalty strategies registered on the `RoyaltyDomain`
    public fun strategies(domain: &RoyaltyDomain): &VecSet<ID> { &domain.strategies }

    // === Utils ===

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Collects an `amount` of tokens from the provided balance into the
    /// aggregate balance of the `RoyaltyDomain` registered on the `Collection`
    ///
    /// Requires that a `RoyaltyDomain` is registered on the collection
    public fun collect_royalty<T, FT>(
        collection: &mut Collection<T>,
        source: &mut Balance<FT>,
        amount: u64,
    ) {
        let delegated_witness = witness::from_witness(Witness {});

        let domain: &mut RoyaltyDomain =
            collection::borrow_domain_mut(delegated_witness, collection);

        let aggregations = &mut domain.aggregations;

        let b = balance::split(source, amount);

        if (!df::exists_with_type<Marker<Balance<FT>>, Balance<FT>>(
            aggregations, marker<Balance<FT>>()
        )) {
            df::add(
                aggregations,
                marker<Balance<FT>>(),
                balance::zero<FT>(),
            );
        };

        let aggregate = df::borrow_mut(
            aggregations,
            marker<Balance<FT>>()
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
    /// Panics if there is no aggregate for token `FT`.\
    public fun distribute_royalties<T, FT>(
        collection: &mut Collection<T>,
        ctx: &mut TxContext,
    ) {
        let delegated_witness = witness::from_witness(Witness {});
        let domain: &mut RoyaltyDomain =
            collection::borrow_domain_mut(delegated_witness, collection);

        let shares = &domain.royalty_shares_bps;
        let aggregate: &mut Balance<FT> = df::borrow_mut(
            &mut domain.aggregations,
            marker<Balance<FT>>(),
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
        let balance_value = balance::value(aggregate);

        let i = 0;
        while (i < vec_map::size(shares)) {
            let (who, share) = vec_map::get_entry_by_idx(shares, i);

            // Truncates fractional part of the result thus ensuring that sum
            // of royalty shares is not greater than total balance.
            let (_, rate) = math::div_round((*share as u64), (utils::bps() as u64));

            let (_, owed_royalty) = math::mul_round(
                rate, balance_value
            );

            if (owed_royalty != 0) {
                let wallet = coin::from_balance(
                    balance::split(aggregate, owed_royalty),
                    ctx,
                );

                transfer::public_transfer(wallet, *who);
            };

            i = i + 1;
        };
    }

    // === Interoperability ===

    /// Returns whether `RoyaltyDomain` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<RoyaltyDomain>, RoyaltyDomain>(
            nft, marker(),
        )
    }

    /// Borrows `RoyaltyDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `RoyaltyDomain` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &RoyaltyDomain {
        assert_royalty(nft);
        df::borrow(nft, marker<RoyaltyDomain>())
    }

    /// Mutably borrows `RoyaltyDomain` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `RoyaltyDomain` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut RoyaltyDomain {
        assert_royalty(nft);
        df::borrow_mut(nft, marker<RoyaltyDomain>())
    }

    /// Adds `RoyaltyDomain` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `RoyaltyDomain` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: RoyaltyDomain,
    ) {
        assert_no_royalty(nft);
        df::add(nft, marker<RoyaltyDomain>(), domain);
    }

    /// Remove `Plugins` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Plugins` domain doesnt exist
    public fun remove_domain(nft: &mut UID): RoyaltyDomain {
        assert_royalty(nft);
        df::remove(nft, marker<RoyaltyDomain>())
    }

    // === Assertions ===

    /// Asserts that no share attributions exist
    fun assert_empty(domain: &RoyaltyDomain) {
        assert!(!contains_shares(domain), EExistingAddress)
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

        assert!(bps_total == utils::bps(), EInvalidTotal);
    }

    /// Asserts that `RoyaltyDomain` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `RoyaltyDomain` is not registered
    public fun assert_royalty(nft: &UID) {
        assert!(has_domain(nft), EUndefinedRoyalty);
    }

    /// Asserts that `RoyaltyDomain` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `RoyaltyDomain` is registered
    public fun assert_no_royalty(nft: &UID) {
        assert!(!has_domain(nft), EExistingRoyalty);
    }

    // === Tests ===

    #[test_only]
    use ob_pseudorandom::pseudorandom;

    #[test_only]
    fun check_sum(vec: vector<u64>, total: u64) {
        let sum = utils::sum_vector(vec);
        assert!(sum == total, 0);
    }

    #[test]
    fun test_precision() {
        // Round 1
        let balance_value = 100_000_000_0000;

        // 100% royalties
        let share_1 = 3_333;
        let share_2 = 3_333;
        let share_3 = 3_334;

        let (_, rate_1) = math::div_round((share_1 as u64), (utils::bps() as u64));
        let (_, rate_2) = math::div_round((share_2 as u64), (utils::bps() as u64));
        let (_, rate_3) = math::div_round((share_3 as u64), (utils::bps() as u64));

        let (_, royalty_1) = math::mul_round(rate_1, balance_value);
        let (_, royalty_2) = math::mul_round(rate_2, balance_value);
        let (_, royalty_3) = math::mul_round(rate_3, balance_value);

        check_sum(vector[ royalty_1, royalty_2, royalty_3], balance_value);
    }

    #[test]
    fun fuzzy_test() {
        let balance_value = 100_000_000_0000;

        let limit = 10_000;
        let i = 0;

        let seed = pseudorandom::rand_with_nonce(b"Some random seedSome random seed");

        while (i < limit) {
            let share_1 = pseudorandom::select_u64(10_000, &seed);
            let share_2 = pseudorandom::select_u64(10_000 - share_1, &seed);
            let share_3 = 10_000 - share_1 - share_2;

            assert!(share_1 + share_2 + share_3 == 10_000, 0);

            let (_, rate_1) = math::div_round((share_1 as u64), (utils::bps() as u64));
            let (_, rate_2) = math::div_round((share_2 as u64), (utils::bps() as u64));
            let (_, rate_3) = math::div_round((share_3 as u64), (utils::bps() as u64));

            let (_, royalty_1) = math::mul_round(rate_1, balance_value);
            let (_, royalty_2) = math::mul_round(rate_2, balance_value);
            let (_, royalty_3) = math::mul_round(rate_3, balance_value);

            check_sum(vector[ royalty_1, royalty_2, royalty_3], balance_value);

            i = i + 1;
        };
    }

}
