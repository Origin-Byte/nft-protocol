module nft_protocol::display {
    use std::string::String;
    use std::option::{Self, Option};

    use sui::url::Url;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::collection::{Self, Collection, MintCap};
    use nft_protocol::attribution;

    struct Witness has drop {}

    struct DisplayDomain has store {
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
        description: String
    ): DisplayDomain {
        DisplayDomain { name, description }
    }

    /// Sets name of `DisplayDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_name<C>(
        collection: &mut Collection<C>,
        name: String,
        ctx: &mut TxContext,
    ) {
        attribution::assert_collection_has_creator(
            collection, tx_context::sender(ctx)
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
        attribution::assert_collection_has_creator(
            collection, tx_context::sender(ctx)
        );

        let domain: &mut DisplayDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.description = description;
    }

    /// ====== Interoperability ===

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
        nft::add_domain(nft, new_display_domain(name, description), ctx);
    }

    public fun add_collection_display_domain<C>(
        nft: &mut Collection<C>,
        mint_cap: &mut MintCap<C>,
        name: String,
        description: String
    ) {
        collection::add_domain(
            nft, mint_cap, new_display_domain(name, description)
        );
    }

    /// === UrlDomain ===

    struct UrlDomain has store {
        url: Url,
    }

    /// Gets URL of `UrlDomain`
    public fun url(domain: &UrlDomain): &Url {
        &domain.url
    }

    /// Creates new `UrlDomain` with a URL
    public fun new_url_domain(url: Url): UrlDomain {
        UrlDomain { url }
    }

    /// Sets name of `DisplayDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_url<C>(
        collection: &mut Collection<C>,
        url: Url,
        ctx: &mut TxContext,
    ) {
        attribution::assert_collection_has_creator(
            collection, tx_context::sender(ctx)
        );

        let domain: &mut UrlDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.url = url;
    }

    /// ====== Interoperability ===

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
        ctx: &mut TxContext
    ) {
        nft::add_domain(nft, new_url_domain(url), ctx);
    }

    public fun add_collection_url_domain<C>(
        nft: &mut Collection<C>,
        mint_cap: &mut MintCap<C>,
        url: Url
    ) {
        collection::add_domain(nft, mint_cap, new_url_domain(url));
    }

    /// === SymbolDomain ===

    struct SymbolDomain has store {
        symbol: String,
    }

    /// Gets symbol of `SymbolDomain`
    public fun symbol(domain: &SymbolDomain): &String {
        &domain.symbol
    }

    /// Creates new `SymbolDomain` with a symbol
    public fun new_symbol_domain(symbol: String): SymbolDomain {
        SymbolDomain { symbol }
    }

    /// Sets name of `DisplayDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_symbol<C>(
        collection: &mut Collection<C>,
        symbol: String,
        ctx: &mut TxContext,
    ) {
        attribution::assert_collection_has_creator(
            collection, tx_context::sender(ctx)
        );

        let domain: &mut SymbolDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.symbol = symbol;
    }

    /// ====== Interoperability ===

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
        ctx: &mut TxContext
    ) {
        nft::add_domain(nft, new_symbol_domain(symbol), ctx);
    }

    public fun add_collection_symbol_domain<C>(
        nft: &mut Collection<C>,
        mint_cap: &mut MintCap<C>,
        symbol: String
    ) {
        collection::add_domain(nft, mint_cap, new_symbol_domain(symbol));
    }

    /// === AttributesDomain ===

    struct Attributes has store {
        keys: vector<String>,
        values: vector<String>,
    }

    /// Gets Keys of `Attributes`
    public fun keys(domain: &Attributes): &vector<String> {
        &domain.keys
    }

    /// Gets Values of `Attributes`
    public fun values(domain: &Attributes): &vector<String> {
        &domain.values
    }

    /// Creates new `Attributes` with a keys and values
    public fun new_attributes_domain(
        keys: vector<String>,
        values: vector<String>
    ): Attributes {
        Attributes { keys, values }
    }

    /// ====== Interoperability ===

    public fun display_attribute_keys<C>(nft: &NFT<C>): &vector<String> {
        keys(nft::borrow_domain<C, Attributes>(nft))
    }

    public fun display_attribute_values<C>(nft: &NFT<C>): &vector<String> {
        values(nft::borrow_domain<C, Attributes>(nft))
    }

    public fun add_attributes_domain<C>(
        nft: &mut NFT<C>,
        keys: vector<String>,
        values: vector<String>,
        ctx: &mut TxContext
    ) {
        nft::add_domain(nft, new_attributes_domain(keys, values), ctx);
    }
}
