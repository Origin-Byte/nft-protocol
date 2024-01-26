import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {VecMap} from "../../_dependencies/source/0x2/vec-map/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== MarketKey =============================== */

export function isMarketKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::limited_fixed_price::MarketKey";
}

export interface MarketKeyFields {
    dummyField: ToField<"bool">
}

export type MarketKeyReified = Reified<
    MarketKey,
    MarketKeyFields
>;

export class MarketKey {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::limited_fixed_price::MarketKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = MarketKey.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::limited_fixed_price::MarketKey";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: MarketKeyFields,
    ) {
        this.$fullTypeName = MarketKey.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): MarketKeyReified {
        return {
            typeName: MarketKey.$typeName,
            fullTypeName: composeSuiType(
                MarketKey.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::limited_fixed_price::MarketKey",
            typeArgs: [],
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
            fetch: async (client: SuiClient, id: string) => MarketKey.fetch(
                client,
                id,
            ),
            new: (
                fields: MarketKeyFields,
            ) => {
                return new MarketKey(
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

/* ============================== LimitedFixedPriceMarket =============================== */

export function isLimitedFixedPriceMarket(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::limited_fixed_price::LimitedFixedPriceMarket<");
}

export interface LimitedFixedPriceMarketFields<FT extends PhantomTypeArgument> {
    id: ToField<UID>; limit: ToField<"u64">; price: ToField<"u64">; inventoryId: ToField<ID>; addresses: ToField<VecMap<"address", "u64">>
}

export type LimitedFixedPriceMarketReified<FT extends PhantomTypeArgument> = Reified<
    LimitedFixedPriceMarket<FT>,
    LimitedFixedPriceMarketFields<FT>
>;

export class LimitedFixedPriceMarket<FT extends PhantomTypeArgument> {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::limited_fixed_price::LimitedFixedPriceMarket";
    static readonly $numTypeParams = 1;

    readonly $typeName = LimitedFixedPriceMarket.$typeName;

    readonly $fullTypeName: `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::limited_fixed_price::LimitedFixedPriceMarket<${PhantomToTypeStr<FT>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly limit:
        ToField<"u64">
    ; readonly price:
        ToField<"u64">
    ; readonly inventoryId:
        ToField<ID>
    ; readonly addresses:
        ToField<VecMap<"address", "u64">>

    private constructor(typeArg: string, fields: LimitedFixedPriceMarketFields<FT>,
    ) {
        this.$fullTypeName = composeSuiType(LimitedFixedPriceMarket.$typeName,
        typeArg) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::limited_fixed_price::LimitedFixedPriceMarket<${PhantomToTypeStr<FT>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.limit = fields.limit;; this.price = fields.price;; this.inventoryId = fields.inventoryId;; this.addresses = fields.addresses;
    }

    static reified<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): LimitedFixedPriceMarketReified<ToPhantomTypeArgument<FT>> {
        return {
            typeName: LimitedFixedPriceMarket.$typeName,
            fullTypeName: composeSuiType(
                LimitedFixedPriceMarket.$typeName,
                ...[extractType(FT)]
            ) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::limited_fixed_price::LimitedFixedPriceMarket<${PhantomToTypeStr<ToPhantomTypeArgument<FT>>}>`,
            typeArgs: [FT],
            fromFields: (fields: Record<string, any>) =>
                LimitedFixedPriceMarket.fromFields(
                    FT,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                LimitedFixedPriceMarket.fromFieldsWithTypes(
                    FT,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                LimitedFixedPriceMarket.fromBcs(
                    FT,
                    data,
                ),
            bcs: LimitedFixedPriceMarket.bcs,
            fromJSONField: (field: any) =>
                LimitedFixedPriceMarket.fromJSONField(
                    FT,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                LimitedFixedPriceMarket.fromJSON(
                    FT,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => LimitedFixedPriceMarket.fetch(
                client,
                FT,
                id,
            ),
            new: (
                fields: LimitedFixedPriceMarketFields<ToPhantomTypeArgument<FT>>,
            ) => {
                return new LimitedFixedPriceMarket(
                    extractType(FT),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return LimitedFixedPriceMarket.reified
    }

    static phantom<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): PhantomReified<ToTypeStr<LimitedFixedPriceMarket<ToPhantomTypeArgument<FT>>>> {
        return phantom(LimitedFixedPriceMarket.reified(
            FT
        ));
    }

    static get p() {
        return LimitedFixedPriceMarket.phantom
    }

    static get bcs() {
        return bcs.struct("LimitedFixedPriceMarket", {
            id:
                UID.bcs
            , limit:
                bcs.u64()
            , price:
                bcs.u64()
            , inventory_id:
                ID.bcs
            , addresses:
                VecMap.bcs(bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),}), bcs.u64())

        })
    };

    static fromFields<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, fields: Record<string, any>
    ): LimitedFixedPriceMarket<ToPhantomTypeArgument<FT>> {
        return LimitedFixedPriceMarket.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), limit: decodeFromFields("u64", fields.limit), price: decodeFromFields("u64", fields.price), inventoryId: decodeFromFields(ID.reified(), fields.inventory_id), addresses: decodeFromFields(VecMap.reified("address", "u64"), fields.addresses)}
        )
    }

    static fromFieldsWithTypes<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, item: FieldsWithTypes
    ): LimitedFixedPriceMarket<ToPhantomTypeArgument<FT>> {
        if (!isLimitedFixedPriceMarket(item.type)) {
            throw new Error("not a LimitedFixedPriceMarket type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return LimitedFixedPriceMarket.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), limit: decodeFromFieldsWithTypes("u64", item.fields.limit), price: decodeFromFieldsWithTypes("u64", item.fields.price), inventoryId: decodeFromFieldsWithTypes(ID.reified(), item.fields.inventory_id), addresses: decodeFromFieldsWithTypes(VecMap.reified("address", "u64"), item.fields.addresses)}
        )
    }

    static fromBcs<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, data: Uint8Array
    ): LimitedFixedPriceMarket<ToPhantomTypeArgument<FT>> {

        return LimitedFixedPriceMarket.fromFields(
            typeArg,
            LimitedFixedPriceMarket.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,limit: this.limit.toString(),price: this.price.toString(),inventoryId: this.inventoryId,addresses: this.addresses.toJSONField(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, field: any
    ): LimitedFixedPriceMarket<ToPhantomTypeArgument<FT>> {
        return LimitedFixedPriceMarket.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), limit: decodeFromJSONField("u64", field.limit), price: decodeFromJSONField("u64", field.price), inventoryId: decodeFromJSONField(ID.reified(), field.inventoryId), addresses: decodeFromJSONField(VecMap.reified("address", "u64"), field.addresses)}
        )
    }

    static fromJSON<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, json: Record<string, any>
    ): LimitedFixedPriceMarket<ToPhantomTypeArgument<FT>> {
        if (json.$typeName !== LimitedFixedPriceMarket.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(LimitedFixedPriceMarket.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return LimitedFixedPriceMarket.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, content: SuiParsedData
    ): LimitedFixedPriceMarket<ToPhantomTypeArgument<FT>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isLimitedFixedPriceMarket(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a LimitedFixedPriceMarket object`);
        }
        return LimitedFixedPriceMarket.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<FT extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: FT, id: string
    ): Promise<LimitedFixedPriceMarket<ToPhantomTypeArgument<FT>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching LimitedFixedPriceMarket object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isLimitedFixedPriceMarket(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a LimitedFixedPriceMarket object`);
        }

        return LimitedFixedPriceMarket.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
