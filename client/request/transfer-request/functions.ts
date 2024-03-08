import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    nft: string | TransactionArgument; originator: string | TransactionArgument; kioskId: string | TransactionArgument; price: bigint | TransactionArgument
}

export function new_(
    txb: TransactionBlock,
    typeArg: string,
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::new`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.nft, `0x2::object::ID`), pure(txb, args.originator, `address`), pure(txb, args.kioskId, `0x2::object::ID`), pure(txb, args.price, `u64`)
        ],
    })
}

export function metadata(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::metadata`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface AddReceiptArgs {
    self: ObjectArg; rule: GenericArg
}

export function addReceipt(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AddReceiptArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::add_receipt`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), generic(txb, `${typeArgs[1]}`, args.rule)
        ],
    })
}

export function inner(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::inner`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface AddOriginbyteRuleArgs {
    rule: GenericArg; self: ObjectArg; cap: ObjectArg; cfg: GenericArg
}

export function addOriginbyteRule(
    txb: TransactionBlock,
    typeArgs: [string, string, string],
    args: AddOriginbyteRuleArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::add_originbyte_rule`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.rule), obj(txb, args.self), obj(txb, args.cap), generic(txb, `${typeArgs[2]}`, args.cfg)
        ],
    })
}

export function balance_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::balance_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function balanceMut_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::balance_mut_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface ConfirmArgs {
    self: ObjectArg; policy: ObjectArg
}

export function confirm(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ConfirmArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::confirm`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.policy)
        ],
    })
}

export function distributeBalanceToBeneficiary(
    txb: TransactionBlock,
    typeArgs: [string, string],
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::distribute_balance_to_beneficiary`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface FromSuiArgs {
    inner: ObjectArg; nft: string | TransactionArgument; originator: string | TransactionArgument
}

export function fromSui(
    txb: TransactionBlock,
    typeArg: string,
    args: FromSuiArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::from_sui`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.inner), pure(txb, args.nft, `0x2::object::ID`), pure(txb, args.originator, `address`)
        ],
    })
}

export function nft(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function originator(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::originator`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function grantBalanceAccessCap(
    txb: TransactionBlock,
    typeArg: string,
    witness: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::grant_balance_access_cap`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, witness)
        ],
    })
}

export function initPolicy(
    txb: TransactionBlock,
    typeArg: string,
    publisher: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::init_policy`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, publisher)
        ],
    })
}

export function innerMut(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::inner_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface IntoSuiArgs {
    self: ObjectArg; policy: ObjectArg
}

export function intoSui(
    txb: TransactionBlock,
    typeArg: string,
    args: IntoSuiArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::into_sui`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.policy)
        ],
    })
}

export function isOriginbyte(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::is_originbyte`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function metadataMut(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::metadata_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function paidInFt(
    txb: TransactionBlock,
    typeArgs: [string, string],
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::paid_in_ft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface PaidInFtMutArgs {
    self: ObjectArg; cap: ObjectArg
}

export function paidInFtMut(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: PaidInFtMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::paid_in_ft_mut`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.cap)
        ],
    })
}

export function paidInSui(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::paid_in_sui`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface PaidInSuiMutArgs {
    self: ObjectArg; cap: ObjectArg
}

export function paidInSuiMut(
    txb: TransactionBlock,
    typeArg: string,
    args: PaidInSuiMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::paid_in_sui_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.cap)
        ],
    })
}

export interface RemoveOriginbyteRuleArgs {
    self: ObjectArg; cap: ObjectArg
}

export function removeOriginbyteRule(
    txb: TransactionBlock,
    typeArgs: [string, string, string],
    args: RemoveOriginbyteRuleArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::remove_originbyte_rule`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.cap)
        ],
    })
}

export function setNothingPaid(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::set_nothing_paid`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface SetPaidArgs {
    self: ObjectArg; paid: ObjectArg; beneficiary: string | TransactionArgument
}

export function setPaid(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SetPaidArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::transfer_request::set_paid`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.paid), pure(txb, args.beneficiary, `address`)
        ],
    })
}
