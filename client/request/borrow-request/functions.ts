import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, option, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    witness: GenericArg; nft: GenericArg; sender: string | TransactionArgument; field: (ObjectArg | TransactionArgument | null); promise: ObjectArg
}

export function new_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::new`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[0]}`, args.witness), generic(txb, `${typeArgs[1]}`, args.nft), pure(txb, args.sender, `address`), option(txb, `0x1::type_name::TypeName`, args.field), obj(txb, args.promise)
        ],
    })
}

export interface AddReceiptArgs {
    self: ObjectArg; rule: GenericArg
}

export function addReceipt(
    txb: TransactionBlock,
    typeArgs: [string, string, string],
    args: AddReceiptArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::add_receipt`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), generic(txb, `${typeArgs[2]}`, args.rule)
        ],
    })
}

export function field(
    txb: TransactionBlock,
    typeArgs: [string, string],
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::field`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface ConfirmArgs {
    witness: GenericArg; self: ObjectArg; policy: ObjectArg
}

export function confirm(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ConfirmArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::confirm`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[0]}`, args.witness), obj(txb, args.self), obj(txb, args.policy)
        ],
    })
}

export function initPolicy(
    txb: TransactionBlock,
    typeArg: string,
    publisher: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::init_policy`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, publisher)
        ],
    })
}

export function innerMut(
    txb: TransactionBlock,
    typeArgs: [string, string],
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::inner_mut`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function txSender(
    txb: TransactionBlock,
    typeArgs: [string, string],
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::tx_sender`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function assertIsBorrowField(
    txb: TransactionBlock,
    typeArgs: [string, string],
    request: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::assert_is_borrow_field`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, request)
        ],
    })
}

export function assertIsBorrowNft(
    txb: TransactionBlock,
    typeArgs: [string, string],
    request: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::assert_is_borrow_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, request)
        ],
    })
}

export interface BorrowFieldArgs {
    witness: ObjectArg; nftUid: ObjectArg
}

export function borrowField(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BorrowFieldArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::borrow_field`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.nftUid)
        ],
    })
}

export interface BorrowNftArgs {
    witness: ObjectArg; request: ObjectArg
}

export function borrowNft(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BorrowNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::borrow_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.request)
        ],
    })
}

export interface BorrowNftRefMutArgs {
    witness: ObjectArg; request: ObjectArg
}

export function borrowNftRefMut(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BorrowNftRefMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::borrow_nft_ref_mut`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.request)
        ],
    })
}

export function isBorrowField(
    txb: TransactionBlock,
    typeArgs: [string, string],
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::is_borrow_field`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function isBorrowNft(
    txb: TransactionBlock,
    typeArgs: [string, string],
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::is_borrow_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function nftId(
    txb: TransactionBlock,
    typeArgs: [string, string],
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::nft_id`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface ReturnFieldArgs {
    witness: ObjectArg; nftUid: ObjectArg; promise: ObjectArg; field: GenericArg
}

export function returnField(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ReturnFieldArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::return_field`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.nftUid), obj(txb, args.promise), generic(txb, `${typeArgs[1]}`, args.field)
        ],
    })
}

export interface ReturnNftArgs {
    witness: ObjectArg; request: ObjectArg; nft: GenericArg
}

export function returnNft(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ReturnNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::borrow_request::return_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.request), generic(txb, `${typeArgs[1]}`, args.nft)
        ],
    })
}
