/// Module of a standard NFT `NftMeta` type.
/// 
/// It acts as a standard domain-specific implementation of an NFT. It adds
/// to the NFT metadata fields such as `name`, `uri` and `attributes`.
module nft_protocol::std_nft {
    use sui::event;
    use sui::transfer;
    use sui::url::{Self, Url};
    use sui::coin::{Self, Coin};
    use sui::sui::{Self, SUI};
    use std::string::{Self, String};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{TxContext};
    use nft_protocol::nft::{Self, NftOwned};
    use nft_protocol::utils::{to_string_vector};
    use nft_protocol::slingshot::{Self, Slingshot};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::std_collection::{StdCollection, CollectionMeta};

    struct StdNft has drop {}

    struct NftMeta has key, store {
        id: UID,
        name: String,
        index: u64,
        uri: Url,
        attributes: Attributes
    }

    struct Attributes has store, drop, copy {
        // TODO: Consider using key-value pair
        keys: vector<String>,
        values: vector<String>,
    }

    struct MintNFT has drop {
        name: String,
        index: u64,
        uri: Url,
        primary_sales_happened: bool,
        is_mutable: bool,
        attributes: Attributes,
    }

    struct MintEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    struct BurnEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    // === Entrypoints ===

    /// Mint one `Nft` with `Metadata` and send it to `recipient`.
    /// Invokes `mint()`.
    /// The only way to mint the NFT for a collection is to give a reference to
    /// [`UID`]. Since this a property, it can be only accessed in the smart 
    /// contract which creates the collection. That contract can then define
    /// their own logic for restriction on minting.
    public entry fun mint_and_transfer(
        // Name of the NFT. This parameter is a vector of bytes that
        // enconde to utf8 and will be stored in the NFT object as a String
        name: vector<u8>,
        // Uri of the NFT. This parameter is a vector of bytes that
        // encondes to utf8 and will be stored in the NFT object as a Url
        uri: vector<u8>,
        is_mutable: bool,
        // A vector of attribute keys, expressed in a vector of bytes that
        // encode to utf8. The attribute keys are stored as a String in the
        // NFT object as part of the `Attributes` struct in the attributes field
        attribute_keys: vector<vector<u8>>,
        // A vector of attribute values, expressed in a vector of bytes that
        // encode to utf8. The attribute values are stored as a String in the
        // NFT object as part of the `Attributes` struct in the
        // `attributes` field
        attribute_values: vector<vector<u8>>,
        // The Collection object that represents the nft collection of the NFT 
        // being minted. As it stands, the NFT can only be minted by the 
        // collection owner if the collection is owned, or be minted by anyone
        // if the collection is shared
        coll: &mut Collection<StdCollection, CollectionMeta>,
        wallet: &mut Coin<SUI>,
        // The recipient of the NFT
        recipient: address,
        ctx: &mut TxContext
    ) {
        let current_supply = collection::current_supply(coll);
        let max_supply = collection::total_supply(coll);

        assert!(current_supply < max_supply, 0);

        let args = mint_args(
            string::utf8(name),
            current_supply + 1,
            url::new_unsafe_from_bytes(uri),
            false,
            is_mutable,
            attribute_keys,
            attribute_values,
        );

        assert!(coin::value(wallet) > collection::initial_price(coll), 0);

        // Split coin into price and change, then transfer 
        // the price and keep the change
        coin::split_and_transfer<SUI>(
            wallet,
            collection::initial_price(coll),
            collection::receiver(coll),
            ctx
        );

        transfer::transfer(
            mint(
                args,
                coll,
                ctx,
            ),
            recipient,
        );
    }

