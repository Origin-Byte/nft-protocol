/// Bidding module that allows users to bid for any given NFT in a kiosk,
/// giving NFT owners a platform to sell their NFTs to any available bid.
module nft_protocol::bidding {
    use std::ascii::String;
    use std::option::{Self, Option};
    use std::type_name;

    use sui::event::emit;
    use sui::kiosk::Kiosk;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer::{public_transfer, share_object};

    use nft_protocol::err;
    use nft_protocol::transfer_policy::{Self, TransferRequest};
    use nft_protocol::ob_kiosk::{Self, OwnerCap};
    use nft_protocol::transfer_allowlist::Allowlist;
    use nft_protocol::trading::{
        AskCommission,
        bid_commission_amount,
        BidCommission,
        destroy_bid_commission,
        new_ask_commission,
        new_bid_commission,
        transfer_bid_commission,
    };

    /// === Errors ===

    /// When a bid is closed or matched, the balance is set to zero.
    ///
    /// It cannot be attempted to be closed or matched again.
    const EBID_ALREADY_CLOSED: u64 = 0;

    /// When a bid is created, the price cannot be zero.
    const EPRICE_CANNOT_BE_ZERO: u64 = 0;

    /// === Structs ===

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    struct Bid<phantom FT> has key {
        id: UID,
        nft: ID,
        buyer: address,
        kiosk: ID,
        offer: Balance<FT>,
        commission: Option<BidCommission<FT>>,
    }

    struct BidCreatedEvent has copy, drop {
        bid: ID,
        nft: ID,
        price: u64,
        commission: u64,
        buyer: address,
        buyer_kiosk: ID,
        ft_type: String,
    }

    /// Bid was closed by the user, no sell happened
    struct BidClosedEvent has copy, drop {
        bid: ID,
        nft: ID,
        buyer: address,
        price: u64,
        ft_type: String,
    }

    /// NFT was sold
    struct BidMatchedEvent has copy, drop {
        bid: ID,
        nft: ID,
        price: u64,
        seller: address,
        buyer: address,
        ft_type: String,
        nft_type: String,
    }

    /// === Entry points ===

    /// Payable entry function to create a bid for an NFT.
    ///
    /// It performs the following:
    /// - Sends funds Balance<FT> from `wallet` to the `bid`
    /// - Creates object `bid` and shares it.
    public entry fun create_bid<FT>(
        nft: ID,
        buyers_kiosk: ID,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        // TODO: We could have our kiosk emmit events on bids, perhaps?
        let bid =
            new_bid(nft, buyers_kiosk, price, option::none(), wallet, ctx);
        share_object(bid);
    }

    /// Payable entry function to create a bid for an NFT.
    ///
    /// It performs the following:
    /// - Sends funds Balance<FT> from `wallet` to the `bid`
    /// - Creates object `bid` with `commission` and shares it.
    ///
    /// To be called by a intermediate application, for the purpose
    /// of securing a commission for intermediating the process.
    public entry fun create_bid_with_commission<FT>(
        nft: ID,
        buyers_kiosk: ID,
        price: u64,
        beneficiary: address,
        commission_ft: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let commission = new_bid_commission(
            beneficiary,
            balance::split(coin::balance_mut(wallet), commission_ft),
        );
        let bid =
            new_bid(nft, buyers_kiosk, price, option::some(commission), wallet, ctx);
        share_object(bid);
    }

    /// Entry function to sell an NFT with an open `bid`.
    ///
    /// It performs the following:
    /// - Splits funds from `Bid<FT>` by:
    ///     - (1) Creating TradePayment<C, FT> for the trade amount
    /// - Transfers NFT from `sellers_kiosk` to `buyers_kiosk` and
    /// burns `TransferCap`
    /// - Transfers bid commission funds to the address
    /// `bid.commission.beneficiary`
    public entry fun sell_nft<T: key + store, FT>(
        bid: &mut Bid<FT>,
        owner_cap: &OwnerCap,
        nft_id: ID,
        sellers_kiosk: &mut Kiosk,
        buyers_kiosk: &mut Kiosk,
        allowlist: &Allowlist,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        sell_nft_<T, FT>(
            bid,
            owner_cap,
            nft_id,
            option::none(),
            sellers_kiosk,
            buyers_kiosk,
            allowlist,
            ctx,
        )
    }

