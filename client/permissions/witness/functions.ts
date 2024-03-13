import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj} from "../../_framework/util";
import {TransactionBlock} from "@mysten/sui.js/transactions";

export function delegate(
    txb: TransactionBlock,
    typeArg: string,
    generator: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::witness::delegate`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, generator)
        ],
    })
}

export function fromPublisher(
    txb: TransactionBlock,
    typeArg: string,
    publisher: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::witness::from_publisher`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, publisher)
        ],
    })
}

export function fromWitness(
    txb: TransactionBlock,
    typeArgs: [string, string],
    witness: GenericArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::witness::from_witness`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, witness)
        ],
    })
}

export function generator(
    txb: TransactionBlock,
    typeArgs: [string, string],
    witness: GenericArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::witness::generator`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, witness)
        ],
    })
}

export function generatorDelegated(
    txb: TransactionBlock,
    typeArg: string,
    witness: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::witness::generator_delegated`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, witness)
        ],
    })
}
