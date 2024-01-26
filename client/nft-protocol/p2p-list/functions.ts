import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface TransferArgs {
    self: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument; nftId: string | TransactionArgument; source: ObjectArg; target: ObjectArg; signature: Array<number | TransactionArgument> | TransactionArgument; nonce: Array<number | TransactionArgument> | TransactionArgument
}

export function transfer(
    txb: TransactionBlock,
    typeArg: string,
    args: TransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::p2p_list::transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), pure(txb, args.authority, `vector<u8>`), pure(txb, args.nftId, `0x2::object::ID`), obj(txb, args.source), obj(txb, args.target), pure(txb, args.signature, `vector<u8>`), pure(txb, args.nonce, `vector<u8>`)
        ],
    })
}

export interface DropArgs {
    policy: ObjectArg; cap: ObjectArg
}

export function drop(
    txb: TransactionBlock,
    typeArg: string,
    args: DropArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::p2p_list::drop`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}

export interface Confirm_Args {
    self: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument; nftId: string | TransactionArgument; source: string | TransactionArgument; destination: string | TransactionArgument; nonce: Array<number | TransactionArgument> | TransactionArgument; signature: Array<number | TransactionArgument> | TransactionArgument
}

export function confirm_(
    txb: TransactionBlock,
    typeArg: string,
    args: Confirm_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::p2p_list::confirm_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), pure(txb, args.authority, `vector<u8>`), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.source, `address`), pure(txb, args.destination, `address`), pure(txb, args.nonce, `vector<u8>`), pure(txb, args.signature, `vector<u8>`)
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
        target: `${PUBLISHED_AT}::p2p_list::enforce`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}

export interface ConfirmTransfer_Args {
    self: ObjectArg; req: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument; nftId: string | TransactionArgument; nonce: Array<number | TransactionArgument> | TransactionArgument; signature: Array<number | TransactionArgument> | TransactionArgument; source: string | TransactionArgument; destination: string | TransactionArgument
}

export function confirmTransfer_(
    txb: TransactionBlock,
    typeArg: string,
    args: ConfirmTransfer_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::p2p_list::confirm_transfer_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.req), pure(txb, args.authority, `vector<u8>`), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.nonce, `vector<u8>`), pure(txb, args.signature, `vector<u8>`), pure(txb, args.source, `address`), pure(txb, args.destination, `address`)
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
        target: `${PUBLISHED_AT}::p2p_list::drop_`,
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
        target: `${PUBLISHED_AT}::p2p_list::enforce_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}

export interface TransferIntoNewKioskArgs {
    self: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument; nftId: string | TransactionArgument; source: ObjectArg; target: string | TransactionArgument; signature: Array<number | TransactionArgument> | TransactionArgument; nonce: Array<number | TransactionArgument> | TransactionArgument
}

export function transferIntoNewKiosk(
    txb: TransactionBlock,
    typeArg: string,
    args: TransferIntoNewKioskArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::p2p_list::transfer_into_new_kiosk`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), pure(txb, args.authority, `vector<u8>`), pure(txb, args.nftId, `0x2::object::ID`), obj(txb, args.source), pure(txb, args.target, `address`), pure(txb, args.signature, `vector<u8>`), pure(txb, args.nonce, `vector<u8>`)
        ],
    })
}
