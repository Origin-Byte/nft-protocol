module nft_protocol::suimarines {
    use std::ascii;
    use std::string::{Self, String};
    use std::vector;

    use sui::object;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::attributes;
    use nft_protocol::collection_id;
    use nft_protocol::collection;
    use nft_protocol::creators;
    use nft_protocol::display;
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::royalty_strategy_bps;
    use nft_protocol::royalty;
    use nft_protocol::symbol;
    use nft_protocol::tags;
    use nft_protocol::transfer_allowlist_domain;
    use nft_protocol::transfer_allowlist;
    use nft_protocol::url;
    use nft_protocol::warehouse::{Self, Warehouse};
    use nft_protocol::witness;

    const EWRONG_DESCRIPTION_LENGTH: u64 = 1;
    const EWRONG_URL_LENGTH: u64 = 2;
    const EWRONG_ATTRIBUTE_KEYS_LENGTH: u64 = 3;
    const EWRONG_ATTRIBUTE_VALUES_LENGTH: u64 = 4;

    /// One time witness is only instantiated in the init method
    struct SUIMARINES has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}

    fun init(witness: SUIMARINES, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let (mint_cap, collection) = nft::new_collection(&witness, ctx);

        // Creates a new policy and registers an allowlist rule to it.
        // Therefore now to finish a transfer, the allowlist must be included
        // in the chain.
        let publisher = sui::package::claim(witness, ctx);
        let (transfer_policy, transfer_policy_cap) =
            sui::transfer_policy::new<SUIMARINES>(&publisher, ctx);
        nft_protocol::transfer_allowlist::add_policy_rule(
            &mut transfer_policy,
            &transfer_policy_cap,
        );

        nft::add_collection_domain(
            Witness {},
            &mut collection,
            creators::from_address_delegated<Nft<SUIMARINES>>(
                nft::delegate_witness(Witness {}), sender,
            ),
        );

        // Register custom domains
        nft::add_collection_domain(
            Witness {},
            &mut collection,
            display::new(
                string::utf8(b"Suimarines"),
                string::utf8(b"A unique NFT collection of Suimarines on Sui"),
            ),
        );

        nft::add_collection_domain(
            Witness {},
            &mut collection,
            url::new(
                sui::url::new_unsafe_from_bytes(b"https://originbyte.io/"),
            ),
        );

        nft::add_collection_domain(
            Witness {},
            &mut collection,
            symbol::new(string::utf8(b"SUIM")),
        );

        royalty_strategy_bps::create_domain_and_add_strategy(
            &Witness {}, &mut collection, 100, ctx,
        );

        let tags = tags::empty(ctx);
        tags::add_tag(&mut tags, tags::art());
        nft::add_collection_domain(Witness {}, &mut collection, tags);

        let allowlist = transfer_allowlist::create(&Witness {}, ctx);
        transfer_allowlist::insert_collection<SUIMARINES, Witness>(
            &mut allowlist,
            &Witness {},
            witness::from_witness<SUIMARINES, Witness>(Witness {}),
        );

        nft::add_collection_domain(
            Witness {},
            &mut collection,
            transfer_allowlist_domain::from_id(object::id(&allowlist)),
        );

        transfer::public_transfer(mint_cap, sender);
        transfer::public_transfer(publisher, sender);
        transfer::public_transfer(transfer_policy_cap, sender);
        transfer::public_share_object(transfer_policy);
        transfer::public_share_object(allowlist);
        transfer::public_share_object(collection);
    }

    public entry fun mint_nft(
        name: String,
        description: String,
        url: vector<u8>,
        attribute_keys: vector<ascii::String>,
        attribute_values: vector<ascii::String>,
        mint_cap: &mut MintCap<Nft<SUIMARINES>>,
        warehouse: &mut Warehouse<Nft<SUIMARINES>>,
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
        attribute_keys: vector<vector<ascii::String>>,
        attribute_values: vector<vector<ascii::String>>,
        mint_cap: &mut MintCap<Nft<SUIMARINES>>,
        warehouse: &mut Warehouse<Nft<SUIMARINES>>,
        ctx: &mut TxContext,
    ) {
        let len = vector::length(&name);

        assert!(vector::length(&description) == len, EWRONG_DESCRIPTION_LENGTH);
        assert!(vector::length(&url) == len, EWRONG_URL_LENGTH);
        assert!(vector::length(&attribute_keys) == len, EWRONG_ATTRIBUTE_KEYS_LENGTH);
        assert!(vector::length(&attribute_values) == len, EWRONG_ATTRIBUTE_VALUES_LENGTH);

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
        attribute_keys: vector<ascii::String>,
        attribute_values: vector<ascii::String>,
        mint_cap: &mut MintCap<Nft<SUIMARINES>>,
        ctx: &mut TxContext,
    ): Nft<SUIMARINES> {
        let url = sui::url::new_unsafe_from_bytes(url);

        let nft = nft::from_mint_cap(mint_cap, name, url, ctx);

        nft::add_domain(Witness {}, &mut nft, display::new(name, description));

        nft::add_domain(Witness {}, &mut nft, url::new(url));

        nft::add_domain(
            Witness {},
            &mut nft,
            attributes::from_vec(attribute_keys, attribute_values),
        );

        nft::add_domain(
            Witness {},
            &mut nft,
            collection_id::from_mint_cap(mint_cap),
        );

        nft
    }
}
