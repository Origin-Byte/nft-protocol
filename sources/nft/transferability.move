//! Dummy module to demonstrate transferability requirement enforcement on
//! `NFT` transfers in between `Safes`.
 
module nft_protocol::transferability {
    use nft_protocol::nft::Nft;

    struct EnforceNop has drop {}

    public fun new_nop(): EnforceNop {
        EnforceNop {}
    }

    struct EnforceMintRoyalty {}

    public fun new_mint_royalty(): EnforceMintRoyalty {
        EnforceMintRoyalty {}
    }

    public fun conclude_mint_royalty<T, D: store>(
        token: EnforceMintRoyalty, // Drop token if successful
        _nft: &Nft<T, D>,
        // Additional arguments required to fulfill royalty after mint requirements
        // ...
    ) {
        // Nothing but potatoes here
        let EnforceMintRoyalty {} = token;
    }
}