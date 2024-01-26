import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface DropArgs {
    policy: ObjectArg; cap: ObjectArg
}

export function drop(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: DropArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::session_token::drop`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}

export interface ConfirmArgs {
    self: ObjectArg; req: ObjectArg
}

export function confirm(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ConfirmArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::session_token::confirm`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.req)
        ],
    })
}

export interface AssertFieldAuthArgs {
    self: ObjectArg; req: ObjectArg
}

export function assertFieldAuth(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AssertFieldAuthArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::session_token::assert_field_auth`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.req)
        ],
    })
}

export interface AssertParentAuthArgs {
    self: ObjectArg; req: ObjectArg
}

export function assertParentAuth(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AssertParentAuthArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::session_token::assert_parent_auth`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.req)
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
        target: `${PUBLISHED_AT}::session_token::enforce`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}

export interface IssueSessionTokenArgs {
    kiosk: ObjectArg; nftId: ObjectArg; receiver: string | TransactionArgument; expiryMs: bigint | TransactionArgument
}

export function issueSessionToken(
    txb: TransactionBlock,
    typeArg: string,
    args: IssueSessionTokenArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::session_token::issue_session_token`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.kiosk), obj(txb, args.nftId), pure(txb, args.receiver, `address`), pure(txb, args.expiryMs, `u64`)
        ],
    })
}

export interface IssueSessionTokenFieldArgs {
    kiosk: ObjectArg; nftId: ObjectArg; receiver: string | TransactionArgument; expiryMs: bigint | TransactionArgument
}

export function issueSessionTokenField(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: IssueSessionTokenFieldArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::session_token::issue_session_token_field`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.kiosk), obj(txb, args.nftId), pure(txb, args.receiver, `address`), pure(txb, args.expiryMs, `u64`)
        ],
    })
}
