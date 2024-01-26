import {PUBLISHED_AT} from "..";
import {ObjectArg, obj, pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface DepositArgs {
    wallet: ObjectArg; coinIn: ObjectArg
}

export function deposit(
    txb: TransactionBlock,
    typeArg: string,
    args: DepositArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::linear_vesting::deposit`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.wallet), obj(txb, args.coinIn)
        ],
    })
}

export interface ClawbackArgs {
    wallet: ObjectArg; clawbackCap: ObjectArg
}

export function clawback(
    txb: TransactionBlock,
    typeArg: string,
    args: ClawbackArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::linear_vesting::clawback`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.wallet), obj(txb, args.clawbackCap)
        ],
    })
}

export interface ClawbackToArgs {
    wallet: ObjectArg; clawbackCap: ObjectArg; recipient: string | TransactionArgument
}

export function clawbackTo(
    txb: TransactionBlock,
    typeArg: string,
    args: ClawbackToArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::linear_vesting::clawback_to`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, args.wallet), obj(txb, args.clawbackCap), pure(txb, args.recipient, `address`)
        ],
    })
}

export function destroyClawbackCapability(
    txb: TransactionBlock,
    clawbackCap: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::linear_vesting::destroy_clawback_capability`,
        arguments: [
            obj(txb, clawbackCap)
        ],
    })
}

export interface InitWalletArgs {
    beneficiary: string | TransactionArgument; start: bigint | TransactionArgument; duration: bigint | TransactionArgument; clawbacker: (string | TransactionArgument | TransactionArgument | null)
}

export function initWallet(
    txb: TransactionBlock,
    typeArg: string,
    args: InitWalletArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::linear_vesting::init_wallet`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.beneficiary, `address`), pure(txb, args.start, `u64`), pure(txb, args.duration, `u64`), pure(txb, args.clawbacker, `0x1::option::Option<address>`)
        ],
    })
}

export interface InitWalletReturnClawbackArgs {
    beneficiary: string | TransactionArgument; start: bigint | TransactionArgument; duration: bigint | TransactionArgument
}

export function initWalletReturnClawback(
    txb: TransactionBlock,
    typeArg: string,
    args: InitWalletReturnClawbackArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::linear_vesting::init_wallet_return_clawback`,
        typeArguments: [typeArg],
        arguments: [
            pure(txb, args.beneficiary, `address`), pure(txb, args.start, `u64`), pure(txb, args.duration, `u64`)
        ],
    })
}

export function release(
    txb: TransactionBlock,
    typeArg: string,
    wallet: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::linear_vesting::release`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, wallet)
        ],
    })
}

export interface VestedAmountArgs {
    start: bigint | TransactionArgument; duration: bigint | TransactionArgument; balance: bigint | TransactionArgument; alreadyReleased: bigint | TransactionArgument; timestamp: bigint | TransactionArgument
}

export function vestedAmount(
    txb: TransactionBlock,
    args: VestedAmountArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::linear_vesting::vested_amount`,
        arguments: [
            pure(txb, args.start, `u64`), pure(txb, args.duration, `u64`), pure(txb, args.balance, `u64`), pure(txb, args.alreadyReleased, `u64`), pure(txb, args.timestamp, `u64`)
        ],
    })
}

export interface VestingScheduleArgs {
    start: bigint | TransactionArgument; duration: bigint | TransactionArgument; totalAllocation: bigint | TransactionArgument; timestamp: bigint | TransactionArgument
}

export function vestingSchedule(
    txb: TransactionBlock,
    args: VestingScheduleArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::linear_vesting::vesting_schedule`,
        arguments: [
            pure(txb, args.start, `u64`), pure(txb, args.duration, `u64`), pure(txb, args.totalAllocation, `u64`), pure(txb, args.timestamp, `u64`)
        ],
    })
}

export function vestingStatus(
    txb: TransactionBlock,
    typeArg: string,
    wallet: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::linear_vesting::vesting_status`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, wallet)
        ],
    })
}

export function walletInfo(
    txb: TransactionBlock,
    typeArg: string,
    wallet: ObjectArg
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::linear_vesting::wallet_info`,
        typeArguments: [typeArg],
        arguments: [
            obj(txb, wallet)
        ],
    })
}
