import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface BorrowArgs {
    cb: ObjectArg; k: bigint | TransactionArgument
}

export function borrow(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::borrow`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`)
        ],
    })
}

export interface BorrowMutArgs {
    cb: ObjectArg; k: bigint | TransactionArgument
}

export function borrowMut(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::borrow_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`)
        ],
    })
}

export function destroyEmpty(
    txb: TransactionBlock,
    typeArg: string,
    cb: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::destroy_empty`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, cb)
        ],
    })
}

export function empty(
    txb: TransactionBlock,
    typeArg: string,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::empty`,
        typeArguments: [typeArg],
        arguments: [],
    })
}

export interface InsertArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; v: GenericArg
}

export function insert(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::insert`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), generic(txb, `${typeArg}`, args.v)
        ],
    })
}

export function isEmpty(
    txb: TransactionBlock,
    typeArg: string,
    cb: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::is_empty`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, cb)
        ],
    })
}

export function length(
    txb: TransactionBlock,
    typeArg: string,
    cb: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::length`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, cb)
        ],
    })
}

export interface SingletonArgs {
    k: bigint | TransactionArgument; v: GenericArg
}

export function singleton(
    txb: TransactionBlock,
    typeArg: string,
    args: SingletonArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::singleton`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.k, `u128`), generic(txb, `${typeArg}`, args.v)
        ],
    })
}

export interface PopArgs {
    cb: ObjectArg; k: bigint | TransactionArgument
}

export function pop(
    txb: TransactionBlock,
    typeArg: string,
    args: PopArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::pop`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`)
        ],
    })
}

export interface BSOArgs {
    cb: ObjectArg; k: bigint | TransactionArgument
}

export function bSO(
    txb: TransactionBlock,
    typeArg: string,
    args: BSOArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::b_s_o`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`)
        ],
    })
}

export interface BSOMArgs {
    cb: ObjectArg; k: bigint | TransactionArgument
}

export function bSOM(
    txb: TransactionBlock,
    typeArg: string,
    args: BSOMArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::b_s_o_m`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`)
        ],
    })
}

export function checkLen(
    txb: TransactionBlock,
    l: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::check_len`,
        arguments: [
            pure(txb, l, `u64`)
        ],
    })
}

export interface CritBitArgs {
    s1: bigint | TransactionArgument; s2: bigint | TransactionArgument
}

export function critBit(
    txb: TransactionBlock,
    args: CritBitArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::crit_bit`,
        arguments: [
            pure(txb, args.s1, `u128`), pure(txb, args.s2, `u128`)
        ],
    })
}

export interface HasKeyArgs {
    cb: ObjectArg; k: bigint | TransactionArgument
}

export function hasKey(
    txb: TransactionBlock,
    typeArg: string,
    args: HasKeyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::has_key`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`)
        ],
    })
}

export interface InsertAboveArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; v: GenericArg; nO: bigint | TransactionArgument; iNI: bigint | TransactionArgument; iSP: bigint | TransactionArgument; c: number | TransactionArgument
}

export function insertAbove(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertAboveArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::insert_above`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), generic(txb, `${typeArg}`, args.v), pure(txb, args.nO, `u64`), pure(txb, args.iNI, `u64`), pure(txb, args.iSP, `u64`), pure(txb, args.c, `u8`)
        ],
    })
}

export interface InsertAboveRootArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; v: GenericArg; nO: bigint | TransactionArgument; iNI: bigint | TransactionArgument; c: number | TransactionArgument
}

export function insertAboveRoot(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertAboveRootArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::insert_above_root`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), generic(txb, `${typeArg}`, args.v), pure(txb, args.nO, `u64`), pure(txb, args.iNI, `u64`), pure(txb, args.c, `u8`)
        ],
    })
}

export interface InsertBelowArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; v: GenericArg; nO: bigint | TransactionArgument; iNI: bigint | TransactionArgument; iSO: bigint | TransactionArgument; sSO: boolean | TransactionArgument; kSO: bigint | TransactionArgument; iSP: bigint | TransactionArgument; c: number | TransactionArgument
}

export function insertBelow(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertBelowArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::insert_below`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), generic(txb, `${typeArg}`, args.v), pure(txb, args.nO, `u64`), pure(txb, args.iNI, `u64`), pure(txb, args.iSO, `u64`), pure(txb, args.sSO, `bool`), pure(txb, args.kSO, `u128`), pure(txb, args.iSP, `u64`), pure(txb, args.c, `u8`)
        ],
    })
}

export interface InsertBelowWalkArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; v: GenericArg; nO: bigint | TransactionArgument; iNI: bigint | TransactionArgument; iNR: bigint | TransactionArgument; c: number | TransactionArgument
}

