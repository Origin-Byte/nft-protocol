module nft_protocol::type_ext {
    use std::type_name::{Self, TypeName};

    use sui::vec_set::{Self, VecSet};
    use sui::object::UID;
    use sui::dynamic_field as df;
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::witness::{Witness as DelegatedWitness};

    /// Field object `Extensions` not registered on in object `T`
    const EUndefinedExtensions: u64 = 1;

    /// Field object `Extensions` already defined as dynamic field.
    const EExistingExtensions: u64 = 2;

    /// Type was not defined on `Extensions`
    const EUndefinedPlugin: u64 = 3;

    struct Extensions has store {
        authority: address,
        /// Witnesses that have the ability to mutate standard domains
        types: VecSet<TypeName>,
    }

    /// Creates empty `Attributes`
    public fun new(ctx: &mut TxContext): Extensions {
        Extensions { authority: tx_context::sender(ctx), types: vec_set::empty() }
    }

    // === Collection Instantiator ===

    public fun add_new<C>(
        collection: &mut Collection<C>,
        witness: DelegatedWitness<C>,
        ctx: &mut TxContext,
    ) {
        collection::add_domain(witness, collection, new(ctx));
    }

    /// Gets underlying authority immutably
    public fun get_authority(
        extensions: &Extensions,
    ): address {
        extensions.authority
    }

    public fun get_types(
        extensions: &Extensions,
    ): &VecSet<TypeName> {
        &extensions.types
    }

    /// Returns whether type is a defined extension
    public fun contains_type<T>(
        extensions: &Extensions,
    ): bool {
        vec_set::contains(&extensions.types, &type_name::get<T>())
    }

    /// Adds type to `Extensions` field in the Collection of type `C`.
    public fun add_type<C, T>(
        _witness_c: DelegatedWitness<C>,
        _witness_t: DelegatedWitness<T>,
        collection: &mut Collection<C>,
    ) {
        let type_ext = collection::borrow_domain_mut<C, Extensions>(
            _witness_c,
            collection
        );

        vec_set::insert(
            &mut type_ext.types,
            type_name::get<T>(),
        );
    }

    /// Removes type from `Extensions` field in Collection of type `C`.
    public fun remove_type<C, T>(
        _witness_c: DelegatedWitness<C>,
        _witness_t: DelegatedWitness<T>,
        collection: &mut Collection<C>,
    ) {
        let type_ext = collection::borrow_domain_mut<C, Extensions>(
            _witness_c,
            collection
        );

        vec_set::remove(
            &mut type_ext.types,
            &type_name::get<T>(),
        );
    }


    // === Interoperability ===

    /// Returns whether `Extensions` is registered on `collection`
    public fun has_domain<T>(object: &UID): bool {
        df::exists_with_type<Marker<Extensions>, Extensions>(
            object, utils::marker(),
        )
    }

    /// Borrows `Extensions` from the object
    ///
    /// #### Panics
    ///
    /// Panics if `Extensions` is not registered on the object
    public fun borrow_domain<T>(object: &UID): &Extensions {
        assert_extensions<T>(object);
        df::borrow(object, utils::marker<Extensions>())
    }

    /// Mutably borrows `Extensions` from the object
    ///
    /// #### Panics
    ///
    /// Panics if `Extensions` is not registered on the object
    public fun borrow_domain_mut<T>(object: &mut UID): &mut Extensions {
        assert_extensions<T>(object);
        df::borrow_mut(object, utils::marker<Extensions>())
    }

    /// Adds `Extensions` to an object
    ///
    /// #### Panics
    ///
    /// Panics if `Extensions` domain already exists
    public fun add_domain<T>(
        object: &mut UID,
        domain: Extensions,
    ) {
        assert_no_extensions<T>(object);
        df::add(object, utils::marker<Extensions>(), domain);
    }

    /// Remove `Extensions` from an object
    ///
    /// #### Panics
    ///
    /// Panics if `Extensions` domain doesnt exist
    public fun remove_domain<T>(object: &mut UID): Extensions {
        assert_extensions<T>(object);
        df::remove(object, utils::marker<Extensions>())
    }

    // === Assertions ===

    /// Asserts that type is attributed in `Extensions`
    ///
    /// #### Panics
    ///
    /// Panics if `Extensions` is not defined or type is not an extension.
    public fun assert_type<T>(domain: &Extensions) {
        assert!(contains_type<T>(domain), EUndefinedPlugin);
    }

    /// Asserts that `Extensions` is registered on an object
    ///
    /// #### Panics
    ///
    /// Panics if `Extensions` is not registered
    public fun assert_extensions<T>(object: &UID) {
        assert!(has_domain<T>(object), EUndefinedExtensions);
    }

    /// Asserts that `Extensions` is not registered on an object
    ///
    /// #### Panics
    ///
    /// Panics if `Extensions` is registered
    public fun assert_no_extensions<T>(object: &UID) {
        assert!(!has_domain<T>(object), EExistingExtensions);
    }
}
