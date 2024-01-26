import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj} from "../../_framework/util";
import {TransactionBlock} from "@mysten/sui.js/transactions";

export function new_(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::new`,
        arguments: [],
    })
}

export function assertPublisher(
    txb: TransactionBlock,
    typeArg: string,
    pub: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::assert_publisher`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, pub)
        ],
    })
}

export function init(
    txb: TransactionBlock,
    otw: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::init`,
        arguments: [
            obj(txb, otw)
        ],
    })
}

export function assertVersion(
    txb: TransactionBlock,
    allowlist: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::assert_version`,
        arguments: [
            obj(txb, allowlist)
        ],
    })
}

export function assertVersionAndUpgrade(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::assert_version_and_upgrade`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function assertAdminWitness(
    txb: TransactionBlock,
    typeArg: string,
    list: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::assert_admin_witness`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, list)
        ],
    })
}

export interface AssertAuthorityArgs {
    allowlist: ObjectArg; auth: ObjectArg
}

export function assertAuthority(
    txb: TransactionBlock,
    args: AssertAuthorityArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::assert_authority`,
        arguments: [
            obj(txb, args.allowlist), obj(txb, args.auth)
        ],
    })
}

export interface AssertCapArgs {
    list: ObjectArg; cap: ObjectArg
}

export function assertCap(
    txb: TransactionBlock,
    args: AssertCapArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::assert_cap`,
        arguments: [
            obj(txb, args.list), obj(txb, args.cap)
        ],
    })
}

export interface AssertCollectionArgs {
    allowlist: ObjectArg; collection: ObjectArg
}

export function assertCollection(
    txb: TransactionBlock,
    args: AssertCollectionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::assert_collection`,
        arguments: [
            obj(txb, args.allowlist), obj(txb, args.collection)
        ],
    })
}

export interface AssertTransferableArgs {
    allowlist: ObjectArg; collection: ObjectArg; auth: ObjectArg
}

export function assertTransferable(
    txb: TransactionBlock,
    args: AssertTransferableArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::assert_transferable`,
        arguments: [
            obj(txb, args.allowlist), obj(txb, args.collection), obj(txb, args.auth)
        ],
    })
}

export function borrowAuthorities(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::borrow_authorities`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function clone(
    txb: TransactionBlock,
    allowlist: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::clone`,
        arguments: [
            obj(txb, allowlist)
        ],
    })
}

export interface ContainsAuthorityArgs {
    self: ObjectArg; auth: ObjectArg
}

export function containsAuthority(
    txb: TransactionBlock,
    args: ContainsAuthorityArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::contains_authority`,
        arguments: [
            obj(txb, args.self), obj(txb, args.auth)
        ],
    })
}

export interface ContainsCollectionArgs {
    self: ObjectArg; collection: ObjectArg
}

export function containsCollection(
    txb: TransactionBlock,
    args: ContainsCollectionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::contains_collection`,
        arguments: [
            obj(txb, args.self), obj(txb, args.collection)
        ],
    })
}

export function deleteOwnerCap(
    txb: TransactionBlock,
    ownerCap: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::delete_owner_cap`,
        arguments: [
            obj(txb, ownerCap)
        ],
    })
}

export function initCloned(
    txb: TransactionBlock,
    allowlist: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::init_cloned`,
        arguments: [
            obj(txb, allowlist)
        ],
    })
}

export interface InsertAuthorityArgs {
    cap: ObjectArg; self: ObjectArg
}

export function insertAuthority(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertAuthorityArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::insert_authority`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cap), obj(txb, args.self)
        ],
    })
}

export function insertAuthority_(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::insert_authority_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface InsertAuthorityWithWitnessArgs {
    witness: GenericArg; self: ObjectArg
}

export function insertAuthorityWithWitness(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: InsertAuthorityWithWitnessArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::insert_authority_with_witness`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[0]}`, args.witness), obj(txb, args.self)
        ],
    })
}

export interface InsertCollectionArgs {
    self: ObjectArg; collectionPub: ObjectArg
}

export function insertCollection(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertCollectionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::insert_collection`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.collectionPub)
        ],
    })
}

export function insertCollection_(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::insert_collection_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface MigrateArgs {
    allowlist: ObjectArg; cap: ObjectArg
}

export function migrate(
    txb: TransactionBlock,
    args: MigrateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::migrate`,
        arguments: [
            obj(txb, args.allowlist), obj(txb, args.cap)
        ],
    })
}

export function newEmbedded(
    txb: TransactionBlock,
    typeArg: string,
    witness: GenericArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::new_embedded`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, witness)
        ],
    })
}

export interface NewEmbeddedWithAuthoritiesArgs {
    witness: GenericArg; authorities: ObjectArg
}

export function newEmbeddedWithAuthorities(
    txb: TransactionBlock,
    typeArg: string,
    args: NewEmbeddedWithAuthoritiesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::new_embedded_with_authorities`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, args.witness), obj(txb, args.authorities)
        ],
    })
}

export function newWithAuthorities(
    txb: TransactionBlock,
    authorities: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::new_with_authorities`,
        arguments: [
            obj(txb, authorities)
        ],
    })
}

export interface RemoveAuthorityArgs {
    cap: ObjectArg; self: ObjectArg
}

export function removeAuthority(
    txb: TransactionBlock,
    typeArg: string,
    args: RemoveAuthorityArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::remove_authority`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cap), obj(txb, args.self)
        ],
    })
}

export function removeAuthority_(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::remove_authority_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface RemoveAuthorityWithWitnessArgs {
    witness: GenericArg; self: ObjectArg
}

export function removeAuthorityWithWitness(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: RemoveAuthorityWithWitnessArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::remove_authority_with_witness`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[0]}`, args.witness), obj(txb, args.self)
        ],
    })
}

export interface RemoveCollectionArgs {
    self: ObjectArg; collectionPub: ObjectArg
}

export function removeCollection(
    txb: TransactionBlock,
    typeArg: string,
    args: RemoveCollectionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::remove_collection`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.collectionPub)
        ],
    })
}

export function removeCollection_(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::remove_collection_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function deleteAllowlist(
    txb: TransactionBlock,
    allowlist: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::delete_allowlist`,
        arguments: [
            obj(txb, allowlist)
        ],
    })
}

export function initAllowlist(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::allowlist::init_allowlist`,
        arguments: [],
    })
}
