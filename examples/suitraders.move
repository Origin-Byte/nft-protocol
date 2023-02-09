module nft_protocol::suitraders {
    use std::string::{Self, String};

    use sui::url;
    use sui::balance;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::witness;
    use nft_protocol::creators;
    use nft_protocol::warehouse::{Self, Warehouse};
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::mint_cap::MintCap;

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
            delegated_witness,
            &mut collection,
            creators::from_address<SUITRADERS, Witness>(
                &Witness {}, tx_context::sender(ctx), ctx,
            ),
        );

        // Register custom domains
        display::add_collection_display_domain(
            delegated_witness,
            &mut collection,
            string::utf8(b"Suitraders"),
            string::utf8(b"A unique NFT collection of Suitraders on Sui"),
            ctx,
        );

        display::add_collection_url_domain(
            delegated_witness,
            &mut collection,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
            ctx,
        );

        display::add_collection_symbol_domain(
            delegated_witness,
            &mut collection,
            string::utf8(b"SUITR"),
            ctx,
        );

        let royalty = royalty::from_address(tx_context::sender(ctx), ctx);
        royalty::add_proportional_royalty(&mut royalty, 100);
        royalty::add_royalty_domain(
            delegated_witness,
            &mut collection,
            royalty,
        );

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art());
        tags::add_collection_tag_domain(
            delegated_witness,
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

        transfer::share_object(listing);

        transfer::transfer(mint_cap, tx_context::sender(ctx));
        transfer::share_object(collection);
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
        url: String,
        attribute_keys: vector<String>,
        attribute_values: vector<String>,
        mint_cap: &MintCap<SUITRADERS>,
        warehouse: &mut Warehouse<SUITRADERS>,
        ctx: &mut TxContext,
    ) {
        let url = url::new_unsafe_from_bytes(*string::bytes(&url));

        let nft = nft::from_mint_cap(
            mint_cap, name, url, tx_context::sender(ctx), ctx,
        );
        let delegated_witness = witness::from_witness(&Witness {});

        display::add_display_domain(
            delegated_witness, &mut nft, name, description, ctx,
        );

        display::add_url_domain(
            delegated_witness, &mut nft, url, ctx,
        );

        display::add_attributes_domain_from_vec(
            delegated_witness, &mut nft, attribute_keys, attribute_values, ctx,
        );

        warehouse::deposit_nft(warehouse, nft);
    }
}
