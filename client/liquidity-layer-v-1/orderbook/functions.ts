import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, option, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    witness: ObjectArg; transferPolicy: ObjectArg; protectedActions: ObjectArg
}

export function new_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::new`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.transferPolicy), obj(txb, args.protectedActions)
        ],
    })
}

export function assertVersion(
    txb: TransactionBlock,
    typeArgs: [string, string],
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::assert_version`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function assertVersionAndUpgrade(
    txb: TransactionBlock,
    typeArgs: [string, string],
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::assert_version_and_upgrade`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface MigrateAsCreatorArgs {
    self: ObjectArg; pub: ObjectArg
}

export function migrateAsCreator(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: MigrateAsCreatorArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::migrate_as_creator`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.pub)
        ],
    })
}

export interface MigrateAsPubArgs {
    self: ObjectArg; pub: ObjectArg
}

export function migrateAsPub(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: MigrateAsPubArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::migrate_as_pub`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.self), obj(txb, args.pub)
        ],
    })
}

export function new__(
    txb: TransactionBlock,
    typeArgs: [string, string],
    protectedActions: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::new_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, protectedActions)
        ],
    })
}

export interface CreateBidArgs {
    book: ObjectArg; buyerKiosk: ObjectArg; price: bigint | TransactionArgument; wallet: ObjectArg
}

export function createBid(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateBidArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::create_bid`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.buyerKiosk), pure(txb, args.price, `u64`), obj(txb, args.wallet)
        ],
    })
}

export interface CreateBidWithCommissionArgs {
    book: ObjectArg; buyerKiosk: ObjectArg; price: bigint | TransactionArgument; beneficiary: string | TransactionArgument; commissionFt: bigint | TransactionArgument; wallet: ObjectArg
}

export function createBidWithCommission(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateBidWithCommissionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::create_bid_with_commission`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.buyerKiosk), pure(txb, args.price, `u64`), pure(txb, args.beneficiary, `address`), pure(txb, args.commissionFt, `u64`), obj(txb, args.wallet)
        ],
    })
}

export function share(
    txb: TransactionBlock,
    typeArgs: [string, string],
    ob: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::share`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, ob)
        ],
    })
}

export interface AddAdministratorArgs {
    publisher: ObjectArg; orderbook: ObjectArg; administrator: string | TransactionArgument
}

export function addAdministrator(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AddAdministratorArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::add_administrator`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.publisher), obj(txb, args.orderbook), pure(txb, args.administrator, `address`)
        ],
    })
}

export interface AddAdministratorWithWitnessArgs {
    witness: ObjectArg; orderbook: ObjectArg; administrator: string | TransactionArgument
}

export function addAdministratorWithWitness(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AddAdministratorWithWitnessArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::add_administrator_with_witness`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.orderbook), pure(txb, args.administrator, `address`)
        ],
    })
}

export function askCommission(
    txb: TransactionBlock,
    ask: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::ask_commission`,
        arguments: [
            obj(txb, ask)
        ],
    })
}

export function askKioskId(
    txb: TransactionBlock,
    ask: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::ask_kiosk_id`,
        arguments: [
            obj(txb, ask)
        ],
    })
}

export function askNftId(
    txb: TransactionBlock,
    ask: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::ask_nft_id`,
        arguments: [
            obj(txb, ask)
        ],
    })
}

export function askOwner(
    txb: TransactionBlock,
    ask: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::ask_owner`,
        arguments: [
            obj(txb, ask)
        ],
    })
}

export function askPrice(
    txb: TransactionBlock,
    ask: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::ask_price`,
        arguments: [
            obj(txb, ask)
        ],
    })
}

export interface AssertAdministratorArgs {
    orderbook: ObjectArg; administrator: string | TransactionArgument
}

export function assertAdministrator(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: AssertAdministratorArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::assert_administrator`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.orderbook), pure(txb, args.administrator, `address`)
        ],
    })
}

