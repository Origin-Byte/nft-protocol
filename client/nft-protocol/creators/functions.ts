import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function empty(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::creators::empty`,
        arguments: [],
    })
}

export function isEmpty(
    txb: TransactionBlock,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::creators::is_empty`,
        arguments: [
            obj(txb, domain)
        ],
    })
}

export function new_(
    txb: TransactionBlock,
    creators: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::creators::new`,
        arguments: [
            obj(txb, creators)
        ],
    })
}

export function delete_(
    txb: TransactionBlock,
    creators: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::creators::delete`,
        arguments: [
            obj(txb, creators)
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
        target: `${PUBLISHED_AT}::creators::add_domain`,
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
        target: `${PUBLISHED_AT}::creators::borrow_domain`,
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
        target: `${PUBLISHED_AT}::creators::borrow_domain_mut`,
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
        target: `${PUBLISHED_AT}::creators::has_domain`,
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
        target: `${PUBLISHED_AT}::creators::remove_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface AddCreatorArgs {
    creators: ObjectArg; who: string | TransactionArgument
}

export function addCreator(
    txb: TransactionBlock,
    args: AddCreatorArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::creators::add_creator`,
        arguments: [
            obj(txb, args.creators), pure(txb, args.who, `address`)
        ],
    })
}

export function assertCreators(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::creators::assert_Creators`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface AssertCreatorArgs {
    domain: ObjectArg; who: string | TransactionArgument
}

export function assertCreator(
    txb: TransactionBlock,
    args: AssertCreatorArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::creators::assert_creator`,
        arguments: [
            obj(txb, args.domain), pure(txb, args.who, `address`)
        ],
    })
}

export function assertNoCreators(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::creators::assert_no_Creators`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface ContainsCreatorArgs {
    creators: ObjectArg; who: string | TransactionArgument
}

export function containsCreator(
    txb: TransactionBlock,
    args: ContainsCreatorArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::creators::contains_creator`,
        arguments: [
            obj(txb, args.creators), pure(txb, args.who, `address`)
        ],
    })
}

export function getCreators(
    txb: TransactionBlock,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::creators::get_Creators`,
        arguments: [
            obj(txb, domain)
        ],
    })
}

export interface RemoveCreatorArgs {
    creators: ObjectArg; who: string | TransactionArgument
}

export function removeCreator(
    txb: TransactionBlock,
    args: RemoveCreatorArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::creators::remove_creator`,
        arguments: [
            obj(txb, args.creators), pure(txb, args.who, `address`)
        ],
    })
}
