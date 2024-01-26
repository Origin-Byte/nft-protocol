import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface AddArgs {
    filter: ObjectArg; item: Array<number | TransactionArgument> | TransactionArgument
}

export function add(
    txb: TransactionBlock,
    args: AddArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bloom_filter::add`,
        arguments: [
            obj(txb, args.filter), pure(txb, args.item, `vector<u8>`)
        ],
    })
}

export function new_(
    txb: TransactionBlock,
    itemNum: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bloom_filter::new`,
        arguments: [
            pure(txb, itemNum, `u64`)
        ],
    })
}

export interface AddToBitmapArgs {
    bitmap: bigint | TransactionArgument; hashCount: number | TransactionArgument; item: Array<number | TransactionArgument> | TransactionArgument
}

export function addToBitmap(
    txb: TransactionBlock,
    args: AddToBitmapArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bloom_filter::add_to_bitmap`,
        arguments: [
            pure(txb, args.bitmap, `u256`), pure(txb, args.hashCount, `u8`), pure(txb, args.item, `vector<u8>`)
        ],
    })
}

export interface CheckArgs {
    filter: ObjectArg; item: Array<number | TransactionArgument> | TransactionArgument
}

export function check(
    txb: TransactionBlock,
    args: CheckArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bloom_filter::check`,
        arguments: [
            obj(txb, args.filter), pure(txb, args.item, `vector<u8>`)
        ],
    })
}

export interface FalsePositiveArgs {
    bitmap: bigint | TransactionArgument; hashCount: number | TransactionArgument; item: Array<number | TransactionArgument> | TransactionArgument
}

export function falsePositive(
    txb: TransactionBlock,
    args: FalsePositiveArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bloom_filter::false_positive`,
        arguments: [
            pure(txb, args.bitmap, `u256`), pure(txb, args.hashCount, `u8`), pure(txb, args.item, `vector<u8>`)
        ],
    })
}

export function getHashCount(
    txb: TransactionBlock,
    itemNum: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::bloom_filter::get_hash_count`,
        arguments: [
            pure(txb, itemNum, `u64`)
        ],
    })
}
