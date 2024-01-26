import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, vector} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function new_(
    txb: TransactionBlock,
    typeArg: string,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::new`,
        typeArguments: [typeArg],
        arguments: [],
    })
}

export function destroy(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::destroy`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function metadata(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::metadata`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface AddReceiptArgs {
    self: ObjectArg; rule: GenericArg
}

export function addReceipt(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AddReceiptArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::add_receipt`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), generic(txb, `${typeArgs[1]}`, args.rule)
        ],
    })
}

export function rules(
    txb: TransactionBlock,
    typeArg: string,
    policy: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::rules`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, policy)
        ],
    })
}

export function receipts(
    txb: TransactionBlock,
    typeArg: string,
    request: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::receipts`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, request)
        ],
    })
}

export function newPolicy(
    txb: TransactionBlock,
    typeArg: string,
    witness: GenericArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::new_policy`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, witness)
        ],
    })
}

export function assertPublisher(
    txb: TransactionBlock,
    typeArg: string,
    pub: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::assert_publisher`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, pub)
        ],
    })
}

export function assertVersion(
    txb: TransactionBlock,
    typeArg: string,
    policy: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::assert_version`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, policy)
        ],
    })
}

export function assertVersionAndUpgrade(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::assert_version_and_upgrade`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface MigrateAsPubArgs {
    policy: ObjectArg; pub: ObjectArg
}

export function migrateAsPub(
    txb: TransactionBlock,
    typeArg: string,
    args: MigrateAsPubArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::migrate_as_pub`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.policy), obj(txb, args.pub)
        ],
    })
}

export interface MigrateArgs {
    policy: ObjectArg; cap: ObjectArg
}

export function migrate(
    txb: TransactionBlock,
    typeArg: string,
    args: MigrateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::migrate`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.policy), obj(txb, args.cap)
        ],
    })
}

export interface ConfirmArgs {
    self: ObjectArg; policy: ObjectArg
}

export function confirm(
    txb: TransactionBlock,
    typeArg: string,
    args: ConfirmArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::confirm`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.policy)
        ],
    })
}

export function metadataMut(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::metadata_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface Confirm_Args {
    completed: Array<ObjectArg> | TransactionArgument; rules: ObjectArg
}

export function confirm_(
    txb: TransactionBlock,
    args: Confirm_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::confirm_`,
        arguments: [
            vector(txb, `0x1::type_name::TypeName`, args.completed), obj(txb, args.rules)
        ],
    })
}

export interface DropRuleArgs {
    self: ObjectArg; cap: ObjectArg
}

export function dropRule(
    txb: TransactionBlock,
    typeArgs: [string, string, string],
    args: DropRuleArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::drop_rule`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.cap)
        ],
    })
}

export interface DropRuleNoStateArgs {
    self: ObjectArg; cap: ObjectArg
}

export function dropRuleNoState(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: DropRuleNoStateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::drop_rule_no_state`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.cap)
        ],
    })
}

export interface EnforceRuleArgs {
    self: ObjectArg; cap: ObjectArg; state: GenericArg
}

export function enforceRule(
    txb: TransactionBlock,
    typeArgs: [string, string, string],
    args: EnforceRuleArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::enforce_rule`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.cap), generic(txb, `${typeArgs[2]}`, args.state)
        ],
    })
}

export interface EnforceRuleNoStateArgs {
    self: ObjectArg; cap: ObjectArg
}

export function enforceRuleNoState(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: EnforceRuleNoStateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::enforce_rule_no_state`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.cap)
        ],
    })
}

export interface NewPolicyWithTypeArgs {
    witness: GenericArg; publisher: ObjectArg
}

export function newPolicyWithType(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: NewPolicyWithTypeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::new_policy_with_type`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.witness), obj(txb, args.publisher)
        ],
    })
}

export function policyCapFor(
    txb: TransactionBlock,
    policy: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::policy_cap_for`,
        arguments: [
            obj(txb, policy)
        ],
    })
}

export function policyMetadata(
    txb: TransactionBlock,
    typeArg: string,
    policy: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::policy_metadata`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, policy)
        ],
    })
}

export function policyMetadataMut(
    txb: TransactionBlock,
    typeArg: string,
    policy: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::policy_metadata_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, policy)
        ],
    })
}

export interface RuleStateArgs {
    self: ObjectArg; rule: GenericArg
}

export function ruleState(
    txb: TransactionBlock,
    typeArgs: [string, string, string],
    args: RuleStateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::rule_state`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), generic(txb, `${typeArgs[1]}`, args.rule)
        ],
    })
}

export interface RuleStateMutArgs {
    self: ObjectArg; rule: GenericArg
}

export function ruleStateMut(
    txb: TransactionBlock,
    typeArgs: [string, string, string],
    args: RuleStateMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::request::rule_state_mut`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), generic(txb, `${typeArgs[1]}`, args.rule)
        ],
    })
}
