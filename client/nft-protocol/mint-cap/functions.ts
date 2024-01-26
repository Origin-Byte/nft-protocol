import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    witness: GenericArg; collectionId: string | TransactionArgument; supply: (bigint | TransactionArgument | TransactionArgument | null)
}

export function new_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::new`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[0]}`, args.witness), pure(txb, args.collectionId, `0x2::object::ID`), pure(txb, args.supply, `0x1::option::Option<u64>`)
        ],
    })
}

export interface SplitArgs {
    mintCap: ObjectArg; quantity: bigint | TransactionArgument
}

export function split(
    txb: TransactionBlock,
    typeArg: string,
    args: SplitArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::split`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.mintCap), pure(txb, args.quantity, `u64`)
        ],
    })
}

export function supply(
    txb: TransactionBlock,
    typeArg: string,
    mintCap: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, mintCap)
        ],
    })
}

export interface NewDisplayArgs {
    witness: ObjectArg; pub: ObjectArg
}

export function newDisplay(
    txb: TransactionBlock,
    typeArg: string,
    args: NewDisplayArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::new_display`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.pub)
        ],
    })
}

export interface MergeArgs {
    mintCap: ObjectArg; other: ObjectArg
}

export function merge(
    txb: TransactionBlock,
    typeArg: string,
    args: MergeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::merge`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.mintCap), obj(txb, args.other)
        ],
    })
}

export function assertLimited(
    txb: TransactionBlock,
    typeArg: string,
    mintCap: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::assert_limited`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, mintCap)
        ],
    })
}

export function assertUnlimited(
    txb: TransactionBlock,
    typeArg: string,
    mintCap: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::assert_unlimited`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, mintCap)
        ],
    })
}

export function borrowSupply(
    txb: TransactionBlock,
    typeArg: string,
    mintCap: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::borrow_supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, mintCap)
        ],
    })
}

export function collectionId(
    txb: TransactionBlock,
    typeArg: string,
    mintCap: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::collection_id`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, mintCap)
        ],
    })
}

export function deleteMintCap(
    txb: TransactionBlock,
    typeArg: string,
    mintCap: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::delete_mint_cap`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, mintCap)
        ],
    })
}

export function getSupply(
    txb: TransactionBlock,
    typeArg: string,
    mintCap: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::get_supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, mintCap)
        ],
    })
}

export function hasSupply(
    txb: TransactionBlock,
    typeArg: string,
    mintCap: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::has_supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, mintCap)
        ],
    })
}

export interface IncrementSupplyArgs {
    mintCap: ObjectArg; quantity: bigint | TransactionArgument
}

export function incrementSupply(
    txb: TransactionBlock,
    typeArg: string,
    args: IncrementSupplyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::increment_supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.mintCap), pure(txb, args.quantity, `u64`)
        ],
    })
}

export interface NewLimitedArgs {
    witness: GenericArg; collectionId: string | TransactionArgument; supply: bigint | TransactionArgument
}

export function newLimited(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: NewLimitedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::new_limited`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[0]}`, args.witness), pure(txb, args.collectionId, `0x2::object::ID`), pure(txb, args.supply, `u64`)
        ],
    })
}

export interface NewUnlimitedArgs {
    witness: GenericArg; collectionId: string | TransactionArgument
}

export function newUnlimited(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: NewUnlimitedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_cap::new_unlimited`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[0]}`, args.witness), pure(txb, args.collectionId, `0x2::object::ID`)
        ],
    })
}
