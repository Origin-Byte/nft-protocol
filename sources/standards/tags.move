/// Module of NFT and Collection `Tags` domain
///
/// This domain allows wallets to organize the NFT display based on categories,
/// such as Art, Profile Picture, Collectibles, etc.
module nft_protocol::tags {
    // TODO: Consider if we should add a wrapper domain Tags {bag} such that
    // wallet can always query this domain instead of having to query all domains
    // and figure out which ones are tags or not.
    use sui::bag::{Self, Bag};
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::collection::{Self, Collection, MintCap};
    use nft_protocol::creators;

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

    struct TagDomain has key, store {
        id: UID,
        bag: Bag,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    public fun empty(ctx: &mut TxContext): TagDomain {
        TagDomain { id: object::new(ctx), bag: bag::new(ctx) }
    }

    public fun has_tag<T: store + drop>(domain: &TagDomain): bool {
        utils::assert_same_module_as_witness<T, Witness>();
        bag::contains_with_type<Marker<T>, T>(&domain.bag, utils::marker<T>())
    }

    /// Adds tag to `TagDomain`
    public fun add_tag<T: store + drop>(
        domain: &mut TagDomain,
        tag: T,
    ) {
        utils::assert_same_module_as_witness<T, Witness>();
        bag::add(&mut domain.bag, utils::marker<T>(), tag)
    }

    /// Removes tag from `TagDomain`
    public fun remove_tag<T: store + drop>(
        domain: &mut TagDomain,
    ) {
        utils::assert_same_module_as_witness<T, Witness>();
        let _: T = bag::remove(&mut domain.bag, utils::marker<T>());
    }

    // ====== Interoperability ===

    public fun tag_domain<C>(
        nft: &Nft<C>,
    ): &TagDomain {
        nft::borrow_domain(nft)
    }

    public fun collection_tag_domain<C>(
        collection: &Collection<C>,
    ): &TagDomain {
        collection::borrow_domain(collection)
    }

    /// Requires that sender is a creator
    public fun collection_tag_domain_mut<C>(
        collection: &mut Collection<C>,
        ctx: &mut TxContext,
    ): &mut TagDomain {
        creators::assert_collection_has_creator(
            collection, &tx_context::sender(ctx)
        );

        collection::borrow_domain_mut(Witness {}, collection)
    }

    public fun add_tag_domain<C>(
        nft: &mut Nft<C>,
        tags: TagDomain,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(nft, tags, ctx);
    }

    public fun add_collection_tag_domain<C>(
        collection: &mut Collection<C>,
        mint_cap: &MintCap<C>,
        tags: TagDomain,
    ) {
        collection::add_domain(collection, mint_cap, tags);
    }
}
