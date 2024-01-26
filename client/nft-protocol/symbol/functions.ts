import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function new_(
    txb: TransactionBlock,
    symbol: string | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::symbol::new`,
        arguments: [
            pure(txb, symbol, `0x1::string::String`)
        ],
    })
}

export function symbol(
    txb: TransactionBlock,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::symbol::symbol`,
        arguments: [
            obj(txb, domain)
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
        target: `${PUBLISHED_AT}::symbol::add_domain`,
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
        target: `${PUBLISHED_AT}::symbol::borrow_domain`,
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
        target: `${PUBLISHED_AT}::symbol::borrow_domain_mut`,
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
        target: `${PUBLISHED_AT}::symbol::has_domain`,
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
        target: `${PUBLISHED_AT}::symbol::remove_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertNoSymbol(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::symbol::assert_no_symbol`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertSymbol(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::symbol::assert_symbol`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface SetSymbolArgs {
    domain: ObjectArg; symbol: string | TransactionArgument
}

export function setSymbol(
    txb: TransactionBlock,
    typeArg: string,
    args: SetSymbolArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::symbol::set_symbol`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.domain), pure(txb, args.symbol, `0x1::string::String`)
        ],
    })
}
