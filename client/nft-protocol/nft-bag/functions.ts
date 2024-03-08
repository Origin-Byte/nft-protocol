import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface BorrowArgs {
    nftBag: ObjectArg; nftId: string | TransactionArgument
}

export function borrow(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::borrow`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.nftBag), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface BorrowMutArgs {
    nftBag: ObjectArg; nftId: string | TransactionArgument
}

export function borrowMut(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::borrow_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.nftBag), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export function new_(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::new`,
        arguments: [],
    })
}

export function delete_(
    txb: TransactionBlock,
    nftBag: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::delete`,
        arguments: [
            obj(txb, nftBag)
        ],
    })
}

export interface BorrowNftArgs {
    nft: ObjectArg; childNftId: string | TransactionArgument
}

export function borrowNft(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::borrow_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.nft), pure(txb, args.childNftId, `0x2::object::ID`)
        ],
    })
}

export interface BorrowNftMutArgs {
    nft: ObjectArg; childNftId: string | TransactionArgument
}

export function borrowNftMut(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowNftMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::borrow_nft_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.nft), pure(txb, args.childNftId, `0x2::object::ID`)
        ],
    })
}

export interface AddDomainArgs {
    nft: ObjectArg; domain: ObjectArg
}

export function addDomain(
    txb: TransactionBlock,
    args: AddDomainArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::add_domain`,
        arguments: [
            obj(txb, args.nft), obj(txb, args.domain)
        ],
    })
}

export function borrowDomain(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::borrow_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function borrowDomainMut(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::borrow_domain_mut`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function hasDomain(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::has_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function removeDomain(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::remove_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function addNew(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::add_new`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface AssertComposedArgs {
    nftBag: ObjectArg; nftId: string | TransactionArgument
}

export function assertComposed(
    txb: TransactionBlock,
    args: AssertComposedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::assert_composed`,
        arguments: [
            obj(txb, args.nftBag), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface AssertComposedTypeArgs {
    nftBag: ObjectArg; nftId: string | TransactionArgument
}

export function assertComposedType(
    txb: TransactionBlock,
    typeArg: string,
    args: AssertComposedTypeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::assert_composed_type`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.nftBag), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export function assertNftBag(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::assert_nft_bag`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertNoNftBag(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::assert_no_nft_bag`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface ComposeArgs {
    authority: GenericArg; domain: ObjectArg; childNft: GenericArg
}

export function compose(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ComposeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::compose`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.authority), obj(txb, args.domain), generic(txb, `${typeArgs[0]}`, args.childNft)
        ],
    })
}

export interface ComposeIntoNftArgs {
    authority: GenericArg; parentNft: ObjectArg; childNft: GenericArg
}

export function composeIntoNft(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ComposeIntoNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::compose_into_nft`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.authority), obj(txb, args.parentNft), generic(txb, `${typeArgs[0]}`, args.childNft)
        ],
    })
}

export function count(
    txb: TransactionBlock,
    typeArg: string,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::count`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, domain)
        ],
    })
}

export interface DecomposeArgs {
    authority: GenericArg; domain: ObjectArg; childNftId: string | TransactionArgument
}

export function decompose(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: DecomposeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::decompose`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.authority), obj(txb, args.domain), pure(txb, args.childNftId, `0x2::object::ID`)
        ],
    })
}

export interface DecomposeAndTransferArgs {
    authority: GenericArg; domain: ObjectArg; childNftId: string | TransactionArgument
}

export function decomposeAndTransfer(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: DecomposeAndTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::decompose_and_transfer`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.authority), obj(txb, args.domain), pure(txb, args.childNftId, `0x2::object::ID`)
        ],
    })
}

export interface DecomposeFromNftArgs {
    authority: GenericArg; parentNft: ObjectArg; childNftId: string | TransactionArgument
}

export function decomposeFromNft(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: DecomposeFromNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::decompose_from_nft`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.authority), obj(txb, args.parentNft), pure(txb, args.childNftId, `0x2::object::ID`)
        ],
    })
}

export interface DecomposeFromNftAndTransferArgs {
    authority: GenericArg; parentNft: ObjectArg; childNftId: string | TransactionArgument
}

export function decomposeFromNftAndTransfer(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: DecomposeFromNftAndTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::decompose_from_nft_and_transfer`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.authority), obj(txb, args.parentNft), pure(txb, args.childNftId, `0x2::object::ID`)
        ],
    })
}

export function getAuthorities(
    txb: TransactionBlock,
    nftBag: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::get_authorities`,
        arguments: [
            obj(txb, nftBag)
        ],
    })
}

export interface GetAuthorityIdxArgs {
    authorityType: ObjectArg; domain: ObjectArg
}

export function getAuthorityIdx(
    txb: TransactionBlock,
    args: GetAuthorityIdxArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::get_authority_idx`,
        arguments: [
            obj(txb, args.authorityType), obj(txb, args.domain)
        ],
    })
}

export function getNfts(
    txb: TransactionBlock,
    nftBag: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::get_nfts`,
        arguments: [
            obj(txb, nftBag)
        ],
    })
}

export interface GetOrInsertAuthorityIdxArgs {
    authorityType: ObjectArg; domain: ObjectArg
}

export function getOrInsertAuthorityIdx(
    txb: TransactionBlock,
    args: GetOrInsertAuthorityIdxArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::get_or_insert_authority_idx`,
        arguments: [
            obj(txb, args.authorityType), obj(txb, args.domain)
        ],
    })
}

export interface HasArgs {
    nftBag: ObjectArg; nftId: string | TransactionArgument
}

export function has(
    txb: TransactionBlock,
    args: HasArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_bag::has`,
        arguments: [
            obj(txb, args.nftBag), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}
