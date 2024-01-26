import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj} from "../../_framework/util";
import {TransactionBlock} from "@mysten/sui.js/transactions";

export function new_(
    txb: TransactionBlock,
    typeArg: string,
    obj: GenericArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::typed_id::new`,
        typeArguments: [typeArg],
        arguments: [
            generic(txb, `${typeArg}`, obj)
        ],
    })
}

export function asId(
    txb: TransactionBlock,
    typeArg: string,
    typedId: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::typed_id::as_id`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, typedId)
        ],
    })
}

export interface EqualsObjectArgs {
    typedId: ObjectArg; obj: GenericArg
}

export function equalsObject(
    txb: TransactionBlock,
    typeArg: string,
    args: EqualsObjectArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::typed_id::equals_object`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.typedId), generic(txb, `${typeArg}`, args.obj)
        ],
    })
}

export function toId(
    txb: TransactionBlock,
    typeArg: string,
    typedId: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::typed_id::to_id`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, typedId)
        ],
    })
}
