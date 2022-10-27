//! Module of a generic `Slingshot` type.
//!
//! It acts as a generic interface for Launchpads and it allows for
//! the creation of arbitrary domain specific implementations.
//!
//! The slingshot acts as the object that configures the primary NFT realease
//! strategy, that is the primary market sale. Primary market sales can take
//! many shapes, depending on the business level requirements.
module nft_protocol::slingshot {
    use std::vector;

    use sui::transfer;
    use sui::object::{Self, ID , UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft;
    use nft_protocol::err;
    use nft_protocol::sale::{Self, Sale, NftCertificate};

    struct Slingshot<phantom T, M> has key, store{
        id: UID,
        /// The ID of the Collection object
        collection_id: ID,
        /// Boolean indicating if the sale is live
        live: bool,
        /// The address of the administrator
        admin: address,
        /// The address of the receiver of funds
        receiver: address,
        /// Vector of all Sale outleds that, each outles holding IDs owned by the slingshot
        sales: vector<Sale<T, M>>,
        /// Field determining if NFTs are embedded or looose.
        /// Embedded NFTs will be directly owned by the Slingshot whilst
        /// loose NFTs will be minted on the fly under the authorithy of the
        /// launchpad.
        is_embedded: bool,
    }

    struct InitSlingshot has drop {
        admin: address,
        collection_id: ID,
        receiver: address,
        is_embedded: bool,
    }

    struct CreateSlingshotEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    struct DeleteSlingshotEvent has copy, drop {
        object_id: ID,
        collection_id: ID,
    }

    /// Initialises a `Slingshot` object and shares it
    public fun create<T: drop, M: store>(
        _witness: T,
        sales: vector<Sale<T, M>>,
        args: InitSlingshot,
        ctx: &mut TxContext,
    ) {
        let id = object::new(ctx);

        let slingshot: Slingshot<T, M> = Slingshot {
            id,
            collection_id: args.collection_id,
            live: false,
            admin: args.admin,
            receiver: args.receiver,
            sales: sales,
            is_embedded: args.is_embedded,
        };

        transfer::share_object(slingshot);
    }

    /// Burn the `Slingshot` and return the `M` object
    public fun delete<T: drop, M: store>(
        slingshot: Slingshot<T, M>,
        ctx: &mut TxContext,
    ): vector<Sale<T, M>> {
        assert!(
            tx_context::sender(ctx) == admin(&slingshot),
            err::wrong_launchpad_admin()
        );

        let Slingshot {
            id,
            collection_id: _,
            live: _,
            admin: _,
            receiver: _,
            sales,
            is_embedded: _,
        } = slingshot;

        object::delete(id);

        sales
    }

    public fun init_args(
        admin: address,
        collection_id: ID,
        receiver: address,
        is_embedded: bool,
    ): InitSlingshot {

        InitSlingshot {
            admin,
            collection_id,
            receiver,
            is_embedded
        }
    }

    // === Entrypoints ===

    /// Once the user has bought an NFT certificate, this method can be called
    /// to claim/redeem the NFT that has been allocated by the launchpad. The
    /// `NFTOwned` object in the function signature should correspond to the
    /// NFT ID mentioned in the certificate.
    ///
    /// We add the slingshot as a phantom parameter since it is the parent object
    /// of the NFT. Since the slingshot is a shared object anyone can mention it
    /// in the function signature and therefore be able to mention its child
    /// objects as well, the NFTs owned by it.
    public entry fun claim_nft_embedded<T, M: store, D: key + store>(
        slingshot: &Slingshot<T, M>,
        // TODO: nft_data is a shared object, we should confirm that we can
        // add it directly as a parameter since this transfers ownership to the
        // function's scope
        nft_data: D,
        certificate: NftCertificate,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        assert!(
            object::id(&nft_data) == sale::nft_id(&certificate),
            err::certificate_does_not_correspond_to_nft_given()
        );

        assert!(is_embedded(slingshot), err::nft_not_embedded());

        let nft = nft::mint_nft_loose<T, D>(
            object::id(&nft_data),
            recipient,
            sale::collection_id(&certificate),
            ctx,
        );

        sale::burn_certificate(certificate);

        nft::join_nft_data(&mut nft, nft_data);

        transfer::transfer(
            nft,
            recipient,
        );
    }

    /// Once the user has bought an NFT certificate, this method can be called
    /// to claim/redeem the NFT that has been allocated by the launchpad. The
    /// `NFTOwned` object in the function signature should correspond to the
    /// NFT ID mentioned in the certificate.
    ///
    /// We add the slingshot as a phantom parameter since it is the parent object
    /// of the NFT. Since the slingshot is a shared object anyone can mention it
    /// in the function signature and therefore be able to mention its child
    /// objects as well, the NFTs owned by it.
    public entry fun claim_nft_loose<T, M: store, D: key + store>(
        slingshot: &Slingshot<T, M>,
        nft_data: &D,
        certificate: NftCertificate,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        assert!(
            object::id(nft_data) == sale::nft_id(&certificate),
            err::certificate_does_not_correspond_to_nft_given()
        );

        assert!(!is_embedded(slingshot), err::nft_not_loose());

        // We are currently not increasing the current supply of the NFT
        // being minted (both collectibles and cNFT implementation have a concept
        // of supply).
        let nft = nft::mint_nft_loose<T, D>(
            object::id(nft_data),
            recipient,
            sale::collection_id(&certificate),
            ctx,
        );

        sale::burn_certificate(certificate);

        transfer::transfer(
            nft,
            recipient,
        );
    }

    // === Modifier Functions ===

    /// Toggle the Slingshot's `live` to `true` therefore
    /// making the NFT sale live.
    public fun sale_on<T, M>(
        slingshot: &mut Slingshot<T, M>,
    ) {
        slingshot.live = true
    }

    /// Toggle the Slingshot's `live` to `false` therefore
    /// pausing or stopping the NFT sale.
    public fun sale_off<T, M>(
        slingshot: &mut Slingshot<T, M>,
    ) {
        slingshot.live = false
    }

    /// Adds a sale outlet `Sale` to `sales` field
    public fun add_sale_outlet<T, M>(
        slingshot: &mut Slingshot<T, M>,
        sale: Sale<T, M>
    ) {
        vector::push_back(&mut slingshot.sales, sale);
    }

    // === Getter Functions ===

    /// Get the Slingshot `id`
    public fun id<T, M>(
        slingshot: &Slingshot<T, M>,
    ): ID {
        object::uid_to_inner(&slingshot.id)
    }

    /// Get the Slingshot `id` as reference
    public fun id_ref<T, M>(
        slingshot: &Slingshot<T, M>,
    ): &ID {
        object::uid_as_inner(&slingshot.id)
    }

    /// Get the Slingshot's `collection_id`
    public fun collection_id<T, M>(
        slingshot: &Slingshot<T, M>,
    ): ID {
        slingshot.collection_id
    }

    /// Get the Slingshot's `live`
    public fun live<T, M>(
        slingshot: &Slingshot<T, M>,
    ): bool {
        slingshot.live
    }

    /// Get the Slingshot's `receiver` address
    public fun receiver<T, M>(
        slingshot: &Slingshot<T, M>,
    ): address {
        slingshot.receiver
    }

    /// Get the Slingshot's `admin` address
    public fun admin<T, M>(
        slingshot: &Slingshot<T, M>,
    ): address {
        slingshot.admin
    }

    /// Get the Slingshot's `sales` address
    public fun sales<T, M>(
        slingshot: &Slingshot<T, M>,
    ): &vector<Sale<T, M>> {
        &slingshot.sales
    }

    /// Get the Slingshot's `sale` address
    public fun sale<T, M>(
        slingshot: &Slingshot<T, M>,
        index: u64,
    ): &Sale<T, M> {
        vector::borrow(&slingshot.sales, index)
    }

    /// Get the Slingshot's `sale` address
    public fun sale_mut<T, M>(
        slingshot: &mut Slingshot<T, M>,
        index: u64,
    ): &mut Sale<T, M> {
        vector::borrow_mut(&mut slingshot.sales, index)
    }

    /// Get the Slingshot's `is_embedded` bool
    public fun is_embedded<T, M>(
        slingshot: &Slingshot<T, M>,
    ): bool {
        slingshot.is_embedded
    }
}
