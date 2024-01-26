import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface BorrowArgs {
    table: ObjectArg; index: bigint | TransactionArgument
}

export function borrow(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_vec::borrow`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.table), pure(txb, args.index, `u64`)
        ],
    })
}

export interface BorrowMutArgs {
    table: ObjectArg; index: bigint | TransactionArgument
}

export function borrowMut(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_vec::borrow_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.table), pure(txb, args.index, `u64`)
        ],
    })
}

export interface ContainsArgs {
    table: ObjectArg; index: bigint | TransactionArgument
}

export function contains(
    txb: TransactionBlock,
    typeArg: string,
    args: ContainsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_vec::contains`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.table), pure(txb, args.index, `u64`)
        ],
    })
}

export function destroyEmpty(
    txb: TransactionBlock,
    typeArg: string,
    table: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_vec::destroy_empty`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, table)
        ],
    })
}

export function isEmpty(
    txb: TransactionBlock,
    typeArg: string,
    table: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_vec::is_empty`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, table)
        ],
    })
}

export function length(
    txb: TransactionBlock,
    typeArg: string,
    table: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_vec::length`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, table)
        ],
    })
}

export interface RemoveArgs {
    table: ObjectArg; index: bigint | TransactionArgument
}

export function remove(
    txb: TransactionBlock,
    typeArg: string,
    args: RemoveArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_vec::remove`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.table), pure(txb, args.index, `u64`)
        ],
    })
}

export interface AddArgs {
    table: ObjectArg; v: GenericArg
}

export function add(
    txb: TransactionBlock,
    typeArg: string,
    args: AddArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_vec::add`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.table), generic(txb, `${typeArg}`, args.v)
        ],
    })
}

export function new_(
    txb: TransactionBlock,
    typeArg: string,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_vec::new`,
        typeArguments: [typeArg],
        arguments: [],
    })
}

export interface ValueIdArgs {
    table: ObjectArg; index: bigint | TransactionArgument
}

export function valueId(
    txb: TransactionBlock,
    typeArg: string,
    args: ValueIdArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_vec::value_id`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.table), pure(txb, args.index, `u64`)
        ],
    })
}
