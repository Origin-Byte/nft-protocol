import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export function new_(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::new`,
        arguments: [],
    })
}

export function delete_(
    txb: TransactionBlock,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::delete`,
        arguments: [
            obj(txb, domain)
        ],
    })
}

export interface RegisterNftArgs {
    parentNft: ObjectArg; childId: string | TransactionArgument
}

export function registerNft(
    txb: TransactionBlock,
    args: RegisterNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::register_nft`,
        arguments: [
            obj(txb, args.parentNft), pure(txb, args.childId, `0x2::object::ID`)
        ],
    })
}

export interface AddDomainArgs {
    nft: ObjectArg; domain: ObjectArg
}

export function addDomain(
    txb: TransactionBlock,
    args: AddDomainArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::add_domain`,
        arguments: [
            obj(txb, args.nft), obj(txb, args.domain)
        ],
    })
}

export function borrowDomain(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::borrow_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function borrowDomainMut(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::borrow_domain_mut`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function hasDomain(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::has_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function removeDomain(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::remove_domain`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function addNew(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::add_new`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface AddFromAttributesArgs {
    nft: ObjectArg; attributes: ObjectArg
}

export function addFromAttributes(
    txb: TransactionBlock,
    args: AddFromAttributesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::add_from_attributes`,
        arguments: [
            obj(txb, args.nft), obj(txb, args.attributes)
        ],
    })
}

export function assertComposableSvg(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::assert_composable_svg`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function assertNoComposableSvg(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::assert_no_composable_svg`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export function borrowAttributes(
    txb: TransactionBlock,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::borrow_attributes`,
        arguments: [
            obj(txb, domain)
        ],
    })
}

export function borrowNfts(
    txb: TransactionBlock,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::borrow_nfts`,
        arguments: [
            obj(txb, domain)
        ],
    })
}

export function borrowSvg(
    txb: TransactionBlock,
    domain: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::borrow_svg`,
        arguments: [
            obj(txb, domain)
        ],
    })
}

export function borrowSvgNft(
    txb: TransactionBlock,
    nft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::borrow_svg_nft`,
        arguments: [
            obj(txb, nft)
        ],
    })
}

export interface DeregisterArgs {
    composableSvg: ObjectArg; childId: string | TransactionArgument
}

export function deregister(
    txb: TransactionBlock,
    args: DeregisterArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::deregister`,
        arguments: [
            obj(txb, args.composableSvg), pure(txb, args.childId, `0x2::object::ID`)
        ],
    })
}

export interface DeregisterNftArgs {
    parentNft: ObjectArg; childId: string | TransactionArgument
}

export function deregisterNft(
    txb: TransactionBlock,
    args: DeregisterNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::deregister_nft`,
        arguments: [
            obj(txb, args.parentNft), pure(txb, args.childId, `0x2::object::ID`)
        ],
    })
}

export interface FinishRenderArgs {
    hp: ObjectArg; composableSvg: ObjectArg
}

export function finishRender(
    txb: TransactionBlock,
    args: FinishRenderArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::finish_render`,
        arguments: [
            obj(txb, args.hp), obj(txb, args.composableSvg)
        ],
    })
}

export interface FinishRenderNftArgs {
    hp: ObjectArg; parentNft: ObjectArg
}

export function finishRenderNft(
    txb: TransactionBlock,
    args: FinishRenderNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::finish_render_nft`,
        arguments: [
            obj(txb, args.hp), obj(txb, args.parentNft)
        ],
    })
}

export function fromAttributes(
    txb: TransactionBlock,
    attributes: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::from_attributes`,
        arguments: [
            obj(txb, attributes)
        ],
    })
}

export interface RegisterArgs {
    composableSvg: ObjectArg; childId: string | TransactionArgument
}

export function register(
    txb: TransactionBlock,
    args: RegisterArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::register`,
        arguments: [
            obj(txb, args.composableSvg), pure(txb, args.childId, `0x2::object::ID`)
        ],
    })
}

export interface RenderChildArgs {
    hp: ObjectArg; child: ObjectArg
}

export function renderChild(
    txb: TransactionBlock,
    args: RenderChildArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::render_child`,
        arguments: [
            obj(txb, args.hp), obj(txb, args.child)
        ],
    })
}

export interface RenderChild_Args {
    hp: ObjectArg; childId: string | TransactionArgument; nftSvg: Array<number | TransactionArgument> | TransactionArgument
}

export function renderChild_(
    txb: TransactionBlock,
    args: RenderChild_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::render_child_`,
        arguments: [
            obj(txb, args.hp), pure(txb, args.childId, `0x2::object::ID`), pure(txb, args.nftSvg, `vector<u8>`)
        ],
    })
}

export interface RenderChildExternalArgs {
    hp: ObjectArg; child: ObjectArg; nftSvg: Array<number | TransactionArgument> | TransactionArgument
}

export function renderChildExternal(
    txb: TransactionBlock,
    args: RenderChildExternalArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::render_child_external`,
        arguments: [
            obj(txb, args.hp), obj(txb, args.child), pure(txb, args.nftSvg, `vector<u8>`)
        ],
    })
}

export function startRender(
    txb: TransactionBlock,
    composableSvg: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::start_render`,
        arguments: [
            obj(txb, composableSvg)
        ],
    })
}

export function startRenderNft(
    txb: TransactionBlock,
    parentNft: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::composable_svg::start_render_nft`,
        arguments: [
            obj(txb, parentNft)
        ],
    })
}
