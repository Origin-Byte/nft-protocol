/// P2PLists NFT transfers.
///
/// This module is a set of functions for implementing and managing a
/// Authlist for NFT (non-fungible token) transfers.
/// The Authlist is used to authorize which contracts are allowed to
/// transfer NFTs of a particular collection.
/// The module includes functions for creating and managing the Authlist,
/// adding and removing collections from the Authlist, and checking whether
/// a contract is authorized to transfer a particular NFT.
/// The module uses generics and reflection to allow for flexibility in
/// implementing and managing the Authlist.
///
/// Generics at play:
/// 1. Admin (Authlist witness) enables any organization to start their own
///     Authlist and manage it according to their own rules;
/// 2. Auth (3rd party witness) is used to authorize contracts via their
///     witness types. If e.g. an orderbook trading contract wants to be
///     included in a Authlist, the Authlist admin adds the stringified
///     version of their witness type. The OB then uses this witness type
///     to authorize transfers.
module nft_protocol::p2p_list {
    use std::vector;
    use std::type_name;

    use sui::bcs;
    use sui::object::{Self, ID};
    use sui::transfer_policy::{TransferPolicy, TransferPolicyCap};
    use sui::kiosk::{Self, Kiosk};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    use ob_request::request::{Self, Policy, PolicyCap, WithNft};
    use ob_kiosk::ob_kiosk;
    use ob_request::transfer_request::{Self, TransferRequest};

    use ob_authlist::authlist::{Self, Authlist};

    // === Structs ===

    struct Witness has drop {}

    /// `sui::transfer_policy::TransferPolicy` can have this rule to enforce
    /// that only P2PListed contracts can transfer NFTs.
    ///
    /// Note that this rule depends on `ob_kiosk::get_transfer_request_auth`
    /// and only works with `transfer_request::TransferRequest`.
    ///
    /// That's because the sui implementation of `TransferRequest` is simplified
    /// and does not support safe metadata about the originator of the transfer.
    struct P2PListRule has drop {}

    // === Transfers ===

    public fun transfer<T: key + store>(
        self: &Authlist,
        authority: &vector<u8>,
        nft_id: ID,
        source: &mut Kiosk,
        target: &mut Kiosk,
        signature: &vector<u8>,
        nonce: vector<u8>,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        let req = ob_kiosk::transfer_signed<T>(
            source,
            target,
            nft_id,
            0,
            ctx,
        );

        confirm_transfer_(
            self,
            &mut req,
            authority,
            nft_id,
            nonce,
            signature,
            kiosk::owner(source),
            kiosk::owner(target),
            ctx,
        );

        req
    }

    #[lint_allow(share_owned)]
    public fun transfer_into_new_kiosk<T: key + store>(
        self: &Authlist,
        authority: &vector<u8>,
        nft_id: ID,
        source: &mut Kiosk,
        target: address,
        signature: &vector<u8>,
        nonce: vector<u8>,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        let (target_kiosk, _) = ob_kiosk::new_for_address(target, ctx);

        let req = ob_kiosk::transfer_signed<T>(
            source,
            &mut target_kiosk,
            nft_id,
            0,
            ctx,
        );

        transfer::public_share_object(target_kiosk);

        confirm_transfer_(
            self,
            &mut req,
            authority,
            nft_id,
            nonce,
            signature,
            kiosk::owner(source),
            target,
            ctx,
        );

        req
    }

    /// Registers collection to use `Authlist` during the transfer.
    public entry fun enforce<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
        transfer_request::add_originbyte_rule<T, P2PListRule, bool>(
            P2PListRule {}, policy, cap, false,
        );
    }

    public fun drop<T>(policy: &mut TransferPolicy<T>, cap: &TransferPolicyCap<T>) {
        transfer_request::remove_originbyte_rule<T, P2PListRule, bool>(
            policy, cap,
        );
    }

    public entry fun enforce_<T, P>(
        policy: &mut Policy<WithNft<T, P>>,
        cap: &PolicyCap,
    ) {
        request::enforce_rule_no_state<WithNft<T, P>, P2PListRule>(
            policy, cap,
        );
    }

    public fun drop_<T, P>(
        policy: &mut Policy<WithNft<T, P>>,
        cap: &PolicyCap,
    ) {
        request::drop_rule_no_state<WithNft<T, P>, P2PListRule>(policy, cap);
    }

    /// Confirms that the transfer is allowed by the `Authlist`.
    /// It adds a signature to the request.
    /// In the end, if the Authlist rule is included in the transfer policy,
    /// the transfer request can only be finished if this rule is present.
    ///
    /// #### Panics
    ///
    /// Panics if signed message does not use `authority` as public key, or
    /// signature does not sign the following concatenation of properties.
    ///
    /// `nft_id | source | destination | tx_context::epoch | nonce`
    fun confirm_transfer_<T>(
        self: &Authlist,
        req: &mut TransferRequest<T>,
        authority: &vector<u8>,
        nft_id: ID,
        nonce: vector<u8>,
        signature: &vector<u8>,
        source: address,
        destination: address,
        ctx: &TxContext,
    ) {
        ob_kiosk::set_transfer_request_auth(req, &Witness {});

        confirm_<T>(self, authority, nft_id, source, destination, nonce, signature, ctx);
        transfer_request::add_receipt(req, P2PListRule {});
    }

    /// Confirm that signature was correctly generated from transaction
    /// properties
    ///
    /// #### Panics
    ///
    /// Panics if signed message does not use `authority` as public key, or
    /// signature does not sign the following concatenation of properties:
    ///
    /// `nft_id | source | destination | tx_context::epoch | nonce`
    fun confirm_<T>(
        self: &Authlist,
        authority: &vector<u8>,
        nft_id: ID,
        source: address,
        destination: address,
        nonce: vector<u8>,
        signature: &vector<u8>,
        ctx: &TxContext,
    ) {
        let msg = vector::empty();
        vector::append(&mut msg, object::id_to_bytes(&nft_id));
        vector::append(&mut msg, bcs::to_bytes(&source));
        vector::append(&mut msg, bcs::to_bytes(&destination));
        vector::append(&mut msg, bcs::to_bytes(&tx_context::epoch(ctx)));
        vector::append(&mut msg, nonce);

        authlist::assert_transferable(
            self, type_name::get<T>(), authority, &msg, signature,
        );
    }
}
