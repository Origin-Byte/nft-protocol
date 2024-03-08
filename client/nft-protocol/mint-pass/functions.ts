import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    mintCap: ObjectArg; supply: bigint | TransactionArgument
}

export function new_(
    txb: TransactionBlock,
    typeArg: string,
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_pass::new`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.mintCap), pure(txb, args.supply, `u64`)
        ],
    })
}

export interface SplitArgs {
    mintPass: ObjectArg; supply: bigint | TransactionArgument
}

export function split(
    txb: TransactionBlock,
    typeArg: string,
    args: SplitArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_pass::split`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.mintPass), pure(txb, args.supply, `u64`)
        ],
    })
}

export function supply(
    txb: TransactionBlock,
    typeArg: string,
    mintPass: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_pass::supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, mintPass)
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
        target: `${PUBLISHED_AT}::mint_pass::new_display`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.pub)
        ],
    })
}

export interface New_Args {
    mintCap: ObjectArg; supply: bigint | TransactionArgument
}

export function new__(
    txb: TransactionBlock,
    typeArg: string,
    args: New_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_pass::new_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.mintCap), pure(txb, args.supply, `u64`)
        ],
    })
}

export interface MergeArgs {
    mintPass: ObjectArg; other: ObjectArg
}

export function merge(
    txb: TransactionBlock,
    typeArg: string,
    args: MergeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_pass::merge`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.mintPass), obj(txb, args.other)
        ],
    })
}

export function borrowSupply(
    txb: TransactionBlock,
    typeArg: string,
    mintPass: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_pass::borrow_supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, mintPass)
        ],
    })
}

export function getSupply(
    txb: TransactionBlock,
    typeArg: string,
    mintPass: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_pass::get_supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, mintPass)
        ],
    })
}

export interface IncrementSupplyArgs {
    mintPass: ObjectArg; quantity: bigint | TransactionArgument
}

export function incrementSupply(
    txb: TransactionBlock,
    typeArg: string,
    args: IncrementSupplyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_pass::increment_supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.mintPass), pure(txb, args.quantity, `u64`)
        ],
    })
}

export function deleteMintPass(
    txb: TransactionBlock,
    typeArg: string,
    mintPass: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_pass::delete_mint_pass`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, mintPass)
        ],
    })
}

export interface NewWithMetadataArgs {
    mintCap: ObjectArg; supply: bigint | TransactionArgument; metadata: Array<number | TransactionArgument> | TransactionArgument
}

export function newWithMetadata(
    txb: TransactionBlock,
    typeArg: string,
    args: NewWithMetadataArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_pass::new_with_metadata`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.mintCap), pure(txb, args.supply, `u64`), pure(txb, args.metadata, `vector<u8>`)
        ],
    })
}

export interface NewWithMetadata_Args {
    mintCap: ObjectArg; supply: bigint | TransactionArgument; metadata: Array<number | TransactionArgument> | TransactionArgument
}

export function newWithMetadata_(
    txb: TransactionBlock,
    typeArg: string,
    args: NewWithMetadata_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_pass::new_with_metadata_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.mintCap), pure(txb, args.supply, `u64`), pure(txb, args.metadata, `vector<u8>`)
        ],
    })
}
