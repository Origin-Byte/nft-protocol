import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    witness: ObjectArg; collection: ObjectArg; royaltyFeeBps: number | TransactionArgument
}

export function new_(
    txb: TransactionBlock,
    typeArg: string,
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::new`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.collection), pure(txb, args.royaltyFeeBps, `u16`)
        ],
    })
}

export interface DisableArgs {
    witness: ObjectArg; self: ObjectArg
}

export function disable(
    txb: TransactionBlock,
    typeArg: string,
    args: DisableArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::disable`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.self)
        ],
    })
}

export interface EnableArgs {
    witness: ObjectArg; self: ObjectArg
}

export function enable(
    txb: TransactionBlock,
    typeArg: string,
    args: EnableArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::enable`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.self)
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
        target: `${PUBLISHED_AT}::royalty_strategy_bps::drop`,
        typeArguments: [typeArg],
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
        target: `${PUBLISHED_AT}::royalty_strategy_bps::assert_version`,
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
        target: `${PUBLISHED_AT}::royalty_strategy_bps::assert_version_and_upgrade`,
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
        target: `${PUBLISHED_AT}::royalty_strategy_bps::migrate_as_creator`,
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
        target: `${PUBLISHED_AT}::royalty_strategy_bps::migrate_as_pub`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.pub)
        ],
    })
}

export function share(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::share`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
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
        target: `${PUBLISHED_AT}::royalty_strategy_bps::enforce`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
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
        target: `${PUBLISHED_AT}::royalty_strategy_bps::drop_`,
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
        target: `${PUBLISHED_AT}::royalty_strategy_bps::enforce_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}

export interface AddBalanceAccessCapArgs {
    self: ObjectArg; cap: ObjectArg
}

export function addBalanceAccessCap(
    txb: TransactionBlock,
    typeArg: string,
    args: AddBalanceAccessCapArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::add_balance_access_cap`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.cap)
        ],
    })
}

export interface CalculateArgs {
    self: ObjectArg; amount: bigint | TransactionArgument
}

export function calculate(
    txb: TransactionBlock,
    typeArg: string,
    args: CalculateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::calculate`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), pure(txb, args.amount, `u64`)
        ],
    })
}

export interface CollectRoyaltiesArgs {
    collection: ObjectArg; strategy: ObjectArg
}

export function collectRoyalties(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CollectRoyaltiesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::collect_royalties`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.collection), obj(txb, args.strategy)
        ],
    })
}

export interface Compute_Args {
    bps: number | TransactionArgument; amount: bigint | TransactionArgument
}

export function compute_(
    txb: TransactionBlock,
    args: Compute_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::compute_`,
        arguments: [
            pure(txb, args.bps, `u16`), pure(txb, args.amount, `u64`)
        ],
    })
}

export interface ConfirmTransferArgs {
    self: ObjectArg; req: ObjectArg
}

export function confirmTransfer(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ConfirmTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::confirm_transfer`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.req)
        ],
    })
}

export interface ConfirmTransferWithBalanceArgs {
    self: ObjectArg; req: ObjectArg; wallet: ObjectArg
}

export function confirmTransferWithBalance(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ConfirmTransferWithBalanceArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::confirm_transfer_with_balance`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.req), obj(txb, args.wallet)
        ],
    })
}

export interface ConfirmTransferWithBalanceWithFeesArgs {
    self: ObjectArg; req: ObjectArg; wallet: ObjectArg
}

export function confirmTransferWithBalanceWithFees(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ConfirmTransferWithBalanceWithFeesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::confirm_transfer_with_balance_with_fees`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.req), obj(txb, args.wallet)
        ],
    })
}

export interface ConfirmTransferWithFeesArgs {
    self: ObjectArg; req: ObjectArg
}

export function confirmTransferWithFees(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ConfirmTransferWithFeesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::confirm_transfer_with_fees`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.req)
        ],
    })
}

export interface CreateDomainAndAddStrategyArgs {
    witness: ObjectArg; collection: ObjectArg; royaltyDomain: ObjectArg; bps: number | TransactionArgument
}

export function createDomainAndAddStrategy(
    txb: TransactionBlock,
    typeArg: string,
    args: CreateDomainAndAddStrategyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::create_domain_and_add_strategy`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.collection), obj(txb, args.royaltyDomain), pure(txb, args.bps, `u16`)
        ],
    })
}

export interface DropBalanceAccessCapArgs {
    witness: ObjectArg; self: ObjectArg
}

export function dropBalanceAccessCap(
    txb: TransactionBlock,
    typeArg: string,
    args: DropBalanceAccessCapArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::drop_balance_access_cap`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.self)
        ],
    })
}

export function royaltyFeeBps(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::royalty_fee_bps`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface SetRoyaltyFeeBpsArgs {
    witness: ObjectArg; self: ObjectArg; royaltyFeeBps: number | TransactionArgument
}

export function setRoyaltyFeeBps(
    txb: TransactionBlock,
    typeArg: string,
    args: SetRoyaltyFeeBpsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::set_royalty_fee_bps`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.self), pure(txb, args.royaltyFeeBps, `u16`)
        ],
    })
}

export interface SetRoyaltyFeeBpsWithPublisherArgs {
    publisher: ObjectArg; self: ObjectArg; royaltyFeeBps: number | TransactionArgument
}

export function setRoyaltyFeeBpsWithPublisher(
    txb: TransactionBlock,
    typeArg: string,
    args: SetRoyaltyFeeBpsWithPublisherArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty_strategy_bps::set_royalty_fee_bps_with_publisher`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.publisher), obj(txb, args.self), pure(txb, args.royaltyFeeBps, `u16`)
        ],
    })
}
