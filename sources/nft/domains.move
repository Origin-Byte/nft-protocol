module nft_protocol::domains {
    use std::string::String;
    use std::option::{Self, Option};

    use sui::url::Url;

    use nft_protocol::nft::{Self, NFT};

    /// Defines a standard domain that all Art NFTs should contain which allows
    /// display interoperability.
    struct DisplayDomain has store {
        name: String,
        description: String,
        url: Url,
    }

    public fun display_new(name: String, description: String, url: Url): DisplayDomain {
        DisplayDomain {
            name,
            description,
            url,
        }
    }

    public fun name(display: &DisplayDomain): String {
        display.name
    }

    public fun display_name<C>(nft: &NFT<C>): Option<String> {
        if (!nft::has_domain<C, DisplayDomain>(nft)) {
            return option::none()
        };

        option::some(name(nft::borrow_domain<C, DisplayDomain>(nft)))
    }

    public fun description(display: &DisplayDomain): String {
        display.description
    }

    public fun display_description<C>(nft: &NFT<C>): Option<String> {
        if (!nft::has_domain<C, DisplayDomain>(nft)) {
            return option::none()
        };

        option::some(description(nft::borrow_domain<C, DisplayDomain>(nft)))
    }

    public fun url(display: &DisplayDomain): Url {
        display.url
    }

    public fun display_url<C>(nft: &NFT<C>): Option<Url> {
        if (!nft::has_domain<C, DisplayDomain>(nft)) {
            return option::none()
        };

        option::some(url(nft::borrow_domain<C, DisplayDomain>(nft)))
    }

    /// Defines a standard domain that defines the royalties that must be paid
    /// when trading the NFT.
    ///
    /// If no royalties are owned then the domain will not be present on the
    /// NFT.
    ///
    /// [RoyaltyDomain] is not yet integrated with the remainder of
    /// `nft_protocol` however serves to illustrate that royalty policies can
    /// be defined on the NFT level.
    struct RoyaltyDomain has store {
        bps: u64,
        recipient: address,
    }

    public fun royalty_new(bps: u64, recipient: address): RoyaltyDomain {
        RoyaltyDomain {
            bps,
            recipient
        }
    }

    public fun bps(royalty: &RoyaltyDomain): u64 {
        royalty.bps
    }

    public fun royalty_bps<C>(nft: &NFT<C>): Option<u64> {
        if (!nft::has_domain<C, RoyaltyDomain>(nft)) {
            return option::none()
        };

        option::some(bps(nft::borrow_domain<C, RoyaltyDomain>(nft)))
    }

    public fun recipient(royalty: &RoyaltyDomain): address {
        royalty.recipient
    }

    public fun royalty_recipient<C>(nft: &NFT<C>): Option<address> {
        if (!nft::has_domain<C, RoyaltyDomain>(nft)) {
            return option::none()
        };

        option::some(recipient(nft::borrow_domain<C, RoyaltyDomain>(nft)))
    }
}
