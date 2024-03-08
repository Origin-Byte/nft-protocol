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
        target: `${PUBLISHED_AT}::access_policy::drop`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}

export function assertVersion(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::assert_version`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function assertVersionAndUpgrade(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::assert_version_and_upgrade`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface MigrateAsCreatorArgs {
    self: ObjectArg; pub: ObjectArg
}

export function migrateAsCreator(
    txb: TransactionBlock,
    typeArg: string,
    args: MigrateAsCreatorArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::migrate_as_creator`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.pub)
        ],
    })
}

export interface MigrateAsPubArgs {
    self: ObjectArg; pub: ObjectArg
}

export function migrateAsPub(
    txb: TransactionBlock,
    typeArg: string,
    args: MigrateAsPubArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::migrate_as_pub`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.pub)
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
        target: `${PUBLISHED_AT}::access_policy::confirm`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.req)
        ],
    })
}

export interface AddFieldAccessArgs {
    witness: ObjectArg; collection: ObjectArg; addresses: Array<string | TransactionArgument> | TransactionArgument
}

export function addFieldAccess(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AddFieldAccessArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::add_field_access`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.collection), pure(txb, args.addresses, `vector<address>`)
        ],
    })
}

export interface AddFieldAccessToPolicyArgs {
    witness: ObjectArg; accessPolicy: ObjectArg; addresses: Array<string | TransactionArgument> | TransactionArgument
}

export function addFieldAccessToPolicy(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AddFieldAccessToPolicyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::add_field_access_to_policy`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.accessPolicy), pure(txb, args.addresses, `vector<address>`)
        ],
    })
}

export interface AddNewArgs {
    witness: ObjectArg; collection: ObjectArg
}

export function addNew(
    txb: TransactionBlock,
    typeArg: string,
    args: AddNewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::add_new`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.collection)
        ],
    })
}

export interface AddParentAccessArgs {
    witness: ObjectArg; collection: ObjectArg; addresses: Array<string | TransactionArgument> | TransactionArgument
}

export function addParentAccess(
    txb: TransactionBlock,
    typeArg: string,
    args: AddParentAccessArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::add_parent_access`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.collection), pure(txb, args.addresses, `vector<address>`)
        ],
    })
}

export interface AddParentAccessToPolicyArgs {
    witness: ObjectArg; accessPolicy: ObjectArg; addresses: Array<string | TransactionArgument> | TransactionArgument
}

export function addParentAccessToPolicy(
    txb: TransactionBlock,
    typeArg: string,
    args: AddParentAccessToPolicyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::add_parent_access_to_policy`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.accessPolicy), pure(txb, args.addresses, `vector<address>`)
        ],
    })
}

export interface AssertFieldAuthArgs {
    self: ObjectArg; field: ObjectArg
}

export function assertFieldAuth(
    txb: TransactionBlock,
    typeArg: string,
    args: AssertFieldAuthArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::assert_field_auth`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.field)
        ],
    })
}

export function assertNoAccessPolicy(
    txb: TransactionBlock,
    typeArgs: [string, string],
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::assert_no_access_policy`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, collection)
        ],
    })
}

export function assertParentAuth(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::assert_parent_auth`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface ConfirmFromCollectionArgs {
    collection: ObjectArg; req: ObjectArg
}

export function confirmFromCollection(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ConfirmFromCollectionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::confirm_from_collection`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.collection), obj(txb, args.req)
        ],
    })
}

export function createNew(
    txb: TransactionBlock,
    typeArg: string,
    witness: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::create_new`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, witness)
        ],
    })
}

export function emptyFieldAccess(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::empty_field_access`,
        arguments: [],
    })
}

export function emptyParentAccess(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::access_policy::empty_parent_access`,
        arguments: [],
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
        target: `${PUBLISHED_AT}::access_policy::enforce`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}
