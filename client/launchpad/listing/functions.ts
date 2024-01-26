import {PUBLISHED_AT} from "..";
import {GenericArg, ObjectArg, generic, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface NewArgs {
    listingAdmin: string | TransactionArgument; receiver: string | TransactionArgument
}

export function new_(
    txb: TransactionBlock,
    args: NewArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::new`,
        arguments: [
            pure(txb, args.listingAdmin, `address`), pure(txb, args.receiver, `address`)
        ],
    })
}

export interface SupplyArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument
}

export function supply(
    txb: TransactionBlock,
    typeArg: string,
    args: SupplyArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::supply`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`)
        ],
    })
}

export interface PayArgs {
    listing: ObjectArg; balance: ObjectArg; quantity: bigint | TransactionArgument
}

export function pay(
    txb: TransactionBlock,
    typeArg: string,
    args: PayArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::pay`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), obj(txb, args.balance), pure(txb, args.quantity, `u64`)
        ],
    })
}

export function receiver(
    txb: TransactionBlock,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::receiver`,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export interface AddMemberArgs {
    listing: ObjectArg; member: string | TransactionArgument
}

export function addMember(
    txb: TransactionBlock,
    args: AddMemberArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::add_member`,
        arguments: [
            obj(txb, args.listing), pure(txb, args.member, `address`)
        ],
    })
}

export function assertVersion(
    txb: TransactionBlock,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::assert_version`,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export function assertVersionAndUpgrade(
    txb: TransactionBlock,
    self: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::assert_version_and_upgrade`,
        arguments: [
            obj(txb, self)
        ],
    })
}

export interface RemoveMemberArgs {
    listing: ObjectArg; member: string | TransactionArgument
}

export function removeMember(
    txb: TransactionBlock,
    args: RemoveMemberArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::remove_member`,
        arguments: [
            obj(txb, args.listing), pure(txb, args.member, `address`)
        ],
    })
}

export function admin(
    txb: TransactionBlock,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::admin`,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export function migrate(
    txb: TransactionBlock,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::migrate`,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export interface BuyNftArgs {
    listing: ObjectArg; key: GenericArg; inventoryId: string | TransactionArgument; venueId: string | TransactionArgument; buyer: string | TransactionArgument; funds: ObjectArg
}

export function buyNft(
    txb: TransactionBlock,
    typeArgs: [string, string, string, string],
    args: BuyNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::buy_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), generic(txb, `${typeArgs[3]}`, args.key), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.venueId, `0x2::object::ID`), pure(txb, args.buyer, `address`), obj(txb, args.funds)
        ],
    })
}

export interface InitVenueArgs {
    listing: ObjectArg; key: GenericArg; market: GenericArg; isWhitelisted: boolean | TransactionArgument
}

export function initVenue(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: InitVenueArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::init_venue`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), generic(txb, `${typeArgs[1]}`, args.key), generic(txb, `${typeArgs[0]}`, args.market), pure(txb, args.isWhitelisted, `bool`)
        ],
    })
}

export function initWarehouse(
    txb: TransactionBlock,
    typeArg: string,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::init_warehouse`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, listing)
        ],
    })
}

export interface ApplyRebateArgs {
    listing: ObjectArg; wallet: ObjectArg
}

export function applyRebate(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: ApplyRebateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::apply_rebate`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), obj(txb, args.wallet)
        ],
    })
}

export function borrowRebate(
    txb: TransactionBlock,
    typeArgs: [string, string],
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::borrow_rebate`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export function borrowRebateMut(
    txb: TransactionBlock,
    typeArgs: [string, string],
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::borrow_rebate_mut`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export interface FundRebateArgs {
    listing: ObjectArg; wallet: ObjectArg; fundAmount: bigint | TransactionArgument
}

export function fundRebate(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: FundRebateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::fund_rebate`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), obj(txb, args.wallet), pure(txb, args.fundAmount, `u64`)
        ],
    })
}

export function hasRebate(
    txb: TransactionBlock,
    typeArgs: [string, string],
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::has_rebate`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export interface SendRebateArgs {
    listing: ObjectArg; receiver: string | TransactionArgument
}

export function sendRebate(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SendRebateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::send_rebate`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.receiver, `address`)
        ],
    })
}

export interface SetRebateArgs {
    listing: ObjectArg; rebateAmount: bigint | TransactionArgument
}

export function setRebate(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SetRebateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::set_rebate`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.rebateAmount, `u64`)
        ],
    })
}

