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
    // TODO: Deprecate DelegatedWitness, consider how it relates to ConsumableWitness
    // TODO: Consider the relevance of WitnessGenerator
    // TODO: Consider if generator should have getters, but I don't think,
    // I believe it should be private
    use std::type_name::{Self, TypeName};

    use sui::vec_set::{Self, VecSet};

    use nft_protocol::witness::{
        Self, WitnessGenerator
    };
    use sui::object::UID;
    use sui::dynamic_field as df;

    use nft_protocol::utils::{
        assert_with_witness, UidType,
        assert_same_module, Self, marker, Marker
    };

    /// Field object `Plugin` not registered on in object `T`
    const EUNDEFINED_PLUGIN_FIELD: u64 = 1;

    /// Field object `Plugin` already defined as dynamic field.
    const EPLUGIN_FIELD_ALREADY_EXISTS: u64 = 2;

    /// Plugin was not defined on `Plugin`
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


    // === Insert with module specific Witness ===


    /// Adds `Plugin` as a dynamic field with key `PluginKey`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    /// Panics if type `T` does not match `C`'s module.
    public fun add_plugin<W: drop, C: drop, T: key>(
        witness: W,
        object_uid: &mut UID,
        object_type: UidType<T>,
    ) {
        assert_has_not_plugin<C>(object_uid);
        assert_with_witness<W, T>(object_uid, object_type);
        assert_same_module<T, C>();

        let plugin = new<W, C>(&witness);
        df::add(object_uid, marker<Plugin<C>>(), plugin);
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
    public fun borrow_plugin<C: drop>(
        object_uid: &UID,
    ): &Plugin<C> {
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_plugin<C>(object_uid);
        df::borrow(object_uid, marker<Plugin<C>>())
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
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    ///
    /// Panics if Witness `W` does not match `T`'s module.
    public fun borrow_display_info_mut<W: drop, C: drop, T: key>(
        _witness: W,
        object_uid: &mut UID,
        object_type: UidType<T>
    ): &mut Plugin<C> {
        assert_same_module<T, C>();
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_plugin<C>(object_uid);
        assert_with_witness<W, T>(object_uid, object_type);
        df::borrow_mut(object_uid, marker<Plugin<C>>())
    }


    // === Writer Functions ===


    /// Inserts witness as typename to `Plugin` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `PluginKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun insert_witness<W: drop, C: drop, T: key, PluginWitness>(
        _main_witness: W,
        object_uid: &mut UID,
        object_type: UidType<T>,
    ) {
        utils::assert_same_module<T, C>();
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_plugin<C>(object_uid);
        assert_with_witness<W, T>(object_uid, object_type);

        let plugin = borrow_mut_internal<C>(object_uid);
        vec_set::insert(&mut plugin.packages, type_name::get<PluginWitness>());
    }

    /// Removes witness as typename from `Plugin` field in the NFT of type `T`.
    ///
    /// Endpoint is protected as it relies on safetly obtaining a witness
    /// from the contract exporting the type `T`.
    ///
    /// #### Panics
    ///
    /// Panics if dynamic field with `PluginKey` does not exist.
    ///
    /// Panics if `object_uid` does not correspond to `object_type.id`,
    /// in other words, it panics if `object_uid` is not of type `T`.
    public fun remove_witness<W: drop, C: drop, T: key, PluginWitness>(
        _main_witness: W,
        object_uid: &mut UID,
        object_type: UidType<T>,
    ) {
        utils::assert_same_module<T, C>();
        // `df::borrow` fails if there is no such dynamic field,
        // however asserting it here allows for a more straightforward
        // error message
        assert_has_plugin<C>(object_uid);
        assert_with_witness<W, T>(object_uid, object_type);

        let plugin = borrow_mut_internal<C>(object_uid);

        vec_set::remove(
            &mut plugin.packages,
            &type_name::get<PluginWitness>()
        );
    }


    // === Getter Functions & Static Mutability Accessors ===

    /// Immutably borrows the list of all plugin witnesses in `Plugin`
    public fun get_plugins<T>(plugin: &Plugin<T>): &VecSet<TypeName> {
        &plugin.packages
    }

    /// Mutably borrows the list of all plugin witnesses in `Plugin`
    ///
    /// Endpoint is unprotected and relies on safely obtaining a mutable
    /// reference to `Plugin`.
    public fun get_plugins_mut<T>(plugin: &mut Plugin<T>): &VecSet<TypeName> {
        &plugin.packages
    }


    // === Private Functions ===


    /// Borrows Mutably the `Plugin` field.
    ///
    /// For internal use only.
    fun borrow_mut_internal<C>(
        object_uid: &mut UID,
    ): &mut Plugin<C> {
        df::borrow_mut<Marker<Plugin<C>>, Plugin<C>>(
            object_uid,
            marker<Plugin<C>>()
        )
    }


    // === Assertions & Helpers ===

    /// Returns whether witness is a defined plugin
    public fun contains_plugin<T, PluginWitness>(
        domain: &Plugin<T>,
    ): bool {
        vec_set::contains(&domain.packages, &type_name::get<PluginWitness>())
    }

    /// Checks that a given NFT has a dynamic field with `DisplayInfoKey`
    public fun has_plugin<C: drop>(
        object_uid: &UID,
    ): bool {
        df::exists_(object_uid, marker<Plugin<C>>())
    }

    /// Asserts that witness is attributed in `Plugin`
    ///
    /// #### Panics
    ///
    /// Panics if `Plugin` is not defined or witness is not a plugin.
    public fun assert_plugin<T, PluginWitness>(domain: &Plugin<T>) {
        assert!(contains_plugin<T, PluginWitness>(domain), EUNDEFINED_PLUGIN);
    }

    /// Asserts that an object has a dynamic field with key `PluginKey`
    ///
    /// #### Panics
    ///
    /// Panics if no dynamic field with key `PluginKey`
    public fun assert_has_plugin<C: drop>(
        object_uid: &UID
    ) {
        assert!(has_plugin<C>(object_uid), EUNDEFINED_PLUGIN_FIELD);
    }

    /// Asserts that an object does not have a dynamic field with key `PluginKey`
    ///
    /// #### Panics
    ///
    /// Panics if it has dynamic field with key `PluginKey`
    public fun assert_has_not_plugin<C: drop>(object_uid: &UID) {
        assert!(!has_plugin<C>(object_uid), EPLUGIN_FIELD_ALREADY_EXISTS);
    }
}
