import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function isZero(
    txb: TransactionBlock,
    x: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i128_type::is_zero`,
        arguments: [
            obj(txb, x)
        ],
    })
}

export function abs(
    txb: TransactionBlock,
    x: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i128_type::abs`,
        arguments: [
            obj(txb, x)
        ],
    })
}

export interface AddArgs {
    a: ObjectArg; b: ObjectArg
}

export function add(
    txb: TransactionBlock,
    args: AddArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i128_type::add`,
        arguments: [
            obj(txb, args.a), obj(txb, args.b)
        ],
    })
}

export function asU128(
    txb: TransactionBlock,
    x: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i128_type::as_u128`,
        arguments: [
            obj(txb, x)
        ],
    })
}

export interface CompareArgs {
    a: ObjectArg; b: ObjectArg
}

export function compare(
    txb: TransactionBlock,
    args: CompareArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i128_type::compare`,
        arguments: [
            obj(txb, args.a), obj(txb, args.b)
        ],
    })
}

export interface DivArgs {
    a: ObjectArg; b: ObjectArg
}

export function div(
    txb: TransactionBlock,
    args: DivArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i128_type::div`,
        arguments: [
            obj(txb, args.a), obj(txb, args.b)
        ],
    })
}

export function from(
    txb: TransactionBlock,
    x: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i128_type::from`,
        arguments: [
            pure(txb, x, `u128`)
        ],
    })
}

export function isNeg(
    txb: TransactionBlock,
    x: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i128_type::is_neg`,
        arguments: [
            obj(txb, x)
        ],
    })
}

export interface MulArgs {
    a: ObjectArg; b: ObjectArg
}

export function mul(
    txb: TransactionBlock,
    args: MulArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i128_type::mul`,
        arguments: [
            obj(txb, args.a), obj(txb, args.b)
        ],
    })
}

export function neg(
    txb: TransactionBlock,
    x: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i128_type::neg`,
        arguments: [
            obj(txb, x)
        ],
    })
}

export function negFrom(
    txb: TransactionBlock,
    x: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i128_type::neg_from`,
        arguments: [
            pure(txb, x, `u128`)
        ],
    })
}

export interface SubArgs {
    a: ObjectArg; b: ObjectArg
}

export function sub(
    txb: TransactionBlock,
    args: SubArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i128_type::sub`,
        arguments: [
            obj(txb, args.a), obj(txb, args.b)
        ],
    })
}

export function zero(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i128_type::zero`,
        arguments: [],
    })
}
