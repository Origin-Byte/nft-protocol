import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    inventoryId: string | TransactionArgument; price: bigint | TransactionArgument
}

export function new_(
    txb: TransactionBlock,
    typeArg: string,
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::fixed_price::new`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.price, `u64`)
        ],
    })
}

export function price(
    txb: TransactionBlock,
    typeArg: string,
    market: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::fixed_price::price`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, market)
        ],
    })
}

export interface BuyNftArgs {
    listing: ObjectArg; venueId: string | TransactionArgument; wallet: ObjectArg
}

export function buyNft(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BuyNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::fixed_price::buy_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`), obj(txb, args.wallet)
        ],
    })
}

export interface BuyNft_Args {
    listing: ObjectArg; venueId: string | TransactionArgument; balance: ObjectArg
}

export function buyNft_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BuyNft_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::fixed_price::buy_nft_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`), obj(txb, args.balance)
        ],
    })
}

export function borrowMarket(
    txb: TransactionBlock,
    typeArg: string,
    venue: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::fixed_price::borrow_market`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, venue)
        ],
    })
}

export interface InitVenueArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument; isWhitelisted: boolean | TransactionArgument; price: bigint | TransactionArgument
}

export function initVenue(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: InitVenueArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::fixed_price::init_venue`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.isWhitelisted, `bool`), pure(txb, args.price, `u64`)
        ],
    })
}

export interface CreateVenueArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument; isWhitelisted: boolean | TransactionArgument; price: bigint | TransactionArgument
}

export function createVenue(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateVenueArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::fixed_price::create_venue`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.isWhitelisted, `bool`), pure(txb, args.price, `u64`)
        ],
    })
}

export interface InitMarketArgs {
    inventoryId: string | TransactionArgument; price: bigint | TransactionArgument
}

export function initMarket(
    txb: TransactionBlock,
    typeArg: string,
    args: InitMarketArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::fixed_price::init_market`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.price, `u64`)
        ],
    })
}

export interface BuyNftIntoKioskArgs {
    listing: ObjectArg; venueId: string | TransactionArgument; wallet: ObjectArg; buyerKiosk: ObjectArg
}

export function buyNftIntoKiosk(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BuyNftIntoKioskArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::fixed_price::buy_nft_into_kiosk`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`), obj(txb, args.wallet), obj(txb, args.buyerKiosk)
        ],
    })
}

export interface BuyWhitelistedNftArgs {
    listing: ObjectArg; venueId: string | TransactionArgument; wallet: ObjectArg; whitelistToken: ObjectArg
}

export function buyWhitelistedNft(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BuyWhitelistedNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::fixed_price::buy_whitelisted_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`), obj(txb, args.wallet), obj(txb, args.whitelistToken)
        ],
    })
}

export interface BuyWhitelistedNftIntoKioskArgs {
    listing: ObjectArg; venueId: string | TransactionArgument; wallet: ObjectArg; safe: ObjectArg; whitelistToken: ObjectArg
}

export function buyWhitelistedNftIntoKiosk(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BuyWhitelistedNftIntoKioskArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::fixed_price::buy_whitelisted_nft_into_kiosk`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`), obj(txb, args.wallet), obj(txb, args.safe), obj(txb, args.whitelistToken)
        ],
    })
}

export interface SetPriceArgs {
    listing: ObjectArg; venueId: string | TransactionArgument; newPrice: bigint | TransactionArgument
}

export function setPrice(
    txb: TransactionBlock,
    typeArg: string,
    args: SetPriceArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::fixed_price::set_price`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`), pure(txb, args.newPrice, `u64`)
        ],
    })
}
