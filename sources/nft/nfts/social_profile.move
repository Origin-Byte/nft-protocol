//! Module of a unique NFT `Unique` data type.
//! 
//! It acts as a standard domain-specific implementation of an NFT type, 
//! fitting use cases such as Art and PFP NFT Collections. It uses the main
//! NFT module to mint embedded NFTs.
module nft_protocol::social_profile {
    use sui::event;
    use sui::object::{Self, UID, ID};
    use std::string::{Self, String};
    use std::option::{Self, Option};
    
    use sui::tx_context::{TxContext};
    
    use nft_protocol::collection::{Self, MintAuthority};
    use nft_protocol::supply_policy;
    use nft_protocol::soulbound::{Self, SoulBound};
    use nft_protocol::nft::{Self, Nft};

    /// An NFT `Unique` data object with standard fields.
    struct SocialProfile has key, store {
        id: UID,
        // TODO: Should be string to be parsed by client
        profile_picture: Option<ID>,
        username: String,
        biography: String,
        media: Media,
    }

    struct Media has store, drop, copy {
        // TODO: Allow for arbitrary new fields
        twitter: String,
        discord: String,
        telegram: String,
    }

    struct MintArgs has drop {
        username: String,
        biography: String,
        media: Media,
    }

    struct MintDataEvent has copy, drop {
        object_id: ID,
    }

    struct BurnDataEvent has copy, drop {
        object_id: ID,
    }

    // === Functions exposed to Witness Module ===

    /// Mint one embedded `Nft` with `SocialProfile` data, wrapped in
    /// a SoulBound, non-tranferrable object, and send it to `recipient`.
    /// Invokes `mint_and_transfer()`.
    /// Mints an NFT from a `Collection` with `Unlimited` supply.
    /// The only way to mint the NFT for a collection is to give a reference to
    /// [`UID`]. One is only allowed to mint `Nft`s for a given collection
    /// if one is the collection owner, or if it is a shared collection.
    /// 
    /// To be called by the Witness Module deployed by NFT creator.
    public fun mint_nft<T, M: store>(
        username: vector<u8>,
        biography: vector<u8>,
        twitter: vector<u8>,
        discord: vector<u8>,
        telegram: vector<u8>,
        mint: &MintAuthority<T>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        // Unlimited collections have a blind supply policy
        assert!(
            supply_policy::is_blind(collection::supply_policy(mint)), 0
        );

        let args = mint_args(
            username,
            biography,
            twitter,
            discord,
            telegram,
        );

        mint_and_transfer<T>(
            args,
            recipient,
            ctx,
        );
    }

    // === Entrypoints ===

    /// Burns embedded `Nft` along with its `Unique`. It invokes `burn_nft()`
    public entry fun burn_nft<T>(
        soulbound: SoulBound<Nft<T, SocialProfile>>,
    ) {
        burn_nft_(soulbound);
    }

    // === Getter Functions  ===

    /// Get the Nft Unique's `id`
    public fun id(
        nft_data: &SocialProfile,
    ): ID {
        *object::uid_as_inner(&nft_data.id)
    }

    /// Get the Nft Unique's `id` as reference
    public fun id_ref(
        nft_data: &SocialProfile,
    ): &ID {
        object::uid_as_inner(&nft_data.id)
    }

    /// Get the Nft Unique's `profile_picture`
    public fun profile_picture(
        nft_data: &SocialProfile,
    ): Option<ID> {
        nft_data.profile_picture
    }

    /// Get the Nft Unique's `username`
    public fun username(
        nft_data: &SocialProfile,
    ): String {
        nft_data.username
    }

    /// Get the Nft Unique's `biography`
    public fun biography(
        nft_data: &SocialProfile,
    ): String {
        nft_data.biography
    }

    /// Get the Nft Unique's `twitter`
    public fun twitter(
        nft_data: &SocialProfile,
    ): String {
        nft_data.media.twitter
    }

    /// Get the Nft Unique's `biography`
    public fun telegram(
        nft_data: &SocialProfile,
    ): String {
        nft_data.media.telegram
    }

    /// Get the Nft Unique's `biography`
    public fun discord(
        nft_data: &SocialProfile,
    ): String {
        nft_data.media.discord
    }

    // === Private Functions ===

    fun nft_data_id(nft_data: &SocialProfile): ID {
        object::uid_to_inner(&nft_data.id)
    }

    fun mint_and_transfer<T>(
        args: MintArgs,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let data_id = object::new(ctx);

        event::emit(
            MintDataEvent {
                object_id: object::uid_to_inner(&data_id),
            }
        );

        let nft_data = SocialProfile {
            id: data_id,            
            profile_picture: option::none(),
            username: args.username,
            biography: args.biography,
            media: args.media,
        };

        let nft = nft::mint_nft_embedded<T, SocialProfile>(
            nft_data_id(&nft_data),
            nft_data,
            ctx
        );

        soulbound::lock_nft(
            nft,
            recipient,
            ctx,
        );
    }

    fun burn_nft_<T>(
        soulbound: SoulBound<Nft<T, SocialProfile>>,
    ) {
        let nft = soulbound::unlock_nft(soulbound);
        let data_option = nft::burn_embedded_nft(nft);

        let data = option::extract(&mut data_option);
        option::destroy_none(data_option);

        event::emit(
            BurnDataEvent {
                object_id: id(&data),
            }
        );

        let SocialProfile {
            id,
            profile_picture: _,
            username: _,
            biography: _,
            media: _,
        } = data;

        object::delete(id);
    }

    fun mint_args(
        username: vector<u8>,
        biography: vector<u8>,
        twitter: vector<u8>,
        discord: vector<u8>,
        telegram: vector<u8>,
    ): MintArgs {
        let media = Media {
            twitter: string::utf8(twitter),
            discord: string::utf8(discord),
            telegram: string::utf8(telegram),
        };

        MintArgs {
            username: string::utf8(username),
            biography: string::utf8(biography),
            media: media,
        }
    }
}