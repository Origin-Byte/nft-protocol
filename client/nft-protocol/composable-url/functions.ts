import {PUBLISHED_AT} from "..";
import {ObjectArg, obj} from "../../_framework/util";
import {TransactionBlock} from "@mysten/sui.js/transactions";

export function new_(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_url::new`,
        arguments: [],
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
        target: `${PUBLISHED_AT}::composable_url::add_domain`,
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
        target: `${PUBLISHED_AT}::composable_url::borrow_domain`,
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
        target: `${PUBLISHED_AT}::composable_url::borrow_domain_mut`,
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
        target: `${PUBLISHED_AT}::composable_url::has_domain`,
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
        target: `${PUBLISHED_AT}::composable_url::remove_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertComposableUrl(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_url::assert_composable_url`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertNoComposableUrl(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_url::assert_no_composable_url`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function regenerate(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_url::regenerate`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface SetUrlArgs {
    domain: ObjectArg; url: ObjectArg
}

export function setUrl(
    txb: TransactionBlock,
    typeArg: string,
    args: SetUrlArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_url::set_url`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.domain), obj(txb, args.url)
        ],
    })
}
