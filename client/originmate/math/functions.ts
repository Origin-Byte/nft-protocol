import {PUBLISHED_AT} from "..";
import {pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface MaxArgs {
    a: bigint | TransactionArgument; b: bigint | TransactionArgument
}

export function max(
    txb: TransactionBlock,
    args: MaxArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::math::max`,
        arguments: [
            pure(txb, args.a, `u64`), pure(txb, args.b, `u64`)
        ],
    })
}

export interface MinArgs {
    a: bigint | TransactionArgument; b: bigint | TransactionArgument
}

export function min(
    txb: TransactionBlock,
    args: MinArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::math::min`,
        arguments: [
            pure(txb, args.a, `u64`), pure(txb, args.b, `u64`)
        ],
    })
}

export function sqrt(
    txb: TransactionBlock,
    a: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::math::sqrt`,
        arguments: [
            pure(txb, a, `u64`)
        ],
    })
}

export interface AverageArgs {
    a: bigint | TransactionArgument; b: bigint | TransactionArgument
}

export function average(
    txb: TransactionBlock,
    args: AverageArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::math::average`,
        arguments: [
            pure(txb, args.a, `u64`), pure(txb, args.b, `u64`)
        ],
    })
}

export interface CeilDivArgs {
    a: bigint | TransactionArgument; b: bigint | TransactionArgument
}

export function ceilDiv(
    txb: TransactionBlock,
    args: CeilDivArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::math::ceil_div`,
        arguments: [
            pure(txb, args.a, `u64`), pure(txb, args.b, `u64`)
        ],
    })
}

export interface ExpArgs {
    a: bigint | TransactionArgument; b: bigint | TransactionArgument
}

export function exp(
    txb: TransactionBlock,
    args: ExpArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::math::exp`,
        arguments: [
            pure(txb, args.a, `u64`), pure(txb, args.b, `u64`)
        ],
    })
}

export interface QuadraticArgs {
    x: bigint | TransactionArgument; a: bigint | TransactionArgument; b: bigint | TransactionArgument; c: bigint | TransactionArgument
}

export function quadratic(
    txb: TransactionBlock,
    args: QuadraticArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::math::quadratic`,
        arguments: [
            pure(txb, args.x, `u64`), pure(txb, args.a, `u64`), pure(txb, args.b, `u64`), pure(txb, args.c, `u64`)
        ],
    })
}

export interface SqrtRoundingArgs {
    a: bigint | TransactionArgument; rounding: number | TransactionArgument
}

export function sqrtRounding(
    txb: TransactionBlock,
    args: SqrtRoundingArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::math::sqrt_rounding`,
        arguments: [
            pure(txb, args.a, `u64`), pure(txb, args.rounding, `u8`)
        ],
    })
}
