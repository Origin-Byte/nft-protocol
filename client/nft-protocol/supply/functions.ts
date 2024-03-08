import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    witness: ObjectArg; max: bigint | TransactionArgument; frozen: boolean | TransactionArgument
}

export function new_(
    txb: TransactionBlock,
    typeArg: string,
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::new`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), pure(txb, args.max, `u64`), pure(txb, args.frozen, `bool`)
        ],
    })
}

export function delete_(
    txb: TransactionBlock,
    typeArg: string,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::delete`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, supply)
        ],
    })
}

export interface SplitArgs {
    supply: ObjectArg; splitMax: bigint | TransactionArgument
}

export function split(
    txb: TransactionBlock,
    typeArg: string,
    args: SplitArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::split`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.supply), pure(txb, args.splitMax, `u64`)
        ],
    })
}

export interface IncrementArgs {
    witness: ObjectArg; supply: ObjectArg; value: bigint | TransactionArgument
}

export function increment(
    txb: TransactionBlock,
    typeArg: string,
    args: IncrementArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::increment`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.supply), pure(txb, args.value, `u64`)
        ],
    })
}

export function assertZero(
    txb: TransactionBlock,
    typeArg: string,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::assert_zero`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, supply)
        ],
    })
}

export interface DecrementArgs {
    witness: ObjectArg; supply: ObjectArg; value: bigint | TransactionArgument
}

export function decrement(
    txb: TransactionBlock,
    typeArg: string,
    args: DecrementArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::decrement`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.supply), pure(txb, args.value, `u64`)
        ],
    })
}

export function getCurrent(
    txb: TransactionBlock,
    typeArg: string,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::get_current`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, supply)
        ],
    })
}

export function getMax(
    txb: TransactionBlock,
    typeArg: string,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::get_max`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, supply)
        ],
    })
}

export function getRemaining(
    txb: TransactionBlock,
    typeArg: string,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::get_remaining`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, supply)
        ],
    })
}

export interface MergeArgs {
    supply: ObjectArg; other: ObjectArg
}

export function merge(
    txb: TransactionBlock,
    typeArg: string,
    args: MergeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::merge`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.supply), obj(txb, args.other)
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
        target: `${PUBLISHED_AT}::supply::add_domain`,
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
        target: `${PUBLISHED_AT}::supply::borrow_domain`,
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
        target: `${PUBLISHED_AT}::supply::borrow_domain_mut`,
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
        target: `${PUBLISHED_AT}::supply::has_domain`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function removeDomain(
    txb: TransactionBlock,
    typeArg: string,
    object: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::remove_domain`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, object)
        ],
    })
}

export interface AddNewArgs {
    witness: ObjectArg; object: ObjectArg; max: bigint | TransactionArgument; frozen: boolean | TransactionArgument
}

export function addNew(
    txb: TransactionBlock,
    typeArg: string,
    args: AddNewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::add_new`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.object), pure(txb, args.max, `u64`), pure(txb, args.frozen, `bool`)
        ],
    })
}

export function assertNotFrozen(
    txb: TransactionBlock,
    typeArg: string,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::assert_not_frozen`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, supply)
        ],
    })
}

export interface FreezeSupplyArgs {
    witness: ObjectArg; supply: ObjectArg
}

export function freezeSupply(
    txb: TransactionBlock,
    typeArg: string,
    args: FreezeSupplyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::freeze_supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.supply)
        ],
    })
}

export function isFrozen(
    txb: TransactionBlock,
    typeArg: string,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::is_frozen`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, supply)
        ],
    })
}

export function assertNoSupply(
    txb: TransactionBlock,
    typeArg: string,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::assert_no_supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertSupply(
    txb: TransactionBlock,
    typeArg: string,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::assert_supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function borrowInner(
    txb: TransactionBlock,
    typeArg: string,
    supply: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::borrow_inner`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, supply)
        ],
    })
}

export interface DecreaseSupplyCeilArgs {
    witness: ObjectArg; supply: ObjectArg; value: bigint | TransactionArgument
}

export function decreaseSupplyCeil(
    txb: TransactionBlock,
    typeArg: string,
    args: DecreaseSupplyCeilArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::decrease_supply_ceil`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.supply), pure(txb, args.value, `u64`)
        ],
    })
}

export interface DecreaseSupplyCeilNftArgs {
    witness: ObjectArg; object: ObjectArg; value: bigint | TransactionArgument
}

export function decreaseSupplyCeilNft(
    txb: TransactionBlock,
    typeArg: string,
    args: DecreaseSupplyCeilNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::decrease_supply_ceil_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.object), pure(txb, args.value, `u64`)
        ],
    })
}

export interface FreezeSupplyNftArgs {
    witness: ObjectArg; object: ObjectArg
}

export function freezeSupplyNft(
    txb: TransactionBlock,
    typeArg: string,
    args: FreezeSupplyNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::freeze_supply_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.object)
        ],
    })
}

export interface IncreaseSupplyCeilArgs {
    witness: ObjectArg; supply: ObjectArg; value: bigint | TransactionArgument
}

export function increaseSupplyCeil(
    txb: TransactionBlock,
    typeArg: string,
    args: IncreaseSupplyCeilArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::increase_supply_ceil`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.supply), pure(txb, args.value, `u64`)
        ],
    })
}

export interface IncreaseSupplyCeilNftArgs {
    witness: ObjectArg; object: ObjectArg; value: bigint | TransactionArgument
}

export function increaseSupplyCeilNft(
    txb: TransactionBlock,
    typeArg: string,
    args: IncreaseSupplyCeilNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::supply::increase_supply_ceil_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.object), pure(txb, args.value, `u64`)
        ],
    })
}
