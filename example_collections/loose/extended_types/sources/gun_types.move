module gun_extensions::gun_types {
    struct Ar15 has drop {}
    struct Mp40 has drop {}
    struct DesertEagle has drop {}
    struct Colt has drop {}

    /// Can be used for authorization of other actions post-creation. It is
    /// vital that this struct is not freely given to any contract, because it
    /// serves as an auth token.
    struct Witness has drop {}
}
