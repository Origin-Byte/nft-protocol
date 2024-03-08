import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface AppendArgs {
    lhs: ObjectArg; other: ObjectArg
}

export function append(
    txb: TransactionBlock,
    typeArg: string,
    args: AppendArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::append`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.lhs), obj(txb, args.other)
        ],
    })
}

export interface BorrowArgs {
    v: ObjectArg; i: bigint | TransactionArgument
}

export function borrow(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::borrow`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), pure(txb, args.i, `u64`)
        ],
    })
}

export interface BorrowMutArgs {
    v: ObjectArg; i: bigint | TransactionArgument
}

export function borrowMut(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::borrow_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), pure(txb, args.i, `u64`)
        ],
    })
}

export interface ContainsArgs {
    v: ObjectArg; e: GenericArg
}

export function contains(
    txb: TransactionBlock,
    typeArg: string,
    args: ContainsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::contains`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), generic(txb, `${typeArg}`, args.e)
        ],
    })
}

export function destroyEmpty(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::destroy_empty`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}

export function empty(
    txb: TransactionBlock,
    typeArg: string,
    capacity: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::empty`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, capacity, `u64`)
        ],
    })
}

export interface IndexOfArgs {
    v: ObjectArg; e: GenericArg
}

export function indexOf(
    txb: TransactionBlock,
    typeArg: string,
    args: IndexOfArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::index_of`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), generic(txb, `${typeArg}`, args.e)
        ],
    })
}

export interface InsertArgs {
    v: ObjectArg; e: GenericArg; i: bigint | TransactionArgument
}

export function insert(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::insert`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), generic(txb, `${typeArg}`, args.e), pure(txb, args.i, `u64`)
        ],
    })
}

export function isEmpty(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::is_empty`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}

export function length(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::length`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}

export function popBack(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::pop_back`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}

export interface PushBackArgs {
    v: ObjectArg; e: GenericArg
}

export function pushBack(
    txb: TransactionBlock,
    typeArg: string,
    args: PushBackArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::push_back`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), generic(txb, `${typeArg}`, args.e)
        ],
    })
}

export interface RemoveArgs {
    v: ObjectArg; i: bigint | TransactionArgument
}

export function remove(
    txb: TransactionBlock,
    typeArg: string,
    args: RemoveArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::remove`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), pure(txb, args.i, `u64`)
        ],
    })
}

export function reverse(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::reverse`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}

export interface SingletonArgs {
    capacity: bigint | TransactionArgument; e: GenericArg
}

export function singleton(
    txb: TransactionBlock,
    typeArg: string,
    args: SingletonArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::singleton`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.capacity, `u64`), generic(txb, `${typeArg}`, args.e)
        ],
    })
}

export interface SwapArgs {
    v: ObjectArg; i: bigint | TransactionArgument; j: bigint | TransactionArgument
}

export function swap(
    txb: TransactionBlock,
    typeArg: string,
    args: SwapArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::swap`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), pure(txb, args.i, `u64`), pure(txb, args.j, `u64`)
        ],
    })
}

export interface SwapRemoveArgs {
    v: ObjectArg; i: bigint | TransactionArgument
}

export function swapRemove(
    txb: TransactionBlock,
    typeArg: string,
    args: SwapRemoveArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::swap_remove`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), pure(txb, args.i, `u64`)
        ],
    })
}

export function capacity(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::capacity`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}

export interface DecreaseCapacityArgs {
    v: ObjectArg; bump: bigint | TransactionArgument
}

export function decreaseCapacity(
    txb: TransactionBlock,
    typeArg: string,
    args: DecreaseCapacityArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::decrease_capacity`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), pure(txb, args.bump, `u64`)
        ],
    })
}

export interface IncreaseCapacityArgs {
    v: ObjectArg; bump: bigint | TransactionArgument
}

export function increaseCapacity(
    txb: TransactionBlock,
    typeArg: string,
    args: IncreaseCapacityArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::increase_capacity`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.v), pure(txb, args.bump, `u64`)
        ],
    })
}

export function slack(
    txb: TransactionBlock,
    typeArg: string,
    v: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::sized_vec::slack`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, v)
        ],
    })
}
