import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function borrowUid(
    txb: TransactionBlock,
    typeArg: string,
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::borrow_uid`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, collection)
        ],
    })
}

export function delete_(
    txb: TransactionBlock,
    typeArg: string,
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::delete`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, collection)
        ],
    })
}

export function create(
    txb: TransactionBlock,
    typeArg: string,
    witness: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::create`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, witness)
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
        target: `${PUBLISHED_AT}::collection::new_display`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.pub)
        ],
    })
}

export function assertVersion(
    txb: TransactionBlock,
    typeArg: string,
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::assert_version`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, collection)
        ],
    })
}

export function assertVersionAndUpgrade(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::assert_version_and_upgrade`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface MigrateAsCreatorArgs {
    collection: ObjectArg; pub: ObjectArg
}

export function migrateAsCreator(
    txb: TransactionBlock,
    typeArg: string,
    args: MigrateAsCreatorArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::migrate_as_creator`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.collection), obj(txb, args.pub)
        ],
    })
}

export interface AddDomainArgs {
    witness: ObjectArg; collection: ObjectArg; domain: GenericArg
}

export function addDomain(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AddDomainArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::add_domain`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.collection), generic(txb, `${typeArgs[1]}`, args.domain)
        ],
    })
}

export function assertDomain(
    txb: TransactionBlock,
    typeArgs: [string, string],
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::assert_domain`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, collection)
        ],
    })
}

export function assertNoDomain(
    txb: TransactionBlock,
    typeArgs: [string, string],
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::assert_no_domain`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, collection)
        ],
    })
}

export function borrowDomain(
    txb: TransactionBlock,
    typeArgs: [string, string],
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::borrow_domain`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, collection)
        ],
    })
}

export interface BorrowDomainMutArgs {
    witness: ObjectArg; collection: ObjectArg
}

export function borrowDomainMut(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BorrowDomainMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::borrow_domain_mut`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.collection)
        ],
    })
}

export interface BorrowUidMutArgs {
    witness: ObjectArg; collection: ObjectArg
}

export function borrowUidMut(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowUidMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::borrow_uid_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.collection)
        ],
    })
}

export function create_(
    txb: TransactionBlock,
    typeArg: string,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::create_`,
        typeArguments: [typeArg],
        arguments: [],
    })
}

export function createFromOtw(
    txb: TransactionBlock,
    typeArgs: [string, string],
    witness: GenericArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::create_from_otw`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[0]}`, witness)
        ],
    })
}

export interface CreateWithMintCapArgs {
    witness: GenericArg; supply: (bigint | TransactionArgument | TransactionArgument | null)
}

export function createWithMintCap(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateWithMintCapArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::create_with_mint_cap`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[0]}`, args.witness), pure(txb, args.supply, `0x1::option::Option<u64>`)
        ],
    })
}

export function hasDomain(
    txb: TransactionBlock,
    typeArgs: [string, string],
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::has_domain`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, collection)
        ],
    })
}

export function initCollection(
    txb: TransactionBlock,
    typeArg: string,
    witness: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::init_collection`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, witness)
        ],
    })
}

export interface RemoveDomainArgs {
    witness: ObjectArg; collection: ObjectArg
}

export function removeDomain(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: RemoveDomainArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::collection::remove_domain`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.collection)
        ],
    })
}
