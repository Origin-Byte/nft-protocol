import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function borrow(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::balances::borrow`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function borrowMut(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::balances::borrow_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export function destroyEmpty(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::balances::destroy_empty`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function new_(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::balances::new`,
        arguments: [],
    })
}

export function withdrawAll(
    txb: TransactionBlock,
    typeArg: string,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::balances::withdraw_all`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface JoinWithArgs {
    self: ObjectArg; with: ObjectArg
}

export function joinWith(
    txb: TransactionBlock,
    typeArg: string,
    args: JoinWithArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::balances::join_with`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.with)
        ],
    })
}

export interface TakeFromArgs {
    self: ObjectArg; from: ObjectArg; amount: bigint | TransactionArgument
}

export function takeFrom(
    txb: TransactionBlock,
    typeArg: string,
    args: TakeFromArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::balances::take_from`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.from), pure(txb, args.amount, `u64`)
        ],
    })
}

export interface WithdrawAllFromArgs {
    self: ObjectArg; from: ObjectArg
}

export function withdrawAllFrom(
    txb: TransactionBlock,
    typeArg: string,
    args: WithdrawAllFromArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::balances::withdraw_all_from`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), obj(txb, args.from)
        ],
    })
}

export interface WithdrawAmountArgs {
    self: ObjectArg; amount: bigint | TransactionArgument
}

export function withdrawAmount(
    txb: TransactionBlock,
    typeArg: string,
    args: WithdrawAmountArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::balances::withdraw_amount`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.self), pure(txb, args.amount, `u64`)
        ],
    })
}
