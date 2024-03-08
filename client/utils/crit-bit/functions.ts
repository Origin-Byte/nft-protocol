import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function destroyEmpty(
    txb: TransactionBlock,
    typeArg: string,
    tree: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::destroy_empty`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, tree)
        ],
    })
}

export function isEmpty(
    txb: TransactionBlock,
    typeArg: string,
    tree: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::is_empty`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, tree)
        ],
    })
}

export function new_(
    txb: TransactionBlock,
    typeArg: string,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::new`,
        typeArguments: [typeArg],
        arguments: [],
    })
}

export function size(
    txb: TransactionBlock,
    typeArg: string,
    tree: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::size`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, tree)
        ],
    })
}

export function drop(
    txb: TransactionBlock,
    typeArg: string,
    tree: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::drop`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, tree)
        ],
    })
}

export interface BorrowLeafByIndexArgs {
    tree: ObjectArg; index: bigint | TransactionArgument
}

export function borrowLeafByIndex(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowLeafByIndexArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::borrow_leaf_by_index`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.index, `u64`)
        ],
    })
}

export interface BorrowLeafByKeyArgs {
    tree: ObjectArg; key: bigint | TransactionArgument
}

export function borrowLeafByKey(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowLeafByKeyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::borrow_leaf_by_key`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.key, `u64`)
        ],
    })
}

export interface BorrowMutLeafByIndexArgs {
    tree: ObjectArg; index: bigint | TransactionArgument
}

export function borrowMutLeafByIndex(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowMutLeafByIndexArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::borrow_mut_leaf_by_index`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.index, `u64`)
        ],
    })
}

export interface BorrowMutLeafByKeyArgs {
    tree: ObjectArg; key: bigint | TransactionArgument
}

export function borrowMutLeafByKey(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowMutLeafByKeyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::borrow_mut_leaf_by_key`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.key, `u64`)
        ],
    })
}

export function countLeadingZeros(
    txb: TransactionBlock,
    x: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::count_leading_zeros`,
        arguments: [
            pure(txb, x, `u128`)
        ],
    })
}

export interface FindClosestKeyArgs {
    tree: ObjectArg; key: bigint | TransactionArgument
}

export function findClosestKey(
    txb: TransactionBlock,
    typeArg: string,
    args: FindClosestKeyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::find_closest_key`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.key, `u64`)
        ],
    })
}

export interface FindLeafArgs {
    tree: ObjectArg; key: bigint | TransactionArgument
}

export function findLeaf(
    txb: TransactionBlock,
    typeArg: string,
    args: FindLeafArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::find_leaf`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.key, `u64`)
        ],
    })
}

export interface GetClosestLeafIndexByKeyArgs {
    tree: ObjectArg; key: bigint | TransactionArgument
}

export function getClosestLeafIndexByKey(
    txb: TransactionBlock,
    typeArg: string,
    args: GetClosestLeafIndexByKeyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::get_closest_leaf_index_by_key`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.key, `u64`)
        ],
    })
}

export interface HasLeafArgs {
    tree: ObjectArg; key: bigint | TransactionArgument
}

export function hasLeaf(
    txb: TransactionBlock,
    typeArg: string,
    args: HasLeafArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::has_leaf`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.key, `u64`)
        ],
    })
}

export interface InsertLeafArgs {
    tree: ObjectArg; key: bigint | TransactionArgument; value: GenericArg
}

export function insertLeaf(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertLeafArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::insert_leaf`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.key, `u64`), generic(txb, `${typeArg}`, args.value)
        ],
    })
}

export interface IsLeftChildArgs {
    tree: ObjectArg; parentIndex: bigint | TransactionArgument; index: bigint | TransactionArgument
}

export function isLeftChild(
    txb: TransactionBlock,
    typeArg: string,
    args: IsLeftChildArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::is_left_child`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.parentIndex, `u64`), pure(txb, args.index, `u64`)
        ],
    })
}

export interface LeftMostLeafArgs {
    tree: ObjectArg; root: bigint | TransactionArgument
}

export function leftMostLeaf(
    txb: TransactionBlock,
    typeArg: string,
    args: LeftMostLeafArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::left_most_leaf`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.root, `u64`)
        ],
    })
}

export function maxLeaf(
    txb: TransactionBlock,
    typeArg: string,
    tree: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::max_leaf`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, tree)
        ],
    })
}

export function minLeaf(
    txb: TransactionBlock,
    typeArg: string,
    tree: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::min_leaf`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, tree)
        ],
    })
}

export interface NextLeafArgs {
    tree: ObjectArg; key: bigint | TransactionArgument
}

export function nextLeaf(
    txb: TransactionBlock,
    typeArg: string,
    args: NextLeafArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::next_leaf`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.key, `u64`)
        ],
    })
}

export interface PreviousLeafArgs {
    tree: ObjectArg; key: bigint | TransactionArgument
}

export function previousLeaf(
    txb: TransactionBlock,
    typeArg: string,
    args: PreviousLeafArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::previous_leaf`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.key, `u64`)
        ],
    })
}

export interface RemoveLeafByIndexArgs {
    tree: ObjectArg; index: bigint | TransactionArgument
}

export function removeLeafByIndex(
    txb: TransactionBlock,
    typeArg: string,
    args: RemoveLeafByIndexArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::remove_leaf_by_index`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.index, `u64`)
        ],
    })
}

export interface RemoveLeafByKeyArgs {
    tree: ObjectArg; key: bigint | TransactionArgument
}

export function removeLeafByKey(
    txb: TransactionBlock,
    typeArg: string,
    args: RemoveLeafByKeyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::remove_leaf_by_key`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.key, `u64`)
        ],
    })
}

export interface RightMostLeafArgs {
    tree: ObjectArg; root: bigint | TransactionArgument
}

export function rightMostLeaf(
    txb: TransactionBlock,
    typeArg: string,
    args: RightMostLeafArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::right_most_leaf`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.root, `u64`)
        ],
    })
}

export interface UpdateChildArgs {
    tree: ObjectArg; parentIndex: bigint | TransactionArgument; newChild: bigint | TransactionArgument; isLeftChild: boolean | TransactionArgument
}

export function updateChild(
    txb: TransactionBlock,
    typeArg: string,
    args: UpdateChildArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::update_child`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.parentIndex, `u64`), pure(txb, args.newChild, `u64`), pure(txb, args.isLeftChild, `bool`)
        ],
    })
}

export interface AssertHasLeafArgs {
    tree: ObjectArg; key: bigint | TransactionArgument
}

export function assertHasLeaf(
    txb: TransactionBlock,
    typeArg: string,
    args: AssertHasLeafArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::assert_has_leaf`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.tree), pure(txb, args.key, `u64`)
        ],
    })
}
