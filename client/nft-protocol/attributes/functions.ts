import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function empty(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::attributes::empty`,
        arguments: [],
    })
}

export function new_(
    txb: TransactionBlock,
    map: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::attributes::new`,
        arguments: [
            obj(txb, map)
        ],
    })
}

export interface FromVecArgs {
    keys: Array<string | TransactionArgument> | TransactionArgument; values: Array<string | TransactionArgument> | TransactionArgument
}

export function fromVec(
    txb: TransactionBlock,
    args: FromVecArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::attributes::from_vec`,
        arguments: [
            pure(txb, args.keys, `vector<0x1::ascii::String>`), pure(txb, args.values, `vector<0x1::ascii::String>`)
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
        target: `${PUBLISHED_AT}::attributes::add_domain`,
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
        target: `${PUBLISHED_AT}::attributes::borrow_domain`,
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
        target: `${PUBLISHED_AT}::attributes::borrow_domain_mut`,
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
        target: `${PUBLISHED_AT}::attributes::has_domain`,
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
        target: `${PUBLISHED_AT}::attributes::remove_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface AddNewArgs {
    objectUid: ObjectArg; map: ObjectArg
}

export function addNew(
    txb: TransactionBlock,
    args: AddNewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::attributes::add_new`,
        arguments: [
            obj(txb, args.objectUid), obj(txb, args.map)
        ],
    })
}

export function addEmpty(
    txb: TransactionBlock,
    nftUid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::attributes::add_empty`,
        arguments: [
            obj(txb, nftUid)
        ],
    })
}

export interface AddFromVecArgs {
    keys: Array<string | TransactionArgument> | TransactionArgument; values: Array<string | TransactionArgument> | TransactionArgument
}

export function addFromVec(
    txb: TransactionBlock,
    args: AddFromVecArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::attributes::add_from_vec`,
        arguments: [
            pure(txb, args.keys, `vector<0x1::ascii::String>`), pure(txb, args.values, `vector<0x1::ascii::String>`)
        ],
    })
}

export function asUrlParameters(
    txb: TransactionBlock,
    attributes: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::attributes::as_url_parameters`,
        arguments: [
            obj(txb, attributes)
        ],
    })
}

export function assertAttributes(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::attributes::assert_attributes`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertNoAttributes(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::attributes::assert_no_attributes`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function getAttributes(
    txb: TransactionBlock,
    attributes: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::attributes::get_attributes`,
        arguments: [
            obj(txb, attributes)
        ],
    })
}

export function getAttributesMut(
    txb: TransactionBlock,
    attributes: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::attributes::get_attributes_mut`,
        arguments: [
            obj(txb, attributes)
        ],
    })
}

export interface InsertAttributeArgs {
    attributes: ObjectArg; attributeKey: string | TransactionArgument; attributeValue: string | TransactionArgument
}

export function insertAttribute(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: InsertAttributeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::attributes::insert_attribute`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.attributes), pure(txb, args.attributeKey, `0x1::ascii::String`), pure(txb, args.attributeValue, `0x1::ascii::String`)
        ],
    })
}

export interface RemoveAttributeArgs {
    attributes: ObjectArg; attributeKey: string | TransactionArgument
}

export function removeAttribute(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: RemoveAttributeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::attributes::remove_attribute`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.attributes), pure(txb, args.attributeKey, `0x1::ascii::String`)
        ],
    })
}