export function assertNotUnderMigration(
    txb: TransactionBlock,
    typeArgs: [string, string],
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::assert_not_under_migration`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface AssertTickLevelArgs {
    price: bigint | TransactionArgument; tickSize: bigint | TransactionArgument
}

export function assertTickLevel(
    txb: TransactionBlock,
    args: AssertTickLevelArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::assert_tick_level`,
        arguments: [
            pure(txb, args.price, `u64`), pure(txb, args.tickSize, `u64`)
        ],
    })
}

export function assertUnderMigration(
    txb: TransactionBlock,
    typeArgs: [string, string],
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::assert_under_migration`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, self)
        ],
    })
}

export function bidCommission(
    txb: TransactionBlock,
    typeArg: string,
    bid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::bid_commission`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, bid)
        ],
    })
}

export function bidKioskId(
    txb: TransactionBlock,
    typeArg: string,
    bid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::bid_kiosk_id`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, bid)
        ],
    })
}

export function bidOffer(
    txb: TransactionBlock,
    typeArg: string,
    bid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::bid_offer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, bid)
        ],
    })
}

export function bidOwner(
    txb: TransactionBlock,
    typeArg: string,
    bid: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::bid_owner`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, bid)
        ],
    })
}

export interface BorrowAdministratorsMutOrCreateArgs {
    witness: ObjectArg; orderbook: ObjectArg
}

export function borrowAdministratorsMutOrCreate(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BorrowAdministratorsMutOrCreateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::borrow_administrators_mut_or_create`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.orderbook)
        ],
    })
}

export function borrowAsks(
    txb: TransactionBlock,
    typeArgs: [string, string],
    book: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::borrow_asks`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, book)
        ],
    })
}

export function borrowBids(
    txb: TransactionBlock,
    typeArgs: [string, string],
    book: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::borrow_bids`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, book)
        ],
    })
}

export interface BuyNftArgs {
    book: ObjectArg; sellerKiosk: ObjectArg; buyerKiosk: ObjectArg; nftId: string | TransactionArgument; price: bigint | TransactionArgument; wallet: ObjectArg
}

export function buyNft(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BuyNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::buy_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.sellerKiosk), obj(txb, args.buyerKiosk), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.price, `u64`), obj(txb, args.wallet)
        ],
    })
}

export interface BuyNft_Args {
    book: ObjectArg; sellerKiosk: ObjectArg; buyerKiosk: ObjectArg; nftId: string | TransactionArgument; price: bigint | TransactionArgument; wallet: ObjectArg
}

export function buyNft_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BuyNft_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::buy_nft_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.sellerKiosk), obj(txb, args.buyerKiosk), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.price, `u64`), obj(txb, args.wallet)
        ],
    })
}

export interface BuyNftProtectedArgs {
    witness: ObjectArg; book: ObjectArg; sellerKiosk: ObjectArg; buyerKiosk: ObjectArg; nftId: string | TransactionArgument; price: bigint | TransactionArgument; wallet: ObjectArg
}

export function buyNftProtected(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: BuyNftProtectedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::buy_nft_protected`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.book), obj(txb, args.sellerKiosk), obj(txb, args.buyerKiosk), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.price, `u64`), obj(txb, args.wallet)
        ],
    })
}

export interface CancelAskArgs {
    book: ObjectArg; sellerKiosk: ObjectArg; nftPriceLevel: bigint | TransactionArgument; nftId: string | TransactionArgument
}

export function cancelAsk(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CancelAskArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::cancel_ask`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.sellerKiosk), pure(txb, args.nftPriceLevel, `u64`), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface CancelAsk_Args {
    book: ObjectArg; kiosk: ObjectArg; nftPriceLevel: bigint | TransactionArgument; nftId: string | TransactionArgument
}

export function cancelAsk_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CancelAsk_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::cancel_ask_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.kiosk), pure(txb, args.nftPriceLevel, `u64`), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface CancelBidArgs {
    book: ObjectArg; bidPriceLevel: bigint | TransactionArgument; wallet: ObjectArg
}

export function cancelBid(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CancelBidArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::cancel_bid`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), pure(txb, args.bidPriceLevel, `u64`), obj(txb, args.wallet)
        ],
    })
}

export interface CancelBid_Args {
    book: ObjectArg; bidPriceLevel: bigint | TransactionArgument; wallet: ObjectArg
}

