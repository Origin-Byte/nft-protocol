/// Orderbook where bids are fungible tokens and asks are NFTs.
/// A bid is a request to buy one NFT from a specific collection.
/// An ask is one NFT with a min price condition.
///
/// One can
/// - create a new orderbook between a given collection and a bid token;
/// - set publicly accessible actions to be witness protected;
/// - open a new bid;
/// - cancel an existing bid they own;
/// - offer an NFT if collection matches OB collection;
/// - cancel an existing NFT offer;
/// - instantly buy a specific NFT;
/// - open bids and asks with a commission on behalf of a user;
/// - edit positions;
/// - trade both native and 3rd party collections.
///
/// # Other resources
/// - https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook
/// - https://origin-byte.github.io/orderbook.html
module liquidity_layer::orderbook {
    // TODO: Consider adding start_time as a static field
    // TODO: Currently, set_protection_ is such that it does not allow the publisher
    // to remove protections, only to add them.
    use std::ascii::String;
    use std::option::{Self, Option};
    use std::type_name;
    use std::vector;

    use sui::transfer_policy::TransferPolicy;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::event;
    use sui::package::{Self, Publisher};
    use sui::kiosk::{Self, Kiosk};
    use sui::object::{Self, ID, UID};
    use sui::transfer::share_object;
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_field as df;
    use sui::clock::{Self, Clock};

    use ob_permissions::witness::{Self, Witness as DelegatedWitness};
    use ob_kiosk::ob_kiosk;
    use ob_request::transfer_request::{Self, TransferRequest};

    use liquidity_layer::trading;
    use liquidity_layer::liquidity_layer::LIQUIDITY_LAYER;
    use liquidity_layer::trade_request::{Self, TradeRequest, BUY_NFT, CREATE_ASK, CREATE_BID};
    use ob_request::request::{Policy};

    use critbit::critbit_u64::{Self as critbit, CritbitTree};

    // Track the current version of the module
    const VERSION: u64 = 1;

    const ENotUpgraded: u64 = 999;
    const EWrongVersion: u64 = 1000;

    // 1 SUI == 1_000_000_000 MIST
    // 0.1 SUI == 100_000_000 MIST
    // 0.01 SUI == 10_000_000 MIST
    // 0.001 SUI == 1_000_000 MIST
    const DEFAULT_TICK_SIZE: u64 = 1_000_000;

    // === Errors ===

    /// A protected action was called without a witness.
    /// This action can only be called from an implementation in the collection
    /// smart contract.
    const EActionNotPublic: u64 = 1;

    const EActionNotProtected: u64 = 2;

    /// Cannot make sell commission higher than listed price
    const ECommissionTooHigh: u64 = 3;

    /// The NFT lives in a kiosk which also wanted to buy it
    const ECannotTradeWithSelf: u64 = 4;

    /// User doesn't own this order
    const EOrderOwnerMustBeSender: u64 = 5;

    /// Expected different kiosk
    const EKioskIdMismatch: u64 = 6;

    /// No order matches the given price level or ownership level
    const EOrderDoesNotExist: u64 = 7;

    /// Market orders fail with this error if they cannot be filled
    const EMarketOrderNotFilled: u64 = 8;

    /// Trying to create an orderbook via a witness protected endpoint
    /// without TransferPolicy being registered with OriginByte
    const ENotOriginBytePolicy: u64 = 9;

    /// Trying to access an endpoint for creating an orderbook for collections
    /// that are external to the OriginByte ecosystem, without itself being external
    const ENotExternalPolicy: u64 = 10;

    /// Trying to enable an time-locked orderbook before its start time
    const EOrderbookTimeLocked: u64 = 11;

    const EOrderbookNotTimeLocked: u64 = 12;

    /// Trying to add migrated liquidity to an orderbook whilst referencing the
    /// incorrect Orderbook V1
    const EIncorrectOrderbookV1: u64 = 13;

    /// Trying to add migrated liquidity to an orderbook which
    /// itself is not under migration
    const ENotUnderMigration: u64 = 14;

    /// Trying to call `set_protection_with_witness` whilst the orderbook is under
    /// migration. This is a non-authorized operation during liquidity migration
    const EUnderMigration: u64 = 15;

    const ENotAuthorized: u64 = 16;

    // === Structs ===

    /// Add this witness type to allowlists via
    /// `transfer_allowlist::insert_authority` to allow orderbook trades with
    /// that allowlist.
    struct Witness has drop {}

    struct TradeIntermediateDfKey has copy, store, drop {
        trade_id: ID,
    }

    struct TimeLockDfKey has copy, store, drop {}
    struct UnderMigrationFromDfKey has copy, store, drop {}

    /// A critbit order book implementation. Contains two ordered trees:
    /// 1. bids ASC
    /// 2. asks DESC
    struct Orderbook<phantom T: key + store, phantom FT> has key, store {
        id: UID,
        version: u64,
        tick_size: u64,
        is_live: bool,
        /// Actions which have a flag set to true can only be called via a
        /// witness protected implementation.
        protected_actions: ProtectedActions,
        /// An ask order stores an NFT to be traded. The price associated with
        /// such an order is saying:
        ///
        /// > for this NFT, I want to receive at least this amount of FT.
        asks: CritbitTree<vector<Ask>>,
        /// A bid order stores amount of tokens of type "B"(id) to trade. A bid
        /// order is saying:
        ///
        /// > for any NFT in this collection, I will spare this many tokens
        bids: CritbitTree<vector<Bid<FT>>>,
    }

    /// The contract which creates the orderbook can restrict specific actions
    /// to be only callable with a witness pattern and not via the entry point
    /// function.
    ///
    /// This means contracts can build on top of this orderbook their custom
    /// logic if they desire so, or they can just use the entry point functions
    /// which might be good enough for most use cases.
    ///
    /// # Important
    /// If a method is protected, then clients call instead of the relevant
    /// endpoint in the orderbook a standardized endpoint in the witness-owning
    /// smart contract.
    ///
    /// Another way to think about this from marketplace or wallet POV:
    /// If I see that an action is protected, I can decide to either call
    /// the downstream implementation in the collection smart contract, or just
    /// not enable to perform that specific action at all.
    ///
    /// We don't restrict canceling positions to protect the users.
    struct ProtectedActions has store {
        buy_nft: Option<Policy<BUY_NFT>>,
        create_ask: Option<Policy<CREATE_ASK>>,
        create_bid: Option<Policy<CREATE_BID>>,
    }

    /// An offer for a single NFT in a collection.
    struct Bid<phantom FT> has store {
        /// How many token are being offered by the order issuer for one NFT.
        offer: Balance<FT>,
        /// The address of the user who created this bid and who will receive an
        /// NFT in exchange for their tokens.
        owner: address,
        /// Points to `Kiosk` shared object into which to deposit NFT.
        kiosk: ID,
        /// If the NFT is offered via a marketplace or a wallet, the
        /// facilitator can optionally set how many tokens they want to claim
        /// on top of the offer.
        commission: Option<trading::BidCommission<FT>>,
    }

    /// Object which is associated with a single NFT.
    ///
    /// When [`Ask`] is created, we transfer the ownership of the NFT to this
    /// new object.
    /// When an ask is matched with a bid, we transfer the ownership of the
    /// [`Ask`] object to the bid owner (buyer).
    /// The buyer can then claim the NFT via [`claim_nft`] endpoint.
    struct Ask has store {
        /// How many tokens does the seller want for their NFT in exchange.
        price: u64,
        /// ID of the respective NFT object
        nft_id: ID,
        /// ID of the respective kiosk
        kiosk_id: ID,
        /// Who owns the NFT.
        owner: address,
        /// If the NFT is offered via a marketplace or a wallet, the
        /// facilitator can optionally set how many tokens they want to claim
        /// from the price of the NFT for themselves as a commission.
        commission: Option<trading::AskCommission>,
    }

