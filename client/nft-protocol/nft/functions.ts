import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    witness: ObjectArg; name: string | TransactionArgument; url: ObjectArg
}

export function new_(
    txb: TransactionBlock,
    typeArg: string,
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::new`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), pure(txb, args.name, `0x1::string::String`), obj(txb, args.url)
        ],
    })
}

export function name(
    txb: TransactionBlock,
    typeArg: string,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::name`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function borrowUid(
    txb: TransactionBlock,
    typeArg: string,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::borrow_uid`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function delete_(
    txb: TransactionBlock,
    typeArg: string,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::delete`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function url(
    txb: TransactionBlock,
    typeArg: string,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::url`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface NewDisplayArgs {
    witness: ObjectArg; pub: ObjectArg
}

export function newDisplay(
    txb: TransactionBlock,
    typeArg: string,
    args: NewDisplayArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::new_display`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.pub)
        ],
    })
}

export interface SetNameArgs {
    witness: ObjectArg; nft: ObjectArg; name: string | TransactionArgument
}

export function setName(
    txb: TransactionBlock,
    typeArg: string,
    args: SetNameArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::set_name`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.nft), pure(txb, args.name, `0x1::string::String`)
        ],
    })
}

export interface New_Args {
    name: string | TransactionArgument; url: ObjectArg
}

export function new__(
    txb: TransactionBlock,
    typeArg: string,
    args: New_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::new_`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.name, `0x1::string::String`), obj(txb, args.url)
        ],
    })
}

export interface AddDomainArgs {
    witness: ObjectArg; nft: ObjectArg; domain: GenericArg
}

export function addDomain(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AddDomainArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::add_domain`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.nft), generic(txb, `${typeArgs[1]}`, args.domain)
        ],
    })
}

export function assertDomain(
    txb: TransactionBlock,
    typeArgs: [string, string],
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::assert_domain`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertNoDomain(
    txb: TransactionBlock,
    typeArgs: [string, string],
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::assert_no_domain`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function borrowDomain(
    txb: TransactionBlock,
    typeArgs: [string, string],
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::borrow_domain`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface BorrowDomainMutArgs {
    witness: ObjectArg; nft: ObjectArg
}

export function borrowDomainMut(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BorrowDomainMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::borrow_domain_mut`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.nft)
        ],
    })
}

export interface BorrowUidMutArgs {
    witness: ObjectArg; nft: ObjectArg
}

export function borrowUidMut(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowUidMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::borrow_uid_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.nft)
        ],
    })
}

export function hasDomain(
    txb: TransactionBlock,
    typeArgs: [string, string],
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::has_domain`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface RemoveDomainArgs {
    witness: ObjectArg; nft: ObjectArg
}

export function removeDomain(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: RemoveDomainArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::remove_domain`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.nft)
        ],
    })
}

export interface SetUrlArgs {
    witness: ObjectArg; nft: ObjectArg; url: ObjectArg
}

export function setUrl(
    txb: TransactionBlock,
    typeArg: string,
    args: SetUrlArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::set_url`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.nft), obj(txb, args.url)
        ],
    })
}

export interface FromMintCapArgs {
    mintCap: ObjectArg; name: string | TransactionArgument; url: ObjectArg
}

export function fromMintCap(
    txb: TransactionBlock,
    typeArg: string,
    args: FromMintCapArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft::from_mint_cap`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.mintCap), pure(txb, args.name, `0x1::string::String`), obj(txb, args.url)
        ],
    })
}
