import * as reified from "../../_framework/reified";
import {Balance} from "../../_dependencies/source/0x2/balance/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, Vector, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {CritbitTree} from "../../utils/crit-bit/structs";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Bid =============================== */

export function isBid(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::Bid<");
}

export interface BidFields<FT extends PhantomTypeArgument> {
    amount: ToField<Balance<FT>>; owner: ToField<"address">
}

export type BidReified<FT extends PhantomTypeArgument> = Reified<
    Bid<FT>,
    BidFields<FT>
>;

export class Bid<FT extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::Bid";
    static readonly $numTypeParams = 1;

    readonly $typeName = Bid.$typeName;

    readonly $fullTypeName: `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::Bid<${PhantomToTypeStr<FT>}>`;

    readonly $typeArgs: [PhantomToTypeStr<FT>];

    readonly amount:
        ToField<Balance<FT>>
    ; readonly owner:
        ToField<"address">

    private constructor(typeArgs: [PhantomToTypeStr<FT>], fields: BidFields<FT>,
    ) {
        this.$fullTypeName = composeSuiType(
            Bid.$typeName,
            ...typeArgs
        ) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::Bid<${PhantomToTypeStr<FT>}>`;
        this.$typeArgs = typeArgs;

        this.amount = fields.amount;; this.owner = fields.owner;
    }

    static reified<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): BidReified<ToPhantomTypeArgument<FT>> {
        return {
            typeName: Bid.$typeName,
            fullTypeName: composeSuiType(
                Bid.$typeName,
                ...[extractType(FT)]
            ) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::Bid<${PhantomToTypeStr<ToPhantomTypeArgument<FT>>}>`,
            typeArgs: [
                extractType(FT)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<FT>>],
            reifiedTypeArgs: [FT],
            fromFields: (fields: Record<string, any>) =>
                Bid.fromFields(
                    FT,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Bid.fromFieldsWithTypes(
                    FT,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Bid.fromBcs(
                    FT,
                    data,
                ),
            bcs: Bid.bcs,
            fromJSONField: (field: any) =>
                Bid.fromJSONField(
                    FT,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Bid.fromJSON(
                    FT,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Bid.fromSuiParsedData(
                    FT,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Bid.fetch(
                client,
                FT,
                id,
            ),
            new: (
                fields: BidFields<ToPhantomTypeArgument<FT>>,
            ) => {
                return new Bid(
                    [extractType(FT)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Bid.reified
    }

    static phantom<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): PhantomReified<ToTypeStr<Bid<ToPhantomTypeArgument<FT>>>> {
        return phantom(Bid.reified(
            FT
        ));
    }

    static get p() {
        return Bid.phantom
    }

    static get bcs() {
        return bcs.struct("Bid", {
            amount:
                Balance.bcs
            , owner:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})

        })
    };

    static fromFields<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, fields: Record<string, any>
    ): Bid<ToPhantomTypeArgument<FT>> {
        return Bid.reified(
            typeArg,
        ).new(
            {amount: decodeFromFields(Balance.reified(typeArg), fields.amount), owner: decodeFromFields("address", fields.owner)}
        )
    }

    static fromFieldsWithTypes<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, item: FieldsWithTypes
    ): Bid<ToPhantomTypeArgument<FT>> {
        if (!isBid(item.type)) {
            throw new Error("not a Bid type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Bid.reified(
            typeArg,
        ).new(
            {amount: decodeFromFieldsWithTypes(Balance.reified(typeArg), item.fields.amount), owner: decodeFromFieldsWithTypes("address", item.fields.owner)}
        )
    }

    static fromBcs<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, data: Uint8Array
    ): Bid<ToPhantomTypeArgument<FT>> {

        return Bid.fromFields(
            typeArg,
            Bid.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            amount: this.amount.toJSONField(),owner: this.owner,

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
    ): Bid<ToPhantomTypeArgument<FT>> {
        return Bid.reified(
            typeArg,
        ).new(
            {amount: decodeFromJSONField(Balance.reified(typeArg), field.amount), owner: decodeFromJSONField("address", field.owner)}
        )
    }

    static fromJSON<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, json: Record<string, any>
    ): Bid<ToPhantomTypeArgument<FT>> {
        if (json.$typeName !== Bid.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Bid.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return Bid.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, content: SuiParsedData
    ): Bid<ToPhantomTypeArgument<FT>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBid(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Bid object`);
        }
        return Bid.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<FT extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: FT, id: string
    ): Promise<Bid<ToPhantomTypeArgument<FT>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Bid object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBid(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Bid object`);
        }

        return Bid.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== MarketKey =============================== */

export function isMarketKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::MarketKey";
}

export interface MarketKeyFields {
    dummyField: ToField<"bool">
}

export type MarketKeyReified = Reified<
    MarketKey,
    MarketKeyFields
>;

export class MarketKey implements StructClass {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::MarketKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = MarketKey.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::MarketKey";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: MarketKeyFields,
    ) {
        this.$fullTypeName = composeSuiType(
            MarketKey.$typeName,
            ...typeArgs
        ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::MarketKey";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): MarketKeyReified {
        return {
            typeName: MarketKey.$typeName,
            fullTypeName: composeSuiType(
                MarketKey.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::MarketKey",
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

/* ============================== DutchAuctionMarket =============================== */

export function isDutchAuctionMarket(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::DutchAuctionMarket<");
}

export interface DutchAuctionMarketFields<FT extends PhantomTypeArgument> {
    id: ToField<UID>; reservePrice: ToField<"u64">; bids: ToField<CritbitTree<Vector<Bid<FT>>>>; inventoryId: ToField<ID>
}

export type DutchAuctionMarketReified<FT extends PhantomTypeArgument> = Reified<
    DutchAuctionMarket<FT>,
    DutchAuctionMarketFields<FT>
>;

export class DutchAuctionMarket<FT extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::DutchAuctionMarket";
    static readonly $numTypeParams = 1;

    readonly $typeName = DutchAuctionMarket.$typeName;

    readonly $fullTypeName: `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::DutchAuctionMarket<${PhantomToTypeStr<FT>}>`;

    readonly $typeArgs: [PhantomToTypeStr<FT>];

    readonly id:
        ToField<UID>
    ; readonly reservePrice:
        ToField<"u64">
    ; readonly bids:
        ToField<CritbitTree<Vector<Bid<FT>>>>
    ; readonly inventoryId:
        ToField<ID>

    private constructor(typeArgs: [PhantomToTypeStr<FT>], fields: DutchAuctionMarketFields<FT>,
    ) {
        this.$fullTypeName = composeSuiType(
            DutchAuctionMarket.$typeName,
            ...typeArgs
        ) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::DutchAuctionMarket<${PhantomToTypeStr<FT>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.reservePrice = fields.reservePrice;; this.bids = fields.bids;; this.inventoryId = fields.inventoryId;
    }

    static reified<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): DutchAuctionMarketReified<ToPhantomTypeArgument<FT>> {
        return {
            typeName: DutchAuctionMarket.$typeName,
            fullTypeName: composeSuiType(
                DutchAuctionMarket.$typeName,
                ...[extractType(FT)]
            ) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction::DutchAuctionMarket<${PhantomToTypeStr<ToPhantomTypeArgument<FT>>}>`,
            typeArgs: [
                extractType(FT)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<FT>>],
            reifiedTypeArgs: [FT],
            fromFields: (fields: Record<string, any>) =>
                DutchAuctionMarket.fromFields(
                    FT,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                DutchAuctionMarket.fromFieldsWithTypes(
                    FT,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                DutchAuctionMarket.fromBcs(
                    FT,
                    data,
                ),
            bcs: DutchAuctionMarket.bcs,
            fromJSONField: (field: any) =>
                DutchAuctionMarket.fromJSONField(
                    FT,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                DutchAuctionMarket.fromJSON(
                    FT,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                DutchAuctionMarket.fromSuiParsedData(
                    FT,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => DutchAuctionMarket.fetch(
                client,
                FT,
                id,
            ),
            new: (
                fields: DutchAuctionMarketFields<ToPhantomTypeArgument<FT>>,
            ) => {
                return new DutchAuctionMarket(
                    [extractType(FT)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return DutchAuctionMarket.reified
    }

    static phantom<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): PhantomReified<ToTypeStr<DutchAuctionMarket<ToPhantomTypeArgument<FT>>>> {
        return phantom(DutchAuctionMarket.reified(
            FT
        ));
    }

    static get p() {
        return DutchAuctionMarket.phantom
    }

    static get bcs() {
        return bcs.struct("DutchAuctionMarket", {
            id:
                UID.bcs
            , reserve_price:
                bcs.u64()
            , bids:
                CritbitTree.bcs(bcs.vector(Bid.bcs))
            , inventory_id:
                ID.bcs

        })
    };

    static fromFields<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, fields: Record<string, any>
    ): DutchAuctionMarket<ToPhantomTypeArgument<FT>> {
        return DutchAuctionMarket.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), reservePrice: decodeFromFields("u64", fields.reserve_price), bids: decodeFromFields(CritbitTree.reified(reified.vector(Bid.reified(typeArg))), fields.bids), inventoryId: decodeFromFields(ID.reified(), fields.inventory_id)}
        )
    }

    static fromFieldsWithTypes<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, item: FieldsWithTypes
    ): DutchAuctionMarket<ToPhantomTypeArgument<FT>> {
        if (!isDutchAuctionMarket(item.type)) {
            throw new Error("not a DutchAuctionMarket type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return DutchAuctionMarket.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), reservePrice: decodeFromFieldsWithTypes("u64", item.fields.reserve_price), bids: decodeFromFieldsWithTypes(CritbitTree.reified(reified.vector(Bid.reified(typeArg))), item.fields.bids), inventoryId: decodeFromFieldsWithTypes(ID.reified(), item.fields.inventory_id)}
        )
    }

    static fromBcs<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, data: Uint8Array
    ): DutchAuctionMarket<ToPhantomTypeArgument<FT>> {

        return DutchAuctionMarket.fromFields(
            typeArg,
            DutchAuctionMarket.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,reservePrice: this.reservePrice.toString(),bids: this.bids.toJSONField(),inventoryId: this.inventoryId,

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
    ): DutchAuctionMarket<ToPhantomTypeArgument<FT>> {
        return DutchAuctionMarket.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), reservePrice: decodeFromJSONField("u64", field.reservePrice), bids: decodeFromJSONField(CritbitTree.reified(reified.vector(Bid.reified(typeArg))), field.bids), inventoryId: decodeFromJSONField(ID.reified(), field.inventoryId)}
        )
    }

    static fromJSON<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, json: Record<string, any>
    ): DutchAuctionMarket<ToPhantomTypeArgument<FT>> {
        if (json.$typeName !== DutchAuctionMarket.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(DutchAuctionMarket.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return DutchAuctionMarket.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, content: SuiParsedData
    ): DutchAuctionMarket<ToPhantomTypeArgument<FT>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isDutchAuctionMarket(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a DutchAuctionMarket object`);
        }
        return DutchAuctionMarket.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<FT extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: FT, id: string
    ): Promise<DutchAuctionMarket<ToPhantomTypeArgument<FT>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching DutchAuctionMarket object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isDutchAuctionMarket(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a DutchAuctionMarket object`);
        }

        return DutchAuctionMarket.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
