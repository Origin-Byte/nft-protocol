/// Module of Collection `CreatorsDomain`
///
/// `CreatorsDomain` tracks all collection creators, their respective
/// addresses, as well as their royalty share.
///
/// `CreatorsDomain` is used to authenticate mutable operations on other
/// OriginByte standard domains.
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

    // === Creator ===

    /// `Creator` type which holds the address of the `Collection` creator as
    /// well their share of the royalties.
    struct Creator has store, copy, drop {
        who: address,
        share_of_royalty_bps: u16,
    }

    /// Create new `Creator`
    public fun new_creator(who: address, share_of_royalty_bps: u16): Creator {
        Creator { who, share_of_royalty_bps }
    }

    /// Returns the address belonging to the `Creator`
    public fun who(creator: &Creator): address {
        creator.who
    }

    /// Returns the royalty share of the `Creator` in basis points
    public fun share_of_royalty_bps(creator: &Creator): u16 {
        creator.share_of_royalty_bps
    }

    /// === CreatorsDomain ===

    /// `CreatorsDomain` tracks collection creators, their respective
    /// addresses, as well as their royalty share.
    ///
    /// ##### Usage
    ///
    /// Originbyte Standard domains will authenticate mutable operations for
    /// transaction senders which are creators using
    /// `assert_collection_has_creator`.
    ///
    /// `CreatorsDomain` can additionally be frozen which will cause
    /// `assert_collection_has_creator` to always fail, therefore, allowing
    /// creators to lock in their NFT collection.
    ///
    /// ```
    /// module nft_protocol::display {
    ///     struct SUIMARINES has drop {}
    ///     struct Witness has drop {}
    ///
    ///     struct DisplayDomain {
    ///         id: UID,
    ///         name: String,
    ///     } has key, store
    ///
    ///     public fun set_name<C>(
    ///         collection: &mut Collection<C>,
    ///         name: String,
    ///         ctx: &mut TxContext,
    ///     ) {
    ///         creators::assert_collection_has_creator(
    ///             collection, tx_context::sender(ctx)
    ///         );
    ///
    ///         let domain: &mut DisplayDomain =
    ///             collection::borrow_domain_mut(Witness {}, collection);
    ///
    ///         domain.name = name;
    ///     }
    /// }
    struct CreatorsDomain has copy, drop, store {
        /// Increments every time we mutate the creators map.
        ///
        /// Enables multisig to invalidate itself if the attribution domain
        /// changed.
        version: u64,
        /// Frozen `CreatorsDomain` will no longer authenticate creators
        is_frozen: bool,
        /// Creators that receive the mint and trade royalties
        creators: VecMap<address, Creator>,
    }

    /// Creates an empty `CreatorsDomain` object
    ///
    /// By not attributing any `Creators`, nobody will ever be able to claim
    /// royalties from this `CreatorsDomain` object or modify the `Collection`
    /// domains.
    public fun empty(): CreatorsDomain {
        CreatorsDomain {
            version: 0,
            is_frozen: false,
            creators: vec_map::empty()
        }
    }

    /// Creates a `CreatorsDomain` object with only one creator
    ///
    /// Only the single `Creator` will ever be able to claim royalties from
    /// this `CreatorsDomain` object and modify the `Collection` domains.
    public fun from_address(who: address): CreatorsDomain {
        let domain = empty();
        vec_map::insert(&mut domain.creators, who, new_creator(who, utils::bps()));
        domain
    }

    /// Creates a `CreatorsDomain` with multiple creators
    ///
    /// Creators will be able to claim royalties and modify `Collection`
    /// domains.
    ///
    /// ##### Panics
    ///
    /// Panics if total sum of creator basis point share is not equal to 10000.
    public fun from_creators(
        creators: VecMap<address, Creator>
    ): CreatorsDomain {
        let domain = CreatorsDomain { version: 0, is_frozen: false, creators };
        assert_total_shares(&domain);

        domain
    }

    /// Returns whether `CreatorsDomain` has defined any creators
    public fun is_empty(domain: &CreatorsDomain): bool {
        vec_map::is_empty(&domain.creators)
    }

    /// Returns whether `CreatorsDomain` is frozen
    public fun is_frozen(domain: &CreatorsDomain): bool {
        domain.is_frozen
    }

    /// Returns the version of the `CreatorsDomain` which increments with every
    /// mutation.
    public fun version(attributions: &CreatorsDomain): u64 {
        attributions.version
    }

    /// Returns the list of creators defined on the `CreatorsDomain`
    public fun creators(
        domain: &CreatorsDomain
    ): &VecMap<address, Creator> {
        &domain.creators
    }

    /// Returns the `Creator` type for the given address
    ///
    /// ##### Panics
    ///
    /// Panics if the provided address is not an attributed creator
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

    /// Returns a mutable reference to the `Creator` type for the given address
    ///
    /// ##### Panics
    ///
    /// Panics if the provided address is not an attributed creator
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

    // === Mutability ===

    /// Add a `Creator` to `CreatorsDomain` object
    ///
    /// This must be done by a creator which already has an attribution who
    /// gives up their share of the royalties for the benefit of the new
    /// creator.
    ///
    /// ##### Panics
    ///
    /// Panics if the transaction sender does not have a large enough royalty
    /// share to transfer to the new creator.
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
    /// Creators can only remove themselves. Shares of removed `Creator` are
    /// allocated to the provided address, who also must be a `Creator`.
    ///
    /// If the only `Creator` is removed then nobody will ever be able to claim
    /// royalties in the future again.
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
    /// Will cause `assert_collection_has_creator` and `assert_is_creator` to
    /// always fail, thus making all standard domains immutable.
    ///
    /// This is irreversible, use with caution.
    public fun freeze_domains(domain: &mut CreatorsDomain,) {
        // Only creators can obtain `&mut CreatorsDomain`
        domain.is_frozen = true
    }

    /// Distributes the contents of a `Balance<FT>` among the creators defined
    /// in the `CreatorsDomain`.
    public fun distribute_balance<FT>(
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

    // === Utils ===

    /// Asserts that total `Creator` shares add up to 10000 basis points
    ///
    /// ##### Panics
    ///
    /// Panics if shares do not add up to 10000 basis points
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

    /// Asserts that address is a `Creator` attributed in `CreatorsDomain`
    ///
    /// ##### Panics
    ///
    /// Panics if address is not an attribtued creator.
    public fun assert_is_creator(
        domain: &CreatorsDomain,
        who: address
    ) {
        get(domain, &who);
    }

    /// Asserts that address is a `Creator` attributed in `CreatorsDomain` of
    /// the `Collection`
    ///
    /// ##### Panics
    ///
    /// Panics if `CreatorsDomain` is not defined or address is not an
    /// attributed creator.
    public fun assert_collection_has_creator<C>(
        collection: &Collection<C>,
        who: address
    ) {
        assert_is_creator(creators_domain(collection), who);
    }

    /// ====== Interoperability ===

    struct Witness has drop {}

    /// Borrows `CreatorsDomain` from `Collection`
    ///
    /// ##### Panics
    ///
    /// Panics if `CreatorsDomain` is not registered on `Collection`.
    public fun creators_domain<C>(
        collection: &Collection<C>,
    ): &CreatorsDomain {
        collection::borrow_domain(collection)
    }

    /// Mutably borrows `CreatorsDomain` from `Collection`
    ///
    /// `CreatorsDomain` has secured endpoints therefore it is safe to expose
    /// a mutable reference to it.
    ///
    /// ##### Panics
    ///
    /// Panics if `CreatorsDomain` is not registered on `Collection`.
    public fun creators_domain_mut<C>(
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ): &mut CreatorsDomain {
        assert_collection_has_creator(
            collection, tx_context::sender(ctx)
        );

        collection::borrow_domain_mut(Witness {}, collection)
    }

    /// Adds `CreatorsDomain` to `Collection`
    ///
    /// ##### Panics
    ///
    /// Panics if `MintCap` does not match `Collection` or domain `D` already
    /// exists.
    public fun add_creators_domain<C>(
        collection: &mut Collection<C>,
        mint_cap: &mut MintCap<C>,
        domain: CreatorsDomain,
    ) {
        collection::add_domain(collection, mint_cap, domain);
    }
}
