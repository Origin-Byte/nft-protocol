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
module nft_protocol::orderbook {
    // TODO: eviction of lowest bid/highest ask on OOM

    use nft_protocol::ob_kiosk;
    use nft_protocol::ob_transfer_request::{Self, TransferRequest};
    use nft_protocol::trading;
    use nft_protocol::witness::Witness as DelegatedWitness;
    use originmate::crit_bit_u64::{Self as crit_bit, CB as CBTree};
    use std::ascii::String;
    use std::option::{Self, Option};
    use std::type_name;
    use std::vector;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::event;
    use sui::kiosk::{Self, Kiosk};
    use sui::object::{Self, ID, UID};
    use sui::transfer::share_object;
    use sui::tx_context::{Self, TxContext};

    // === Errors ===

    /// A protected action was called without a witness.
    /// This action can only be called from an implementation in the collection
    /// smart contract.
    const EActionNotPublic: u64 = 1;

    /// Cannot make sell commission higher than listed price
    const ECommissionTooHigh: u64 = 2;

    /// The NFT lives in a kiosk which also wanted to buy it
    const ECannotTradeWithSelf: u64 = 3;

    /// User doesn't own this order
    const EOrderOwnerMustBeSender: u64 = 4;

    /// Expected different kiosk
    const EKioskIdMismatch: u64 = 5;

    /// No order matches the given price level or ownership level
    const EOrderDoesNotExist: u64 = 6;

    /// Market orders fail with this error if they cannot be filled
    const EMarketOrderNotFilled: u64 = 6;

    // === Structs ===

    /// Add this witness type to allowlists via
    /// `transfer_allowlist::insert_authority` to allow orderbook trades with
    /// that allowlist.
    struct Witness has drop {}

    /// A critbit order book implementation. Contains two ordered trees:
    /// 1. bids ASC
    /// 2. asks DESC
    struct Orderbook<phantom T: key + store, phantom FT> has key {
        id: UID,
        /// Actions which have a flag set to true can only be called via a
        /// witness protected implementation.
        protected_actions: WitnessProtectedActions,
        /// An ask order stores an NFT to be traded. The price associated with
        /// such an order is saying:
        ///
        /// > for this NFT, I want to receive at least this amount of FT.
        asks: CBTree<vector<Ask>>,
        /// A bid order stores amount of tokens of type "B"(id) to trade. A bid
        /// order is saying:
        ///
        /// > for any NFT in this collection, I will spare this many tokens
        bids: CBTree<vector<Bid<FT>>>,
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
    struct WitnessProtectedActions has store, drop {
        buy_nft: bool,
        create_ask: bool,
        create_bid: bool,
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
    struct TradeIntermediate<phantom T, phantom FT> has key {
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
    ): Option<u64> {
        assert!(!book.protected_actions.create_bid, EActionNotPublic);
        create_bid_<T, FT>(book, buyer_kiosk, price, option::none(), wallet, ctx)
    }

