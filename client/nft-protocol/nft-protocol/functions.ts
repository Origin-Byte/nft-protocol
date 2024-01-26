import {PUBLISHED_AT} from "..";
import {ObjectArg, obj} from "../../_framework/util";
import {TransactionBlock} from "@mysten/sui.js/transactions";

export function init(
    txb: TransactionBlock,
    otw: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_protocol::init`,
        arguments: [
            obj(txb, otw)
        ],
    })
}

export function initAuthlist(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_protocol::init_authlist`,
        arguments: [],
    })
}

export function initAllowlist(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_protocol::init_allowlist`,
        arguments: [],
    })
}

export function permissionlessPrivateKey(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_protocol::permissionless_private_key`,
        arguments: [],
    })
}

export function permissionlessPublicKey(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::nft_protocol::permissionless_public_key`,
        arguments: [],
    })
}
