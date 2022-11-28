module nft_protocol::tags {
    use std::vector;
    use std::string::String;

    use sui::vec_map::{Self, VecMap};
    use sui::tx_context::TxContext;

    use nft_protocol::utils;
    use nft_protocol::nft::{Self, NFT};
    use nft_protocol::collection::{Self, Collection};

    struct TagDomain has store {
        // TODO: Use VecSet?
        enumerations: VecMap<u64, String>
    }

    public fun tags(domain: &TagDomain): &VecMap<u64, String> {
        &domain.enumerations
    }

    public fun empty(): TagDomain {
        TagDomain { enumerations: vec_map::empty() }
    }

    public fun from_vec_string(v: vector<String>): TagDomain {
        let enumerations = vec_map::empty();

        while (!vector::is_empty(&v)) {
            let index = vec_map::size(&enumerations);
            vec_map::insert(&mut enumerations, index, vector::pop_back(&mut v));
        };

        TagDomain { enumerations }
    }

    public fun from_byte_vec(v: vector<vector<u8>>): TagDomain {
        from_vec_string(utils::to_string_vector(v))
    }

    /// ====== Interoperability ===

    public fun tag_domain<C>(
        nft: &NFT<C>,
    ): &TagDomain {
        nft::borrow_domain(nft)
    }

    public fun collection_tag_domain<C>(
        nft: &Collection<C>,
    ): &TagDomain {
        collection::borrow_domain(nft)
    }

    public fun add_tag_domain<C>(
        nft: &mut NFT<C>,
        tags: TagDomain,
        ctx: &mut TxContext,
    ) {
        nft::add_domain(nft, tags, ctx);
    }

    public fun add_collection_tag_domain<C>(
        nft: &mut Collection<C>,
        tags: TagDomain,
    ) {
        collection::add_domain(nft, tags);
    }
}
