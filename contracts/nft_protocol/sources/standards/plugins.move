/// Module of the `Plugins` for extending collection contracts
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
    use sui::object::UID;
    use sui::dynamic_field as df;

    use ob_utils::utils::{marker, Marker};
    use ob_permissions::witness::{
        Self, WitnessGenerator, Witness as DelegatedWitness,
    };

    /// Field object `Plugins` not registered on in object `T`
    const EUndefinedPlugins: u64 = 1;

    /// Field object `Plugins` already defined as dynamic field.
    const EExistingPlugins: u64 = 2;

    /// Plugins was not defined on `Plugins`
    const EUndefinedPlugin: u64 = 3;

    struct Plugins<phantom T> has store {
        /// Generator responsible for issuing delegated witnesses
        generator: WitnessGenerator<T>,
        /// Witnesses that have the ability to mutate standard domains
        packages: VecSet<TypeName>,
    }

    #[allow(unused_type_parameter, unused_function)]
    /// Creates a new `Plugins` object
    fun new<T, W: drop>(witness: W): Plugins<T> {
        Plugins {
            generator: witness::generator(witness),
            packages: vec_set::empty(),
        }
    }

    /// Returns whether witness is a defined plugin
    public fun contains_plugin<T, PluginWitness>(
        domain: &Plugins<T>,
    ): bool {
        vec_set::contains(&domain.packages, &type_name::get<PluginWitness>())
    }

    /// Mutably borrows the list of all plugin witnesses in `Plugins`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Plugins`.
    public fun get_plugins<T>(plugin: &mut Plugins<T>): &VecSet<TypeName> {
        &plugin.packages
    }

    /// Adds witness to `Plugins` field in the NFT of type `T`.
    //
    // TODO: Unsafe to arbitrarily add creator, should check that sender is
    // already a creator
    public fun add_plugin<T, PluginWitness>(
        _witness: DelegatedWitness<T>,
        plugins: &mut Plugins<T>,
    ) {
        vec_set::insert(
            &mut plugins.packages,
            type_name::get<PluginWitness>(),
        );
    }

    /// Removes witness from `Plugins` field in the NFT of type `T`.
    //
    // TODO: Unsafe to arbitrarily add creator, should check that sender is
    // already a creator
    public fun remove_plugin<T, PluginWitness>(
        _witness: DelegatedWitness<T>,
        plugins: &mut Plugins<T>,
    ) {
        vec_set::remove(
            &mut plugins.packages,
            &type_name::get<PluginWitness>(),
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
        plugins: &mut Plugins<T>,
    ): DelegatedWitness<T> {
        assert_plugin<T, PluginWitness>(plugins);
        witness::delegate(&plugins.generator)
    }

    // === Interoperability ===

    /// Returns whether `Plugins` is registered on `Nft`
    public fun has_domain<T>(nft: &UID): bool {
        df::exists_with_type<Marker<Plugins<T>>, Plugins<T>>(
            nft, marker(),
        )
    }

    /// Borrows `Plugins` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Plugins` is not registered on the `Nft`
    public fun borrow_domain<T>(nft: &UID): &Plugins<T> {
        assert_plugins<T>(nft);
        df::borrow(nft, marker<Plugins<T>>())
    }

    /// Mutably borrows `Plugins` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Plugins` is not registered on the `Nft`
    public fun borrow_domain_mut<T>(nft: &mut UID): &mut Plugins<T> {
        assert_plugins<T>(nft);
        df::borrow_mut(nft, marker<Plugins<T>>())
    }

    /// Adds `Plugins` to `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Plugins` domain already exists
    public fun add_domain<T>(
        nft: &mut UID,
        domain: Plugins<T>,
    ) {
        assert_no_plugins<T>(nft);
        df::add(nft, marker<Plugins<T>>(), domain);
    }

    /// Remove `Plugins` from `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Plugins` domain doesnt exist
    public fun remove_domain<T>(nft: &mut UID): Plugins<T> {
        assert_plugins<T>(nft);
        df::remove(nft, marker<Plugins<T>>())
    }

    // === Assertions ===

    /// Asserts that witness is attributed in `Plugins`
    ///
    /// #### Panics
    ///
    /// Panics if `Plugins` is not defined or witness is not a plugin.
    public fun assert_plugin<T, PluginWitness>(domain: &Plugins<T>) {
        assert!(contains_plugin<T, PluginWitness>(domain), EUndefinedPlugin);
    }

    /// Asserts that `Plugins` is registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Plugins` is not registered
    public fun assert_plugins<T>(nft: &UID) {
        assert!(has_domain<T>(nft), EUndefinedPlugins);
    }

    /// Asserts that `Plugins` is not registered on `Nft`
    ///
    /// #### Panics
    ///
    /// Panics if `Plugins` is registered
    public fun assert_no_plugins<T>(nft: &UID) {
        assert!(!has_domain<T>(nft), EExistingPlugins);
    }
}
