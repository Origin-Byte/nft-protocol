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
/// - trade both native and 3rd party collections.
///
/// # Other resources
/// - https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook
/// - https://origin-byte.github.io/ob.html
module nft_protocol::orderbook {
    // TODO: protocol toll
    // TODO: eviction of lowest bid/highest ask on OOM
    // TODO: do we allow anyone to create an OB for any collection?
    // TODO: settings to skip royalty settlement (witness protected)

    use nft_protocol::ob_kiosk::{Self, OwnerCap};
    use nft_protocol::transfer_allowlist::Allowlist;
    use nft_protocol::utils;
    use nft_protocol::trading::{
        AskCommission,
        BidCommission,
        destroy_bid_commission,
        new_ask_commission,
        new_bid_commission,
        transfer_bid_commission,
    };

    use originmate::crit_bit_u64::{Self as crit_bit, CB as CBTree};

    use std::ascii::String;
    use std::option::{Self, Option};
    use std::type_name;
    use std::vector;

    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::kiosk::Kiosk;
    use sui::event;
    use sui::object::{Self, ID, UID};
    use sui::transfer::{public_transfer, share_object, public_share_object};
    use sui::tx_context::{Self, TxContext};

    // === Errors ===

    /// A protected action was called without a witness.
    /// This action can only be called from an implementation in the collection
    /// smart contract.
    const EACTION_NOT_PUBLIC: u64 = 0;

    /// # of nfts and # of requested prices must match
    const EINPUT_LENGTH_MISMATCH: u64 = 1;

    /// Cannot make sell commission higher than listed price
    const ECOMMISSION_TOO_HIGH: u64 = 2;

    /// Must list at least one NFT
    const EEMPTY_INPUT: u64 = 3;

    /// The NFT lives in a kiosk which also wanted to buy it
    const ECANNOT_TRADE_WITH_SELF: u64 = 4;

    /// User doesn't own this order
    const EORDER_OWNER_MUST_BE_SENDER: u64 = 5;

    /// Expected different kiosk
    const EKIOSK_ID_MISMATCH: u64 = 6;

    /// No order matches the given price level or ownership level
    const EORDER_DOES_NOT_EXIST: u64 = 7;

    // === Structs ===

    /// Witness used to authenticate witness protected endpoints
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
    struct WitnessProtectedActions has store, drop {
        buy_nft: bool,
        cancel_ask: bool,
        cancel_bid: bool,
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
        commission: Option<BidCommission<FT>>,
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
        commission: Option<AskCommission>,
    }

    /// `TradeIntermediate` is made a shared object and can be called
    /// permissionlessly.
    struct TradeIntermediate<phantom T, phantom FT> has key {
        id: UID,
        nft_id: ID,
        seller: address,
        seller_kiosk: ID,
        buyer: address,
        buyer_kiosk: ID,
        paid: Balance<FT>,
        commission: Option<AskCommission>,
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
    public entry fun create_bid<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        assert!(!book.protected_actions.create_bid, EACTION_NOT_PUBLIC);
        create_bid_<T, FT>(book, buyer_kiosk, price, option::none(), wallet, ctx)
    }

    /// Same as [`create_bid`] but protected by
    /// [collection witness](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#witness-protected-actions).
    public fun create_bid_protected<W: drop, T: key + store, FT>(
        _witness: W,
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        utils::assert_same_module_as_witness<T, W>();

        create_bid_<T, FT>(book, buyer_kiosk, price, option::none(), wallet, ctx)
    }

    /// Same as [`create_bid`] but creates a new kiosk for the sender first
    public entry fun create_kiosk_and_bid<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let (buyer_kiosk, owner_cap) = ob_kiosk::new(ctx);
        create_bid<T, FT>(book, &mut buyer_kiosk, price, wallet, ctx);

