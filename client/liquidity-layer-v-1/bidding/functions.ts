import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, option, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function closeBid(
    txb: TransactionBlock,
    typeArg: string,
    bid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bidding::close_bid`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, bid)
        ],
    })
}

export function closeBid_(
    txb: TransactionBlock,
    typeArg: string,
    bid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bidding::close_bid_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, bid)
        ],
    })
}

export interface CreateBidArgs {
    buyersKiosk: string | TransactionArgument; nft: string | TransactionArgument; price: bigint | TransactionArgument; wallet: ObjectArg
}

export function createBid(
    txb: TransactionBlock,
    typeArg: string,
    args: CreateBidArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bidding::create_bid`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.buyersKiosk, `0x2::object::ID`), pure(txb, args.nft, `0x2::object::ID`), pure(txb, args.price, `u64`), obj(txb, args.wallet)
        ],
    })
}

export interface CreateBidWithCommissionArgs {
    buyersKiosk: string | TransactionArgument; nft: string | TransactionArgument; price: bigint | TransactionArgument; beneficiary: string | TransactionArgument; commissionFt: bigint | TransactionArgument; wallet: ObjectArg
}

export function createBidWithCommission(
    txb: TransactionBlock,
    typeArg: string,
    args: CreateBidWithCommissionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bidding::create_bid_with_commission`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.buyersKiosk, `0x2::object::ID`), pure(txb, args.nft, `0x2::object::ID`), pure(txb, args.price, `u64`), pure(txb, args.beneficiary, `address`), pure(txb, args.commissionFt, `u64`), obj(txb, args.wallet)
        ],
    })
}

export interface NewBidArgs {
    buyersKiosk: string | TransactionArgument; nft: string | TransactionArgument; price: bigint | TransactionArgument; commission: (ObjectArg | TransactionArgument | null); wallet: ObjectArg
}

export function newBid(
    txb: TransactionBlock,
    typeArg: string,
    args: NewBidArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bidding::new_bid`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.buyersKiosk, `0x2::object::ID`), pure(txb, args.nft, `0x2::object::ID`), pure(txb, args.price, `u64`), option(txb, `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::BidCommission<${typeArg}>`, args.commission), obj(txb, args.wallet)
        ],
    })
}

export interface SellNftArgs {
    bid: ObjectArg; buyersKiosk: ObjectArg; nft: GenericArg
}

export function sellNft(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SellNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bidding::sell_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.bid), obj(txb, args.buyersKiosk), generic(txb, `${typeArgs[0]}`, args.nft)
        ],
    })
}

export interface SellNftCommonArgs {
    bid: ObjectArg; buyersKiosk: ObjectArg; transferReq: ObjectArg; nftId: string | TransactionArgument
}

export function sellNftCommon(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SellNftCommonArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bidding::sell_nft_common`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.bid), obj(txb, args.buyersKiosk), obj(txb, args.transferReq), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface SellNftFromKioskArgs {
    bid: ObjectArg; sellersKiosk: ObjectArg; buyersKiosk: ObjectArg; nftId: string | TransactionArgument
}

export function sellNftFromKiosk(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SellNftFromKioskArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bidding::sell_nft_from_kiosk`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.bid), obj(txb, args.sellersKiosk), obj(txb, args.buyersKiosk), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export function share(
    txb: TransactionBlock,
    typeArg: string,
    bid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bidding::share`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, bid)
        ],
    })
}
