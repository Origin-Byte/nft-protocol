/// Module of NFT `ModifyDomain`
///
/// `ModifyDomain` allows collection creators to delegate users
/// the right to independently register new domains on their NFTs without
/// delegating the right to mint or modify the collection.
///
/// An alternative is delegating a `RegulatedMintCap` with zero supply
/// which will allow users or contracts to register domains on
module nft_protocol::modify {
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::witness::{
        Self, WitnessGenerator,
    };

    /// `ModifyDomain` was not defined on `Collection`
    ///
    /// Call `modify::add_modify_domain` to add `ModifyDomain`.
    const EUNDEFINED_MODIFY_DOMAIN: u64 = 1;

    /// Transaction sender was not the logical owner of the NFT
    const EINVALID_LOGICAL_OWNER: u64 = 2;

    /// `ModifyDomain` object
    struct ModifyDomain<phantom C> has store {
        /// Generator responsible for issuing delegated witnesses
        generator: WitnessGenerator<C>,
    }

    /// Creates a new `ModifyDomain`
    fun new<C, W>(witness: &W): ModifyDomain<C> {
        ModifyDomain { generator: witness::generator(witness) }
    }

    /// Adds domain of type `D` to `Nft`
    ///
    /// Allows users to independently register
    ///
    /// #### Panics
    ///
    /// - Transaction sender is not logical owner of the NFT
    /// - `ModifyDomain` was not registered on `Collection`
    /// - Domain `D` already exists on the `Nft`
    public fun add_domain<C, D: store>(
        collection: &Collection<C>,
        nft: &mut Nft<C>,
        domain: D,
        ctx: &mut TxContext,
    ) {
        assert_owner(nft, ctx);
        let modify_domain = borrow_modify_domain(collection);

        nft::add_domain(
            witness::delegate(&modify_domain.generator),
            nft,
            domain,
        )
    }

    /// Adds `ModifyDomain` to `Collection`
    ///
    /// This allows users to independently add domains to their NFTs.
    ///
    /// #### Panics
    ///
    /// Panics if `ModifyDomain` already exists.
    public fun add_modify_domain<C, W>(
        witness: &W,
        collection: &mut Collection<C>,
    ) {
        let domain = new<C, W>(witness);
        collection::add_domain(
            witness::from_witness(witness),
            collection,
            domain,
        );
    }

    /// Borrows `ModifyDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `ModifyDomain` is not registered on `Collection`.
    fun borrow_modify_domain<C>(collection: &Collection<C>): &ModifyDomain<C> {
        assert_domain(collection);
        collection::borrow_domain(collection)
    }

    // === Assertions ===

    /// Asserts that transaction sender is the logical owner of the NFT
    ///
    /// #### Panics
    ///
    /// Panics if transaction sender is not the logical owner of the NFT.
    public fun assert_owner<C>(nft: &Nft<C>,  ctx: &mut TxContext) {
        assert!(
            tx_context::sender(ctx) == nft::logical_owner(nft),
            EINVALID_LOGICAL_OWNER,
        )
    }

    /// Asserts that `ModifyDomain` is defined on the `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `ModifyDomain` is not defined on the `Collection`.
    public fun assert_domain<C>(collection: &Collection<C>) {
        assert!(
            collection::has_domain<C, ModifyDomain<C>>(collection),
            EUNDEFINED_MODIFY_DOMAIN,
        )
    }
}
