import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function new_(
    txb: TransactionBlock,
    max: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils_supply::new`,
        arguments: [
            pure(txb, max, `u64`)
        ],
    })
}

export interface SplitArgs {
    supply: ObjectArg; value: bigint | TransactionArgument
}

export function split(
    txb: TransactionBlock,
    args: SplitArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils_supply::split`,
        arguments: [
            obj(txb, args.supply), pure(txb, args.value, `u64`)
        ],
    })
}

export interface IncrementArgs {
    supply: ObjectArg; value: bigint | TransactionArgument
}

export function increment(
    txb: TransactionBlock,
    args: IncrementArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils_supply::increment`,
        arguments: [
            obj(txb, args.supply), pure(txb, args.value, `u64`)
        ],
    })
}

export function assertZero(
    txb: TransactionBlock,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils_supply::assert_zero`,
        arguments: [
            obj(txb, supply)
        ],
    })
}

export interface DecreaseMaximumArgs {
    supply: ObjectArg; value: bigint | TransactionArgument
}

export function decreaseMaximum(
    txb: TransactionBlock,
    args: DecreaseMaximumArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils_supply::decrease_maximum`,
        arguments: [
            obj(txb, args.supply), pure(txb, args.value, `u64`)
        ],
    })
}

export interface DecrementArgs {
    supply: ObjectArg; value: bigint | TransactionArgument
}

export function decrement(
    txb: TransactionBlock,
    args: DecrementArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils_supply::decrement`,
        arguments: [
            obj(txb, args.supply), pure(txb, args.value, `u64`)
        ],
    })
}

export function getCurrent(
    txb: TransactionBlock,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils_supply::get_current`,
        arguments: [
            obj(txb, supply)
        ],
    })
}

export function getMax(
    txb: TransactionBlock,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils_supply::get_max`,
        arguments: [
            obj(txb, supply)
        ],
    })
}

export function getRemaining(
    txb: TransactionBlock,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils_supply::get_remaining`,
        arguments: [
            obj(txb, supply)
        ],
    })
}

export interface IncreaseMaximumArgs {
    supply: ObjectArg; value: bigint | TransactionArgument
}

export function increaseMaximum(
    txb: TransactionBlock,
    args: IncreaseMaximumArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils_supply::increase_maximum`,
        arguments: [
            obj(txb, args.supply), pure(txb, args.value, `u64`)
        ],
    })
}

export interface MergeArgs {
    supply: ObjectArg; other: ObjectArg
}

export function merge(
    txb: TransactionBlock,
    args: MergeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils_supply::merge`,
        arguments: [
            obj(txb, args.supply), obj(txb, args.other)
        ],
    })
}
