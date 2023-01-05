/// Module of Collection `Creators` domain.
///
/// Creators domain gathers all collection creators, their respective
/// addresses as well as the share of royalty.
module nft_protocol::creators {
    use std::fixed_point32;

    use sui::balance::{Self, Balance};
    use sui::coin;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};

    use nft_protocol::collection::{Self, Collection, MintCap};
    use nft_protocol::err;
    use nft_protocol::utils;

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

    /// === CreatorsDomain ===

    struct CreatorsDomain has copy, drop, store {
        /// Increments every time we mutate the creators map.
        ///
        /// Enables multisig to invalidate itself if the attribution domain
        /// changed.
        version: u64,
        is_frozen: bool,
        /// Address that receives the mint and trade royalties
        creators: VecMap<address, Creator>,
    }

    /// Creates an empty `Attributions` object
    ///
    /// By not attributing any `Creators`, nobody will ever be able to claim
    /// royalties from this `Attributions` object or modify it's domains.
    public fun empty(): CreatorsDomain {
        CreatorsDomain {
            version: 0,
            is_frozen: false,
            creators: vec_map::empty()
        }
    }

    public fun from_address(who: address): CreatorsDomain {
        let domain = empty();
        vec_map::insert(&mut domain.creators, who, new_creator(who, utils::bps()));
        domain
    }

    public fun from_creators(
        creators: VecMap<address, Creator>
    ): CreatorsDomain {
        let domain = CreatorsDomain { version: 0, is_frozen: false, creators };
        assert_total_shares(&domain);

        domain
    }

    public fun is_empty(domain: &CreatorsDomain): bool {
        vec_map::is_empty(&domain.creators)
    }

    public fun is_frozen(domain: &CreatorsDomain): bool {
        domain.is_frozen
    }

    public fun version(attributions: &CreatorsDomain): u64 {
        attributions.version
    }

    public fun creators(
        domain: &CreatorsDomain
    ): &VecMap<address, Creator> {
        &domain.creators
    }

    public fun get(
        domain: &CreatorsDomain,
        who: &address,
    ): &Creator {
        assert!(
            vec_map::contains(&domain.creators, who),
            err::address_not_attributed()
        );
        vec_map::get(&domain.creators, who)
    }

    fun get_mut(
        domain: &mut CreatorsDomain,
        who: address,
    ): &mut Creator {
        assert!(
            vec_map::contains(&domain.creators, &who),
            err::address_not_attributed()
        );
        vec_map::get_mut(&mut domain.creators, &who)
    }

    /// === Mutability ===

    /// Add a `Creator` to CreatorsDomain object
    ///
    /// This must be done by a `Creator` which already has an attribution who
    /// gives up an arithmetic share of their royalty share.
    // TODO: assert not frozen?
    public fun add_creator(
        domain: &mut CreatorsDomain,
        new_creator: Creator,
        ctx: &mut TxContext,
    ) {
        // Asserts that sender is a creator
        let creator = get_mut(domain, tx_context::sender(ctx));

        assert!(
            creator.share_of_royalty_bps >= new_creator.share_of_royalty_bps,
            err::address_does_not_have_enough_shares()
        );

        creator.share_of_royalty_bps =
            creator.share_of_royalty_bps - new_creator.share_of_royalty_bps;

        if (creator.share_of_royalty_bps == 0) {
            let who = creator.who;
            vec_map::remove(&mut domain.creators, &who);
        };

        vec_map::insert(&mut domain.creators, new_creator.who, new_creator);
        domain.version = domain.version + 1;
    }

    /// Remove a `Creator` from CreatorsDomain
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
    // TODO: assert not frozen?
    public fun remove_creator_by_transfer(
        domain: &mut CreatorsDomain,
        to: address,
        ctx: &mut TxContext,
    ) {
        // Asserts that sender is a creator
        let (_, creator) = vec_map::remove(
            &mut domain.creators,
            &tx_context::sender(ctx)
        );

        // Get creator to which shares will be transfered
        let beneficiary = get_mut(domain, to);

        beneficiary.share_of_royalty_bps =
            beneficiary.share_of_royalty_bps + creator.share_of_royalty_bps;

        domain.version = domain.version + 1;
    }

    /// Makes `Collection` domains immutable
    ///
    /// This is irreversible, use with caution.
    ///
    /// Will cause `assert_collection_has_creator` and `assert_is_creator` to
    /// always fail, thus making all standard domains immutable.
    public fun freeze_domains(domain: &mut CreatorsDomain,) {
        // Only creators can obtain `&mut CreatorsDomain`
        domain.is_frozen = true
    }

    /// Distributes content of `aggregate` balance among the creators defined
    /// in the `CreatorsDomain`
    public fun distribute_royalties<FT>(
        domain: &CreatorsDomain,
        aggregate: &mut Balance<FT>,
        ctx: &mut TxContext,
    ) {
        // balance * share_of_royalty_bps / utils::bps()
        let total = fixed_point32::create_from_rational(
            balance::value(aggregate),
            (utils::bps() as u64)
        );

        let i = 0;
        while (i < vec_map::size(&domain.creators)) {
            let (_, creator) =
                vec_map::get_entry_by_idx(&domain.creators, i);

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

    fun assert_total_shares(domain: &CreatorsDomain) {
        let bps_total = 0;

        let i = 0;
        while (i < vec_map::size(&domain.creators)) {
            let (_, creator) =
                vec_map::get_entry_by_idx(&domain.creators, i);
            bps_total = bps_total + creator.share_of_royalty_bps;
            i = i + 1;
        };

        assert!(bps_total == utils::bps(), err::invalid_total_share_of_royalties());
    }

    public fun assert_is_creator(
        domain: &CreatorsDomain,
        who: address
    ) {
        get(domain, &who);
    }

    public fun assert_collection_has_creator<C>(
        collection: &Collection<C>,
        who: address
    ) {
        assert_is_creator(creators_domain(collection), who);
    }

    /// ====== Interoperability ===

    struct Witness has drop {}

    public fun creators_domain<C>(
        collection: &Collection<C>,
    ): &CreatorsDomain {
        collection::borrow_domain(collection)
    }

    public fun creators_domain_mut<C>(
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ): &mut CreatorsDomain {
        assert_collection_has_creator(
            collection, tx_context::sender(ctx)
        );

        collection::borrow_domain_mut(Witness {}, collection)
    }

    public fun add_creators_domain<C>(
        collection: &mut Collection<C>,
        mint_cap: &mut MintCap<C>,
        domain: CreatorsDomain,
    ) {
        collection::add_domain(collection, mint_cap, domain);
    }
}
