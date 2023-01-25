/// A plugin is a smart contract which extends the functionality of a collection
/// base smart contract by being allowed to get an instance of the `Witness`
/// struct.
/// Therefore, a plugin can be used to implement custom logic for a collection
/// post deployment of the original collection smart contract.
///
/// This solves the issue that after a package is deployed, it can no longer
/// leverage our pattern where we use `Witness` to authorize access to various
/// APIs.
module nft_protocol::plugins {
    use std::type_name::{Self, TypeName};
    use sui::vec_set::{Self, VecSet};
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::collection::{Self, Collection};
    use nft_protocol::err;
    use nft_protocol::utils;

    // === PluginDomain ===

    struct PluginDomain has key, store {
        id: UID,
        packages: VecSet<TypeName>,
    }

    struct Witness has drop {}

    public fun empty(ctx: &mut TxContext): PluginDomain {
        PluginDomain { id: object::new(ctx), packages: vec_set::empty() }
    }

    public fun has_plugin<PluginWitness>(domain: &PluginDomain): bool {
        vec_set::contains(&domain.packages, &type_name::get<PluginWitness>())
    }

    public fun collection_has_plugin<C, PluginWitness>(collection: &Collection<C>): bool {
        let domain: &PluginDomain = collection::borrow_domain(collection);
        vec_set::contains(&domain.packages, &type_name::get<PluginWitness>())
    }

    public fun add_plugin<PluginWitness>(
        domain: &mut PluginDomain,
    ) {
        vec_set::insert(&mut domain.packages, type_name::get<PluginWitness>());
    }

    public fun remove_plugin<PluginWitness>(
        domain: &mut PluginDomain,
    ) {
        vec_set::remove(&mut domain.packages, &type_name::get<PluginWitness>());
    }

    /// === Interoperability ===

    public fun borrow_plugin_domain<C>(
        collection: &Collection<C>,
    ): &PluginDomain {
        collection::borrow_domain(collection)
    }

    /// Requires that sender is a creator
    public fun borrow_plugin_domain_mut<C, W: drop>(
        _witness: W,
        collection: &mut Collection<C>,
    ): &mut PluginDomain {
        utils::assert_same_module_as_witness<C, W>();

        collection::borrow_domain_mut(Witness {}, collection)
    }

    /// === Assertions ===

    public fun assert_has_plugin<PluginWitness>(domain: &PluginDomain) {
        assert!(has_plugin<PluginWitness>(domain), err::collection_does_not_have_plugin());
    }

    public fun assert_collection_has_plugin<C, PluginWitness>(collection: &Collection<C>) {
        assert!(
            collection_has_plugin<C, PluginWitness>(collection),
            err::collection_does_not_have_plugin(),
        );
    }
}