    /// Entry function to sell an NFT with an open `bid`.
    ///
    /// It performs the following:
    /// - Splits funds from `Bid<FT>` by:
    ///     - (1) Creating TradePayment<C, FT> for the Ask commission
    ///     - (2) Creating TradePayment<C, FT> for the net trade amount
    /// - Transfers NFT from `sellers_kiosk` to `buyers_kiosk` and
    /// burns `TransferCap`
    /// - Transfers bid commission funds to the address
    /// `bid.commission.beneficiary`
    ///
    /// To be called by a intermediate application, for the purpose of
    /// securing a commission for intermediating the process.
    public entry fun sell_nft_with_commission<T: key + store, FT>(
        bid: &mut Bid<FT>,
        owner_cap: &OwnerCap,
        nft_id: ID,
        beneficiary: address,
        commission_ft: u64,
        sellers_kiosk: &mut Kiosk,
        buyers_kiosk: &mut Kiosk,
        allowlist: &Allowlist,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        let commission = new_ask_commission(
            beneficiary,
            commission_ft,
        );
        sell_nft_<T, FT>(
            bid,
            owner_cap,
            nft_id,
            option::none(),
            sellers_kiosk,
            buyers_kiosk,
            allowlist,
            ctx,
        )
    }

    /// If a user wants to cancel their position, they get their coins back.
    public entry fun close_bid<FT>(bid: &mut Bid<FT>, ctx: &mut TxContext) {
        close_bid_(bid, ctx);
    }

    /// === Helpers ===

    public fun share<FT>(bid: Bid<FT>) {
        share_object(bid);
    }

    /// Sends funds Balance<FT> from `wallet` to the `bid` and
    /// shares object `bid.`
    public fun new_bid<FT>(
        nft: ID,
        buyers_kiosk: ID,
        price: u64,
        commission: Option<BidCommission<FT>>,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Bid<FT> {
        assert!(price != 0, EPRICE_CANNOT_BE_ZERO);

        let offer = balance::split(coin::balance_mut(wallet), price);
        let buyer = tx_context::sender(ctx);

        let commission_amount = if(option::is_some(&commission)) {
            bid_commission_amount(option::borrow(&commission))
        } else {
            0
        };

        let bid = Bid<FT> {
            id: object::new(ctx),
            nft,
            offer,
            buyer,
            kiosk: buyers_kiosk,
            commission,
        };
        let bid_id = object::id(&bid);

        emit(BidCreatedEvent {
            bid: bid_id,
            nft: nft,
            price,
            buyer,
            buyer_kiosk: buyers_kiosk,
            ft_type: *type_name::borrow_string(&type_name::get<FT>()),
            commission: commission_amount,
        });

        bid
    }

    /// === Privates ===

    /// Function to sell an NFT with an open `bid`.
    ///
    /// It splits funds from `Bid<FT>` by creating TradePayment<C, FT>
    /// for the Ask commission if any, and creating TradePayment<C, FT> for the
    /// next trade amount. It transfers the NFT from `sellers_kiosk` to
    /// `buyers_kiosk` and burns `TransferCap`. It then transfers bid
    /// commission funds to address `bid.commission.beneficiary`.
    fun sell_nft_<T: key + store, FT>(
        bid: &mut Bid<FT>,
        owner_cap: &OwnerCap,
        nft_id: ID,
        ask_commission: Option<AskCommission>,
        sellers_kiosk: &mut Kiosk,
        buyers_kiosk: &mut Kiosk,
        allowlist: &Allowlist,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        ob_kiosk::assert_owner_cap(sellers_kiosk, owner_cap);
        ob_kiosk::assert_is_ob_kiosk(sellers_kiosk);
        ob_kiosk::assert_is_ob_kiosk(buyers_kiosk);
        ob_kiosk::assert_kiosk_id(buyers_kiosk, bid.kiosk);

        let price = balance::value(&bid.offer);
        assert!(price != 0, EBID_ALREADY_CLOSED);
        option::destroy_none(ask_commission);

        // TODO: This is odd, it should not compile because request does not have drop
        let tx_builder = ob_kiosk::transfer_signed<T>(
            sellers_kiosk,
            buyers_kiosk,
            nft_id,
            ctx,
        );

        let tx_request = transfer_policy::build(tx_builder);

        transfer_bid_commission(&mut bid.commission, ctx);

        emit(BidMatchedEvent {
            bid: object::id(bid),
            nft: nft_id,
            price,
            seller: tx_context::sender(ctx),
            buyer: bid.buyer,
            ft_type: *type_name::borrow_string(&type_name::get<FT>()),
            nft_type: *type_name::borrow_string(&type_name::get<T>()),
        });

        tx_request
    }

    fun close_bid_<FT>(bid: &mut Bid<FT>, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        assert!(bid.buyer == sender, err::sender_not_owner());

        let total = balance::value(&bid.offer);
        assert!(total != 0, EBID_ALREADY_CLOSED);
        let offer = coin::take(&mut bid.offer, total, ctx);

        if (option::is_some(&bid.commission)) {
            let commission = option::extract(&mut bid.commission);
            let (cut, _beneficiary) = destroy_bid_commission(commission);

            balance::join(coin::balance_mut(&mut offer), cut);
        };

        public_transfer(offer, sender);

        emit(BidClosedEvent {
            bid: object::id(bid),
            nft: bid.nft,
            buyer: sender,
            price: total,
            ft_type: *type_name::borrow_string(&type_name::get<FT>()),
        });
    }
}
