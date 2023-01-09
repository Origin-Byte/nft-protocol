module nft_protocol::c_url {
    use std::vector;
    use std::option::{Self, Option};

    use sui::url::Url;
    use sui::tx_context::TxContext;

    use nft_protocol::nft::{Self, Nft};

    friend nft_protocol::composable;

    // TODO: Perhaps use the plugin pattern here?
    struct Witness has drop {}

    /// === CUrlDomain ===

    struct CUrlDomain has store {
        urls: vector<Url>,
    }

    /// Gets URL of `UrlDomain`
    public fun url(domain: &CUrlDomain): &vector<Url> {
        &domain.urls
    }

    /// Creates new `UrlDomain` with a URL
    public fun new_c_url_domain(urls: vector<Url>): CUrlDomain {
        CUrlDomain { urls }
    }

    /// Creates new `UrlDomain` with a URL
    public (friend) fun add_url(
        c_url: &mut CUrlDomain,
        url: Url,
    ) {
        vector::push_back(&mut c_url.urls, url)
    }

    /// ====== Interoperability ===

    public fun display_url<C>(nft: &Nft<C>): Option<vector<Url>> {
        if (!nft::has_domain<C, CUrlDomain>(nft)) {
            return option::none()
        };

        option::some(*url(nft::borrow_domain<C, CUrlDomain>(nft)))
    }

    public fun add_url_domain<C>(
        nft: &mut Nft<C>,
        urls: vector<Url>,
        ctx: &mut TxContext
    ) {
        nft::add_domain(nft, new_c_url_domain(urls), ctx);
    }
}