export interface WithdrawRebateFundsArgs {
    listing: ObjectArg; coin: ObjectArg; amount: bigint | TransactionArgument
}

export function withdrawRebateFunds(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: WithdrawRebateFundsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::withdraw_rebate_funds`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), obj(txb, args.coin), pure(txb, args.amount, `u64`)
        ],
    })
}

export function assertListingAdminOrMember(
    txb: TransactionBlock,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::assert_listing_admin_or_member`,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export function isAdminOrMember(
    txb: TransactionBlock,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::is_admin_or_member`,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export interface AcceptListingRequestArgs {
    marketplace: ObjectArg; listing: ObjectArg
}

export function acceptListingRequest(
    txb: TransactionBlock,
    args: AcceptListingRequestArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::accept_listing_request`,
        arguments: [
            obj(txb, args.marketplace), obj(txb, args.listing)
        ],
    })
}

export interface AddFeeArgs {
    marketplace: ObjectArg; listing: ObjectArg; fee: GenericArg
}

export function addFee(
    txb: TransactionBlock,
    typeArg: string,
    args: AddFeeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::add_fee`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.marketplace), obj(txb, args.listing), generic(txb, `${typeArg}`, args.fee)
        ],
    })
}

export interface AddInventoryArgs {
    listing: ObjectArg; inventory: ObjectArg
}

export function addInventory(
    txb: TransactionBlock,
    typeArg: string,
    args: AddInventoryArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::add_inventory`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), obj(txb, args.inventory)
        ],
    })
}

export interface AddNftArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument; nft: GenericArg
}

export function addNft(
    txb: TransactionBlock,
    typeArg: string,
    args: AddNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::add_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`), generic(txb, `${typeArg}`, args.nft)
        ],
    })
}

export interface AddVenueArgs {
    listing: ObjectArg; venue: ObjectArg
}

export function addVenue(
    txb: TransactionBlock,
    args: AddVenueArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::add_venue`,
        arguments: [
            obj(txb, args.listing), obj(txb, args.venue)
        ],
    })
}

export interface AddWarehouseArgs {
    listing: ObjectArg; warehouse: ObjectArg
}

export function addWarehouse(
    txb: TransactionBlock,
    typeArg: string,
    args: AddWarehouseArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::add_warehouse`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), obj(txb, args.warehouse)
        ],
    })
}

export interface AddWhitelistInternalArgs {
    listing: ObjectArg; venueId: string | TransactionArgument; whitelist: GenericArg
}

export function addWhitelistInternal(
    txb: TransactionBlock,
    typeArg: string,
    args: AddWhitelistInternalArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::add_whitelist_internal`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`), generic(txb, `${typeArg}`, args.whitelist)
        ],
    })
}

export interface AdminRedeemNftArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument
}

export function adminRedeemNft(
    txb: TransactionBlock,
    typeArg: string,
    args: AdminRedeemNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::admin_redeem_nft`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`)
        ],
    })
}

export interface AdminRedeemNftAndTransferArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument; receiver: string | TransactionArgument
}

export function adminRedeemNftAndTransfer(
    txb: TransactionBlock,
    typeArg: string,
    args: AdminRedeemNftAndTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::admin_redeem_nft_and_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.receiver, `address`)
        ],
    })
}

export interface AdminRedeemNftToKioskArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument; receiver: ObjectArg
}

export function adminRedeemNftToKiosk(
    txb: TransactionBlock,
    typeArg: string,
    args: AdminRedeemNftToKioskArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::admin_redeem_nft_to_kiosk`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`), obj(txb, args.receiver)
        ],
    })
}

export interface AdminRedeemNftToNewKioskArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument; receiver: string | TransactionArgument
}

export function adminRedeemNftToNewKiosk(
    txb: TransactionBlock,
    typeArg: string,
    args: AdminRedeemNftToNewKioskArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::admin_redeem_nft_to_new_kiosk`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.receiver, `address`)
        ],
    })
}

export interface AdminRedeemNftWithIdArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument; nftId: string | TransactionArgument
}

