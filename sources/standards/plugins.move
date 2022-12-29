module nft_protocol::plugins {
    use sui::vec_set::{Self, VecSet};
    use std::type_name::{Self, TypeName};

    use nft_protocol::utils;
    use nft_protocol::collection::{Self, Collection};

    // === PluginDomain ===

    struct PluginDomain has store {
        packages: VecSet<TypeName>,
    }

    struct Witness has drop {}

    public fun empty(): PluginDomain {
        PluginDomain { packages: vec_set::empty() }
    }

    public fun has_plugin<PluginWitness>(domain: &PluginDomain): bool {
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
        assert!(has_plugin<PluginWitness>(domain), 0); // TODO
    }
}
