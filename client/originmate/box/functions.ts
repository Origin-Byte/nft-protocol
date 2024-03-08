import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface BoxArgs {
    recipient: string | TransactionArgument; objIn: GenericArg
}

export function box(
    txb: TransactionBlock,
    typeArg: string,
    args: BoxArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::box::box`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.recipient, `address`), generic(txb, `${typeArg}`, args.objIn)
        ],
    })
}

export function unbox(
    txb: TransactionBlock,
    typeArg: string,
    box: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::box::unbox`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, box)
        ],
    })
}
