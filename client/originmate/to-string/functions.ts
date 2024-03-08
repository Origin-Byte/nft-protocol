import {PUBLISHED_AT} from "..";
import {pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function toString(
    txb: TransactionBlock,
    value: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::to_string::to_string`,
        arguments: [
            pure(txb, value, `u128`)
        ],
    })
}

export function bytesToHexString(
    txb: TransactionBlock,
    bytes: Array<number | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::to_string::bytes_to_hex_string`,
        arguments: [
            pure(txb, bytes, `vector<u8>`)
        ],
    })
}

export function toHexString(
    txb: TransactionBlock,
    value: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::to_string::to_hex_string`,
        arguments: [
            pure(txb, value, `u128`)
        ],
    })
}

export interface ToHexStringFixedLengthArgs {
    value: bigint | TransactionArgument; length: bigint | TransactionArgument
}

export function toHexStringFixedLength(
    txb: TransactionBlock,
    args: ToHexStringFixedLengthArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::to_string::to_hex_string_fixed_length`,
        arguments: [
            pure(txb, args.value, `u128`), pure(txb, args.length, `u128`)
        ],
    })
}