        ob_kiosk::transfer_cap_to_owner(
            owner_cap,
            &buyer_kiosk,
            tx_context::sender(ctx)
        );
        public_share_object(buyer_kiosk);
    }

    /// Same as [`create_bid`] but with a
    /// [commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).
    public entry fun create_bid_with_commission<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        price: u64,
        beneficiary: address,
        commission_ft: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        assert!(!book.protected_actions.create_bid, EACTION_NOT_PUBLIC);
        let commission = new_bid_commission(
            beneficiary,
            balance::split(coin::balance_mut(wallet), commission_ft),
        );
        create_bid_<T, FT>(
            book, buyer_kiosk, price, option::some(commission), wallet, ctx,
        )
    }

    /// Same as [`create_bid_protected`] but with a
    /// [commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).
    public fun create_bid_with_commission_protected<W: drop, T: key + store, FT>(
        _witness: W,
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        price: u64,
        beneficiary: address,
        commission_ft: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        utils::assert_same_module_as_witness<T, W>();

        let commission = new_bid_commission(
            beneficiary,
            balance::split(coin::balance_mut(wallet), commission_ft),
        );
        create_bid_<T, FT>(
            book, buyer_kiosk, price, option::some(commission), wallet, ctx,
        )
    }

    /// Same as [`create_kiosk_and_bid`] but with a
    /// [commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).
    public entry fun create_kiosk_and_bid_with_commission<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        price: u64,
        beneficiary: address,
        commission_ft: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let (buyer_kiosk, owner_cap) = ob_kiosk::new(ctx);
        create_bid_with_commission(
            book,
            &mut buyer_kiosk,
            price,
            beneficiary,
            commission_ft,
            wallet,
            ctx,
        );

        ob_kiosk::transfer_cap_to_owner(
            owner_cap,
            &buyer_kiosk,
            tx_context::sender(ctx)
        );
        public_share_object(buyer_kiosk);
    }

    // === Cancel bid ===

    /// Cancel a bid owned by the sender at given price. If there are two bids
    /// with the same price, the one created later is cancelled.
    public entry fun cancel_bid<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        bid_price_level: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        assert!(!book.protected_actions.cancel_bid, EACTION_NOT_PUBLIC);
        cancel_bid_(book, bid_price_level, wallet, ctx)
    }

    /// Same as [`cancel_bid`] but protected by
    /// [collection witness](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#witness-protected-actions).
    public fun cancel_bid_protected<W: drop, T: key + store, FT>(
        _witness: W,
        book: &mut Orderbook<T, FT>,
        bid_price_level: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        utils::assert_same_module_as_witness<T, W>();
        cancel_bid_(book, bid_price_level, wallet, ctx)
    }

    // === Create ask ===

    /// Offer given NFT to be traded for given (`requested_tokens`) tokens.
    /// If there exists a bid with higher offer than `requested_tokens`, then
    /// trade is immediately executed.
    /// In such a case, a new shared object [`TradeIntermediate`] is created.
    /// Otherwise the transfer cap is stored in the orderbook.
    public entry fun create_ask<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        owner_cap: &OwnerCap,
        requested_tokens: u64,
        nft_id: ID,
        seller_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        assert!(!book.protected_actions.create_ask, EACTION_NOT_PUBLIC);
        create_ask_<T, FT>(
            book, owner_cap, requested_tokens, option::none(), nft_id, seller_kiosk, ctx
        )
    }

    /// Provide list of NFTs and corresponding prices (index # match.)
    ///
    /// The NFTs must be deposited in the seller's kiosk.
    ///
    /// #### Panics
    /// * If `nfts` and `prices` have different lengths
    /// * If `nfts` is empty
    public entry fun list_multiple_nfts<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        owner_cap: &OwnerCap,
        nfts: vector<ID>,
        prices: vector<u64>,
        seller_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        assert!(
            vector::length(&nfts) == vector::length(&prices),
            EINPUT_LENGTH_MISMATCH,
        );
        assert!(vector::length(&nfts) > 0, EEMPTY_INPUT);

        let i = 0;
        while (i < vector::length(&nfts)) {
            let nft = vector::borrow(&nfts, i);
            let price = vector::borrow(&prices, i);

            create_ask(book, owner_cap, *price, *nft, seller_kiosk, ctx);

            i = i + 1;
        }
    }

    /// 1. Deposits an NFT to kiosk
    /// 2. Calls [`list_nft`]
    ///
    /// The type `T` in case of OB collections is `Nft<T>`.
    /// In case of generic collections `C == T`.
    ///
    /// This endpoint is useful mainly for generic collections, because NFTs
    /// of OB _usually_ live in a kiosk in the first place.
    public entry fun deposit_and_list_nft<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        nft: T,
        requested_tokens: u64,
        owner_cap: &OwnerCap,
        seller_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        let nft_id = object::id(&nft);
        ob_kiosk::deposit_as_owner(seller_kiosk, owner_cap, nft);
        create_ask(book, owner_cap, requested_tokens, nft_id, seller_kiosk, ctx);
    }

    /// 1. Creates a new kiosk for the sender
    /// 2. Calls [`deposit_and_list_nft`]
    public entry fun create_kiosk_and_deposit_and_list_nft<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        nft: T,
        requested_tokens: u64,
        ctx: &mut TxContext,
    ) {
        let seller = tx_context::sender(ctx);
        let (seller_kiosk, owner_cap) = ob_kiosk::new(ctx);

        deposit_and_list_nft(
            book,
            nft,
            requested_tokens,
            &owner_cap,
            &mut seller_kiosk,
            ctx,
        );

        ob_kiosk::transfer_cap_to_owner(
            owner_cap,
            &seller_kiosk,
            seller
        );
        public_share_object(seller_kiosk);
    }

    /// Same as [`create_ask`] but protected by
    /// [collection witness](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#witness-protected-actions).
    public fun create_ask_protected<W: drop, T: key + store, FT>(
        _witness: W,
        book: &mut Orderbook<T, FT>,
        owner_cap: &OwnerCap,
        requested_tokens: u64,
        nft_id: ID,
        seller_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        utils::assert_same_module_as_witness<T, W>();

        create_ask_<T, FT>(
            book, owner_cap, requested_tokens, option::none(), nft_id, seller_kiosk, ctx
        )
    }

    /// Same as [`create_ask`] but with a
    /// [commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).
    public entry fun create_ask_with_commission<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        owner_cap: &OwnerCap,
        requested_tokens: u64,
        nft_id: ID,
        beneficiary: address,
        commission: u64,
        seller_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        assert!(!book.protected_actions.create_ask, EACTION_NOT_PUBLIC);
        assert!(commission < requested_tokens, ECOMMISSION_TOO_HIGH);

        let commission = new_ask_commission(
            beneficiary,
            commission,
        );
        create_ask_<T, FT>(
            book, owner_cap, requested_tokens, option::none(), nft_id, seller_kiosk, ctx
        )
    }

    /// Same as [`list_multiple_nfts`] but with a
    /// [commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).
    ///
    /// The commission is a vector which is associated with the NFTs by index.
    ///
    /// #### Panics
    /// If the commissions length does not match the NFTs length.
    public entry fun list_multiple_nfts_with_commission<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        nfts: vector<ID>,
        prices: vector<u64>,
        beneficiary: address,
        commissions: vector<u64>,
        owner_cap: &OwnerCap,
        seller_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        assert!(
            vector::length(&nfts) == vector::length(&prices),
            EINPUT_LENGTH_MISMATCH,
        );
        assert!(
            vector::length(&nfts) == vector::length(&commissions),
            EINPUT_LENGTH_MISMATCH,
        );
        assert!(vector::length(&nfts) > 0, EEMPTY_INPUT);

        let i = 0;
        while (i < vector::length(&nfts)) {
            let nft = vector::borrow(&nfts, i);
            let price = vector::borrow(&prices, i);
            let commission = vector::borrow(&commissions, i);

            create_ask_with_commission(
                book,
                owner_cap,
                *price,
                *nft,
                beneficiary,
                *commission,
                seller_kiosk,
                ctx,
            );

            i = i + 1;
        }
    }

    /// Same as [`deposit_and_list_nft_with`] but with a
    /// [commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).
    public entry fun deposit_and_list_nft_with_commission<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        nft: T,
        requested_tokens: u64,
        owner_cap: &OwnerCap,
        beneficiary: address,
        commission: u64,
        seller_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        let nft_id = object::id(&nft);
        ob_kiosk::deposit_as_owner(seller_kiosk, owner_cap, nft);

        create_ask_with_commission(
                book,
                owner_cap,
                requested_tokens,
                nft_id,
                beneficiary,
                commission,
                seller_kiosk,
                ctx,
            );
    }

    /// Same as [`create_kiosk_and_deposit_and_list_nft`] but with a
    /// [commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).
    public entry fun create_kiosk_and_deposit_and_list_nft_with_commission<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        nft: T,
        requested_tokens: u64,
        beneficiary: address,
        commission: u64,
        ctx: &mut TxContext,
    ) {
        let seller = tx_context::sender(ctx);
        let (seller_kiosk, owner_cap) = ob_kiosk::new(ctx);

        deposit_and_list_nft_with_commission(
            book,
            nft,
            requested_tokens,
            &owner_cap,
            beneficiary,
            commission,
            &mut seller_kiosk,
            ctx,
        );

        ob_kiosk::transfer_cap_to_owner(
            owner_cap,
            &seller_kiosk,
            seller
        );
        public_share_object(seller_kiosk);
    }

    /// Same as [`create_ask_protected`] but with a
    /// [commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).
    ///
    /// #### Panics
    /// The `commission` arg must be less than `requested_tokens`.
    public fun create_ask_with_commission_protected<W: drop, T: key + store, FT>(
        _witness: W,
        book: &mut Orderbook<T, FT>,
        owner_cap: &OwnerCap,
        requested_tokens: u64,
        nft_id: ID,
        beneficiary: address,
        commission: u64,
        seller_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        utils::assert_same_module_as_witness<T, W>();
        assert!(commission < requested_tokens, ECOMMISSION_TOO_HIGH);

        let commission = new_ask_commission(
            beneficiary,
            commission,
        );
        create_ask_<T, FT>(
            book, owner_cap, requested_tokens, option::none(), nft_id, seller_kiosk, ctx
        )
    }

    // === Cancel ask ===

    /// To cancel an offer on a specific NFT, the client provides the price they
    /// listed it for.
    /// The [`TransferCap`] object is transferred back to the tx sender.
    //
    // We could remove the NFT requested price from the argument, but then the
    // search for the ask would be O(n) instead of O(log n).
    //
    // This API might be improved in future as we use a different data
    // structure for the orderbook.
    public entry fun cancel_ask<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        nft_price_level: u64,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        assert!(!book.protected_actions.cancel_ask, EACTION_NOT_PUBLIC);
        cancel_ask_(book, nft_price_level, nft_id, ctx);
    }

    /// Same as [`cancel_ask`] but protected by
    /// [collection witness](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#witness-protected-actions).
    public fun cancel_ask_protected<W: drop, T: key + store, FT>(
        _witness: W,
        book: &mut Orderbook<T, FT>,
        nft_price_level: u64,
        nft_id: ID,
        ctx: &mut TxContext,
    ) {
        utils::assert_same_module_as_witness<T, W>();
        cancel_ask_(book, nft_price_level, nft_id, ctx);
    }

    // === Edit listing ===

    /// Removes the old ask and creates a new one with the same NFT.
    /// Two events are emitted at least:
    /// Firstly, we always emit `AskRemovedEvent` for the old ask.
    /// Then either `AskCreatedEvent` or `TradeFilledEvent`.
    /// Depends on whether the ask is filled immediately or not.
    public entry fun edit_ask<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        owner_cap: &OwnerCap,
        old_price: u64,
        nft_id: ID,
        new_price: u64,
        seller_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        assert!(!book.protected_actions.cancel_ask, EACTION_NOT_PUBLIC);
        assert!(!book.protected_actions.create_ask, EACTION_NOT_PUBLIC);

        let commission = cancel_ask_(book, old_price, nft_id, ctx);
        create_ask_(book, owner_cap, new_price, commission, nft_id, seller_kiosk, ctx);
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
        assert!(!book.protected_actions.cancel_bid, EACTION_NOT_PUBLIC);
        assert!(!book.protected_actions.create_bid, EACTION_NOT_PUBLIC);

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
    /// The whitelist is used to check if the orderbook is authorized to trade
    /// the collection at all.
    ///
    /// This endpoint does not create a new [`TradeIntermediate`], rather
    /// performs he transfer straight away.
    public entry fun buy_nft<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        nft_id: ID,
        price: u64,
        wallet: &mut Coin<FT>,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        allowlist: &Allowlist,
        ctx: &mut TxContext,
    ) {
        assert!(!book.protected_actions.buy_nft, EACTION_NOT_PUBLIC);
        buy_nft_<T, FT>(
            book, nft_id, price, wallet, seller_kiosk, buyer_kiosk, allowlist, ctx
        )
    }

    /// 1. Creates a new [`Kiosk`] for the sender
    /// 2. Buys the NFT into this new kiosk
    /// 3. Shares the kiosk and gives the owner cap to sender
    public entry fun create_kiosk_and_buy_nft<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        nft_id: ID,
        price: u64,
        wallet: &mut Coin<FT>,
        seller_kiosk: &mut Kiosk,
        allowlist: &Allowlist,
        ctx: &mut TxContext,
    ) {
        let buyer = tx_context::sender(ctx);
        let (buyer_kiosk, owner_cap) = ob_kiosk::new(ctx);

        assert!(!book.protected_actions.buy_nft, EACTION_NOT_PUBLIC);
        buy_nft_<T, FT>(
            book, nft_id, price, wallet, seller_kiosk, &mut buyer_kiosk, allowlist, ctx
        );

        ob_kiosk::transfer_cap_to_owner(
            owner_cap,
            &buyer_kiosk,
            buyer
        );
        public_share_object(buyer_kiosk);
    }

    /// Same as [`buy_nft`] but protected by
    /// [collection witness](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#witness-protected-actions).
    public fun buy_nft_protected<W: drop, T: key + store, FT>(
        _witness: W,
        book: &mut Orderbook<T, FT>,
        nft_id: ID,
        price: u64,
        wallet: &mut Coin<FT>,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        allowlist: &Allowlist,
        ctx: &mut TxContext,
    ) {
        utils::assert_same_module_as_witness<T, W>();

        buy_nft_<T, FT>(
            book, nft_id, price, wallet, seller_kiosk, buyer_kiosk, allowlist, ctx
        )
    }

    // === Finish trade ===

    /// When a bid is created and there's an ask with a lower price, then the
    /// trade cannot be resolved immediately.
    ///
    /// That's because we don't know the `Kiosk` ID up front in OB.
    ///
    /// Therefore, orderbook creates [`TradeIntermediate`] which then has to be
    /// permissionlessly resolved via this endpoint.
    public entry fun finish_trade<T: key + store, FT>(
        book: &Orderbook<T, FT>,
        trade: &mut TradeIntermediate<T, FT>,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        allowlist: &Allowlist,
        ctx: &mut TxContext,
    ) {
        finish_trade_<T, FT>(book, trade, seller_kiosk, buyer_kiosk, allowlist, ctx)
    }

    // === Create orderbook ===

    /// `C`ollection kind of NFTs to be traded, and `F`ungible `T`oken to be
    /// quoted for an NFT in such a collection.
    ///
    /// By default, an orderbook has no restriction on actions, ie. all can be
    /// called with public entry functions.
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
    public entry fun create<T: key + store, FT>(ctx: &mut TxContext) {
        let ob = new<T, FT>(no_protection(), ctx);
        share_object(ob);
    }

    public fun share<T: key + store, FT>(ob: Orderbook<T, FT>) {
        share_object(ob);
    }

    /// Settings where all endpoints can be called as entry point functions.
    public fun no_protection(): WitnessProtectedActions {
        custom_protection(false, false, false, false, false)
    }

    public fun custom_protection(
        buy_nft: bool,
        cancel_ask: bool,
        cancel_bid: bool,
        create_ask: bool,
        create_bid: bool,
    ): WitnessProtectedActions {
        WitnessProtectedActions {
            buy_nft,
            cancel_ask,
            cancel_bid,
            create_ask,
            create_bid,
        }
    }

    // === Toggling protection ===

    public fun set_protection<W: drop, T: key + store, FT>(
        _witness: W,
        ob: &mut Orderbook<T, FT>,
        protected_actions: WitnessProtectedActions,
    ) {
        utils::assert_same_module_as_witness<T, W>();

        ob.protected_actions = protected_actions;
    }

    public fun toggle_protection_on_buy_nft<W: drop, T: key + store, FT>(
        _witness: W,
        book: &mut Orderbook<T, FT>,
    ) {
        utils::assert_same_module_as_witness<T, W>();

        book.protected_actions.buy_nft =
            !book.protected_actions.buy_nft;
    }

    public fun toggle_protection_on_cancel_ask<W: drop, T: key + store, FT>(
        _witness: W,
        book: &mut Orderbook<T, FT>,
    ) {
        utils::assert_same_module_as_witness<T, W>();

        book.protected_actions.cancel_ask =
            !book.protected_actions.cancel_ask;
    }

    public fun toggle_protection_on_cancel_bid<W: drop, T: key + store, FT>(
        _witness: W,
        book: &mut Orderbook<T, FT>,
    ) {
        utils::assert_same_module_as_witness<T, W>();

        book.protected_actions.cancel_bid =
            !book.protected_actions.cancel_bid;
    }

    public fun toggle_protection_on_create_ask<W: drop, T: key + store, FT>(
        _witness: W,
        book: &mut Orderbook<T, FT>,
    ) {
        utils::assert_same_module_as_witness<T, W>();

        book.protected_actions.create_ask =
            !book.protected_actions.create_ask;
    }

    public fun toggle_protection_on_create_bid<W: drop, T: key + store, FT>(
        _witness: W,
        book: &mut Orderbook<T, FT>,
    ) {
        utils::assert_same_module_as_witness<T, W>();

        book.protected_actions.create_bid =
            !book.protected_actions.create_bid;
    }

    // === Getters ===

    public fun borrow_bids<T: key + store, FT>(
        book: &Orderbook<T, FT>,
    ): &CBTree<vector<Bid<FT>>> {
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
    ): &CBTree<vector<Ask>> {
        &book.asks
    }

    public fun ask_price(ask: &Ask): u64 {
        ask.price
    }

    public fun ask_owner(ask: &Ask): address {
        ask.owner
    }

    public fun protected_actions<T: key + store, FT>(
        book: &Orderbook<T, FT>,
    ): &WitnessProtectedActions {
        &book.protected_actions
    }

    public fun is_create_ask_protected(
        protected_actions: &WitnessProtectedActions
    ): bool {
        protected_actions.create_ask
    }

    public fun is_create_bid_protected(
        protected_actions: &WitnessProtectedActions
    ): bool {
        protected_actions.create_bid
    }

    public fun is_cancel_ask_protected(
        protected_actions: &WitnessProtectedActions
    ): bool {
        protected_actions.cancel_ask
    }

    public fun is_cancel_bid_protected(
        protected_actions: &WitnessProtectedActions
    ): bool {
        protected_actions.cancel_bid
    }

    public fun is_buy_nft_protected(
        protected_actions: &WitnessProtectedActions
    ): bool {
        protected_actions.buy_nft
    }

    // === Priv fns ===

    fun create_bid_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        buyer_kiosk: &mut Kiosk,
        price: u64,
        bid_commission: Option<BidCommission<FT>>,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        ob_kiosk::assert_is_ob_kiosk(buyer_kiosk);

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

            assert!(
                kiosk_id != buyer_kiosk_id,
                ECANNOT_TRADE_WITH_SELF,
            );

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

            transfer_bid_commission(&mut bid_commission, ctx);
            option::destroy_none(bid_commission);
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
            }
        }
    }

    fun cancel_bid_except_commission_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        bid_price_level: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Option<BidCommission<FT>> {
        let sender = tx_context::sender(ctx);

        let bids = &mut book.bids;

        assert!(
            crit_bit::has_key(bids, bid_price_level),
            EORDER_DOES_NOT_EXIST
        );

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
        assert!(index < bids_count, EORDER_OWNER_MUST_BE_SENDER);

        let Bid { offer, owner: _owner, commission, kiosk } =
            vector::remove(price_level, index);

        event::emit(BidClosedEvent {
            owner: sender,
            kiosk,
            orderbook: object::id(book),
            price: bid_price_level,
            nft_type: type_name::into_string(type_name::get<T>()),
            ft_type: type_name::into_string(type_name::get<FT>()),
        });

        balance::join(
            coin::balance_mut(wallet),
            offer,
        );

        commission
    }

    fun cancel_bid_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        bid_price_level: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let commission =
            cancel_bid_except_commission_(book, bid_price_level, wallet, ctx);

        if (option::is_some(&commission)) {
            let (cut, _beneficiary) =
                destroy_bid_commission(option::extract(&mut commission));
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
            cancel_bid_except_commission_(book, old_price, wallet, ctx);

        create_bid_(book, buyer_kiosk, new_price, commission, wallet, ctx);
    }

    fun create_ask_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        owner_cap: &OwnerCap,
        price: u64,
        ask_commission: Option<AskCommission>,
        nft_id: ID,
        seller_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        ob_kiosk::assert_is_ob_kiosk(seller_kiosk);
        ob_kiosk::assert_owner_cap(seller_kiosk, owner_cap);

        // TODO: Confirm that NFT is in the kiosk
        // TODO: Check Type of NFT matches orderbook type
        // if (kiosk::transfer_cap_is_nft_generic(&transfer_cap)) {
        //     kiosk::assert_generic_nft_type<T>(&transfer_cap);
        // } else {
        //     kiosk::assert_nft_type<T>(&transfer_cap);
        // };

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
            assert!(
                buyer_kiosk_id != seller_kiosk_id,
                ECANNOT_TRADE_WITH_SELF,
            );
            let paid = balance::value(&bid_offer);

            // we cannot transfer the NFT straight away because we don't know
            // the buyers kiosk at the point of sending the tx

            ob_kiosk::auth_exclusive_transfer(
                seller_kiosk,
                owner_cap,
                nft_id,
                &book.id,
            );

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

            transfer_bid_commission(&mut bid_commission, ctx);
            option::destroy_none(bid_commission);
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
                    crit_bit::borrow_mut(&mut book.asks, price),
                    ask
                );
            } else {
                crit_bit::insert(
                    &mut book.asks,
                    price,
                    vector::singleton(ask),
                );
            };
        }
    }

    fun cancel_ask_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        nft_price_level: u64,
        nft_id: ID,
        ctx: &mut TxContext,
    ): Option<AskCommission> {
        let sender = tx_context::sender(ctx);

        let Ask {
            owner,
            price: _,
            nft_id,
            kiosk_id,
            commission,
        } = remove_ask(
            &mut book.asks,
            nft_price_level,
            nft_id,
        );

        event::emit(AskClosedEvent {
            price: nft_price_level,
            orderbook: object::id(book),
            nft: nft_id,
            owner: sender,
            nft_type: type_name::into_string(type_name::get<T>()),
            ft_type: type_name::into_string(type_name::get<FT>()),
        });

        assert!(owner == sender, EORDER_OWNER_MUST_BE_SENDER);

        commission
    }

    fun buy_nft_<T: key + store, FT>(
        book: &mut Orderbook<T, FT>,
        nft_id: ID,
        price: u64,
        wallet: &mut Coin<FT>,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        allowlist: &Allowlist,
        ctx: &mut TxContext,
    ) {
        // TODO: Why is there no TradeIntermediate here?
        let buyer = tx_context::sender(ctx);

        let Ask {
            owner: seller,
            price: _,
            nft_id: _,
            kiosk_id: _,
            commission: maybe_commission,
        } = remove_ask(
            &mut book.asks,
            price,
            nft_id,
        );

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
        settle_funds_with_royalties<T, FT>(
            &mut bid_offer,
            seller,
            &mut maybe_commission,
            ctx,
        );
        option::destroy_none(maybe_commission);
        balance::destroy_zero(bid_offer);

        // TODO: This is odd, it should not compile because request does not have drop
        let tx_request = ob_kiosk::transfer_delegated<T>(
            seller_kiosk,
            buyer_kiosk,
            nft_id,
            &book.id,
            price,
            ctx,
        );
    }

    fun finish_trade_<T: key + store, FT>(
        // Note: We need this here to provide &UID
        book: &Orderbook<T, FT>,
        trade: &mut TradeIntermediate<T, FT>,
        seller_kiosk: &mut Kiosk,
        buyer_kiosk: &mut Kiosk,
        _allowlist: &Allowlist,
        ctx: &mut TxContext,
    ) {
        let TradeIntermediate {
            id: _,
            nft_id,
            seller_kiosk: _,
            paid,
            seller,
            buyer,
            buyer_kiosk: expected_buyer_kiosk_id,
            commission: maybe_commission,
        } = trade;

        assert!(
            *expected_buyer_kiosk_id == object::id(buyer_kiosk),
            EKIOSK_ID_MISMATCH,
        );

        let price = balance::value(paid);

        settle_funds_with_royalties<T, FT>(
            paid,
            *seller,
            maybe_commission,
            ctx,
        );

        // TODO: This is odd, it should not compile because request does not have drop
        let tx_request = ob_kiosk::transfer_delegated<T>(
            seller_kiosk,
            buyer_kiosk,
            *nft_id,
            &book.id,
            price,
            ctx,
        );
    }

    /// Finds an ask of a given NFT advertized for the given price. Removes it
    /// from the asks vector preserving order and returns it.
    fun remove_ask(asks: &mut CBTree<vector<Ask>>, price: u64, nft_id: ID): Ask {
        assert!(
            crit_bit::has_key(asks, price),
            EORDER_DOES_NOT_EXIST
        );

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

        assert!(index < asks_count, EORDER_DOES_NOT_EXIST);

        vector::remove(price_level, index)
    }
}
