module nft_protocol::sale {
    use std::vector;

    use sui::object::{Self, ID , UID};
    use sui::tx_context::{TxContext};

    struct Sale<phantom T, Market> has key, store{
        id: UID,
        tier_index: u64,
        whitelist: bool,
        // Vector of all IDs owned by the slingshot
        nfts: vector<ID>,
        queue: vector<ID>,
        market: Market,
    }

    struct Whitelist has key {
        id: UID,
        sale_id: ID,
    }

    /// This object acts as an intermediate step between the payment
    /// and the transfer of the NFT. The user first has to call 
    /// `buy_nft_certificate` which mints and transfers the `NftCertificate` to
    /// the user. This object will dictate which NFT the userwill receive by
    /// calling the endpoint `claim_nft`
    struct NftCertificate has key, store {
        id: UID,
        nft_id: ID,
    }

    public fun create<T: drop, Market: store>(
        _witness: T,
        tier_index: u64,
        whitelist: bool,
        market: Market,
        ctx: &mut TxContext,
    ): Sale<T, Market> {
        let id = object::new(ctx);

        let nfts = vector::empty();
        let queue = vector::empty();

        Sale {
            id,
            tier_index,
            whitelist,
            nfts,
            queue,
            market,
        }
    }

    /// Burn the `Sale` and return the `Market` object
    public fun delete<T: drop, Market: store>(
        sale_box: Sale<T, Market>,
    ): Market {
        assert!(vector::length(&sale_box.nfts) == 0, 0);
        assert!(vector::length(&sale_box.queue) == 0, 0);

        let Sale {
            id,
            tier_index: _,
            whitelist: _,
            nfts: _,
            queue: _,
            market,
        } = sale_box;

        object::delete(id);

        market
    }

    // TODO: need to add a function with nft_id as function parameter
    public fun issue_nft_certificate<T, Market>(
        sale: &mut Sale<T, Market>,
        ctx: &mut TxContext,
    ): NftCertificate {
        let nft_id = pop_nft(sale);
        
        let certificate = NftCertificate {
            id: object::new(ctx),
            nft_id: nft_id,
        };

        certificate
    }

    public fun burn_certificate(
        certificate: NftCertificate,
    ) {
        let NftCertificate {
            id,
            nft_id: _,
        } = certificate;

        object::delete(id);
    }

    /// Adds an NFT's ID to the `nfts` field in `Sale` object
    public fun add_nft<T, Market>(
        sale: &mut Sale<T, Market>,
        id: ID,
    ) {
        let nfts = &mut sale.nfts;
        vector::push_back(nfts, id);
    }

    /// Pops an NFT's ID from the `nfts` field in `Sale` object
    /// and returns respective `ID`
    /// TODO: Need to push the ID to the queue
    fun pop_nft<T, Market>(
        sale: &mut Sale<T, Market>,
    ): ID {
        let nfts = &mut sale.nfts;
        vector::pop_back(nfts)
    }

    public fun market<T, M>(
        sale: &Sale<T, M>,
    ): &M {
        &sale.market
    }

    public fun market_mut<T, M>(
        sale: &mut Sale<T, M>,
    ): &mut M {
        &mut sale.market
    }

    public fun nft_id(
        certificate: &NftCertificate,
    ): ID {
        certificate.nft_id
    }

    public fun id<T, M>(
        sale: &Sale<T, M>,
    ): ID {
        object::uid_to_inner(&sale.id)
    }

    public fun id_ref<T, M>(
        sale: &Sale<T, M>,
    ): &ID {
        object::uid_as_inner(&sale.id)
    }
}