    /// Same as [`create_bid`] but protected by
    /// [collection witness](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#witness-protected-actions).
    public fun create_bid_protected<T: key + store, FT>(
        _witness: DelegatedWitness<T>,
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Option<u64> {
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
    ): Option<u64> {
        assert!(!book.protected_actions.create_bid, EActionNotPublic);
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
        _witness: DelegatedWitness<T>,
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        price: u64,
        beneficiary: address,
        commission_ft: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Option<u64> {
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
    ): u64 {
        let is_matched_with_price = create_bid(
            book,
            buyer_kiosk,
            max_price,
            wallet,
            ctx,
        );
        assert!(option::is_some(&is_matched_with_price), EMarketOrderNotFilled);
        option::destroy_some(is_matched_with_price)
    }

    // === Cancel position ===

    /// Cancel a bid owned by the sender at given price. If there are two bids
    /// with the same price, the one created later is cancelled.
    public fun cancel_bid<T: key + store, FT>(
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
    public fun cancel_ask<T: key + store, FT>(
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
    ): Option<u64> {
        assert!(!book.protected_actions.create_ask, EActionNotPublic);
        create_ask_<T, FT>(
            book, seller_kiosk, requested_tokens, option::none(), nft_id, ctx
        )
    }

    /// Same as [`create_ask`] but protected by
    /// [collection witness](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#witness-protected-actions).
    public fun create_ask_protected<T: key + store, FT>(
        _witness: DelegatedWitness<T>,
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        requested_tokens: u64,
        nft_id: ID,
        ctx: &mut TxContext,
    ): Option<u64> {
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
    ): Option<u64> {
        assert!(!book.protected_actions.create_ask, EActionNotPublic);
        assert!(commission_ft < requested_tokens, ECommissionTooHigh);

        let commission = trading::new_ask_commission(
            beneficiary, commission_ft,
        );
        create_ask_<T, FT>(
            book, seller_kiosk, requested_tokens, option::some(commission), nft_id, ctx
        )
    }

    /// Same as [`create_ask_protected`] but with a
    /// [commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).
    ///
    /// #### Panics
    /// The `commission` arg must be less than `requested_tokens`.
    public fun create_ask_with_commission_protected<T: key + store, FT>(
        _witness: DelegatedWitness<T>,
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        requested_tokens: u64,
        nft_id: ID,
        beneficiary: address,
        commission_ft: u64,
        ctx: &mut TxContext,
    ): Option<u64> {
        assert!(commission_ft < requested_tokens, ECommissionTooHigh);

        let commission = trading::new_ask_commission(
            beneficiary,
            commission_ft,
        );
        create_ask_<T, FT>(
            book, seller_kiosk, requested_tokens, option::some(commission), nft_id, ctx
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
    ): u64 {
        let is_matched_with_price = create_ask(
            book,
            seller_kiosk,
            min_price,
            nft_id,
            ctx,
        );
        assert!(option::is_some(&is_matched_with_price), EMarketOrderNotFilled);
        option::destroy_some(is_matched_with_price)
    }

    // === Edit listing ===

    /// Removes the old ask and creates a new one with the same NFT.
    /// Two events are emitted at least:
    /// Firstly, we always emit `AskRemovedEvent` for the old ask.
    /// Then either `AskCreatedEvent` or `TradeFilledEvent`.
    /// Depends on whether the ask is filled immediately or not.
    public fun edit_ask<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        old_price: u64,
        nft_id: ID,
        new_price: u64,
        ctx: &mut TxContext,
    ) {
        assert!(!book.protected_actions.create_ask, EActionNotPublic);

        let commission = cancel_ask_(book, seller_kiosk, old_price, nft_id, ctx);
        create_ask_(book, seller_kiosk, new_price, commission, nft_id, ctx);
    }

    /// Cancels the old bid and creates a new one with new price.
    public fun edit_bid<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        old_price: u64,
        new_price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        assert!(!book.protected_actions.create_bid, EActionNotPublic);
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
        assert!(!book.protected_actions.buy_nft, EActionNotPublic);
        buy_nft_<T, FT>(
            book, seller_kiosk, buyer_kiosk, nft_id, price, wallet, ctx
        )
    }

    /// Same as [`buy_nft`] but protected by
    /// [collection witness](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#witness-protected-actions).
    public fun buy_nft_protected<T: key + store, FT>(
        _witness: DelegatedWitness<T>,
        book: &mut Orderbook<T, FT>,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        nft_id: ID,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
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
        book: &Orderbook<T, FT>,
        trade: &mut TradeIntermediate<T, FT>,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        finish_trade_<T, FT>(book, trade, seller_kiosk, buyer_kiosk, ctx)
    }

    // === Create orderbook ===

    /// NFTs of type `T` to be traded, and `F`ungible `T`oken to be
    /// quoted for an NFT in such a collection.
    ///
    /// By default, an orderbook has no restriction on actions, ie. all can be
    /// called with public functions.
    ///
    /// To implement specific logic in your smart contract, you can toggle the
    /// protection on specific actions. That will make them only accessible via
    /// witness protected methods.
    public fun new<T: key + store, FT>(
        protected_actions: WitnessProtectedActions,
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
            protected_actions,
            asks: crit_bit::empty(),
            bids: crit_bit::empty(),
        }
    }

    /// Returns a new orderbook without any protection, ie. all endpoints can
    /// be called as entry points.
    public fun new_unprotected<T: key + store, FT>(ctx: &mut TxContext): Orderbook<T, FT> {
        new<T, FT>(no_protection(), ctx)
    }

    public fun new_with_protected_actions<T: key + store, FT>(
        protected_actions: WitnessProtectedActions,
        ctx: &mut TxContext,
    ): Orderbook<T, FT> {
        new<T, FT>(protected_actions, ctx)
    }

    /// Creates a new empty orderbook as a shared object.
    ///
    /// All actions can be called as entry points.
    public fun create_unprotected<T: key + store, FT>(ctx: &mut TxContext) {
        let ob = new<T, FT>(no_protection(), ctx);
        share_object(ob);
    }

    public fun share<T: key + store, FT>(ob: Orderbook<T, FT>) {
        share_object(ob);
    }

    /// Settings where all endpoints can be called as entry point functions.
    public fun no_protection(): WitnessProtectedActions {
        custom_protection(false, false, false)
    }

    /// Select which actions are witness protected (true).
    public fun custom_protection(
        buy_nft: bool,
        create_ask: bool,
        create_bid: bool,
    ): WitnessProtectedActions {
        WitnessProtectedActions {
            buy_nft,
            create_ask,
            create_bid,
        }
    }

    /// Change protection level of an existing orderbook.
    public fun set_protection<T: key + store, FT>(
        _witness: DelegatedWitness<T>,
        ob: &mut Orderbook<T, FT>,
        protected_actions: WitnessProtectedActions,
    ) {
        ob.protected_actions = protected_actions;
    }

    // === Getters ===

    public fun borrow_bids<T: key + store, FT>(
        book: &Orderbook<T, FT>,
    ): &CBTree<vector<Bid<FT>>> { &book.bids }

    public fun bid_offer<FT>(bid: &Bid<FT>): &Balance<FT> { &bid.offer }

    public fun bid_owner<FT>(bid: &Bid<FT>): address { bid.owner }

    public fun borrow_asks<T: key + store, FT>(
        book: &Orderbook<T, FT>,
    ): &CBTree<vector<Ask>> { &book.asks }

    public fun ask_price(ask: &Ask): u64 { ask.price }

    public fun ask_owner(ask: &Ask): address { ask.owner }

    public fun protected_actions<T: key + store, FT>(
        book: &Orderbook<T, FT>,
    ): &WitnessProtectedActions { &book.protected_actions }

    public fun is_create_ask_protected(
        protected_actions: &WitnessProtectedActions
    ): bool { protected_actions.create_ask }

    public fun is_create_bid_protected(
        protected_actions: &WitnessProtectedActions
    ): bool { protected_actions.create_bid }

    public fun is_buy_nft_protected(
        protected_actions: &WitnessProtectedActions
    ): bool { protected_actions.buy_nft }

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
    ): Option<u64> {
        ob_kiosk::assert_is_ob_kiosk(buyer_kiosk);
        ob_kiosk::assert_permission(buyer_kiosk, ctx);
        ob_kiosk::assert_can_deposit_permissionlessly<T>(buyer_kiosk);

        let buyer = tx_context::sender(ctx);
        let buyer_kiosk_id = object::id(buyer_kiosk);

        let asks = &mut book.asks;

        // if map empty, then lowest ask price is 0
        let (can_be_filled, lowest_ask_price) = if (crit_bit::is_empty(asks)) {
            (false, 0)
        } else {
            let lowest_ask_price = crit_bit::min_key(asks);

            (lowest_ask_price <= price, lowest_ask_price)
        };

        if (can_be_filled) {
            match_buy_with_ask_(
                book,
                lowest_ask_price,
                buyer_kiosk_id,
                bid_commission,
                wallet,
                ctx,
            );

            option::some(lowest_ask_price)
        } else {
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

            if (crit_bit::has_key(&book.bids, price)) {
                vector::push_back(
                    crit_bit::borrow_mut(&mut book.bids, price),
                    order
                );
            } else {
                crit_bit::insert(
                    &mut book.bids,
                    price,
                    vector::singleton(order),
                );
            };

            option::none()
        }
    }

