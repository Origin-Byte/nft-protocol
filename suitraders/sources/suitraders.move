module suitraders::suitraders {
    use std::ascii;
    use std::option;
    use std::string::{Self, String};

    use sui::transfer;
    use sui::vec_set;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::attributes;
    use nft_protocol::collection_id;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::creators;
    use nft_protocol::display_info;
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::royalty_strategy_bps;
    use nft_protocol::tags;
    use nft_protocol::warehouse::{Self, Warehouse};
    use nft_protocol::witness;

    /// One time witness is only instantiated in the init method
    struct SUITRADERS has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: SUITRADERS, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let collection: Collection<SUITRADERS> =
            nft::create_collection(witness, ctx);
        // let mint_cap =
        //     mint_cap::new<Witness, Nft<SUITRADERS>>(Witness {}, &collection, option::none(), ctx);

        // collection::add_domain(
        //     Witness {},
        //     &mut collection,
        //     creators::new(vec_set::singleton(sender)),
        // );

        // // Register custom domains
        // collection::add_domain(
        //     Witness {},
        //     &mut collection,
        //     display_info::new(
        //         string::utf8(b"Suimarines"),
        //         string::utf8(b"A unique NFT collection of Suimarines on Sui"),
        //     ),
        // );

        // let delegated_witness = witness::from_witness<Nft<SUITRADERS>, Witness>(Witness {});

        // royalty_strategy_bps::create_domain_and_add_strategy<Nft<SUITRADERS>>(
        //     delegated_witness, &mut collection, 100, ctx,
        // );

        // let tags = tags::empty(ctx);
        // tags::add_tag(&mut tags, tags::art());
        // collection::add_domain(Witness {}, &mut collection, tags);

        // let listing = nft_protocol::listing::new(
        //     @0xfb6f8982534d9ec059764346a67de63e01ecbf80,
        //     @0xfb6f8982534d9ec059764346a67de63e01ecbf80,
        //     ctx,
        // );

        // let inventory_id = nft_protocol::listing::create_warehouse<Nft<SUITRADERS>>(
        //     &mut listing, ctx
        // );

        // nft_protocol::fixed_price::init_venue<Nft<SUITRADERS>, sui::sui::SUI>(
        //     &mut listing,
        //     inventory_id,
        //     false, // is whitelisted
        //     500, // price
        //     ctx,
        // );

        // nft_protocol::dutch_auction::init_venue<Nft<SUITRADERS>, sui::sui::SUI>(
        //     &mut listing,
        //     inventory_id,
        //     false, // is whitelisted
        //     100, // reserve price
        //     ctx,
        // );

        // transfer::public_share_object(listing);

        // transfer::public_transfer(mint_cap, tx_context::sender(ctx));
        transfer::public_share_object(collection);
    }

    public entry fun mint_nft(
        name: String,
        description: String,
        url: vector<u8>,
        attribute_keys: vector<ascii::String>,
        attribute_values: vector<ascii::String>,
        mint_cap: &mut MintCap<SUITRADERS>,
        warehouse: &mut Warehouse<Nft<SUITRADERS>>,
        ctx: &mut TxContext,
    ) {
        let url = sui::url::new_unsafe_from_bytes(url);

        let nft = nft::from_mint_cap(mint_cap, name, url, ctx);

        nft::add_domain(Witness {}, &mut nft, display_info::new(name, description));
        nft::add_domain(Witness {}, &mut nft, url);

        nft::add_domain(
            Witness {},
            &mut nft,
            attributes::from_vec(attribute_keys, attribute_values),
        );

        nft::add_domain(Witness {}, &mut nft, collection_id::from_mint_cap(mint_cap));

        warehouse::deposit_nft(warehouse, nft);
    }
}
