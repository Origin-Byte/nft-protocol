import {PUBLISHED_AT} from "..";
import {TransactionBlock} from "@mysten/sui.js/transactions";

export function symbol(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::tags::symbol`,
        arguments: [],
    })
}

export function ticket(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::tags::ticket`,
        arguments: [],
    })
}

export function art(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::tags::art`,
        arguments: [],
    })
}

export function collectible(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::tags::collectible`,
        arguments: [],
    })
}

export function domainName(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::tags::domain_name`,
        arguments: [],
    })
}

export function gameAsset(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::tags::game_asset`,
        arguments: [],
    })
}

export function license(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::tags::license`,
        arguments: [],
    })
}

export function music(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::tags::music`,
        arguments: [],
    })
}

export function profilePicture(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::tags::profile_picture`,
        arguments: [],
    })
}

export function tokenisedAsset(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::tags::tokenised_asset`,
        arguments: [],
    })
}

export function video(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::tags::video`,
        arguments: [],
    })
}