export function cancelBid_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CancelBid_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::cancel_bid_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), pure(txb, args.bidPriceLevel, `u64`), obj(txb, args.wallet)
        ],
    })
}

export interface CancelBidExceptCommissionArgs {
    book: ObjectArg; bidPriceLevel: bigint | TransactionArgument; wallet: ObjectArg
}

export function cancelBidExceptCommission(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CancelBidExceptCommissionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::cancel_bid_except_commission`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), pure(txb, args.bidPriceLevel, `u64`), obj(txb, args.wallet)
        ],
    })
}

export interface ChangeTickSizeArgs {
    witness: ObjectArg; book: ObjectArg; newTick: bigint | TransactionArgument
}

export function changeTickSize(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ChangeTickSizeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::change_tick_size`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.book), pure(txb, args.newTick, `u64`)
        ],
    })
}

export interface CheckTickLevelArgs {
    price: bigint | TransactionArgument; tickSize: bigint | TransactionArgument
}

export function checkTickLevel(
    txb: TransactionBlock,
    args: CheckTickLevelArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::check_tick_level`,
        arguments: [
            pure(txb, args.price, `u64`), pure(txb, args.tickSize, `u64`)
        ],
    })
}

export interface CreateAskArgs {
    book: ObjectArg; sellerKiosk: ObjectArg; requestedTokens: bigint | TransactionArgument; nftId: string | TransactionArgument
}

export function createAsk(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateAskArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::create_ask`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.sellerKiosk), pure(txb, args.requestedTokens, `u64`), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface CreateAsk_Args {
    book: ObjectArg; sellerKiosk: ObjectArg; price: bigint | TransactionArgument; askCommission: (ObjectArg | TransactionArgument | null); nftId: string | TransactionArgument
}

export function createAsk_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateAsk_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::create_ask_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.sellerKiosk), pure(txb, args.price, `u64`), option(txb, `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::AskCommission`, args.askCommission), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface CreateAskProtectedArgs {
    witness: ObjectArg; book: ObjectArg; sellerKiosk: ObjectArg; requestedTokens: bigint | TransactionArgument; nftId: string | TransactionArgument
}

export function createAskProtected(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateAskProtectedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::create_ask_protected`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.book), obj(txb, args.sellerKiosk), pure(txb, args.requestedTokens, `u64`), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface CreateAskWithCommissionArgs {
    book: ObjectArg; sellerKiosk: ObjectArg; requestedTokens: bigint | TransactionArgument; nftId: string | TransactionArgument; beneficiary: string | TransactionArgument; commissionFt: bigint | TransactionArgument
}

export function createAskWithCommission(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateAskWithCommissionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::create_ask_with_commission`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.sellerKiosk), pure(txb, args.requestedTokens, `u64`), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.beneficiary, `address`), pure(txb, args.commissionFt, `u64`)
        ],
    })
}

export interface CreateAskWithCommissionProtectedArgs {
    witness: ObjectArg; book: ObjectArg; sellerKiosk: ObjectArg; requestedTokens: bigint | TransactionArgument; nftId: string | TransactionArgument; beneficiary: string | TransactionArgument; commissionFt: bigint | TransactionArgument
}

export function createAskWithCommissionProtected(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateAskWithCommissionProtectedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::create_ask_with_commission_protected`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.book), obj(txb, args.sellerKiosk), pure(txb, args.requestedTokens, `u64`), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.beneficiary, `address`), pure(txb, args.commissionFt, `u64`)
        ],
    })
}

export interface CreateBid_Args {
    book: ObjectArg; buyerKiosk: ObjectArg; price: bigint | TransactionArgument; bidCommission: (ObjectArg | TransactionArgument | null); wallet: ObjectArg
}

export function createBid_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateBid_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::create_bid_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.buyerKiosk), pure(txb, args.price, `u64`), option(txb, `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::BidCommission<${typeArgs[1]}>`, args.bidCommission), obj(txb, args.wallet)
        ],
    })
}

export interface CreateBidProtectedArgs {
    witness: ObjectArg; book: ObjectArg; buyerKiosk: ObjectArg; price: bigint | TransactionArgument; wallet: ObjectArg
}

export function createBidProtected(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateBidProtectedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::create_bid_protected`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.book), obj(txb, args.buyerKiosk), pure(txb, args.price, `u64`), obj(txb, args.wallet)
        ],
    })
}

