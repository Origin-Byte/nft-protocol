import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface EmitBurnArgs {
    guard: ObjectArg; collectionId: string | TransactionArgument; object: ObjectArg
}

export function emitBurn(
    txb: TransactionBlock,
    typeArg: string,
    args: EmitBurnArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_event::emit_burn`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.guard), pure(txb, args.collectionId, `0x2::object::ID`), obj(txb, args.object)
        ],
    })
}

export interface EmitMintArgs {
    witness: ObjectArg; collectionId: string | TransactionArgument; object: GenericArg
}

export function emitMint(
    txb: TransactionBlock,
    typeArg: string,
    args: EmitMintArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_event::emit_mint`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), pure(txb, args.collectionId, `0x2::object::ID`), generic(txb, `${typeArg}`, args.object)
        ],
    })
}

export interface StartBurnArgs {
    witness: ObjectArg; object: GenericArg
}

export function startBurn(
    txb: TransactionBlock,
    typeArg: string,
    args: StartBurnArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::mint_event::start_burn`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.witness), generic(txb, `${typeArg}`, args.object)
        ],
    })
}
