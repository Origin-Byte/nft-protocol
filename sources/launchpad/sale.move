//! Module representing `Sale` Outlets of `Launchpad`s.
//!
//! Launchpads can now have multiple sale outlets, repsented
//! through `sales: vector<Sale<T, M>>`, which meants that NFT creators can
//! perform tiered sales. An example of this would be an Gaming NFT creator
//! separating the sale based on NFT rarity and emit whitelist tokens to
//! different users for different rarities depending on the user's game score.
//!
//! The Sale object is agnostic to the Market mechanism and instead decides to
//! outsource this logic to generic `Market` object. This way developers can
//! come up with their plug-and-play market primitives, of which some examples
//! are Dutch Auctions, Sealed-Bid Auctions, etc.
module nft_protocol::sale {
    use std::vector;

    use sui::object::{Self, ID , UID};
    use sui::tx_context::{TxContext};

    use nft_protocol::err;

    struct Sale<phantom T, Market> has key, store {
        id: UID,
        tier_index: u64,
        whitelisted: bool,
        // Vector of all IDs owned by the slingshot
        nfts: vector<ID>,
        queue: vector<ID>,
        market: Market,
    }

    /// This object acts as an intermediate step between the payment
    /// and the transfer of the NFT. The user first has to call
    /// `buy_nft_certificate` which mints and transfers the `NftCertificate` to
    /// the user. This object will dictate which NFT the userwill receive by
    /// calling the endpoint `claim_nft`
    struct NftCertificate has key, store {
        id: UID,
        launchpad_id: ID,
        nft_id: ID,
    }

    public fun create<T: drop, Market: store>(
        tier_index: u64,
        whitelisted: bool,
        market: Market,
        ctx: &mut TxContext,
    ): Sale<T, Market> {
        let id = object::new(ctx);

        let nfts = vector::empty();
        let queue = vector::empty();

        Sale {
            id,
            tier_index,
            whitelisted,
            nfts,
            queue,
            market,
        }
    }

    /// Burn the `Sale` and return the `Market` object
    public fun delete<T: drop, Market: store>(
        sale_box: Sale<T, Market>,
    ): Market {
        assert!(
            vector::length(&sale_box.nfts) == 0,
            err::sale_outlet_still_has_nfts_to_sell()
        );
        assert!(
            vector::length(&sale_box.queue) == 0,
            err::sale_outlet_still_has_nfts_to_redeem()
        );

        let Sale {
            id,
            tier_index: _,
            whitelisted: _,
            nfts: _,
            queue: _,
            market,
        } = sale_box;

        object::delete(id);

        market
    }

    // TODO: need to add a function with nft_id as function parameter
    public fun issue_nft_certificate<T, M>(
        sale: &mut Sale<T, M>,
        launchpad_id: ID,
        ctx: &mut TxContext,
    ): NftCertificate {
        let nft_id = pop_nft(sale);

        let certificate = NftCertificate {
            id: object::new(ctx),
            launchpad_id: launchpad_id,
            nft_id: nft_id,
        };

        certificate
    }

    public fun burn_certificate(
        certificate: NftCertificate,
    ) {
        let NftCertificate {
            id,
            launchpad_id: _,
            nft_id: _,
        } = certificate;

        object::delete(id);
    }

    /// Adds an NFT's ID to the `nfts` field in `Sale` object
    public fun add_nft<T, Market>(
        sale: &mut Sale<T, Market>,
        id: ID,
    ) {
        let nfts = &mut sale.nfts;
        vector::push_back(nfts, id);
    }

    /// Pops an NFT's ID from the `nfts` field in `Sale` object
    /// and returns respective `ID`
    /// TODO: Need to push the ID to the queue
    fun pop_nft<T, Market>(
        sale: &mut Sale<T, Market>,
    ): ID {
        let nfts = &mut sale.nfts;
        assert!(!vector::is_empty(nfts), err::sale_outlet_has_no_nfts_to_sell());
        vector::pop_back(nfts)
    }

    /// Check how many `nfts` there are to sell
    public fun length<T, Market>(
        sale: &Sale<T, Market>,
    ): u64 {
        vector::length(&sale.nfts)
    }

    public fun market<T, M>(
        sale: &Sale<T, M>,
    ): &M {
        &sale.market
    }

    public fun market_mut<T, M>(
        sale: &mut Sale<T, M>,
    ): &mut M {
        &mut sale.market
    }

    public fun nft_id(
        certificate: &NftCertificate,
    ): ID {
        certificate.nft_id
    }

    public fun id<T, M>(
        sale: &Sale<T, M>,
    ): ID {
        object::uid_to_inner(&sale.id)
    }

    public fun id_ref<T, M>(
        sale: &Sale<T, M>,
    ): &ID {
        object::uid_as_inner(&sale.id)
    }

    public fun index<T, M>(
        sale: &Sale<T, M>,
    ): u64 {
        sale.tier_index
    }

    public fun whitelisted<T, M>(
        sale: &Sale<T, M>,
    ): bool {
        sale.whitelisted
    }
}