export interface CreateBidWithCommissionProtectedArgs {
    witness: ObjectArg; book: ObjectArg; buyerKiosk: ObjectArg; price: bigint | TransactionArgument; beneficiary: string | TransactionArgument; commissionFt: bigint | TransactionArgument; wallet: ObjectArg
}

export function createBidWithCommissionProtected(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateBidWithCommissionProtectedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::create_bid_with_commission_protected`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.book), obj(txb, args.buyerKiosk), pure(txb, args.price, `u64`), pure(txb, args.beneficiary, `address`), pure(txb, args.commissionFt, `u64`), obj(txb, args.wallet)
        ],
    })
}

export function createForExternal(
    txb: TransactionBlock,
    typeArgs: [string, string],
    transferPolicy: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::create_for_external`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, transferPolicy)
        ],
    })
}

export interface CreateUnprotectedArgs {
    witness: ObjectArg; transferPolicy: ObjectArg
}

export function createUnprotected(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateUnprotectedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::create_unprotected`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.transferPolicy)
        ],
    })
}

export interface CustomProtectionArgs {
    buyNft: boolean | TransactionArgument; createAsk: boolean | TransactionArgument; createBid: boolean | TransactionArgument
}

export function customProtection(
    txb: TransactionBlock,
    args: CustomProtectionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::custom_protection`,
        arguments: [
            pure(txb, args.buyNft, `bool`), pure(txb, args.createAsk, `bool`), pure(txb, args.createBid, `bool`)
        ],
    })
}

export interface DisableOrderbookArgs {
    publisher: ObjectArg; orderbook: ObjectArg
}

export function disableOrderbook(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: DisableOrderbookArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::disable_orderbook`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.publisher), obj(txb, args.orderbook)
        ],
    })
}

export function disableOrderbookAsAdministrator(
    txb: TransactionBlock,
    typeArgs: [string, string],
    orderbook: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::disable_orderbook_as_administrator`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, orderbook)
        ],
    })
}

export interface EditAskArgs {
    book: ObjectArg; sellerKiosk: ObjectArg; oldPrice: bigint | TransactionArgument; nftId: string | TransactionArgument; newPrice: bigint | TransactionArgument
}

export function editAsk(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: EditAskArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::edit_ask`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.sellerKiosk), pure(txb, args.oldPrice, `u64`), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.newPrice, `u64`)
        ],
    })
}

export interface EditAskWithCommissionArgs {
    book: ObjectArg; sellerKiosk: ObjectArg; oldPrice: bigint | TransactionArgument; nftId: string | TransactionArgument; newPrice: bigint | TransactionArgument; beneficiary: string | TransactionArgument; commissionFt: bigint | TransactionArgument
}

export function editAskWithCommission(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: EditAskWithCommissionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::edit_ask_with_commission`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.sellerKiosk), pure(txb, args.oldPrice, `u64`), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.newPrice, `u64`), pure(txb, args.beneficiary, `address`), pure(txb, args.commissionFt, `u64`)
        ],
    })
}

export interface EditBidArgs {
    book: ObjectArg; buyerKiosk: ObjectArg; oldPrice: bigint | TransactionArgument; newPrice: bigint | TransactionArgument; wallet: ObjectArg
}

export function editBid(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: EditBidArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::edit_bid`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.buyerKiosk), pure(txb, args.oldPrice, `u64`), pure(txb, args.newPrice, `u64`), obj(txb, args.wallet)
        ],
    })
}

export interface EditBidWithCommissionArgs {
    book: ObjectArg; buyerKiosk: ObjectArg; oldPrice: bigint | TransactionArgument; newPrice: bigint | TransactionArgument; beneficiary: string | TransactionArgument; commissionFt: bigint | TransactionArgument; wallet: ObjectArg
}

export function editBidWithCommission(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: EditBidWithCommissionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::edit_bid_with_commission`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.buyerKiosk), pure(txb, args.oldPrice, `u64`), pure(txb, args.newPrice, `u64`), pure(txb, args.beneficiary, `address`), pure(txb, args.commissionFt, `u64`), obj(txb, args.wallet)
        ],
    })
}

