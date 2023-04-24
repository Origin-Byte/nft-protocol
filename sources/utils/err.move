/// Exports error functions. All errors in this smart contract have a prefix
/// which distinguishes them from errors in other packages.
module nft_protocol::err {
    const Prefix: u64 = 13370000;

    // === Domains ===

    public fun address_not_attributed(): u64 {
        return Prefix + 800
    }

    public fun address_does_not_have_enough_shares(): u64 {
        return Prefix + 801
    }

    public fun invalid_total_share_of_royalties(): u64 {
        return Prefix + 802
    }

    public fun share_attribution_already_exists(): u64 {
        return Prefix + 803
    }
}
