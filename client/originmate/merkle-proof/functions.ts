import {PUBLISHED_AT} from "..";
import {pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface EfficientHashArgs {
    a: Array<number | TransactionArgument> | TransactionArgument; b: Array<number | TransactionArgument> | TransactionArgument
}

export function efficientHash(
    txb: TransactionBlock,
    args: EfficientHashArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::merkle_proof::efficient_hash`,
        arguments: [
            pure(txb, args.a, `vector<u8>`), pure(txb, args.b, `vector<u8>`)
        ],
    })
}

export interface HashPairArgs {
    a: Array<number | TransactionArgument> | TransactionArgument; b: Array<number | TransactionArgument> | TransactionArgument
}

export function hashPair(
    txb: TransactionBlock,
    args: HashPairArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::merkle_proof::hash_pair`,
        arguments: [
            pure(txb, args.a, `vector<u8>`), pure(txb, args.b, `vector<u8>`)
        ],
    })
}

export interface MultiProofVerifyArgs {
    proof: Array<Array<number | TransactionArgument> | TransactionArgument> | TransactionArgument; proofFlags: Array<boolean | TransactionArgument> | TransactionArgument; root: Array<number | TransactionArgument> | TransactionArgument; leaves: Array<Array<number | TransactionArgument> | TransactionArgument> | TransactionArgument
}

export function multiProofVerify(
    txb: TransactionBlock,
    args: MultiProofVerifyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::merkle_proof::multi_proof_verify`,
        arguments: [
            pure(txb, args.proof, `vector<vector<u8>>`), pure(txb, args.proofFlags, `vector<bool>`), pure(txb, args.root, `vector<u8>`), pure(txb, args.leaves, `vector<vector<u8>>`)
        ],
    })
}

export interface ProcessMultiProofArgs {
    proof: Array<Array<number | TransactionArgument> | TransactionArgument> | TransactionArgument; proofFlags: Array<boolean | TransactionArgument> | TransactionArgument; leaves: Array<Array<number | TransactionArgument> | TransactionArgument> | TransactionArgument
}

export function processMultiProof(
    txb: TransactionBlock,
    args: ProcessMultiProofArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::merkle_proof::process_multi_proof`,
        arguments: [
            pure(txb, args.proof, `vector<vector<u8>>`), pure(txb, args.proofFlags, `vector<bool>`), pure(txb, args.leaves, `vector<vector<u8>>`)
        ],
    })
}

export interface ProcessProofArgs {
    proof: Array<Array<number | TransactionArgument> | TransactionArgument> | TransactionArgument; leaf: Array<number | TransactionArgument> | TransactionArgument
}

export function processProof(
    txb: TransactionBlock,
    args: ProcessProofArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::merkle_proof::process_proof`,
        arguments: [
            pure(txb, args.proof, `vector<vector<u8>>`), pure(txb, args.leaf, `vector<u8>`)
        ],
    })
}

export interface VerifyArgs {
    proof: Array<Array<number | TransactionArgument> | TransactionArgument> | TransactionArgument; root: Array<number | TransactionArgument> | TransactionArgument; leaf: Array<number | TransactionArgument> | TransactionArgument
}

export function verify(
    txb: TransactionBlock,
    args: VerifyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::merkle_proof::verify`,
        arguments: [
            pure(txb, args.proof, `vector<vector<u8>>`), pure(txb, args.root, `vector<u8>`), pure(txb, args.leaf, `vector<u8>`)
        ],
    })
}
