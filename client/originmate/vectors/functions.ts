import {PUBLISHED_AT} from "..";
import {GenericArg, pure, vector} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface FromVecToMapArgs {
    keys: Array<GenericArg> | TransactionArgument; values: Array<GenericArg> | TransactionArgument
}

export function fromVecToMap(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: FromVecToMapArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::vectors::from_vec_to_map`,
        typeArguments: typeArgs,
        arguments: [
            vector(txb, `${typeArgs[0]}`, args.keys), vector(txb, `${typeArgs[1]}`, args.values)
        ],
    })
}

export interface FindUpperBoundArgs {
    vec: Array<bigint | TransactionArgument> | TransactionArgument; element: bigint | TransactionArgument
}

export function findUpperBound(
    txb: TransactionBlock,
    args: FindUpperBoundArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::vectors::find_upper_bound`,
        arguments: [
            pure(txb, args.vec, `vector<u64>`), pure(txb, args.element, `u64`)
        ],
    })
}

export interface GtArgs {
    a: Array<number | TransactionArgument> | TransactionArgument; b: Array<number | TransactionArgument> | TransactionArgument
}

export function gt(
    txb: TransactionBlock,
    args: GtArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::vectors::gt`,
        arguments: [
            pure(txb, args.a, `vector<u8>`), pure(txb, args.b, `vector<u8>`)
        ],
    })
}

export interface GteArgs {
    a: Array<number | TransactionArgument> | TransactionArgument; b: Array<number | TransactionArgument> | TransactionArgument
}

export function gte(
    txb: TransactionBlock,
    args: GteArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::vectors::gte`,
        arguments: [
            pure(txb, args.a, `vector<u8>`), pure(txb, args.b, `vector<u8>`)
        ],
    })
}

export interface LtArgs {
    a: Array<number | TransactionArgument> | TransactionArgument; b: Array<number | TransactionArgument> | TransactionArgument
}

export function lt(
    txb: TransactionBlock,
    args: LtArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::vectors::lt`,
        arguments: [
            pure(txb, args.a, `vector<u8>`), pure(txb, args.b, `vector<u8>`)
        ],
    })
}

export interface LteArgs {
    a: Array<number | TransactionArgument> | TransactionArgument; b: Array<number | TransactionArgument> | TransactionArgument
}

export function lte(
    txb: TransactionBlock,
    args: LteArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::vectors::lte`,
        arguments: [
            pure(txb, args.a, `vector<u8>`), pure(txb, args.b, `vector<u8>`)
        ],
    })
}