export function insertBelowWalk(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertBelowWalkArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::insert_below_walk`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), generic(txb, `${typeArg}`, args.v), pure(txb, args.nO, `u64`), pure(txb, args.iNI, `u64`), pure(txb, args.iNR, `u64`), pure(txb, args.c, `u8`)
        ],
    })
}

export interface InsertEmptyArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; v: GenericArg
}

export function insertEmpty(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertEmptyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::insert_empty`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), generic(txb, `${typeArg}`, args.v)
        ],
    })
}

export interface InsertGeneralArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; v: GenericArg; nO: bigint | TransactionArgument
}

export function insertGeneral(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertGeneralArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::insert_general`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), generic(txb, `${typeArg}`, args.v), pure(txb, args.nO, `u64`)
        ],
    })
}

export interface InsertSingletonArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; v: GenericArg
}

export function insertSingleton(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertSingletonArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::insert_singleton`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), generic(txb, `${typeArg}`, args.v)
        ],
    })
}

export function isOut(
    txb: TransactionBlock,
    i: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::is_out`,
        arguments: [
            pure(txb, i, `u64`)
        ],
    })
}

export interface IsSetArgs {
    k: bigint | TransactionArgument; b: number | TransactionArgument
}

export function isSet(
    txb: TransactionBlock,
    args: IsSetArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::is_set`,
        arguments: [
            pure(txb, args.k, `u128`), pure(txb, args.b, `u8`)
        ],
    })
}

export function maxKey(
    txb: TransactionBlock,
    typeArg: string,
    cb: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::max_key`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, cb)
        ],
    })
}

export function maxNodeCI(
    txb: TransactionBlock,
    typeArg: string,
    cb: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::max_node_c_i`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, cb)
        ],
    })
}

export function minKey(
    txb: TransactionBlock,
    typeArg: string,
    cb: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::min_key`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, cb)
        ],
    })
}

export function minNodeCI(
    txb: TransactionBlock,
    typeArg: string,
    cb: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::min_node_c_i`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, cb)
        ],
    })
}

export function oC(
    txb: TransactionBlock,
    v: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::o_c`,
        arguments: [
            pure(txb, v, `u64`)
        ],
    })
}

export function oV(
    txb: TransactionBlock,
    c: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::o_v`,
        arguments: [
            pure(txb, c, `u64`)
        ],
    })
}

export interface PopDestroyNodesArgs {
    cb: ObjectArg; iI: bigint | TransactionArgument; iO: bigint | TransactionArgument; nO: bigint | TransactionArgument
}

export function popDestroyNodes(
    txb: TransactionBlock,
    typeArg: string,
    args: PopDestroyNodesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::pop_destroy_nodes`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.iI, `u64`), pure(txb, args.iO, `u64`), pure(txb, args.nO, `u64`)
        ],
    })
}

export interface PopGeneralArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; nO: bigint | TransactionArgument
}

export function popGeneral(
    txb: TransactionBlock,
    typeArg: string,
    args: PopGeneralArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::pop_general`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), pure(txb, args.nO, `u64`)
        ],
    })
}

export interface PopSingletonArgs {
    cb: ObjectArg; k: bigint | TransactionArgument
}

export function popSingleton(
    txb: TransactionBlock,
    typeArg: string,
    args: PopSingletonArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::pop_singleton`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`)
        ],
    })
}

export interface PopUpdateRelationshipsArgs {
    cb: ObjectArg; sC: boolean | TransactionArgument; iP: bigint | TransactionArgument
}

export function popUpdateRelationships(
    txb: TransactionBlock,
    typeArg: string,
    args: PopUpdateRelationshipsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::pop_update_relationships`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.sC, `bool`), pure(txb, args.iP, `u64`)
        ],
    })
}

export interface PushBackInsertNodesArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; v: GenericArg; iNI: bigint | TransactionArgument; c: number | TransactionArgument; iP: bigint | TransactionArgument; iNCC: boolean | TransactionArgument; c1: bigint | TransactionArgument; c2: bigint | TransactionArgument
}

export function pushBackInsertNodes(
    txb: TransactionBlock,
    typeArg: string,
    args: PushBackInsertNodesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::push_back_insert_nodes`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), generic(txb, `${typeArg}`, args.v), pure(txb, args.iNI, `u64`), pure(txb, args.c, `u8`), pure(txb, args.iP, `u64`), pure(txb, args.iNCC, `bool`), pure(txb, args.c1, `u64`), pure(txb, args.c2, `u64`)
        ],
    })
}

export interface SearchOuterArgs {
    cb: ObjectArg; k: bigint | TransactionArgument
}

export function searchOuter(
    txb: TransactionBlock,
    typeArg: string,
    args: SearchOuterArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::search_outer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`)
        ],
    })
}

export interface StitchChildOfParentArgs {
    cb: ObjectArg; iN: bigint | TransactionArgument; iP: bigint | TransactionArgument; iO: bigint | TransactionArgument
}

export function stitchChildOfParent(
    txb: TransactionBlock,
    typeArg: string,
    args: StitchChildOfParentArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::stitch_child_of_parent`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.iN, `u64`), pure(txb, args.iP, `u64`), pure(txb, args.iO, `u64`)
        ],
    })
}

