//! Exports error functions. All errors in this smart contract have a prefix
//! which distinguishes them from errors in other packages.
module nft_protocol::err {

    const Prefix: u64 = 13370000;

    public fun nft_not_embedded(): u64 {
        return Prefix + 01
    }

    public fun nft_not_loose(): u64 {
        return Prefix + 02
    }

    public fun collection_mismatch(): u64 {
        return Prefix + 03
    }

    public fun collection_is_not_mutable(): u64 {
        return Prefix + 04
    }

    public fun wrong_nft_data_provided(): u64 {
        return Prefix + 05
    }

    public fun nft_data_mismatch(): u64 {
        return Prefix + 06
    }

    public fun not_enough_nfts_to_mint_cnft(): u64 {
        return Prefix + 07
    }

    public fun coin_amount_below_price(): u64 {
        return Prefix + 08
    }

    public fun not_nft_owner(): u64 {
        return Prefix + 09
    }

    // === Supply ===

    public fun supply_policy_mismatch(): u64 {
        return Prefix + 100
    }

    public fun supply_is_not_zero(): u64 {
        return Prefix + 101
    }

    public fun supply_is_limited(): u64 {
        return Prefix + 102
    }

    public fun supply_is_unlimited(): u64 {
        return Prefix + 103
    }

    public fun frozen_supply(): u64 {
        return Prefix + 104
    }

    public fun max_supply_cannot_be_below_current_supply(): u64 {
        return Prefix + 105
    }

    public fun current_supply_cannot_be_negative(): u64 {
        return Prefix + 106
    }

    public fun supply_maxed_out(): u64 {
        return Prefix + 107
    }

    // Launchpad

    public fun wrong_launchpad_admin(): u64 {
        return Prefix + 201
    }

    public fun launchpad_not_live(): u64 {
        return Prefix + 202
    }

    public fun sale_outlet_still_has_nfts_to_sell(): u64 {
        return Prefix + 203
    }

    public fun sale_outlet_still_has_nfts_to_redeem(): u64 {
        return Prefix + 204
    }

    public fun sale_is_not_whitelisted(): u64 {
        return Prefix + 205
    }

    public fun sale_is_whitelisted(): u64 {
        return Prefix + 206
    }

    public fun incorrect_whitelist_token(): u64 {
        return Prefix + 207
    }

    public fun certificate_does_not_correspond_to_nft_given(): u64 {
        return Prefix + 208
    }

    // === Safe ===

    public fun safe_cap_mismatch(): u64 {
        return Prefix + 300
    }

    public fun safe_does_not_contain_nft(): u64 {
        return Prefix + 301
    }

    public fun nft_exlusively_listed(): u64 {
        return Prefix + 302
    }

    public fun transfer_cap_nft_mismatch(): u64 {
        return Prefix + 303
    }

    public fun transfer_cap_expired(): u64 {
        return Prefix + 304
    }

    // === Whitelist ===

    public fun authority_not_whitelisted(): u64 {
        return Prefix + 400
    }

    public fun sender_not_collection_creator(): u64 {
        return Prefix + 401
    }
}
