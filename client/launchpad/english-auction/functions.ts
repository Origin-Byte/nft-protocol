import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    nft: GenericArg; bid: ObjectArg
}

export function new_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::new`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[0]}`, args.nft), obj(txb, args.bid)
        ],
    })
}

export function delete_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    auction: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::delete`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, auction)
        ],
    })
}

export interface CreateBidArgs {
    listing: ObjectArg; wallet: ObjectArg; venueId: string | TransactionArgument; bid: bigint | TransactionArgument
}

export function createBid(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateBidArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::create_bid`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), obj(txb, args.wallet), pure(txb, args.venueId, `0x2::object::ID`), pure(txb, args.bid, `u64`)
        ],
    })
}

export interface CreateBid_Args {
    auction: ObjectArg; bid: ObjectArg
}

export function createBid_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateBid_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::create_bid_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.auction), obj(txb, args.bid)
        ],
    })
}

export function borrowMarket(
    txb: TransactionBlock,
    typeArgs: [string, string],
    venue: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::borrow_market`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, venue)
        ],
    })
}

export interface FromWarehouseArgs {
    warehouse: ObjectArg; nftId: string | TransactionArgument; bid: ObjectArg
}

export function fromWarehouse(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: FromWarehouseArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::from_warehouse`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.warehouse), pure(txb, args.nftId, `0x2::object::ID`), obj(txb, args.bid)
        ],
    })
}

export interface ConcludeAuctionArgs {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function concludeAuction(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ConcludeAuctionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::conclude_auction`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface CreateBidWhitelistedArgs {
    listing: ObjectArg; wallet: ObjectArg; venueId: string | TransactionArgument; whitelistToken: ObjectArg; bid: bigint | TransactionArgument
}

export function createBidWhitelisted(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateBidWhitelistedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::create_bid_whitelisted`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), obj(txb, args.wallet), pure(txb, args.venueId, `0x2::object::ID`), obj(txb, args.whitelistToken), pure(txb, args.bid, `u64`)
        ],
    })
}

export function assertConcluded(
    txb: TransactionBlock,
    typeArgs: [string, string],
    auction: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::assert_concluded`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, auction)
        ],
    })
}

export function assertNotConcluded(
    txb: TransactionBlock,
    typeArgs: [string, string],
    auction: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::assert_not_concluded`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, auction)
        ],
    })
}

export function bidFromBalance(
    txb: TransactionBlock,
    typeArg: string,
    offer: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::bid_from_balance`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, offer)
        ],
    })
}

export interface BidFromCoinArgs {
    wallet: ObjectArg; bid: bigint | TransactionArgument
}

export function bidFromCoin(
    txb: TransactionBlock,
    typeArg: string,
    args: BidFromCoinArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::bid_from_coin`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.wallet), pure(txb, args.bid, `u64`)
        ],
    })
}

export interface ClaimNftArgs {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function claimNft(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ClaimNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::claim_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface ClaimNft_Args {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function claimNft_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ClaimNft_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::claim_nft_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface ClaimNftIntoKioskArgs {
    listing: ObjectArg; venueId: string | TransactionArgument; buyerKiosk: ObjectArg
}

export function claimNftIntoKiosk(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ClaimNftIntoKioskArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::claim_nft_into_kiosk`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`), obj(txb, args.buyerKiosk)
        ],
    })
}

export interface CreateAuctionArgs {
    listing: ObjectArg; wallet: ObjectArg; isWhitelisted: boolean | TransactionArgument; inventoryId: string | TransactionArgument; nftId: string | TransactionArgument; bid: bigint | TransactionArgument
}

export function createAuction(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateAuctionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::create_auction`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), obj(txb, args.wallet), pure(txb, args.isWhitelisted, `bool`), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.bid, `u64`)
        ],
    })
}

export function currentBid(
    txb: TransactionBlock,
    typeArgs: [string, string],
    auction: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::current_bid`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, auction)
        ],
    })
}

export function currentBidder(
    txb: TransactionBlock,
    typeArgs: [string, string],
    auction: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::current_bidder`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, auction)
        ],
    })
}

export function deleteBid(
    txb: TransactionBlock,
    typeArg: string,
    bid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::delete_bid`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, bid)
        ],
    })
}

export interface FromInventoryArgs {
    inventory: ObjectArg; nftId: string | TransactionArgument; bid: ObjectArg
}

export function fromInventory(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: FromInventoryArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::from_inventory`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.inventory), pure(txb, args.nftId, `0x2::object::ID`), obj(txb, args.bid)
        ],
    })
}

export interface InitAuctionArgs {
    listing: ObjectArg; wallet: ObjectArg; inventoryId: string | TransactionArgument; isWhitelisted: boolean | TransactionArgument; nftId: string | TransactionArgument; bid: bigint | TransactionArgument
}

export function initAuction(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: InitAuctionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::init_auction`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), obj(txb, args.wallet), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.isWhitelisted, `bool`), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.bid, `u64`)
        ],
    })
}

export function isConcluded(
    txb: TransactionBlock,
    typeArgs: [string, string],
    auction: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::english_auction::is_concluded`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, auction)
        ],
    })
}
