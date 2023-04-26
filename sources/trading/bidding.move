/// Bidding module that allows users to bid for any given NFT just by its ID.
/// This gives NFT owners a platform to sell their NFTs to any available bid.
module nft_protocol::bidding {
    use std::ascii::String;
    use std::option::{Self, Option};
    use std::type_name;

    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::event::emit;
    use sui::kiosk::Kiosk;
    use sui::object::{Self, ID, UID, uid_to_address};
    use sui::transfer::{public_transfer, share_object};
    use sui::tx_context::{TxContext, sender};

    use request::ob_kiosk;
    use request::ob_transfer_request::{Self, TransferRequest};

    use nft_protocol::trading;

    /// === Errors ===

    /// When a bid is closed or matched, the balance is set to zero.
    ///
    /// It cannot be attempted to be closed or matched again.
    const EBidAlreadyClosed: u64 = 1;

    /// When a bid is created, the price cannot be zero.
    const EPriceCannotBeZero: u64 = 2;

    const ESenderNotOwner: u64 = 3;

    /// === Structs ===

    /// Witness used to authenticate witness protected endpoints
    struct Witness has drop {}

    /// Holds public information about a bid.
    ///
    /// Initially, a bid is open, ie. the offer balance is not zero.
    /// Then, a bid is either closed or matched.
    /// In either case, the offer balance is set to zero.
    struct Bid<phantom FT> has key {
        id: UID,
        nft: ID,
        buyer: address,
        /// Buyer's kiosk into which the NFT must be deposited.
        kiosk: ID,
        offer: Balance<FT>,
        /// Optionally, upon creation, the bid can be created with a commission.
        /// This means that when the bid is matched, the balance in this field
        /// is sent to the given beneficiary.
        ///
        /// Useful for wallets or marketplaces which create bids on behalf of
        /// users and want to secure a commission.
        commission: Option<trading::BidCommission<FT>>,
    }

    /// === Events ===

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

    /// It performs the following:
    /// - Creates object `bid`
    /// - Transfers `price` tokens from `wallet` to the `bid.offer`
    /// - Shares the bid
    ///
    /// Make sure that the buyers kiosk allows deposits of `T`.
    /// See `ob_kiosk::DepositSetting`.
    public fun create_bid<FT>(
        buyers_kiosk: ID,
        nft: ID,
        price: u64,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ) {
        let bid =
            new_bid(buyers_kiosk, nft, price, option::none(), wallet, ctx);
        share_object(bid);
    }

    /// It performs the following:
    /// - Creates object `bid`
    /// - Transfers `price` tokens from `wallet` to the `bid.offer`
    /// - Transfers `commission_ft` tokens from `wallet` to the `bid.commission`
    /// - Shares the bid
    ///
    /// To be called by a intermediate application, for the purpose
    /// of securing a commission for intermediating the process.
    ///
    /// Make sure that the buyers kiosk allows deposits of `T`.
    /// See `ob_kiosk::DepositSetting`.
    public fun create_bid_with_commission<FT>(
        buyers_kiosk: ID,
        nft: ID,
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
            new_bid(buyers_kiosk, nft, price, option::some(commission), wallet, ctx);
        share_object(bid);
    }

    /// Match a bid.
    /// The NFT must live in the sellers kiosk.
    ///
    /// Aborts if the buyers kiosk does not allow deposits of `T`.
    /// See `ob_kiosk::DepositSetting`.
    public fun sell_nft_from_kiosk<T: key + store, FT>(
        bid: &mut Bid<FT>,
        sellers_kiosk: &mut Kiosk,
        buyers_kiosk: &mut Kiosk,
        nft_id: ID,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        let transfer_req = ob_kiosk::transfer_delegated<T>(
            sellers_kiosk,
            buyers_kiosk,
            nft_id,
            &bid.id,
            balance::value(&bid.offer),
            ctx,
        );
        sell_nft_common(bid, buyers_kiosk, transfer_req, nft_id, ctx)
    }

    /// Use if the NFT does not live in a safe and the seller has access to it
    /// as an owner object.
    ///
    /// Aborts if the buyers kiosk does not allow deposits of `T`.
    /// See `ob_kiosk::DepositSetting`.
    public fun sell_nft<T: key + store, FT>(
        bid: &mut Bid<FT>,
        buyers_kiosk: &mut Kiosk,
        nft: T,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        let nft_id = object::id(&nft);
        ob_kiosk::deposit(buyers_kiosk, nft, ctx);
        let transfer_req = ob_transfer_request::new<T>(
            nft_id,
            uid_to_address(&bid.id),
            bid.kiosk,
            balance::value(&bid.offer),
            ctx,
        );
        sell_nft_common(bid, buyers_kiosk, transfer_req, nft_id, ctx)
    }

    /// If a user wants to cancel their position, they get their coins back.
    /// Both offer and commission (if set) are given back.
    public fun close_bid<FT>(bid: &mut Bid<FT>, ctx: &mut TxContext) {
        close_bid_(bid, ctx);
    }

    /// === Helpers ===

    public fun share<FT>(bid: Bid<FT>) {
        share_object(bid);
    }

    /// It performs the following:
    /// - Creates object `bid`
    /// - Transfers `price` tokens from `wallet` to the `bid.offer`
    /// - Transfers `commission_ft` tokens from `wallet` to the `bid.commission`
    /// if commission is set
    public fun new_bid<FT>(
        buyers_kiosk: ID,
        nft: ID,
        price: u64,
        commission: Option<trading::BidCommission<FT>>,
        wallet: &mut Coin<FT>,
        ctx: &mut TxContext,
    ): Bid<FT> {
        assert!(price != 0, EPriceCannotBeZero);

        let offer = balance::split(coin::balance_mut(wallet), price);
        let buyer = sender(ctx);

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

    fun sell_nft_common<T: key + store, FT>(
        bid: &mut Bid<FT>,
        buyers_kiosk: &mut Kiosk,
        transfer_req: TransferRequest<T>,
        nft_id: ID,
        ctx: &mut TxContext,
    ): TransferRequest<T> {
        ob_kiosk::assert_kiosk_id(buyers_kiosk, bid.kiosk);
        let seller = sender(ctx);
        let price = balance::value(&bid.offer);
        assert!(price != 0, EBidAlreadyClosed);

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

    fun close_bid_<FT>(bid: &mut Bid<FT>, ctx: &mut TxContext) {
        let sender = sender(ctx);
        assert!(bid.buyer == sender, ESenderNotOwner);

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
    }
}
