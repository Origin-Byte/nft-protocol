import {PUBLISHED_AT} from "..";
import {pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface MulArgs {
    x: bigint | TransactionArgument; y: bigint | TransactionArgument
}

export function mul(
    txb: TransactionBlock,
    args: MulArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::math::mul`,
        arguments: [
            pure(txb, args.x, `u64`), pure(txb, args.y, `u64`)
        ],
    })
}

export interface DivRoundArgs {
    x: bigint | TransactionArgument; y: bigint | TransactionArgument
}

export function divRound(
    txb: TransactionBlock,
    args: DivRoundArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::math::div_round`,
        arguments: [
            pure(txb, args.x, `u64`), pure(txb, args.y, `u64`)
        ],
    })
}

export interface MulRoundArgs {
    x: bigint | TransactionArgument; y: bigint | TransactionArgument
}

export function mulRound(
    txb: TransactionBlock,
    args: MulRoundArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::math::mul_round`,
        arguments: [
            pure(txb, args.x, `u64`), pure(txb, args.y, `u64`)
        ],
    })
}
