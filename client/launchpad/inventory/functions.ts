import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function isEmpty(
    txb: TransactionBlock,
    typeArg: string,
    inventory: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::is_empty`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, inventory)
        ],
    })
}

export function supply(
    txb: TransactionBlock,
    typeArg: string,
    inventory: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, inventory)
        ],
    })
}

export interface DepositNftArgs {
    inventory: ObjectArg; nft: GenericArg
}

export function depositNft(
    txb: TransactionBlock,
    typeArg: string,
    args: DepositNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::deposit_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.inventory), generic(txb, `${typeArg}`, args.nft)
        ],
    })
}

export function redeemNft(
    txb: TransactionBlock,
    typeArg: string,
    inventory: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::redeem_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, inventory)
        ],
    })
}

export function redeemNftAndTransfer(
    txb: TransactionBlock,
    typeArg: string,
    inventory: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::redeem_nft_and_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, inventory)
        ],
    })
}

export interface RedeemNftAtIndexArgs {
    inventory: ObjectArg; index: bigint | TransactionArgument
}

export function redeemNftAtIndex(
    txb: TransactionBlock,
    typeArg: string,
    args: RedeemNftAtIndexArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::redeem_nft_at_index`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.inventory), pure(txb, args.index, `u64`)
        ],
    })
}

export interface RedeemNftAtIndexAndTransferArgs {
    inventory: ObjectArg; index: bigint | TransactionArgument
}

export function redeemNftAtIndexAndTransfer(
    txb: TransactionBlock,
    typeArg: string,
    args: RedeemNftAtIndexAndTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::redeem_nft_at_index_and_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.inventory), pure(txb, args.index, `u64`)
        ],
    })
}

export interface RedeemNftWithIdArgs {
    inventory: ObjectArg; nftId: string | TransactionArgument
}

export function redeemNftWithId(
    txb: TransactionBlock,
    typeArg: string,
    args: RedeemNftWithIdArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::redeem_nft_with_id`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.inventory), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface RedeemNftWithIdAndTransferArgs {
    inventory: ObjectArg; nftId: string | TransactionArgument
}

export function redeemNftWithIdAndTransfer(
    txb: TransactionBlock,
    typeArg: string,
    args: RedeemNftWithIdAndTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::redeem_nft_with_id_and_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.inventory), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export function redeemPseudorandomNft(
    txb: TransactionBlock,
    typeArg: string,
    inventory: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::redeem_pseudorandom_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, inventory)
        ],
    })
}

export function redeemPseudorandomNftAndTransfer(
    txb: TransactionBlock,
    typeArg: string,
    inventory: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::redeem_pseudorandom_nft_and_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, inventory)
        ],
    })
}

export interface RedeemRandomNftArgs {
    inventory: ObjectArg; commitment: ObjectArg; userCommitment: Array<number | TransactionArgument> | TransactionArgument
}

export function redeemRandomNft(
    txb: TransactionBlock,
    typeArg: string,
    args: RedeemRandomNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::redeem_random_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.inventory), obj(txb, args.commitment), pure(txb, args.userCommitment, `vector<u8>`)
        ],
    })
}

export interface RedeemRandomNftAndTransferArgs {
    inventory: ObjectArg; commitment: ObjectArg; userCommitment: Array<number | TransactionArgument> | TransactionArgument
}

export function redeemRandomNftAndTransfer(
    txb: TransactionBlock,
    typeArg: string,
    args: RedeemRandomNftAndTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::redeem_random_nft_and_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.inventory), obj(txb, args.commitment), pure(txb, args.userCommitment, `vector<u8>`)
        ],
    })
}

export function assertWarehouse(
    txb: TransactionBlock,
    typeArg: string,
    inventory: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::assert_warehouse`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, inventory)
        ],
    })
}

export function borrowWarehouse(
    txb: TransactionBlock,
    typeArg: string,
    inventory: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::borrow_warehouse`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, inventory)
        ],
    })
}

export function borrowWarehouseMut(
    txb: TransactionBlock,
    typeArg: string,
    inventory: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::borrow_warehouse_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, inventory)
        ],
    })
}

export function fromWarehouse(
    txb: TransactionBlock,
    typeArg: string,
    warehouse: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::from_warehouse`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, warehouse)
        ],
    })
}

export function isWarehouse(
    txb: TransactionBlock,
    typeArg: string,
    inventory: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::inventory::is_warehouse`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, inventory)
        ],
    })
}
