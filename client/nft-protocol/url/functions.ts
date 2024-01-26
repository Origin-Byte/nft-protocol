import {PUBLISHED_AT} from "..";
import {ObjectArg, obj} from "../../_framework/util";
import {TransactionBlock} from "@mysten/sui.js/transactions";

export interface AddDomainArgs {
    nft: ObjectArg; domain: ObjectArg
}

export function addDomain(
    txb: TransactionBlock,
    args: AddDomainArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::url::add_domain`,
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
        target: `${PUBLISHED_AT}::url::borrow_domain`,
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
        target: `${PUBLISHED_AT}::url::borrow_domain_mut`,
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
        target: `${PUBLISHED_AT}::url::has_domain`,
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
        target: `${PUBLISHED_AT}::url::remove_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertNoUrl(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::url::assert_no_url`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertUrl(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::url::assert_url`,
        arguments: [
            obj(txb, nft)
        ],
    })
}
