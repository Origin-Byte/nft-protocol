/// Module defining the OriginByte `NFT` type
///
/// OriginByte's NFT protocol brings dynamism, composability and extendability
/// to NFTs. The current design allows creators to create NFTs with custom
/// domain-specific fields, with their own bespoke behavior.
///
/// OriginByte provides a set of standard domains which implement common NFT
/// use-cases such as `DisplayDomain` which allows wallets and marketplaces to
/// easily display your NFT.
module nft_protocol::nft {
    use std::ascii;
    use std::string;
    use std::type_name;

    use sui::url::Url;
    use sui::event;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::witness::{Self, Witness as DelegatedWitness};
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::mint_cap::{Self, MintCap};

    /// Domain not defined
    ///
    /// Call `collection::add_domain` to add domains
    const EUndefinedDomain: u64 = 1;

    /// Domain already defined
    ///
    /// Call `collection::borrow` to borrow domain
    const EExistingDomain: u64 = 2;

    /// Witness used to authorize collection creation
    struct Witness has drop {}

    /// `Nft` object
    ///
    /// OriginByte collections and NFTs have a generic parameter `C` which is a
    /// one-time witness created by the creator's NFT collection module. This
    /// allows `Collection` and `Nft` to be linked via type association, but
    /// also ensures that NFTs can only be minted by the contract that
    /// initially deployed them.
    ///
    /// An `Nft` exclusively owns domains of different types, which can be
    /// dynamically acquired and lost over its lifetime. OriginByte NFTs are
    /// modelled after [Entity Component Systems](https://en.wikipedia.org/wiki/Entity_component_system),
    /// where their domains are accessible by type. See
    /// [borrow_domain_mut](#borrow_domain_mut).
    struct Nft<phantom C> has key, store {
        /// `Nft` ID
        id: UID,
        /// `Nft` name
        name: string::String,
        /// `Nft` URL
        url: Url,
    }

    /// Event signalling that an `Nft` was minted
    struct MintNftEvent has copy, drop {
        /// ID of the `Nft` that was minted
        nft_id: ID,
        /// Type name of `Nft<C>` one-time witness `C`
        ///
        /// Intended to allow users to filter by collections of interest.
        nft_type: ascii::String,
    }

    /// Create a new `Nft`
    fun new_<C>(
        name: string::String,
        url: Url,
        ctx: &mut TxContext,
    ): Nft<C> {
        let id = object::new(ctx);

        event::emit(MintNftEvent {
            nft_id: object::uid_to_inner(&id),
            nft_type: type_name::into_string(type_name::get<C>()),
        });

        Nft { id, name, url }
    }

    /// Create a new `Nft` using `MintCap`
    ///
    /// Requires witness of collection contract as this function should only
    /// be used by functions defined within that contract due to the potential
    /// to violate correctness guarantees in other parts of the codebase.
    ///
    /// `mint_cap::increment_supply` should be called when instantiating a new
    /// `Nft` using this method if you are tracking supply using `MintCap`.
    public fun new<C, W: drop>(
        _witness: W,
        name: string::String,
        url: Url,
        ctx: &mut TxContext,
    ): Nft<C> {
        utils::assert_same_module_as_witness<C, W>();
        new_(name, url, ctx)
    }

    /// Create a new `Nft` using `MintCap`
    public fun from_mint_cap<C>(
        mint_cap: &mut MintCap<Nft<C>>,
        name: string::String,
        url: Url,
        ctx: &mut TxContext,
    ): Nft<C> {
        mint_cap::increment_supply(mint_cap, 1);
        new_(name, url, ctx)
    }

    // === Domain Functions ===

    /// Delegates a witness for wrapped NFTs
    ///
    /// #### Panics
    ///
    /// Panics if witness `W` does not originate from the same module as `C`.
    public fun delegate_witness<C, W: drop>(
        _witness: W,
    ): DelegatedWitness<Nft<C>> {
        utils::assert_same_module_as_witness<C, W>();
        witness::from_witness<Nft<C>, Witness>(Witness {})
    }

    /// Delegates `&UID` for domain specified extensions of `Nft`
    public fun borrow_uid<C>(nft: &Nft<C>): &UID {
        &nft.id
    }

