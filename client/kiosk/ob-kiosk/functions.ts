import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, option, pure, vector} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function new_(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::new`,
        arguments: [],
    })
}

export function init(
    txb: TransactionBlock,
    otw: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::init`,
        arguments: [
            obj(txb, otw)
        ],
    })
}

export function assertVersion(
    txb: TransactionBlock,
    kioskUid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_version`,
        arguments: [
            obj(txb, kioskUid)
        ],
    })
}

export function assertVersionAndUpgrade(
    txb: TransactionBlock,
    kioskUid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_version_and_upgrade`,
        arguments: [
            obj(txb, kioskUid)
        ],
    })
}

export function borrowCap(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::borrow_cap`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface MigrateAsPubArgs {
    self: ObjectArg; pub: ObjectArg
}

export function migrateAsPub(
    txb: TransactionBlock,
    args: MigrateAsPubArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::migrate_as_pub`,
        arguments: [
            obj(txb, args.self), obj(txb, args.pub)
        ],
    })
}

export function migrate(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::migrate`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface BorrowNftArgs {
    self: ObjectArg; nftId: string | TransactionArgument
}

export function borrowNft(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::borrow_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface ReturnNftArgs {
    self: ObjectArg; borrowedNft: ObjectArg; policy: ObjectArg
}

export function returnNft(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ReturnNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::return_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.borrowedNft), obj(txb, args.policy)
        ],
    })
}

export function assertCanDeposit(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_can_deposit`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function assertCanDepositPermissionlessly(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_can_deposit_permissionlessly`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface AssertHasNftArgs {
    self: ObjectArg; nftId: string | TransactionArgument
}

export function assertHasNft(
    txb: TransactionBlock,
    args: AssertHasNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_has_nft`,
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export function assertIsObKiosk(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_is_ob_kiosk`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function assertIsPermissionless(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_is_permissionless`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface AssertKioskIdArgs {
    self: ObjectArg; id: string | TransactionArgument
}

export function assertKioskId(
    txb: TransactionBlock,
    args: AssertKioskIdArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_kiosk_id`,
        arguments: [
            obj(txb, args.self), pure(txb, args.id, `0x2::object::ID`)
        ],
    })
}

export interface AssertMissingRefArgs {
    refs: ObjectArg; nftId: string | TransactionArgument
}

export function assertMissingRef(
    txb: TransactionBlock,
    args: AssertMissingRefArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_missing_ref`,
        arguments: [
            obj(txb, args.refs), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface AssertNftTypeArgs {
    self: ObjectArg; nftId: string | TransactionArgument
}

export function assertNftType(
    txb: TransactionBlock,
    typeArg: string,
    args: AssertNftTypeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_nft_type`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface AssertNotExclusivelyListedArgs {
    self: ObjectArg; nftId: string | TransactionArgument
}

export function assertNotExclusivelyListed(
    txb: TransactionBlock,
    args: AssertNotExclusivelyListedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_not_exclusively_listed`,
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface AssertNotListedArgs {
    self: ObjectArg; nftId: string | TransactionArgument
}

export function assertNotListed(
    txb: TransactionBlock,
    args: AssertNotListedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_not_listed`,
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface AssertOwnerAddressArgs {
    self: ObjectArg; owner: string | TransactionArgument
}

export function assertOwnerAddress(
    txb: TransactionBlock,
    args: AssertOwnerAddressArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_owner_address`,
        arguments: [
            obj(txb, args.self), pure(txb, args.owner, `address`)
        ],
    })
}

export function assertPermission(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_permission`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function assertRefNotExclusivelyListed(
    txb: TransactionBlock,
    ref: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_ref_not_exclusively_listed`,
        arguments: [
            obj(txb, ref)
        ],
    })
}

export function assertRefNotListed(
    txb: TransactionBlock,
    ref: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::assert_ref_not_listed`,
        arguments: [
            obj(txb, ref)
        ],
    })
}

export interface AuthExclusiveTransferArgs {
    self: ObjectArg; nftId: string | TransactionArgument; entityId: ObjectArg
}

export function authExclusiveTransfer(
    txb: TransactionBlock,
    args: AuthExclusiveTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::auth_exclusive_transfer`,
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`), obj(txb, args.entityId)
        ],
    })
}

export interface AuthTransferArgs {
    self: ObjectArg; nftId: string | TransactionArgument; entity: string | TransactionArgument
}

export function authTransfer(
    txb: TransactionBlock,
    args: AuthTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::auth_transfer`,
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.entity, `address`)
        ],
    })
}