export interface EnableOrderbookArgs {
    publisher: ObjectArg; orderbook: ObjectArg
}

export function enableOrderbook(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: EnableOrderbookArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::enable_orderbook`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.publisher), obj(txb, args.orderbook)
        ],
    })
}

export function enableOrderbookAsAdministrator(
    txb: TransactionBlock,
    typeArgs: [string, string],
    orderbook: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::enable_orderbook_as_administrator`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, orderbook)
        ],
    })
}

export interface EnableTradingPermissionlessArgs {
    orderbook: ObjectArg; clock: ObjectArg
}

export function enableTradingPermissionless(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: EnableTradingPermissionlessArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::enable_trading_permissionless`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.orderbook), obj(txb, args.clock)
        ],
    })
}

export interface FinishTradeArgs {
    book: ObjectArg; tradeId: string | TransactionArgument; sellerKiosk: ObjectArg; buyerKiosk: ObjectArg
}

export function finishTrade(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: FinishTradeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::finish_trade`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), pure(txb, args.tradeId, `0x2::object::ID`), obj(txb, args.sellerKiosk), obj(txb, args.buyerKiosk)
        ],
    })
}

export function tradeId(
    txb: TransactionBlock,
    trade: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::trade_id`,
        arguments: [
            obj(txb, trade)
        ],
    })
}

export interface FinishTrade_Args {
    book: ObjectArg; tradeId: string | TransactionArgument; sellerKiosk: ObjectArg; buyerKiosk: ObjectArg
}

export function finishTrade_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: FinishTrade_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::finish_trade_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), pure(txb, args.tradeId, `0x2::object::ID`), obj(txb, args.sellerKiosk), obj(txb, args.buyerKiosk)
        ],
    })
}

export interface FinishTradeIfKiosksMatchArgs {
    book: ObjectArg; tradeId: string | TransactionArgument; sellerKiosk: ObjectArg; buyerKiosk: ObjectArg
}

export function finishTradeIfKiosksMatch(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: FinishTradeIfKiosksMatchArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::finish_trade_if_kiosks_match`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), pure(txb, args.tradeId, `0x2::object::ID`), obj(txb, args.sellerKiosk), obj(txb, args.buyerKiosk)
        ],
    })
}

export interface IsAdministratorArgs {
    orderbook: ObjectArg; administrator: string | TransactionArgument
}

export function isAdministrator(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: IsAdministratorArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::is_administrator`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.orderbook), pure(txb, args.administrator, `address`)
        ],
    })
}

export function isBuyNftProtected(
    txb: TransactionBlock,
    protectedActions: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::is_buy_nft_protected`,
        arguments: [
            obj(txb, protectedActions)
        ],
    })
}

export function protectedActions(
    txb: TransactionBlock,
    typeArgs: [string, string],
    book: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::protected_actions`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, book)
        ],
    })
}

export function isCreateAskProtected(
    txb: TransactionBlock,
    protectedActions: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::is_create_ask_protected`,
        arguments: [
            obj(txb, protectedActions)
        ],
    })
}

export function isCreateBidProtected(
    txb: TransactionBlock,
    protectedActions: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::is_create_bid_protected`,
        arguments: [
            obj(txb, protectedActions)
        ],
    })
}

export interface MarketBuyArgs {
    book: ObjectArg; buyerKiosk: ObjectArg; wallet: ObjectArg; maxPrice: bigint | TransactionArgument
}

export function marketBuy(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: MarketBuyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::market_buy`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.buyerKiosk), obj(txb, args.wallet), pure(txb, args.maxPrice, `u64`)
        ],
    })
}

export interface MarketBuyWithCommissionArgs {
    book: ObjectArg; buyerKiosk: ObjectArg; beneficiary: string | TransactionArgument; commissionFt: bigint | TransactionArgument; wallet: ObjectArg; maxPrice: bigint | TransactionArgument
}

