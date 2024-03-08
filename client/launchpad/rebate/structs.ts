import {Balance} from "../../_dependencies/source/0x2/balance/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Rebate =============================== */

export function isRebate(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x5cf2b8379d7471113852dbf343c14f933ccaca527bbe37b42724b5dde4738830::rebate::Rebate<");
}

export interface RebateFields<FT extends PhantomTypeArgument> {
    funds: ToField<Balance<FT>>; rebateAmount: ToField<"u64">
}

export type RebateReified<FT extends PhantomTypeArgument> = Reified<
    Rebate<FT>,
    RebateFields<FT>
>;

export class Rebate<FT extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x5cf2b8379d7471113852dbf343c14f933ccaca527bbe37b42724b5dde4738830::rebate::Rebate";
    static readonly $numTypeParams = 1;

    readonly $typeName = Rebate.$typeName;

    readonly $fullTypeName: `0x5cf2b8379d7471113852dbf343c14f933ccaca527bbe37b42724b5dde4738830::rebate::Rebate<${PhantomToTypeStr<FT>}>`;

    readonly $typeArgs: [PhantomToTypeStr<FT>];

    readonly funds:
        ToField<Balance<FT>>
    ; readonly rebateAmount:
        ToField<"u64">

    private constructor(typeArgs: [PhantomToTypeStr<FT>], fields: RebateFields<FT>,
    ) {
        this.$fullTypeName = composeSuiType(
            Rebate.$typeName,
            ...typeArgs
        ) as `0x5cf2b8379d7471113852dbf343c14f933ccaca527bbe37b42724b5dde4738830::rebate::Rebate<${PhantomToTypeStr<FT>}>`;
        this.$typeArgs = typeArgs;

        this.funds = fields.funds;; this.rebateAmount = fields.rebateAmount;
    }

    static reified<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): RebateReified<ToPhantomTypeArgument<FT>> {
        return {
            typeName: Rebate.$typeName,
            fullTypeName: composeSuiType(
                Rebate.$typeName,
                ...[extractType(FT)]
            ) as `0x5cf2b8379d7471113852dbf343c14f933ccaca527bbe37b42724b5dde4738830::rebate::Rebate<${PhantomToTypeStr<ToPhantomTypeArgument<FT>>}>`,
            typeArgs: [
                extractType(FT)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<FT>>],
            reifiedTypeArgs: [FT],
            fromFields: (fields: Record<string, any>) =>
                Rebate.fromFields(
                    FT,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Rebate.fromFieldsWithTypes(
                    FT,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Rebate.fromBcs(
                    FT,
                    data,
                ),
            bcs: Rebate.bcs,
            fromJSONField: (field: any) =>
                Rebate.fromJSONField(
                    FT,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Rebate.fromJSON(
                    FT,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Rebate.fromSuiParsedData(
                    FT,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Rebate.fetch(
                client,
                FT,
                id,
            ),
            new: (
                fields: RebateFields<ToPhantomTypeArgument<FT>>,
            ) => {
                return new Rebate(
                    [extractType(FT)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Rebate.reified
    }

    static phantom<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): PhantomReified<ToTypeStr<Rebate<ToPhantomTypeArgument<FT>>>> {
        return phantom(Rebate.reified(
            FT
        ));
    }

    static get p() {
        return Rebate.phantom
    }

    static get bcs() {
        return bcs.struct("Rebate", {
            funds:
                Balance.bcs
            , rebate_amount:
                bcs.u64()

        })
    };

    static fromFields<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, fields: Record<string, any>
    ): Rebate<ToPhantomTypeArgument<FT>> {
        return Rebate.reified(
            typeArg,
        ).new(
            {funds: decodeFromFields(Balance.reified(typeArg), fields.funds), rebateAmount: decodeFromFields("u64", fields.rebate_amount)}
        )
    }

    static fromFieldsWithTypes<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, item: FieldsWithTypes
    ): Rebate<ToPhantomTypeArgument<FT>> {
        if (!isRebate(item.type)) {
            throw new Error("not a Rebate type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Rebate.reified(
            typeArg,
        ).new(
            {funds: decodeFromFieldsWithTypes(Balance.reified(typeArg), item.fields.funds), rebateAmount: decodeFromFieldsWithTypes("u64", item.fields.rebate_amount)}
        )
    }

    static fromBcs<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, data: Uint8Array
    ): Rebate<ToPhantomTypeArgument<FT>> {

        return Rebate.fromFields(
            typeArg,
            Rebate.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            funds: this.funds.toJSONField(),rebateAmount: this.rebateAmount.toString(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, field: any
    ): Rebate<ToPhantomTypeArgument<FT>> {
        return Rebate.reified(
            typeArg,
        ).new(
            {funds: decodeFromJSONField(Balance.reified(typeArg), field.funds), rebateAmount: decodeFromJSONField("u64", field.rebateAmount)}
        )
    }

    static fromJSON<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, json: Record<string, any>
    ): Rebate<ToPhantomTypeArgument<FT>> {
        if (json.$typeName !== Rebate.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Rebate.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return Rebate.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, content: SuiParsedData
    ): Rebate<ToPhantomTypeArgument<FT>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isRebate(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Rebate object`);
        }
        return Rebate.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<FT extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: FT, id: string
    ): Promise<Rebate<ToPhantomTypeArgument<FT>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Rebate object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isRebate(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Rebate object`);
        }

        return Rebate.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== RebateDfKey =============================== */

export function isRebateDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x5cf2b8379d7471113852dbf343c14f933ccaca527bbe37b42724b5dde4738830::rebate::RebateDfKey<");
}

export interface RebateDfKeyFields<T extends PhantomTypeArgument, FT extends PhantomTypeArgument> {
    dummyField: ToField<"bool">
}

export type RebateDfKeyReified<T extends PhantomTypeArgument, FT extends PhantomTypeArgument> = Reified<
    RebateDfKey<T, FT>,
    RebateDfKeyFields<T, FT>
>;

export class RebateDfKey<T extends PhantomTypeArgument, FT extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x5cf2b8379d7471113852dbf343c14f933ccaca527bbe37b42724b5dde4738830::rebate::RebateDfKey";
    static readonly $numTypeParams = 2;

    readonly $typeName = RebateDfKey.$typeName;

    readonly $fullTypeName: `0x5cf2b8379d7471113852dbf343c14f933ccaca527bbe37b42724b5dde4738830::rebate::RebateDfKey<${PhantomToTypeStr<T>}, ${PhantomToTypeStr<FT>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>, PhantomToTypeStr<FT>];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [PhantomToTypeStr<T>, PhantomToTypeStr<FT>], fields: RebateDfKeyFields<T, FT>,
    ) {
        this.$fullTypeName = composeSuiType(
            RebateDfKey.$typeName,
            ...typeArgs
        ) as `0x5cf2b8379d7471113852dbf343c14f933ccaca527bbe37b42724b5dde4738830::rebate::RebateDfKey<${PhantomToTypeStr<T>}, ${PhantomToTypeStr<FT>}>`;
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        T: T, FT: FT
    ): RebateDfKeyReified<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return {
            typeName: RebateDfKey.$typeName,
            fullTypeName: composeSuiType(
                RebateDfKey.$typeName,
                ...[extractType(T), extractType(FT)]
            ) as `0x5cf2b8379d7471113852dbf343c14f933ccaca527bbe37b42724b5dde4738830::rebate::RebateDfKey<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}, ${PhantomToTypeStr<ToPhantomTypeArgument<FT>>}>`,
            typeArgs: [
                extractType(T), extractType(FT)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>, PhantomToTypeStr<ToPhantomTypeArgument<FT>>],
            reifiedTypeArgs: [T, FT],
            fromFields: (fields: Record<string, any>) =>
                RebateDfKey.fromFields(
                    [T, FT],
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                RebateDfKey.fromFieldsWithTypes(
                    [T, FT],
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                RebateDfKey.fromBcs(
                    [T, FT],
                    data,
                ),
            bcs: RebateDfKey.bcs,
            fromJSONField: (field: any) =>
                RebateDfKey.fromJSONField(
                    [T, FT],
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                RebateDfKey.fromJSON(
                    [T, FT],
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                RebateDfKey.fromSuiParsedData(
                    [T, FT],
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => RebateDfKey.fetch(
                client,
                [T, FT],
                id,
            ),
            new: (
                fields: RebateDfKeyFields<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>>,
            ) => {
                return new RebateDfKey(
                    [extractType(T), extractType(FT)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return RebateDfKey.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        T: T, FT: FT
    ): PhantomReified<ToTypeStr<RebateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>>>> {
        return phantom(RebateDfKey.reified(
            T, FT
        ));
    }

    static get p() {
        return RebateDfKey.phantom
    }

    static get bcs() {
        return bcs.struct("RebateDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], fields: Record<string, any>
    ): RebateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return RebateDfKey.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], item: FieldsWithTypes
    ): RebateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (!isRebateDfKey(item.type)) {
            throw new Error("not a RebateDfKey type");
        }
        assertFieldsWithTypesArgsMatch(item, typeArgs);

        return RebateDfKey.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], data: Uint8Array
    ): RebateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {

        return RebateDfKey.fromFields(
            typeArgs,
            RebateDfKey.bcs.parse(data)
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

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], field: any
    ): RebateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return RebateDfKey.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], json: Record<string, any>
    ): RebateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (json.$typeName !== RebateDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(RebateDfKey.$typeName,
            ...typeArgs.map(extractType)),
            json.$typeArgs,
            typeArgs,
        )

        return RebateDfKey.fromJSONField(
            typeArgs,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], content: SuiParsedData
    ): RebateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isRebateDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a RebateDfKey object`);
        }
        return RebateDfKey.fromFieldsWithTypes(
            typeArgs,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArgs: [T, FT], id: string
    ): Promise<RebateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching RebateDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isRebateDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a RebateDfKey object`);
        }

        return RebateDfKey.fromBcs(
            typeArgs,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
