module nft_protocol::launchpad_whitelist {
    use sui::transfer;
    use sui::object::{Self, ID , UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::err;
    use nft_protocol::inventory::Inventory;
    use nft_protocol::launchpad::{Self as lp, Slot};

    struct Whitelist has key {
        id: UID,
        sale_id: ID,
    }

    public fun whitelist_address(
        slot: &Slot,
        inventory: &Inventory,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        assert!(
            tx_context::sender(ctx) == lp::slot_admin(slot),
            err::wrong_launchpad_admin()
        );
        let sale_id = object::id(inventory);

        let whitelisting = Whitelist {
            id: object::new(ctx),
            sale_id: sale_id,
        };

        transfer::transfer(
            whitelisting,
            recipient,
        );
    }

    public fun burn_whitelist_token(
        whitelist_token: Whitelist,
    ) {
        let Whitelist {
            id,
            sale_id: _,
        } = whitelist_token;

        object::delete(id);
    }

    public fun sale_id(
        whitelist_token: &Whitelist,
    ): ID {
        whitelist_token.sale_id
    }

    public fun assert_whitelist_token_market(
        slot: &Slot,
        market_id: ID,
        whitelist_token: &Whitelist,
    ) {
        let inventory = lp::inventory(slot, market_id);

        // Infer that whitelist token corresponds to correct sale inventory
        assert!(
            sale_id(whitelist_token) == object::id(inventory),
            err::incorrect_whitelist_token()
        );
    }

    public fun assert_whitelist_token_inventory(
        inventory: &Inventory,
        whitelist_token: &Whitelist,
    ) {
        // Infer that whitelist token corresponds to correct sale inventory
        assert!(
            sale_id(whitelist_token) == object::id(inventory),
            err::incorrect_whitelist_token()
        );
    }
}