export function marketBuyWithCommission(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: MarketBuyWithCommissionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::market_buy_with_commission`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.buyerKiosk), pure(txb, args.beneficiary, `address`), pure(txb, args.commissionFt, `u64`), obj(txb, args.wallet), pure(txb, args.maxPrice, `u64`)
        ],
    })
}

export interface MarketSellArgs {
    book: ObjectArg; sellerKiosk: ObjectArg; minPrice: bigint | TransactionArgument; nftId: string | TransactionArgument
}

export function marketSell(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: MarketSellArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::market_sell`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.sellerKiosk), pure(txb, args.minPrice, `u64`), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface MarketSellWithCommissionArgs {
    book: ObjectArg; sellerKiosk: ObjectArg; beneficiary: string | TransactionArgument; commissionFt: bigint | TransactionArgument; minPrice: bigint | TransactionArgument; nftId: string | TransactionArgument
}

export function marketSellWithCommission(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: MarketSellWithCommissionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::market_sell_with_commission`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), obj(txb, args.sellerKiosk), pure(txb, args.beneficiary, `address`), pure(txb, args.commissionFt, `u64`), pure(txb, args.minPrice, `u64`), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface MatchBuyWithAsk_Args {
    book: ObjectArg; lowestAskPrice: bigint | TransactionArgument; buyerKioskId: string | TransactionArgument; bidCommission: (ObjectArg | TransactionArgument | null); wallet: ObjectArg
}

export function matchBuyWithAsk_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: MatchBuyWithAsk_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::match_buy_with_ask_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), pure(txb, args.lowestAskPrice, `u64`), pure(txb, args.buyerKioskId, `0x2::object::ID`), option(txb, `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::BidCommission<${typeArgs[1]}>`, args.bidCommission), obj(txb, args.wallet)
        ],
    })
}

export interface MatchSellWithBid_Args {
    book: ObjectArg; highestBidPrice: bigint | TransactionArgument; sellerKioskId: string | TransactionArgument; askCommission: (ObjectArg | TransactionArgument | null); nftId: string | TransactionArgument
}

export function matchSellWithBid_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: MatchSellWithBid_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::match_sell_with_bid_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), pure(txb, args.highestBidPrice, `u64`), pure(txb, args.sellerKioskId, `0x2::object::ID`), option(txb, `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::AskCommission`, args.askCommission), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface NewUnprotectedArgs {
    witness: ObjectArg; transferPolicy: ObjectArg
}

export function newUnprotected(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: NewUnprotectedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::new_unprotected`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.transferPolicy)
        ],
    })
}

export interface NewWithProtectedActionsArgs {
    witness: ObjectArg; transferPolicy: ObjectArg; protectedActions: ObjectArg
}

export function newWithProtectedActions(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: NewWithProtectedActionsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::new_with_protected_actions`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.transferPolicy), obj(txb, args.protectedActions)
        ],
    })
}

export function noProtection(
    txb: TransactionBlock,
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::no_protection`,
        arguments: [],
    })
}

export interface RemoveAdministratorArgs {
    publisher: ObjectArg; orderbook: ObjectArg; administrator: string | TransactionArgument
}

export function removeAdministrator(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: RemoveAdministratorArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::remove_administrator`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.publisher), obj(txb, args.orderbook), pure(txb, args.administrator, `address`)
        ],
    })
}

export interface RemoveAdministratorWithWitnessArgs {
    witness: ObjectArg; orderbook: ObjectArg; administrator: string | TransactionArgument
}

export function removeAdministratorWithWitness(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: RemoveAdministratorWithWitnessArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::remove_administrator_with_witness`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.orderbook), pure(txb, args.administrator, `address`)
        ],
    })
}

export interface RemoveAskArgs {
    asks: ObjectArg; price: bigint | TransactionArgument; nftId: string | TransactionArgument
}

export function removeAsk(
    txb: TransactionBlock,
    args: RemoveAskArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::remove_ask`,
        arguments: [
            obj(txb, args.asks), pure(txb, args.price, `u64`), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface RemoveStartTimeArgs {
    publisher: ObjectArg; orderbook: ObjectArg
}

export function removeStartTime(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: RemoveStartTimeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::remove_start_time`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.publisher), obj(txb, args.orderbook)
        ],
    })
}