    /// Delegates `&mut UID` for domain specified extensions of `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if witness `W` does not originate from the same module as `C`.
    public fun borrow_uid_mut<C, W: drop>(
        witness: W,
        nft: &mut Nft<C>,
    ): &mut UID {
        borrow_uid_delegated_mut(delegate_witness(witness), nft)
    }

    /// Delegates `&mut UID` for domain specified extensions of `Nft`
    public fun borrow_uid_delegated_mut<C>(
        _witness: DelegatedWitness<Nft<C>>,
        nft: &mut Nft<C>,
    ): &mut UID {
        &mut nft.id
    }

    /// Check whether `Nft` has a domain
    public fun has_domain<C, Domain: store>(nft: &Nft<C>): bool {
        df::exists_with_type<Marker<Domain>, Domain>(
            &nft.id, utils::marker<Domain>(),
        )
    }

    /// Borrow domain from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain is not present on the `Nft`
    public fun borrow_domain<C, Domain: store>(nft: &Nft<C>): &Domain {
        assert_domain<C, Domain>(nft);
        df::borrow(&nft.id, utils::marker<Domain>())
    }

    /// Mutably borrow domain from `Nft`
    ///
    /// Guarantees that `Nft<C>` domains can only be mutated by the module that
    /// instantiated it.
    ///
    /// #### Panics
    ///
    /// Panics if domain does not exist or if witness `W` does not originate
    /// from the same module as `C`.
    public fun borrow_domain_mut<C, W: drop, Domain: store>(
        witness: W,
        nft: &mut Nft<C>,
    ): &mut Domain {
        borrow_domain_delegated_mut(
            delegate_witness(witness),
            nft,
        )
    }

    /// Mutably borrow domain from `Nft`
    ///
    /// Guarantees that `Nft<C>` domains can only be mutated by the module that
    /// instantiated it.
    ///
    /// #### Panics
    ///
    /// Panics if domain does not exist or if witness `W` does not originate
    /// from the same module as `C`.
    public fun borrow_domain_delegated_mut<C, Domain: store>(
        witness: DelegatedWitness<Nft<C>>,
        nft: &mut Nft<C>,
    ): &mut Domain {
        assert_domain<C, Domain>(nft);
        df::borrow_mut(
            borrow_uid_delegated_mut(witness, nft),
            utils::marker<Domain>(),
        )
    }

    /// Adds domain to `Nft`
    ///
    /// Helper method that can be simply used without knowing what a delegated
    /// witness is.
    ///
    /// #### Panics
    ///
    /// Panics if domain already exists or if witness `W` does not originate
    /// from the same module as `C`.
    public fun add_domain<C, Domain: store, W: drop>(
        witness: W,
        nft: &mut Nft<C>,
        domain: Domain,
    ) {
        add_domain_delegated(
            delegate_witness(witness),
            nft,
            domain,
        )
    }

    /// Adds domain to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain already exists or if witness `W` does not originate
    /// from the same module as `C`.
    public fun add_domain_delegated<C, Domain: store>(
        witness: DelegatedWitness<Nft<C>>,
        nft: &mut Nft<C>,
        domain: Domain,
    ) {
        assert_no_domain<C, Domain>(nft);
        df::add(
            borrow_uid_delegated_mut(witness, nft),
            utils::marker<Domain>(),
            domain,
        );
    }

    /// Removes domain of type from `Nft`
    ///
    /// ##### Panics
    ///
    /// Panics if domain doesnt exist or if witness `W` does not originate from
    /// the same module as `C`.
    public fun remove_domain<C, W: drop, Domain: store>(
        witness: W,
        nft: &mut Nft<C>,
    ): Domain {
        assert_domain<C, Domain>(nft);
        remove_domain_delegated(delegate_witness(witness), nft)
    }

    /// Removes domain of type from `Nft`
    ///
    /// ##### Panics
    ///
    /// Panics if domain doesnt exist.
    public fun remove_domain_delegated<C, Domain: store>(
        witness: DelegatedWitness<Nft<C>>,
        nft: &mut Nft<C>,
    ): Domain {
        assert_domain<C, Domain>(nft);
        df::remove(
            borrow_uid_delegated_mut(witness, nft),
            utils::marker<Domain>(),
        )
    }

