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
    struct Nft<phantom T> has key, store {
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
        /// Type name of `Nft<T>`
        ///
        /// Intended to allow users to filter by collections of interest.
        nft_type: ascii::String,
    }

    /// Create a new `Nft`
    fun new_<T>(
        name: string::String,
        url: Url,
        ctx: &mut TxContext,
    ): Nft<T> {
        let id = object::new(ctx);

        event::emit(MintNftEvent {
            nft_id: object::uid_to_inner(&id),
            nft_type: type_name::into_string(type_name::get<Nft<T>>()),
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
    public fun new<T, C: drop>(
        _witness: C,
        name: string::String,
        url: Url,
        ctx: &mut TxContext,
    ): Nft<T> {
        utils::assert_same_module_as_witness<T, C>();
        new_(name, url, ctx)
    }

    /// Create a new `Nft` using `MintCap`
    public fun from_mint_cap<T>(
        mint_cap: &mut MintCap<T>,
        name: string::String,
        url: Url,
        ctx: &mut TxContext,
    ): Nft<T> {
        mint_cap::increment_supply(mint_cap, 1);
        new_(name, url, ctx)
    }

    // === Domain Functions ===

    /// Delegates a witness for wrapped NFTs
    ///
    /// #### Panics
    ///
    /// Panics if witness `W` does not originate from the same module as `C`.
    public fun delegate_witness<T, W: drop>(
        _witness: W,
    ): DelegatedWitness<T> {
        utils::assert_same_module_as_witness<T, W>();
        witness::from_witness<T, Witness>(Witness {})
    }

    /// Delegates `&UID` for domain specified extensions of `Nft`
    public fun borrow_uid<T>(nft: &Nft<T>): &UID {
        &nft.id
    }

    /// Delegates `&mut UID` for domain specified extensions of `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if witness `W` does not originate from the same module as `C`.
    public fun borrow_uid_mut<T, W: drop>(
        witness: W,
        nft: &mut Nft<T>,
    ): &mut UID {
        borrow_uid_delegated_mut(delegate_witness(witness), nft)
    }

    /// Delegates `&mut UID` for domain specified extensions of `Nft`
    public fun borrow_uid_delegated_mut<T>(
        _witness: DelegatedWitness<T>,
        nft: &mut Nft<T>,
    ): &mut UID {
        &mut nft.id
    }

    /// Check whether `Nft` has a domain
    public fun has_domain<T, Domain: store>(nft: &Nft<T>): bool {
        df::exists_with_type<Marker<Domain>, Domain>(
            &nft.id, utils::marker<Domain>(),
        )
    }

    /// Borrow domain from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain is not present on the `Nft`
    public fun borrow_domain<T, Domain: store>(nft: &Nft<T>): &Domain {
        assert_domain<T, Domain>(nft);
        df::borrow(&nft.id, utils::marker<Domain>())
    }

    /// Mutably borrow domain from `Nft`
    ///
    /// Guarantees that `Nft<T>` domains can only be mutated by the module that
    /// instantiated it.
    ///
    /// #### Panics
    ///
    /// Panics if domain does not exist or if witness `W` does not originate
    /// from the same module as `C`.
    public fun borrow_domain_mut<T, W: drop, Domain: store>(
        witness: W,
        nft: &mut Nft<T>,
    ): &mut Domain {
        borrow_domain_delegated_mut(
            delegate_witness(witness),
            nft,
        )
    }

    /// Mutably borrow domain from `Nft`
    ///
    /// Guarantees that `Nft<T>` domains can only be mutated by the module that
    /// instantiated it.
    ///
    /// #### Panics
    ///
    /// Panics if domain does not exist or if witness `W` does not originate
    /// from the same module as `C`.
    public fun borrow_domain_delegated_mut<T, Domain: store>(
        witness: DelegatedWitness<T>,
        nft: &mut Nft<T>,
    ): &mut Domain {
        assert_domain<T, Domain>(nft);
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
    public fun add_domain<T, Domain: store, W: drop>(
        witness: W,
        nft: &mut Nft<T>,
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
    public fun add_domain_delegated<T, Domain: store>(
        witness: DelegatedWitness<T>,
        nft: &mut Nft<T>,
        domain: Domain,
    ) {
        assert_no_domain<T, Domain>(nft);
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
    public fun remove_domain<T, W: drop, Domain: store>(
        witness: W,
        nft: &mut Nft<T>,
    ): Domain {
        assert_domain<T, Domain>(nft);
        remove_domain_delegated(delegate_witness(witness), nft)
    }

    /// Removes domain of type from `Nft`
    ///
    /// ##### Panics
    ///
    /// Panics if domain doesnt exist.
    public fun remove_domain_delegated<T, Domain: store>(
        witness: DelegatedWitness<T>,
        nft: &mut Nft<T>,
    ): Domain {
        assert_domain<T, Domain>(nft);
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
    public entry fun delete<T>(nft: Nft<T>) {
        let Nft { id, name: _, url: _ } = nft;
        object::delete(id);
    }

    // === Static Properties ===

    /// Returns `Nft` name
    public fun name<T>(nft: &Nft<T>): &string::String {
        &nft.name
    }

    /// Returns `Nft` URL
    public fun url<T>(nft: &Nft<T>): &Url {
        &nft.url
    }

    /// Sets `Nft` static name
    ///
    /// Caution when changing properties of loose NFTs as the changes will
    /// not be propagated to the template.
    public fun set_name<T>(
        _witness: DelegatedWitness<T>,
        nft: &mut Nft<T>,
        name: string::String,
    ) {
        nft.name = name
    }

    /// Sets `Nft` static URL
    ///
    /// Caution when changing properties of loose NFTs as the changes will
    /// not be propagated to the template.
    public fun set_url<T>(
        _witness: DelegatedWitness<T>,
        nft: &mut Nft<T>,
        url: Url,
    ) {
        nft.url = url
    }

    // === `Collection<C>` functions ===

    /// Creates a `Collection<C>` and corresponding `MintCap<Nft<T>>`
    public fun create_collection<C: drop, W: drop>(
        witness: W,
        ctx: &mut TxContext,
    ): Collection<C> {
        collection::create<C, W>(witness, ctx)
    }

    /// Delegates `&mut UID` of `Collection<C>`
    ///
    /// #### Panics
    ///
    /// Panics if witness `W` does not originate from the same module as `C`.
    public fun borrow_collection_uid_mut<C: drop, W: drop>(
        witness: W,
        collection: &mut Collection<C>,
    ): &mut UID {
        collection::borrow_uid_delegated_mut(
            delegate_witness(witness),
            collection,
        )
    }

    /// Mutably borrow domain from `Collection<C>`
    ///
    /// #### Panics
    ///
    /// Panics if domain does not exist or if witness `W` does not originate
    /// from the same module as `C`.
    public fun borrow_collection_domain_mut<C: drop, Domain: store, W: drop>(
        witness: W,
        collection: &mut Collection<C>,
    ): &mut Domain {
        collection::borrow_domain_delegated_mut(
            delegate_witness(witness),
            collection,
        )
    }

    /// Adds domain to `Collection<C>`
    ///
    /// Helper method that can be simply used without knowing what a delegated
    /// witness is.
    ///
    /// #### Panics
    ///
    /// Panics if domain already exists or if witness `W` does not originate
    /// from the same module as `C`.
    public fun add_collection_domain<C: drop, Domain: store, W: drop>(
        witness: W,
        collection: &mut Collection<C>,
        domain: Domain,
    ) {
        collection::add_domain_delegated(
            delegate_witness(witness),
            collection,
            domain,
        )
    }

    /// Removes domain of type from `Collection<C>`
    ///
    /// ##### Panics
    ///
    /// Panics if domain doesnt exist or if witness `W` does not originate from
    /// the same module as `C`.
    public fun remove_collection_domain<C: drop, Domain: store, W: drop>(
        witness: W,
        collection: &mut Collection<C>,
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
    public fun assert_domain<T, Domain: store>(nft: &Nft<T>) {
        assert!(has_domain<T, Domain>(nft), EUndefinedDomain);
    }

    /// Assert that domain does not exist on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if domain exists on `Nft`.
    public fun assert_no_domain<T, Domain: store>(nft: &Nft<T>) {
        assert!(!has_domain<T, Domain>(nft), EExistingDomain);
    }

    // === Test helpers ===

    #[test_only]
    /// Create `Nft` without access to `MintCap` or derivatives
    public fun test_mint<T>(ctx: &mut TxContext): Nft<T> {
        new_(std::string::utf8(b""), sui::url::new_unsafe_from_bytes(b""), ctx)
    }
}
