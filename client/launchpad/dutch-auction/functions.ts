import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    inventoryId: string | TransactionArgument; reservePrice: bigint | TransactionArgument
}

export function new_(
    txb: TransactionBlock,
    typeArg: string,
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::new`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.reservePrice, `u64`)
        ],
    })
}

export interface CreateBidArgs {
    wallet: ObjectArg; listing: ObjectArg; venueId: string | TransactionArgument; price: bigint | TransactionArgument; quantity: bigint | TransactionArgument
}

export function createBid(
    txb: TransactionBlock,
    typeArg: string,
    args: CreateBidArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::create_bid`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.wallet), obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`), pure(txb, args.price, `u64`), pure(txb, args.quantity, `u64`)
        ],
    })
}

export function bidOwner(
    txb: TransactionBlock,
    typeArg: string,
    bid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::bid_owner`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, bid)
        ],
    })
}

export interface CancelBidArgs {
    wallet: ObjectArg; listing: ObjectArg; venueId: string | TransactionArgument; price: bigint | TransactionArgument
}

export function cancelBid(
    txb: TransactionBlock,
    typeArg: string,
    args: CancelBidArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::cancel_bid`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.wallet), obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`), pure(txb, args.price, `u64`)
        ],
    })
}

export interface CancelBid_Args {
    auction: ObjectArg; wallet: ObjectArg; price: bigint | TransactionArgument; sender: string | TransactionArgument
}

export function cancelBid_(
    txb: TransactionBlock,
    typeArg: string,
    args: CancelBid_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::cancel_bid_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.auction), obj(txb, args.wallet), pure(txb, args.price, `u64`), pure(txb, args.sender, `address`)
        ],
    })
}

export interface CreateBid_Args {
    auction: ObjectArg; wallet: ObjectArg; price: bigint | TransactionArgument; quantity: bigint | TransactionArgument; owner: string | TransactionArgument
}

export function createBid_(
    txb: TransactionBlock,
    typeArg: string,
    args: CreateBid_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::create_bid_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.auction), obj(txb, args.wallet), pure(txb, args.price, `u64`), pure(txb, args.quantity, `u64`), pure(txb, args.owner, `address`)
        ],
    })
}

export function bids(
    txb: TransactionBlock,
    typeArg: string,
    market: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::bids`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, market)
        ],
    })
}

export function borrowMarket(
    txb: TransactionBlock,
    typeArg: string,
    venue: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::borrow_market`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, venue)
        ],
    })
}

export interface InitVenueArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument; isWhitelisted: boolean | TransactionArgument; reservePrice: bigint | TransactionArgument
}

export function initVenue(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: InitVenueArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::init_venue`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.isWhitelisted, `bool`), pure(txb, args.reservePrice, `u64`)
        ],
    })
}

export interface CreateVenueArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument; isWhitelisted: boolean | TransactionArgument; reservePrice: bigint | TransactionArgument
}

export function createVenue(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateVenueArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::create_venue`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.isWhitelisted, `bool`), pure(txb, args.reservePrice, `u64`)
        ],
    })
}

export function bidAmount(
    txb: TransactionBlock,
    typeArg: string,
    bid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::bid_amount`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, bid)
        ],
    })
}

export function cancelAuction(
    txb: TransactionBlock,
    typeArg: string,
    book: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::cancel_auction`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, book)
        ],
    })
}

export interface ConcludeAuctionArgs {
    auction: ObjectArg; nftsToSell: bigint | TransactionArgument
}

export function concludeAuction(
    txb: TransactionBlock,
    typeArg: string,
    args: ConcludeAuctionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::conclude_auction`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.auction), pure(txb, args.nftsToSell, `u64`)
        ],
    })
}

export interface CreateBidWhitelistedArgs {
    wallet: ObjectArg; listing: ObjectArg; venueId: string | TransactionArgument; whitelistToken: ObjectArg; price: bigint | TransactionArgument; quantity: bigint | TransactionArgument
}

export function createBidWhitelisted(
    txb: TransactionBlock,
    typeArg: string,
    args: CreateBidWhitelistedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::create_bid_whitelisted`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.wallet), obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`), obj(txb, args.whitelistToken), pure(txb, args.price, `u64`), pure(txb, args.quantity, `u64`)
        ],
    })
}

export function reservePrice(
    txb: TransactionBlock,
    typeArg: string,
    market: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::reserve_price`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, market)
        ],
    })
}

export interface InitMarketArgs {
    inventoryId: string | TransactionArgument; reservePrice: bigint | TransactionArgument
}

export function initMarket(
    txb: TransactionBlock,
    typeArg: string,
    args: InitMarketArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::init_market`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.reservePrice, `u64`)
        ],
    })
}

export interface RefundBidArgs {
    bid: ObjectArg; wallet: ObjectArg; sender: string | TransactionArgument
}

export function refundBid(
    txb: TransactionBlock,
    typeArg: string,
    args: RefundBidArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::refund_bid`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.bid), obj(txb, args.wallet), pure(txb, args.sender, `address`)
        ],
    })
}

export interface SaleCancelArgs {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function saleCancel(
    txb: TransactionBlock,
    typeArg: string,
    args: SaleCancelArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::sale_cancel`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface SaleConcludeArgs {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function saleConclude(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SaleConcludeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dutch_auction::sale_conclude`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}
