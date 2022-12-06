//! Module representing `Sale` Outlets of `Launchpad`s.
//!
//! Launchpads can now have multiple sale outlets, repsented
//! through `sales: vector<Sale>`, which meants that NFT creators can
//! perform tiered sales. An example of this would be an Gaming NFT creator
//! separating the sale based on NFT rarity and emit whitelist tokens to
//! different users for different rarities depending on the user's game score.
//!
//! The Sale object is agnostic to the Market mechanism and instead decides to
//! outsource this logic to generic `Market` object. This way developers can
//! come up with their plug-and-play market primitives, of which some examples
//! are Dutch Auctions, Sealed-Bid Auctions, etc.
module nft_protocol::outlet {
    use std::vector;

    use sui::tx_context::{TxContext};
    use sui::object::{Self, ID , UID};

    use nft_protocol::err;

    struct Outlet has key, store {
        id: UID,
        whitelisted: bool,
        // Vector of all IDs owned by the slingshot
        nfts: vector<ID>,
        queue: vector<ID>,
    }

    /// This object acts as an intermediate step between the payment
    /// and the transfer of the NFT. The user first has to call
    /// `buy_nft_certificate` which mints and transfers the `NftCertificate` to
    /// the user. This object will dictate which NFT the userwill receive by
    /// calling the endpoint `claim_nft`
    struct NftCertificate has key, store {
        id: UID,
        launchpad_id: ID,
        slot_id: ID,
        nft_id: ID,
    }

    public fun create(
        whitelisted: bool,
        ctx: &mut TxContext,
    ): Outlet {
        let id = object::new(ctx);

        let nfts = vector::empty();
        let queue = vector::empty();

        Outlet {
            id,
            whitelisted,
            nfts,
            queue,
        }
    }

    /// Burn the `Outlet` and return the `Market` object
    public fun delete(
        sale_box: Outlet,
    ) {
        assert!(
            vector::length(&sale_box.nfts) == 0,
            err::sale_outlet_still_has_nfts_to_sell()
        );
        assert!(
            vector::length(&sale_box.queue) == 0,
            err::sale_outlet_still_has_nfts_to_redeem()
        );

        let Outlet {
            id,
            whitelisted: _,
            nfts: _,
            queue: _,
        } = sale_box;

        object::delete(id);
    }

    // TODO: need to add a function with nft_id as function parameter
    public fun issue_nft_certificate(
        sale: &mut Outlet,
        launchpad_id: ID,
        slot_id: ID,
        ctx: &mut TxContext,
    ): NftCertificate {
        let nft_id = pop_nft(sale);

        let certificate = NftCertificate {
            id: object::new(ctx),
            launchpad_id,
            slot_id,
            nft_id,
        };

        certificate
    }

    public fun burn_certificate(
        certificate: NftCertificate,
    ) {
        let NftCertificate {
            id,
            launchpad_id: _,
            slot_id: _,
            nft_id: _,
        } = certificate;

        object::delete(id);
    }

    /// Adds an NFT's ID to the `nfts` field in `Outlet` object
    public fun add_nft(
        sale: &mut Outlet,
        id: ID,
    ) {
        let nfts = &mut sale.nfts;
        vector::push_back(nfts, id);
    }

    /// Pops an NFT's ID from the `nfts` field in `Outlet` object
    /// and returns respective `ID`
    /// TODO: Need to push the ID to the queue
    fun pop_nft(
        sale: &mut Outlet,
    ): ID {
        let nfts = &mut sale.nfts;
        assert!(!vector::is_empty(nfts), err::sale_outlet_has_no_nfts_to_sell());
        vector::pop_back(nfts)
    }

    /// Check how many `nfts` there are to sell
    public fun length(
        sale: &Outlet,
    ): u64 {
        vector::length(&sale.nfts)
    }

    public fun nft_id(
        certificate: &NftCertificate,
    ): ID {
        certificate.nft_id
    }

    public fun whitelisted(
        sale: &Outlet,
    ): bool {
        sale.whitelisted
    }
}
