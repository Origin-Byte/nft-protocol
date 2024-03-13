import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function new_(
    txb: TransactionBlock,
    rateBps: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::flat_fee::new`,
        arguments: [
            pure(txb, rateBps, `u64`)
        ],
    })
}

export interface CalcFeeArgs {
    proceedsValue: bigint | TransactionArgument; rateBps: bigint | TransactionArgument
}

export function calcFee(
    txb: TransactionBlock,
    args: CalcFeeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::flat_fee::calc_fee`,
        arguments: [
            pure(txb, args.proceedsValue, `u64`), pure(txb, args.rateBps, `u64`)
        ],
    })
}

export interface CollectProceedsAndFeesArgs {
    marketplace: ObjectArg; listing: ObjectArg
}

export function collectProceedsAndFees(
    txb: TransactionBlock,
    typeArg: string,
    args: CollectProceedsAndFeesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::flat_fee::collect_proceeds_and_fees`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.marketplace), obj(txb, args.listing)
        ],
    })
}

export function initFee(
    txb: TransactionBlock,
    rate: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::flat_fee::init_fee`,
        arguments: [
            pure(txb, rate, `u64`)
        ],
    })
}
