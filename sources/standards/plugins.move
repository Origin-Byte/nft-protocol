/// Module of the `Plugin` for extending collection contracts
///
/// A plugin is a smart contract which extends the functionality of the
/// collection base contract by obtaining an instance of the collection
/// `Witness` type.
/// Plugins are thus able to implement custom logic for collections
/// post-deployment.
/// This solves the issue that after a package is deployed, it can no
/// longer leverage witness protected API.
module nft_protocol::plugins {
    // TODO: Plugin must be generalised beyond the collection
    use std::type_name::{Self, TypeName};

    use sui::vec_set::{Self, VecSet};

    use nft_protocol::witness::{
        Self, WitnessGenerator, Witness as DelegatedWitness
    };
    use nft_protocol::collection::{Self, Collection};
    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{
        assert_with_witness, assert_with_consumable_witness, UidType,
        assert_same_module
    };
    use nft_protocol::consumable_witness::{Self as cw, ConsumableWitness};

    /// `Plugin` not registered on `Collection`
    ///
    /// Call `add_plugin_domain` to register plugin on `Collection`.
    const EUNDEFINED_PLUGIN_FIELD: u64 = 1;

    /// Field object `Plugin` already defined as dynamic field.
    const EPLUGIN_FIELD_ALREADY_EXISTS: u64 = 2;

    /// Plugin was not defined on `Plugin`
    ///
    /// Call `add_plugin` or `add_collection_plugin` to register plugins.
    const EUNDEFINED_PLUGIN: u64 = 3;

    // === Plugin ===

    struct Plugin<phantom C> has store {
        /// Generator responsible for issuing delegated witnesses
        generator: WitnessGenerator<C>,
        /// Witnesses that have the ability to mutate standard domains
        packages: VecSet<TypeName>,
    }

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Key struct used to store DisplayInfo in dynamic fields
    struct PluginKey has store, copy, drop {}


    // === Insert with ConsumableWitness ===


    /// Adds `DisplayInfo` as a dynamic field with key `DisplayInfoKey`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if type `T` does not match `C`'s module.
    public fun add_plugin<C, T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
    ) {
        assert_has_not_plugin(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);
        assert_same_module<C, T>();

        let plugin = new<ConsumableWitness<T>, C>(&consumable);

        cw::consume<T, Plugin<C>>(consumable, &mut plugin);
        df::add(nft_uid, PluginKey {}, plugin);
    }


    // === Insert with module specific Witness ===


    /// Adds `Plugin` as a dynamic field with key `PluginKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    /// Panics if type `T` does not match `C`'s module.
    public fun add_plugin_<W: drop, C, T: key>(
        witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>,
    ) {
        assert_has_not_plugin(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);
        assert_same_module<C, T>();

        let plugin = new<W, C>(&witness);
        df::add(nft_uid, PluginKey {}, plugin);
    }

    // === Get for call from external Module ===


    /// Creates a new `Plugin` object
    fun new<W, C>(witness: &W): Plugin<C> {
        Plugin {
            generator: witness::generator(witness),
            packages: vec_set::empty(),
        }
    }


    // === Field Borrow Functions ===


    /// Borrows immutably the `Plugin` field.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `DisplayInfoKey` does not exist.
    public fun borrow_plugin<C>(
        nft_uid: &UID,
    ): &Plugin<C> {
        // TODO: Consider asserting that type C and T come from same mod

        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_plugin(nft_uid);
        df::borrow(nft_uid, PluginKey {})
    }

    /// Borrows Mutably the `Plugin` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a
    /// `ConsumableWitness` for the specific type `T` and field `Plugin`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `DisplayInfoKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    public fun borrow_plugin_mut<C, T: key>(
        consumable: ConsumableWitness<T>,
        nft_uid: &mut UID,
        nft_type: UidType<T>
    ): &mut Plugin<C> {
        // TODO: Consider asserting that type C and T come from same mod

        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_plugin(nft_uid);
        assert_with_consumable_witness(nft_uid, nft_type);

        let plugin = df::borrow_mut<PluginKey, Plugin<C>>(
            nft_uid,
            PluginKey {}
        );
        cw::consume<T, Plugin<C>>(consumable, plugin);

        plugin
    }

    /// Borrows Mutably the `Plugin` field.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `DisplayInfoKey` does not exist.
    ///
    /// Panics if `nft_uid` does not correspond to `nft_type.id`,
    /// in other words, it panics if `nft_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun borrow_display_info_mut_<W: drop, C, T: key>(
        _witness: W,
        nft_uid: &mut UID,
        nft_type: UidType<T>
    ): &mut Plugin<C> {
        // TODO: Consider asserting that type C and T come from same mod

        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_plugin(nft_uid);
        assert_with_witness<W, T>(nft_uid, nft_type);

        df::borrow_mut(nft_uid, PluginKey {})
    }

    /// Mutably borrows `Plugin` from `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Plugin` is not registered on `Collection`.
    fun borrow_plugin_domain_mut<T>(
        collection: &mut Collection<T>,
    ): &mut Plugin<T> {
        assert_domain(collection);
        collection::borrow_domain_mut(Witness {}, collection)
    }

    /// Attributes witness as a plugin on the `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if witness was already attributed or `Plugin` is not
    /// registered on the `Collection`.
    public fun insert_plugin<T, PluginWitness>(
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
    /// Panics if witness was not attributed or `Plugin` is not
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
        domain: &Plugin<T>,
    ): bool {
        vec_set::contains(&domain.packages, &type_name::get<PluginWitness>())
    }

    /// Returns list of all defined plugins
    public fun borrow_plugins<T>(domain: &Plugin<T>): &VecSet<TypeName> {
        &domain.packages
    }

    // === Interoperability ===

    /// Adds `Plugin` to `Collection`
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

    /// Asserts that witness is attributed in `Plugin`
    ///
    /// #### Panics
    ///
    /// Panics if `Plugin` is not defined or witness is not a plugin.
    public fun assert_plugin<T, PluginWitness>(domain: &Plugin<T>) {
        assert!(contains_plugin<T, PluginWitness>(domain), EUNDEFINED_PLUGIN);
    }

    /// Asserts that `Plugin` is defined on the `Collection`
    ///
    /// #### Panics
    ///
    /// Panics if `Plugin` is not defined on the `Collection`.
    public fun assert_domain<T>(collection: &Collection<T>) {
        assert!(
            collection::has_domain<T, Plugin<T>>(collection),
            EUNDEFINED_PLUGIN_DOMAIN,
        )
    }

    // === Assertions & Helpers ===


    /// Checks that a given NFT has a dynamic field with `DisplayInfoKey`
    public fun has_plugin(
        nft_uid: &UID,
    ): bool {
        df::exists_(nft_uid, PluginKey {})
    }

    public fun assert_has_plugin(nft_uid: &UID) {
        assert!(has_plugin(nft_uid), EUNDEFINED_PLUGIN_FIELD);
    }

    public fun assert_has_not_plugin(nft_uid: &UID) {
        assert!(!has_plugin(nft_uid), EPLUGIN_FIELD_ALREADY_EXISTS);
    }
}
