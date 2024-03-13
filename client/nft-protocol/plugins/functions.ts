import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj} from "../../_framework/util";
import {TransactionBlock} from "@mysten/sui.js/transactions";

export function new_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    witness: GenericArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::plugins::new`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, witness)
        ],
    })
}

export interface DelegateArgs {
    witness: GenericArg; plugins: ObjectArg
}

export function delegate(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: DelegateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::plugins::delegate`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.witness), obj(txb, args.plugins)
        ],
    })
}

export interface AddDomainArgs {
    nft: ObjectArg; domain: ObjectArg
}

export function addDomain(
    txb: TransactionBlock,
    typeArg: string,
    args: AddDomainArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::plugins::add_domain`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.nft), obj(txb, args.domain)
        ],
    })
}

export function borrowDomain(
    txb: TransactionBlock,
    typeArg: string,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::plugins::borrow_domain`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function borrowDomainMut(
    txb: TransactionBlock,
    typeArg: string,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::plugins::borrow_domain_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function hasDomain(
    txb: TransactionBlock,
    typeArg: string,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::plugins::has_domain`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function removeDomain(
    txb: TransactionBlock,
    typeArg: string,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::plugins::remove_domain`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface AddPluginArgs {
    witness: ObjectArg; plugins: ObjectArg
}

export function addPlugin(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AddPluginArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::plugins::add_plugin`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.plugins)
        ],
    })
}

export function assertNoPlugins(
    txb: TransactionBlock,
    typeArg: string,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::plugins::assert_no_plugins`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertPlugin(
    txb: TransactionBlock,
    typeArgs: [string, string],
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::plugins::assert_plugin`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, domain)
        ],
    })
}

export function assertPlugins(
    txb: TransactionBlock,
    typeArg: string,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::plugins::assert_plugins`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function containsPlugin(
    txb: TransactionBlock,
    typeArgs: [string, string],
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::plugins::contains_plugin`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, domain)
        ],
    })
}

export function getPlugins(
    txb: TransactionBlock,
    typeArg: string,
    plugin: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::plugins::get_plugins`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, plugin)
        ],
    })
}

export interface RemovePluginArgs {
    witness: ObjectArg; plugins: ObjectArg
}

export function removePlugin(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: RemovePluginArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::plugins::remove_plugin`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.plugins)
        ],
    })
}
