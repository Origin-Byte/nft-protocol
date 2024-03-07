import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== MarketKey =============================== */

export function isMarketKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::fixed_price::MarketKey";
}

export interface MarketKeyFields {
    dummyField: ToField<"bool">
}

export type MarketKeyReified = Reified<
    MarketKey,
    MarketKeyFields
>;

export class MarketKey implements StructClass {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::fixed_price::MarketKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = MarketKey.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::fixed_price::MarketKey";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: MarketKeyFields,
    ) {
        this.$fullTypeName = composeSuiType(
            MarketKey.$typeName,
            ...typeArgs
        ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::fixed_price::MarketKey";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): MarketKeyReified {
        return {
            typeName: MarketKey.$typeName,
            fullTypeName: composeSuiType(
                MarketKey.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::fixed_price::MarketKey",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                MarketKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                MarketKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                MarketKey.fromBcs(
                    data,
                ),
            bcs: MarketKey.bcs,
            fromJSONField: (field: any) =>
                MarketKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                MarketKey.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                MarketKey.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => MarketKey.fetch(
                client,
                id,
            ),
            new: (
                fields: MarketKeyFields,
            ) => {
                return new MarketKey(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return MarketKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<MarketKey>> {
        return phantom(MarketKey.reified());
    }

    static get p() {
        return MarketKey.phantom()
    }

    static get bcs() {
        return bcs.struct("MarketKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): MarketKey {
        return MarketKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): MarketKey {
        if (!isMarketKey(item.type)) {
            throw new Error("not a MarketKey type");
        }

        return MarketKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): MarketKey {

        return MarketKey.fromFields(
            MarketKey.bcs.parse(data)
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
    ): MarketKey {
        return MarketKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): MarketKey {
        if (json.$typeName !== MarketKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return MarketKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): MarketKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isMarketKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a MarketKey object`);
        }
        return MarketKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<MarketKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching MarketKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isMarketKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a MarketKey object`);
        }

        return MarketKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== FixedPriceMarket =============================== */

export function isFixedPriceMarket(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::fixed_price::FixedPriceMarket<");
}

export interface FixedPriceMarketFields<FT extends PhantomTypeArgument> {
    id: ToField<UID>; price: ToField<"u64">; inventoryId: ToField<ID>
}

export type FixedPriceMarketReified<FT extends PhantomTypeArgument> = Reified<
    FixedPriceMarket<FT>,
    FixedPriceMarketFields<FT>
>;

export class FixedPriceMarket<FT extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::fixed_price::FixedPriceMarket";
    static readonly $numTypeParams = 1;

    readonly $typeName = FixedPriceMarket.$typeName;

    readonly $fullTypeName: `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::fixed_price::FixedPriceMarket<${PhantomToTypeStr<FT>}>`;

    readonly $typeArgs: [PhantomToTypeStr<FT>];

    readonly id:
        ToField<UID>
    ; readonly price:
        ToField<"u64">
    ; readonly inventoryId:
        ToField<ID>

    private constructor(typeArgs: [PhantomToTypeStr<FT>], fields: FixedPriceMarketFields<FT>,
    ) {
        this.$fullTypeName = composeSuiType(
            FixedPriceMarket.$typeName,
            ...typeArgs
        ) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::fixed_price::FixedPriceMarket<${PhantomToTypeStr<FT>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.price = fields.price;; this.inventoryId = fields.inventoryId;
    }

    static reified<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): FixedPriceMarketReified<ToPhantomTypeArgument<FT>> {
        return {
            typeName: FixedPriceMarket.$typeName,
            fullTypeName: composeSuiType(
                FixedPriceMarket.$typeName,
                ...[extractType(FT)]
            ) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::fixed_price::FixedPriceMarket<${PhantomToTypeStr<ToPhantomTypeArgument<FT>>}>`,
            typeArgs: [
                extractType(FT)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<FT>>],
            reifiedTypeArgs: [FT],
            fromFields: (fields: Record<string, any>) =>
                FixedPriceMarket.fromFields(
                    FT,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                FixedPriceMarket.fromFieldsWithTypes(
                    FT,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                FixedPriceMarket.fromBcs(
                    FT,
                    data,
                ),
            bcs: FixedPriceMarket.bcs,
            fromJSONField: (field: any) =>
                FixedPriceMarket.fromJSONField(
                    FT,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                FixedPriceMarket.fromJSON(
                    FT,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                FixedPriceMarket.fromSuiParsedData(
                    FT,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => FixedPriceMarket.fetch(
                client,
                FT,
                id,
            ),
            new: (
                fields: FixedPriceMarketFields<ToPhantomTypeArgument<FT>>,
            ) => {
                return new FixedPriceMarket(
                    [extractType(FT)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return FixedPriceMarket.reified
    }

    static phantom<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): PhantomReified<ToTypeStr<FixedPriceMarket<ToPhantomTypeArgument<FT>>>> {
        return phantom(FixedPriceMarket.reified(
            FT
        ));
    }

    static get p() {
        return FixedPriceMarket.phantom
    }

    static get bcs() {
        return bcs.struct("FixedPriceMarket", {
            id:
                UID.bcs
            , price:
                bcs.u64()
            , inventory_id:
                ID.bcs

        })
    };

    static fromFields<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, fields: Record<string, any>
    ): FixedPriceMarket<ToPhantomTypeArgument<FT>> {
        return FixedPriceMarket.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), price: decodeFromFields("u64", fields.price), inventoryId: decodeFromFields(ID.reified(), fields.inventory_id)}
        )
    }

    static fromFieldsWithTypes<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, item: FieldsWithTypes
    ): FixedPriceMarket<ToPhantomTypeArgument<FT>> {
        if (!isFixedPriceMarket(item.type)) {
            throw new Error("not a FixedPriceMarket type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return FixedPriceMarket.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), price: decodeFromFieldsWithTypes("u64", item.fields.price), inventoryId: decodeFromFieldsWithTypes(ID.reified(), item.fields.inventory_id)}
        )
    }

    static fromBcs<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, data: Uint8Array
    ): FixedPriceMarket<ToPhantomTypeArgument<FT>> {

        return FixedPriceMarket.fromFields(
            typeArg,
            FixedPriceMarket.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,price: this.price.toString(),inventoryId: this.inventoryId,

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
    ): FixedPriceMarket<ToPhantomTypeArgument<FT>> {
        return FixedPriceMarket.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), price: decodeFromJSONField("u64", field.price), inventoryId: decodeFromJSONField(ID.reified(), field.inventoryId)}
        )
    }

    static fromJSON<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, json: Record<string, any>
    ): FixedPriceMarket<ToPhantomTypeArgument<FT>> {
        if (json.$typeName !== FixedPriceMarket.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(FixedPriceMarket.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return FixedPriceMarket.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, content: SuiParsedData
    ): FixedPriceMarket<ToPhantomTypeArgument<FT>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isFixedPriceMarket(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a FixedPriceMarket object`);
        }
        return FixedPriceMarket.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<FT extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: FT, id: string
    ): Promise<FixedPriceMarket<ToPhantomTypeArgument<FT>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching FixedPriceMarket object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isFixedPriceMarket(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a FixedPriceMarket object`);
        }

        return FixedPriceMarket.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
