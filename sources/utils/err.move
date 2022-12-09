//! Exports error functions. All errors in this smart contract have a prefix
//! which distinguishes them from errors in other packages.
module nft_protocol::err {

    const Prefix: u64 = 13370000;

    // === NFT ===

    public fun not_nft_owner(): u64 {
        return Prefix + 000
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

    // === Launchpad ===

    public fun wrong_launchpad_admin(): u64 {
        return Prefix + 201
    }

    public fun slot_not_live(): u64 {
        return Prefix + 202
    }

    public fun nft_sale_incompleted(): u64 {
        return Prefix + 203
    }

    public fun nft_redemption_incompleted(): u64 {
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

    // TODO: To be used by redeem function
    public fun certificate_nft_id_mismatch(): u64 {
        return Prefix + 208
    }

    public fun no_nfts_left(): u64 {
        return Prefix + 209
    }

    public fun launchpad_slot_mismatch(): u64 {
        return Prefix + 210
    }

    public fun wrong_launchpad_or_slot_admin(): u64 {
        return Prefix + 211
    }

    public fun wrong_slot_admin(): u64 {
        return Prefix + 212
    }

    public fun wrong_fee_policy_type(): u64 {
        return Prefix + 213
    }

    public fun has_custom_fee_policy(): u64 {
        return Prefix + 214
    }

    public fun slot_not_approved(): u64 {
        return Prefix + 215
    }

    // === Auction ===

    public fun order_does_not_exist(): u64 {
        return Prefix + 301
    }

    public fun order_owner_must_be_sender(): u64 {
        return Prefix + 302
    }

    public fun order_price_below_reserve(): u64 {
        return Prefix + 303
    }

    public fun action_not_public(): u64 {
        return Prefix + 304
    }

    // === Safe ===

    public fun safe_cap_mismatch(): u64 {
        return Prefix + 400
    }

    public fun safe_does_not_contain_nft(): u64 {
        return Prefix + 401
    }

    public fun nft_exclusively_listed(): u64 {
        return Prefix + 402
    }

    public fun transfer_cap_nft_mismatch(): u64 {
        return Prefix + 403
    }

    public fun transfer_cap_expired(): u64 {
        return Prefix + 404
    }

    public fun safe_does_not_accept_deposits(): u64 {
        return Prefix + 405
    }

    public fun nft_not_exlusively_listed(): u64 {
        return Prefix + 406
    }

    public fun safe_id_mismatch(): u64 {
        return Prefix + 407
    }

    // === Whitelist ===

    public fun authority_not_whitelisted(): u64 {
        return Prefix + 500
    }

    public fun sender_not_whitelist_admin(): u64 {
        return Prefix + 502
    }

    // === Utils ===

    public fun witness_source_mismatch(): u64 {
        return Prefix + 600
    }

    public fun must_be_witness(): u64 {
        return Prefix + 601
    }

    // === Trading ===

    public fun sender_not_owner(): u64 {
        return Prefix + 700
    }

    // === AttributionDomain ===

    public fun address_not_attributed(): u64 {
        return Prefix + 800
    }

    public fun address_does_not_have_enough_shares(): u64 {
        return Prefix + 801
    }

    public fun invalid_total_share_of_royalties(): u64 {
        return Prefix + 802
    }

    // === Generic ===

    public fun generic_bag_full(): u64 {
        return Prefix + 900
    }

    public fun generic_box_full(): u64 {
        return Prefix + 901
    }

    public fun missing_dynamic_field(): u64 {
        return Prefix + 902
    }

    // === Collection ===

    public fun mint_cap_mismatch(): u64 {
        return Prefix + 1000
    }
}
