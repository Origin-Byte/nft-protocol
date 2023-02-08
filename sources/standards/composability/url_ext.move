/// Module of `ComposableUrlDomain` domain
///
/// `ComposableUrlDomain` composes the base `UrlDomain` and `AttributesDomain` by
/// composing attributes as GET parameters.
///
/// `composable_url` defines the core type to avoid dependency cycles.
module nft_protocol::composable_url_ext {
    use std::vector;
    use std::ascii::{Self, String};

    use sui::url::{Self, Url};
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::witness::Witness as DelegatedWitness;
    use nft_protocol::composable_url::{Self, ComposableUrlDomain};

    // === Interoperability ===

    public fun add() {
        // TODO
    }
}