export interface BorrowNftMutArgs {
    self: ObjectArg; nftId: string | TransactionArgument; field: (ObjectArg | TransactionArgument | null)
}

export function borrowNftMut(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowNftMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::borrow_nft_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`), option(txb, `0x1::type_name::TypeName`, args.field)
        ],
    })
}

export function canDeposit(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::can_deposit`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function canDepositPermissionlessly(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::can_deposit_permissionlessly`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface CheckEntityAndPopRefArgs {
    self: ObjectArg; entity: string | TransactionArgument; nftId: string | TransactionArgument
}

export function checkEntityAndPopRef(
    txb: TransactionBlock,
    args: CheckEntityAndPopRefArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::check_entity_and_pop_ref`,
        arguments: [
            obj(txb, args.self), pure(txb, args.entity, `address`), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export function createForAddress(
    txb: TransactionBlock,
    owner: string | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::create_for_address`,
        arguments: [
            pure(txb, owner, `address`)
        ],
    })
}

export function createForSender(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::create_for_sender`,
        arguments: [],
    })
}

export function createPermissionless(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::create_permissionless`,
        arguments: [],
    })
}

export interface DelegateAuthArgs {
    self: ObjectArg; nftId: string | TransactionArgument; oldEntity: ObjectArg; newEntity: string | TransactionArgument
}

export function delegateAuth(
    txb: TransactionBlock,
    args: DelegateAuthArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::delegate_auth`,
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`), obj(txb, args.oldEntity), pure(txb, args.newEntity, `address`)
        ],
    })
}

export interface DelistNftAsOwnerArgs {
    self: ObjectArg; nftId: string | TransactionArgument
}

export function delistNftAsOwner(
    txb: TransactionBlock,
    args: DelistNftAsOwnerArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::delist_nft_as_owner`,
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface DepositArgs {
    self: ObjectArg; nft: GenericArg
}

export function deposit(
    txb: TransactionBlock,
    typeArg: string,
    args: DepositArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::deposit`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), generic(txb, `${typeArg}`, args.nft)
        ],
    })
}

export interface Deposit_Args {
    self: ObjectArg; cap: ObjectArg; nft: GenericArg
}

export function deposit_(
    txb: TransactionBlock,
    typeArg: string,
    args: Deposit_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::deposit_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.cap), generic(txb, `${typeArg}`, args.nft)
        ],
    })
}

export interface DepositBatchArgs {
    self: ObjectArg; nfts: Array<GenericArg> | TransactionArgument
}

export function depositBatch(
    txb: TransactionBlock,
    typeArg: string,
    args: DepositBatchArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::deposit_batch`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), vector(txb, `${typeArg}`, args.nfts)
        ],
    })
}

export function depositSettingMut(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::deposit_setting_mut`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function disableDepositsOfCollection(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::disable_deposits_of_collection`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function enableAnyDeposit(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::enable_any_deposit`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function enableDepositsOfCollection(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::enable_deposits_of_collection`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function getTransferRequestAuth(
    txb: TransactionBlock,
    typeArg: string,
    req: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::get_transfer_request_auth`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, req)
        ],
    })
}

export function getTransferRequestAuth_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    req: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::get_transfer_request_auth_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, req)
        ],
    })
}

export function initForAddress(
    txb: TransactionBlock,
    owner: string | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::init_for_address`,
        arguments: [
            pure(txb, owner, `address`)
        ],
    })
}

export function initForSender(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::init_for_sender`,
        arguments: [],
    })
}

export function initPermissionless(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::init_permissionless`,
        arguments: [],
    })
}

export interface InstallExtensionArgs {
    self: ObjectArg; kioskCap: ObjectArg
}

export function installExtension(
    txb: TransactionBlock,
    args: InstallExtensionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::install_extension`,
        arguments: [
            obj(txb, args.self), obj(txb, args.kioskCap)
        ],
    })
}

export interface InstallExtension_Args {
    self: ObjectArg; kioskCap: ObjectArg
}

export function installExtension_(
    txb: TransactionBlock,
    args: InstallExtension_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::install_extension_`,
        arguments: [
            obj(txb, args.self), obj(txb, args.kioskCap)
        ],
    })
}

