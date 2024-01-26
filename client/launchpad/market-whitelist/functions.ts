import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function new_(
    txb: TransactionBlock,
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::market_whitelist::new`,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export function burn(
    txb: TransactionBlock,
    certificate: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::market_whitelist::burn`,
        arguments: [
            obj(txb, certificate)
        ],
    })
}

export interface AddAddressesArgs {
    listing: ObjectArg; venueId: string | TransactionArgument; wlAddresses: Array<string | TransactionArgument> | TransactionArgument
}

export function addAddresses(
    txb: TransactionBlock,
    args: AddAddressesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::market_whitelist::add_addresses`,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`), pure(txb, args.wlAddresses, `vector<address>`)
        ],
    })
}

export interface AddWhitelistArgs {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function addWhitelist(
    txb: TransactionBlock,
    args: AddWhitelistArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::market_whitelist::add_whitelist`,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface AssertCertificateArgs {
    certificate: ObjectArg; venueId: string | TransactionArgument
}

export function assertCertificate(
    txb: TransactionBlock,
    args: AssertCertificateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::market_whitelist::assert_certificate`,
        arguments: [
            obj(txb, args.certificate), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface AssertWhitelistArgs {
    certificate: ObjectArg; venue: ObjectArg
}

export function assertWhitelist(
    txb: TransactionBlock,
    args: AssertWhitelistArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::market_whitelist::assert_whitelist`,
        arguments: [
            obj(txb, args.certificate), obj(txb, args.venue)
        ],
    })
}

export interface AssertWlAddressArgs {
    whitelist: ObjectArg; wlAddress: string | TransactionArgument
}

export function assertWlAddress(
    txb: TransactionBlock,
    args: AssertWlAddressArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::market_whitelist::assert_wl_address`,
        arguments: [
            obj(txb, args.whitelist), pure(txb, args.wlAddress, `address`)
        ],
    })
}

export interface CheckInAddressArgs {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function checkInAddress(
    txb: TransactionBlock,
    args: CheckInAddressArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::market_whitelist::check_in_address`,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface IssueArgs {
    listing: ObjectArg; venueId: string | TransactionArgument; recipient: string | TransactionArgument
}

export function issue(
    txb: TransactionBlock,
    args: IssueArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::market_whitelist::issue`,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`), pure(txb, args.recipient, `address`)
        ],
    })
}

export interface RemoveAddressesArgs {
    listing: ObjectArg; venueId: string | TransactionArgument; wlAddresses: Array<string | TransactionArgument> | TransactionArgument
}

export function removeAddresses(
    txb: TransactionBlock,
    args: RemoveAddressesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::market_whitelist::remove_addresses`,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`), pure(txb, args.wlAddresses, `vector<address>`)
        ],
    })
}
