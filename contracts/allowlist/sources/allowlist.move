module allowlist::allowlist {
    use sui::transfer;
    use sui::tx_context::TxContext;

    use nft_protocol::bidding;
    use nft_protocol::orderbook;
    use nft_protocol::transfer_allowlist;

    struct ALLOWLIST has drop {}

    fun init(_otw: ALLOWLIST, ctx: &mut TxContext) {
        let (al, al_cap) = transfer_allowlist::new(ctx);

        // orderbooks can perform trades with our allowlist
        transfer_allowlist::insert_authority<orderbook::Witness>(&al_cap, &mut al);
        // bidding contract can perform trades too
        transfer_allowlist::insert_authority<bidding::Witness>(&al_cap, &mut al);

        // Delete `AllowlistOwnerCap` to guarantee that each release of
        // `OriginByte` always has a fixed set of trading contracts
        transfer_allowlist::delete_owner_cap(al_cap);
        transfer::public_share_object(al);
    }
}
