//! Module of NFT release whitelist tokens.
//!
//! Whitin a release `Slot`, each market has its own whitelist policy.
//! As an example, creators can create tiered sales based on the NFT rarity,
//! and then whitelist only the rare NFT sale. They can then emit whitelist
//! tokens and send them to users who have completed a set of defined actions.
module nft_protocol::launchpad_whitelist {
    use sui::object::{Self, ID , UID};
    use sui::tx_context::TxContext;

    use nft_protocol::err;
    use nft_protocol::slot::{Self, Slot};
    use nft_protocol::inventory::Inventory;

    struct Whitelist has key {
        id: UID,
        inventory_id: ID,
    }

    public fun whitelist_address(
        slot: &Slot,
        inventory_id: ID,
        ctx: &mut TxContext,
    ): Whitelist {
        slot::assert_slot_admin(slot, ctx);

        Whitelist {
            id: object::new(ctx),
            inventory_id,
        }
    }

    public fun burn_whitelist_token(
        whitelist_token: Whitelist,
    ) {
        let Whitelist {
            id,
            inventory_id: _,
        } = whitelist_token;

        object::delete(id);
    }

    public fun inventory_id(
        whitelist_token: &Whitelist,
    ): ID {
        whitelist_token.inventory_id
    }

    public fun assert_whitelist_token_market(
        slot: &Slot,
        market_id: ID,
        whitelist_token: &Whitelist,
    ) {
        let inventory = slot::inventory(slot, market_id);

        // Infer that whitelist token corresponds to correct sale inventory
        assert!(
            whitelist_token.inventory_id == object::id(inventory),
            err::incorrect_whitelist_token()
        );
    }

    public fun assert_whitelist_token_inventory(
        inventory: &Inventory,
        whitelist_token: &Whitelist,
    ) {
        // Infer that whitelist token corresponds to correct sale inventory
        assert!(
            whitelist_token.inventory_id == object::id(inventory),
            err::incorrect_whitelist_token()
        );
    }
}
