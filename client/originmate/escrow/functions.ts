import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function transfer(
    txb: TransactionBlock,
    typeArg: string,
    escrow: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::escrow::transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, escrow)
        ],
    })
}

export interface EscrowArgs {
    sender: string | TransactionArgument; recipient: string | TransactionArgument; objIn: GenericArg
}

export function escrow(
    txb: TransactionBlock,
    typeArg: string,
    args: EscrowArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::escrow::escrow`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.sender, `address`), pure(txb, args.recipient, `address`), generic(txb, `${typeArg}`, args.objIn)
        ],
    })
}
