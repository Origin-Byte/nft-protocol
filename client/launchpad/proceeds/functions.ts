import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function empty(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::proceeds::empty`,
        arguments: [],
    })
}

export interface AddArgs {
    proceeds: ObjectArg; newProceeds: ObjectArg; qtySold: bigint | TransactionArgument
}

export function add(
    txb: TransactionBlock,
    typeArg: string,
    args: AddArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::proceeds::add`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.proceeds), obj(txb, args.newProceeds), pure(txb, args.qtySold, `u64`)
        ],
    })
}

export function balance(
    txb: TransactionBlock,
    typeArg: string,
    proceeds: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::proceeds::balance`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, proceeds)
        ],
    })
}

export function balanceMut(
    txb: TransactionBlock,
    typeArg: string,
    proceeds: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::proceeds::balance_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, proceeds)
        ],
    })
}

export interface CollectWithFeesArgs {
    proceeds: ObjectArg; fees: bigint | TransactionArgument; marketplaceReceiver: string | TransactionArgument; listingReceiver: string | TransactionArgument
}

export function collectWithFees(
    txb: TransactionBlock,
    typeArg: string,
    args: CollectWithFeesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::proceeds::collect_with_fees`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.proceeds), pure(txb, args.fees, `u64`), pure(txb, args.marketplaceReceiver, `address`), pure(txb, args.listingReceiver, `address`)
        ],
    })
}

export interface CollectWithoutFeesArgs {
    proceeds: ObjectArg; listingReceiver: string | TransactionArgument
}

export function collectWithoutFees(
    txb: TransactionBlock,
    typeArg: string,
    args: CollectWithoutFeesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::proceeds::collect_without_fees`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.proceeds), pure(txb, args.listingReceiver, `address`)
        ],
    })
}

export function collected(
    txb: TransactionBlock,
    proceeds: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::proceeds::collected`,
        arguments: [
            obj(txb, proceeds)
        ],
    })
}

export function total(
    txb: TransactionBlock,
    proceeds: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::proceeds::total`,
        arguments: [
            obj(txb, proceeds)
        ],
    })
}