    /// `TradeIntermediate` is made a shared object and can be called in a
    /// permissionless transaction `finish_trade`.
    struct TradeIntermediate<phantom T, phantom FT> has key, store {
        id: UID,
        nft_id: ID,
        /// Who receives the funds
        seller: address,
        /// Where can we find the NFT
        seller_kiosk: ID,
        /// Who pays
        buyer: address,
        /// Where to deposit the NFT
        buyer_kiosk: ID,
        /// From buyer to seller
        paid: Balance<FT>,
        /// From the `paid` amount we deduct commission
        commission: Option<trading::AskCommission>,
    }

    /// Helper struct to be used on the client side. Helps the client side
    /// to identity the trade_id which is needed to call `finish_trade`
    struct TradeInfo has copy, store, drop {
        trade_price: u64,
        trade_id: ID,
    }

    // === Events ===

    struct OrderbookCreatedEvent has copy, drop {
        orderbook: ID,
        nft_type: String,
        ft_type: String,
    }

    struct AskCreatedEvent has copy, drop {
        nft: ID,
        orderbook: ID,
        owner: address,
        price: u64,
        kiosk: ID,
        nft_type: String,
        ft_type: String,
    }

    /// When de-listed, not when sold!
    struct AskClosedEvent has copy, drop {
        nft: ID,
        orderbook: ID,
        owner: address,
        price: u64,
        nft_type: String,
        ft_type: String,
    }

    struct BidCreatedEvent has copy, drop {
        orderbook: ID,
        owner: address,
        price: u64,
        kiosk: ID,
        nft_type: String,
        ft_type: String,
    }

    /// When de-listed, not when bought!
    struct BidClosedEvent has copy, drop {
        orderbook: ID,
        owner: address,
        kiosk: ID,
        price: u64,
        nft_type: String,
        ft_type: String,
    }

    /// Either an ask is created and immediately matched with a bid, or a bid
    /// is created and immediately matched with an ask.
    /// In both cases [`TradeFilledEvent`] is emitted.
    /// In such case, the property `trade_intermediate` is `Some`.
    ///
    /// If the NFT was bought directly (`buy_nft`), then
    /// the property `trade_intermediate` is `None`.
    struct TradeFilledEvent has copy, drop {
        buyer_kiosk: ID,
        buyer: address,
        nft: ID,
        orderbook: ID,
        price: u64,
        seller_kiosk: ID,
        seller: address,
        /// Is `None` if the NFT was bought directly (`buy_nft`)
        ///
        /// Is `Some` if the NFT was bought via `create_bid` or `create_ask`.
        trade_intermediate: Option<ID>,
        nft_type: String,
        ft_type: String,
    }

    /// Create a new `Orderbook<T, FT>`
    ///
    /// To implement specific logic in your smart contract, you can toggle the
    /// protection on specific actions. That will make them only accessible via
    /// witness protected methods.
    ///
    /// #### Panics
    ///
    /// Panics if `TransferPolicy<T>` is not an OriginByte policy.
    public fun new<T: key + store, FT>(
        _witness: DelegatedWitness<T>,
        transfer_policy: &TransferPolicy<T>,
        is_live: bool,
        protected_actions: ProtectedActions,
        ctx: &mut TxContext,
    ): Orderbook<T, FT> {
        assert!(
            transfer_request::is_originbyte(transfer_policy),
            ENotOriginBytePolicy,
        );

        new_(is_live, protected_actions, ctx)
    }

    /// Create an unprotected new `Orderbook<T, FT>`
    ///
    /// To implement specific logic in your smart contract, you can toggle the
    /// protection on specific actions. That will make them only accessible via
    /// witness protected methods.
    ///
    /// #### Panics
    ///
    /// Panics if `TransferPolicy<T>` is not an OriginByte policy.
    public fun new_unprotected<T: key + store, FT>(
        witness: DelegatedWitness<T>,
        transfer_policy: &TransferPolicy<T>,
        is_live: bool,
        ctx: &mut TxContext
    ): Orderbook<T, FT> {
        new<T, FT>(witness, transfer_policy, is_live, no_protection(), ctx)
    }

    /// Create a new unprotected `Orderbook<T, FT>` and immediately share it
    /// returning it's ID
    ///
    /// #### Panics
    ///
    /// Panics if `TransferPolicy<T>` is not an OriginByte policy.
    public fun create_unprotected<T: key + store, FT>(
        witness: DelegatedWitness<T>,
        transfer_policy: &TransferPolicy<T>,
        is_live: bool,
        ctx: &mut TxContext
    ): ID {
        let orderbook = new_unprotected<T, FT>(
            witness, transfer_policy, is_live, ctx,
        );
        let orderbook_id = object::id(&orderbook);
        share_object(orderbook);
        orderbook_id
    }

    /// Create a new unprotected `Orderbook<T, FT>` and immediately share it
    ///
    /// #### Panics
    ///
    /// Panics if `TransferPolicy<T>` is not an OriginByte policy.
    public entry fun init_unprotected<T: key + store, FT>(
        publisher: &Publisher,
        transfer_policy: &TransferPolicy<T>,
        is_live: bool,
        ctx: &mut TxContext,
    ) {
        let ob = new_unprotected<T, FT>(
            witness::from_publisher(publisher),
            transfer_policy,
            is_live,
            ctx,
        );

        share_object(ob);
    }

    /// Create a new `Orderbook<T, FT>` for external `TransferPolicy`
    ///
    /// To implement specific logic in your smart contract, you can toggle the
    /// protection on specific actions. That will make them only accessible via
    /// witness protected methods.
    ///
    /// #### Panics
    ///
    /// Panics if `TransferPolicy<T>` is an OriginByte policy.
    public fun new_external<T: key + store, FT>(
        transfer_policy: &TransferPolicy<T>,
        is_live: bool,
        protected_actions: ProtectedActions,
        ctx: &mut TxContext
    ): Orderbook<T, FT> {
        assert!(
            !transfer_request::is_originbyte(transfer_policy),
            ENotExternalPolicy,
        );

        new_<T, FT>(
            is_live,
            protected_actions,
            ctx,
        )
    }

    /// Create a new `Orderbook<T, FT>` for external `TransferPolicy` and
    /// immediately share it returning its ID
    ///
    /// To implement specific logic in your smart contract, you can toggle the
    /// protection on specific actions. That will make them only accessible via
    /// witness protected methods.
    ///
    /// #### Panics
    ///
    /// Panics if `TransferPolicy<T>` is an OriginByte policy.
    public fun create_external<T: key + store, FT>(
        transfer_policy: &TransferPolicy<T>,
        is_live: bool,
        protected_actions: ProtectedActions,
        ctx: &mut TxContext
    ): ID {
        let orderbook = new_external<T, FT>(transfer_policy, is_live, protected_actions, ctx);
        let orderbook_id = object::id(&orderbook);
        share_object(orderbook);
        orderbook_id
    }

    /// Create a new `Orderbook<T, FT>` for external `TransferPolicy` and
    /// immediately share it
    ///
    /// To implement specific logic in your smart contract, you can toggle the
    /// protection on specific actions. That will make them only accessible via
    /// witness protected methods.
    ///
    /// #### Panics
    ///
    /// Panics if `TransferPolicy<T>` is an OriginByte policy.
    public entry fun init_external<T: key + store, FT>(
        transfer_policy: &TransferPolicy<T>,
        is_live: bool,
        ctx: &mut TxContext
    ) {
        create_external<T, FT>(transfer_policy, is_live, no_protection(), ctx);
    }

