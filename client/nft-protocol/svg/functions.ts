import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function new_(
    txb: TransactionBlock,
    svg: Array<number | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::svg::new`,
        arguments: [
            pure(txb, svg, `vector<u8>`)
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
        target: `${PUBLISHED_AT}::svg::add_domain`,
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
        target: `${PUBLISHED_AT}::svg::borrow_domain`,
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
        target: `${PUBLISHED_AT}::svg::borrow_domain_mut`,
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
        target: `${PUBLISHED_AT}::svg::has_domain`,
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
        target: `${PUBLISHED_AT}::svg::remove_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface AddNewArgs {
    nft: ObjectArg; svg: Array<number | TransactionArgument> | TransactionArgument
}

export function addNew(
    txb: TransactionBlock,
    args: AddNewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::svg::add_new`,
        arguments: [
            obj(txb, args.nft), pure(txb, args.svg, `vector<u8>`)
        ],
    })
}

export function addEmpty(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::svg::add_empty`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertNoSvg(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::svg::assert_no_svg`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertSvg(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::svg::assert_svg`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function getSvg(
    txb: TransactionBlock,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::svg::get_svg`,
        arguments: [
            obj(txb, domain)
        ],
    })
}

export function newEmpty(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::svg::new_empty`,
        arguments: [],
    })
}

export interface SetSvgArgs {
    domain: ObjectArg; svg: Array<number | TransactionArgument> | TransactionArgument
}

export function setSvg(
    txb: TransactionBlock,
    typeArg: string,
    args: SetSvgArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::svg::set_svg`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.domain), pure(txb, args.svg, `vector<u8>`)
        ],
    })
}