    fun match_buy_with_ask_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        lowest_ask_price: u64,
        buyer_kiosk_id: ID,
        bid_commission: Option<trading::BidCommission<FT>>,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let asks = &mut book.asks;
        let buyer = tx_context::sender(ctx);
        let price_level = crit_bit::borrow_mut(asks, lowest_ask_price);

        let ask = vector::remove(
            price_level,
            // remove zeroth for FIFO, must exist due to `can_be_filled`
            0,
        );
        if (vector::length(price_level) == 0) {
            // to simplify impl, always delete empty price level
            vector::destroy_empty(crit_bit::pop(asks, lowest_ask_price));
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
        share_object(trade_intermediate);

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
    }

    fun match_sell_with_bid_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        highest_bid_price: u64,
        seller_kiosk_id: ID,
        ask_commission: Option<trading::AskCommission>,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        let bids = &mut book.bids;
        let seller = tx_context::sender(ctx);
        let price_level = crit_bit::borrow_mut(bids, highest_bid_price);

        let bid = vector::remove(
            price_level,
            // remove zeroth for FIFO, must exist due to `can_be_filled`
            0,
        );
        if (vector::length(price_level) == 0) {
            // to simplify impl, always delete empty price level
            vector::destroy_empty(crit_bit::pop(bids, highest_bid_price));
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
        share_object(trade_intermediate);

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
        let sender = tx_context::sender(ctx);
        let bids = &mut book.bids;

        assert!(crit_bit::has_key(bids, bid_price_level), EOrderDoesNotExist);
        let price_level = crit_bit::borrow_mut(bids, bid_price_level);

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
    ): Option<u64> {

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
        let (can_be_filled, highest_bid_price) = if (crit_bit::is_empty(bids)) {
            (false, 0)
        } else {
            let highest_bid_price = crit_bit::max_key(bids);

            (highest_bid_price >= price, highest_bid_price)
        };

        if (can_be_filled) {
            match_sell_with_bid_(
                book,
                highest_bid_price,
                seller_kiosk_id,
                ask_commission,
                nft_id,
                ctx,
            );

            option::some(highest_bid_price)
        } else {
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
            if (crit_bit::has_key(&book.asks, price)) {
                vector::push_back(
                    crit_bit::borrow_mut(&mut book.asks, price), ask
                );
            } else {
                crit_bit::insert(&mut book.asks, price, vector::singleton(ask));
            };

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

        trading::transfer_ask_commission<FT>(
            &mut maybe_commission, &mut bid_offer, ctx,
        );
        option::destroy_none(maybe_commission);

        let transfer_req = ob_kiosk::transfer_delegated<T>(
            seller_kiosk,
            buyer_kiosk,
            nft_id,
            &book.id,
            price,
            ctx,
        );
        ob_transfer_request::set_paid<T, FT>(&mut transfer_req, bid_offer, seller);
        ob_kiosk::set_transfer_request_auth(&mut transfer_req, &Witness {});

        transfer_req
    }

    fun finish_trade_<T: key + store, FT>(
        book: &Orderbook<T, FT>,
        trade: &mut TradeIntermediate<T, FT>,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        let TradeIntermediate {
            id: _,
            nft_id,
            seller_kiosk: _,
            paid,
            seller,
            buyer: _,
            buyer_kiosk: expected_buyer_kiosk_id,
            commission: maybe_commission,
        } = trade;

        let price = balance::value(paid);

        assert!(
            *expected_buyer_kiosk_id == object::id(buyer_kiosk), EKioskIdMismatch,
        );

        trading::transfer_ask_commission<FT>(maybe_commission, paid, ctx);

        let transfer_req = if (kiosk::is_locked(seller_kiosk, *nft_id)) {
            ob_kiosk::transfer_locked_nft<T>(
                seller_kiosk,
                buyer_kiosk,
                *nft_id,
                &book.id,
                ctx,
            )
        } else {
            ob_kiosk::transfer_delegated<T>(
                seller_kiosk,
                buyer_kiosk,
                *nft_id,
                &book.id,
                price,
                ctx,
            )
        };

        ob_transfer_request::set_paid<T, FT>(
            &mut transfer_req, balance::withdraw_all(paid), *seller,
        );
        ob_kiosk::set_transfer_request_auth(&mut transfer_req, &Witness {});

        transfer_req
    }

    /// Finds an ask of a given NFT advertized for the given price. Removes it
    /// from the asks vector preserving order and returns it.
    fun remove_ask(asks: &mut CBTree<vector<Ask>>, price: u64, nft_id: ID): Ask {
        assert!(crit_bit::has_key(asks, price), EOrderDoesNotExist);

        let price_level = crit_bit::borrow_mut(asks, price);

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

        vector::remove(price_level, index)
    }
}
