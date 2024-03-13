import {Option} from "../../_dependencies/source/0x1/option/structs";
import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {Balances} from "../../originmate/balances/structs";
import {BalanceAccessCap} from "../../request/transfer-request/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== BpsRoyaltyStrategy =============================== */

export function isBpsRoyaltyStrategy(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::royalty_strategy_bps::BpsRoyaltyStrategy<");
}

export interface BpsRoyaltyStrategyFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; version: ToField<"u64">; royaltyFeeBps: ToField<"u16">; accessCap: ToField<Option<BalanceAccessCap<T>>>; aggregator: ToField<Balances>; isEnabled: ToField<"bool">
}

export type BpsRoyaltyStrategyReified<T extends PhantomTypeArgument> = Reified<
    BpsRoyaltyStrategy<T>,
    BpsRoyaltyStrategyFields<T>
>;

export class BpsRoyaltyStrategy<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::royalty_strategy_bps::BpsRoyaltyStrategy";
    static readonly $numTypeParams = 1;

    readonly $typeName = BpsRoyaltyStrategy.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::royalty_strategy_bps::BpsRoyaltyStrategy<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly id:
        ToField<UID>
    ; readonly version:
        ToField<"u64">
    ; readonly royaltyFeeBps:
        ToField<"u16">
    ; readonly accessCap:
        ToField<Option<BalanceAccessCap<T>>>
    ; readonly aggregator:
        ToField<Balances>
    ; readonly isEnabled:
        ToField<"bool">

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: BpsRoyaltyStrategyFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            BpsRoyaltyStrategy.$typeName,
            ...typeArgs
        ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::royalty_strategy_bps::BpsRoyaltyStrategy<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.version = fields.version;; this.royaltyFeeBps = fields.royaltyFeeBps;; this.accessCap = fields.accessCap;; this.aggregator = fields.aggregator;; this.isEnabled = fields.isEnabled;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): BpsRoyaltyStrategyReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: BpsRoyaltyStrategy.$typeName,
            fullTypeName: composeSuiType(
                BpsRoyaltyStrategy.$typeName,
                ...[extractType(T)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::royalty_strategy_bps::BpsRoyaltyStrategy<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                BpsRoyaltyStrategy.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                BpsRoyaltyStrategy.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                BpsRoyaltyStrategy.fromBcs(
                    T,
                    data,
                ),
            bcs: BpsRoyaltyStrategy.bcs,
            fromJSONField: (field: any) =>
                BpsRoyaltyStrategy.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                BpsRoyaltyStrategy.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                BpsRoyaltyStrategy.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => BpsRoyaltyStrategy.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: BpsRoyaltyStrategyFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new BpsRoyaltyStrategy(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return BpsRoyaltyStrategy.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<BpsRoyaltyStrategy<ToPhantomTypeArgument<T>>>> {
        return phantom(BpsRoyaltyStrategy.reified(
            T
        ));
    }

    static get p() {
        return BpsRoyaltyStrategy.phantom
    }

    static get bcs() {
        return bcs.struct("BpsRoyaltyStrategy", {
            id:
                UID.bcs
            , version:
                bcs.u64()
            , royalty_fee_bps:
                bcs.u16()
            , access_cap:
                Option.bcs(BalanceAccessCap.bcs)
            , aggregator:
                Balances.bcs
            , is_enabled:
                bcs.bool()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): BpsRoyaltyStrategy<ToPhantomTypeArgument<T>> {
        return BpsRoyaltyStrategy.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), version: decodeFromFields("u64", fields.version), royaltyFeeBps: decodeFromFields("u16", fields.royalty_fee_bps), accessCap: decodeFromFields(Option.reified(BalanceAccessCap.reified(typeArg)), fields.access_cap), aggregator: decodeFromFields(Balances.reified(), fields.aggregator), isEnabled: decodeFromFields("bool", fields.is_enabled)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): BpsRoyaltyStrategy<ToPhantomTypeArgument<T>> {
        if (!isBpsRoyaltyStrategy(item.type)) {
            throw new Error("not a BpsRoyaltyStrategy type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return BpsRoyaltyStrategy.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), version: decodeFromFieldsWithTypes("u64", item.fields.version), royaltyFeeBps: decodeFromFieldsWithTypes("u16", item.fields.royalty_fee_bps), accessCap: decodeFromFieldsWithTypes(Option.reified(BalanceAccessCap.reified(typeArg)), item.fields.access_cap), aggregator: decodeFromFieldsWithTypes(Balances.reified(), item.fields.aggregator), isEnabled: decodeFromFieldsWithTypes("bool", item.fields.is_enabled)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): BpsRoyaltyStrategy<ToPhantomTypeArgument<T>> {

        return BpsRoyaltyStrategy.fromFields(
            typeArg,
            BpsRoyaltyStrategy.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,version: this.version.toString(),royaltyFeeBps: this.royaltyFeeBps,accessCap: fieldToJSON<Option<BalanceAccessCap<T>>>(`0x1::option::Option<0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::BalanceAccessCap<${this.$typeArgs[0]}>>`, this.accessCap),aggregator: this.aggregator.toJSONField(),isEnabled: this.isEnabled,

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): BpsRoyaltyStrategy<ToPhantomTypeArgument<T>> {
        return BpsRoyaltyStrategy.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), version: decodeFromJSONField("u64", field.version), royaltyFeeBps: decodeFromJSONField("u16", field.royaltyFeeBps), accessCap: decodeFromJSONField(Option.reified(BalanceAccessCap.reified(typeArg)), field.accessCap), aggregator: decodeFromJSONField(Balances.reified(), field.aggregator), isEnabled: decodeFromJSONField("bool", field.isEnabled)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): BpsRoyaltyStrategy<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== BpsRoyaltyStrategy.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(BpsRoyaltyStrategy.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return BpsRoyaltyStrategy.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): BpsRoyaltyStrategy<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBpsRoyaltyStrategy(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a BpsRoyaltyStrategy object`);
        }
        return BpsRoyaltyStrategy.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<BpsRoyaltyStrategy<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching BpsRoyaltyStrategy object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBpsRoyaltyStrategy(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a BpsRoyaltyStrategy object`);
        }

        return BpsRoyaltyStrategy.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== BpsRoyaltyStrategyRule =============================== */

export function isBpsRoyaltyStrategyRule(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::royalty_strategy_bps::BpsRoyaltyStrategyRule";
}

export interface BpsRoyaltyStrategyRuleFields {
    dummyField: ToField<"bool">
}

export type BpsRoyaltyStrategyRuleReified = Reified<
    BpsRoyaltyStrategyRule,
    BpsRoyaltyStrategyRuleFields
>;

export class BpsRoyaltyStrategyRule implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::royalty_strategy_bps::BpsRoyaltyStrategyRule";
    static readonly $numTypeParams = 0;

    readonly $typeName = BpsRoyaltyStrategyRule.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::royalty_strategy_bps::BpsRoyaltyStrategyRule";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: BpsRoyaltyStrategyRuleFields,
    ) {
        this.$fullTypeName = composeSuiType(
            BpsRoyaltyStrategyRule.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::royalty_strategy_bps::BpsRoyaltyStrategyRule";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): BpsRoyaltyStrategyRuleReified {
        return {
            typeName: BpsRoyaltyStrategyRule.$typeName,
            fullTypeName: composeSuiType(
                BpsRoyaltyStrategyRule.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::royalty_strategy_bps::BpsRoyaltyStrategyRule",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                BpsRoyaltyStrategyRule.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                BpsRoyaltyStrategyRule.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                BpsRoyaltyStrategyRule.fromBcs(
                    data,
                ),
            bcs: BpsRoyaltyStrategyRule.bcs,
            fromJSONField: (field: any) =>
                BpsRoyaltyStrategyRule.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                BpsRoyaltyStrategyRule.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                BpsRoyaltyStrategyRule.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => BpsRoyaltyStrategyRule.fetch(
                client,
                id,
            ),
            new: (
                fields: BpsRoyaltyStrategyRuleFields,
            ) => {
                return new BpsRoyaltyStrategyRule(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return BpsRoyaltyStrategyRule.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<BpsRoyaltyStrategyRule>> {
        return phantom(BpsRoyaltyStrategyRule.reified());
    }

    static get p() {
        return BpsRoyaltyStrategyRule.phantom()
    }

    static get bcs() {
        return bcs.struct("BpsRoyaltyStrategyRule", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): BpsRoyaltyStrategyRule {
        return BpsRoyaltyStrategyRule.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): BpsRoyaltyStrategyRule {
        if (!isBpsRoyaltyStrategyRule(item.type)) {
            throw new Error("not a BpsRoyaltyStrategyRule type");
        }

        return BpsRoyaltyStrategyRule.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): BpsRoyaltyStrategyRule {

        return BpsRoyaltyStrategyRule.fromFields(
            BpsRoyaltyStrategyRule.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            dummyField: this.dummyField,

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField(
         field: any
    ): BpsRoyaltyStrategyRule {
        return BpsRoyaltyStrategyRule.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): BpsRoyaltyStrategyRule {
        if (json.$typeName !== BpsRoyaltyStrategyRule.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return BpsRoyaltyStrategyRule.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): BpsRoyaltyStrategyRule {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBpsRoyaltyStrategyRule(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a BpsRoyaltyStrategyRule object`);
        }
        return BpsRoyaltyStrategyRule.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<BpsRoyaltyStrategyRule> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching BpsRoyaltyStrategyRule object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBpsRoyaltyStrategyRule(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a BpsRoyaltyStrategyRule object`);
        }

        return BpsRoyaltyStrategyRule.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
