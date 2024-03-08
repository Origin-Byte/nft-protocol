import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface AddDomainArgs {
    nft: ObjectArg; domain: ObjectArg
}

export function addDomain(
    txb: TransactionBlock,
    args: AddDomainArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::add_domain`,
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
        target: `${PUBLISHED_AT}::royalty::borrow_domain`,
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
        target: `${PUBLISHED_AT}::royalty::borrow_domain_mut`,
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
        target: `${PUBLISHED_AT}::royalty::has_domain`,
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
        target: `${PUBLISHED_AT}::royalty::remove_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function newEmpty(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::new_empty`,
        arguments: [],
    })
}

export interface AddCollectionShareArgs {
    collection: ObjectArg; to: string | TransactionArgument; share: number | TransactionArgument
}

export function addCollectionShare(
    txb: TransactionBlock,
    typeArg: string,
    args: AddCollectionShareArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::add_collection_share`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.collection), pure(txb, args.to, `address`), pure(txb, args.share, `u16`)
        ],
    })
}

export interface AddShareArgs {
    domain: ObjectArg; to: string | TransactionArgument; share: number | TransactionArgument
}

export function addShare(
    txb: TransactionBlock,
    args: AddShareArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::add_share`,
        arguments: [
            obj(txb, args.domain), pure(txb, args.to, `address`), pure(txb, args.share, `u16`)
        ],
    })
}

export interface AddShareToEmptyArgs {
    domain: ObjectArg; who: string | TransactionArgument
}

export function addShareToEmpty(
    txb: TransactionBlock,
    args: AddShareToEmptyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::add_share_to_empty`,
        arguments: [
            obj(txb, args.domain), pure(txb, args.who, `address`)
        ],
    })
}

export interface AddSharesToEmptyArgs {
    domain: ObjectArg; royaltySharesBps: ObjectArg
}

export function addSharesToEmpty(
    txb: TransactionBlock,
    args: AddSharesToEmptyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::add_shares_to_empty`,
        arguments: [
            obj(txb, args.domain), obj(txb, args.royaltySharesBps)
        ],
    })
}

export interface AddStrategyArgs {
    domain: ObjectArg; strategy: string | TransactionArgument
}

export function addStrategy(
    txb: TransactionBlock,
    args: AddStrategyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::add_strategy`,
        arguments: [
            obj(txb, args.domain), pure(txb, args.strategy, `0x2::object::ID`)
        ],
    })
}

export function assertEmpty(
    txb: TransactionBlock,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::assert_empty`,
        arguments: [
            obj(txb, domain)
        ],
    })
}

export function assertNoRoyalty(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::assert_no_royalty`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertRoyalty(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::assert_royalty`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertTotalShares(
    txb: TransactionBlock,
    shares: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::assert_total_shares`,
        arguments: [
            obj(txb, shares)
        ],
    })
}

export interface BorrowShareArgs {
    domain: ObjectArg; who: string | TransactionArgument
}

export function borrowShare(
    txb: TransactionBlock,
    args: BorrowShareArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::borrow_share`,
        arguments: [
            obj(txb, args.domain), pure(txb, args.who, `address`)
        ],
    })
}

export interface BorrowShareMutArgs {
    domain: ObjectArg; who: string | TransactionArgument
}

export function borrowShareMut(
    txb: TransactionBlock,
    args: BorrowShareMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::borrow_share_mut`,
        arguments: [
            obj(txb, args.domain), pure(txb, args.who, `address`)
        ],
    })
}

export function borrowShares(
    txb: TransactionBlock,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::borrow_shares`,
        arguments: [
            obj(txb, domain)
        ],
    })
}

export interface CollectRoyaltyArgs {
    collection: ObjectArg; source: ObjectArg; amount: bigint | TransactionArgument
}

export function collectRoyalty(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CollectRoyaltyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::collect_royalty`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.collection), obj(txb, args.source), pure(txb, args.amount, `u64`)
        ],
    })
}

export interface ContainsShareArgs {
    domain: ObjectArg; who: string | TransactionArgument
}

export function containsShare(
    txb: TransactionBlock,
    args: ContainsShareArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::contains_share`,
        arguments: [
            obj(txb, args.domain), pure(txb, args.who, `address`)
        ],
    })
}

export function containsShares(
    txb: TransactionBlock,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::contains_shares`,
        arguments: [
            obj(txb, domain)
        ],
    })
}

export interface DistributeBalanceArgs {
    shares: ObjectArg; aggregate: ObjectArg
}

export function distributeBalance(
    txb: TransactionBlock,
    typeArg: string,
    args: DistributeBalanceArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::distribute_balance`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.shares), obj(txb, args.aggregate)
        ],
    })
}

export function distributeRoyalties(
    txb: TransactionBlock,
    typeArgs: [string, string],
    collection: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::distribute_royalties`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, collection)
        ],
    })
}

export function fromAddress(
    txb: TransactionBlock,
    who: string | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::from_address`,
        arguments: [
            pure(txb, who, `address`)
        ],
    })
}

export function fromShares(
    txb: TransactionBlock,
    royaltySharesBps: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::from_shares`,
        arguments: [
            obj(txb, royaltySharesBps)
        ],
    })
}

export interface RemoveCollectionShareArgs {
    collection: ObjectArg; to: string | TransactionArgument
}

export function removeCollectionShare(
    txb: TransactionBlock,
    typeArg: string,
    args: RemoveCollectionShareArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::remove_collection_share`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.collection), pure(txb, args.to, `address`)
        ],
    })
}

export interface RemoveCreatorByTransferArgs {
    domain: ObjectArg; to: string | TransactionArgument
}

export function removeCreatorByTransfer(
    txb: TransactionBlock,
    args: RemoveCreatorByTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::remove_creator_by_transfer`,
        arguments: [
            obj(txb, args.domain), pure(txb, args.to, `address`)
        ],
    })
}

export interface RemoveStrategyArgs {
    domain: ObjectArg; strategy: string | TransactionArgument
}

export function removeStrategy(
    txb: TransactionBlock,
    args: RemoveStrategyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::remove_strategy`,
        arguments: [
            obj(txb, args.domain), pure(txb, args.strategy, `0x2::object::ID`)
        ],
    })
}

export function strategies(
    txb: TransactionBlock,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::royalty::strategies`,
        arguments: [
            obj(txb, domain)
        ],
    })
}
