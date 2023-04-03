module nft_protocol::tribal_realms {
    use std::string::{Self, String};

    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::mint_cap;
    use nft_protocol::collection::Collection;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::display_info;
    use nft_protocol::mint_cap::{MintCap};
    use nft_protocol::warehouse::{Self, Warehouse};
    use nft_protocol::composable_nft::{Self as c_nft};

    /// One time witness is only instantiated in the init method
    struct TRIBAL_REALMS has drop {}

    /// Types
    struct Avatar has copy, drop, store {}
    struct Skin has copy, drop, store {}
    struct Hat has copy, drop, store {}
    struct Glasses has copy, drop, store {}
    struct Gun has copy, drop, store {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(_witness: TRIBAL_REALMS, ctx: &mut TxContext) {
        let collection: Collection<Nft<TRIBAL_REALMS>> =
            nft::create_collection(Witness {}, ctx);
        let mint_cap = mint_cap::new_unregulated(Witness {}, &collection, ctx);

        nft::add_collection_domain(
            Witness {},
            &mut collection,
            display_info::new(
                string::utf8(b"TribalRealms"),
                string::utf8(b"A composable NFT collection on Sui"),
            ),
        );

        // === Avatar composability ===

        let avatar_blueprint = c_nft::new_composition<Avatar>();
        c_nft::add_relationship<Avatar, Hat>(
            &mut avatar_blueprint, 1,
        );
        c_nft::add_relationship<Avatar, Glasses>(
            &mut avatar_blueprint, 1,
        );
        c_nft::add_relationship<Avatar, Gun>(
            &mut avatar_blueprint, 1,
        );

        nft::add_collection_domain(
            Witness {}, &mut collection, avatar_blueprint,
        );

        // === Gun composability ===

        let gun_blueprint = c_nft::new_composition<Gun>();
        c_nft::add_relationship<Gun, Skin>(
            &mut gun_blueprint, 1,
        );

        nft::add_collection_domain(
            Witness {}, &mut collection, gun_blueprint,
        );

        transfer::public_transfer(mint_cap, tx_context::sender(ctx));
        transfer::public_share_object(collection);
    }

    public entry fun mint_nft<T: drop + store>(
        name: String,
        description: String,
        url: vector<u8>,
        mint_cap: &mut MintCap<Nft<TRIBAL_REALMS>>,
        warehouse: &mut Warehouse<Nft<TRIBAL_REALMS>>,
        ctx: &mut TxContext,
    ) {
        let url = sui::url::new_unsafe_from_bytes(url);

        let nft = nft::from_mint_cap(mint_cap, name, url, ctx);
        nft::add_domain(Witness {}, &mut nft, display_info::new(name, description));
        nft::add_domain(Witness {}, &mut nft, url);

        warehouse::deposit_nft(warehouse, nft);
    }
}
