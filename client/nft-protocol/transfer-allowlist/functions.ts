import {PUBLISHED_AT} from "..";
import {ObjectArg, obj} from "../../_framework/util";
import {TransactionBlock} from "@mysten/sui.js/transactions";

export interface DropArgs {
    policy: ObjectArg; cap: ObjectArg
}

export function drop(
    txb: TransactionBlock,
    typeArg: string,
    args: DropArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_allowlist::drop`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}

export interface EnforceArgs {
    policy: ObjectArg; cap: ObjectArg
}

export function enforce(
    txb: TransactionBlock,
    typeArg: string,
    args: EnforceArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_allowlist::enforce`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}

export interface ConfirmTransfer_Args {
    self: ObjectArg; req: ObjectArg
}

export function confirmTransfer_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ConfirmTransfer_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_allowlist::confirm_transfer_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.req)
        ],
    })
}

export interface Drop_Args {
    policy: ObjectArg; cap: ObjectArg
}

export function drop_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: Drop_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_allowlist::drop_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}

export interface Enforce_Args {
    policy: ObjectArg; cap: ObjectArg
}

export function enforce_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: Enforce_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_allowlist::enforce_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}

export interface ConfirmTransferArgs {
    self: ObjectArg; req: ObjectArg
}

export function confirmTransfer(
    txb: TransactionBlock,
    typeArg: string,
    args: ConfirmTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_allowlist::confirm_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.req)
        ],
    })
}
