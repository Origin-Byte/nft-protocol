import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function new_(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::new`,
        arguments: [],
    })
}

export function assertPublisher(
    txb: TransactionBlock,
    typeArg: string,
    pub: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::assert_publisher`,
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
        target: `${PUBLISHED_AT}::authlist::init`,
        arguments: [
            obj(txb, otw)
        ],
    })
}

export function assertVersion(
    txb: TransactionBlock,
    authlist: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::assert_version`,
        arguments: [
            obj(txb, authlist)
        ],
    })
}

export function assertVersionAndUpgrade(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::assert_version_and_upgrade`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function addressToBytes(
    txb: TransactionBlock,
    addr: string | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::address_to_bytes`,
        arguments: [
            pure(txb, addr, `address`)
        ],
    })
}

export function assertAdminWitness(
    txb: TransactionBlock,
    typeArg: string,
    list: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::assert_admin_witness`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, list)
        ],
    })
}

export interface AssertAuthorityArgs {
    authlist: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument
}

export function assertAuthority(
    txb: TransactionBlock,
    args: AssertAuthorityArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::assert_authority`,
        arguments: [
            obj(txb, args.authlist), pure(txb, args.authority, `vector<u8>`)
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
        target: `${PUBLISHED_AT}::authlist::assert_cap`,
        arguments: [
            obj(txb, args.list), obj(txb, args.cap)
        ],
    })
}

export interface AssertCollectionArgs {
    authlist: ObjectArg; collection: ObjectArg
}

export function assertCollection(
    txb: TransactionBlock,
    args: AssertCollectionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::assert_collection`,
        arguments: [
            obj(txb, args.authlist), obj(txb, args.collection)
        ],
    })
}

export interface AssertTransferableArgs {
    authlist: ObjectArg; collection: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument; msg: Array<number | TransactionArgument> | TransactionArgument; signature: Array<number | TransactionArgument> | TransactionArgument
}

export function assertTransferable(
    txb: TransactionBlock,
    args: AssertTransferableArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::assert_transferable`,
        arguments: [
            obj(txb, args.authlist), obj(txb, args.collection), pure(txb, args.authority, `vector<u8>`), pure(txb, args.msg, `vector<u8>`), pure(txb, args.signature, `vector<u8>`)
        ],
    })
}

export function borrowAuthorities(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::borrow_authorities`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function borrowNames(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::borrow_names`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function clone(
    txb: TransactionBlock,
    authlist: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::clone`,
        arguments: [
            obj(txb, authlist)
        ],
    })
}

export interface ContainsAuthorityArgs {
    self: ObjectArg; auth: Array<number | TransactionArgument> | TransactionArgument
}

export function containsAuthority(
    txb: TransactionBlock,
    args: ContainsAuthorityArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::contains_authority`,
        arguments: [
            obj(txb, args.self), pure(txb, args.auth, `vector<u8>`)
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
        target: `${PUBLISHED_AT}::authlist::contains_collection`,
        arguments: [
            obj(txb, args.self), obj(txb, args.collection)
        ],
    })
}

export interface ContainsNameArgs {
    self: ObjectArg; auth: Array<number | TransactionArgument> | TransactionArgument
}

export function containsName(
    txb: TransactionBlock,
    args: ContainsNameArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::contains_name`,
        arguments: [
            obj(txb, args.self), pure(txb, args.auth, `vector<u8>`)
        ],
    })
}

export function deleteAuthlist(
    txb: TransactionBlock,
    authlist: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::delete_authlist`,
        arguments: [
            obj(txb, authlist)
        ],
    })
}

export function deleteOwnerCap(
    txb: TransactionBlock,
    ownerCap: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::delete_owner_cap`,
        arguments: [
            obj(txb, ownerCap)
        ],
    })
}

export function initAuthlist(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::init_authlist`,
        arguments: [],
    })
}

export function initCloned(
    txb: TransactionBlock,
    authlist: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::init_cloned`,
        arguments: [
            obj(txb, authlist)
        ],
    })
}

export interface InsertAuthorityArgs {
    cap: ObjectArg; self: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument
}

