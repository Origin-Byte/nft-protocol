import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function addressToString(
    txb: TransactionBlock,
    address: string | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display::address_to_string`,
        arguments: [
            pure(txb, address, `address`)
        ],
    })
}

export function bytesToString(
    txb: TransactionBlock,
    bytes: Array<number | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display::bytes_to_string`,
        arguments: [
            pure(txb, bytes, `vector<u8>`)
        ],
    })
}

export function fromVec(
    txb: TransactionBlock,
    vec: Array<string | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display::from_vec`,
        arguments: [
            pure(txb, vec, `vector<0x1::string::String>`)
        ],
    })
}

export function fromVecMap(
    txb: TransactionBlock,
    vec: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display::from_vec_map`,
        arguments: [
            obj(txb, vec)
        ],
    })
}

export interface FromVecMapRefArgs {
    vec: ObjectArg; isString: boolean | TransactionArgument
}

export function fromVecMapRef(
    txb: TransactionBlock,
    args: FromVecMapRefArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display::from_vec_map_ref`,
        arguments: [
            obj(txb, args.vec), pure(txb, args.isString, `bool`)
        ],
    })
}

export function fromVecUtf8(
    txb: TransactionBlock,
    vec: Array<Array<number | TransactionArgument> | TransactionArgument> | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display::from_vec_utf8`,
        arguments: [
            pure(txb, vec, `vector<vector<u8>>`)
        ],
    })
}

export function idToString(
    txb: TransactionBlock,
    id: string | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::display::id_to_string`,
        arguments: [
            pure(txb, id, `0x2::object::ID`)
        ],
    })
}
