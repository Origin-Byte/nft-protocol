/// Exports error functions. All errors in this smart contract have a prefix
/// which distinguishes them from errors in other packages.
module nft_protocol::err {
    const Prefix: u64 = 13370000;

    // === Marketplace ===

    public fun wrong_marketplace_admin(): u64 {
        return Prefix + 201
    }

    public fun marketplace_listing_mismatch(): u64 {
        return Prefix + 210
    }

    public fun wrong_marketplace_or_listing_admin(): u64 {
        return Prefix + 211
    }

    public fun wrong_fee_policy_type(): u64 {
        return Prefix + 213
    }

    public fun has_custom_fee_policy(): u64 {
        return Prefix + 214
    }

    public fun listing_already_attached_to_marketplace(): u64 {
        return Prefix + 219
    }

    public fun listing_has_not_applied_to_this_marketplace(): u64 {
        return Prefix + 219
    }

    public fun action_exclusive_to_standalone_listings(): u64 {
        return Prefix + 219
    }

    // === Trading ===

    public fun sender_not_owner(): u64 {
        return Prefix + 700
    }

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