export function removeStartTime_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    orderbook: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::remove_start_time_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, orderbook)
        ],
    })
}

export function removeStartTimeAsAdministrator(
    txb: TransactionBlock,
    typeArgs: [string, string],
    orderbook: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::remove_start_time_as_administrator`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, orderbook)
        ],
    })
}

export interface RemoveStartTimeWithWitnessArgs {
    witness: ObjectArg; orderbook: ObjectArg
}

export function removeStartTimeWithWitness(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: RemoveStartTimeWithWitnessArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::remove_start_time_with_witness`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.orderbook)
        ],
    })
}

export interface SetProtectionArgs {
    witness: ObjectArg; ob: ObjectArg; protectedActions: ObjectArg
}

export function setProtection(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SetProtectionArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::set_protection`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.ob), obj(txb, args.protectedActions)
        ],
    })
}

export interface SetProtection_Args {
    orderbook: ObjectArg; protectedActions: ObjectArg
}

export function setProtection_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SetProtection_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::set_protection_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.orderbook), obj(txb, args.protectedActions)
        ],
    })
}

export interface SetProtectionAsAdministratorArgs {
    orderbook: ObjectArg; buyNft: boolean | TransactionArgument; createAsk: boolean | TransactionArgument; createBid: boolean | TransactionArgument
}

export function setProtectionAsAdministrator(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SetProtectionAsAdministratorArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::set_protection_as_administrator`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.orderbook), pure(txb, args.buyNft, `bool`), pure(txb, args.createAsk, `bool`), pure(txb, args.createBid, `bool`)
        ],
    })
}

export interface SetProtectionAsPublisherArgs {
    publisher: ObjectArg; orderbook: ObjectArg; buyNft: boolean | TransactionArgument; createAsk: boolean | TransactionArgument; createBid: boolean | TransactionArgument
}

export function setProtectionAsPublisher(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SetProtectionAsPublisherArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::set_protection_as_publisher`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.publisher), obj(txb, args.orderbook), pure(txb, args.buyNft, `bool`), pure(txb, args.createAsk, `bool`), pure(txb, args.createBid, `bool`)
        ],
    })
}

export interface SetStartTimeArgs {
    publisher: ObjectArg; orderbook: ObjectArg; startTime: bigint | TransactionArgument
}

export function setStartTime(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SetStartTimeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::set_start_time`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.publisher), obj(txb, args.orderbook), pure(txb, args.startTime, `u64`)
        ],
    })
}

export function startTime(
    txb: TransactionBlock,
    typeArgs: [string, string],
    book: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::start_time`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, book)
        ],
    })
}

export interface SetStartTime_Args {
    orderbook: ObjectArg; startTime: bigint | TransactionArgument
}

export function setStartTime_(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SetStartTime_Args
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::set_start_time_`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.orderbook), pure(txb, args.startTime, `u64`)
        ],
    })
}

export interface SetStartTimeAsAdministratorArgs {
    orderbook: ObjectArg; startTime: bigint | TransactionArgument
}

export function setStartTimeAsAdministrator(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SetStartTimeAsAdministratorArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::set_start_time_as_administrator`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.orderbook), pure(txb, args.startTime, `u64`)
        ],
    })
}

export interface SetStartTimeWithWitnessArgs {
    witness: ObjectArg; orderbook: ObjectArg; startTime: bigint | TransactionArgument
}

export function setStartTimeWithWitness(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SetStartTimeWithWitnessArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::set_start_time_with_witness`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.witness), obj(txb, args.orderbook), pure(txb, args.startTime, `u64`)
        ],
    })
}

export interface TradeArgs {
    book: ObjectArg; tradeId: string | TransactionArgument
}

export function trade(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: TradeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::trade`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.book), pure(txb, args.tradeId, `0x2::object::ID`)
        ],
    })
}

export function tradePrice(
    txb: TransactionBlock,
    trade: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::orderbook::trade_price`,
        arguments: [
            obj(txb, trade)
        ],
    })
}
