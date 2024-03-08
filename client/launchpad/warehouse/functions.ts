import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function isEmpty(
    txb: TransactionBlock,
    typeArg: string,
    warehouse: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::is_empty`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, warehouse)
        ],
    })
}

export function new_(
    txb: TransactionBlock,
    typeArg: string,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::new`,
        typeArguments: [typeArg],
        arguments: [],
    })
}

export function supply(
    txb: TransactionBlock,
    typeArg: string,
    warehouse: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, warehouse)
        ],
    })
}

export function destroy(
    txb: TransactionBlock,
    typeArg: string,
    warehouse: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::destroy`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, warehouse)
        ],
    })
}

export function nfts(
    txb: TransactionBlock,
    typeArg: string,
    warehouse: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::nfts`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, warehouse)
        ],
    })
}

export function assertIsEmpty(
    txb: TransactionBlock,
    typeArg: string,
    warehouse: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::assert_is_empty`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, warehouse)
        ],
    })
}

export interface DepositNftArgs {
    warehouse: ObjectArg; nft: GenericArg
}

export function depositNft(
    txb: TransactionBlock,
    typeArg: string,
    args: DepositNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::deposit_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.warehouse), generic(txb, `${typeArg}`, args.nft)
        ],
    })
}

export function destroyCommitment(
    txb: TransactionBlock,
    commitment: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::destroy_commitment`,
        arguments: [
            obj(txb, commitment)
        ],
    })
}

export interface IdxWithIdArgs {
    warehouse: ObjectArg; nftId: string | TransactionArgument
}

export function idxWithId(
    txb: TransactionBlock,
    typeArg: string,
    args: IdxWithIdArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::idx_with_id`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.warehouse), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export function initRedeemCommitment(
    txb: TransactionBlock,
    hashedSenderCommitment: Array<number | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::init_redeem_commitment`,
        arguments: [
            pure(txb, hashedSenderCommitment, `vector<u8>`)
        ],
    })
}

export function initWarehouse(
    txb: TransactionBlock,
    typeArg: string,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::init_warehouse`,
        typeArguments: [typeArg],
        arguments: [],
    })
}

export function newRedeemCommitment(
    txb: TransactionBlock,
    hashedSenderCommitment: Array<number | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::new_redeem_commitment`,
        arguments: [
            pure(txb, hashedSenderCommitment, `vector<u8>`)
        ],
    })
}

export function redeemNft(
    txb: TransactionBlock,
    typeArg: string,
    warehouse: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::redeem_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, warehouse)
        ],
    })
}

export function redeemNftAndTransfer(
    txb: TransactionBlock,
    typeArg: string,
    warehouse: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::redeem_nft_and_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, warehouse)
        ],
    })
}

export interface RedeemNftAtIndexArgs {
    warehouse: ObjectArg; index: bigint | TransactionArgument
}

export function redeemNftAtIndex(
    txb: TransactionBlock,
    typeArg: string,
    args: RedeemNftAtIndexArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::redeem_nft_at_index`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.warehouse), pure(txb, args.index, `u64`)
        ],
    })
}

export interface RedeemNftAtIndexAndTransferArgs {
    warehouse: ObjectArg; index: bigint | TransactionArgument
}

export function redeemNftAtIndexAndTransfer(
    txb: TransactionBlock,
    typeArg: string,
    args: RedeemNftAtIndexAndTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::redeem_nft_at_index_and_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.warehouse), pure(txb, args.index, `u64`)
        ],
    })
}

export interface RedeemNftWithIdArgs {
    warehouse: ObjectArg; nftId: string | TransactionArgument
}

export function redeemNftWithId(
    txb: TransactionBlock,
    typeArg: string,
    args: RedeemNftWithIdArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::redeem_nft_with_id`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.warehouse), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface RedeemNftWithIdAndTransferArgs {
    warehouse: ObjectArg; nftId: string | TransactionArgument
}

export function redeemNftWithIdAndTransfer(
    txb: TransactionBlock,
    typeArg: string,
    args: RedeemNftWithIdAndTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::redeem_nft_with_id_and_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.warehouse), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export function redeemPseudorandomNft(
    txb: TransactionBlock,
    typeArg: string,
    warehouse: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::redeem_pseudorandom_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, warehouse)
        ],
    })
}

export function redeemPseudorandomNftAndTransfer(
    txb: TransactionBlock,
    typeArg: string,
    warehouse: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::redeem_pseudorandom_nft_and_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, warehouse)
        ],
    })
}

export interface RedeemRandomNftArgs {
    warehouse: ObjectArg; commitment: ObjectArg; userCommitment: Array<number | TransactionArgument> | TransactionArgument
}

export function redeemRandomNft(
    txb: TransactionBlock,
    typeArg: string,
    args: RedeemRandomNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::redeem_random_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.warehouse), obj(txb, args.commitment), pure(txb, args.userCommitment, `vector<u8>`)
        ],
    })
}

export interface RedeemRandomNftAndTransferArgs {
    warehouse: ObjectArg; commitment: ObjectArg; userCommitment: Array<number | TransactionArgument> | TransactionArgument
}

export function redeemRandomNftAndTransfer(
    txb: TransactionBlock,
    typeArg: string,
    args: RedeemRandomNftAndTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::redeem_random_nft_and_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.warehouse), obj(txb, args.commitment), pure(txb, args.userCommitment, `vector<u8>`)
        ],
    })
}

export interface SelectArgs {
    bound: bigint | TransactionArgument; random: Array<number | TransactionArgument> | TransactionArgument
}

export function select(
    txb: TransactionBlock,
    args: SelectArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::warehouse::select`,
        arguments: [
            pure(txb, args.bound, `u64`), pure(txb, args.random, `vector<u8>`)
        ],
    })
}
