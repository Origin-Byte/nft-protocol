import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface SingletonArgs {
    witness: GenericArg; admin: string | TransactionArgument
}

export function singleton(
    txb: TransactionBlock,
    typeArg: string,
    args: SingletonArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::singleton`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, args.witness), pure(txb, args.admin, `address`)
        ],
    })
}

export interface CreateArgs {
    witness: GenericArg; admins: ObjectArg; members: ObjectArg; delegates: ObjectArg
}

export function create(
    txb: TransactionBlock,
    typeArg: string,
    args: CreateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::create`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, args.witness), obj(txb, args.admins), obj(txb, args.members), obj(txb, args.delegates)
        ],
    })
}

export interface AddAdminWithExtensionArgs {
    quorum: ObjectArg; extToken: ObjectArg; newAdmin: string | TransactionArgument
}

export function addAdminWithExtension(
    txb: TransactionBlock,
    typeArg: string,
    args: AddAdminWithExtensionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::add_admin_with_extension`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.quorum), obj(txb, args.extToken), pure(txb, args.newAdmin, `address`)
        ],
    })
}

export interface AddDelegateWithExtensionArgs {
    quorum: ObjectArg; extToken: ObjectArg; entity: string | TransactionArgument
}

export function addDelegateWithExtension(
    txb: TransactionBlock,
    typeArg: string,
    args: AddDelegateWithExtensionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::add_delegate_with_extension`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.quorum), obj(txb, args.extToken), pure(txb, args.entity, `0x2::object::ID`)
        ],
    })
}

export interface AddMemberArgs {
    quorum: ObjectArg; member: string | TransactionArgument
}

export function addMember(
    txb: TransactionBlock,
    typeArg: string,
    args: AddMemberArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::add_member`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.quorum), pure(txb, args.member, `address`)
        ],
    })
}

export function adminCount(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::admin_count`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function admins(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::admins`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function assertAdmin(
    txb: TransactionBlock,
    typeArg: string,
    quorum: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::assert_admin`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, quorum)
        ],
    })
}

export interface AssertDelegateArgs {
    quorum: ObjectArg; delegateUid: ObjectArg
}

export function assertDelegate(
    txb: TransactionBlock,
    typeArg: string,
    args: AssertDelegateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::assert_delegate`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.quorum), obj(txb, args.delegateUid)
        ],
    })
}

export interface AssertExtensionTokenArgs {
    quorum: ObjectArg; extToken: ObjectArg
}

export function assertExtensionToken(
    txb: TransactionBlock,
    typeArg: string,
    args: AssertExtensionTokenArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::assert_extension_token`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.quorum), obj(txb, args.extToken)
        ],
    })
}

export function assertMember(
    txb: TransactionBlock,
    typeArg: string,
    quorum: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::assert_member`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, quorum)
        ],
    })
}

export function assertMemberOrAdmin(
    txb: TransactionBlock,
    typeArg: string,
    quorum: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::assert_member_or_admin`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, quorum)
        ],
    })
}

export function assertVersion(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::assert_version`,
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
        target: `${PUBLISHED_AT}::quorum::assert_version_and_upgrade`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function borrowCap(
    txb: TransactionBlock,
    typeArgs: [string, string],
    quorum: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::borrow_cap`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, quorum)
        ],
    })
}

export interface BorrowCapAsDelegateArgs {
    quorum: ObjectArg; delegate: ObjectArg
}

export function borrowCapAsDelegate(
    txb: TransactionBlock,
    typeArgs: [string, string, string],
    args: BorrowCapAsDelegateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::borrow_cap_as_delegate`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.quorum), obj(txb, args.delegate)
        ],
    })
}

export function burnReceipt(
    txb: TransactionBlock,
    typeArgs: [string, string],
    receipt: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::burn_receipt`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, receipt)
        ],
    })
}

export function calcVotingThreshold(
    txb: TransactionBlock,
    adminCount: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::calc_voting_threshold`,
        arguments: [
            pure(txb, adminCount, `u64`)
        ],
    })
}

export function members(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::members`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function delegates(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::delegates`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface CreateForExtensionArgs {
    witness: GenericArg; admins: ObjectArg; members: ObjectArg; delegates: ObjectArg
}

export function createForExtension(
    txb: TransactionBlock,
    typeArg: string,
    args: CreateForExtensionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::create_for_extension`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, args.witness), obj(txb, args.admins), obj(txb, args.members), obj(txb, args.delegates)
        ],
    })
}

export function extensionTokenId(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::extension_token_id`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface InitQuorumArgs {
    witness: GenericArg; admins: ObjectArg; members: ObjectArg; delegates: ObjectArg
}

export function initQuorum(
    txb: TransactionBlock,
    typeArg: string,
    args: InitQuorumArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::init_quorum`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, args.witness), obj(txb, args.admins), obj(txb, args.members), obj(txb, args.delegates)
        ],
    })
}