    /// Mint one `Nft` with `Metadata` and send it to `LaunchpadConfig` object.
    /// Invokes `mint()`.
    public entry fun mint_to_launchpad<T, Config: store>(
        // Name of the NFT. This parameter is a vector of bytes that
        // enconde to utf8 and will be stored in the NFT object as a String
        name: vector<u8>,
        // Uri of the NFT. This parameter is a vector of bytes that
        // encondes to utf8 and will be stored in the Nft object as a Url
        uri: vector<u8>,
        is_mutable: bool,
        // A vector of attribute keys, expressed in a vector of bytes that
        // encode to utf8. The attribute keys are stored as a String in the
        // Nft object as part of the `Attributes` struct in the attributes field
        attribute_keys: vector<vector<u8>>,
        // A vector of attribute values, expressed in a vector of bytes that
        // encode to utf8. The attribute values are stored as a String in the
        // Nft object as part of the `Attributes` struct in the
        // `attributes` field
        attribute_values: vector<vector<u8>>,
        // The Collection object that represents the nft collection of the Nft 
        // being minted. As it stands, the NFT can only be minted by the 
        // collection owner if the collection is owned, or be minted by anyone
        // if the collection is shared
        collection: &mut Collection<StdCollection, CollectionMeta>,
        coin: Coin<SUI>,
        // The rNftecipient of the 
        launchpad: &mut Slingshot<T, Config>,
        ctx: &mut TxContext
    ) {
        // TODO: reduce code duplication between `mint_and_transfer` and 
        // `mint_to_launchpad`
        let current_supply = collection::current_supply(collection);
        let max_supply = collection::total_supply(collection);

        assert!(current_supply < max_supply, 0);

        let args = mint_args(
            string::utf8(name),
            current_supply + 1,
            url::new_unsafe_from_bytes(uri),
            false,
            is_mutable,
            attribute_keys,
            attribute_values,
        );

        assert!(coin::value(&coin) > collection::initial_price(collection), 0);

        // Split coin into price and change, then transfer 
        // the price and keep the change
        let balance = coin::into_balance(coin);

        let price = coin::take(
            &mut balance,
            collection::initial_price(collection),
            ctx,
        );

        let change = coin::from_balance(balance, ctx);
        coin::keep(change, ctx);

        // Transfer Sui to pay for the mint
        sui::transfer(
            price,
            collection::receiver(collection),
        );

        let nft = mint(
            args,
            collection,
            ctx,
        );

        event::emit(
            MintEvent {
                object_id: object::id(&nft),
                collection_id: object::id(collection),
            }
        );

        let id = nft::id(&nft);

        slingshot::add_nft<T, Config>(launchpad, id);

        transfer::transfer_to_object(
            nft,
            launchpad,
        );
    }

    /// Burn an NFT and reduce the total_supply. Invokes `burn()`.
    public entry fun burn<T: drop, Meta: store>(
        nft: NftOwned<StdNft, NftMeta>,
        coll: &mut Collection<T, Meta>
        ) {
        event::emit(
            BurnEvent {
                object_id: nft::id(&nft),
                collection_id: nft::collection_id(&nft),
            }
        );
        
        // Delete generic Nft object
        let metadata = nft::destroy_owned(
            StdNft {},
            nft,
            coll,
        );

        let NftMeta {
            id,
            name: _,
            index: _,
            uri: _,
            attributes: _,
        } = metadata;

        // Delete nft metadata
        object::delete(id);
    }

    // === Getter Functions ===

    /// Get the Nft Meta's `name`
    public fun name(
        meta: &NftMeta,
    ): String {
        meta.name
    }

    /// Get the Nft Meta's `index`
    public fun index(
        meta: &NftMeta,
    ): u64 {
        meta.index
    }

    /// Get the Nft Meta's `uri`
    public fun uri(
        meta: &NftMeta,
    ): Url {
        meta.uri
    }

    /// Get the Nft Meta's `attributes`
    public fun attributes(
        meta: &NftMeta,
    ): &Attributes {
        &meta.attributes
    }

    // === Private Functions ===

    fun mint_args(
        name: String,
        index: u64,
        uri: Url,
        primary_sales_happened: bool,
        is_mutable: bool,
        attribute_keys: vector<vector<u8>>,
        attribute_values: vector<vector<u8>>,
    ): MintNFT {
        let attributes = Attributes {
            keys: to_string_vector(&mut attribute_keys),
            values: to_string_vector(&mut attribute_values),
        };

        MintNFT {
            name,
            index,
            uri,
            primary_sales_happened,
            is_mutable,
            attributes,
        }
    }

    /// Mints an `NftOwned` object and returns it.
    fun mint(
        args: MintNFT,
        coll: &mut Collection<StdCollection, CollectionMeta>,
        ctx: &mut TxContext,
    ): NftOwned<StdNft, NftMeta> {
        let metadata = NftMeta {
            id: object::new(ctx),
            name: args.name,
            index: args.index,
            uri: args.uri,
            attributes: args.attributes,
        };

        let nft = nft::create_owned(
            StdNft {},
            metadata,
            coll,
            ctx
        );

        nft
    }
}