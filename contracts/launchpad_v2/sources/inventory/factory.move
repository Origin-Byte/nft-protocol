/// Module of `Factory` type
module launchpad_v2::factory {
    use std::vector;

    use sui::math;
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::bcs::{Self, BCS};
    use sui::table_vec::{Self, TableVec};
    use sui::transfer;
    use sui::tx_context;

    use nft_protocol::mint_pass::{Self, MintPass};
    use nft_protocol::mint_cap::{MintCap};
    use launchpad_v2::venue::{Self};
    use launchpad_v2::certificate::{Self, NftCertificate};

    /// `Warehouse` does not have NFT at specified index
    ///
    /// Call `Warehouse::redeem_nft_at_index` with an index that exists.
    const EINDEX_OUT_OF_BOUNDS: u64 = 3;

    struct Witness has drop {}

    /// `Factory` is an inventory that can mint loose NFTs
    ///
    /// Each `Factory` may only mint NFTs from a single collection.
    struct Factory<phantom T> has key, store {
        /// `Factory` ID
        id: UID,
        // TODO: To convert to table vec, need to add fetch_idx helper
        metadata: TableVec<vector<BCS>>,
        /// `LooseMintCap` responsible for generating `PointerDomain` and
        /// maintianing supply invariants on `Collection` and `Archetype`
        /// levels.
        total_deposited: u64,
        mint_cap: MintCap<T>,
    }

    /// Creates a new `Factory`
    ///
    /// `Factory` supply is limited by both the supply of the `Collection`
    /// and `Archetype` if either is regulated.
    ///
    /// #### Panics
    ///
    /// - Archetype `RegistryDomain` is not registered
    /// - `Archetype` does not exist
    public fun new<T>(
        mint_cap: MintCap<T>,
        ctx: &mut TxContext,
    ): Factory<T> {
        Factory {
            id: object::new(ctx),
            metadata: table_vec::empty(ctx),
            total_deposited: 0,
            mint_cap,
        }
    }

    /// Deposits NFT to `Warehouse`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    public entry fun deposit_metadata<T: key + store>(
        warehouse: &mut Factory<T>,
        metadata: vector<BCS>,
    ) {
        table_vec::push_back(&mut warehouse.metadata, metadata);
        warehouse.total_deposited = warehouse.total_deposited + 1;
    }

    /// Mints NFT from `Factory`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Factory`.
    ///
    /// #### Panics
    ///
    /// Panics if supply was exceeded.
    public fun redeem_nfts<T: key + store>(
        factory: &mut Factory<T>,
        certificate: &mut NftCertificate,
        ctx: &mut TxContext,
    ) {
        certificate::assert_cert_buyer(certificate, ctx);

        let factory_id = object::id(factory);

        let len = certificate::quantity(certificate);
        let remaining = certificate::quantity_mut(Witness {}, certificate);
        let inventories = certificate::invetories_mut_as_inventory(Witness {}, certificate);
        let nft = certificate::nft_mut_as_inventory(Witness {}, certificate);

        assert!(len > 0, 0);

        while (len > 0) {
            let inv_id = vector::borrow(inventories, len);

            if (*inv_id == factory_id) {
                vector::remove(inventories, len);


                let rel_index = vector::remove(nft, len);

                let index = math::divide_and_round_up(
                    factory.total_deposited * rel_index,
                    10_000
                );

                redeem_mint_pass_and_transfer<T>(factory, index, ctx);
            };

            len = len - 1;
        };
    }

    /// Mints NFT from `Factory`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Factory`.
    ///
    /// #### Panics
    ///
    /// Panics if supply was exceeded.
    public fun redeem_nft<T: key + store>(
        factory: &mut Factory<T>,
        certificate: &mut NftCertificate,
        ctx: &mut TxContext,
    ): MintPass<T> {
        certificate::assert_cert_buyer(certificate, ctx);

        let factory_id = object::id(factory);

        let len = certificate::quantity(certificate);
        let remaining = certificate::quantity_mut(Witness {}, certificate);
        let inventories = certificate::invetories_mut_as_inventory(Witness {}, certificate);
        let metadata_idxs = certificate::nft_mut_as_inventory(Witness {}, certificate);

        assert!(len > 0, 0);

        let mint_pass: MintPass<T>;

        while (len > 0) {
            let inv_id = vector::borrow(inventories, len);

            if (*inv_id == factory_id) {
                vector::remove(inventories, len);


                let rel_index = vector::remove(metadata_idxs, len);

                let index = math::divide_and_round_up(
                    factory.total_deposited * rel_index,
                    10_000
                );

                mint_pass = redeem_mint_pass<T>(factory, index, ctx);

                break
            };

            len = len - 1;
        };

        mint_pass
    }

    /// Redeems NFT from specific index in `Warehouse`
    ///
    /// Does not retain original order of NFTs in the bookkeeping vector.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    ///
    /// `Warehouse` may not change the logical owner of an `Nft` when
    /// redeeming as this would allow royalties to be trivially bypassed.
    ///
    /// #### Panics
    ///
    /// Panics if index does not exist in `Warehouse`.
    fun redeem_mint_pass_and_transfer<T: key + store>(
        factory: &mut Factory<T>,
        index: u64,
        ctx: &mut TxContext,
    ) {
        let metadatas = &mut factory.metadata;
        assert!(index < table_vec::length(&factory.metadata), EINDEX_OUT_OF_BOUNDS);

        let metadata = *table_vec::borrow(&factory.metadata, index);

        let mint_pass = mint_pass::new_with_metadata(
            &mut factory.mint_cap,
            1, // SUPPLY
            &bcs::to_bytes(&metadata),
            ctx,
        );

        transfer::public_transfer(mint_pass, tx_context::sender(ctx));
    }

    /// Redeems NFT from specific index in `Warehouse`
    ///
    /// Does not retain original order of NFTs in the bookkeeping vector.
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Warehouse`.
    ///
    /// `Warehouse` may not change the logical owner of an `Nft` when
    /// redeeming as this would allow royalties to be trivially bypassed.
    ///
    /// #### Panics
    ///
    /// Panics if index does not exist in `Warehouse`.
    fun redeem_mint_pass<T: key + store>(
        factory: &mut Factory<T>,
        index: u64,
        ctx: &mut TxContext,
    ): MintPass<T> {
        let metadatas = &mut factory.metadata;
        assert!(index < table_vec::length(&factory.metadata), EINDEX_OUT_OF_BOUNDS);

        let metadata = *table_vec::borrow(&factory.metadata, index);

        mint_pass::new_with_metadata(
            &mut factory.mint_cap,
            1, // SUPPLY
            &bcs::to_bytes(&metadata),
            ctx,
        )
    }
}