export function adminRedeemNftWithId(
    txb: TransactionBlock,
    typeArg: string,
    args: AdminRedeemNftWithIdArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::admin_redeem_nft_with_id`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.nftId, `0x2::object::ID`)
        ],
    })
}

export interface AdminRedeemNftWithIdAndTransferArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument; nftId: string | TransactionArgument; receiver: string | TransactionArgument
}

export function adminRedeemNftWithIdAndTransfer(
    txb: TransactionBlock,
    typeArg: string,
    args: AdminRedeemNftWithIdAndTransferArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::admin_redeem_nft_with_id_and_transfer`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.receiver, `address`)
        ],
    })
}

export interface AdminRedeemNftWithIdToKioskArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument; nftId: string | TransactionArgument; receiver: ObjectArg
}

export function adminRedeemNftWithIdToKiosk(
    txb: TransactionBlock,
    typeArg: string,
    args: AdminRedeemNftWithIdToKioskArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::admin_redeem_nft_with_id_to_kiosk`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.nftId, `0x2::object::ID`), obj(txb, args.receiver)
        ],
    })
}

export interface AdminRedeemNftWithIdToNewKioskArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument; nftId: string | TransactionArgument; receiver: string | TransactionArgument
}

export function adminRedeemNftWithIdToNewKiosk(
    txb: TransactionBlock,
    typeArg: string,
    args: AdminRedeemNftWithIdToNewKioskArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::admin_redeem_nft_with_id_to_new_kiosk`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.nftId, `0x2::object::ID`), pure(txb, args.receiver, `address`)
        ],
    })
}

export interface AssertCorrectAdminArgs {
    marketplace: ObjectArg; listing: ObjectArg
}

export function assertCorrectAdmin(
    txb: TransactionBlock,
    args: AssertCorrectAdminArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::assert_correct_admin`,
        arguments: [
            obj(txb, args.marketplace), obj(txb, args.listing)
        ],
    })
}

export interface AssertCorrectAdminOrMemberArgs {
    marketplace: ObjectArg; listing: ObjectArg
}

export function assertCorrectAdminOrMember(
    txb: TransactionBlock,
    args: AssertCorrectAdminOrMemberArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::assert_correct_admin_or_member`,
        arguments: [
            obj(txb, args.marketplace), obj(txb, args.listing)
        ],
    })
}

export function assertDefaultFee(
    txb: TransactionBlock,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::assert_default_fee`,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export interface AssertInventoryArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument
}

export function assertInventory(
    txb: TransactionBlock,
    typeArg: string,
    args: AssertInventoryArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::assert_inventory`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`)
        ],
    })
}

export function assertListingAdmin(
    txb: TransactionBlock,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::assert_listing_admin`,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export interface AssertListingMarketplaceMatchArgs {
    marketplace: ObjectArg; listing: ObjectArg
}

export function assertListingMarketplaceMatch(
    txb: TransactionBlock,
    args: AssertListingMarketplaceMatchArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::assert_listing_marketplace_match`,
        arguments: [
            obj(txb, args.marketplace), obj(txb, args.listing)
        ],
    })
}

export interface AssertVenueArgs {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function assertVenue(
    txb: TransactionBlock,
    args: AssertVenueArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::assert_venue`,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface BorrowInventoryArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument
}

export function borrowInventory(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowInventoryArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::borrow_inventory`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`)
        ],
    })
}

export interface BorrowInventoryMutArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument
}

