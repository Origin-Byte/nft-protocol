/// Module of NFT and Collection `Tags` domain
///
/// This domain allows wallets to organize the NFT display based on categories,
/// such as Art, Profile Picture, Collectibles, etc.
module nft_protocol::tags {
    // TODO: limit tags to three
    // Ability to add tags with vector<string>
    use sui::dynamic_field as df;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::bag::{Self, Bag};

    use nft_protocol::utils::{Self, Marker};

    /// `Tags` was not defined
    ///
    /// Call `tags::add_domain` to add `TagsDomain`.
    const EUndefinedTags: u64 = 1;

    /// `Tags` already defined
    ///
    /// Call `tags::borrow_domain` to borrow domain.
    const EExistingTags: u64 = 2;

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

    // === Tags ===

    struct Tags has store {
        id: UID,
        tags: Bag
    }

    /// Creates empty `Tags`
    public fun empty(ctx: &mut TxContext): Tags {
        Tags { id: object::new(ctx), tags: bag::new(ctx) }
    }


    /// Adds tag to `Tags`
    public fun add_tag<Tag: store + drop>(
        tags: &mut Tags,
        tag: Tag,
    ) {
        bag::add(&mut tags.tags, utils::marker<Tag>(), tag);
    }

    /// Removes tag from `Tags`
    public fun remove_tag<Tag: store + drop>(tags: &mut Tags) {
        let _: Tag = bag::remove(&mut tags.tags, utils::marker<Tag>());
    }

    // === Interoperability ===

    /// Returns whether `Tags` is registered on `Nft`
    public fun has_domain(nft: &UID): bool {
        df::exists_with_type<Marker<Tags>, Tags>(
            nft, utils::marker(),
        )
    }

    /// Borrows `Tags` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Tags` is not registered on the `Nft`
    public fun borrow_domain(nft: &UID): &Tags {
        assert_tags(nft);
        df::borrow(nft, utils::marker<Tags>())
    }

    /// Mutably borrows `Tags` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Tags` is not registered on the `Nft`
    public fun borrow_domain_mut(nft: &mut UID): &mut Tags {
        assert_tags(nft);
        df::borrow_mut(nft, utils::marker<Tags>())
    }

    /// Adds `Tags` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Tags` domain already exists
    public fun add_domain(
        nft: &mut UID,
        domain: Tags,
    ) {
        assert_no_tags(nft);
        df::add(nft, utils::marker<Tags>(), domain);
    }

    /// Remove `Tags` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Tags` domain doesnt exist
    public fun remove_domain(nft: &mut UID): Tags {
        assert_tags(nft);
        df::remove(nft, utils::marker<Tags>())
    }

    // === Assertions ===

    /// Asserts that `Tags` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Tags` is not registered
    public fun assert_tags(nft: &UID) {
        assert!(has_domain(nft), EUndefinedTags);
    }

    /// Asserts that `Tags` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Tags` is registered
    public fun assert_no_tags(nft: &UID) {
        assert!(!has_domain(nft), EExistingTags);
    }
}
