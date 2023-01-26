/// Module of NFT domains for displaying standard information
///
/// Current display domains are:
///     - DisplayDomain (For NFTs and Collections)
///     - UrlDomain (For NFTs and Collections)
///     - SymbolDomain (For Collections)
///     - Attributes (For NFTs)
module nft_protocol::display {
    use std::string::String;
    use std::option::{Self, Option};

    use sui::url::Url;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};

    use nft_protocol::utils;
    use nft_protocol::creators;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::collection::{Self, Collection, MintCap};

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    struct DisplayDomain has key, store {
        id: UID,
        name: String,
        description: String,
    }

    /// Gets name of `DisplayDomain`
    public fun name(domain: &DisplayDomain): &String {
        &domain.name
    }

    /// Gets description of `DisplayDomain`
    public fun description(domain: &DisplayDomain): &String {
        &domain.description
    }

    /// Creates a new `DisplayDomain` with name and description
    public fun new_display_domain(
        name: String,
        description: String,
        ctx: &mut TxContext,
    ): DisplayDomain {
        DisplayDomain { id: object::new(ctx), name, description }
    }

    /// Sets name of `DisplayDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_name<C>(
        collection: &mut Collection<C>,
        name: String,
        ctx: &mut TxContext,
    ) {
        creators::assert_collection_has_creator(
            collection, &tx_context::sender(ctx)
        );

        let domain: &mut DisplayDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.name = name;
    }

    /// Sets description of `DisplayDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_description<C>(
        collection: &mut Collection<C>,
        description: String,
        ctx: &mut TxContext,
    ) {
        creators::assert_collection_has_creator(
            collection, &tx_context::sender(ctx)
        );

        let domain: &mut DisplayDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.description = description;
    }

    // ====== Interoperability ===

    public fun display_domain<C>(
        nft: &Nft<C>,
    ): &DisplayDomain {
        nft::borrow_domain(nft)
    }

    public fun collection_display_domain<C>(
        nft: &Collection<C>,
    ): &DisplayDomain {
        collection::borrow_domain(nft)
    }

    public fun add_display_domain<C>(
        nft: &mut Nft<C>,
        name: String,
        description: String,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(nft, new_display_domain(name, description, ctx), ctx);
    }

    public fun add_collection_display_domain<C>(
        collection: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        name: String,
        description: String,
        ctx: &mut TxContext,
    ) {
        collection::add_domain(
            collection, mint_cap, new_display_domain(name, description, ctx)
        );
    }

    // === UrlDomain ===

    struct UrlDomain has key, store {
        id: UID,
        url: Url,
    }

    /// Gets URL of `UrlDomain`
    public fun url(domain: &UrlDomain): &Url {
        &domain.url
    }

    /// Creates new `UrlDomain` with a URL
    public fun new_url_domain(url: Url, ctx: &mut TxContext,): UrlDomain {
        UrlDomain { id: object::new(ctx), url }
    }

    /// Sets name of `UrlDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_url<C>(
        collection: &mut Collection<C>,
        url: Url,
        ctx: &mut TxContext,
    ) {
        creators::assert_collection_has_creator(
            collection, &tx_context::sender(ctx)
        );

        let domain: &mut UrlDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.url = url;
    }

    // ====== Interoperability ===

    public fun display_url<C>(nft: &Nft<C>): Option<Url> {
        if (!nft::has_domain<C, UrlDomain>(nft)) {
            return option::none()
        };

        option::some(*url(nft::borrow_domain<C, UrlDomain>(nft)))
    }

    public fun display_collection_url<C>(nft: &Collection<C>): Option<Url> {
        if (!collection::has_domain<C, UrlDomain>(nft)) {
            return option::none()
        };

        option::some(*url(collection::borrow_domain<C, UrlDomain>(nft)))
    }

    public fun add_url_domain<C>(
        nft: &mut Nft<C>,
        url: Url,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(nft, new_url_domain(url, ctx), ctx);
    }

    public fun add_collection_url_domain<C>(
        nft: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        url: Url,
        ctx: &mut TxContext,
    ) {
        collection::add_domain(nft, mint_cap, new_url_domain(url, ctx));
    }

    // === SymbolDomain ===

    struct SymbolDomain has key, store {
        id: UID,
        symbol: String,
    }

    /// Gets symbol of `SymbolDomain`
    public fun symbol(domain: &SymbolDomain): &String {
        &domain.symbol
    }

    /// Creates new `SymbolDomain` with a symbol
    public fun new_symbol_domain(
        symbol: String,
        ctx: &mut TxContext,
    ): SymbolDomain {
        SymbolDomain { id: object::new(ctx), symbol }
    }

    /// Sets name of `DisplayDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_symbol<C>(
        collection: &mut Collection<C>,
        symbol: String,
        ctx: &mut TxContext,
    ) {
        creators::assert_collection_has_creator(
            collection, &tx_context::sender(ctx)
        );

        let domain: &mut SymbolDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.symbol = symbol;
    }

    // ====== Interoperability ===

    public fun display_symbol<C>(nft: &Nft<C>): Option<String> {
        if (!nft::has_domain<C, SymbolDomain>(nft)) {
            return option::none()
        };

        option::some(*symbol(nft::borrow_domain<C, SymbolDomain>(nft)))
    }

    public fun display_collection_symbol<C>(
        nft: &Collection<C>
    ): Option<String> {
        if (!collection::has_domain<C, SymbolDomain>(nft)) {
            return option::none()
        };

        option::some(*symbol(collection::borrow_domain<C, SymbolDomain>(nft)))
    }

    public fun add_symbol_domain<C>(
        nft: &mut Nft<C>,
        symbol: String,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(nft, new_symbol_domain(symbol, ctx), ctx);
    }

    public fun add_collection_symbol_domain<C>(
        nft: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        symbol: String,
        ctx: &mut TxContext,
    ) {
        collection::add_domain(nft, mint_cap, new_symbol_domain(symbol, ctx));
    }

    // === AttributesDomain ===

    struct AttributesDomain has key, store {
        id: UID,
        map: VecMap<String, String>,
    }

    /// Gets Keys of `Attributes`
    public fun attributes(domain: &AttributesDomain): &VecMap<String, String> {
        &domain.map
    }

    /// Gets Keys of `Attributes`
    public fun keys(domain: &AttributesDomain): vector<String> {
        let (keys, _) = vec_map::into_keys_values(domain.map);
        keys
    }

    /// Gets Values of `Attributes`
    public fun values(domain: &AttributesDomain): vector<String> {
        let (_, values) = vec_map::into_keys_values(domain.map);
        values
    }

    /// Creates new `Attributes` with a keys and values
    public fun new_attributes_domain(
        map: VecMap<String, String>,
        ctx: &mut TxContext,
    ): AttributesDomain {
        AttributesDomain { id: object::new(ctx), map }
    }

    // ====== Interoperability ===

    public fun display_attribute<C>(nft: &Nft<C>): &AttributesDomain {
        nft::borrow_domain<C, AttributesDomain>(nft)
    }

    public fun display_attribute_mut<C>(
        nft: &mut Nft<C>,
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ): &mut AttributesDomain {
        creators::assert_collection_has_creator(
            collection, &tx_context::sender(ctx)
        );
        nft::borrow_domain_mut(Witness {}, nft)
    }

    public fun add_attributes_domain<C>(
        nft: &mut Nft<C>,
        map: VecMap<String, String>,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(nft, new_attributes_domain(map, ctx), ctx);
    }

    public fun add_attributes_domain_from_vec<C>(
        nft: &mut Nft<C>,
        keys: vector<String>,
        values: vector<String>,
        ctx: &mut TxContext,
    ) {
        let map =  utils::from_vec_to_map<String, String>(keys, values);

        nft::add_domain(nft, new_attributes_domain(map, ctx), ctx);
    }
}
