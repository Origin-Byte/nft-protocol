import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, option, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function askCommissionAmount(
    txb: TransactionBlock,
    ask: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::trading::ask_commission_amount`,
        arguments: [
            obj(txb, ask)
        ],
    })
}

export function askCommissionBeneficiary(
    txb: TransactionBlock,
    ask: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::trading::ask_commission_beneficiary`,
        arguments: [
            obj(txb, ask)
        ],
    })
}

export function bidCommissionAmount(
    txb: TransactionBlock,
    typeArg: string,
    bid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::trading::bid_commission_amount`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, bid)
        ],
    })
}

export function bidCommissionBeneficiary(
    txb: TransactionBlock,
    typeArg: string,
    bid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::trading::bid_commission_beneficiary`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, bid)
        ],
    })
}

export function destroyAskCommission(
    txb: TransactionBlock,
    commission: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::trading::destroy_ask_commission`,
        arguments: [
            obj(txb, commission)
        ],
    })
}

export function destroyBidCommission(
    txb: TransactionBlock,
    typeArg: string,
    commission: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::trading::destroy_bid_commission`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, commission)
        ],
    })
}

export interface ExtractAskCommissionArgs {
    commission: ObjectArg; source: ObjectArg
}

export function extractAskCommission(
    txb: TransactionBlock,
    typeArg: string,
    args: ExtractAskCommissionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::trading::extract_ask_commission`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.commission), obj(txb, args.source)
        ],
    })
}

export interface NewAskCommissionArgs {
    beneficiary: string | TransactionArgument; cut: bigint | TransactionArgument
}

export function newAskCommission(
    txb: TransactionBlock,
    args: NewAskCommissionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::trading::new_ask_commission`,
        arguments: [
            pure(txb, args.beneficiary, `address`), pure(txb, args.cut, `u64`)
        ],
    })
}

export interface NewBidCommissionArgs {
    beneficiary: string | TransactionArgument; cut: ObjectArg
}

export function newBidCommission(
    txb: TransactionBlock,
    typeArg: string,
    args: NewBidCommissionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::trading::new_bid_commission`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.beneficiary, `address`), obj(txb, args.cut)
        ],
    })
}

export interface TransferAskCommissionArgs {
    commission: (ObjectArg | TransactionArgument | null); source: ObjectArg
}

export function transferAskCommission(
    txb: TransactionBlock,
    typeArg: string,
    args: TransferAskCommissionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::trading::transfer_ask_commission`,
        typeArguments: [typeArg],
        arguments: [
            option(txb, `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::AskCommission`, args.commission), obj(txb, args.source)
        ],
    })
}

export function transferBidCommission(
    txb: TransactionBlock,
    typeArg: string,
    commission: (ObjectArg | TransactionArgument | null)
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::trading::transfer_bid_commission`,
        typeArguments: [typeArg],
        arguments: [
            option(txb, `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::BidCommission<${typeArg}>`, commission)
        ],
    })
}