    /// Deletes an `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if any domains are still registered on the `Nft`.
    public entry fun delete<C>(nft: Nft<C>) {
        let Nft { id, name: _, url: _ } = nft;
        object::delete(id);
    }

    // === Static Properties ===

    /// Returns `Nft` name
    public fun name<C>(nft: &Nft<C>): &string::String {
        &nft.name
    }

    /// Returns `Nft` URL
    public fun url<C>(nft: &Nft<C>): &Url {
        &nft.url
    }

    /// Sets `Nft` static name
    ///
    /// Caution when changing properties of loose NFTs as the changes will
    /// not be propagated to the template.
    public fun set_name<C>(
        _witness: DelegatedWitness<Nft<C>>,
        nft: &mut Nft<C>,
        name: string::String,
    ) {
        nft.name = name
    }

    /// Sets `Nft` static URL
    ///
    /// Caution when changing properties of loose NFTs as the changes will
    /// not be propagated to the template.
    public fun set_url<C>(
        _witness: DelegatedWitness<Nft<C>>,
        nft: &mut Nft<C>,
        url: Url,
    ) {
        nft.url = url
    }

    // === `Collection<Nft<C>>` functions ===

    /// Creates a `Collection<Nft<C>>` and corresponding `MintCap<Nft<C>>`
    public fun create_collection<C, W: drop>(
        _witness: W,
        ctx: &mut TxContext,
    ): Collection<Nft<C>> {
        utils::assert_same_module_as_witness<C, W>();
        collection::create<Nft<C>, Witness>(Witness {}, ctx)
    }

    /// Delegates `&mut UID` of `Collection<Nft<C>>`
    ///
    /// #### Panics
    ///
    /// Panics if witness `W` does not originate from the same module as `C`.
    public fun borrow_collection_uid_mut<C, W: drop>(
        witness: W,
        collection: &mut Collection<Nft<C>>,
    ): &mut UID {
        collection::borrow_uid_delegated_mut(
            delegate_witness(witness),
            collection,
        )
    }

    /// Mutably borrow domain from `Collection<Nft<C>>`
    ///
    /// #### Panics
    ///
    /// Panics if domain does not exist or if witness `W` does not originate
    /// from the same module as `C`.
    public fun borrow_collection_domain_mut<C, Domain: store, W: drop>(
        witness: W,
        collection: &mut Collection<Nft<C>>,
    ): &mut Domain {
        collection::borrow_domain_delegated_mut(
            delegate_witness(witness),
            collection,
        )
    }

    /// Adds domain to `Collection<Nft<C>>`
    ///
    /// Helper method that can be simply used without knowing what a delegated
    /// witness is.
    ///
    /// #### Panics
    ///
    /// Panics if domain already exists or if witness `W` does not originate
    /// from the same module as `C`.
    public fun add_collection_domain<C, Domain: store, W: drop>(
        witness: W,
        collection: &mut Collection<Nft<C>>,
        domain: Domain,
    ) {
        collection::add_domain_delegated(
            delegate_witness(witness),
            collection,
            domain,
        )
    }

    /// Removes domain of type from `Collection<Nft<C>>`
    ///
    /// ##### Panics
    ///
    /// Panics if domain doesnt exist or if witness `W` does not originate from
    /// the same module as `C`.
    public fun remove_collection_domain<C, Domain: store, W: drop>(
        witness: W,
        collection: &mut Collection<Nft<C>>,
    ): Domain {
        collection::remove_domain_delegated(
            delegate_witness(witness),
            collection,
        )
    }

    // === Assertions ===

    /// Assert that domain exists on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain does not exist on `Nft`.
    public fun assert_domain<C, Domain: store>(nft: &Nft<C>) {
        assert!(has_domain<C, Domain>(nft), EUndefinedDomain);
    }

    /// Assert that domain does not exist on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain exists on `Nft`.
    public fun assert_no_domain<C, Domain: store>(nft: &Nft<C>) {
        assert!(!has_domain<C, Domain>(nft), EExistingDomain);
    }

    // === Test helpers ===

    #[test_only]
    /// Create `Nft` without access to `MintCap` or derivatives
    public fun test_mint<C>(ctx: &mut TxContext): Nft<C> {
        new_(std::string::utf8(b""), sui::url::new_unsafe_from_bytes(b""), ctx)
    }
}
