module nft_protocol::attribution {
    use std::fixed_point32;

    use sui::coin;
    use sui::transfer;
    use sui::vec_map::{Self, VecMap};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::collection::{Self, Collection};

    /// === Creator ===

    /// Creator struct which holds the addresses of the creators of the NFT
    /// Collection, as well their share of the royalties collected.
    struct Creator has store, copy, drop {
        who: address,
        share_of_royalty_bps: u16,
    }

    public fun new_creator(who: address, share_of_royalty_bps: u16): Creator {
        Creator { who, share_of_royalty_bps }
    }

    public fun who(creator: &Creator): address {
        creator.who
    }

    public fun share_of_royalty_bps(creator: &Creator): u16 {
        creator.share_of_royalty_bps
    }

    /// === AttributionDomain ===

    const BPS: u16 = 10_000;

    struct AttributionDomain has copy, drop, store {
        /// Address that receives the mint and trade royalties
        creators: VecMap<address, Creator>,
    }

    /// Creates an empty `Attributions` object
    ///
    /// By not attributing any `Creators`, nobody will ever be able to claim
    /// royalties from this `Attributions` object or modify it's domains.
    public fun empty(): AttributionDomain {
        AttributionDomain { creators: vec_map::empty() }
    }

    public fun from_address(who: address): AttributionDomain {
        let domain = empty();
        vec_map::insert(&mut domain.creators, who, new_creator(who, BPS));
        domain
    }

    public fun from_creators(
        creators: VecMap<address, Creator>
    ): AttributionDomain {
        let attributions = AttributionDomain { creators };
        assert_total_shares(&attributions);

        attributions
    }

    public fun is_empty(attributions: &AttributionDomain): bool {
        vec_map::is_empty(&attributions.creators)
    }

    public fun creators(
        attributions: &AttributionDomain
    ): &VecMap<address, Creator> {
        &attributions.creators
    }

    public fun get(
        attributions: &AttributionDomain,
        who: &address,
    ): &Creator {
        assert!(
            vec_map::contains(&attributions.creators, who),
            err::address_not_attributed()
        );
        vec_map::get(&attributions.creators, who)
    }

    fun get_mut(
        attributions: &mut AttributionDomain,
        who: address,
    ): &mut Creator {
        assert!(
            vec_map::contains(&attributions.creators, &who),
            err::address_not_attributed()
        );
        vec_map::get_mut(&mut attributions.creators, &who)
    }

    /// === Mutability ===

    /// Add a `Creator` to attributions
    ///
    /// This must be done by a `Creator` which already has an attribution who
    /// gives up an arithmetic share of their royalty share.
    public fun add_creator(
        attributions: &mut AttributionDomain,
        new_creator: Creator,
        ctx: &mut TxContext,
    ) {
        // Asserts that sender is a creator
        let creator = get_mut(attributions, tx_context::sender(ctx));

        assert!(
            creator.share_of_royalty_bps >= new_creator.share_of_royalty_bps,
            err::address_does_not_have_enough_shares()
        );

        creator.share_of_royalty_bps =
            creator.share_of_royalty_bps - new_creator.share_of_royalty_bps;

        if (creator.share_of_royalty_bps == 0) {
            let who = creator.who;
            vec_map::remove(&mut attributions.creators, &who);
        };

        vec_map::insert(&mut attributions.creators, new_creator.who, new_creator);
    }

    /// Remove a `Creator` from attributions
    ///
    /// `Creator` can only remove themselves.
    ///
    /// If the only `Creator` is removed then nobody will ever be able to claim
    /// royalties in the future again.
    ///
    /// Shares of removed `Creator` are allocated to the provided address, who
    /// must be a `Creator`.
    //
    // TODO: Create removal methods which split shares evenly and
    // proportionally.
    public fun remove_creator_by_transfer(
        attributions: &mut AttributionDomain,
        to: address,
        ctx: &mut TxContext,
    ) {
        // Asserts that sender is a creator
        let (_, creator) = vec_map::remove(
            &mut attributions.creators,
            &tx_context::sender(ctx)
        );

        // Get creator to which shares will be transfered
        let beneficiary = get_mut(attributions, to);

        beneficiary.share_of_royalty_bps =
            beneficiary.share_of_royalty_bps + creator.share_of_royalty_bps;
    }

    /// Distributes content of `aggregate` balance among the creators defined
    /// in the `AttributionDomain`
    public fun distribute_royalties<FT>(
        attributions: &AttributionDomain,
        aggregate: &mut Balance<FT>,
        ctx: &mut TxContext,
    ) {
        // balance * share_of_royalty_bps / BPS
        let total = fixed_point32::create_from_rational(
            balance::value(aggregate),
            (BPS as u64)
        );

        let i = 0;
        while (i < vec_map::size(&attributions.creators)) {
            let (_, creator) =
                vec_map::get_entry_by_idx(&attributions.creators, i);

            // Truncates fractional part of the result thus ensuring that sum
            // of royalty shares is not greater than total balance.
            let owed_royalty = fixed_point32::multiply_u64(
                (creator.share_of_royalty_bps as u64),
                total,
            );

            if (owed_royalty != 0) {
                let wallet = coin::from_balance(
                    balance::split(aggregate, owed_royalty),
                    ctx,
                );

                transfer::transfer(wallet, creator.who);
            };

            i = i + 1;
        };
    }

    /// === Utils ===

    fun assert_total_shares(attributions: &AttributionDomain) {
        let bps_total = 0;

        let i = 0;
        while (i < vec_map::size(&attributions.creators)) {
            let (_, creator) =
                vec_map::get_entry_by_idx(&attributions.creators, i);
            bps_total = bps_total + creator.share_of_royalty_bps;
            i = i + 1;
        };

        assert!(bps_total == BPS, err::invalid_total_share_of_royalties());
    }

    public fun assert_is_creator(
        attributions: &AttributionDomain,
        who: address
    ) {
        get(attributions, &who);
    }

    public fun assert_collection_has_creator<C>(
        collection: &Collection<C>,
        who: address
    ) {
        assert_is_creator(attribution_domain(collection), who);
    }

    /// ====== Interoperability ===

    struct Witness has drop {}

    public fun attribution_domain<C>(
        collection: &Collection<C>,
    ): &AttributionDomain {
        collection::borrow_domain(collection)
    }

    public fun attribution_domain_mut<C>(
        collection: &mut Collection<C>,
    ): &mut AttributionDomain {
        collection::borrow_domain_mut(Witness {}, collection)
    }

    public fun add_attribution_domain<C>(
        collection: &mut Collection<C>,
        domain: AttributionDomain,
    ) {
        collection::add_domain(collection, domain);
    }
}
