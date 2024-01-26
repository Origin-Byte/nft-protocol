import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    name: string | TransactionArgument; description: string | TransactionArgument
}

export function new_(
    txb: TransactionBlock,
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display_info::new`,
        arguments: [
            pure(txb, args.name, `0x1::string::String`), pure(txb, args.description, `0x1::string::String`)
        ],
    })
}

export function getDescription(
    txb: TransactionBlock,
    displayInfo: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display_info::get_description`,
        arguments: [
            obj(txb, displayInfo)
        ],
    })
}

export function getName(
    txb: TransactionBlock,
    displayInfo: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display_info::get_name`,
        arguments: [
            obj(txb, displayInfo)
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
        target: `${PUBLISHED_AT}::display_info::add_domain`,
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
        target: `${PUBLISHED_AT}::display_info::borrow_domain`,
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
        target: `${PUBLISHED_AT}::display_info::borrow_domain_mut`,
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
        target: `${PUBLISHED_AT}::display_info::has_domain`,
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
        target: `${PUBLISHED_AT}::display_info::remove_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertDisplay(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display_info::assert_display`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertNoDisplay(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display_info::assert_no_display`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface ChangeDescriptionArgs {
    objectUid: ObjectArg; newDescription: string | TransactionArgument
}

export function changeDescription(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ChangeDescriptionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display_info::change_description`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.objectUid), pure(txb, args.newDescription, `0x1::string::String`)
        ],
    })
}

export interface ChangeNameArgs {
    objectUid: ObjectArg; newName: string | TransactionArgument
}

export function changeName(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ChangeNameArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display_info::change_name`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.objectUid), pure(txb, args.newName, `0x1::string::String`)
        ],
    })
}

export function getDescriptionMut(
    txb: TransactionBlock,
    displayInfo: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display_info::get_description_mut`,
        arguments: [
            obj(txb, displayInfo)
        ],
    })
}

export function getNameMut(
    txb: TransactionBlock,
    displayInfo: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display_info::get_name_mut`,
        arguments: [
            obj(txb, displayInfo)
        ],
    })
}
