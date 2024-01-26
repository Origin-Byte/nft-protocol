import {Balance} from "../../_dependencies/source/0x2/balance/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeArgument, ToTypeStr, TypeArgument, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom, toBcs} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {BcsType, bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Bid =============================== */

export function isBid(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction::Bid<");
}

export interface BidFields<FT extends PhantomTypeArgument> {
    bidder: ToField<"address">; offer: ToField<Balance<FT>>
}

export type BidReified<FT extends PhantomTypeArgument> = Reified<
    Bid<FT>,
    BidFields<FT>
>;

export class Bid<FT extends PhantomTypeArgument> {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction::Bid";
    static readonly $numTypeParams = 1;

    readonly $typeName = Bid.$typeName;

    readonly $fullTypeName: `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction::Bid<${PhantomToTypeStr<FT>}>`;

    readonly $typeArg: string;

    ;

    readonly bidder:
        ToField<"address">
    ; readonly offer:
        ToField<Balance<FT>>

    private constructor(typeArg: string, fields: BidFields<FT>,
    ) {
        this.$fullTypeName = composeSuiType(Bid.$typeName,
        typeArg) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction::Bid<${PhantomToTypeStr<FT>}>`;

        this.$typeArg = typeArg;

        this.bidder = fields.bidder;; this.offer = fields.offer;
    }

    static reified<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): BidReified<ToPhantomTypeArgument<FT>> {
        return {
            typeName: Bid.$typeName,
            fullTypeName: composeSuiType(
                Bid.$typeName,
                ...[extractType(FT)]
            ) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction::Bid<${PhantomToTypeStr<ToPhantomTypeArgument<FT>>}>`,
            typeArgs: [FT],
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
            fetch: async (client: SuiClient, id: string) => Bid.fetch(
                client,
                FT,
                id,
            ),
            new: (
                fields: BidFields<ToPhantomTypeArgument<FT>>,
            ) => {
                return new Bid(
                    extractType(FT),
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
            bidder:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , offer:
                Balance.bcs

        })
    };

