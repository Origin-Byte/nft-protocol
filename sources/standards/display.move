/// Module of NFT domains for displaying standard information
///
/// Current display domains are:
///     - DisplayDomain (For NFTs and Collections)
///     - UrlDomain (For NFTs and Collections)
///     - SymbolDomain (For Collections)
///     - Attributes (For NFTs)
module nft_protocol::display {
    use std::string::String;
    use std::option::{Self, Option};

    use sui::url::Url;
    use sui::object::ID;
    use sui::vec_map::{Self, VecMap};

    use nft_protocol::witness;
    use nft_protocol::utils;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::collection::{Self, Collection};

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    struct DisplayDomain has drop, store {
        name: String,
        description: String,
    }

    /// Gets name of `DisplayDomain`
    public fun name(domain: &DisplayDomain): &String {
        &domain.name
    }

    /// Gets description of `DisplayDomain`
    public fun description(domain: &DisplayDomain): &String {
        &domain.description
    }

    /// Creates a new `DisplayDomain` with name and description
    public fun new_display_domain(
        name: String,
        description: String,
    ): DisplayDomain {
        DisplayDomain { name, description }
    }

    /// Sets name of `DisplayDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_name<C>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        name: String,
    ) {
        let domain: &mut DisplayDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.name = name;
    }

    /// Sets description of `DisplayDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_description<C>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        description: String,
    ) {
        let domain: &mut DisplayDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.description = description;
    }

    // ====== Interoperability ===

    public fun display_domain<C>(
        nft: &Nft<C>,
    ): &DisplayDomain {
        nft::borrow_domain(nft)
    }

    public fun collection_display_domain<C>(
        nft: &Collection<C>,
    ): &DisplayDomain {
        collection::borrow_domain(nft)
    }

    public fun add_display_domain<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
        name: String,
        description: String,
    ) {
        nft::add_domain(
            witness, nft, new_display_domain(name, description),
        );
    }

    public fun add_collection_display_domain<C, W>(
        witness: &W,
        collection: &mut Collection<C>,
        name: String,
        description: String,
    ) {
        collection::add_domain(
            witness, collection, new_display_domain(name, description)
        );
    }

    public fun remove_display_domain<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
    ): DisplayDomain {
        remove_display_domain_delegated(witness::from_witness(witness), nft)
    }

    public fun remove_display_domain_delegated<C>(
        _witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
    ): DisplayDomain {
        nft::remove_domain<C, Witness, DisplayDomain>(Witness {}, nft)
    }

    // === UrlDomain ===

    struct UrlDomain has store {
        url: Url,
    }

    /// Gets URL of `UrlDomain`
    public fun url(domain: &UrlDomain): &Url {
        &domain.url
    }

    /// Creates new `UrlDomain` with a URL
    public fun new_url_domain(url: Url): UrlDomain {
        UrlDomain { url }
    }

    /// Sets name of `UrlDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_url<C>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        url: Url,
    ) {
        let domain: &mut UrlDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.url = url;
    }

    // ====== Interoperability ===

    public fun display_url<C>(nft: &Nft<C>): Option<Url> {
        if (!nft::has_domain<C, UrlDomain>(nft)) {
            return option::none()
        };

        option::some(*url(nft::borrow_domain<C, UrlDomain>(nft)))
    }

    public fun display_collection_url<C>(nft: &Collection<C>): Option<Url> {
        if (!collection::has_domain<C, UrlDomain>(nft)) {
            return option::none()
        };

        option::some(*url(collection::borrow_domain<C, UrlDomain>(nft)))
    }

    public fun add_url_domain<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
        url: Url,
    ) {
        nft::add_domain(witness, nft, new_url_domain(url));
    }

    public fun add_collection_url_domain<C, W>(
        witness: &W,
        nft: &mut Collection<C>,
        url: Url,
    ) {
        collection::add_domain(witness, nft, new_url_domain(url));
    }

    // === SymbolDomain ===

    struct SymbolDomain has store {
        symbol: String,
    }

    /// Gets symbol of `SymbolDomain`
    public fun symbol(domain: &SymbolDomain): &String {
        &domain.symbol
    }

    /// Creates new `SymbolDomain` with a symbol
    public fun new_symbol_domain(symbol: String): SymbolDomain {
        SymbolDomain { symbol }
    }

    /// Sets name of `DisplayDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_symbol<C>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        symbol: String,
    ) {
        let domain: &mut SymbolDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.symbol = symbol;
    }

    // ====== Interoperability ===

    public fun display_symbol<C>(nft: &Nft<C>): Option<String> {
        if (!nft::has_domain<C, SymbolDomain>(nft)) {
            return option::none()
        };

        option::some(*symbol(nft::borrow_domain<C, SymbolDomain>(nft)))
    }

    public fun display_collection_symbol<C>(
        nft: &Collection<C>
    ): Option<String> {
        if (!collection::has_domain<C, SymbolDomain>(nft)) {
            return option::none()
        };

        option::some(*symbol(collection::borrow_domain<C, SymbolDomain>(nft)))
    }

    public fun add_symbol_domain<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
        symbol: String,
    ) {
        nft::add_domain(witness, nft, new_symbol_domain(symbol));
    }

    public fun add_collection_symbol_domain<C, W>(
        witness: &W,
        nft: &mut Collection<C>,
        symbol: String,
    ) {
        collection::add_domain(witness, nft, new_symbol_domain(symbol));
    }

    // === AttributesDomain ===

    struct AttributesDomain has store {
        map: VecMap<String, String>,
    }

    /// Gets Keys of `Attributes`
    public fun attributes(domain: &AttributesDomain): &VecMap<String, String> {
        &domain.map
    }

    /// Gets Keys of `Attributes`
    public fun keys(domain: &AttributesDomain): vector<String> {
        let (keys, _) = vec_map::into_keys_values(domain.map);
        keys
    }

    /// Gets Values of `Attributes`
    public fun values(domain: &AttributesDomain): vector<String> {
        let (_, values) = vec_map::into_keys_values(domain.map);
        values
    }

    /// Creates new `Attributes` with a keys and values
    public fun new_attributes_domain(
        map: VecMap<String, String>,
    ): AttributesDomain {
        AttributesDomain { map }
    }

    public fun new_attributes_domain_from_vec(
        keys: vector<String>,
        values: vector<String>,
    ): AttributesDomain {
        let map = utils::from_vec_to_map<String, String>(keys, values);
        new_attributes_domain(map)
    }

    // ====== Interoperability ===

    public fun display_attribute<C>(nft: &Nft<C>): &AttributesDomain {
        nft::borrow_domain<C, AttributesDomain>(nft)
    }

    public fun display_attribute_mut<C>(
        _witness: DelegatedWitness<C>,
        nft: &mut Nft<C>,
    ): &mut AttributesDomain {
        nft::borrow_domain_mut(Witness {}, nft)
    }

    public fun add_attributes_domain<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
        map: VecMap<String, String>,
    ) {
        nft::add_domain(
            witness, nft, new_attributes_domain(map),
        );
    }

    public fun add_attributes_domain_from_vec<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
        keys: vector<String>,
        values: vector<String>,
    ) {
        nft::add_domain(
            witness, nft, new_attributes_domain_from_vec(keys, values),
        );
    }

    struct CollectionIdDomain has store {
        collection_id: ID,
    }

    /// Gets name of `CollectionIdDomain`
    public fun collection_id(domain: &CollectionIdDomain): &ID {
        &domain.collection_id
    }

    /// Creates a new `CollectionIdDomain` with name
    public fun new_collection_id_domain(
        collection_id: ID,
    ): CollectionIdDomain {
        CollectionIdDomain { collection_id }
    }

    /// Sets name of `CollectionIdDomain`
    ///
    /// Requires that `AttributionDomain` is defined and sender is a creator
    public fun set_collection_id<C>(
        _witness: DelegatedWitness<C>,
        collection: &mut Collection<C>,
        collection_id: ID,
    ) {
        let domain: &mut CollectionIdDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        domain.collection_id = collection_id;
    }

    // ====== Interoperability ===

    public fun collection_id_domain<C>(
        nft: &Nft<C>,
    ): &CollectionIdDomain {
        nft::borrow_domain(nft)
    }

    public fun add_collection_id_domain<C, W>(
        witness: &W,
        nft: &mut Nft<C>,
        collection_id: ID,
    ) {
        nft::add_domain(
            witness, nft, new_collection_id_domain(collection_id),
        );
    }
}
