module nft_protocol::tags {
    use sui::bag::{Self, Bag};
    use sui::tx_context::TxContext;

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::nft::{Self, NFT};
    use nft_protocol::collection::{Self, Collection};

    // === Tags ===

    struct Art has store, drop {}
    struct ProfilePicture has store, drop {}
    // An example of a collectible would be digital Baseball cards
    struct Collectible has store, drop {}
    struct GameAsset has store, drop {}
    // A tokenised asset is a real world asset represented on-chian,
    // i.e. insurance policies, loan contracts, etc.
    struct TokenisedAsset has store, drop {}
    // Tickers are what's called the abbreviation used to uniquely identify
    // publicly traded assets, i.e. Tesla trades as $TSLA and Amazon as $AMZN.
    // Crypto asset tickers themselves can be minted and sold as NFTs.
    struct Ticker has store, drop {}
    struct DomainName has store, drop {}
    struct Music has store, drop {}
    struct Video has store, drop {}
    struct Ticket has store, drop {}
    struct License has store, drop {}

    public fun art(): Art {
        Art {}
    }

    public fun profile_picture(): ProfilePicture {
        ProfilePicture {}
    }

    public fun collectible(): Collectible {
        Collectible {}
    }

    public fun game_asset(): GameAsset {
        GameAsset {}
    }

    public fun tokenised_asset(): TokenisedAsset {
        TokenisedAsset {}
    }

    public fun ticker(): Ticker {
        Ticker {}
    }

    public fun domain_name(): DomainName {
        DomainName {}
    }

    public fun music(): Music {
        Music {}
    }

    public fun video(): Video {
        Video {}
    }

    public fun ticket(): Ticket {
        Ticket {}
    }

    public fun license(): License {
        License {}
    }

    // === TagDomain ===

    struct TagDomain has store {
        bag: Bag,
    }

    struct Witness {}

    public fun empty(ctx: &mut TxContext): TagDomain {
        TagDomain { bag: bag::new(ctx) }
    }

    public fun has_tag<T: store>(domain: &TagDomain): bool {
        utils::assert_same_module_as_witness<T, Witness>();
        bag::contains_with_type<Marker<T>, T>(&domain.bag, utils::marker<T>())
    }

    // TODO(https://github.com/Origin-Byte/nft-protocol/issues/125):
    // Protect with AttributionDomain
    public fun add_tag<T: store>(
        domain: &mut TagDomain,
        tag: T,
        _ctx: &mut TxContext,
    ) {
        utils::assert_same_module_as_witness<T, Witness>();
        bag::add(&mut domain.bag, utils::marker<T>(), tag)
    }

    /// ====== Interoperability ===

    public fun tag_domain<C>(
        nft: &NFT<C>,
    ): &TagDomain {
        nft::borrow_domain(nft)
    }

    public fun collection_tag_domain<C>(
        nft: &Collection<C>,
    ): &TagDomain {
        collection::borrow_domain(nft)
    }

    public fun add_tag_domain<C>(
        nft: &mut NFT<C>,
        tags: TagDomain,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(nft, tags, ctx);
    }

    public fun add_collection_tag_domain<C>(
        nft: &mut Collection<C>,
        tags: TagDomain,
    ) {
        collection::add_domain(nft, tags);
    }
}
