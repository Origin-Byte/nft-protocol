/// Implements a domain registrar contract
///
/// TODO: This module has an accompanying article ...
module nft_protocol::domain_name {
    use std::vector;
    use std::string::{Self, String};

    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::witness;
    use nft_protocol::display;
    use nft_protocol::mint_cap::MintCap;
    use nft_protocol::collection::{Self, Collection};

    /// Provided domain was already registered
    ///
    /// Call `register_domain` with a different domain
    const ECONFLICTING_DOMAIN: u64 = 1;

    /// One time witness is only instantiated in the init method
    struct DOMAINNAME has drop {}

    /// Used for authorization of other protected actions.
    ///
    /// `Witness` must not be freely exposed to any contract.
    struct Witness has drop {}

    // === RegistryDomain ===

    /// Collection domain responsible for storing domains already registered
    struct RegistryDomain has key, store {
        /// `RegistryDomain` ID
        id: UID,
        /// Registered domains mapped to their `Nft` ID
        domains: VecMap<String, ID>,
    }

    /// Create new `RegistryDomain`
    fun registry_domain(ctx: &mut TxContext): RegistryDomain {
        RegistryDomain {
            id: object::new(ctx),
            domains: vec_map::empty(),
        }
    }

    /// Adds registration to `RegistryDomain` and mints corresponding NFT
    ///
    /// #### Panics
    ///
    /// Panics if domain was already registered
    fun add_registration(
        mint_cap: &MintCap<DOMAINNAME>,
        registry: &mut RegistryDomain,
        domain: String,
        description: String,
        ctx: &mut TxContext,
    ): Nft<DOMAINNAME> {
        assert!(
            !vec_map::contains(&registry.domains, &domain),
            ECONFLICTING_DOMAIN,
        );

        let nft = nft::new(
            &Witness {},
            mint_cap,
            tx_context::sender(ctx),
            ctx,
        );

        // Use `DisplayDomain` to display registry entry
        display::add_display_domain(
            witness::from_witness(&Witness {}),
            &mut nft,
            domain,
            description,
            ctx,
        );

        vec_map::insert(&mut registry.domains, domain, object::id(&nft));

        nft
    }

    // === Record ===

    /// DNS record
    struct Record has drop, store {
        type: String,
        host: String,
        value: String,
    }

    /// Create a CNAME record
    public fun new_cname(host: String, value: String): Record {
        Record { type: string::utf8(b"CNAME"), host, value }
    }

    /// Create a fictional CADDR methods which points to a SUI address
    public fun new_caddr(host: String, value: address): Record {
        Record {
            type: string::utf8(b"CADDR"),
            host,
            value: sui::address::to_string(value)
        }
    }

    // === RecordDomain ===

    /// NFT domain responsible for holding DNS records
    struct RecordDomain has key, store {
        /// `RecordDomain` ID
        id: UID,
        /// `Record` list
        records: vector<Record>,
    }

    /// Create a new `RecordDomain`
    public fun record_domain(ctx: &mut TxContext): RecordDomain {
        RecordDomain { id: object::new(ctx), records: vector::empty() }
    }

    /// Add `Record` to `RecordDomain`
    public fun add_record(records: &mut RecordDomain, record: Record) {
        vector::push_back(&mut records.records, record);
    }

    /// Remove `Record` at index from `RecordDomain`
    ///
    /// #### Panics
    ///
    /// Panics if `Record` with the given index does not exist
    public fun remove_record(records: &mut RecordDomain, index: u64): Record {
        vector::remove(&mut records.records, index)
    }

    // === Contract ===

    fun init(witness: DOMAINNAME, ctx: &mut TxContext) {
        let (mint_cap, collection) = collection::create(&witness, ctx);
        let delegated_witness = witness::from_witness(&Witness {});

        display::add_collection_display_domain(
            delegated_witness,
            &mut collection,
            string::utf8(b".sui Registrar"),
            string::utf8(b".sui domain name registrar"),
            ctx,
        );

        collection::add_domain(
            delegated_witness,
            &mut collection,
            registry_domain(ctx),
        );

        // Share `MintCap` to allow any user to register domains at will
        transfer::share_object(mint_cap);
        transfer::share_object(collection);
    }

    /// Register new domain in `RegistryDomain`
    ///
    /// #### Panics
    ///
    /// Panics if domain was already registered
    public entry fun register_domain(
        mint_cap: &MintCap<DOMAINNAME>,
        collection: &mut Collection<DOMAINNAME>,
        domain: String,
        description: String,
        ctx: &mut TxContext,
    ) {
        let delegated_witness = witness::from_witness(&Witness {});

        let registry_domain: &mut RegistryDomain =
            collection::borrow_domain_mut(Witness {}, collection);

        let nft = add_registration(
            mint_cap, registry_domain, domain, description, ctx,
        );

        nft::add_domain(
            delegated_witness, &mut nft, record_domain(ctx),
        );

        transfer::transfer(nft, tx_context::sender(ctx));
    }

    /// Add CNAME `Record` to domain `Nft`
    public entry fun add_cname_record(
        nft: &mut Nft<DOMAINNAME>,
        host: String,
        value: String,
        ctx: &mut TxContext,
    ) {
        nft::assert_logical_owner(nft, ctx);

        let record_domain: &mut RecordDomain =
            nft::borrow_domain_mut(Witness {}, nft);

        add_record(record_domain, new_cname(host, value));
    }

    /// Add CADDR `Record` to domain `Nft`
    public entry fun add_caddr_record(
        nft: &mut Nft<DOMAINNAME>,
        host: String,
        value: address,
        ctx: &mut TxContext,
    ) {
        nft::assert_logical_owner(nft, ctx);

        let record_domain: &mut RecordDomain =
            nft::borrow_domain_mut(Witness {}, nft);

        add_record(record_domain, new_caddr(host, value));
    }
}
