/// Module of the `PluginDomain` for extending collection contracts
///
/// A plugin is a smart contract which extends the functionality of the
/// collection base contract by obtaining an instance of the collection
/// `Witness` type.
/// Plugins are thus able to implement custom logic for collections
/// post-deployment.
/// This solves the issue that after a package is deployed, it can no
/// longer leverage witness protected API.
module nft_protocol::plugins {
    use std::type_name::{Self, TypeName};

    use sui::vec_set::{Self, VecSet};

    use nft_protocol::witness::{
        Self, WitnessGenerator, Witness as DelegatedWitness
    };
    use nft_protocol::collection::{Self, Collection};

    /// `PluginDomain` not registered on `Collection`
    ///
    /// Call `add_plugin_domain` to register plugin on `Collection`.
    const EUNDEFINED_PLUGIN_DOMAIN: u64 = 1;

    /// Plugin was not defined on `PluginDomain`
    ///
    /// Call `add_plugin` or `add_collection_plugin` to register plugins.
    const EUNDEFINED_PLUGIN: u64 = 2;

    // === PluginDomain ===

    struct PluginDomain<phantom C> has store {
        /// Generator responsible for issuing delegated witnesses
        generator: WitnessGenerator<C>,
        /// Witnesses that have the ability to mutate standard domains
        packages: VecSet<TypeName>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Creates a new `PluginDomain` object
    fun new<C, W>(witness: &W): PluginDomain<C> {
        PluginDomain {
            generator: witness::generator(witness),
            packages: vec_set::empty(),
        }
    }

    /// Attributes witness as a plugin on the `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if witness was already attributed or `PluginDomain` is not
    /// registered on the `Collection`.
    public fun add_plugin<T, PluginWitness>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
    ) {
        let domain = borrow_plugin_domain_mut(collection);
        vec_set::insert(&mut domain.packages, type_name::get<PluginWitness>());
    }

    /// Removes witness as a plugin on the `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if witness was not attributed or `PluginDomain` is not
    /// registered on the `Collection`.
    public fun remove_plugin<T, PluginWitness>(
        _witness: DelegatedWitness<T>,
        collection: &mut Collection<T>,
    ) {
        let domain = borrow_plugin_domain_mut(collection);
        vec_set::remove(
            &mut domain.packages,
            &type_name::get<PluginWitness>()
        );
    }

    /// Create a delegated witness
    ///
    /// Delegated witness can be used to authorize mutating operations across
    /// most OriginByte domains.
    ///
    /// #### Panics
    ///
    /// Panics if plugin witness was not a plugin or `CreatorsDomain` was not
    /// registered on the `Collection`.
    public fun delegate<T, PluginWitness>(
        _witness: &PluginWitness,
        collection: &mut Collection<T>,
    ): DelegatedWitness<T> {
        let domain = borrow_plugin_domain(collection);
        assert_plugin<T, PluginWitness>(domain);
        witness::delegate(&domain.generator)
    }

    // === Getters ===

    /// Returns whether witness is a defined plugin
    public fun contains_plugin<T, PluginWitness>(
        domain: &PluginDomain<T>,
    ): bool {
        vec_set::contains(&domain.packages, &type_name::get<PluginWitness>())
    }

    /// Returns list of all defined plugins
    public fun borrow_plugins<T>(domain: &PluginDomain<T>): &VecSet<TypeName> {
        &domain.packages
    }

    // === Interoperability ===

    /// Borrows `PluginDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `PluginDomain` is not registered on `Collection`.
    public fun borrow_plugin_domain<T>(
        collection: &Collection<T>,
    ): &PluginDomain<T> {
        assert_domain(collection);
        collection::borrow_domain(collection)
    }

    /// Mutably borrows `PluginDomain` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `PluginDomain` is not registered on `Collection`.
    fun borrow_plugin_domain_mut<T>(
        collection: &mut Collection<T>,
    ): &mut PluginDomain<T> {
        assert_domain(collection);
        collection::borrow_domain_mut(Witness {}, collection)
    }

    /// Adds `PluginDomain` to `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `CreatorsDomain` already exists.
    public fun add_plugin_domain<T, W>(
        witness: &W,
        collection: &mut Collection<T>,
    ) {
        let domain = new<T, W>(witness);
        collection::add_domain(witness, collection, domain);
    }

    // === Assertions ===

    /// Asserts that witness is attributed in `PluginDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `PluginDomain` is not defined or witness is not a plugin.
    public fun assert_plugin<T, PluginWitness>(domain: &PluginDomain<T>) {
        assert!(contains_plugin<T, PluginWitness>(domain), EUNDEFINED_PLUGIN);
    }

    /// Asserts that `PluginDomain` is defined on the `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `PluginDomain` is not defined on the `Collection`.
    public fun assert_domain<T>(collection: &Collection<T>) {
        assert!(
            collection::has_domain<T, PluginDomain<T>>(collection),
            EUNDEFINED_PLUGIN_DOMAIN,
        )
    }
}
