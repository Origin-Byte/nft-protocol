import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface ApplyRebateArgs {
    object: ObjectArg; wallet: ObjectArg
}

export function applyRebate(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ApplyRebateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::rebate::apply_rebate`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.object), obj(txb, args.wallet)
        ],
    })
}

export function borrowRebate(
    txb: TransactionBlock,
    typeArgs: [string, string],
    object: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::rebate::borrow_rebate`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, object)
        ],
    })
}

export function borrowRebateAmount(
    txb: TransactionBlock,
    typeArg: string,
    rebate: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::rebate::borrow_rebate_amount`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, rebate)
        ],
    })
}

export function borrowRebateFunds(
    txb: TransactionBlock,
    typeArg: string,
    rebate: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::rebate::borrow_rebate_funds`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, rebate)
        ],
    })
}

export function borrowRebateMut(
    txb: TransactionBlock,
    typeArgs: [string, string],
    object: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::rebate::borrow_rebate_mut`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, object)
        ],
    })
}

export interface FundRebateArgs {
    object: ObjectArg; balance: ObjectArg; fundAmount: bigint | TransactionArgument
}

export function fundRebate(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: FundRebateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::rebate::fund_rebate`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.object), obj(txb, args.balance), pure(txb, args.fundAmount, `u64`)
        ],
    })
}

export function hasRebate(
    txb: TransactionBlock,
    typeArgs: [string, string],
    object: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::rebate::has_rebate`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, object)
        ],
    })
}

export interface SendRebateArgs {
    object: ObjectArg; receiver: string | TransactionArgument
}

export function sendRebate(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SendRebateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::rebate::send_rebate`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.object), pure(txb, args.receiver, `address`)
        ],
    })
}

export interface SetRebateArgs {
    object: ObjectArg; rebateAmount: bigint | TransactionArgument
}

export function setRebate(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SetRebateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::rebate::set_rebate`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.object), pure(txb, args.rebateAmount, `u64`)
        ],
    })
}

export interface WithdrawRebateFundsArgs {
    object: ObjectArg; receiver: ObjectArg; amount: bigint | TransactionArgument
}

export function withdrawRebateFunds(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: WithdrawRebateFundsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::rebate::withdraw_rebate_funds`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.object), obj(txb, args.receiver), pure(txb, args.amount, `u64`)
        ],
    })
}
