import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function init(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::init`,
        arguments: [],
    })
}

export function bcsU128FromBytes(
    txb: TransactionBlock,
    bytes: Array<number | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::bcs_u128_from_bytes`,
        arguments: [
            pure(txb, bytes, `vector<u8>`)
        ],
    })
}

export function bcsU64FromBytes(
    txb: TransactionBlock,
    bytes: Array<number | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::bcs_u64_from_bytes`,
        arguments: [
            pure(txb, bytes, `vector<u8>`)
        ],
    })
}

export function bcsU8FromBytes(
    txb: TransactionBlock,
    bytes: Array<number | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::bcs_u8_from_bytes`,
        arguments: [
            pure(txb, bytes, `vector<u8>`)
        ],
    })
}

export function increment(
    txb: TransactionBlock,
    counter: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::increment`,
        arguments: [
            obj(txb, counter)
        ],
    })
}

export function nonceCounter(
    txb: TransactionBlock,
    counter: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::nonce_counter`,
        arguments: [
            obj(txb, counter)
        ],
    })
}

export function noncePrimitives(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::nonce_primitives`,
        arguments: [],
    })
}

export interface RandArgs {
    nonce: Array<number | TransactionArgument> | TransactionArgument; counter: ObjectArg
}

export function rand(
    txb: TransactionBlock,
    args: RandArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::rand`,
        arguments: [
            pure(txb, args.nonce, `vector<u8>`), obj(txb, args.counter)
        ],
    })
}

export function randNoCounter(
    txb: TransactionBlock,
    nonce: Array<number | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::rand_no_counter`,
        arguments: [
            pure(txb, nonce, `vector<u8>`)
        ],
    })
}

export interface RandNoCtxArgs {
    nonce: Array<number | TransactionArgument> | TransactionArgument; counter: ObjectArg
}

export function randNoCtx(
    txb: TransactionBlock,
    args: RandNoCtxArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::rand_no_ctx`,
        arguments: [
            pure(txb, args.nonce, `vector<u8>`), obj(txb, args.counter)
        ],
    })
}

export function randNoNonce(
    txb: TransactionBlock,
    counter: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::rand_no_nonce`,
        arguments: [
            obj(txb, counter)
        ],
    })
}

export function randWithCounter(
    txb: TransactionBlock,
    counter: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::rand_with_counter`,
        arguments: [
            obj(txb, counter)
        ],
    })
}

export function randWithCtx(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::rand_with_ctx`,
        arguments: [],
    })
}

export function randWithNonce(
    txb: TransactionBlock,
    nonce: Array<number | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::rand_with_nonce`,
        arguments: [
            pure(txb, nonce, `vector<u8>`)
        ],
    })
}

export interface SelectU64Args {
    bound: bigint | TransactionArgument; random: Array<number | TransactionArgument> | TransactionArgument
}

export function selectU64(
    txb: TransactionBlock,
    args: SelectU64Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::select_u64`,
        arguments: [
            pure(txb, args.bound, `u64`), pure(txb, args.random, `vector<u8>`)
        ],
    })
}

export function u128FromBytes(
    txb: TransactionBlock,
    bytes: Array<number | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::u128_from_bytes`,
        arguments: [
            pure(txb, bytes, `vector<u8>`)
        ],
    })
}

export function u256FromBytes(
    txb: TransactionBlock,
    bytes: Array<number | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::u256_from_bytes`,
        arguments: [
            pure(txb, bytes, `vector<u8>`)
        ],
    })
}

export function u64FromBytes(
    txb: TransactionBlock,
    bytes: Array<number | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::u64_from_bytes`,
        arguments: [
            pure(txb, bytes, `vector<u8>`)
        ],
    })
}

export function u8FromBytes(
    txb: TransactionBlock,
    bytes: Array<number | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::pseudorandom::u8_from_bytes`,
        arguments: [
            pure(txb, bytes, `vector<u8>`)
        ],
    })
}