    static fromFields<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, fields: Record<string, any>
    ): Bid<ToPhantomTypeArgument<FT>> {
        return Bid.reified(
            typeArg,
        ).new(
            {bidder: decodeFromFields("address", fields.bidder), offer: decodeFromFields(Balance.reified(typeArg), fields.offer)}
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
            {bidder: decodeFromFieldsWithTypes("address", item.fields.bidder), offer: decodeFromFieldsWithTypes(Balance.reified(typeArg), item.fields.offer)}
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
            bidder: this.bidder,offer: this.offer.toJSONField(),

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
    ): Bid<ToPhantomTypeArgument<FT>> {
        return Bid.reified(
            typeArg,
        ).new(
            {bidder: decodeFromJSONField("address", field.bidder), offer: decodeFromJSONField(Balance.reified(typeArg), field.offer)}
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
            [json.$typeArg],
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
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction::MarketKey";
}

export interface MarketKeyFields {
    dummyField: ToField<"bool">
}

export type MarketKeyReified = Reified<
    MarketKey,
    MarketKeyFields
>;

export class MarketKey {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction::MarketKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = MarketKey.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction::MarketKey";

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
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction::MarketKey",
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

/* ============================== EnglishAuction =============================== */

export function isEnglishAuction(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction::EnglishAuction<");
}

export interface EnglishAuctionFields<T extends TypeArgument, FT extends PhantomTypeArgument> {
    nft: ToField<T>; bid: ToField<Bid<FT>>; concluded: ToField<"bool">
}

export type EnglishAuctionReified<T extends TypeArgument, FT extends PhantomTypeArgument> = Reified<
    EnglishAuction<T, FT>,
    EnglishAuctionFields<T, FT>
>;

export class EnglishAuction<T extends TypeArgument, FT extends PhantomTypeArgument> {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction::EnglishAuction";
    static readonly $numTypeParams = 2;

    readonly $typeName = EnglishAuction.$typeName;

    readonly $fullTypeName: `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction::EnglishAuction<${ToTypeStr<T>}, ${PhantomToTypeStr<FT>}>`;

    readonly $typeArgs: [string, string];

    ;

    readonly nft:
        ToField<T>
    ; readonly bid:
        ToField<Bid<FT>>
    ; readonly concluded:
        ToField<"bool">

    private constructor(typeArgs: [string, string], fields: EnglishAuctionFields<T, FT>,
    ) {
        this.$fullTypeName = composeSuiType(EnglishAuction.$typeName,
        ...typeArgs) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction::EnglishAuction<${ToTypeStr<T>}, ${PhantomToTypeStr<FT>}>`;

        this.$typeArgs = typeArgs;

        this.nft = fields.nft;; this.bid = fields.bid;; this.concluded = fields.concluded;
    }

    static reified<T extends Reified<TypeArgument, any>, FT extends PhantomReified<PhantomTypeArgument>>(
        T: T, FT: FT
    ): EnglishAuctionReified<ToTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return {
            typeName: EnglishAuction.$typeName,
            fullTypeName: composeSuiType(
                EnglishAuction.$typeName,
                ...[extractType(T), extractType(FT)]
            ) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction::EnglishAuction<${ToTypeStr<ToTypeArgument<T>>}, ${PhantomToTypeStr<ToPhantomTypeArgument<FT>>}>`,
            typeArgs: [T, FT],
            fromFields: (fields: Record<string, any>) =>
                EnglishAuction.fromFields(
                    [T, FT],
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                EnglishAuction.fromFieldsWithTypes(
                    [T, FT],
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                EnglishAuction.fromBcs(
                    [T, FT],
                    data,
                ),
            bcs: EnglishAuction.bcs(toBcs(T)),
            fromJSONField: (field: any) =>
                EnglishAuction.fromJSONField(
                    [T, FT],
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                EnglishAuction.fromJSON(
                    [T, FT],
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => EnglishAuction.fetch(
                client,
                [T, FT],
                id,
            ),
            new: (
                fields: EnglishAuctionFields<ToTypeArgument<T>, ToPhantomTypeArgument<FT>>,
            ) => {
                return new EnglishAuction(
                    [extractType(T), extractType(FT)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return EnglishAuction.reified
    }

    static phantom<T extends Reified<TypeArgument, any>, FT extends PhantomReified<PhantomTypeArgument>>(
        T: T, FT: FT
    ): PhantomReified<ToTypeStr<EnglishAuction<ToTypeArgument<T>, ToPhantomTypeArgument<FT>>>> {
        return phantom(EnglishAuction.reified(
            T, FT
        ));
    }

    static get p() {
        return EnglishAuction.phantom
    }

    static get bcs() {
        return <T extends BcsType<any>>(T: T) => bcs.struct(`EnglishAuction<${T.name}>`, {
            nft:
                T
            , bid:
                Bid.bcs
            , concluded:
                bcs.bool()

        })
    };

    static fromFields<T extends Reified<TypeArgument, any>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], fields: Record<string, any>
    ): EnglishAuction<ToTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return EnglishAuction.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {nft: decodeFromFields(typeArgs[0], fields.nft), bid: decodeFromFields(Bid.reified(typeArgs[1]), fields.bid), concluded: decodeFromFields("bool", fields.concluded)}
        )
    }

    static fromFieldsWithTypes<T extends Reified<TypeArgument, any>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], item: FieldsWithTypes
    ): EnglishAuction<ToTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (!isEnglishAuction(item.type)) {
            throw new Error("not a EnglishAuction type");
        }
        assertFieldsWithTypesArgsMatch(item, typeArgs);

        return EnglishAuction.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {nft: decodeFromFieldsWithTypes(typeArgs[0], item.fields.nft), bid: decodeFromFieldsWithTypes(Bid.reified(typeArgs[1]), item.fields.bid), concluded: decodeFromFieldsWithTypes("bool", item.fields.concluded)}
        )
    }

    static fromBcs<T extends Reified<TypeArgument, any>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], data: Uint8Array
    ): EnglishAuction<ToTypeArgument<T>, ToPhantomTypeArgument<FT>> {

        return EnglishAuction.fromFields(
            typeArgs,
            EnglishAuction.bcs(toBcs(typeArgs[0])).parse(data)
        )
    }

    toJSONField() {
        return {
            nft: fieldToJSON<T>(this.$typeArgs[0], this.nft),bid: this.bid.toJSONField(),concluded: this.concluded,

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends Reified<TypeArgument, any>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], field: any
    ): EnglishAuction<ToTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return EnglishAuction.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {nft: decodeFromJSONField(typeArgs[0], field.nft), bid: decodeFromJSONField(Bid.reified(typeArgs[1]), field.bid), concluded: decodeFromJSONField("bool", field.concluded)}
        )
    }

    static fromJSON<T extends Reified<TypeArgument, any>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], json: Record<string, any>
    ): EnglishAuction<ToTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (json.$typeName !== EnglishAuction.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(EnglishAuction.$typeName,
            ...typeArgs.map(extractType)),
            json.$typeArgs,
            typeArgs,
        )

        return EnglishAuction.fromJSONField(
            typeArgs,
            json,
        )
    }

    static fromSuiParsedData<T extends Reified<TypeArgument, any>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], content: SuiParsedData
    ): EnglishAuction<ToTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isEnglishAuction(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a EnglishAuction object`);
        }
        return EnglishAuction.fromFieldsWithTypes(
            typeArgs,
            content
        );
    }

    static async fetch<T extends Reified<TypeArgument, any>, FT extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArgs: [T, FT], id: string
    ): Promise<EnglishAuction<ToTypeArgument<T>, ToPhantomTypeArgument<FT>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching EnglishAuction object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isEnglishAuction(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a EnglishAuction object`);
        }

        return EnglishAuction.fromBcs(
            typeArgs,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
