import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function delete_(
    txb: TransactionBlock,
    typeArg: string,
    composition: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::delete`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, composition)
        ],
    })
}

export interface AddDomainArgs {
    object: ObjectArg; domain: ObjectArg
}

export function addDomain(
    txb: TransactionBlock,
    typeArg: string,
    args: AddDomainArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::add_domain`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.object), obj(txb, args.domain)
        ],
    })
}

export function borrowDomain(
    txb: TransactionBlock,
    typeArg: string,
    object: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::borrow_domain`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, object)
        ],
    })
}

export function borrowDomainMut(
    txb: TransactionBlock,
    typeArg: string,
    object: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::borrow_domain_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, object)
        ],
    })
}

export function hasDomain(
    txb: TransactionBlock,
    typeArg: string,
    object: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::has_domain`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, object)
        ],
    })
}

export function removeDomain(
    txb: TransactionBlock,
    typeArg: string,
    object: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::remove_domain`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, object)
        ],
    })
}

export interface ComposeArgs {
    composition: ObjectArg; nfts: ObjectArg; childNft: GenericArg
}

export function compose(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ComposeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::compose`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.composition), obj(txb, args.nfts), generic(txb, `${typeArgs[1]}`, args.childNft)
        ],
    })
}

export interface ComposeIntoNftArgs {
    composition: ObjectArg; parentNft: ObjectArg; childNft: GenericArg
}

export function composeIntoNft(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ComposeIntoNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::compose_into_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.composition), obj(txb, args.parentNft), generic(txb, `${typeArgs[1]}`, args.childNft)
        ],
    })
}

export interface DecomposeArgs {
    composition: ObjectArg; nfts: ObjectArg; childNftId: string | TransactionArgument
}

export function decompose(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: DecomposeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::decompose`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.composition), obj(txb, args.nfts), pure(txb, args.childNftId, `0x2::object::ID`)
        ],
    })
}

export interface DecomposeFromNftArgs {
    composition: ObjectArg; parentNft: ObjectArg; childNftId: string | TransactionArgument
}

export function decomposeFromNft(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: DecomposeFromNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::decompose_from_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.composition), obj(txb, args.parentNft), pure(txb, args.childNftId, `0x2::object::ID`)
        ],
    })
}

export function addNewComposition(
    txb: TransactionBlock,
    typeArg: string,
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::add_new_composition`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, collection)
        ],
    })
}

export interface AddRelationshipArgs {
    composition: ObjectArg; limit: bigint | TransactionArgument
}

export function addRelationship(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AddRelationshipArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::add_relationship`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.composition), pure(txb, args.limit, `u64`)
        ],
    })
}

export interface AssertComposableArgs {
    composition: ObjectArg; childType: ObjectArg
}

export function assertComposable(
    txb: TransactionBlock,
    typeArg: string,
    args: AssertComposableArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::assert_composable`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.composition), obj(txb, args.childType)
        ],
    })
}

export function assertComposition(
    txb: TransactionBlock,
    typeArg: string,
    object: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::assert_composition`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, object)
        ],
    })
}

export interface AssertInsertableArgs {
    composition: ObjectArg; count: bigint | TransactionArgument
}

export function assertInsertable(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AssertInsertableArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::assert_insertable`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.composition), pure(txb, args.count, `u64`)
        ],
    })
}

export function assertNoComposition(
    txb: TransactionBlock,
    typeArg: string,
    object: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::assert_no_composition`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, object)
        ],
    })
}

export interface BorrowLimitMutArgs {
    composition: ObjectArg; childType: ObjectArg
}

export function borrowLimitMut(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowLimitMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::borrow_limit_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.composition), obj(txb, args.childType)
        ],
    })
}

export function borrowLimits(
    txb: TransactionBlock,
    typeArg: string,
    composition: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::borrow_limits`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, composition)
        ],
    })
}

export interface Compose_Args {
    nfts: ObjectArg; childNft: GenericArg
}

export function compose_(
    txb: TransactionBlock,
    typeArg: string,
    args: Compose_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::compose_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.nfts), generic(txb, `${typeArg}`, args.childNft)
        ],
    })
}

export interface ComposeWithCollectionSchemaArgs {
    collection: ObjectArg; parentNft: ObjectArg; childNft: GenericArg
}

export function composeWithCollectionSchema(
    txb: TransactionBlock,
    typeArgs: [string, string, string],
    args: ComposeWithCollectionSchemaArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::compose_with_collection_schema`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.collection), obj(txb, args.parentNft), generic(txb, `${typeArgs[2]}`, args.childNft)
        ],
    })
}

export interface ComposeWithNftSchemaArgs {
    parentNft: ObjectArg; childNft: GenericArg
}

export function composeWithNftSchema(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ComposeWithNftSchemaArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::compose_with_nft_schema`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.parentNft), generic(txb, `${typeArgs[1]}`, args.childNft)
        ],
    })
}

export interface Decompose_Args {
    nfts: ObjectArg; childNftId: string | TransactionArgument
}

export function decompose_(
    txb: TransactionBlock,
    typeArg: string,
    args: Decompose_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::decompose_`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.nfts), pure(txb, args.childNftId, `0x2::object::ID`)
        ],
    })
}

export interface DecomposeWithCollectionSchemaArgs {
    collection: ObjectArg; parentNft: ObjectArg; childNftId: string | TransactionArgument
}

export function decomposeWithCollectionSchema(
    txb: TransactionBlock,
    typeArgs: [string, string, string],
    args: DecomposeWithCollectionSchemaArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::decompose_with_collection_schema`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.collection), obj(txb, args.parentNft), pure(txb, args.childNftId, `0x2::object::ID`)
        ],
    })
}

export interface DecomposeWithNftSchemaArgs {
    parentNft: ObjectArg; childNftId: string | TransactionArgument
}

export function decomposeWithNftSchema(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: DecomposeWithNftSchemaArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::decompose_with_nft_schema`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.parentNft), pure(txb, args.childNftId, `0x2::object::ID`)
        ],
    })
}

export function dropRelationship(
    txb: TransactionBlock,
    typeArgs: [string, string],
    composition: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::drop_relationship`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, composition)
        ],
    })
}

export interface GetLimitArgs {
    composition: ObjectArg; childType: ObjectArg
}

export function getLimit(
    txb: TransactionBlock,
    typeArg: string,
    args: GetLimitArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::get_limit`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.composition), obj(txb, args.childType)
        ],
    })
}

export interface HasChildArgs {
    composition: ObjectArg; childType: ObjectArg
}

export function hasChild(
    txb: TransactionBlock,
    typeArg: string,
    args: HasChildArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::has_child`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.composition), obj(txb, args.childType)
        ],
    })
}

export function newComposition(
    txb: TransactionBlock,
    typeArg: string,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_nft::new_composition`,
        typeArguments: [typeArg],
        arguments: [],
    })
}
