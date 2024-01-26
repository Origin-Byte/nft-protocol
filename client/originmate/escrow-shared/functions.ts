import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function transfer(
    txb: TransactionBlock,
    typeArg: string,
    escrow: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::escrow_shared::transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, escrow)
        ],
    })
}

export interface EscrowArgs {
    sender: string | TransactionArgument; recipient: string | TransactionArgument; arbitrator: (string | TransactionArgument | TransactionArgument | null); objIn: GenericArg
}

export function escrow(
    txb: TransactionBlock,
    typeArg: string,
    args: EscrowArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::escrow_shared::escrow`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.sender, `address`), pure(txb, args.recipient, `address`), pure(txb, args.arbitrator, `0x1::option::Option<address>`), generic(txb, `${typeArg}`, args.objIn)
        ],
    })
}

export function refund(
    txb: TransactionBlock,
    typeArg: string,
    escrow: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::escrow_shared::refund`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, escrow)
        ],
    })
}

export function refundArbitrated(
    txb: TransactionBlock,
    typeArg: string,
    escrow: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::escrow_shared::refund_arbitrated`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, escrow)
        ],
    })
}

export function transferArbitrated(
    txb: TransactionBlock,
    typeArg: string,
    escrow: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::escrow_shared::transfer_arbitrated`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, escrow)
        ],
    })
}
