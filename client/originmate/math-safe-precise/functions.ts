import {PUBLISHED_AT} from "..";
import {pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface QuadraticArgs {
    x: bigint | TransactionArgument; a: bigint | TransactionArgument; b: bigint | TransactionArgument; c: bigint | TransactionArgument
}

export function quadratic(
    txb: TransactionBlock,
    args: QuadraticArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::math_safe_precise::quadratic`,
        arguments: [
            pure(txb, args.x, `u64`), pure(txb, args.a, `u64`), pure(txb, args.b, `u64`), pure(txb, args.c, `u64`)
        ],
    })
}

export interface MulDivArgs {
    a: bigint | TransactionArgument; b: bigint | TransactionArgument; c: bigint | TransactionArgument
}

export function mulDiv(
    txb: TransactionBlock,
    args: MulDivArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::math_safe_precise::mul_div`,
        arguments: [
            pure(txb, args.a, `u64`), pure(txb, args.b, `u64`), pure(txb, args.c, `u64`)
        ],
    })
}