export interface InsertCapArgs {
    quorum: ObjectArg; capObject: GenericArg; adminOnly: boolean | TransactionArgument
}

export function insertCap(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: InsertCapArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::insert_cap`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.quorum), generic(txb, `${typeArgs[1]}`, args.capObject), pure(txb, args.adminOnly, `bool`)
        ],
    })
}

export interface InsertCap_Args {
    quorum: ObjectArg; capObject: GenericArg; adminOnly: boolean | TransactionArgument
}

export function insertCap_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: InsertCap_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::insert_cap_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.quorum), generic(txb, `${typeArgs[1]}`, args.capObject), pure(txb, args.adminOnly, `bool`)
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
        target: `${PUBLISHED_AT}::quorum::migrate_as_creator`,
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
        target: `${PUBLISHED_AT}::quorum::migrate_as_pub`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.pub)
        ],
    })
}

export function quorumId(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::quorum_id`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface RemoveAdminWithExtensionArgs {
    quorum: ObjectArg; extToken: ObjectArg; oldAdmin: string | TransactionArgument
}

export function removeAdminWithExtension(
    txb: TransactionBlock,
    typeArg: string,
    args: RemoveAdminWithExtensionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::remove_admin_with_extension`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.quorum), obj(txb, args.extToken), pure(txb, args.oldAdmin, `address`)
        ],
    })
}

export interface RemoveDelegateWithExtensionArgs {
    quorum: ObjectArg; extToken: ObjectArg; entity: string | TransactionArgument
}

export function removeDelegateWithExtension(
    txb: TransactionBlock,
    typeArg: string,
    args: RemoveDelegateWithExtensionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::remove_delegate_with_extension`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.quorum), obj(txb, args.extToken), pure(txb, args.entity, `0x2::object::ID`)
        ],
    })
}

export interface RemoveMemberArgs {
    quorum: ObjectArg; member: string | TransactionArgument
}

export function removeMember(
    txb: TransactionBlock,
    typeArg: string,
    args: RemoveMemberArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::remove_member`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.quorum), pure(txb, args.member, `address`)
        ],
    })
}

export interface ReturnCapArgs {
    quorum: ObjectArg; capObject: GenericArg; receipt: ObjectArg
}

export function returnCap(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ReturnCapArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::return_cap`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.quorum), generic(txb, `${typeArgs[1]}`, args.capObject), obj(txb, args.receipt)
        ],
    })
}

export interface ReturnCap_Args {
    quorum: ObjectArg; capObject: GenericArg
}

export function returnCap_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ReturnCap_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::return_cap_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.quorum), generic(txb, `${typeArgs[1]}`, args.capObject)
        ],
    })
}

export interface ReturnCapAsDelegateArgs {
    quorum: ObjectArg; delegate: ObjectArg; capObject: GenericArg; receipt: ObjectArg
}

export function returnCapAsDelegate(
    txb: TransactionBlock,
    typeArgs: [string, string, string],
    args: ReturnCapAsDelegateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::return_cap_as_delegate`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.quorum), obj(txb, args.delegate), generic(txb, `${typeArgs[2]}`, args.capObject), obj(txb, args.receipt)
        ],
    })
}

export function sign(
    txb: TransactionBlock,
    typeArg: string,
    sigs: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::sign`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, sigs)
        ],
    })
}

export interface VoteArgs {
    quorum: ObjectArg; field: GenericArg
}

export function vote(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: VoteArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::vote`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.quorum), generic(txb, `${typeArgs[1]}`, args.field)
        ],
    })
}

export interface VoteAddAdminArgs {
    quorum: ObjectArg; newAdmin: string | TransactionArgument
}

export function voteAddAdmin(
    txb: TransactionBlock,
    typeArg: string,
    args: VoteAddAdminArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::vote_add_admin`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.quorum), pure(txb, args.newAdmin, `address`)
        ],
    })
}

export interface VoteAddDelegateArgs {
    quorum: ObjectArg; entity: string | TransactionArgument
}

export function voteAddDelegate(
    txb: TransactionBlock,
    typeArg: string,
    args: VoteAddDelegateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::vote_add_delegate`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.quorum), pure(txb, args.entity, `0x2::object::ID`)
        ],
    })
}

export interface VoteRemoveAdminArgs {
    quorum: ObjectArg; oldAdmin: string | TransactionArgument
}

export function voteRemoveAdmin(
    txb: TransactionBlock,
    typeArg: string,
    args: VoteRemoveAdminArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::vote_remove_admin`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.quorum), pure(txb, args.oldAdmin, `address`)
        ],
    })
}

export interface VoteRemoveDelegateArgs {
    quorum: ObjectArg; entity: string | TransactionArgument
}

export function voteRemoveDelegate(
    txb: TransactionBlock,
    typeArg: string,
    args: VoteRemoveDelegateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::quorum::vote_remove_delegate`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.quorum), pure(txb, args.entity, `0x2::object::ID`)
        ],
    })
}
