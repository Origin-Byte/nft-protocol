import {PUBLISHED_AT} from "..";
import {pure} from "../../_framework/util";
import {TransactionArgument, TransactionBlock} from "@mysten/sui.js/transactions";

export interface AddDaysArgs {
    timestamp: bigint | TransactionArgument; days: bigint | TransactionArgument
}

export function addDays(
    txb: TransactionBlock,
    args: AddDaysArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::add_days`,
        arguments: [
            pure(txb, args.timestamp, `u64`), pure(txb, args.days, `u64`)
        ],
    })
}

export interface AddHoursArgs {
    timestamp: bigint | TransactionArgument; hours: bigint | TransactionArgument
}

export function addHours(
    txb: TransactionBlock,
    args: AddHoursArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::add_hours`,
        arguments: [
            pure(txb, args.timestamp, `u64`), pure(txb, args.hours, `u64`)
        ],
    })
}

export interface AddMinutesArgs {
    timestamp: bigint | TransactionArgument; minutes: bigint | TransactionArgument
}

export function addMinutes(
    txb: TransactionBlock,
    args: AddMinutesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::add_minutes`,
        arguments: [
            pure(txb, args.timestamp, `u64`), pure(txb, args.minutes, `u64`)
        ],
    })
}

export interface AddMonthsArgs {
    timestamp: bigint | TransactionArgument; months: bigint | TransactionArgument
}

export function addMonths(
    txb: TransactionBlock,
    args: AddMonthsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::add_months`,
        arguments: [
            pure(txb, args.timestamp, `u64`), pure(txb, args.months, `u64`)
        ],
    })
}

export interface AddSecondsArgs {
    timestamp: bigint | TransactionArgument; seconds: bigint | TransactionArgument
}

export function addSeconds(
    txb: TransactionBlock,
    args: AddSecondsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::add_seconds`,
        arguments: [
            pure(txb, args.timestamp, `u64`), pure(txb, args.seconds, `u64`)
        ],
    })
}

export interface AddYearsArgs {
    timestamp: bigint | TransactionArgument; years: bigint | TransactionArgument
}

export function addYears(
    txb: TransactionBlock,
    args: AddYearsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::add_years`,
        arguments: [
            pure(txb, args.timestamp, `u64`), pure(txb, args.years, `u64`)
        ],
    })
}

export interface DaysFromDateArgs {
    year: bigint | TransactionArgument; month: bigint | TransactionArgument; day: bigint | TransactionArgument
}

export function daysFromDate(
    txb: TransactionBlock,
    args: DaysFromDateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::days_from_date`,
        arguments: [
            pure(txb, args.year, `u64`), pure(txb, args.month, `u64`), pure(txb, args.day, `u64`)
        ],
    })
}

export function daysToDate(
    txb: TransactionBlock,
    days: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::days_to_date`,
        arguments: [
            pure(txb, days, `u64`)
        ],
    })
}

export interface DiffDaysArgs {
    fromTimestamp: bigint | TransactionArgument; toTimestamp: bigint | TransactionArgument
}

export function diffDays(
    txb: TransactionBlock,
    args: DiffDaysArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::diff_days`,
        arguments: [
            pure(txb, args.fromTimestamp, `u64`), pure(txb, args.toTimestamp, `u64`)
        ],
    })
}

export interface DiffHoursArgs {
    fromTimestamp: bigint | TransactionArgument; toTimestamp: bigint | TransactionArgument
}

export function diffHours(
    txb: TransactionBlock,
    args: DiffHoursArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::diff_hours`,
        arguments: [
            pure(txb, args.fromTimestamp, `u64`), pure(txb, args.toTimestamp, `u64`)
        ],
    })
}

export interface DiffMinutesArgs {
    fromTimestamp: bigint | TransactionArgument; toTimestamp: bigint | TransactionArgument
}

export function diffMinutes(
    txb: TransactionBlock,
    args: DiffMinutesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::diff_minutes`,
        arguments: [
            pure(txb, args.fromTimestamp, `u64`), pure(txb, args.toTimestamp, `u64`)
        ],
    })
}

export interface DiffMonthsArgs {
    fromTimestamp: bigint | TransactionArgument; toTimestamp: bigint | TransactionArgument
}

export function diffMonths(
    txb: TransactionBlock,
    args: DiffMonthsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::diff_months`,
        arguments: [
            pure(txb, args.fromTimestamp, `u64`), pure(txb, args.toTimestamp, `u64`)
        ],
    })
}