export function borrowInventoryMut(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowInventoryMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::borrow_inventory_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`)
        ],
    })
}

export function borrowMembers(
    txb: TransactionBlock,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::borrow_members`,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export function borrowProceeds(
    txb: TransactionBlock,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::borrow_proceeds`,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export function borrowProceedsMut(
    txb: TransactionBlock,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::borrow_proceeds_mut`,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export interface BorrowVenueArgs {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function borrowVenue(
    txb: TransactionBlock,
    args: BorrowVenueArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::borrow_venue`,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface BorrowVenueMutArgs {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function borrowVenueMut(
    txb: TransactionBlock,
    args: BorrowVenueMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::borrow_venue_mut`,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface BorrowWhitelistMutArgs {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function borrowWhitelistMut(
    txb: TransactionBlock,
    typeArg: string,
    args: BorrowWhitelistMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::borrow_whitelist_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface BuyPseudorandomNftArgs {
    listing: ObjectArg; key: GenericArg; inventoryId: string | TransactionArgument; venueId: string | TransactionArgument; buyer: string | TransactionArgument; funds: ObjectArg
}

export function buyPseudorandomNft(
    txb: TransactionBlock,
    typeArgs: [string, string, string, string],
    args: BuyPseudorandomNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::buy_pseudorandom_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), generic(txb, `${typeArgs[3]}`, args.key), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.venueId, `0x2::object::ID`), pure(txb, args.buyer, `address`), obj(txb, args.funds)
        ],
    })
}

export interface BuyRandomNftArgs {
    listing: ObjectArg; key: GenericArg; commitment: ObjectArg; userCommitment: Array<number | TransactionArgument> | TransactionArgument; inventoryId: string | TransactionArgument; venueId: string | TransactionArgument; buyer: string | TransactionArgument; funds: ObjectArg
}

export function buyRandomNft(
    txb: TransactionBlock,
    typeArgs: [string, string, string, string],
    args: BuyRandomNftArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::buy_random_nft`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), generic(txb, `${typeArgs[3]}`, args.key), obj(txb, args.commitment), pure(txb, args.userCommitment, `vector<u8>`), pure(txb, args.inventoryId, `0x2::object::ID`), pure(txb, args.venueId, `0x2::object::ID`), pure(txb, args.buyer, `address`), obj(txb, args.funds)
        ],
    })
}

export function collectProceeds(
    txb: TransactionBlock,
    typeArg: string,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::collect_proceeds`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, listing)
        ],
    })
}

export function containsCustomFee(
    txb: TransactionBlock,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::contains_custom_fee`,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export interface ContainsInventoryArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument
}

export function containsInventory(
    txb: TransactionBlock,
    typeArg: string,
    args: ContainsInventoryArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::contains_inventory`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`)
        ],
    })
}

export interface ContainsVenueArgs {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function containsVenue(
    txb: TransactionBlock,
    args: ContainsVenueArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::contains_venue`,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface CreateVenueArgs {
    listing: ObjectArg; key: GenericArg; market: GenericArg; isWhitelisted: boolean | TransactionArgument
}

export function createVenue(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: CreateVenueArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::create_venue`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), generic(txb, `${typeArgs[1]}`, args.key), generic(txb, `${typeArgs[0]}`, args.market), pure(txb, args.isWhitelisted, `bool`)
        ],
    })
}

export function createWarehouse(
    txb: TransactionBlock,
    typeArg: string,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::create_warehouse`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, listing)
        ],
    })
}

export function customFee(
    txb: TransactionBlock,
    listing: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::custom_fee`,
        arguments: [
            obj(txb, listing)
        ],
    })
}

export interface EmitSoldEventArgs {
    nft: GenericArg; price: bigint | TransactionArgument; buyer: string | TransactionArgument
}

export function emitSoldEvent(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: EmitSoldEventArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::emit_sold_event`,
        typeArguments: typeArgs,
        arguments: [
            generic(txb, `${typeArgs[1]}`, args.nft), pure(txb, args.price, `u64`), pure(txb, args.buyer, `address`)
        ],
    })
}

export interface FundRebateWithBalanceArgs {
    listing: ObjectArg; balance: ObjectArg; fundAmount: bigint | TransactionArgument
}

export function fundRebateWithBalance(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: FundRebateWithBalanceArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::fund_rebate_with_balance`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), obj(txb, args.balance), pure(txb, args.fundAmount, `u64`)
        ],
    })
}

export interface InitListingArgs {
    listingAdmin: string | TransactionArgument; receiver: string | TransactionArgument
}

export function initListing(
    txb: TransactionBlock,
    args: InitListingArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::init_listing`,
        arguments: [
            pure(txb, args.listingAdmin, `address`), pure(txb, args.receiver, `address`)
        ],
    })
}

export interface InsertWarehouseArgs {
    listing: ObjectArg; warehouse: ObjectArg
}

export function insertWarehouse(
    txb: TransactionBlock,
    typeArg: string,
    args: InsertWarehouseArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::insert_warehouse`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), obj(txb, args.warehouse)
        ],
    })
}

export interface InventoryAdminMutArgs {
    listing: ObjectArg; inventoryId: string | TransactionArgument
}

export function inventoryAdminMut(
    txb: TransactionBlock,
    typeArg: string,
    args: InventoryAdminMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::inventory_admin_mut`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.listing), pure(txb, args.inventoryId, `0x2::object::ID`)
        ],
    })
}

export interface InventoryInternalMutArgs {
    listing: ObjectArg; key: GenericArg; venueId: string | TransactionArgument; inventoryId: string | TransactionArgument
}

