import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    key: GenericArg; market: GenericArg; isWhitelisted: boolean | TransactionArgument
}

export function new_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::venue::new`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.key), generic(txb, `${typeArgs[0]}`, args.market), pure(txb, args.isWhitelisted, `bool`)
        ],
    })
}

export interface DeleteArgs {
    key: GenericArg; venue: ObjectArg
}

export function delete_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: DeleteArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::venue::delete`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.key), obj(txb, args.venue)
        ],
    })
}

export function assertIsLive(
    txb: TransactionBlock,
    venue: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::venue::assert_is_live`,
        arguments: [
            obj(txb, venue)
        ],
    })
}

export function assertIsNotWhitelisted(
    txb: TransactionBlock,
    venue: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::venue::assert_is_not_whitelisted`,
        arguments: [
            obj(txb, venue)
        ],
    })
}

export function assertIsWhitelisted(
    txb: TransactionBlock,
    venue: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::venue::assert_is_whitelisted`,
        arguments: [
            obj(txb, venue)
        ],
    })
}

export interface AssertMarketArgs {
    key: GenericArg; venue: ObjectArg
}

export function assertMarket(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AssertMarketArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::venue::assert_market`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.key), obj(txb, args.venue)
        ],
    })
}

export interface BorrowMarketArgs {
    key: GenericArg; venue: ObjectArg
}

export function borrowMarket(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BorrowMarketArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::venue::borrow_market`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.key), obj(txb, args.venue)
        ],
    })
}

export interface BorrowMarketMutArgs {
    key: GenericArg; venue: ObjectArg
}

export function borrowMarketMut(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BorrowMarketMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::venue::borrow_market_mut`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.key), obj(txb, args.venue)
        ],
    })
}

export interface InitVenueArgs {
    key: GenericArg; market: GenericArg; isWhitelisted: boolean | TransactionArgument
}

export function initVenue(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: InitVenueArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::venue::init_venue`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.key), generic(txb, `${typeArgs[0]}`, args.market), pure(txb, args.isWhitelisted, `bool`)
        ],
    })
}

export function isWhitelisted(
    txb: TransactionBlock,
    venue: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::venue::is_whitelisted`,
        arguments: [
            obj(txb, venue)
        ],
    })
}

export function isLive(
    txb: TransactionBlock,
    venue: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::venue::is_live`,
        arguments: [
            obj(txb, venue)
        ],
    })
}

export interface SetLiveArgs {
    venue: ObjectArg; isLive: boolean | TransactionArgument
}

export function setLive(
    txb: TransactionBlock,
    args: SetLiveArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::venue::set_live`,
        arguments: [
            obj(txb, args.venue), pure(txb, args.isLive, `bool`)
        ],
    })
}

export interface SetWhitelistedArgs {
    venue: ObjectArg; isWhitelisted: boolean | TransactionArgument
}

export function setWhitelisted(
    txb: TransactionBlock,
    args: SetWhitelistedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::venue::set_whitelisted`,
        arguments: [
            obj(txb, args.venue), pure(txb, args.isWhitelisted, `bool`)
        ],
    })
}