    /// Create a new `Orderbook<T, FT>`
    fun new_<T: key + store, FT>(
        is_live: bool,
        protected_actions: ProtectedActions,
        ctx: &mut TxContext,
    ): Orderbook<T, FT> {
        let id = object::new(ctx);

        event::emit(OrderbookCreatedEvent {
            orderbook: object::uid_to_inner(&id),
            nft_type: type_name::into_string(type_name::get<T>()),
            ft_type: type_name::into_string(type_name::get<FT>()),
        });

        Orderbook<T, FT> {
            id,
            version: VERSION,
            tick_size: DEFAULT_TICK_SIZE,
            is_live,
            protected_actions,
            asks: critbit::new(ctx),
            bids: critbit::new(ctx),
        }
    }

    // === Create bid ===

    /// How many (`price`) fungible tokens should be taken from sender's wallet
    /// and put into the orderbook with the intention of exchanging them for
    /// 1 NFT.
    ///
    /// If the `price` is higher than the lowest ask requested price, then we
    /// execute a trade straight away.
    /// In such a case, a new shared object [`TradeIntermediate`] is created.
    /// Otherwise we add the bid to the orderbook's state.
    ///
    /// The client provides the Kiosk into which they wish to receive an NFT.
    ///
    /// * buyer kiosk must be in Originbyte ecosystem
    /// * sender must be owner of buyer kiosk
    /// * the buyer kiosk must allow deposits of `T`
    ///
    /// Returns `Some` with amount if matched.
    /// The amount is always equal or less than price.
    public fun create_bid<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Option<TradeInfo> {
        assert!(option::is_none(&book.protected_actions.create_bid), EActionNotPublic);
        create_bid_<T, FT>(book, buyer_kiosk, price, option::none(), wallet, ctx)
    }

    /// Same as [`create_bid`] but protected by
    /// [collection witness](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#witness-protected-actions).
    public fun create_bid_protected<T: key + store, FT>(
        trade_request: TradeRequest<CREATE_BID>,
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Option<TradeInfo> {
        confirm_create_bid(trade_request, book);
        create_bid_<T, FT>(book, buyer_kiosk, price, option::none(), wallet, ctx)
    }

    /// Same as [`create_bid`] but with a
    /// [commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).
    public fun create_bid_with_commission<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        price: u64,
        beneficiary: address,
        commission_ft: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Option<TradeInfo> {
        assert!(option::is_none(&book.protected_actions.create_bid), EActionNotPublic);
        let commission = trading::new_bid_commission(
            beneficiary,
            balance::split(coin::balance_mut(wallet), commission_ft),
        );
        create_bid_<T, FT>(
            book, buyer_kiosk, price, option::some(commission), wallet, ctx,
        )
    }

    /// Same as [`create_bid_protected`] but with a
    /// [commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).
    public fun create_bid_with_commission_protected<T: key + store, FT>(
        trade_request: TradeRequest<CREATE_BID>,
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        price: u64,
        beneficiary: address,
        commission_ft: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Option<TradeInfo> {
        confirm_create_bid(trade_request, book);

        let commission = trading::new_bid_commission(
            beneficiary,
            balance::split(coin::balance_mut(wallet), commission_ft),
        );
        create_bid_<T, FT>(
            book, buyer_kiosk, price, option::some(commission), wallet, ctx,
        )
    }

    // === Create bid - Market Order ===

    /// How many (`price`) fungible tokens should be taken from sender's wallet
    /// and put into the orderbook with the intention of exchanging them for
    /// 1 NFT.
    ///
    /// If the `price` is higher than the lowest ask requested price, then we
    /// execute a trade straight away.
    /// In such a case, a new shared object [`TradeIntermediate`] is created.
    /// If market order is not filled, then the tx fails.
    ///
    /// The client provides the Kiosk into which they wish to receive an NFT.
    ///
    /// * buyer kiosk must be in Originbyte ecosystem
    /// * sender must be owner of buyer kiosk
    /// * the buyer kiosk must allow deposits of `T`
    ///
    /// Returns the paid amount.
    public fun market_buy<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        wallet: &mut Coin<FT>,
        max_price: u64,
        ctx: &mut TxContext,
    ): TradeInfo {
        let is_matched_with_price = create_bid(
            book, buyer_kiosk, max_price, wallet, ctx,
        );
        assert!(
            option::is_some(&is_matched_with_price),
            EMarketOrderNotFilled,
        );
        option::destroy_some(is_matched_with_price)
    }

    // === Cancel position ===

    /// Cancel a bid owned by the sender at given price. If there are two bids
    /// with the same price, the one created later is cancelled.
    public entry fun cancel_bid<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        bid_price_level: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        cancel_bid_(book, bid_price_level, wallet, ctx)
    }

