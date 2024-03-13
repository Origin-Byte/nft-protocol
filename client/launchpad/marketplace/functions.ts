import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    admin: string | TransactionArgument; receiver: string | TransactionArgument; defaultFee: GenericArg
}

export function new_(
    txb: TransactionBlock,
    typeArg: string,
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::new`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.admin, `address`), pure(txb, args.receiver, `address`), generic(txb, `${typeArg}`, args.defaultFee)
        ],
    })
}

export function receiver(
    txb: TransactionBlock,
    marketplace: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::receiver`,
        arguments: [
            obj(txb, marketplace)
        ],
    })
}

export interface AddMemberArgs {
    marketplace: ObjectArg; member: string | TransactionArgument
}

export function addMember(
    txb: TransactionBlock,
    args: AddMemberArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::add_member`,
        arguments: [
            obj(txb, args.marketplace), pure(txb, args.member, `address`)
        ],
    })
}

export function assertVersion(
    txb: TransactionBlock,
    marketplace: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::assert_version`,
        arguments: [
            obj(txb, marketplace)
        ],
    })
}

export function assertVersionAndUpgrade(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::assert_version_and_upgrade`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface RemoveMemberArgs {
    marketplace: ObjectArg; member: string | TransactionArgument
}

export function removeMember(
    txb: TransactionBlock,
    args: RemoveMemberArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::remove_member`,
        arguments: [
            obj(txb, args.marketplace), pure(txb, args.member, `address`)
        ],
    })
}

export function admin(
    txb: TransactionBlock,
    marketplace: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::admin`,
        arguments: [
            obj(txb, marketplace)
        ],
    })
}

export function migrate(
    txb: TransactionBlock,
    marketplace: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::migrate`,
        arguments: [
            obj(txb, marketplace)
        ],
    })
}

export function assertListingAdminOrMember(
    txb: TransactionBlock,
    marketplace: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::assert_listing_admin_or_member`,
        arguments: [
            obj(txb, marketplace)
        ],
    })
}

export function assertMarketplaceAdmin(
    txb: TransactionBlock,
    marketplace: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::assert_marketplace_admin`,
        arguments: [
            obj(txb, marketplace)
        ],
    })
}

export function assertMarketplaceAdminOrMember(
    txb: TransactionBlock,
    marketplace: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::assert_marketplace_admin_or_member`,
        arguments: [
            obj(txb, marketplace)
        ],
    })
}

export function assertPermissionless(
    txb: TransactionBlock,
    marketplace: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::assert_permissionless`,
        arguments: [
            obj(txb, marketplace)
        ],
    })
}

export function defaultFee(
    txb: TransactionBlock,
    marketplace: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::default_fee`,
        arguments: [
            obj(txb, marketplace)
        ],
    })
}

export interface InitMarketplaceArgs {
    admin: string | TransactionArgument; receiver: string | TransactionArgument; defaultFee: GenericArg
}

export function initMarketplace(
    txb: TransactionBlock,
    typeArg: string,
    args: InitMarketplaceArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::init_marketplace`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.admin, `address`), pure(txb, args.receiver, `address`), generic(txb, `${typeArg}`, args.defaultFee)
        ],
    })
}

export function isAdminOrMember(
    txb: TransactionBlock,
    marketplace: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::is_admin_or_member`,
        arguments: [
            obj(txb, marketplace)
        ],
    })
}

export function makePermissionless(
    txb: TransactionBlock,
    marketplace: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::marketplace::make_permissionless`,
        arguments: [
            obj(txb, marketplace)
        ],
    })
}
