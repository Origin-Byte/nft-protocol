module nft_protocol::domain {
    use std::type_name::{Self, TypeName};

    struct DomainKey has copy, drop, store {
        type: TypeName,
    }

    public fun domain_key<D>(): DomainKey {
        DomainKey {
            type: type_name::get<D>(),
        }
    }
}