    /// To cancel an offer on a specific NFT, the client provides the price they
    /// listed it for.
    //
    // We could remove the NFT requested price from the argument, but then the
    // search for the ask would be O(n) instead of O(log n).
    //
    // This API might be improved in future as we use a different data
    // structure for the orderbook.
    public entry fun cancel_ask<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        nft_price_level: u64,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        cancel_ask_(book, seller_kiosk, nft_price_level, nft_id, ctx);
    }

    // === Create ask ===

    /// Offer given NFT to be traded for given (`requested_tokens`) tokens.
    /// If there exists a bid with higher offer than `requested_tokens`, then
    /// trade is immediately executed.
    /// In such a case, a new shared object [`TradeIntermediate`] is created.
    /// Otherwise we exclusively lock the NFT in the seller's kiosk for the
    /// orderbook to collect later.
    ///
    /// * the sender must be owner of kiosk
    /// * the kiosk must be in Originbyte universe
    /// * the NFT mustn't be listed anywhere else yet
    ///
    /// Returns `Some` with the amount if matched.
    /// Amount is always equal or more than `requested_tokens`.
    public fun create_ask<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        requested_tokens: u64,
        nft_id: ID,
        ctx: &mut TxContext,
    ): Option<TradeInfo> {
        assert!(option::is_none(&book.protected_actions.create_ask), EActionNotPublic);
        create_ask_<T, FT>(
            book, seller_kiosk, requested_tokens, option::none(), nft_id, ctx
        )
    }

    /// Same as [`create_ask`] but protected by
    /// [collection witness](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#witness-protected-actions).
    public fun create_ask_protected<T: key + store, FT>(
        trade_request: TradeRequest<CREATE_ASK>,
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        requested_tokens: u64,
        nft_id: ID,
        ctx: &mut TxContext,
    ): Option<TradeInfo> {
        confirm_create_ask(trade_request, book);

        create_ask_<T, FT>(
            book, seller_kiosk, requested_tokens, option::none(), nft_id, ctx
        )
    }

    /// Same as [`create_ask`] but with a
    /// [commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).
    public fun create_ask_with_commission<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        requested_tokens: u64,
        nft_id: ID,
        beneficiary: address,
        commission_ft: u64,
        ctx: &mut TxContext,
    ): Option<TradeInfo> {
        assert!(option::is_none(&book.protected_actions.create_ask), EActionNotPublic);
        assert!(commission_ft < requested_tokens, ECommissionTooHigh);

        let commission = trading::new_ask_commission(
            beneficiary, commission_ft,
        );
        create_ask_<T, FT>(
            book,
            seller_kiosk,
            requested_tokens,
            option::some(commission),
            nft_id,
            ctx,
        )
    }

    /// Same as [`create_ask_protected`] but with a
    /// [commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).
    ///
    /// #### Panics
    /// The `commission` arg must be less than `requested_tokens`.
    public fun create_ask_with_commission_protected<T: key + store, FT>(
        trade_request: TradeRequest<CREATE_ASK>,
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        requested_tokens: u64,
        nft_id: ID,
        beneficiary: address,
        commission_ft: u64,
        ctx: &mut TxContext,
    ): Option<TradeInfo> {
        confirm_create_ask(trade_request, book);

        assert!(commission_ft < requested_tokens, ECommissionTooHigh);

        let commission = trading::new_ask_commission(
            beneficiary,
            commission_ft,
        );
        create_ask_<T, FT>(
            book,
            seller_kiosk,
            requested_tokens,
            option::some(commission),
            nft_id,
            ctx,
        )
    }

    // === Create ask - Market Order ===

    /// Offer given NFT to be traded for given (`requested_tokens`) tokens.
    /// If there exists a bid with higher offer than `requested_tokens`, then
    /// trade is immediately executed.
    /// In such a case, a new shared object [`TradeIntermediate`] is created.
    /// Otherwise we fail the transaction.
    ///
    /// * the sender must be owner of kiosk
    /// * the kiosk must be in Originbyte universe
    /// * the NFT mustn't be listed anywhere else yet
    ///
    /// Returns the paid amount for the NFT.
    public fun market_sell<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        min_price: u64,
        nft_id: ID,
        ctx: &mut TxContext,
    ): TradeInfo {
        let is_matched_with_price = create_ask(
            book,
            seller_kiosk,
            min_price,
            nft_id,
            ctx,
        );
        assert!(
            option::is_some(&is_matched_with_price),
            EMarketOrderNotFilled,
        );
        option::destroy_some(is_matched_with_price)
    }

    // === Edit listing ===

    /// Removes the old ask and creates a new one with the same NFT.
    /// Two events are emitted at least:
    /// Firstly, we always emit `AskRemovedEvent` for the old ask.
    /// Then either `AskCreatedEvent` or `TradeFilledEvent`.
    /// Depends on whether the ask is filled immediately or not.
    public entry fun edit_ask<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        old_price: u64,
        nft_id: ID,
        new_price: u64,
        ctx: &mut TxContext,
    ) {
        assert!(option::is_none(&book.protected_actions.create_ask), EActionNotPublic);

        let commission = cancel_ask_(
            book, seller_kiosk, old_price, nft_id, ctx,
        );
        create_ask_(book, seller_kiosk, new_price, commission, nft_id, ctx);
    }

    /// Cancels the old bid and creates a new one with new price.
    public entry fun edit_bid<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        old_price: u64,
        new_price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        assert!(option::is_none(&book.protected_actions.create_bid), EActionNotPublic);
        edit_bid_(book, buyer_kiosk, old_price, new_price, wallet, ctx);
    }

    // === Buy NFT ===

    /// To buy a specific NFT listed in the orderbook, the client provides the
    /// price for which the NFT is listed.
    ///
    /// The NFT is transferred from the seller's Kiosk to the buyer's Kiosk.
    ///
    /// In this case, it's important to provide both the price and NFT ID to
    /// avoid actions such as offering an NFT for a really low price and then
    /// quickly changing the price to a higher one.
    ///
    /// The provided [`Coin`] wallet is used to pay for the NFT.
    ///
    /// This endpoint does not create a new [`TradeIntermediate`], rather
    /// performs he transfer straight away.
    ///
    /// See the documentation for `nft_protocol::transfer_request` to understand
    /// how to deal with the returned [`TransferRequest`] type.
    ///
    /// * both kiosks must be in the OB universe
    public fun buy_nft<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        nft_id: ID,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        assert!(option::is_none(&book.protected_actions.buy_nft), EActionNotPublic);
        buy_nft_<T, FT>(
            book, seller_kiosk, buyer_kiosk, nft_id, price, wallet, ctx
        )
    }

    /// Same as [`buy_nft`] but protected by
    /// [collection witness](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#witness-protected-actions).
    public fun buy_nft_protected<T: key + store, FT>(
        trade_request: TradeRequest<BUY_NFT>,
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        nft_id: ID,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        confirm_buy_nft(trade_request, book);

        buy_nft_<T, FT>(
            book, seller_kiosk, buyer_kiosk, nft_id, price, wallet, ctx
        )
    }

    // === Finish trade ===

    /// When a bid is created and there's an ask with a lower price, then the
    /// trade cannot be resolved immediately.
    /// That's because we don't know the `Kiosk` ID up front in OB.
    /// Conversely, when an ask is created, we don't know the `Kiosk` ID of the
    /// buyer as the best bid can change at any time.
    ///
    /// Therefore, orderbook creates [`TradeIntermediate`] which then has to be
    /// permissionlessly resolved via this endpoint.
    ///
    /// See the documentation for `nft_protocol::transfer_request` to understand
    /// how to deal with the returned [`TransferRequest`] type.
    ///
    /// * the buyer's kiosk must allow permissionless deposits of `T` unless
    /// buyer is the signer
    public fun finish_trade<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        trade_id: ID,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        finish_trade_<T, FT>(book, trade_id, seller_kiosk, buyer_kiosk, ctx)
    }

    public fun finish_trade_if_kiosks_match<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        trade_id: ID,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ): Option<TransferRequest<T>> {
        let t = trade(book, trade_id);
        let kiosks_match = &t.seller_kiosk == &object::id(seller_kiosk)
            && &t.buyer_kiosk == &object::id(buyer_kiosk);

        if (kiosks_match) {
            option::some(
                finish_trade(book, trade_id, seller_kiosk, buyer_kiosk, ctx),
            )
        } else {
            option::none()
        }
    }

    // === Manage orderbook ===

    /// Change tick size of orderbook
    ///
    /// #### Panics
    ///
    /// Panics if provided `Publisher` did not publish type `T`
    public entry fun change_tick_size<T: key + store, FT>(
        publisher: &Publisher,
        orderbook: &mut Orderbook<T, FT>,
        tick_size: u64,
    ) {
        change_tick_size_with_witness(
            witness::from_publisher(publisher), orderbook, tick_size,
        )
    }

    /// Change tick size of orderbook
    public fun change_tick_size_with_witness<T: key + store, FT>(
        _witness: DelegatedWitness<T>,
        orderbook: &mut Orderbook<T, FT>,
        tick_size: u64,
    ) {
        assert!(tick_size < orderbook.tick_size, 0);
        orderbook.tick_size = tick_size;
    }

    /// Change protection level of an existing orderbook
    ///
    /// #### Panics
    ///
    /// Panics if provided `Publisher` did not publish type `T`
    public fun set_protection<T: key + store, FT>(
        publisher: &Publisher,
        orderbook: &mut Orderbook<T, FT>,
        buy_nft: Option<Policy<BUY_NFT>>,
        create_ask: Option<Policy<CREATE_ASK>>,
        create_bid: Option<Policy<CREATE_BID>>,
    ) {
        set_protection_with_witness<T, FT>(
            witness::from_publisher(publisher),
            orderbook,
            buy_nft,
            create_ask,
            create_bid,
        )
    }

    // TODO: RETHINK Protection endpoints
    /// Change protection level of an existing orderbook
    public fun set_protection_with_witness<T: key + store, FT>(
        _witness: DelegatedWitness<T>,
        orderbook: &mut Orderbook<T, FT>,
        buy_nft: Option<Policy<BUY_NFT>>,
        create_ask: Option<Policy<CREATE_ASK>>,
        create_bid: Option<Policy<CREATE_BID>>,
    ) {
        set_protection_(
            orderbook,
            buy_nft,
            create_ask,
            create_bid,
        )
    }

    /// Helper method to protect all endpoints thus disabling trading
    ///
    /// #### Panics
    ///
    /// Panics if provided `Publisher` did not publish type `T`
    public entry fun disable_trading<T: key + store, FT>(
        publisher: &Publisher,
        orderbook: &mut Orderbook<T, FT>,
    ) {
        assert!(package::from_package<T>(publisher), ENotAuthorized);

        orderbook.is_live = false;
    }

    /// Helper method to unprotect all endpoints thus enabling trading
    ///
    /// #### Panics
    ///
    /// Panics if provided `Publisher` did not publish type `T`
    public entry fun enable_trading<T: key + store, FT>(
        publisher: &Publisher,
        orderbook: &mut Orderbook<T, FT>,
    ) {
        assert!(package::from_package<T>(publisher), ENotAuthorized);

        orderbook.is_live = true;
    }

    public entry fun set_start_time<T: key + store, FT>(
        publisher: &Publisher,
        orderbook: &mut Orderbook<T, FT>,
        start_time: u64,
    ) {
        set_start_time_with_witness(
            witness::from_publisher(publisher), orderbook, start_time
        )
    }

    public fun set_start_time_with_witness<T: key + store, FT>(
        _witness: DelegatedWitness<T>,
        orderbook: &mut Orderbook<T, FT>,
        start_time: u64,
    ) {
        if (df::exists_(&mut orderbook.id, TimeLockDfKey {})) {
            let time = df::borrow_mut(&mut orderbook.id, TimeLockDfKey {});
            *time = start_time
        } else {
            df::add(&mut orderbook.id, TimeLockDfKey {}, start_time);
        };
    }

    /// Method for permissionlessly unlock trading whenever the opening
    /// time starts.
    ///
    /// #### Panics
    ///
    /// Panics if the current time provided by the Clock's timestamp is
    /// less than the opening time.
    public entry fun enable_trading_permissionless<T: key + store, FT>(
        orderbook: &mut Orderbook<T, FT>,
        clock: &Clock
    ) {
        assert!(df::exists_(&orderbook.id, TimeLockDfKey {}), EOrderbookNotTimeLocked);
        let start_time = df::borrow(&orderbook.id, TimeLockDfKey {});

        assert!(clock::timestamp_ms(clock) >= *start_time, EOrderbookTimeLocked);

        orderbook.is_live = true;
    }

    /// Settings where all endpoints can be called as entry point functions.
    public fun no_protection(): ProtectedActions {
        ProtectedActions {
            buy_nft: option::none(),
            create_ask: option::none(),
            create_bid: option::none(),
        }
    }

    public fun confirm_buy_nft<T: key + store, FT>(
        trade_request: TradeRequest<BUY_NFT>,
        book: &Orderbook<T, FT>,
    ) {
        assert!(option::is_some(&book.protected_actions.buy_nft), EActionNotProtected);

        let policy = option::borrow(&book.protected_actions.buy_nft);
        trade_request::confirm(trade_request, policy);
    }

    public fun confirm_create_ask<T: key + store, FT>(
        trade_request: TradeRequest<CREATE_ASK>,
        book: &Orderbook<T, FT>,
    ) {
        assert!(option::is_some(&book.protected_actions.create_ask), EActionNotProtected);

        let policy = option::borrow(&book.protected_actions.create_ask);
        trade_request::confirm(trade_request, policy);
    }

    public fun confirm_create_bid<T: key + store, FT>(
        trade_request: TradeRequest<CREATE_BID>,
        book: &Orderbook<T, FT>,
    ) {
        assert!(option::is_some(&book.protected_actions.create_bid), EActionNotProtected);

        let policy = option::borrow(&book.protected_actions.create_bid);
        trade_request::confirm(trade_request, policy);
    }

    // === Getters ===

    public fun borrow_bids<T: key + store, FT>(
        book: &Orderbook<T, FT>,
    ): &CritbitTree<vector<Bid<FT>>> {
        &book.bids
    }

    public fun bid_offer<FT>(bid: &Bid<FT>): &Balance<FT> {
        &bid.offer
    }

    public fun bid_owner<FT>(bid: &Bid<FT>): address {
        bid.owner
    }

    public fun borrow_asks<T: key + store, FT>(
        book: &Orderbook<T, FT>,
    ): &CritbitTree<vector<Ask>> {
        &book.asks
    }

    public fun ask_price(ask: &Ask): u64 {
        ask.price
    }

    public fun ask_owner(ask: &Ask): address {
        ask.owner
    }

    public fun is_create_ask_protected<T: key + store, FT>(
        orderbook: &Orderbook<T, FT>,
    ): bool {
        option::is_some(&orderbook.protected_actions.create_ask)
    }

    public fun is_create_bid_protected<T: key + store, FT>(
        orderbook: &Orderbook<T, FT>,
    ): bool {
        option::is_some(&orderbook.protected_actions.create_bid)
    }

    public fun is_buy_nft_protected<T: key + store, FT>(
        orderbook: &Orderbook<T, FT>,
    ): bool {
        option::is_some(&orderbook.protected_actions.buy_nft)
    }

    public fun trade_id(trade: &TradeInfo): ID {
        trade.trade_id
    }

    public fun trade_price(trade: &TradeInfo): u64 {
        trade.trade_price
    }

    public fun trade<T: key + store, FT>(
        book: &Orderbook<T, FT>,
        trade_id: ID,
    ): &TradeIntermediate<T, FT> {
        df::borrow(&book.id, TradeIntermediateDfKey { trade_id })
    }

    // === Priv fns ===

    /// * buyer kiosk must be in Originbyte ecosystem
    /// * sender must be owner of buyer kiosk
    /// * kiosk must allow permissionless deposits of `T`
    ///
    /// Either `TradeIntermediate` is shared, or bid is added to the state.
    ///
    /// Returns `Some` with amount if matched.
    /// The amount is always equal or less than price.
    fun create_bid_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        price: u64,
        bid_commission: Option<trading::BidCommission<FT>>,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Option<TradeInfo> {
        assert_version_and_upgrade(book);
        assert_tick_level(price, book.tick_size);

        ob_kiosk::assert_is_ob_kiosk(buyer_kiosk);
        ob_kiosk::assert_permission(buyer_kiosk, ctx);
        ob_kiosk::assert_can_deposit_permissionlessly<T>(buyer_kiosk);

        let buyer = tx_context::sender(ctx);
        let buyer_kiosk_id = object::id(buyer_kiosk);

        let asks = &mut book.asks;

        // if map empty, then lowest ask price is 0
        let (can_be_filled, lowest_ask_price) = if (critbit::is_empty(asks)) {
            (false, 0)
        } else {
            let (lowest_ask_price, _) = critbit::min_leaf(asks);

            (lowest_ask_price <= price, lowest_ask_price)
        };

        if (can_be_filled) {
            let trade_id = match_buy_with_ask_(
                book,
                lowest_ask_price,
                buyer_kiosk_id,
                bid_commission,
                wallet,
                ctx,
            );

            option::some(TradeInfo {
                trade_price: lowest_ask_price,
                trade_id,
            })
        } else {
            insert_bid_(
                book,
                buyer_kiosk_id,
                price,
                bid_commission,
                wallet,
                buyer,
            );

            option::none()
        }
    }

    fun insert_bid_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        buyer_kiosk_id: ID,
        price: u64,
        bid_commission: Option<trading::BidCommission<FT>>,
        wallet: &mut Coin<FT>,
        buyer: address,
    ) {
        event::emit(BidCreatedEvent {
            orderbook: object::id(book),
            owner: buyer,
            price,
            kiosk: buyer_kiosk_id,
            nft_type: type_name::into_string(type_name::get<T>()),
            ft_type: type_name::into_string(type_name::get<FT>()),
        });

        // take the amount that the sender wants to create a bid with from their
        // wallet
        let bid_offer = balance::split(coin::balance_mut(wallet), price);

        let order = Bid {
            offer: bid_offer,
            owner: buyer,
            kiosk: buyer_kiosk_id,
            commission: bid_commission,
        };

        let (has_key, price_level_idx) =
            critbit::find_leaf(&book.bids, price);

        if (has_key) {
            vector::push_back(
                critbit::borrow_mut_leaf_by_index(
                    &mut book.bids, price_level_idx,
                ),
                order
            );
        } else {
            critbit::insert_leaf(
                &mut book.bids, price, vector::singleton(order),
            );
        };
    }

    fun match_buy_with_ask_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        lowest_ask_price: u64,
        buyer_kiosk_id: ID,
        bid_commission: Option<trading::BidCommission<FT>>,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): ID {
        let asks = &mut book.asks;
        let buyer = tx_context::sender(ctx);
        let price_level =
            critbit::borrow_mut_leaf_by_key(asks, lowest_ask_price);

        // remove zeroth for FIFO, must exist due to `can_be_filled`
        let ask = vector::remove(price_level, 0);

        if (vector::length(price_level) == 0) {
            // to simplify impl, always delete empty price level
            let price_level =
                critbit::remove_leaf_by_key(asks, lowest_ask_price);
            vector::destroy_empty(price_level);
        };

        let Ask {
            price: _,
            owner: seller,
            nft_id,
            kiosk_id,
            commission: ask_commission,
        } = ask;

        assert!(kiosk_id != buyer_kiosk_id, ECannotTradeWithSelf);

        // see also `finish_trade` entry point
        let trade_intermediate = TradeIntermediate<T, FT> {
            buyer_kiosk: buyer_kiosk_id,
            buyer,
            nft_id,
            seller,
            seller_kiosk: kiosk_id,
            commission: ask_commission,
            id: object::new(ctx),
            paid: balance::split(coin::balance_mut(wallet), lowest_ask_price),
        };
        let trade_intermediate_id = object::id(&trade_intermediate);

        // Add TradeIntermediate as a dynamic field to the Orderbook
        df::add(
            &mut book.id,
            TradeIntermediateDfKey { trade_id: trade_intermediate_id },
            trade_intermediate
        );

        event::emit(TradeFilledEvent {
            orderbook: object::id(book),
            buyer_kiosk: buyer_kiosk_id,
            buyer,
            nft: nft_id,
            price: lowest_ask_price,
            seller_kiosk: kiosk_id,
            seller,
            trade_intermediate: option::some(trade_intermediate_id),
            nft_type: type_name::into_string(type_name::get<T>()),
            ft_type: type_name::into_string(type_name::get<FT>()),
        });

        trading::transfer_bid_commission(&mut bid_commission, ctx);
        option::destroy_none(bid_commission);

        trade_intermediate_id
    }

    fun match_sell_with_bid_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        highest_bid_price: u64,
        seller_kiosk_id: ID,
        ask_commission: Option<trading::AskCommission>,
        nft_id: ID,
        ctx: &mut TxContext,
    ): ID {
        let bids = &mut book.bids;
        let seller = tx_context::sender(ctx);
        let price_level = critbit::borrow_mut_leaf_by_key(bids, highest_bid_price);

        // remove zeroth for FIFO, must exist due to `can_be_filled`
        let bid = vector::remove(price_level, 0);

        if (vector::length(price_level) == 0) {
            // to simplify impl, always delete empty price level
            let price_level =
                critbit::remove_leaf_by_key(bids, highest_bid_price);
            vector::destroy_empty(price_level);
        };

        let Bid {
            owner: buyer,
            offer: bid_offer,
            kiosk: buyer_kiosk_id,
            commission: bid_commission,
        } = bid;
        assert!(buyer_kiosk_id != seller_kiosk_id, ECannotTradeWithSelf);
        let paid = balance::value(&bid_offer);

        // see also `finish_trade` entry point
        let trade_intermediate = TradeIntermediate<T, FT> {
            id: object::new(ctx),
            commission: ask_commission,
            seller,
            buyer,
            buyer_kiosk: buyer_kiosk_id,
            seller_kiosk: seller_kiosk_id,
            nft_id: nft_id,
            paid: bid_offer,
        };
        let trade_intermediate_id = object::id(&trade_intermediate);

        // Add TradeIntermediate as a dynamic field to the Orderbook
        df::add(
            &mut book.id,
            TradeIntermediateDfKey { trade_id: trade_intermediate_id },
            trade_intermediate
        );

        event::emit(TradeFilledEvent {
            orderbook: object::id(book),
            buyer_kiosk: buyer_kiosk_id,
            buyer,
            nft: nft_id,
            price: paid,
            seller_kiosk: seller_kiosk_id,
            seller,
            trade_intermediate: option::some(trade_intermediate_id),
            nft_type: type_name::into_string(type_name::get<T>()),
            ft_type: type_name::into_string(type_name::get<FT>()),
        });

        trading::transfer_bid_commission(&mut bid_commission, ctx);
        option::destroy_none(bid_commission);

        trade_intermediate_id
    }

    /// Removes bid from the state and returns the commission which contains
    /// tokens that the buyer was meant to pay as a commission on a successful
    /// trade.
    fun cancel_bid_except_commission<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        bid_price_level: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Option<trading::BidCommission<FT>> {
        assert_version_and_upgrade(book);

        let sender = tx_context::sender(ctx);
        let bids = &mut book.bids;

        let (has_key, price_level_idx) =
            critbit::find_leaf(bids, bid_price_level);

        assert!(has_key, EOrderDoesNotExist);

        let price_level =
            critbit::borrow_mut_leaf_by_index(bids, price_level_idx);

        let index = 0;
        let bids_count = vector::length(price_level);
        while (bids_count > index) {
            let bid = vector::borrow(price_level, index);
            if (bid.owner == sender) {
                break
            };

            index = index + 1;
        };
        // we iterated over all bids and didn't find one where owner is sender
        assert!(index < bids_count, EOrderOwnerMustBeSender);

        let Bid { offer, owner: _owner, commission, kiosk } =
            vector::remove(price_level, index);
        balance::join(coin::balance_mut(wallet), offer);

        if (vector::length(price_level) == 0) {
            // to simplify impl, always delete empty price level
            let price_level = critbit::remove_leaf_by_index(bids, price_level_idx);
            vector::destroy_empty(price_level);
        };

        event::emit(BidClosedEvent {
            owner: sender,
            kiosk,
            orderbook: object::id(book),
            price: bid_price_level,
            nft_type: type_name::into_string(type_name::get<T>()),
            ft_type: type_name::into_string(type_name::get<FT>()),
        });

        commission
    }

    fun cancel_bid_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        bid_price_level: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        assert_version_and_upgrade(book);

        let commission =
            cancel_bid_except_commission(book, bid_price_level, wallet, ctx);

        if (option::is_some(&commission)) {
            let (cut, _beneficiary) =
                trading::destroy_bid_commission(option::extract(&mut commission));
            balance::join(
                coin::balance_mut(wallet),
                cut,
            );
        };
        option::destroy_none(commission);
    }

    fun edit_bid_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        old_price: u64,
        new_price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let commission =
            cancel_bid_except_commission(book, old_price, wallet, ctx);

        create_bid_(book, buyer_kiosk, new_price, commission, wallet, ctx);
    }

    /// * the sender must be owner of kiosk
    /// * the kiosk must be in Originbyte universe
    /// * NFT is exclusively listed in the kiosk
    ///
    /// Returns `Some` with the amount if matched.
    /// Amount is always equal or more than `requested_tokens`.
    fun create_ask_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        price: u64,
        ask_commission: Option<trading::AskCommission>,
        nft_id: ID,
        ctx: &mut TxContext,
    ): Option<TradeInfo> {
        assert_version_and_upgrade(book);
        assert_tick_level(price, book.tick_size);

        // we cannot transfer the NFT straight away because we don't know
        // the buyers kiosk at the point of sending the tx

        // will fail if not OB kiosk
        ob_kiosk::auth_exclusive_transfer(seller_kiosk, nft_id, &book.id, ctx);

        // prevent listing of NFTs which don't belong to the collection
        ob_kiosk::assert_nft_type<T>(seller_kiosk, nft_id);

        let seller = tx_context::sender(ctx);
        let seller_kiosk_id = object::id(seller_kiosk);

        let bids = &mut book.bids;

        // if map empty, then highest bid ask price is 0
        let (can_be_filled, highest_bid_price) = if (critbit::is_empty(bids)) {
            (false, 0)
        } else {
            let (highest_bid_price, _) = critbit::max_leaf(bids);

            (highest_bid_price >= price, highest_bid_price)
        };

        if (can_be_filled) {
            let trade_id = match_sell_with_bid_(
                book,
                highest_bid_price,
                seller_kiosk_id,
                ask_commission,
                nft_id,
                ctx,
            );

            option::some(TradeInfo {
                trade_price: highest_bid_price,
                trade_id,
            })
        } else {
            insert_ask_(
                book,
                object::id(seller_kiosk),
                price,
                ask_commission,
                nft_id,
                seller,
            );

            option::none()
        }
    }

    /// * cancels the exclusive listing
    fun cancel_ask_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        kiosk: &mut Kiosk,
        nft_price_level: u64,
        nft_id: ID,
        ctx: &mut TxContext,
    ): Option<trading::AskCommission> {
        assert_version_and_upgrade(book);
        let sender = tx_context::sender(ctx);

        let Ask {
            owner,
            price: _,
            nft_id,
            kiosk_id: _,
            commission,
        } = remove_ask(&mut book.asks, nft_price_level, nft_id);

        event::emit(AskClosedEvent {
            price: nft_price_level,
            orderbook: object::id(book),
            nft: nft_id,
            owner: sender,
            nft_type: type_name::into_string(type_name::get<T>()),
            ft_type: type_name::into_string(type_name::get<FT>()),
        });

        assert!(owner == sender, EOrderOwnerMustBeSender);
        ob_kiosk::remove_auth_transfer(kiosk, nft_id, &book.id);

        commission
    }

    fun buy_nft_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        nft_id: ID,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        assert_version_and_upgrade(book);

        let buyer = tx_context::sender(ctx);

        let Ask {
            owner: seller,
            price: _,
            nft_id: _,
            kiosk_id: _,
            commission: maybe_commission,
        } = remove_ask(&mut book.asks, price, nft_id);

        event::emit(TradeFilledEvent {
            orderbook: object::id(book),
            buyer_kiosk: object::id(buyer_kiosk),
            buyer,
            nft: nft_id,
            price,
            seller_kiosk: object::id(seller_kiosk),
            seller,
            trade_intermediate: option::none(),
            nft_type: type_name::into_string(type_name::get<T>()),
            ft_type: type_name::into_string(type_name::get<FT>()),
        });

        let bid_offer = balance::split(coin::balance_mut(wallet), price);

        // Sell-side commission gets transferred to the sell-side intermediary
        trading::transfer_ask_commission<FT>(
            &mut maybe_commission, &mut bid_offer, ctx,
        );
        option::destroy_none(maybe_commission);

        let transfer_req = if (kiosk::is_locked(seller_kiosk, nft_id)) {
            ob_kiosk::transfer_locked_nft<T>(
                seller_kiosk,
                buyer_kiosk,
                nft_id,
                &book.id,
                ctx,
            )
        } else {
            ob_kiosk::transfer_delegated<T>(
                seller_kiosk,
                buyer_kiosk,
                nft_id,
                &book.id,
                price,
                ctx,
            )
        };

        transfer_request::set_paid<T, FT>(&mut transfer_req, bid_offer, seller);
        ob_kiosk::set_transfer_request_auth(&mut transfer_req, &Witness {});

        transfer_req
    }

    fun finish_trade_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        trade_id: ID,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        assert_version_and_upgrade(book);

        let trade = df::remove(
            &mut book.id, TradeIntermediateDfKey { trade_id }
        );

        let TradeIntermediate<T, FT> {
            id,
            nft_id,
            seller_kiosk: _,
            paid,
            seller,
            buyer: _,
            buyer_kiosk: expected_buyer_kiosk_id,
            commission: maybe_commission,
        } = trade;

        object::delete(id);

        let price = balance::value(&paid);

        assert!(
            expected_buyer_kiosk_id == object::id(buyer_kiosk), EKioskIdMismatch,
        );

        // Sell-side commission gets transferred to the sell-side intermediary
        trading::transfer_ask_commission<FT>(&mut maybe_commission, &mut paid, ctx);

        let transfer_req = if (kiosk::is_locked(seller_kiosk, nft_id)) {
            ob_kiosk::transfer_locked_nft<T>(
                seller_kiosk,
                buyer_kiosk,
                nft_id,
                &book.id,
                ctx,
            )
        } else {
            ob_kiosk::transfer_delegated<T>(
                seller_kiosk,
                buyer_kiosk,
                nft_id,
                &book.id,
                price,
                ctx,
            )
        };

        transfer_request::set_paid<T, FT>(
            &mut transfer_req, paid, seller,
        );
        ob_kiosk::set_transfer_request_auth(&mut transfer_req, &Witness {});

        transfer_req
    }

    /// Finds an ask of a given NFT advertized for the given price. Removes it
    /// from the asks vector preserving order and returns it.
    fun remove_ask(asks: &mut CritbitTree<vector<Ask>>, price: u64, nft_id: ID): Ask {
        let (has_key, price_level_idx) = critbit::find_leaf(asks, price);
        assert!(has_key, EOrderDoesNotExist);

        let price_level = critbit::borrow_mut_leaf_by_index(asks, price_level_idx);

        let index = 0;
        let asks_count = vector::length(price_level);
        while (asks_count > index) {
            let ask = vector::borrow(price_level, index);
            // on the same price level, we search for the specified NFT
            if (nft_id == ask.nft_id) {
                break
            };

            index = index + 1;
        };

        assert!(index < asks_count, EOrderDoesNotExist);

        let ask = vector::remove(price_level, index);

        if (vector::length(price_level) == 0) {
            // to simplify impl, always delete empty price level
            let price_level = critbit::remove_leaf_by_index(asks, price_level_idx);
            vector::destroy_empty(price_level);
        };

        ask
    }

    fun check_tick_level(price: u64, tick_size: u64): bool {
        price >= tick_size
    }

    /// Change protection level of an existing orderbook
    fun set_protection_<T: key + store, FT>(
        orderbook: &mut Orderbook<T, FT>,
        buy_nft: Option<Policy<BUY_NFT>>,
        create_ask: Option<Policy<CREATE_ASK>>,
        create_bid: Option<Policy<CREATE_BID>>,
    ) {
        assert_version_and_upgrade(orderbook);
        assert_not_under_migration(orderbook);

        if (option::is_some(&buy_nft)) {
            assert!(option::is_none(&orderbook.protected_actions.buy_nft), 0); // Already has policy

            option::fill(&mut orderbook.protected_actions.buy_nft, option::extract(&mut buy_nft));
        };

        if (option::is_some(&create_ask)) {
            assert!(option::is_none(&orderbook.protected_actions.create_ask), 0); // Already has policy

            option::fill(&mut orderbook.protected_actions.create_ask, option::extract(&mut create_ask));
        };

        if (option::is_some(&create_bid)) {
            assert!(option::is_none(&orderbook.protected_actions.create_bid), 0); // Already has policy

            option::fill(&mut orderbook.protected_actions.create_bid, option::extract(&mut create_bid));
        };

        option::destroy_none(buy_nft);
        option::destroy_none(create_ask);
        option::destroy_none(create_bid);
    }

    fun insert_ask_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        seller_kiosk_id: ID,
        price: u64,
        ask_commission: Option<trading::AskCommission>,
        nft_id: ID,
        seller: address,
    ) {
        event::emit(AskCreatedEvent {
            nft: nft_id,
            orderbook: object::id(book),
            owner: seller,
            price,
            kiosk: seller_kiosk_id,
            nft_type: type_name::into_string(type_name::get<T>()),
            ft_type: type_name::into_string(type_name::get<FT>()),
        });

        let ask = Ask {
            price,
            nft_id,
            kiosk_id: seller_kiosk_id,
            owner: seller,
            commission: ask_commission,
        };
        // store the Ask object
        let (has_key, price_level_idx) =
            critbit::find_leaf(&book.asks, price);

        if (has_key) {
            vector::push_back(
                critbit::borrow_mut_leaf_by_index(
                    &mut book.asks, price_level_idx,
                ),
                ask,
            );
        } else {
            critbit::insert_leaf(&mut book.asks, price, vector::singleton(ask));
        };
    }

    // === Liquidity Migration ===

    public fun start_migration_from_v1<T: key + store, FT>(
        _witness: DelegatedWitness<T>,
        book_v2: &mut Orderbook<T, FT>,
        book_v1_id: ID,
    ) {
        book_v2.is_live = false;
        df::add(&mut book_v2.id, UnderMigrationFromDfKey {}, book_v1_id);
    }

    public fun finish_migration_from_v1<T: key + store, FT>(
        _witness: DelegatedWitness<T>,
        book: &mut Orderbook<T, FT>,
    ) {
        book.is_live = true;
        let _: ID = df::remove(&mut book.id, UnderMigrationFromDfKey {});
    }

    public fun migrate_bid_v1<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        buyer_kiosk_id: ID,
        price: u64,
        bid_commission: Option<trading::BidCommission<FT>>,
        wallet: &mut Coin<FT>,
        buyer: address,
        book_v1_uid: &UID,
    ) {
        assert_under_migration(book);
        assert_orderbook_v1(book, book_v1_uid);

        insert_bid_(
            book,
            buyer_kiosk_id,
            price,
            bid_commission,
            wallet,
            buyer,
        );
    }

    public fun migrate_ask_v1<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        price: u64,
        ask_commission: Option<trading::AskCommission>,
        nft_id: ID,
        seller: address,
        book_v1_uid: &UID,
    ) {
        assert_under_migration(book);
        assert_orderbook_v1(book, book_v1_uid);

        // will fail if not OB kiosk
        ob_kiosk::delegate_auth(seller_kiosk, nft_id, book_v1_uid, object::uid_to_address(&book.id));

        insert_ask_(
            book,
            object::id(seller_kiosk),
            price,
            ask_commission,
            nft_id,
            seller,
        );
    }


    // === Upgradeability ===

    fun assert_version<T: key + store, FT>(self: &Orderbook<T, FT>) {
        assert!(self.version == VERSION, EWrongVersion);
    }

    fun assert_version_and_upgrade<T: key + store, FT>(self: &mut Orderbook<T, FT>) {
        if (self.version < VERSION) {
            self.version = VERSION;
        };
        assert_version(self);
    }

    // Only the publisher of type `T` can upgrade
    entry fun migrate_as_creator<T: key + store, FT>(
        self: &mut Orderbook<T, FT>,
        pub: &Publisher,
    ) {
        assert!(package::from_package<T>(pub), 0);
        self.version = VERSION;
    }

    entry fun migrate_as_pub<T: key + store, FT>(
        self: &mut Orderbook<T, FT>,
        pub: &Publisher,
    ) {
        assert!(package::from_package<LIQUIDITY_LAYER>(pub), 0);
        self.version = VERSION;
    }

    // === Assertions ===

    fun assert_tick_level(price: u64, tick_size: u64) {
        assert!(check_tick_level(price, tick_size), 0);
    }

    fun assert_under_migration<T: key + store, FT>(self: &Orderbook<T, FT>) {
        assert!(df::exists_(&self.id, UnderMigrationFromDfKey {}), ENotUnderMigration);
    }

    fun assert_not_under_migration<T: key + store, FT>(self: &Orderbook<T, FT>) {
        assert!(!df::exists_(&self.id, UnderMigrationFromDfKey {}), EUnderMigration);
    }

    fun assert_orderbook_v1<T: key + store, FT>(book_v2: &Orderbook<T, FT>, book_v1_uid: &UID) {
        let book_v1_id = df::borrow(&book_v2.id, UnderMigrationFromDfKey {});

        assert!(object::uid_to_inner(book_v1_uid) == *book_v1_id, EIncorrectOrderbookV1);
    }

    #[test]
    fun test_tick_size_enforcement() {
        // 1 SUI == 1_000_000_000 MIST
        // 0.1 SUI == 100_000_000 MIST
        // 0.01 SUI == 10_000_000 MIST
        // 0.001 SUI == 1_000_000 MIST
        // const DEFAULT_TICK_SIZE: u64 = 1_000_000;

        assert!(check_tick_level(1, DEFAULT_TICK_SIZE) == false, 0);
        assert!(check_tick_level(10, DEFAULT_TICK_SIZE) == false, 0);
        assert!(check_tick_level(100, DEFAULT_TICK_SIZE) == false, 0);
        assert!(check_tick_level(1_000, DEFAULT_TICK_SIZE) == false, 0);
        assert!(check_tick_level(10_000, DEFAULT_TICK_SIZE) == false, 0);
        assert!(check_tick_level(100_000, DEFAULT_TICK_SIZE) == false, 0);

        assert!(check_tick_level(1_000_000, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(10_000_000, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(100_000_000, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(1_000_000_000, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(10_000_000_000, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(100_000_000_000, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(1_000_000_000_000, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(10_000_000_000_000, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(100_000_000_000_000, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(1_000_000_000_000_000, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(10_000_000_000_000_000, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(100_000_000_000_000_000, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(1_000_000_000_000_000_000, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(10_000_000_000_000_000_000, DEFAULT_TICK_SIZE) == true, 0);
    }

    #[test]
    fun test_tick_size_enforcement_with() {
        // 1 SUI == 1_000_000_000 MIST
        // 0.1 SUI == 100_000_000 MIST
        // 0.01 SUI == 10_000_000 MIST
        // 0.001 SUI == 1_000_000 MIST
        // const DEFAULT_TICK_SIZE: u64 = 1_000_000;


        assert!(check_tick_level(7, DEFAULT_TICK_SIZE) == false, 0);
        assert!(check_tick_level(77, DEFAULT_TICK_SIZE) == false, 0);
        assert!(check_tick_level(777, DEFAULT_TICK_SIZE) == false, 0);
        assert!(check_tick_level(7_777, DEFAULT_TICK_SIZE) == false, 0);
        assert!(check_tick_level(77_777, DEFAULT_TICK_SIZE) == false, 0);
        assert!(check_tick_level(777_777, DEFAULT_TICK_SIZE) == false, 0);

        assert!(check_tick_level(7_777_777, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(77_777_777, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(777_777_777, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(7_777_777_777, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(77_777_777_777, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(777_777_777_777, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(7_777_777_777_777, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(70_777_777_777_777, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(700_777_777_777_777, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(7_777_777_777_777_777, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(77_777_777_777_777_777, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(777_777_777_777_777_777, DEFAULT_TICK_SIZE) == true, 0);
        assert!(check_tick_level(7_777_777_777_777_777_777, DEFAULT_TICK_SIZE) == true, 0);
        // assert!(check_tick_level(70_000_000_000_000_000_000, DEFAULT_TICK_SIZE) == true, 0);
    }
}
