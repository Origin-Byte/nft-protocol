import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj} from "../../_framework/util";
import {TransactionBlock} from "@mysten/sui.js/transactions";

export function new_(
    txb: TransactionBlock,
    inner: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::frozen_publisher::new`,
        arguments: [
            obj(txb, inner)
        ],
    })
}

export function publicFreezeObject(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::frozen_publisher::public_freeze_object`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface BorrowPublisherArgs {
    witness: ObjectArg; self: ObjectArg
}

export function borrowPublisher(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowPublisherArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::frozen_publisher::borrow_publisher`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.self)
        ],
    })
}

export function freezeFromOtw(
    txb: TransactionBlock,
    typeArg: string,
    otw: GenericArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::frozen_publisher::freeze_from_otw`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, otw)
        ],
    })
}

export function init(
    txb: TransactionBlock,
    otw: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::frozen_publisher::init`,
        arguments: [
            obj(txb, otw)
        ],
    })
}

export function mod(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::frozen_publisher::mod`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface NewDisplayArgs {
    parentWit: GenericArg; self: ObjectArg
}

export function newDisplay(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: NewDisplayArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::frozen_publisher::new_display`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[0]}`, args.parentWit), obj(txb, args.self)
        ],
    })
}

export function pkg(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::frozen_publisher::pkg`,
        arguments: [
            obj(txb, self)
        ],
    })
}
