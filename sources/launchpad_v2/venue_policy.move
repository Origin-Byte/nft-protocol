/// The rolling hot potato pattern was designed by us in conjunction with
/// Mysten team.
///
/// To lower the barrier to entry, we mimic those APIs where relevant.
/// See the `sui::transfer_policy` module in the https://github.com/MystenLabs/sui
///
/// Our transfer request offers generics over fungible token and associates
/// paid balance with the request.
/// This enables us to do permissionless transfers of NFTs.
///
/// We interoperate with the sui ecosystem by allowing our `TransferRequest` to
/// be converted into the sui version.
/// This is only possible for the cases where the payment is done in SUI token.
module nft_protocol::venue_request {
    use std::type_name::{Self, TypeName};
    use std::vector;
    use sui::dynamic_field as df;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};

    /// A completed rule is not set in the `TransferPolicy`.
    const EIllegalRule: u64 = 1;
    /// Conversion of our transfer request to the one exposed by the sui library
    /// is only permitted for SUI token.
    const EOnlyTransferRequestOfSuiToken: u64 = 2;
    /// The number of receipts does not match the `TransferPolicy` requirement.
    const EPolicyNotSatisfied: u64 = 3;

    /// A "Hot Potato" forcing the buyer to get a transfer permission
    /// from the item type (`T`) owner on purchase attempt.
    ///
    /// We create some helper methods for SUI token, but also support any
    /// fungible token.
    struct VenueRequest {
        venue: ID,
        /// For entities which authorize with `ID`, we convert the `ID` to
        /// address.
        originator: address,
        /// Collected Receipts.
        ///
        /// Used to verify that all of the rules were followed and
        /// `TransferRequest` can be confirmed.
        receipts: VecSet<TypeName>,
        /// Optional metadata can be attached to the request.
        /// The metadata is dropped at the destruction of the request.
        /// It doesn't have to be emptied out.
        metadata: UID,
    }

    /// A unique capability that allows the owner of the `T` to authorize
    /// transfers. Can only be created with the `Publisher` object. Although
    /// there's no limitation to how many policies can be created, for most
    /// of the cases there's no need to create more than one since any of the
    /// policies can be used to confirm the `TransferRequest`.
    struct VenuePolicy has key, store {
        id: UID,
        venue: ID,
        /// Set of types of attached rules - used to verify `receipts` when
        /// a `TransferRequest` is received in `confirm_request` function.
        ///
        /// Additionally provides a way to look up currently attached Rules.
        rules: VecSet<TypeName>
    }

    /// A Capability granting the owner permission to add/remove rules as well
    /// as to `withdraw` and `destroy_and_withdraw` the `TransferPolicy`.
    struct VenuePolicyCap has key, store {
        id: UID,
        venue: ID,
        policy_id: ID
    }

    /// Stores `VecSet<TypeName>` on `TransferPolicy`
    struct OringinbyteRulesDfKey has copy, store, drop {}

    /// Construct a new `TransferRequest` hot potato which requires an
    /// approving action from the creator to be destroyed / resolved.
    ///
    /// Must call `set_paid` to set the paid amount.
    public fun new(
        venue: ID, ctx: &mut TxContext,
    ): VenueRequest {
        VenueRequest {
            metadata: object::new(ctx),
            venue,
            originator: tx_context::sender(ctx),
            receipts: vec_set::empty(),
        }
    }

    /// Adds a `Receipt` to the `TransferRequest`, unblocking the request and
    /// confirming that the policy requirements are satisfied.
    public fun add_receipt<Rule>(self: &mut VenueRequest, _rule: &Rule) {
        vec_set::insert(&mut self.receipts, type_name::get<Rule>())
    }

    /// Anyone can attach any metadata (dynamic fields).
    /// The UID is eventually dropped when the `AuthRequest` is destroyed.
    ///
    /// There are some standard metadata which contracts should attach such as
    /// * `ob_kiosk::set_transfer_request_auth`
    public fun metadata_mut<T>(self: &mut VenueRequest): &mut UID {
        &mut self.metadata
    }

    // === Request confirmation ===

    /// Allow a `TransferRequest` for the type `T`.
    /// The call is protected by the type constraint, as only the publisher of
    /// the `T` can get `TransferPolicy<T>`.
    ///
    /// Note: unless there's a policy for `T` to allow transfers,
    /// Kiosk trades will not be possible.
    /// If there is no transfer policy in the OB ecosystem, try using
    /// `into_sui` to convert the `TransferRequest` to the SUI ecosystem.
    public fun confirm_request(
        self: &VenuePolicy, request: VenueRequest,
    ) {
        let VenueRequest {
            metadata,
            venue: _,
            originator: _,
            receipts,
        } = request;
        let rules = df::borrow(&self.id, OringinbyteRulesDfKey {});
        let completed = vec_set::into_keys(receipts);
        let total = vector::length(&completed);

        assert!(total == vec_set::size(rules), EPolicyNotSatisfied);

        while (total > 0) {
            let rule_type = vector::pop_back(&mut completed);
            assert!(vec_set::contains(rules, &rule_type), EIllegalRule);
            total = total - 1;
        };

        object::delete(metadata);
    }

    // === Fields access ===

    /// Which entity started the trade.
    public fun originator<T>(self: &VenueRequest): address { self.originator }

    /// What's the NFT that's being transferred.
    public fun venue(self: &VenueRequest): ID { self.venue }
}
