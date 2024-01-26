import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function new_(
    txb: TransactionBlock,
    typeArg: string,
    sender: string | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::withdraw_request::new`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, sender, `address`)
        ],
    })
}

export interface AddReceiptArgs {
    self: ObjectArg; rule: GenericArg
}

export function addReceipt(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AddReceiptArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::withdraw_request::add_receipt`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), generic(txb, `${typeArgs[1]}`, args.rule)
        ],
    })
}

export interface ConfirmArgs {
    self: ObjectArg; policy: ObjectArg
}

export function confirm(
    txb: TransactionBlock,
    typeArg: string,
    args: ConfirmArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::withdraw_request::confirm`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.policy)
        ],
    })
}

export function initPolicy(
    txb: TransactionBlock,
    typeArg: string,
    publisher: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::withdraw_request::init_policy`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, publisher)
        ],
    })
}

export function innerMut(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::withdraw_request::inner_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function txSender(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::withdraw_request::tx_sender`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}
