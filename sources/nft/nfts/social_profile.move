//! Module of a NFT `SocialProfile` data type.
//!
//! It acts as a standard domain-specific implementation of an Social Profile.
module nft_protocol::social_profile {
    use std::string::{Self, String};
    use std::option;

    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use sui::event;

    use nft_protocol::collection::{Self, MintAuthority};
    use nft_protocol::soulbound::{Self, SoulBound};
    use nft_protocol::utils::{to_string_vector};
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::supply_policy;

    /// An NFT `SocialProfile` data object with standard fields.
    struct SocialProfile has key, store {
        id: UID,
        profile_picture: String,
        username: String,
        biography: String,
        media: Media,
    }

    struct Media has store, drop, copy {
        keys: vector<String>,
        values: vector<String>,
    }

    struct MintArgs has drop {
        username: String,
        profile_picture: String,
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
    public fun mint_nft<T>(
        username: vector<u8>,
        profile_picture: vector<u8>,
        biography: vector<u8>,
        media_keys: vector<vector<u8>>,
        media_values: vector<vector<u8>>,
        mint: &MintAuthority<T>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        // Assert that it has an unregulated supply policy
        assert!(
            !supply_policy::regulated(collection::supply_policy(mint)), 0
        );

        let media = Media {
            keys: to_string_vector(&mut media_keys),
            values: to_string_vector(&mut media_values),
        };

        let args = mint_args(
            username,
            profile_picture,
            biography,
            media,
        );

        mint_and_transfer<T>(
            args,
            recipient,
            ctx,
        );
    }

    // === Entrypoints ===

    /// Burns embedded `Nft` along with its `SocialProfile`. It invokes `burn_nft()`
    public entry fun burn_nft<T>(
        soulbound: SoulBound<Nft<T, SocialProfile>>,
    ) {
        burn_nft_(soulbound);
    }

    // === Getter Functions  ===

    /// Get the Nft SocialProfile's `id`
    public fun id(
        nft_data: &SocialProfile,
    ): ID {
        *object::uid_as_inner(&nft_data.id)
    }

    /// Get the Nft SocialProfile's `id` as reference
    public fun id_ref(
        nft_data: &SocialProfile,
    ): &ID {
        object::uid_as_inner(&nft_data.id)
    }

    /// Get the Nft SocialProfile's `profile_picture`
    public fun profile_picture(
        nft_data: &SocialProfile,
    ): &String {
        &nft_data.profile_picture
    }

    /// Get the Nft SocialProfile's `username`
    public fun username(
        nft_data: &SocialProfile,
    ): String {
        nft_data.username
    }

    /// Get the Nft SocialProfile's `biography`
    public fun biography(
        nft_data: &SocialProfile,
    ): String {
        nft_data.biography
    }

    /// Get the Nft SocialProfile's `media`
    public fun media(
        nft_data: &SocialProfile,
    ): &Media {
        &nft_data.media
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
            profile_picture: args.profile_picture,
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
        profile_picture: vector<u8>,
        biography: vector<u8>,
        media: Media,
    ): MintArgs {


        MintArgs {
            username: string::utf8(username),
            profile_picture: string::utf8(profile_picture),
            biography: string::utf8(biography),
            media: media,
        }
    }
}
