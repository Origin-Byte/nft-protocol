import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    mintCap: ObjectArg; supply: bigint | TransactionArgument; frozen: boolean | TransactionArgument
}

export function new_(
    txb: TransactionBlock,
    typeArg: string,
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::new`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.mintCap), pure(txb, args.supply, `u64`), pure(txb, args.frozen, `bool`)
        ],
    })
}

export function delete_(
    txb: TransactionBlock,
    typeArg: string,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::delete`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, supply)
        ],
    })
}

export interface DelegateArgs {
    supply: ObjectArg; quantity: bigint | TransactionArgument
}

export function delegate(
    txb: TransactionBlock,
    typeArg: string,
    args: DelegateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::delegate`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.supply), pure(txb, args.quantity, `u64`)
        ],
    })
}

export function getSupply(
    txb: TransactionBlock,
    typeArg: string,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::get_supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, supply)
        ],
    })
}

export interface AddDomainArgs {
    collection: ObjectArg; domain: ObjectArg
}

export function addDomain(
    txb: TransactionBlock,
    typeArg: string,
    args: AddDomainArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::add_domain`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.collection), obj(txb, args.domain)
        ],
    })
}

export function borrowDomain(
    txb: TransactionBlock,
    typeArg: string,
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::borrow_domain`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, collection)
        ],
    })
}

export function borrowDomainMut(
    txb: TransactionBlock,
    typeArg: string,
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::borrow_domain_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, collection)
        ],
    })
}

export function hasDomain(
    txb: TransactionBlock,
    typeArg: string,
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::has_domain`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, collection)
        ],
    })
}

export function removeDomain(
    txb: TransactionBlock,
    typeArg: string,
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::remove_domain`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, collection)
        ],
    })
}

export function assertFrozen(
    txb: TransactionBlock,
    typeArg: string,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::assert_frozen`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, domain)
        ],
    })
}

export function assertNotFrozen(
    txb: TransactionBlock,
    typeArg: string,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::assert_not_frozen`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, domain)
        ],
    })
}

export function assertRegulated(
    txb: TransactionBlock,
    typeArg: string,
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::assert_regulated`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, collection)
        ],
    })
}

export function assertUnregulated(
    txb: TransactionBlock,
    typeArg: string,
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::assert_unregulated`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, collection)
        ],
    })
}

export interface DecreaseMaxSupplyArgs {
    supply: ObjectArg; value: bigint | TransactionArgument
}

export function decreaseMaxSupply(
    txb: TransactionBlock,
    typeArg: string,
    args: DecreaseMaxSupplyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::decrease_max_supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.supply), pure(txb, args.value, `u64`)
        ],
    })
}

export interface DelegateAndTransferArgs {
    supply: ObjectArg; quantity: bigint | TransactionArgument; receiver: string | TransactionArgument
}

export function delegateAndTransfer(
    txb: TransactionBlock,
    typeArg: string,
    args: DelegateAndTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::delegate_and_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.supply), pure(txb, args.quantity, `u64`), pure(txb, args.receiver, `address`)
        ],
    })
}

export function freezeSupply(
    txb: TransactionBlock,
    typeArg: string,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::freeze_supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, supply)
        ],
    })
}

export interface IncreaseMaxSupplyArgs {
    supply: ObjectArg; value: bigint | TransactionArgument
}

export function increaseMaxSupply(
    txb: TransactionBlock,
    typeArg: string,
    args: IncreaseMaxSupplyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::increase_max_supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.supply), pure(txb, args.value, `u64`)
        ],
    })
}

export function isFrozen(
    txb: TransactionBlock,
    typeArg: string,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::is_frozen`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, supply)
        ],
    })
}

export interface MergeDelegatedArgs {
    supply: ObjectArg; delegated: ObjectArg
}

export function mergeDelegated(
    txb: TransactionBlock,
    typeArg: string,
    args: MergeDelegatedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_supply::merge_delegated`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.supply), obj(txb, args.delegated)
        ],
    })
}
