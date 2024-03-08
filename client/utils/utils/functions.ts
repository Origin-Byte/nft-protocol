import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, obj, pure, vector} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function assertPackagePublisher(
    txb: TransactionBlock,
    typeArg: string,
    pub: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::assert_package_publisher`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, pub)
        ],
    })
}

export function assertPublisher(
    txb: TransactionBlock,
    typeArg: string,
    pub: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::assert_publisher`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, pub)
        ],
    })
}

export function assertSameModule(
    txb: TransactionBlock,
    typeArgs: [string, string],
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::assert_same_module`,
        typeArguments: typeArgs,
        arguments: [],
    })
}

export function assertSameModuleAsWitness(
    txb: TransactionBlock,
    typeArgs: [string, string],
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::assert_same_module_as_witness`,
        typeArguments: typeArgs,
        arguments: [],
    })
}

export function bps(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::bps`,
        arguments: [],
    })
}

export interface FromVecToMapArgs {
    keys: Array<GenericArg> | TransactionArgument; values: Array<GenericArg> | TransactionArgument
}

export function fromVecToMap(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: FromVecToMapArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::from_vec_to_map`,
        typeArguments: typeArgs,
        arguments: [
            vector(txb, `${typeArgs[0]}`, args.keys), vector(txb, `${typeArgs[1]}`, args.values)
        ],
    })
}

export function getPackageModuleType(
    txb: TransactionBlock,
    typeArg: string,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::get_package_module_type`,
        typeArguments: [typeArg],
        arguments: [],
    })
}

export function getPackageModuleTypeRaw(
    txb: TransactionBlock,
    t: string | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::get_package_module_type_raw`,
        arguments: [
            pure(txb, t, `0x1::string::String`)
        ],
    })
}

export interface InsertVecInTableArgs {
    table: ObjectArg; vec: Array<GenericArg> | TransactionArgument
}

export function insertVecInTable(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertVecInTableArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::insert_vec_in_table`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.table), vector(txb, `${typeArg}`, args.vec)
        ],
    })
}

export interface InsertVecInVecSetArgs {
    set: ObjectArg; vec: Array<GenericArg> | TransactionArgument
}

export function insertVecInVecSet(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertVecInVecSetArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::insert_vec_in_vec_set`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.set), vector(txb, `${typeArg}`, args.vec)
        ],
    })
}

export function isShared(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::is_shared`,
        arguments: [],
    })
}

export function marker(
    txb: TransactionBlock,
    typeArg: string,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::marker`,
        typeArguments: [typeArg],
        arguments: [],
    })
}

export function originbyteDocsUrl(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::originbyte_docs_url`,
        arguments: [],
    })
}

export function sumVector(
    txb: TransactionBlock,
    vec: Array<bigint | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::sum_vector`,
        arguments: [
            pure(txb, vec, `vector<u64>`)
        ],
    })
}

export function tableFromVecMap(
    txb: TransactionBlock,
    typeArgs: [string, string],
    vec: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::table_from_vec_map`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, vec)
        ],
    })
}

export function tableVecFromVec(
    txb: TransactionBlock,
    typeArg: string,
    vec: Array<GenericArg> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::table_vec_from_vec`,
        typeArguments: [typeArg],
        arguments: [
            vector(txb, `${typeArg}`, vec)
        ],
    })
}

export function vecMapEntries(
    txb: TransactionBlock,
    typeArgs: [string, string],
    map: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::vec_map_entries`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, map)
        ],
    })
}

export function vecSetFromVec(
    txb: TransactionBlock,
    typeArg: string,
    vec: Array<GenericArg> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::utils::vec_set_from_vec`,
        typeArguments: [typeArg],
        arguments: [
            vector(txb, `${typeArg}`, vec)
        ],
    })
}