export interface DiffSecondsArgs {
    fromTimestamp: bigint | TransactionArgument; toTimestamp: bigint | TransactionArgument
}

export function diffSeconds(
    txb: TransactionBlock,
    args: DiffSecondsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::diff_seconds`,
        arguments: [
            pure(txb, args.fromTimestamp, `u64`), pure(txb, args.toTimestamp, `u64`)
        ],
    })
}

export interface DiffYearsArgs {
    fromTimestamp: bigint | TransactionArgument; toTimestamp: bigint | TransactionArgument
}

export function diffYears(
    txb: TransactionBlock,
    args: DiffYearsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::diff_years`,
        arguments: [
            pure(txb, args.fromTimestamp, `u64`), pure(txb, args.toTimestamp, `u64`)
        ],
    })
}

export function getDay(
    txb: TransactionBlock,
    timestamp: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::get_day`,
        arguments: [
            pure(txb, timestamp, `u64`)
        ],
    })
}

export function getDayOfWeek(
    txb: TransactionBlock,
    timestamp: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::get_day_of_week`,
        arguments: [
            pure(txb, timestamp, `u64`)
        ],
    })
}

export function getDaysInTimestampMonth(
    txb: TransactionBlock,
    timestamp: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::get_days_in_timestamp_month`,
        arguments: [
            pure(txb, timestamp, `u64`)
        ],
    })
}

export interface GetDaysInYearMonthArgs {
    year: bigint | TransactionArgument; month: bigint | TransactionArgument
}

export function getDaysInYearMonth(
    txb: TransactionBlock,
    args: GetDaysInYearMonthArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::get_days_in_year_month`,
        arguments: [
            pure(txb, args.year, `u64`), pure(txb, args.month, `u64`)
        ],
    })
}

export function getHour(
    txb: TransactionBlock,
    timestamp: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::get_hour`,
        arguments: [
            pure(txb, timestamp, `u64`)
        ],
    })
}

export function getMinute(
    txb: TransactionBlock,
    timestamp: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::get_minute`,
        arguments: [
            pure(txb, timestamp, `u64`)
        ],
    })
}

export function getMonth(
    txb: TransactionBlock,
    timestamp: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::get_month`,
        arguments: [
            pure(txb, timestamp, `u64`)
        ],
    })
}

export function getSecond(
    txb: TransactionBlock,
    timestamp: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::get_second`,
        arguments: [
            pure(txb, timestamp, `u64`)
        ],
    })
}

export function getYear(
    txb: TransactionBlock,
    timestamp: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::get_year`,
        arguments: [
            pure(txb, timestamp, `u64`)
        ],
    })
}

export function isTimestampLeapYear(
    txb: TransactionBlock,
    timestamp: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::is_timestamp_leap_year`,
        arguments: [
            pure(txb, timestamp, `u64`)
        ],
    })
}

export interface IsValidDateArgs {
    year: bigint | TransactionArgument; month: bigint | TransactionArgument; day: bigint | TransactionArgument
}

export function isValidDate(
    txb: TransactionBlock,
    args: IsValidDateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::is_valid_date`,
        arguments: [
            pure(txb, args.year, `u64`), pure(txb, args.month, `u64`), pure(txb, args.day, `u64`)
        ],
    })
}

export interface IsValidDateTimeArgs {
    year: bigint | TransactionArgument; month: bigint | TransactionArgument; day: bigint | TransactionArgument; hour: bigint | TransactionArgument; minute: bigint | TransactionArgument; second: bigint | TransactionArgument
}

export function isValidDateTime(
    txb: TransactionBlock,
    args: IsValidDateTimeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::is_valid_date_time`,
        arguments: [
            pure(txb, args.year, `u64`), pure(txb, args.month, `u64`), pure(txb, args.day, `u64`), pure(txb, args.hour, `u64`), pure(txb, args.minute, `u64`), pure(txb, args.second, `u64`)
        ],
    })
}

