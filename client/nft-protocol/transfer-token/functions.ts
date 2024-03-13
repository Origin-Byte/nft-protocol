import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    witness: ObjectArg; futureRecipient: string | TransactionArgument
}

export function new_(
    txb: TransactionBlock,
    typeArg: string,
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_token::new`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), pure(txb, args.futureRecipient, `address`)
        ],
    })
}

export interface DropArgs {
    policy: ObjectArg; cap: ObjectArg
}

export function drop(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: DropArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_token::drop`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}

export interface ConfirmArgs {
    nft: GenericArg; token: ObjectArg; req: ObjectArg
}

export function confirm(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ConfirmArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_token::confirm`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[0]}`, args.nft), obj(txb, args.token), obj(txb, args.req)
        ],
    })
}

export interface EnforceArgs {
    policy: ObjectArg; cap: ObjectArg
}

export function enforce(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: EnforceArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_token::enforce`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}

export interface CreateAndTransferArgs {
    witness: ObjectArg; receiver: string | TransactionArgument; currentOwner: string | TransactionArgument
}

export function createAndTransfer(
    txb: TransactionBlock,
    typeArg: string,
    args: CreateAndTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_token::create_and_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), pure(txb, args.receiver, `address`), pure(txb, args.currentOwner, `address`)
        ],
    })
}
