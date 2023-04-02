/// Bidding module that allows users to bid for any given NFT just by its ID.
/// This gives NFT owners a platform to sell their NFTs to any available bid.
module nft_protocol::bidding {
    // TODO: sell NFT that's not in kiosk

    use nft_protocol::err;
    use nft_protocol::ob_kiosk;
    use nft_protocol::trading;
    use nft_protocol::ob_transfer_request::{Self, TransferRequest};
    use std::ascii::String;
    use std::option::{Self, Option};
    use std::type_name;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::event::emit;
    use sui::kiosk::Kiosk;
    use sui::object::{Self, ID, UID};
    use sui::transfer::{public_transfer, share_object};
    use sui::tx_context::{Self, TxContext};

    /// === Errors ===

    /// When a bid is closed or matched, the balance is set to zero.
    ///
    /// It cannot be attempted to be closed or matched again.
    const EBidAlreadyClosed: u64 = 1;

    /// When a bid is created, the price cannot be zero.
    const EPriceCannotBeZero: u64 = 2;

    /// === Structs ===

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    struct Bid<phantom FT> has key {
        id: UID,
        nft: ID,
        buyer: address,
        kiosk: ID,
        offer: Balance<FT>,
        commission: Option<trading::BidCommission<FT>>,
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
    public fun create_bid<FT>(
        nft: ID,
        buyers_kiosk: ID,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
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
    public fun create_bid_with_commission<FT>(
        nft: ID,
        buyers_kiosk: ID,
        price: u64,
        beneficiary: address,
        commission_ft: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let commission = trading::new_bid_commission(
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
    public fun sell_nft<T: key + store, FT>(
        bid: &mut Bid<FT>,
        nft_id: ID,
        sellers_kiosk: &mut Kiosk,
        buyers_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        sell_nft_<T, FT>(
            bid,
            nft_id,
            sellers_kiosk,
            buyers_kiosk,
            ctx,
        )
    }

    /// If a user wants to cancel their position, they get their coins back.
    public fun close_bid<FT>(
        bid: &mut Bid<FT>, kiosk: &mut Kiosk, ctx: &mut TxContext,
    ) {
        close_bid_(bid, kiosk, ctx);
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
        commission: Option<trading::BidCommission<FT>>,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Bid<FT> {
        assert!(price != 0, EPriceCannotBeZero);

        let offer = balance::split(coin::balance_mut(wallet), price);
        let buyer = tx_context::sender(ctx);

        let commission_amount = if(option::is_some(&commission)) {
            trading::bid_commission_amount(option::borrow(&commission))
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
        nft_id: ID,
        sellers_kiosk: &mut Kiosk,
        buyers_kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        ob_kiosk::assert_kiosk_id(buyers_kiosk, bid.kiosk);
        let seller = tx_context::sender(ctx);

        let price = balance::value(&bid.offer);
        assert!(price != 0, EBidAlreadyClosed);

        let transfer_req = ob_kiosk::transfer_delegated<T>(
            sellers_kiosk,
            buyers_kiosk,
            nft_id,
            &bid.id,
            ctx,
        );
        ob_transfer_request::set_paid<T, FT>(
            &mut transfer_req, balance::withdraw_all(&mut bid.offer), seller,
        );
        ob_kiosk::set_transfer_request_auth(&mut transfer_req, &Witness {});

        trading::transfer_bid_commission(&mut bid.commission, ctx);

        emit(BidMatchedEvent {
            bid: object::id(bid),
            nft: nft_id,
            price,
            seller,
            buyer: bid.buyer,
            ft_type: *type_name::borrow_string(&type_name::get<FT>()),
            nft_type: *type_name::borrow_string(&type_name::get<T>()),
        });

        transfer_req
    }

    fun close_bid_<FT>(
        bid: &mut Bid<FT>,
        kiosk: &mut Kiosk,
        ctx: &mut TxContext,
    ) {
        let sender = tx_context::sender(ctx);
        assert!(bid.buyer == sender, err::sender_not_owner());

        let total = balance::value(&bid.offer);
        assert!(total != 0, EBidAlreadyClosed);
        let offer = coin::take(&mut bid.offer, total, ctx);

        if (option::is_some(&bid.commission)) {
            let commission = option::extract(&mut bid.commission);
            let (cut, _beneficiary) = trading::destroy_bid_commission(commission);

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

        ob_kiosk::remove_auth_transfer(kiosk, bid.nft, &bid.id)
    }
}