export function isWeekday(
    txb: TransactionBlock,
    timestamp: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::is_weekday`,
        arguments: [
            pure(txb, timestamp, `u64`)
        ],
    })
}

export function isWeekend(
    txb: TransactionBlock,
    timestamp: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::is_weekend`,
        arguments: [
            pure(txb, timestamp, `u64`)
        ],
    })
}

export function isYearLeapYear(
    txb: TransactionBlock,
    year: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::is_year_leap_year`,
        arguments: [
            pure(txb, year, `u64`)
        ],
    })
}

export interface SubDaysArgs {
    timestamp: bigint | TransactionArgument; days: bigint | TransactionArgument
}

export function subDays(
    txb: TransactionBlock,
    args: SubDaysArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::sub_days`,
        arguments: [
            pure(txb, args.timestamp, `u64`), pure(txb, args.days, `u64`)
        ],
    })
}

export interface SubHoursArgs {
    timestamp: bigint | TransactionArgument; hours: bigint | TransactionArgument
}

export function subHours(
    txb: TransactionBlock,
    args: SubHoursArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::sub_hours`,
        arguments: [
            pure(txb, args.timestamp, `u64`), pure(txb, args.hours, `u64`)
        ],
    })
}

export interface SubMinutesArgs {
    timestamp: bigint | TransactionArgument; minutes: bigint | TransactionArgument
}

export function subMinutes(
    txb: TransactionBlock,
    args: SubMinutesArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::sub_minutes`,
        arguments: [
            pure(txb, args.timestamp, `u64`), pure(txb, args.minutes, `u64`)
        ],
    })
}

export interface SubMonthsArgs {
    timestamp: bigint | TransactionArgument; months: bigint | TransactionArgument
}

export function subMonths(
    txb: TransactionBlock,
    args: SubMonthsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::sub_months`,
        arguments: [
            pure(txb, args.timestamp, `u64`), pure(txb, args.months, `u64`)
        ],
    })
}

export interface SubSecondsArgs {
    timestamp: bigint | TransactionArgument; seconds: bigint | TransactionArgument
}

export function subSeconds(
    txb: TransactionBlock,
    args: SubSecondsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::sub_seconds`,
        arguments: [
            pure(txb, args.timestamp, `u64`), pure(txb, args.seconds, `u64`)
        ],
    })
}

export interface SubYearsArgs {
    timestamp: bigint | TransactionArgument; years: bigint | TransactionArgument
}

export function subYears(
    txb: TransactionBlock,
    args: SubYearsArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::sub_years`,
        arguments: [
            pure(txb, args.timestamp, `u64`), pure(txb, args.years, `u64`)
        ],
    })
}

export interface TimestampFromDateArgs {
    year: bigint | TransactionArgument; month: bigint | TransactionArgument; day: bigint | TransactionArgument
}

export function timestampFromDate(
    txb: TransactionBlock,
    args: TimestampFromDateArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::timestamp_from_date`,
        arguments: [
            pure(txb, args.year, `u64`), pure(txb, args.month, `u64`), pure(txb, args.day, `u64`)
        ],
    })
}

export interface TimestampFromDateTimeArgs {
    year: bigint | TransactionArgument; month: bigint | TransactionArgument; day: bigint | TransactionArgument; hour: bigint | TransactionArgument; minute: bigint | TransactionArgument; second: bigint | TransactionArgument
}

export function timestampFromDateTime(
    txb: TransactionBlock,
    args: TimestampFromDateTimeArgs
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::timestamp_from_date_time`,
        arguments: [
            pure(txb, args.year, `u64`), pure(txb, args.month, `u64`), pure(txb, args.day, `u64`), pure(txb, args.hour, `u64`), pure(txb, args.minute, `u64`), pure(txb, args.second, `u64`)
        ],
    })
}

export function timestampToDate(
    txb: TransactionBlock,
    timestamp: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::timestamp_to_date`,
        arguments: [
            pure(txb, timestamp, `u64`)
        ],
    })
}

export function timestampToDateTime(
    txb: TransactionBlock,
    timestamp: bigint | TransactionArgument
) {
    return txb.moveCall({
        target: `${PUBLISHED_AT}::date::timestamp_to_date_time`,
        arguments: [
            pure(txb, timestamp, `u64`)
        ],
    })
}