export function isObKiosk(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::is_ob_kiosk`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function isObKioskImut(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::is_ob_kiosk_imut`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface IsOwnerArgs {
    self: ObjectArg; address: string | TransactionArgument
}

export function isOwner(
    txb: TransactionBlock,
    args: IsOwnerArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::is_owner`,
        arguments: [
            obj(txb, args.self), pure(txb, args.address, `address`)
        ],
    })
}

export function isPermissionless(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::is_permissionless`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function new__(
    txb: TransactionBlock,
    owner: string | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::new_`,
        arguments: [
            pure(txb, owner, `address`)
        ],
    })
}

export function newForAddress(
    txb: TransactionBlock,
    owner: string | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::new_for_address`,
        arguments: [
            pure(txb, owner, `address`)
        ],
    })
}

export function newPermissionless(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::new_permissionless`,
        arguments: [],
    })
}

export interface NftRefArgs {
    self: ObjectArg; nftId: string | TransactionArgument
}

export function nftRef(
    txb: TransactionBlock,
    args: NftRefArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::nft_ref`,
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface NftRefMutArgs {
    self: ObjectArg; nftId: string | TransactionArgument
}

export function nftRefMut(
    txb: TransactionBlock,
    args: NftRefMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::nft_ref_mut`,
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export function nftRefs(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::nft_refs`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function nftRefsMut(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::nft_refs_mut`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface P2pTransferArgs {
    source: ObjectArg; target: ObjectArg; nftId: string | TransactionArgument
}

export function p2pTransfer(
    txb: TransactionBlock,
    typeArg: string,
    args: P2pTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::p2p_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.source), obj(txb, args.target), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface P2pTransferAndCreateTargetKioskArgs {
    source: ObjectArg; target: string | TransactionArgument; nftId: string | TransactionArgument
}

export function p2pTransferAndCreateTargetKiosk(
    txb: TransactionBlock,
    typeArg: string,
    args: P2pTransferAndCreateTargetKioskArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::p2p_transfer_and_create_target_kiosk`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.source), pure(txb, args.target, `address`), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export function popCap(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::pop_cap`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface RegisterNftArgs {
    self: ObjectArg; nftId: string | TransactionArgument
}

export function registerNft(
    txb: TransactionBlock,
    typeArg: string,
    args: RegisterNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::register_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface RemoveAuthTransferArgs {
    self: ObjectArg; nftId: string | TransactionArgument; entity: ObjectArg
}

export function removeAuthTransfer(
    txb: TransactionBlock,
    args: RemoveAuthTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::remove_auth_transfer`,
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`), obj(txb, args.entity)
        ],
    })
}

export interface RemoveAuthTransferAsOwnerArgs {
    self: ObjectArg; nftId: string | TransactionArgument; entity: string | TransactionArgument
}

export function removeAuthTransferAsOwner(
    txb: TransactionBlock,
    args: RemoveAuthTransferAsOwnerArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::remove_auth_transfer_as_owner`,
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.entity, `address`)
        ],
    })
}

export interface RemoveAuthTransferSignedArgs {
    self: ObjectArg; nftId: string | TransactionArgument
}

export function removeAuthTransferSigned(
    txb: TransactionBlock,
    args: RemoveAuthTransferSignedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::remove_auth_transfer_signed`,
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface RemoveNftArgs {
    self: ObjectArg; nftId: string | TransactionArgument; originator: string | TransactionArgument
}

export function removeNft(
    txb: TransactionBlock,
    typeArg: string,
    args: RemoveNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::remove_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.originator, `address`)
        ],
    })
}

export function restrictDeposits(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::restrict_deposits`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface SetCapArgs {
    self: ObjectArg; cap: ObjectArg
}

export function setCap(
    txb: TransactionBlock,
    args: SetCapArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::set_cap`,
        arguments: [
            obj(txb, args.self), obj(txb, args.cap)
        ],
    })
}

export interface SetPermissionlessToPermissionedArgs {
    self: ObjectArg; user: string | TransactionArgument
}

export function setPermissionlessToPermissioned(
    txb: TransactionBlock,
    args: SetPermissionlessToPermissionedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::set_permissionless_to_permissioned`,
        arguments: [
            obj(txb, args.self), pure(txb, args.user, `address`)
        ],
    })
}

export interface SetTransferRequestAuthArgs {
    req: ObjectArg; auth: GenericArg
}

