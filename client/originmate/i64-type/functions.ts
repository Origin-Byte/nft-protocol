import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function isZero(
    txb: TransactionBlock,
    x: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i64_type::is_zero`,
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
        target: `${PUBLISHED_AT}::i64_type::abs`,
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
        target: `${PUBLISHED_AT}::i64_type::add`,
        arguments: [
            obj(txb, args.a), obj(txb, args.b)
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
        target: `${PUBLISHED_AT}::i64_type::compare`,
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
        target: `${PUBLISHED_AT}::i64_type::div`,
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
        target: `${PUBLISHED_AT}::i64_type::from`,
        arguments: [
            pure(txb, x, `u64`)
        ],
    })
}

export function isNeg(
    txb: TransactionBlock,
    x: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i64_type::is_neg`,
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
        target: `${PUBLISHED_AT}::i64_type::mul`,
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
        target: `${PUBLISHED_AT}::i64_type::neg`,
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
        target: `${PUBLISHED_AT}::i64_type::neg_from`,
        arguments: [
            pure(txb, x, `u64`)
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
        target: `${PUBLISHED_AT}::i64_type::sub`,
        arguments: [
            obj(txb, args.a), obj(txb, args.b)
        ],
    })
}

export function zero(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i64_type::zero`,
        arguments: [],
    })
}

export function asU64(
    txb: TransactionBlock,
    x: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::i64_type::as_u64`,
        arguments: [
            obj(txb, x)
        ],
    })
}
