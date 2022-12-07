//! Module representing the Nft bookeeping Inventories of `Launchpad`s.
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
module nft_protocol::inventory {
    use std::vector;

    use sui::tx_context::{TxContext};
    use sui::object::{Self, ID , UID};

    use nft_protocol::err;

    struct Inventory has key, store {
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
    ): Inventory {
        let id = object::new(ctx);

        let nfts = vector::empty();
        let queue = vector::empty();

        Inventory {
            id,
            whitelisted,
            nfts,
            queue,
        }
    }

    /// Burn the `Inventory` and return the `Market` object
    public fun delete(
        inventory: Inventory,
    ) {
        assert!(
            vector::length(&inventory.nfts) == 0,
            err::nft_sale_incompleted()
        );
        assert!(
            vector::length(&inventory.queue) == 0,
            err::nft_redemption_incompleted()
        );

        let Inventory {
            id,
            whitelisted: _,
            nfts: _,
            queue: _,
        } = inventory;

        object::delete(id);
    }

    // TODO: need to add a function with nft_id as function parameter
    public fun issue_nft_certificate(
        inventory: &mut Inventory,
        launchpad_id: ID,
        slot_id: ID,
        ctx: &mut TxContext,
    ): NftCertificate {
        let nft_id = pop_nft(inventory);

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

    /// Adds an NFT's ID to the `nfts` field in `Inventory` object
    public fun add_nft(
        inventory: &mut Inventory,
        id: ID,
    ) {
        let nfts = &mut inventory.nfts;
        vector::push_back(nfts, id);
    }

    /// Pops an NFT's ID from the `nfts` field in `Inventory` object
    /// and returns respective `ID`
    /// TODO: Need to push the ID to the queue
    fun pop_nft(
        inventory: &mut Inventory,
    ): ID {
        let nfts = &mut inventory.nfts;
        assert!(!vector::is_empty(nfts), err::no_nfts_left());
        vector::pop_back(nfts)
    }

    /// Check how many `nfts` there are to sell
    public fun length(
        inventory: &Inventory,
    ): u64 {
        vector::length(&inventory.nfts)
    }

    public fun nft_id(
        certificate: &NftCertificate,
    ): ID {
        certificate.nft_id
    }

    public fun whitelisted(
        inventory: &Inventory,
    ): bool {
        inventory.whitelisted
    }
}