export function setTransferRequestAuth(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SetTransferRequestAuthArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::set_transfer_request_auth`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.req), generic(txb, `${typeArgs[1]}`, args.auth)
        ],
    })
}

export interface SetTransferRequestAuth_Args {
    req: ObjectArg; auth: GenericArg
}

export function setTransferRequestAuth_(
    txb: TransactionBlock,
    typeArgs: [string, string, string],
    args: SetTransferRequestAuth_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::set_transfer_request_auth_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.req), generic(txb, `${typeArgs[2]}`, args.auth)
        ],
    })
}

export interface TransferBetweenOwnedArgs {
    source: ObjectArg; target: ObjectArg; nftId: string | TransactionArgument
}

export function transferBetweenOwned(
    txb: TransactionBlock,
    typeArg: string,
    args: TransferBetweenOwnedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::transfer_between_owned`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.source), obj(txb, args.target), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface TransferBetweenOwned_Args {
    source: ObjectArg; target: ObjectArg; nftId: string | TransactionArgument
}

export function transferBetweenOwned_(
    txb: TransactionBlock,
    typeArg: string,
    args: TransferBetweenOwned_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::transfer_between_owned_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.source), obj(txb, args.target), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface TransferBetweenOwnedWithWitnessArgs {
    witness: ObjectArg; source: ObjectArg; target: ObjectArg; nftId: string | TransactionArgument
}

export function transferBetweenOwnedWithWitness(
    txb: TransactionBlock,
    typeArg: string,
    args: TransferBetweenOwnedWithWitnessArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::transfer_between_owned_with_witness`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.source), obj(txb, args.target), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface TransferDelegatedArgs {
    source: ObjectArg; target: ObjectArg; nftId: string | TransactionArgument; entityId: ObjectArg; price: bigint | TransactionArgument
}

export function transferDelegated(
    txb: TransactionBlock,
    typeArg: string,
    args: TransferDelegatedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::transfer_delegated`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.source), obj(txb, args.target), pure(txb, args.nftId, `0x2::object::ID`), obj(txb, args.entityId), pure(txb, args.price, `u64`)
        ],
    })
}

export interface TransferLockedNftArgs {
    source: ObjectArg; target: ObjectArg; nftId: string | TransactionArgument; entityId: ObjectArg
}

export function transferLockedNft(
    txb: TransactionBlock,
    typeArg: string,
    args: TransferLockedNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::transfer_locked_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.source), obj(txb, args.target), pure(txb, args.nftId, `0x2::object::ID`), obj(txb, args.entityId)
        ],
    })
}

export interface TransferNft_Args {
    self: ObjectArg; nftId: string | TransactionArgument; originator: string | TransactionArgument; price: bigint | TransactionArgument
}

export function transferNft_(
    txb: TransactionBlock,
    typeArg: string,
    args: TransferNft_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::transfer_nft_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.originator, `address`), pure(txb, args.price, `u64`)
        ],
    })
}

export interface TransferSignedArgs {
    source: ObjectArg; target: ObjectArg; nftId: string | TransactionArgument; price: bigint | TransactionArgument
}

export function transferSigned(
    txb: TransactionBlock,
    typeArg: string,
    args: TransferSignedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::transfer_signed`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.source), obj(txb, args.target), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.price, `u64`)
        ],
    })
}

export interface UninstallExtensionArgs {
    self: ObjectArg; ownerToken: ObjectArg
}

export function uninstallExtension(
    txb: TransactionBlock,
    args: UninstallExtensionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::uninstall_extension`,
        arguments: [
            obj(txb, args.self), obj(txb, args.ownerToken)
        ],
    })
}

export interface WithdrawNftArgs {
    self: ObjectArg; nftId: string | TransactionArgument; entityId: ObjectArg
}

export function withdrawNft(
    txb: TransactionBlock,
    typeArg: string,
    args: WithdrawNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::withdraw_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`), obj(txb, args.entityId)
        ],
    })
}

export interface WithdrawNft_Args {
    self: ObjectArg; nftId: string | TransactionArgument; originator: string | TransactionArgument
}

export function withdrawNft_(
    txb: TransactionBlock,
    typeArg: string,
    args: WithdrawNft_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::withdraw_nft_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.originator, `address`)
        ],
    })
}

export interface WithdrawNftSignedArgs {
    self: ObjectArg; nftId: string | TransactionArgument
}

export function withdrawNftSigned(
    txb: TransactionBlock,
    typeArg: string,
    args: WithdrawNftSignedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::ob_kiosk::withdraw_nft_signed`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}
