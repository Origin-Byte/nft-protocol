module nft_protocol::suimarines {
    use std::string::{Self, String};
    use std::vector;

    use sui::object;
    use sui::balance;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url;

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::tags;
    use nft_protocol::royalty;
    use nft_protocol::display;
    use nft_protocol::witness;
    use nft_protocol::creators;
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::transfer_allowlist;
    use nft_protocol::warehouse::{Self, Warehouse};
    use nft_protocol::royalties::{Self, TradePayment};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::transfer_allowlist_domain;

    const EWrongDescriptionLength: u64 = 1;
    const EWrongUrlLength: u64 = 2;
    const EWrongAttributeKeysLength: u64 = 3;
    const EWrongAttributeValuesLength: u64 = 4;

    /// One time witness is only instantiated in the init method
    struct SUIMARINES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: SUIMARINES, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);

        let (mint_cap, collection) = collection::create(&witness, ctx);

        collection::add_domain(
            &Witness {},
            &mut collection,
            creators::from_address<SUIMARINES, Witness>(
                &Witness {}, sender,
            ),
        );

        // Register custom domains
        display::add_collection_display_domain(
            &Witness {},
            &mut collection,
            string::utf8(b"Suimarines"),
            string::utf8(b"A unique NFT collection of Suimarines on Sui"),
        );

        display::add_collection_url_domain(
            &Witness {},
            &mut collection,
            sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
        );

        display::add_collection_symbol_domain(
            &Witness {},
            &mut collection,
            string::utf8(b"SUIM"),
        );

        let royalty = royalty::from_address(sender, ctx);
        royalty::add_proportional_royalty(&mut royalty, 100);
        royalty::add_royalty_domain(&Witness {}, &mut collection, royalty);

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art());
        tags::add_collection_tag_domain(&Witness {}, &mut collection, tags);

        let allowlist = transfer_allowlist::create(&Witness {}, ctx);
        transfer_allowlist::insert_collection<SUIMARINES, Witness>(
            &Witness {},
            witness::from_witness(&Witness {}),
            &mut allowlist,
        );

        collection::add_domain(
            &Witness {},
            &mut collection,
            transfer_allowlist_domain::from_id(object::id(&allowlist)),
        );

        transfer::transfer(mint_cap, sender);
        transfer::share_object(allowlist);
        transfer::share_object(collection);
    }

    /// Calculates and transfers royalties to the `RoyaltyDomain`
    public entry fun collect_royalty<FT>(
        payment: &mut TradePayment<SUIMARINES, FT>,
        collection: &mut Collection<SUIMARINES>,
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
        attribute_keys: vector<String>,
        attribute_values: vector<String>,
        mint_cap: &MintCap<SUIMARINES>,
        warehouse: &mut Warehouse<SUIMARINES>,
        ctx: &mut TxContext,
    ) {
        let nft = mint(
            name,
            description,
            url,
            attribute_keys,
            attribute_values,
            mint_cap,
            ctx,
        );

        warehouse::deposit_nft(warehouse, nft);
    }

    public entry fun batch_mint_nft(
        name: vector<String>,
        description: vector<String>,
        url: vector<vector<u8>>,
        attribute_keys: vector<vector<String>>,
        attribute_values: vector<vector<String>>,
        mint_cap: &MintCap<SUIMARINES>,
        warehouse: &mut Warehouse<SUIMARINES>,
        ctx: &mut TxContext,
    ) {
        let len = vector::length(&name);

        assert!(vector::length(&description) == len, EWrongDescriptionLength);
        assert!(vector::length(&url) == len, EWrongUrlLength);
        assert!(vector::length(&attribute_keys) == len, EWrongAttributeKeysLength);
        assert!(vector::length(&attribute_values) == len, EWrongAttributeValuesLength);

        while (len > 0) {
            let nft = mint(
                vector::pop_back(&mut name),
                vector::pop_back(&mut description),
                vector::pop_back(&mut url),
                vector::pop_back(&mut attribute_keys),
                vector::pop_back(&mut attribute_values),
                mint_cap,
                ctx,
            );

            warehouse::deposit_nft(warehouse, nft);

            len = len - 1;
        };
    }

    fun mint(
        name: String,
        description: String,
        url: vector<u8>,
        attribute_keys: vector<String>,
        attribute_values: vector<String>,
        mint_cap: &MintCap<SUIMARINES>,
        ctx: &mut TxContext,
    ): Nft<SUIMARINES> {
        let url = url::new_unsafe_from_bytes(url);

        let nft = nft::from_mint_cap(mint_cap, name, url, ctx);

        display::add_display_domain(
            &Witness {}, &mut nft, name, description,
        );

        display::add_url_domain(&Witness {}, &mut nft, url);

        display::add_attributes_domain_from_vec(
            &Witness {}, &mut nft, attribute_keys, attribute_values,
        );

        display::add_collection_id_domain(
            &Witness {}, &mut nft, mint_cap::collection_id(mint_cap),
        );

        nft
    }
}
