import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function empty(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::p2p_list_domain::empty`,
        arguments: [],
    })
}

export function delete_(
    txb: TransactionBlock,
    allowlists: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::p2p_list_domain::delete`,
        arguments: [
            obj(txb, allowlists)
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
        target: `${PUBLISHED_AT}::p2p_list_domain::add_domain`,
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
        target: `${PUBLISHED_AT}::p2p_list_domain::borrow_domain`,
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
        target: `${PUBLISHED_AT}::p2p_list_domain::borrow_domain_mut`,
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
        target: `${PUBLISHED_AT}::p2p_list_domain::has_domain`,
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
        target: `${PUBLISHED_AT}::p2p_list_domain::remove_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface AddIdArgs {
    witness: ObjectArg; collection: ObjectArg; al: ObjectArg
}

export function addId(
    txb: TransactionBlock,
    typeArg: string,
    args: AddIdArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::p2p_list_domain::add_id`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.collection), obj(txb, args.al)
        ],
    })
}

export function assertNoTransferAllowlist(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::p2p_list_domain::assert_no_transfer_allowlist`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertTransferAllowlist(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::p2p_list_domain::assert_transfer_allowlist`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function borrowAllowlists(
    txb: TransactionBlock,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::p2p_list_domain::borrow_allowlists`,
        arguments: [
            obj(txb, domain)
        ],
    })
}

export function fromId(
    txb: TransactionBlock,
    id: string | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::p2p_list_domain::from_id`,
        arguments: [
            pure(txb, id, `0x2::object::ID`)
        ],
    })
}

export interface RemoveIdArgs {
    witness: ObjectArg; collection: ObjectArg; id: string | TransactionArgument
}

export function removeId(
    txb: TransactionBlock,
    typeArg: string,
    args: RemoveIdArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::p2p_list_domain::remove_id`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), obj(txb, args.collection), pure(txb, args.id, `0x2::object::ID`)
        ],
    })
}
