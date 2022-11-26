module nft_protocol::display {
    use std::string::String;

    use sui::url::Url;

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

    public fun new_display_domain(name: String, description: String): DisplayDomain {
        DisplayDomain {
            name,
            description,
        }
    }

    /// === UrlDomain ===

    struct UrlDomain has store {
        url: Url,
    }

    public fun url(domain: &UrlDomain): &Url {
        &domain.url
    }

    public fun new_url_domain(url: Url): UrlDomain {
        UrlDomain {
            url,
        }
    }
}
