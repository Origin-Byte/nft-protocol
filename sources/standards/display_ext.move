module nft_protocol::display_ext {
    use std::string::String;
    use std::option::{Self, Option};

    use sui::url::Url;

    use nft_protocol::display::{Self, DisplayDomain, UrlDomain};
    use nft_protocol::nft::{Self, NFT};
    use nft_protocol::collection::{Self, Collection};

    /// === Display ===

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
        description: String
    ) {
        nft::add_domain(nft, display::new_display_domain(name, description));
    }

    public fun add_collection_display_domain<C>(
        nft: &mut Collection<C>,
        name: String,
        description: String
    ) {
        collection::add_domain(nft, display::new_display_domain(name, description));
    }

    public fun display_name<C>(nft: &NFT<C>): Option<String> {
        if (!nft::has_domain<C, DisplayDomain>(nft)) {
            return option::none()
        };

        option::some(*display::name(display_domain(nft)))
    }

    public fun collection_display_name<C>(nft: &Collection<C>): Option<String> {
        if (!collection::has_domain<C, DisplayDomain>(nft)) {
            return option::none()
        };

        option::some(*display::name(collection_display_domain(nft)))
    }

    public fun display_description<C>(nft: &NFT<C>): Option<String> {
        if (!nft::has_domain<C, DisplayDomain>(nft)) {
            return option::none()
        };

        option::some(*display::description(display_domain(nft)))
    }

    public fun collection_display_description<C>(nft: &Collection<C>): Option<String> {
        if (!collection::has_domain<C, DisplayDomain>(nft)) {
            return option::none()
        };

        option::some(*display::description(collection_display_domain(nft)))
    }

    /// === Url ===

    public fun url_domain<C>(nft: &NFT<C>): Option<Url> {
        if (!nft::has_domain<C, UrlDomain>(nft)) {
            return option::none()
        };

        option::some(*display::url(nft::borrow_domain<C, UrlDomain>(nft)))
    }

    public fun collection_url_domain<C>(nft: &Collection<C>): Option<Url> {
        if (!collection::has_domain<C, UrlDomain>(nft)) {
            return option::none()
        };

        option::some(*display::url(collection::borrow_domain<C, UrlDomain>(nft)))
    }

    public fun add_url_domain<C>(nft: &mut NFT<C>, url: Url) {
        nft::add_domain(nft, display::new_url_domain(url));
    }

    public fun add_collection_url_domain<C>(nft: &mut Collection<C>, url: Url) {
        collection::add_domain(nft, display::new_url_domain(url));
    }
}