export function inventoryInternalMut(
    txb: TransactionBlock,
    typeArgs: [string, string, string],
    args: InventoryInternalMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::inventory_internal_mut`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), generic(txb, `${typeArgs[2]}`, args.key), pure(txb, args.venueId, `0x2::object::ID`), pure(txb, args.inventoryId, `0x2::object::ID`)
        ],
    })
}

export interface MarketInternalMutArgs {
    listing: ObjectArg; key: GenericArg; venueId: string | TransactionArgument
}

export function marketInternalMut(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: MarketInternalMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::market_internal_mut`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), generic(txb, `${typeArgs[1]}`, args.key), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface PayAndEmitSoldEventArgs {
    listing: ObjectArg; nft: GenericArg; funds: ObjectArg; buyer: string | TransactionArgument
}

export function payAndEmitSoldEvent(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: PayAndEmitSoldEventArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::pay_and_emit_sold_event`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), generic(txb, `${typeArgs[1]}`, args.nft), obj(txb, args.funds), pure(txb, args.buyer, `address`)
        ],
    })
}

export interface RemoveVenueArgs {
    listing: ObjectArg; key: GenericArg; venueId: string | TransactionArgument
}

export function removeVenue(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: RemoveVenueArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::remove_venue`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), generic(txb, `${typeArgs[1]}`, args.key), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface RequestToJoinMarketplaceArgs {
    marketplace: ObjectArg; listing: ObjectArg
}

export function requestToJoinMarketplace(
    txb: TransactionBlock,
    args: RequestToJoinMarketplaceArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::request_to_join_marketplace`,
        arguments: [
            obj(txb, args.marketplace), obj(txb, args.listing)
        ],
    })
}

export interface SaleOffArgs {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function saleOff(
    txb: TransactionBlock,
    args: SaleOffArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::sale_off`,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface SaleOffDelegatedArgs {
    marketplace: ObjectArg; listing: ObjectArg; venueId: string | TransactionArgument
}

export function saleOffDelegated(
    txb: TransactionBlock,
    args: SaleOffDelegatedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::sale_off_delegated`,
        arguments: [
            obj(txb, args.marketplace), obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface SaleOnArgs {
    listing: ObjectArg; venueId: string | TransactionArgument
}

export function saleOn(
    txb: TransactionBlock,
    args: SaleOnArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::sale_on`,
        arguments: [
            obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface SaleOnDelegatedArgs {
    marketplace: ObjectArg; listing: ObjectArg; venueId: string | TransactionArgument
}

export function saleOnDelegated(
    txb: TransactionBlock,
    args: SaleOnDelegatedArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::sale_on_delegated`,
        arguments: [
            obj(txb, args.marketplace), obj(txb, args.listing), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface SendRebateFundsToAddressArgs {
    listing: ObjectArg; amount: bigint | TransactionArgument; receiver: string | TransactionArgument
}

export function sendRebateFundsToAddress(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SendRebateFundsToAddressArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::send_rebate_funds_to_address`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.amount, `u64`), pure(txb, args.receiver, `address`)
        ],
    })
}

export interface SendRebateFundsToSenderArgs {
    listing: ObjectArg; amount: bigint | TransactionArgument
}

export function sendRebateFundsToSender(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: SendRebateFundsToSenderArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::send_rebate_funds_to_sender`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), pure(txb, args.amount, `u64`)
        ],
    })
}

export interface VenueInternalMutArgs {
    listing: ObjectArg; key: GenericArg; venueId: string | TransactionArgument
}

export function venueInternalMut(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: VenueInternalMutArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::venue_internal_mut`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), generic(txb, `${typeArgs[1]}`, args.key), pure(txb, args.venueId, `0x2::object::ID`)
        ],
    })
}

export interface WithdrawRebateFundsToBalanceArgs {
    listing: ObjectArg; balance: ObjectArg; amount: bigint | TransactionArgument
}

export function withdrawRebateFundsToBalance(
    txb: TransactionBlock,
    typeArgs: [string, string],
    args: WithdrawRebateFundsToBalanceArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::listing::withdraw_rebate_funds_to_balance`,
        typeArguments: typeArgs,
        arguments: [
            obj(txb, args.listing), obj(txb, args.balance), pure(txb, args.amount, `u64`)
        ],
    })
}
