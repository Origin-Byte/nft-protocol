module nft_protocol::attribution {
    use std::vector;
    use std::option::{Self, Option};

    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;

    const BPS: u16 = 10_000;

    /// Creator struct which holds the addresses of the creators of the NFT
    /// Collection, as well their share of the royalties collected.
    struct Creator has store, copy, drop {
        who: address,
        share_of_royalty_bps: u16,
    }

    public fun new_creator(who: address, share_of_royalty_bps: u16): Creator {
        Creator {
            who,
            share_of_royalty_bps,
        }
    }

    public fun who(creator: &Creator): address {
        creator.who
    }

    public fun share_of_royalty_bps(creator: &Creator): u16 {
        creator.share_of_royalty_bps
    }

    struct Attributions has store {
        /// Address that receives the mint and trade royalties
        creators: vector<Creator>,
    }

    // TODO: Discuss empty attributions
    // /// Creates an empty `Attributions` object
    // ///
    // /// By not attributing any `Creators`, nobody will ever be able to claim
    // /// royalties from this `Attributions` object.
    // public fun empty(): Attributions {
    //     Attributions { creators: vector::empty() }
    // }

    public fun from_address(who: address): Attributions {
        Attributions {
            creators: vector::singleton(new_creator(who, BPS)),
        }
    }

    public fun from_creators(creators: vector<Creator>): Attributions {
        let attributions = Attributions { creators };
        assert_total_shares(&attributions);

        attributions
    }

    public fun is_empty(attributions: &Attributions): bool {
        vector::is_empty(&attributions.creators)
    }

    public fun index(
        attributions: &Attributions,
        who: address,
    ): Option<u16> {
        let i = 0;
        while (i < vector::length(&attributions.creators)) {
            let creator = vector::borrow(&attributions.creators, i);
            if (creator.who == who) {
                // Can cast to u16 as you can only have, at max, BPS number of
                // creators.
                return option::some((i as u16))
            };
            i = i + 1;
        };

        option::none()
    }

    public fun get(
        attributions: &Attributions,
        index: u16,
    ): &Creator {
        vector::borrow(&attributions.creators, (index as u64))
    }

    fun get_mut(
        attributions: &mut Attributions,
        index: u16,
    ): &mut Creator {
        vector::borrow_mut(&mut attributions.creators, (index as u64))
    }

    /// === Mutability ===

    /// Add a `Creator` to attributions
    ///
    /// This must be done by a `Creator` which already has an attribution who
    /// gives up an arithmetic share of their royalty share.
    public fun add_creator(
        attributions: &mut Attributions,
        new_creator: Creator,
        ctx: &mut TxContext,
    ) {
        let tentative_index = index(attributions, tx_context::sender(ctx));

        assert!(
            option::is_some(&tentative_index),
            err::address_not_attributed()
        );

        let creator_index = option::destroy_some(tentative_index);
        let creator = get_mut(attributions, creator_index);

        assert!(
            creator.share_of_royalty_bps >= new_creator.share_of_royalty_bps,
            err::address_does_not_have_enough_shares()
        );

        creator.share_of_royalty_bps =
            creator.share_of_royalty_bps - new_creator.share_of_royalty_bps;

        if (creator.share_of_royalty_bps == 0) {
            vector::swap_remove(&mut attributions.creators, (creator_index as u64));
        };

        vector::push_back(&mut attributions.creators, new_creator);
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
    public fun remove_creator_transfer(
        attributions: &mut Attributions,
        to: address,
        ctx: &mut TxContext,
    ) {
        let creator = remove_creator(attributions, ctx);

        // Get creator to which shares will be transfered
        let tentative_index = index(attributions, to);

        assert!(
            option::is_some(&tentative_index),
            err::address_not_attributed()
        );

        let beneficiary = get_mut(
            attributions,
            option::destroy_some(tentative_index)
        );

        beneficiary.share_of_royalty_bps =
            beneficiary.share_of_royalty_bps + creator.share_of_royalty_bps;
    }

    fun remove_creator(
        attributions: &mut Attributions,
        ctx: &mut TxContext,
    ): Creator {
        let tentative_index = index(attributions, tx_context::sender(ctx));

        assert!(
            option::is_some(&tentative_index),
            err::address_not_attributed()
        );

        vector::swap_remove(
            &mut attributions.creators,
            (option::destroy_some(tentative_index) as u64)
        )
    }

    fun assert_total_shares(attributions: &Attributions) {
        let bps_total = 0;

        let i = 0;
        while (i < vector::length(&attributions.creators)) {
            let creator = vector::borrow(&attributions.creators, i);
            bps_total = bps_total + creator.share_of_royalty_bps;
            i = i + 1;
        };

        assert!(bps_total == BPS, err::invalid_total_share_of_royalties());
    }
}
