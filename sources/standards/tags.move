module nft_protocol::tags_x {
    use sui::dynamic_field as df;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::witness::Witness as DelegatedWitness;
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

    // === Tags ===

    struct Tags has store {
        id: UID,
        tags: Bag,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    public fun empty(ctx: &mut TxContext): Tags {
        Tags { id: object::new(ctx) }
    }

    public fun has_tag<T: store + drop>(domain: &Tags): bool {
        utils::assert_same_module_as_witness<T, Witness>();
        df::exists_with_type<Marker<T>, T>(&domain.id, utils::marker<T>())
    }

    /// Adds tag to `TagDomain`
    public fun add_tag<T: store + drop>(
        domain: &mut Tags,
        tag: T,
    ) {
        utils::assert_same_module_as_witness<T, Witness>();
        df::add(&mut domain.id, utils::marker<T>(), tag)
    }

    /// Removes tag from `TagDomain`
    public fun remove_tag<T: store + drop>(
        domain: &mut Tags,
    ) {
        utils::assert_same_module_as_witness<T, Witness>();
        let _: T = df::remove(&mut domain.id, utils::marker<T>());
    }
}

/// Module of NFT and Collection `Tags` domain
///
/// This domain allows wallets to organize the NFT display based on categories,
/// such as Art, Profile Picture, Collectibles, etc.
module nft_protocol::tags {
    // TODO: limit tags to three
    // Ability to add tags with vector<string>
    use std::string::String;
    use sui::dynamic_field as df;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::bag::{Self, Bag};

    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::utils::{
        assert_with_witness, assert_with_consumable_witness, UidType
    };
    use nft_protocol::consumable_witness::{Self as cw, ConsumableWitness};

    struct Tags has store {
        id: UID,
        tags: Bag
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Key struct used to store Tags in dynamic fields
    struct TagsKey has store, copy, drop {}

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


    // === Insert with ConsumableWitness ===


    /// Adds `Tags` as a dynamic field with key `TagsKey`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun add_empty<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        ctx: &mut TxContext,
    ) {
        assert_has_not_tags(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let tags = empty(ctx);

        cw::consume<T, Tags>(consumable, &mut tags);
        df::add(nft_uid, TagsKey {}, tags);
    }


    // === Insert with module specific Witness ===


    /// Adds `Tags` as a dynamic field with key `TagsKey`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun add_tags_<W: drop, T: key>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        name: String,
        ctx: &mut TxContext,
    ) {
        assert_has_not_tags(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let tags = empty(ctx);
        df::add(nft_uid, TagsKey {}, tags);
    }

    // === Get for call from external Module ===

    /// Creates empty `Tags`
    public fun empty(ctx: &mut TxContext): Tags {
        Tags { id: object::new(ctx), tags: bag::new(ctx) }
    }

    // === Field Borrow Functions ===


    /// Borrows immutably the `Tags` field.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `TagsKey` does not exist.
    public fun borrow_tags(
        nft_uid: &UID,
    ): &Tags {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_tags(nft_uid);
        df::borrow(nft_uid, TagsKey {})
    }

    /// Borrows Mutably the `Tags` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Tags`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `TagsKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun borrow_tags_mut<T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>
    ): &mut Tags {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_tags(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let tags = df::borrow_mut<TagsKey, Tags>(
            nft_uid,
            TagsKey {}
        );
        cw::consume<T, Tags>(consumable, tags);

        tags
    }

    /// Borrows Mutably the `Tags` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `TagsKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun borrow_tags_mut_<W: drop, T: key>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>
    ): &mut Tags {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_tags(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        df::borrow_mut(nft_uid, TagsKey {})
    }


    // === Writer Functions ===


    /// Inserts tag to `Tags` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun insert_tag<T: key, Tag: store + drop>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        tag: Tag,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_tags(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let tags = borrow_tags_mut(consumable, nft_uid, nft_type);

        bag::add(&mut tags.tags, utils::marker<Tag>(), tag);

        cw::consume<T, Tags>(consumable, tags);
    }


    /// Removes attribute to `Attributes` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Attributes`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun remove_tag<T: key, Tag: store + drop>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_tags(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let tags = borrow_tags_mut(consumable, nft_uid, nft_type);

        bag::remove<Marker<Tag>, Tag>(&mut tags.tags, utils::marker<Tag>());

        cw::consume<T, Tags>(consumable, tags);
    }

    /// Inserts attribute to `Attributes` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun insert_tag_<W: drop, T: key>(
        witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        attribute_key: String,
        attribute_value: String,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_attributes(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let attributes = borrow_attributes_mut_(witness, nft_uid, nft_type);

        vec_map::insert(
            &mut attributes.map,
            attribute_key,
            attribute_value,
        );
    }

    /// Removes attribute to `Attributes` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `AttributesKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun remove_tag_<W: drop, T: key>(
        witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
        attribute_key: &String,
    ) {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_attributes(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        let attributes = borrow_attributes_mut_(witness, nft_uid, nft_type);

        vec_map::remove(
            &mut attributes.map,
            attribute_key,
        );
    }

    // === Assertions & Helpers ===


    /// Checks that a given NFT has a dynamic field with `TagsKey`
    public fun has_tags(
        nft_uid: &UID,
    ): bool {
        df::exists_(nft_uid, TagsKey {})
    }

    public fun assert_has_tags(nft_uid: &UID) {
        assert!(has_tags(nft_uid), EUNDEFINED_DISPLAY_INFO_FIELD);
    }

    public fun assert_has_not_tags(nft_uid: &UID) {
        assert!(!has_tags(nft_uid), EDISPLAY_INFO_FIELD_ALREADY_EXISTS);
    }
}