export interface StitchParentOfChildArgs {
    cb: ObjectArg; iN: bigint | TransactionArgument; iC: bigint | TransactionArgument
}

export function stitchParentOfChild(
    txb: TransactionBlock,
    typeArg: string,
    args: StitchParentOfChildArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::stitch_parent_of_child`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.iN, `u64`), pure(txb, args.iC, `u64`)
        ],
    })
}

export interface StitchSwapRemoveArgs {
    cb: ObjectArg; iN: bigint | TransactionArgument; nN: bigint | TransactionArgument
}

export function stitchSwapRemove(
    txb: TransactionBlock,
    typeArg: string,
    args: StitchSwapRemoveArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::stitch_swap_remove`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.iN, `u64`), pure(txb, args.nN, `u64`)
        ],
    })
}

export interface TraverseCIArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; pF: bigint | TransactionArgument; d: boolean | TransactionArgument
}

export function traverseCI(
    txb: TransactionBlock,
    typeArg: string,
    args: TraverseCIArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::traverse_c_i`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), pure(txb, args.pF, `u64`), pure(txb, args.d, `bool`)
        ],
    })
}

export interface TraverseEndPopArgs {
    cb: ObjectArg; pF: bigint | TransactionArgument; cI: bigint | TransactionArgument; nO: bigint | TransactionArgument
}

export function traverseEndPop(
    txb: TransactionBlock,
    typeArg: string,
    args: TraverseEndPopArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::traverse_end_pop`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.pF, `u64`), pure(txb, args.cI, `u64`), pure(txb, args.nO, `u64`)
        ],
    })
}

export interface TraverseInitMutArgs {
    cb: ObjectArg; d: boolean | TransactionArgument
}

export function traverseInitMut(
    txb: TransactionBlock,
    typeArg: string,
    args: TraverseInitMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::traverse_init_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.d, `bool`)
        ],
    })
}

export interface TraverseMutArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; pF: bigint | TransactionArgument; d: boolean | TransactionArgument
}

export function traverseMut(
    txb: TransactionBlock,
    typeArg: string,
    args: TraverseMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::traverse_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), pure(txb, args.pF, `u64`), pure(txb, args.d, `bool`)
        ],
    })
}

export function traversePInitMut(
    txb: TransactionBlock,
    typeArg: string,
    cb: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::traverse_p_init_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, cb)
        ],
    })
}

export interface TraversePMutArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; pF: bigint | TransactionArgument
}

export function traversePMut(
    txb: TransactionBlock,
    typeArg: string,
    args: TraversePMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::traverse_p_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), pure(txb, args.pF, `u64`)
        ],
    })
}

export interface TraversePPopMutArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; pF: bigint | TransactionArgument; cI: bigint | TransactionArgument; nO: bigint | TransactionArgument
}

export function traversePPopMut(
    txb: TransactionBlock,
    typeArg: string,
    args: TraversePPopMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::traverse_p_pop_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), pure(txb, args.pF, `u64`), pure(txb, args.cI, `u64`), pure(txb, args.nO, `u64`)
        ],
    })
}

export interface TraversePopMutArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; pF: bigint | TransactionArgument; cI: bigint | TransactionArgument; nO: bigint | TransactionArgument; d: boolean | TransactionArgument
}

export function traversePopMut(
    txb: TransactionBlock,
    typeArg: string,
    args: TraversePopMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::traverse_pop_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), pure(txb, args.pF, `u64`), pure(txb, args.cI, `u64`), pure(txb, args.nO, `u64`), pure(txb, args.d, `bool`)
        ],
    })
}

export function traverseSInitMut(
    txb: TransactionBlock,
    typeArg: string,
    cb: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::traverse_s_init_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, cb)
        ],
    })
}

export interface TraverseSMutArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; pF: bigint | TransactionArgument
}

export function traverseSMut(
    txb: TransactionBlock,
    typeArg: string,
    args: TraverseSMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::traverse_s_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), pure(txb, args.pF, `u64`)
        ],
    })
}

export interface TraverseSPopMutArgs {
    cb: ObjectArg; k: bigint | TransactionArgument; pF: bigint | TransactionArgument; cI: bigint | TransactionArgument; nO: bigint | TransactionArgument
}

export function traverseSPopMut(
    txb: TransactionBlock,
    typeArg: string,
    args: TraverseSPopMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::crit_bit::traverse_s_pop_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.cb), pure(txb, args.k, `u128`), pure(txb, args.pF, `u64`), pure(txb, args.cI, `u64`), pure(txb, args.nO, `u64`)
        ],
    })
}
