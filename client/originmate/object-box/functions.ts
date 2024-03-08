import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj} from "../../_framework/util";
import {TransactionBlock} from "@mysten/sui.js/transactions";

export function borrow(
    txb: TransactionBlock,
    typeArg: string,
    ob: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_box::borrow`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, ob)
        ],
    })
}

export function borrowMut(
    txb: TransactionBlock,
    typeArg: string,
    ob: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_box::borrow_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, ob)
        ],
    })
}

export function empty(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_box::empty`,
        arguments: [],
    })
}

export function isEmpty(
    txb: TransactionBlock,
    ob: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_box::is_empty`,
        arguments: [
            obj(txb, ob)
        ],
    })
}

export function remove(
    txb: TransactionBlock,
    typeArg: string,
    ob: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_box::remove`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, ob)
        ],
    })
}

export interface AddArgs {
    ob: ObjectArg; v: GenericArg
}

export function add(
    txb: TransactionBlock,
    typeArg: string,
    args: AddArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_box::add`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.ob), generic(txb, `${typeArg}`, args.v)
        ],
    })
}

export function new_(
    txb: TransactionBlock,
    typeArg: string,
    object: GenericArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_box::new`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, object)
        ],
    })
}

export function hasObject(
    txb: TransactionBlock,
    typeArg: string,
    ob: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::object_box::has_object`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, ob)
        ],
    })
}
