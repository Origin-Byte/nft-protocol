module nft_protocol::display {
    use std::string::String;
    use std::option::{Self, Option};

    use sui::url::Url;
    use sui::tx_context::TxContext;

    use nft_protocol::nft::{Self, NFT};
    use nft_protocol::collection::{Self, Collection};

    struct DisplayDomain has store {
        name: String,
        description: String,
    }

    public fun name(domain: &DisplayDomain): &String {
        &domain.name
    }

    public fun description(domain: &DisplayDomain): &String {
        &domain.description
    }

    public fun new_display_domain(
        name: String,
        description: String
    ): DisplayDomain {
        DisplayDomain { name, description }
    }

    /// ====== Interoperability ===

    public fun display_domain<C>(
        nft: &NFT<C>,
    ): &DisplayDomain {
        nft::borrow_domain(nft)
    }

    public fun collection_display_domain<C>(
        nft: &Collection<C>,
    ): &DisplayDomain {
        collection::borrow_domain(nft)
    }

    public fun add_display_domain<C>(
        nft: &mut NFT<C>,
        name: String,
        description: String,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(nft, new_display_domain(name, description), ctx);
    }

    public fun add_collection_display_domain<C>(
        nft: &mut Collection<C>,
        name: String,
        description: String
    ) {
        collection::add_domain(nft, new_display_domain(name, description));
    }

    /// === UrlDomain ===

    struct UrlDomain has store {
        url: Url,
    }

    public fun url(domain: &UrlDomain): &Url {
        &domain.url
    }

    public fun new_url_domain(url: Url): UrlDomain {
        UrlDomain { url }
    }

    /// ====== Interoperability ===

    public fun display_url<C>(nft: &NFT<C>): Option<Url> {
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
        nft: &mut NFT<C>,
        url: Url,
        ctx: &mut TxContext
    ) {
        nft::add_domain(nft, new_url_domain(url), ctx);
    }

    public fun add_collection_url_domain<C>(
        nft: &mut Collection<C>,
        url: Url
    ) {
        collection::add_domain(nft, new_url_domain(url));
    }

    /// === SymbolDomain ===

    struct SymbolDomain has store {
        symbol: String,
    }

    public fun symbol(domain: &SymbolDomain): &String {
        &domain.symbol
    }

    public fun new_symbol_domain(symbol: String): SymbolDomain {
        SymbolDomain { symbol }
    }

    /// ====== Interoperability ===

    public fun display_symbol<C>(nft: &NFT<C>): Option<String> {
        if (!nft::has_domain<C, SymbolDomain>(nft)) {
            return option::none()
        };

        option::some(*symbol(nft::borrow_domain<C, SymbolDomain>(nft)))
    }

    public fun display_collection_symbol<C>(nft: &Collection<C>): Option<String> {
        if (!collection::has_domain<C, SymbolDomain>(nft)) {
            return option::none()
        };

        option::some(*symbol(collection::borrow_domain<C, SymbolDomain>(nft)))
    }

    public fun add_symbol_domain<C>(
        nft: &mut NFT<C>,
        symbol: String,
        ctx: &mut TxContext
    ) {
        nft::add_domain(nft, new_symbol_domain(symbol), ctx);
    }

    public fun add_collection_symbol_domain<C>(
        nft: &mut Collection<C>,
        symbol: String
    ) {
        collection::add_domain(nft, new_symbol_domain(symbol));
    }
}
