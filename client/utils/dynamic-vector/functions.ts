import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function empty(
    txb: TransactionBlock,
    typeArg: string,
    limit: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::empty`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, limit, `u64`)
        ],
    })
}

export function popBack(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::pop_back`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}

export interface PushBackArgs {
    v: ObjectArg; elem: GenericArg
}

export function pushBack(
    txb: TransactionBlock,
    typeArg: string,
    args: PushBackArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::push_back`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), generic(txb, `${typeArg}`, args.elem)
        ],
    })
}

export interface SingletonArgs {
    e: GenericArg; limit: bigint | TransactionArgument
}

export function singleton(
    txb: TransactionBlock,
    typeArg: string,
    args: SingletonArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::singleton`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, args.e), pure(txb, args.limit, `u64`)
        ],
    })
}

export function delete_(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::delete`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}

export interface BorrowAtIndexArgs {
    v: ObjectArg; index: bigint | TransactionArgument
}

export function borrowAtIndex(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowAtIndexArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::borrow_at_index`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), pure(txb, args.index, `u64`)
        ],
    })
}

export interface BorrowChunkArgs {
    v: ObjectArg; chunkIdx: bigint | TransactionArgument
}

export function borrowChunk(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowChunkArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::borrow_chunk`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), pure(txb, args.chunkIdx, `u64`)
        ],
    })
}

export interface BorrowChunkMutArgs {
    v: ObjectArg; chunkIdx: bigint | TransactionArgument
}

export function borrowChunkMut(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowChunkMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::borrow_chunk_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), pure(txb, args.chunkIdx, `u64`)
        ],
    })
}

export interface ChunkIndexArgs {
    v: ObjectArg; idx: bigint | TransactionArgument
}

export function chunkIndex(
    txb: TransactionBlock,
    typeArg: string,
    args: ChunkIndexArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::chunk_index`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), pure(txb, args.idx, `u64`)
        ],
    })
}

export function currentChunk(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::current_chunk`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}

export interface HasChunkArgs {
    v: ObjectArg; chunkIdx: bigint | TransactionArgument
}

export function hasChunk(
    txb: TransactionBlock,
    typeArg: string,
    args: HasChunkArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::has_chunk`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), pure(txb, args.chunkIdx, `u64`)
        ],
    })
}

export interface InsertChunkArgs {
    v: ObjectArg; element: GenericArg
}

export function insertChunk(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertChunkArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::insert_chunk`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), generic(txb, `${typeArg}`, args.element)
        ],
    })
}

export interface PopAtIndexArgs {
    v: ObjectArg; index: bigint | TransactionArgument
}

export function popAtIndex(
    txb: TransactionBlock,
    typeArg: string,
    args: PopAtIndexArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::pop_at_index`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), pure(txb, args.index, `u64`)
        ],
    })
}

export function popElementFromChunk(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::pop_element_from_chunk`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}

export function popLastElement(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::pop_last_element`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}

export interface PushElementToChunkArgs {
    v: ObjectArg; e: GenericArg
}

export function pushElementToChunk(
    txb: TransactionBlock,
    typeArg: string,
    args: PushElementToChunkArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::push_element_to_chunk`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), generic(txb, `${typeArg}`, args.e)
        ],
    })
}

export function removeChunk(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::remove_chunk`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}

export function tipLength(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::tip_length`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}

export function totalLength(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::dynamic_vector::total_length`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}