export function insertAuthority(
    txb: TransactionBlock,
    args: InsertAuthorityArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::insert_authority`,
        arguments: [
            obj(txb, args.cap), obj(txb, args.self), pure(txb, args.authority, `vector<u8>`)
        ],
    })
}

export interface InsertAuthority_Args {
    self: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument
}

export function insertAuthority_(
    txb: TransactionBlock,
    args: InsertAuthority_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::insert_authority_`,
        arguments: [
            obj(txb, args.self), pure(txb, args.authority, `vector<u8>`)
        ],
    })
}

export interface InsertAuthorityWithWitnessArgs {
    witness: GenericArg; self: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument
}

export function insertAuthorityWithWitness(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertAuthorityWithWitnessArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::insert_authority_with_witness`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, args.witness), obj(txb, args.self), pure(txb, args.authority, `vector<u8>`)
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
        target: `${PUBLISHED_AT}::authlist::insert_collection`,
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
        target: `${PUBLISHED_AT}::authlist::insert_collection_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface MigrateArgs {
    authlist: ObjectArg; cap: ObjectArg
}

export function migrate(
    txb: TransactionBlock,
    args: MigrateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::migrate`,
        arguments: [
            obj(txb, args.authlist), obj(txb, args.cap)
        ],
    })
}

export function newEmbedded(
    txb: TransactionBlock,
    typeArg: string,
    witness: GenericArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::new_embedded`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, witness)
        ],
    })
}

export interface NewEmbeddedWithAuthoritiesArgs {
    witness: GenericArg; authorities: ObjectArg; names: ObjectArg
}

export function newEmbeddedWithAuthorities(
    txb: TransactionBlock,
    typeArg: string,
    args: NewEmbeddedWithAuthoritiesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::new_embedded_with_authorities`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, args.witness), obj(txb, args.authorities), obj(txb, args.names)
        ],
    })
}

export function newWithAuthorities(
    txb: TransactionBlock,
    authorities: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::new_with_authorities`,
        arguments: [
            obj(txb, authorities)
        ],
    })
}

export interface RemoveAuthorityArgs {
    cap: ObjectArg; self: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument
}

export function removeAuthority(
    txb: TransactionBlock,
    args: RemoveAuthorityArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::remove_authority`,
        arguments: [
            obj(txb, args.cap), obj(txb, args.self), pure(txb, args.authority, `vector<u8>`)
        ],
    })
}

export interface RemoveAuthority_Args {
    self: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument
}

export function removeAuthority_(
    txb: TransactionBlock,
    args: RemoveAuthority_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::remove_authority_`,
        arguments: [
            obj(txb, args.self), pure(txb, args.authority, `vector<u8>`)
        ],
    })
}

export interface RemoveAuthorityWithWitnessArgs {
    witness: GenericArg; self: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument
}

export function removeAuthorityWithWitness(
    txb: TransactionBlock,
    typeArg: string,
    args: RemoveAuthorityWithWitnessArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::remove_authority_with_witness`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, args.witness), obj(txb, args.self), pure(txb, args.authority, `vector<u8>`)
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
        target: `${PUBLISHED_AT}::authlist::remove_collection`,
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
        target: `${PUBLISHED_AT}::authlist::remove_collection_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface SetNameArgs {
    cap: ObjectArg; self: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument; name: string | TransactionArgument
}

export function setName(
    txb: TransactionBlock,
    args: SetNameArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::set_name`,
        arguments: [
            obj(txb, args.cap), obj(txb, args.self), pure(txb, args.authority, `vector<u8>`), pure(txb, args.name, `0x1::string::String`)
        ],
    })
}

export interface SetName_Args {
    self: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument; name: string | TransactionArgument
}

export function setName_(
    txb: TransactionBlock,
    args: SetName_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::set_name_`,
        arguments: [
            obj(txb, args.self), pure(txb, args.authority, `vector<u8>`), pure(txb, args.name, `0x1::string::String`)
        ],
    })
}

export interface SetNameWithWitnessArgs {
    witness: GenericArg; self: ObjectArg; authority: Array<number | TransactionArgument> | TransactionArgument; name: string | TransactionArgument
}

export function setNameWithWitness(
    txb: TransactionBlock,
    typeArg: string,
    args: SetNameWithWitnessArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::authlist::set_name_with_witness`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, args.witness), obj(txb, args.self), pure(txb, args.authority, `vector<u8>`), pure(txb, args.name, `0x1::string::String`)
        ],
    })
}
