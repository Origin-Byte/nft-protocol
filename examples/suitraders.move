module nft_protocol::suitraders {
    use std::ascii;
    use std::string::{Self, String};

    use sui::balance;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::url;
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::witness;
    use nft_protocol::creators;
    use nft_protocol::attributes;
    use nft_protocol::warehouse::{Self, Warehouse};
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::mint_cap::{Self, MintCap};

    /// One time witness is only instantiated in the init method
    struct SUITRADERS has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: SUITRADERS, ctx: &mut TxContext) {
        let (mint_cap, collection) = collection::create(&witness, ctx);
        let delegated_witness = witness::from_witness(&Witness {});

        collection::add_domain(
            &Witness {},
            &mut collection,
            creators::from_address<SUITRADERS, Witness>(
                &Witness {}, tx_context::sender(ctx),
            ),
        );

        // Register custom domains
        display::add_collection_display_domain(
            &Witness {},
            &mut collection,
            string::utf8(b"Suitraders"),
            string::utf8(b"A unique NFT collection of Suitraders on Sui"),
        );

        url::add_collection_url_domain(
            &Witness {},
            &mut collection,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        display::add_collection_symbol_domain(
            &Witness {},
            &mut collection,
            string::utf8(b"SUITR"),
        );

        let royalty = royalty::from_address(tx_context::sender(ctx), ctx);
        royalty::add_proportional_royalty(&mut royalty, 100);
        royalty::add_royalty_domain(
            &Witness {},
            &mut collection,
            royalty,
        );

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art());
        tags::add_collection_tag_domain(
            &Witness {},
            &mut collection,
            tags,
        );

        let listing = nft_protocol::listing::new(
            @0xfb6f8982534d9ec059764346a67de63e01ecbf80,
            @0xfb6f8982534d9ec059764346a67de63e01ecbf80,
            ctx,
        );

        let inventory_id = nft_protocol::listing::create_warehouse<SUITRADERS>(
            delegated_witness, &mut listing, ctx
        );

        nft_protocol::fixed_price::init_venue<SUITRADERS, sui::sui::SUI>(
            &mut listing,
            inventory_id,
            false, // is whitelisted
            500, // price
            ctx,
        );

        nft_protocol::dutch_auction::init_venue<SUITRADERS, sui::sui::SUI>(
            &mut listing,
            inventory_id,
            false, // is whitelisted
            100, // reserve price
            ctx,
        );

        transfer::public_share_object(listing);

        transfer::public_transfer(mint_cap, tx_context::sender(ctx));
        transfer::public_share_object(collection);
    }

    /// Calculates and transfers royalties to the `RoyaltyDomain`
    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<SUITRADERS, FT>,
        collection: &mut Collection<SUITRADERS>,
        ctx: &mut TxContext,
    ) {
        let b = royalties::balance_mut(Witness {}, payment);

        let domain = royalty::royalty_domain(collection);
        let royalty_owed =
            royalty::calculate_proportional_royalty(domain, balance::value(b));

        royalty::collect_royalty(collection, b, royalty_owed);
        royalties::transfer_remaining_to_beneficiary(Witness {}, payment, ctx);
    }

    public entry fun mint_nft(
        name: String,
        description: String,
        url: vector<u8>,
        attribute_keys: vector<ascii::String>,
        attribute_values: vector<ascii::String>,
        mint_cap: &MintCap<SUITRADERS>,
        warehouse: &mut Warehouse<SUITRADERS>,
        ctx: &mut TxContext,
    ) {
        let url = sui::url::new_unsafe_from_bytes(url);

        let nft = nft::from_mint_cap(mint_cap, name, url, ctx);

        display::add_display_domain(
            &Witness {}, &mut nft, name, description,
        );

        url::add_url_domain(&Witness {}, &mut nft, url);

        attributes::add_domain_from_vec(
            &Witness {}, &mut nft, attribute_keys, attribute_values,
        );

        display::add_collection_id_domain(
            &Witness {}, &mut nft, mint_cap::collection_id(mint_cap),
        );

        warehouse::deposit_nft(warehouse, nft);
    }
}
