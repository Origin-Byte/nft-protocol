import * as reified from "../../_framework/reified";
import {String} from "../../_dependencies/source/0x1/ascii/structs";
import {Option} from "../../_dependencies/source/0x1/option/structs";
import {Balance} from "../../_dependencies/source/0x2/balance/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, Vector, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {CB} from "../../originmate/crit-bit-u64/structs";
import {AskCommission, BidCommission} from "../trading/structs";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Witness";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: WitnessFields,
    ) {
        this.$fullTypeName = Witness.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): WitnessReified {
        return {
            typeName: Witness.$typeName,
            fullTypeName: composeSuiType(
                Witness.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Witness",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Witness.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Witness.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Witness.fromBcs(
                    data,
                ),
            bcs: Witness.bcs,
            fromJSONField: (field: any) =>
                Witness.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Witness.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Witness.fetch(
                client,
                id,
            ),
            new: (
                fields: WitnessFields,
            ) => {
                return new Witness(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Witness.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Witness>> {
        return phantom(Witness.reified());
    }

    static get p() {
        return Witness.phantom()
    }

    static get bcs() {
        return bcs.struct("Witness", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Witness {
        return Witness.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Witness {
        if (!isWitness(item.type)) {
            throw new Error("not a Witness type");
        }

        return Witness.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Witness {

        return Witness.fromFields(
            Witness.bcs.parse(data)
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
    ): Witness {
        return Witness.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Witness {
        if (json.$typeName !== Witness.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Witness.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Witness {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWitness(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Witness object`);
        }
        return Witness.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Witness> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Witness object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWitness(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Witness object`);
        }

        return Witness.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Bid =============================== */

export function isBid(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Bid<");
}

export interface BidFields<FT extends PhantomTypeArgument> {
    offer: ToField<Balance<FT>>; owner: ToField<"address">; kiosk: ToField<ID>; commission: ToField<Option<BidCommission<FT>>>
}

export type BidReified<FT extends PhantomTypeArgument> = Reified<
    Bid<FT>,
    BidFields<FT>
>;

export class Bid<FT extends PhantomTypeArgument> {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Bid";
    static readonly $numTypeParams = 1;

    readonly $typeName = Bid.$typeName;

    readonly $fullTypeName: `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Bid<${PhantomToTypeStr<FT>}>`;

    readonly $typeArg: string;

    ;

    readonly offer:
        ToField<Balance<FT>>
    ; readonly owner:
        ToField<"address">
    ; readonly kiosk:
        ToField<ID>
    ; readonly commission:
        ToField<Option<BidCommission<FT>>>

    private constructor(typeArg: string, fields: BidFields<FT>,
    ) {
        this.$fullTypeName = composeSuiType(Bid.$typeName,
        typeArg) as `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Bid<${PhantomToTypeStr<FT>}>`;

        this.$typeArg = typeArg;

        this.offer = fields.offer;; this.owner = fields.owner;; this.kiosk = fields.kiosk;; this.commission = fields.commission;
    }

    static reified<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): BidReified<ToPhantomTypeArgument<FT>> {
        return {
            typeName: Bid.$typeName,
            fullTypeName: composeSuiType(
                Bid.$typeName,
                ...[extractType(FT)]
            ) as `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Bid<${PhantomToTypeStr<ToPhantomTypeArgument<FT>>}>`,
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
            offer:
                Balance.bcs
            , owner:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , kiosk:
                ID.bcs
            , commission:
                Option.bcs(BidCommission.bcs)

        })
    };

    static fromFields<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, fields: Record<string, any>
    ): Bid<ToPhantomTypeArgument<FT>> {
        return Bid.reified(
            typeArg,
        ).new(
            {offer: decodeFromFields(Balance.reified(typeArg), fields.offer), owner: decodeFromFields("address", fields.owner), kiosk: decodeFromFields(ID.reified(), fields.kiosk), commission: decodeFromFields(Option.reified(BidCommission.reified(typeArg)), fields.commission)}
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
            {offer: decodeFromFieldsWithTypes(Balance.reified(typeArg), item.fields.offer), owner: decodeFromFieldsWithTypes("address", item.fields.owner), kiosk: decodeFromFieldsWithTypes(ID.reified(), item.fields.kiosk), commission: decodeFromFieldsWithTypes(Option.reified(BidCommission.reified(typeArg)), item.fields.commission)}
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
            offer: this.offer.toJSONField(),owner: this.owner,kiosk: this.kiosk,commission: fieldToJSON<Option<BidCommission<FT>>>(`0x1::option::Option<0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::BidCommission<${this.$typeArg}>>`, this.commission),

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
            {offer: decodeFromJSONField(Balance.reified(typeArg), field.offer), owner: decodeFromJSONField("address", field.owner), kiosk: decodeFromJSONField(ID.reified(), field.kiosk), commission: decodeFromJSONField(Option.reified(BidCommission.reified(typeArg)), field.commission)}
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

/* ============================== BidClosedEvent =============================== */

export function isBidClosedEvent(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::BidClosedEvent";
}

export interface BidClosedEventFields {
    orderbook: ToField<ID>; owner: ToField<"address">; kiosk: ToField<ID>; price: ToField<"u64">; nftType: ToField<String>; ftType: ToField<String>
}

export type BidClosedEventReified = Reified<
    BidClosedEvent,
    BidClosedEventFields
>;

export class BidClosedEvent {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::BidClosedEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = BidClosedEvent.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::BidClosedEvent";

    ;

    readonly orderbook:
        ToField<ID>
    ; readonly owner:
        ToField<"address">
    ; readonly kiosk:
        ToField<ID>
    ; readonly price:
        ToField<"u64">
    ; readonly nftType:
        ToField<String>
    ; readonly ftType:
        ToField<String>

    private constructor( fields: BidClosedEventFields,
    ) {
        this.$fullTypeName = BidClosedEvent.$typeName;

        this.orderbook = fields.orderbook;; this.owner = fields.owner;; this.kiosk = fields.kiosk;; this.price = fields.price;; this.nftType = fields.nftType;; this.ftType = fields.ftType;
    }

    static reified(): BidClosedEventReified {
        return {
            typeName: BidClosedEvent.$typeName,
            fullTypeName: composeSuiType(
                BidClosedEvent.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::BidClosedEvent",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                BidClosedEvent.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                BidClosedEvent.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                BidClosedEvent.fromBcs(
                    data,
                ),
            bcs: BidClosedEvent.bcs,
            fromJSONField: (field: any) =>
                BidClosedEvent.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                BidClosedEvent.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => BidClosedEvent.fetch(
                client,
                id,
            ),
            new: (
                fields: BidClosedEventFields,
            ) => {
                return new BidClosedEvent(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return BidClosedEvent.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<BidClosedEvent>> {
        return phantom(BidClosedEvent.reified());
    }

    static get p() {
        return BidClosedEvent.phantom()
    }

    static get bcs() {
        return bcs.struct("BidClosedEvent", {
            orderbook:
                ID.bcs
            , owner:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , kiosk:
                ID.bcs
            , price:
                bcs.u64()
            , nft_type:
                String.bcs
            , ft_type:
                String.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): BidClosedEvent {
        return BidClosedEvent.reified().new(
            {orderbook: decodeFromFields(ID.reified(), fields.orderbook), owner: decodeFromFields("address", fields.owner), kiosk: decodeFromFields(ID.reified(), fields.kiosk), price: decodeFromFields("u64", fields.price), nftType: decodeFromFields(String.reified(), fields.nft_type), ftType: decodeFromFields(String.reified(), fields.ft_type)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): BidClosedEvent {
        if (!isBidClosedEvent(item.type)) {
            throw new Error("not a BidClosedEvent type");
        }

        return BidClosedEvent.reified().new(
            {orderbook: decodeFromFieldsWithTypes(ID.reified(), item.fields.orderbook), owner: decodeFromFieldsWithTypes("address", item.fields.owner), kiosk: decodeFromFieldsWithTypes(ID.reified(), item.fields.kiosk), price: decodeFromFieldsWithTypes("u64", item.fields.price), nftType: decodeFromFieldsWithTypes(String.reified(), item.fields.nft_type), ftType: decodeFromFieldsWithTypes(String.reified(), item.fields.ft_type)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): BidClosedEvent {

        return BidClosedEvent.fromFields(
            BidClosedEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            orderbook: this.orderbook,owner: this.owner,kiosk: this.kiosk,price: this.price.toString(),nftType: this.nftType,ftType: this.ftType,

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
    ): BidClosedEvent {
        return BidClosedEvent.reified().new(
            {orderbook: decodeFromJSONField(ID.reified(), field.orderbook), owner: decodeFromJSONField("address", field.owner), kiosk: decodeFromJSONField(ID.reified(), field.kiosk), price: decodeFromJSONField("u64", field.price), nftType: decodeFromJSONField(String.reified(), field.nftType), ftType: decodeFromJSONField(String.reified(), field.ftType)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): BidClosedEvent {
        if (json.$typeName !== BidClosedEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return BidClosedEvent.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): BidClosedEvent {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBidClosedEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a BidClosedEvent object`);
        }
        return BidClosedEvent.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<BidClosedEvent> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching BidClosedEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBidClosedEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a BidClosedEvent object`);
        }

        return BidClosedEvent.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== BidCreatedEvent =============================== */

export function isBidCreatedEvent(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::BidCreatedEvent";
}

export interface BidCreatedEventFields {
    orderbook: ToField<ID>; owner: ToField<"address">; price: ToField<"u64">; kiosk: ToField<ID>; nftType: ToField<String>; ftType: ToField<String>
}

export type BidCreatedEventReified = Reified<
    BidCreatedEvent,
    BidCreatedEventFields
>;

export class BidCreatedEvent {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::BidCreatedEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = BidCreatedEvent.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::BidCreatedEvent";

    ;

    readonly orderbook:
        ToField<ID>
    ; readonly owner:
        ToField<"address">
    ; readonly price:
        ToField<"u64">
    ; readonly kiosk:
        ToField<ID>
    ; readonly nftType:
        ToField<String>
    ; readonly ftType:
        ToField<String>

    private constructor( fields: BidCreatedEventFields,
    ) {
        this.$fullTypeName = BidCreatedEvent.$typeName;

        this.orderbook = fields.orderbook;; this.owner = fields.owner;; this.price = fields.price;; this.kiosk = fields.kiosk;; this.nftType = fields.nftType;; this.ftType = fields.ftType;
    }

    static reified(): BidCreatedEventReified {
        return {
            typeName: BidCreatedEvent.$typeName,
            fullTypeName: composeSuiType(
                BidCreatedEvent.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::BidCreatedEvent",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                BidCreatedEvent.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                BidCreatedEvent.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                BidCreatedEvent.fromBcs(
                    data,
                ),
            bcs: BidCreatedEvent.bcs,
            fromJSONField: (field: any) =>
                BidCreatedEvent.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                BidCreatedEvent.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => BidCreatedEvent.fetch(
                client,
                id,
            ),
            new: (
                fields: BidCreatedEventFields,
            ) => {
                return new BidCreatedEvent(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return BidCreatedEvent.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<BidCreatedEvent>> {
        return phantom(BidCreatedEvent.reified());
    }

    static get p() {
        return BidCreatedEvent.phantom()
    }

    static get bcs() {
        return bcs.struct("BidCreatedEvent", {
            orderbook:
                ID.bcs
            , owner:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , price:
                bcs.u64()
            , kiosk:
                ID.bcs
            , nft_type:
                String.bcs
            , ft_type:
                String.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): BidCreatedEvent {
        return BidCreatedEvent.reified().new(
            {orderbook: decodeFromFields(ID.reified(), fields.orderbook), owner: decodeFromFields("address", fields.owner), price: decodeFromFields("u64", fields.price), kiosk: decodeFromFields(ID.reified(), fields.kiosk), nftType: decodeFromFields(String.reified(), fields.nft_type), ftType: decodeFromFields(String.reified(), fields.ft_type)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): BidCreatedEvent {
        if (!isBidCreatedEvent(item.type)) {
            throw new Error("not a BidCreatedEvent type");
        }

        return BidCreatedEvent.reified().new(
            {orderbook: decodeFromFieldsWithTypes(ID.reified(), item.fields.orderbook), owner: decodeFromFieldsWithTypes("address", item.fields.owner), price: decodeFromFieldsWithTypes("u64", item.fields.price), kiosk: decodeFromFieldsWithTypes(ID.reified(), item.fields.kiosk), nftType: decodeFromFieldsWithTypes(String.reified(), item.fields.nft_type), ftType: decodeFromFieldsWithTypes(String.reified(), item.fields.ft_type)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): BidCreatedEvent {

        return BidCreatedEvent.fromFields(
            BidCreatedEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            orderbook: this.orderbook,owner: this.owner,price: this.price.toString(),kiosk: this.kiosk,nftType: this.nftType,ftType: this.ftType,

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
    ): BidCreatedEvent {
        return BidCreatedEvent.reified().new(
            {orderbook: decodeFromJSONField(ID.reified(), field.orderbook), owner: decodeFromJSONField("address", field.owner), price: decodeFromJSONField("u64", field.price), kiosk: decodeFromJSONField(ID.reified(), field.kiosk), nftType: decodeFromJSONField(String.reified(), field.nftType), ftType: decodeFromJSONField(String.reified(), field.ftType)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): BidCreatedEvent {
        if (json.$typeName !== BidCreatedEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return BidCreatedEvent.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): BidCreatedEvent {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBidCreatedEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a BidCreatedEvent object`);
        }
        return BidCreatedEvent.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<BidCreatedEvent> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching BidCreatedEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBidCreatedEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a BidCreatedEvent object`);
        }

        return BidCreatedEvent.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== AdministratorsDfKey =============================== */

export function isAdministratorsDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::AdministratorsDfKey";
}

export interface AdministratorsDfKeyFields {
    dummyField: ToField<"bool">
}

export type AdministratorsDfKeyReified = Reified<
    AdministratorsDfKey,
    AdministratorsDfKeyFields
>;

export class AdministratorsDfKey {
    static readonly $typeName = "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::AdministratorsDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = AdministratorsDfKey.$typeName;

    readonly $fullTypeName: "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::AdministratorsDfKey";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: AdministratorsDfKeyFields,
    ) {
        this.$fullTypeName = AdministratorsDfKey.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): AdministratorsDfKeyReified {
        return {
            typeName: AdministratorsDfKey.$typeName,
            fullTypeName: composeSuiType(
                AdministratorsDfKey.$typeName,
                ...[]
            ) as "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::AdministratorsDfKey",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                AdministratorsDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                AdministratorsDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                AdministratorsDfKey.fromBcs(
                    data,
                ),
            bcs: AdministratorsDfKey.bcs,
            fromJSONField: (field: any) =>
                AdministratorsDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                AdministratorsDfKey.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => AdministratorsDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: AdministratorsDfKeyFields,
            ) => {
                return new AdministratorsDfKey(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return AdministratorsDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<AdministratorsDfKey>> {
        return phantom(AdministratorsDfKey.reified());
    }

    static get p() {
        return AdministratorsDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("AdministratorsDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): AdministratorsDfKey {
        return AdministratorsDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): AdministratorsDfKey {
        if (!isAdministratorsDfKey(item.type)) {
            throw new Error("not a AdministratorsDfKey type");
        }

        return AdministratorsDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): AdministratorsDfKey {

        return AdministratorsDfKey.fromFields(
            AdministratorsDfKey.bcs.parse(data)
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
    ): AdministratorsDfKey {
        return AdministratorsDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): AdministratorsDfKey {
        if (json.$typeName !== AdministratorsDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return AdministratorsDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): AdministratorsDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAdministratorsDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a AdministratorsDfKey object`);
        }
        return AdministratorsDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<AdministratorsDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching AdministratorsDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAdministratorsDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a AdministratorsDfKey object`);
        }

        return AdministratorsDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Ask =============================== */

export function isAsk(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Ask";
}

export interface AskFields {
    price: ToField<"u64">; nftId: ToField<ID>; kioskId: ToField<ID>; owner: ToField<"address">; commission: ToField<Option<AskCommission>>
}

export type AskReified = Reified<
    Ask,
    AskFields
>;

export class Ask {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Ask";
    static readonly $numTypeParams = 0;

    readonly $typeName = Ask.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Ask";

    ;

    readonly price:
        ToField<"u64">
    ; readonly nftId:
        ToField<ID>
    ; readonly kioskId:
        ToField<ID>
    ; readonly owner:
        ToField<"address">
    ; readonly commission:
        ToField<Option<AskCommission>>

    private constructor( fields: AskFields,
    ) {
        this.$fullTypeName = Ask.$typeName;

        this.price = fields.price;; this.nftId = fields.nftId;; this.kioskId = fields.kioskId;; this.owner = fields.owner;; this.commission = fields.commission;
    }

    static reified(): AskReified {
        return {
            typeName: Ask.$typeName,
            fullTypeName: composeSuiType(
                Ask.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Ask",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Ask.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Ask.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Ask.fromBcs(
                    data,
                ),
            bcs: Ask.bcs,
            fromJSONField: (field: any) =>
                Ask.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Ask.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Ask.fetch(
                client,
                id,
            ),
            new: (
                fields: AskFields,
            ) => {
                return new Ask(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Ask.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Ask>> {
        return phantom(Ask.reified());
    }

    static get p() {
        return Ask.phantom()
    }

    static get bcs() {
        return bcs.struct("Ask", {
            price:
                bcs.u64()
            , nft_id:
                ID.bcs
            , kiosk_id:
                ID.bcs
            , owner:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , commission:
                Option.bcs(AskCommission.bcs)

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Ask {
        return Ask.reified().new(
            {price: decodeFromFields("u64", fields.price), nftId: decodeFromFields(ID.reified(), fields.nft_id), kioskId: decodeFromFields(ID.reified(), fields.kiosk_id), owner: decodeFromFields("address", fields.owner), commission: decodeFromFields(Option.reified(AskCommission.reified()), fields.commission)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Ask {
        if (!isAsk(item.type)) {
            throw new Error("not a Ask type");
        }

        return Ask.reified().new(
            {price: decodeFromFieldsWithTypes("u64", item.fields.price), nftId: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft_id), kioskId: decodeFromFieldsWithTypes(ID.reified(), item.fields.kiosk_id), owner: decodeFromFieldsWithTypes("address", item.fields.owner), commission: decodeFromFieldsWithTypes(Option.reified(AskCommission.reified()), item.fields.commission)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Ask {

        return Ask.fromFields(
            Ask.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            price: this.price.toString(),nftId: this.nftId,kioskId: this.kioskId,owner: this.owner,commission: fieldToJSON<Option<AskCommission>>(`0x1::option::Option<0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::AskCommission>`, this.commission),

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
    ): Ask {
        return Ask.reified().new(
            {price: decodeFromJSONField("u64", field.price), nftId: decodeFromJSONField(ID.reified(), field.nftId), kioskId: decodeFromJSONField(ID.reified(), field.kioskId), owner: decodeFromJSONField("address", field.owner), commission: decodeFromJSONField(Option.reified(AskCommission.reified()), field.commission)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Ask {
        if (json.$typeName !== Ask.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Ask.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Ask {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAsk(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Ask object`);
        }
        return Ask.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Ask> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Ask object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAsk(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Ask object`);
        }

        return Ask.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== AskClosedEvent =============================== */

export function isAskClosedEvent(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::AskClosedEvent";
}

export interface AskClosedEventFields {
    nft: ToField<ID>; orderbook: ToField<ID>; owner: ToField<"address">; price: ToField<"u64">; nftType: ToField<String>; ftType: ToField<String>
}

export type AskClosedEventReified = Reified<
    AskClosedEvent,
    AskClosedEventFields
>;

export class AskClosedEvent {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::AskClosedEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = AskClosedEvent.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::AskClosedEvent";

    ;

    readonly nft:
        ToField<ID>
    ; readonly orderbook:
        ToField<ID>
    ; readonly owner:
        ToField<"address">
    ; readonly price:
        ToField<"u64">
    ; readonly nftType:
        ToField<String>
    ; readonly ftType:
        ToField<String>

    private constructor( fields: AskClosedEventFields,
    ) {
        this.$fullTypeName = AskClosedEvent.$typeName;

        this.nft = fields.nft;; this.orderbook = fields.orderbook;; this.owner = fields.owner;; this.price = fields.price;; this.nftType = fields.nftType;; this.ftType = fields.ftType;
    }

    static reified(): AskClosedEventReified {
        return {
            typeName: AskClosedEvent.$typeName,
            fullTypeName: composeSuiType(
                AskClosedEvent.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::AskClosedEvent",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                AskClosedEvent.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                AskClosedEvent.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                AskClosedEvent.fromBcs(
                    data,
                ),
            bcs: AskClosedEvent.bcs,
            fromJSONField: (field: any) =>
                AskClosedEvent.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                AskClosedEvent.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => AskClosedEvent.fetch(
                client,
                id,
            ),
            new: (
                fields: AskClosedEventFields,
            ) => {
                return new AskClosedEvent(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return AskClosedEvent.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<AskClosedEvent>> {
        return phantom(AskClosedEvent.reified());
    }

    static get p() {
        return AskClosedEvent.phantom()
    }

    static get bcs() {
        return bcs.struct("AskClosedEvent", {
            nft:
                ID.bcs
            , orderbook:
                ID.bcs
            , owner:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , price:
                bcs.u64()
            , nft_type:
                String.bcs
            , ft_type:
                String.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): AskClosedEvent {
        return AskClosedEvent.reified().new(
            {nft: decodeFromFields(ID.reified(), fields.nft), orderbook: decodeFromFields(ID.reified(), fields.orderbook), owner: decodeFromFields("address", fields.owner), price: decodeFromFields("u64", fields.price), nftType: decodeFromFields(String.reified(), fields.nft_type), ftType: decodeFromFields(String.reified(), fields.ft_type)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): AskClosedEvent {
        if (!isAskClosedEvent(item.type)) {
            throw new Error("not a AskClosedEvent type");
        }

        return AskClosedEvent.reified().new(
            {nft: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft), orderbook: decodeFromFieldsWithTypes(ID.reified(), item.fields.orderbook), owner: decodeFromFieldsWithTypes("address", item.fields.owner), price: decodeFromFieldsWithTypes("u64", item.fields.price), nftType: decodeFromFieldsWithTypes(String.reified(), item.fields.nft_type), ftType: decodeFromFieldsWithTypes(String.reified(), item.fields.ft_type)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): AskClosedEvent {

        return AskClosedEvent.fromFields(
            AskClosedEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            nft: this.nft,orderbook: this.orderbook,owner: this.owner,price: this.price.toString(),nftType: this.nftType,ftType: this.ftType,

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
    ): AskClosedEvent {
        return AskClosedEvent.reified().new(
            {nft: decodeFromJSONField(ID.reified(), field.nft), orderbook: decodeFromJSONField(ID.reified(), field.orderbook), owner: decodeFromJSONField("address", field.owner), price: decodeFromJSONField("u64", field.price), nftType: decodeFromJSONField(String.reified(), field.nftType), ftType: decodeFromJSONField(String.reified(), field.ftType)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): AskClosedEvent {
        if (json.$typeName !== AskClosedEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return AskClosedEvent.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): AskClosedEvent {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAskClosedEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a AskClosedEvent object`);
        }
        return AskClosedEvent.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<AskClosedEvent> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching AskClosedEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAskClosedEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a AskClosedEvent object`);
        }

        return AskClosedEvent.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== AskCreatedEvent =============================== */

export function isAskCreatedEvent(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::AskCreatedEvent";
}

export interface AskCreatedEventFields {
    nft: ToField<ID>; orderbook: ToField<ID>; owner: ToField<"address">; price: ToField<"u64">; kiosk: ToField<ID>; nftType: ToField<String>; ftType: ToField<String>
}

export type AskCreatedEventReified = Reified<
    AskCreatedEvent,
    AskCreatedEventFields
>;

export class AskCreatedEvent {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::AskCreatedEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = AskCreatedEvent.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::AskCreatedEvent";

    ;

    readonly nft:
        ToField<ID>
    ; readonly orderbook:
        ToField<ID>
    ; readonly owner:
        ToField<"address">
    ; readonly price:
        ToField<"u64">
    ; readonly kiosk:
        ToField<ID>
    ; readonly nftType:
        ToField<String>
    ; readonly ftType:
        ToField<String>

    private constructor( fields: AskCreatedEventFields,
    ) {
        this.$fullTypeName = AskCreatedEvent.$typeName;

        this.nft = fields.nft;; this.orderbook = fields.orderbook;; this.owner = fields.owner;; this.price = fields.price;; this.kiosk = fields.kiosk;; this.nftType = fields.nftType;; this.ftType = fields.ftType;
    }

    static reified(): AskCreatedEventReified {
        return {
            typeName: AskCreatedEvent.$typeName,
            fullTypeName: composeSuiType(
                AskCreatedEvent.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::AskCreatedEvent",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                AskCreatedEvent.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                AskCreatedEvent.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                AskCreatedEvent.fromBcs(
                    data,
                ),
            bcs: AskCreatedEvent.bcs,
            fromJSONField: (field: any) =>
                AskCreatedEvent.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                AskCreatedEvent.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => AskCreatedEvent.fetch(
                client,
                id,
            ),
            new: (
                fields: AskCreatedEventFields,
            ) => {
                return new AskCreatedEvent(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return AskCreatedEvent.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<AskCreatedEvent>> {
        return phantom(AskCreatedEvent.reified());
    }

    static get p() {
        return AskCreatedEvent.phantom()
    }

    static get bcs() {
        return bcs.struct("AskCreatedEvent", {
            nft:
                ID.bcs
            , orderbook:
                ID.bcs
            , owner:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , price:
                bcs.u64()
            , kiosk:
                ID.bcs
            , nft_type:
                String.bcs
            , ft_type:
                String.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): AskCreatedEvent {
        return AskCreatedEvent.reified().new(
            {nft: decodeFromFields(ID.reified(), fields.nft), orderbook: decodeFromFields(ID.reified(), fields.orderbook), owner: decodeFromFields("address", fields.owner), price: decodeFromFields("u64", fields.price), kiosk: decodeFromFields(ID.reified(), fields.kiosk), nftType: decodeFromFields(String.reified(), fields.nft_type), ftType: decodeFromFields(String.reified(), fields.ft_type)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): AskCreatedEvent {
        if (!isAskCreatedEvent(item.type)) {
            throw new Error("not a AskCreatedEvent type");
        }

        return AskCreatedEvent.reified().new(
            {nft: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft), orderbook: decodeFromFieldsWithTypes(ID.reified(), item.fields.orderbook), owner: decodeFromFieldsWithTypes("address", item.fields.owner), price: decodeFromFieldsWithTypes("u64", item.fields.price), kiosk: decodeFromFieldsWithTypes(ID.reified(), item.fields.kiosk), nftType: decodeFromFieldsWithTypes(String.reified(), item.fields.nft_type), ftType: decodeFromFieldsWithTypes(String.reified(), item.fields.ft_type)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): AskCreatedEvent {

        return AskCreatedEvent.fromFields(
            AskCreatedEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            nft: this.nft,orderbook: this.orderbook,owner: this.owner,price: this.price.toString(),kiosk: this.kiosk,nftType: this.nftType,ftType: this.ftType,

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
    ): AskCreatedEvent {
        return AskCreatedEvent.reified().new(
            {nft: decodeFromJSONField(ID.reified(), field.nft), orderbook: decodeFromJSONField(ID.reified(), field.orderbook), owner: decodeFromJSONField("address", field.owner), price: decodeFromJSONField("u64", field.price), kiosk: decodeFromJSONField(ID.reified(), field.kiosk), nftType: decodeFromJSONField(String.reified(), field.nftType), ftType: decodeFromJSONField(String.reified(), field.ftType)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): AskCreatedEvent {
        if (json.$typeName !== AskCreatedEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return AskCreatedEvent.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): AskCreatedEvent {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAskCreatedEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a AskCreatedEvent object`);
        }
        return AskCreatedEvent.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<AskCreatedEvent> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching AskCreatedEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAskCreatedEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a AskCreatedEvent object`);
        }

        return AskCreatedEvent.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== IsDeprecatedDfKey =============================== */

export function isIsDeprecatedDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::IsDeprecatedDfKey";
}

export interface IsDeprecatedDfKeyFields {
    dummyField: ToField<"bool">
}

export type IsDeprecatedDfKeyReified = Reified<
    IsDeprecatedDfKey,
    IsDeprecatedDfKeyFields
>;

export class IsDeprecatedDfKey {
    static readonly $typeName = "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::IsDeprecatedDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = IsDeprecatedDfKey.$typeName;

    readonly $fullTypeName: "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::IsDeprecatedDfKey";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: IsDeprecatedDfKeyFields,
    ) {
        this.$fullTypeName = IsDeprecatedDfKey.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): IsDeprecatedDfKeyReified {
        return {
            typeName: IsDeprecatedDfKey.$typeName,
            fullTypeName: composeSuiType(
                IsDeprecatedDfKey.$typeName,
                ...[]
            ) as "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::IsDeprecatedDfKey",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                IsDeprecatedDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                IsDeprecatedDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                IsDeprecatedDfKey.fromBcs(
                    data,
                ),
            bcs: IsDeprecatedDfKey.bcs,
            fromJSONField: (field: any) =>
                IsDeprecatedDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                IsDeprecatedDfKey.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => IsDeprecatedDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: IsDeprecatedDfKeyFields,
            ) => {
                return new IsDeprecatedDfKey(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return IsDeprecatedDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<IsDeprecatedDfKey>> {
        return phantom(IsDeprecatedDfKey.reified());
    }

    static get p() {
        return IsDeprecatedDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("IsDeprecatedDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): IsDeprecatedDfKey {
        return IsDeprecatedDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): IsDeprecatedDfKey {
        if (!isIsDeprecatedDfKey(item.type)) {
            throw new Error("not a IsDeprecatedDfKey type");
        }

        return IsDeprecatedDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): IsDeprecatedDfKey {

        return IsDeprecatedDfKey.fromFields(
            IsDeprecatedDfKey.bcs.parse(data)
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
    ): IsDeprecatedDfKey {
        return IsDeprecatedDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): IsDeprecatedDfKey {
        if (json.$typeName !== IsDeprecatedDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return IsDeprecatedDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): IsDeprecatedDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isIsDeprecatedDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a IsDeprecatedDfKey object`);
        }
        return IsDeprecatedDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<IsDeprecatedDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching IsDeprecatedDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isIsDeprecatedDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a IsDeprecatedDfKey object`);
        }

        return IsDeprecatedDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Orderbook =============================== */

export function isOrderbook(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Orderbook<");
}

export interface OrderbookFields<T extends PhantomTypeArgument, FT extends PhantomTypeArgument> {
    id: ToField<UID>; version: ToField<"u64">; tickSize: ToField<"u64">; protectedActions: ToField<WitnessProtectedActions>; asks: ToField<CB<Vector<Ask>>>; bids: ToField<CB<Vector<Bid<FT>>>>
}

export type OrderbookReified<T extends PhantomTypeArgument, FT extends PhantomTypeArgument> = Reified<
    Orderbook<T, FT>,
    OrderbookFields<T, FT>
>;

export class Orderbook<T extends PhantomTypeArgument, FT extends PhantomTypeArgument> {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Orderbook";
    static readonly $numTypeParams = 2;

    readonly $typeName = Orderbook.$typeName;

    readonly $fullTypeName: `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Orderbook<${PhantomToTypeStr<T>}, ${PhantomToTypeStr<FT>}>`;

    readonly $typeArgs: [string, string];

    ;

    readonly id:
        ToField<UID>
    ; readonly version:
        ToField<"u64">
    ; readonly tickSize:
        ToField<"u64">
    ; readonly protectedActions:
        ToField<WitnessProtectedActions>
    ; readonly asks:
        ToField<CB<Vector<Ask>>>
    ; readonly bids:
        ToField<CB<Vector<Bid<FT>>>>

    private constructor(typeArgs: [string, string], fields: OrderbookFields<T, FT>,
    ) {
        this.$fullTypeName = composeSuiType(Orderbook.$typeName,
        ...typeArgs) as `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Orderbook<${PhantomToTypeStr<T>}, ${PhantomToTypeStr<FT>}>`;

        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.version = fields.version;; this.tickSize = fields.tickSize;; this.protectedActions = fields.protectedActions;; this.asks = fields.asks;; this.bids = fields.bids;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        T: T, FT: FT
    ): OrderbookReified<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return {
            typeName: Orderbook.$typeName,
            fullTypeName: composeSuiType(
                Orderbook.$typeName,
                ...[extractType(T), extractType(FT)]
            ) as `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::Orderbook<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}, ${PhantomToTypeStr<ToPhantomTypeArgument<FT>>}>`,
            typeArgs: [T, FT],
            fromFields: (fields: Record<string, any>) =>
                Orderbook.fromFields(
                    [T, FT],
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Orderbook.fromFieldsWithTypes(
                    [T, FT],
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Orderbook.fromBcs(
                    [T, FT],
                    data,
                ),
            bcs: Orderbook.bcs,
            fromJSONField: (field: any) =>
                Orderbook.fromJSONField(
                    [T, FT],
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Orderbook.fromJSON(
                    [T, FT],
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Orderbook.fetch(
                client,
                [T, FT],
                id,
            ),
            new: (
                fields: OrderbookFields<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>>,
            ) => {
                return new Orderbook(
                    [extractType(T), extractType(FT)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Orderbook.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        T: T, FT: FT
    ): PhantomReified<ToTypeStr<Orderbook<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>>>> {
        return phantom(Orderbook.reified(
            T, FT
        ));
    }

    static get p() {
        return Orderbook.phantom
    }

    static get bcs() {
        return bcs.struct("Orderbook", {
            id:
                UID.bcs
            , version:
                bcs.u64()
            , tick_size:
                bcs.u64()
            , protected_actions:
                WitnessProtectedActions.bcs
            , asks:
                CB.bcs(bcs.vector(Ask.bcs))
            , bids:
                CB.bcs(bcs.vector(Bid.bcs))

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], fields: Record<string, any>
    ): Orderbook<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return Orderbook.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), version: decodeFromFields("u64", fields.version), tickSize: decodeFromFields("u64", fields.tick_size), protectedActions: decodeFromFields(WitnessProtectedActions.reified(), fields.protected_actions), asks: decodeFromFields(CB.reified(reified.vector(Ask.reified())), fields.asks), bids: decodeFromFields(CB.reified(reified.vector(Bid.reified(typeArgs[1]))), fields.bids)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], item: FieldsWithTypes
    ): Orderbook<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (!isOrderbook(item.type)) {
            throw new Error("not a Orderbook type");
        }
        assertFieldsWithTypesArgsMatch(item, typeArgs);

        return Orderbook.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), version: decodeFromFieldsWithTypes("u64", item.fields.version), tickSize: decodeFromFieldsWithTypes("u64", item.fields.tick_size), protectedActions: decodeFromFieldsWithTypes(WitnessProtectedActions.reified(), item.fields.protected_actions), asks: decodeFromFieldsWithTypes(CB.reified(reified.vector(Ask.reified())), item.fields.asks), bids: decodeFromFieldsWithTypes(CB.reified(reified.vector(Bid.reified(typeArgs[1]))), item.fields.bids)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], data: Uint8Array
    ): Orderbook<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {

        return Orderbook.fromFields(
            typeArgs,
            Orderbook.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,version: this.version.toString(),tickSize: this.tickSize.toString(),protectedActions: this.protectedActions.toJSONField(),asks: this.asks.toJSONField(),bids: this.bids.toJSONField(),

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
    ): Orderbook<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return Orderbook.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), version: decodeFromJSONField("u64", field.version), tickSize: decodeFromJSONField("u64", field.tickSize), protectedActions: decodeFromJSONField(WitnessProtectedActions.reified(), field.protectedActions), asks: decodeFromJSONField(CB.reified(reified.vector(Ask.reified())), field.asks), bids: decodeFromJSONField(CB.reified(reified.vector(Bid.reified(typeArgs[1]))), field.bids)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], json: Record<string, any>
    ): Orderbook<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (json.$typeName !== Orderbook.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Orderbook.$typeName,
            ...typeArgs.map(extractType)),
            json.$typeArgs,
            typeArgs,
        )

        return Orderbook.fromJSONField(
            typeArgs,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], content: SuiParsedData
    ): Orderbook<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isOrderbook(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Orderbook object`);
        }
        return Orderbook.fromFieldsWithTypes(
            typeArgs,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArgs: [T, FT], id: string
    ): Promise<Orderbook<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Orderbook object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isOrderbook(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Orderbook object`);
        }

        return Orderbook.fromBcs(
            typeArgs,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== OrderbookCreatedEvent =============================== */

export function isOrderbookCreatedEvent(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::OrderbookCreatedEvent";
}

export interface OrderbookCreatedEventFields {
    orderbook: ToField<ID>; nftType: ToField<String>; ftType: ToField<String>
}

export type OrderbookCreatedEventReified = Reified<
    OrderbookCreatedEvent,
    OrderbookCreatedEventFields
>;

export class OrderbookCreatedEvent {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::OrderbookCreatedEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = OrderbookCreatedEvent.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::OrderbookCreatedEvent";

    ;

    readonly orderbook:
        ToField<ID>
    ; readonly nftType:
        ToField<String>
    ; readonly ftType:
        ToField<String>

    private constructor( fields: OrderbookCreatedEventFields,
    ) {
        this.$fullTypeName = OrderbookCreatedEvent.$typeName;

        this.orderbook = fields.orderbook;; this.nftType = fields.nftType;; this.ftType = fields.ftType;
    }

    static reified(): OrderbookCreatedEventReified {
        return {
            typeName: OrderbookCreatedEvent.$typeName,
            fullTypeName: composeSuiType(
                OrderbookCreatedEvent.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::OrderbookCreatedEvent",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                OrderbookCreatedEvent.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                OrderbookCreatedEvent.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                OrderbookCreatedEvent.fromBcs(
                    data,
                ),
            bcs: OrderbookCreatedEvent.bcs,
            fromJSONField: (field: any) =>
                OrderbookCreatedEvent.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                OrderbookCreatedEvent.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => OrderbookCreatedEvent.fetch(
                client,
                id,
            ),
            new: (
                fields: OrderbookCreatedEventFields,
            ) => {
                return new OrderbookCreatedEvent(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return OrderbookCreatedEvent.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<OrderbookCreatedEvent>> {
        return phantom(OrderbookCreatedEvent.reified());
    }

    static get p() {
        return OrderbookCreatedEvent.phantom()
    }

    static get bcs() {
        return bcs.struct("OrderbookCreatedEvent", {
            orderbook:
                ID.bcs
            , nft_type:
                String.bcs
            , ft_type:
                String.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): OrderbookCreatedEvent {
        return OrderbookCreatedEvent.reified().new(
            {orderbook: decodeFromFields(ID.reified(), fields.orderbook), nftType: decodeFromFields(String.reified(), fields.nft_type), ftType: decodeFromFields(String.reified(), fields.ft_type)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): OrderbookCreatedEvent {
        if (!isOrderbookCreatedEvent(item.type)) {
            throw new Error("not a OrderbookCreatedEvent type");
        }

        return OrderbookCreatedEvent.reified().new(
            {orderbook: decodeFromFieldsWithTypes(ID.reified(), item.fields.orderbook), nftType: decodeFromFieldsWithTypes(String.reified(), item.fields.nft_type), ftType: decodeFromFieldsWithTypes(String.reified(), item.fields.ft_type)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): OrderbookCreatedEvent {

        return OrderbookCreatedEvent.fromFields(
            OrderbookCreatedEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            orderbook: this.orderbook,nftType: this.nftType,ftType: this.ftType,

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
    ): OrderbookCreatedEvent {
        return OrderbookCreatedEvent.reified().new(
            {orderbook: decodeFromJSONField(ID.reified(), field.orderbook), nftType: decodeFromJSONField(String.reified(), field.nftType), ftType: decodeFromJSONField(String.reified(), field.ftType)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): OrderbookCreatedEvent {
        if (json.$typeName !== OrderbookCreatedEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return OrderbookCreatedEvent.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): OrderbookCreatedEvent {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isOrderbookCreatedEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a OrderbookCreatedEvent object`);
        }
        return OrderbookCreatedEvent.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<OrderbookCreatedEvent> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching OrderbookCreatedEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isOrderbookCreatedEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a OrderbookCreatedEvent object`);
        }

        return OrderbookCreatedEvent.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== TimeLockDfKey =============================== */

export function isTimeLockDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::TimeLockDfKey";
}

export interface TimeLockDfKeyFields {
    dummyField: ToField<"bool">
}

export type TimeLockDfKeyReified = Reified<
    TimeLockDfKey,
    TimeLockDfKeyFields
>;

export class TimeLockDfKey {
    static readonly $typeName = "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::TimeLockDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = TimeLockDfKey.$typeName;

    readonly $fullTypeName: "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::TimeLockDfKey";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: TimeLockDfKeyFields,
    ) {
        this.$fullTypeName = TimeLockDfKey.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): TimeLockDfKeyReified {
        return {
            typeName: TimeLockDfKey.$typeName,
            fullTypeName: composeSuiType(
                TimeLockDfKey.$typeName,
                ...[]
            ) as "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::TimeLockDfKey",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                TimeLockDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TimeLockDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TimeLockDfKey.fromBcs(
                    data,
                ),
            bcs: TimeLockDfKey.bcs,
            fromJSONField: (field: any) =>
                TimeLockDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TimeLockDfKey.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => TimeLockDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: TimeLockDfKeyFields,
            ) => {
                return new TimeLockDfKey(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TimeLockDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<TimeLockDfKey>> {
        return phantom(TimeLockDfKey.reified());
    }

    static get p() {
        return TimeLockDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("TimeLockDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): TimeLockDfKey {
        return TimeLockDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): TimeLockDfKey {
        if (!isTimeLockDfKey(item.type)) {
            throw new Error("not a TimeLockDfKey type");
        }

        return TimeLockDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): TimeLockDfKey {

        return TimeLockDfKey.fromFields(
            TimeLockDfKey.bcs.parse(data)
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
    ): TimeLockDfKey {
        return TimeLockDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): TimeLockDfKey {
        if (json.$typeName !== TimeLockDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return TimeLockDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): TimeLockDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTimeLockDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TimeLockDfKey object`);
        }
        return TimeLockDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<TimeLockDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TimeLockDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTimeLockDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TimeLockDfKey object`);
        }

        return TimeLockDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== TradeFilledEvent =============================== */

export function isTradeFilledEvent(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeFilledEvent";
}

export interface TradeFilledEventFields {
    buyerKiosk: ToField<ID>; buyer: ToField<"address">; nft: ToField<ID>; orderbook: ToField<ID>; price: ToField<"u64">; sellerKiosk: ToField<ID>; seller: ToField<"address">; tradeIntermediate: ToField<Option<ID>>; nftType: ToField<String>; ftType: ToField<String>
}

export type TradeFilledEventReified = Reified<
    TradeFilledEvent,
    TradeFilledEventFields
>;

export class TradeFilledEvent {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeFilledEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = TradeFilledEvent.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeFilledEvent";

    ;

    readonly buyerKiosk:
        ToField<ID>
    ; readonly buyer:
        ToField<"address">
    ; readonly nft:
        ToField<ID>
    ; readonly orderbook:
        ToField<ID>
    ; readonly price:
        ToField<"u64">
    ; readonly sellerKiosk:
        ToField<ID>
    ; readonly seller:
        ToField<"address">
    ; readonly tradeIntermediate:
        ToField<Option<ID>>
    ; readonly nftType:
        ToField<String>
    ; readonly ftType:
        ToField<String>

    private constructor( fields: TradeFilledEventFields,
    ) {
        this.$fullTypeName = TradeFilledEvent.$typeName;

        this.buyerKiosk = fields.buyerKiosk;; this.buyer = fields.buyer;; this.nft = fields.nft;; this.orderbook = fields.orderbook;; this.price = fields.price;; this.sellerKiosk = fields.sellerKiosk;; this.seller = fields.seller;; this.tradeIntermediate = fields.tradeIntermediate;; this.nftType = fields.nftType;; this.ftType = fields.ftType;
    }

    static reified(): TradeFilledEventReified {
        return {
            typeName: TradeFilledEvent.$typeName,
            fullTypeName: composeSuiType(
                TradeFilledEvent.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeFilledEvent",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                TradeFilledEvent.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TradeFilledEvent.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TradeFilledEvent.fromBcs(
                    data,
                ),
            bcs: TradeFilledEvent.bcs,
            fromJSONField: (field: any) =>
                TradeFilledEvent.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TradeFilledEvent.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => TradeFilledEvent.fetch(
                client,
                id,
            ),
            new: (
                fields: TradeFilledEventFields,
            ) => {
                return new TradeFilledEvent(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TradeFilledEvent.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<TradeFilledEvent>> {
        return phantom(TradeFilledEvent.reified());
    }

    static get p() {
        return TradeFilledEvent.phantom()
    }

    static get bcs() {
        return bcs.struct("TradeFilledEvent", {
            buyer_kiosk:
                ID.bcs
            , buyer:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , nft:
                ID.bcs
            , orderbook:
                ID.bcs
            , price:
                bcs.u64()
            , seller_kiosk:
                ID.bcs
            , seller:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , trade_intermediate:
                Option.bcs(ID.bcs)
            , nft_type:
                String.bcs
            , ft_type:
                String.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): TradeFilledEvent {
        return TradeFilledEvent.reified().new(
            {buyerKiosk: decodeFromFields(ID.reified(), fields.buyer_kiosk), buyer: decodeFromFields("address", fields.buyer), nft: decodeFromFields(ID.reified(), fields.nft), orderbook: decodeFromFields(ID.reified(), fields.orderbook), price: decodeFromFields("u64", fields.price), sellerKiosk: decodeFromFields(ID.reified(), fields.seller_kiosk), seller: decodeFromFields("address", fields.seller), tradeIntermediate: decodeFromFields(Option.reified(ID.reified()), fields.trade_intermediate), nftType: decodeFromFields(String.reified(), fields.nft_type), ftType: decodeFromFields(String.reified(), fields.ft_type)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): TradeFilledEvent {
        if (!isTradeFilledEvent(item.type)) {
            throw new Error("not a TradeFilledEvent type");
        }

        return TradeFilledEvent.reified().new(
            {buyerKiosk: decodeFromFieldsWithTypes(ID.reified(), item.fields.buyer_kiosk), buyer: decodeFromFieldsWithTypes("address", item.fields.buyer), nft: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft), orderbook: decodeFromFieldsWithTypes(ID.reified(), item.fields.orderbook), price: decodeFromFieldsWithTypes("u64", item.fields.price), sellerKiosk: decodeFromFieldsWithTypes(ID.reified(), item.fields.seller_kiosk), seller: decodeFromFieldsWithTypes("address", item.fields.seller), tradeIntermediate: decodeFromFieldsWithTypes(Option.reified(ID.reified()), item.fields.trade_intermediate), nftType: decodeFromFieldsWithTypes(String.reified(), item.fields.nft_type), ftType: decodeFromFieldsWithTypes(String.reified(), item.fields.ft_type)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): TradeFilledEvent {

        return TradeFilledEvent.fromFields(
            TradeFilledEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            buyerKiosk: this.buyerKiosk,buyer: this.buyer,nft: this.nft,orderbook: this.orderbook,price: this.price.toString(),sellerKiosk: this.sellerKiosk,seller: this.seller,tradeIntermediate: fieldToJSON<Option<ID>>(`0x1::option::Option<0x2::object::ID>`, this.tradeIntermediate),nftType: this.nftType,ftType: this.ftType,

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
    ): TradeFilledEvent {
        return TradeFilledEvent.reified().new(
            {buyerKiosk: decodeFromJSONField(ID.reified(), field.buyerKiosk), buyer: decodeFromJSONField("address", field.buyer), nft: decodeFromJSONField(ID.reified(), field.nft), orderbook: decodeFromJSONField(ID.reified(), field.orderbook), price: decodeFromJSONField("u64", field.price), sellerKiosk: decodeFromJSONField(ID.reified(), field.sellerKiosk), seller: decodeFromJSONField("address", field.seller), tradeIntermediate: decodeFromJSONField(Option.reified(ID.reified()), field.tradeIntermediate), nftType: decodeFromJSONField(String.reified(), field.nftType), ftType: decodeFromJSONField(String.reified(), field.ftType)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): TradeFilledEvent {
        if (json.$typeName !== TradeFilledEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return TradeFilledEvent.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): TradeFilledEvent {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTradeFilledEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TradeFilledEvent object`);
        }
        return TradeFilledEvent.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<TradeFilledEvent> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TradeFilledEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTradeFilledEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TradeFilledEvent object`);
        }

        return TradeFilledEvent.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== TradeInfo =============================== */

export function isTradeInfo(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeInfo";
}

export interface TradeInfoFields {
    tradePrice: ToField<"u64">; tradeId: ToField<ID>
}

export type TradeInfoReified = Reified<
    TradeInfo,
    TradeInfoFields
>;

export class TradeInfo {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeInfo";
    static readonly $numTypeParams = 0;

    readonly $typeName = TradeInfo.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeInfo";

    ;

    readonly tradePrice:
        ToField<"u64">
    ; readonly tradeId:
        ToField<ID>

    private constructor( fields: TradeInfoFields,
    ) {
        this.$fullTypeName = TradeInfo.$typeName;

        this.tradePrice = fields.tradePrice;; this.tradeId = fields.tradeId;
    }

    static reified(): TradeInfoReified {
        return {
            typeName: TradeInfo.$typeName,
            fullTypeName: composeSuiType(
                TradeInfo.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeInfo",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                TradeInfo.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TradeInfo.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TradeInfo.fromBcs(
                    data,
                ),
            bcs: TradeInfo.bcs,
            fromJSONField: (field: any) =>
                TradeInfo.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TradeInfo.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => TradeInfo.fetch(
                client,
                id,
            ),
            new: (
                fields: TradeInfoFields,
            ) => {
                return new TradeInfo(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TradeInfo.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<TradeInfo>> {
        return phantom(TradeInfo.reified());
    }

    static get p() {
        return TradeInfo.phantom()
    }

    static get bcs() {
        return bcs.struct("TradeInfo", {
            trade_price:
                bcs.u64()
            , trade_id:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): TradeInfo {
        return TradeInfo.reified().new(
            {tradePrice: decodeFromFields("u64", fields.trade_price), tradeId: decodeFromFields(ID.reified(), fields.trade_id)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): TradeInfo {
        if (!isTradeInfo(item.type)) {
            throw new Error("not a TradeInfo type");
        }

        return TradeInfo.reified().new(
            {tradePrice: decodeFromFieldsWithTypes("u64", item.fields.trade_price), tradeId: decodeFromFieldsWithTypes(ID.reified(), item.fields.trade_id)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): TradeInfo {

        return TradeInfo.fromFields(
            TradeInfo.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            tradePrice: this.tradePrice.toString(),tradeId: this.tradeId,

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
    ): TradeInfo {
        return TradeInfo.reified().new(
            {tradePrice: decodeFromJSONField("u64", field.tradePrice), tradeId: decodeFromJSONField(ID.reified(), field.tradeId)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): TradeInfo {
        if (json.$typeName !== TradeInfo.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return TradeInfo.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): TradeInfo {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTradeInfo(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TradeInfo object`);
        }
        return TradeInfo.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<TradeInfo> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TradeInfo object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTradeInfo(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TradeInfo object`);
        }

        return TradeInfo.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== TradeIntermediate =============================== */

export function isTradeIntermediate(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeIntermediate<");
}

export interface TradeIntermediateFields<T extends PhantomTypeArgument, FT extends PhantomTypeArgument> {
    id: ToField<UID>; nftId: ToField<ID>; seller: ToField<"address">; sellerKiosk: ToField<ID>; buyer: ToField<"address">; buyerKiosk: ToField<ID>; paid: ToField<Balance<FT>>; commission: ToField<Option<AskCommission>>
}

export type TradeIntermediateReified<T extends PhantomTypeArgument, FT extends PhantomTypeArgument> = Reified<
    TradeIntermediate<T, FT>,
    TradeIntermediateFields<T, FT>
>;

export class TradeIntermediate<T extends PhantomTypeArgument, FT extends PhantomTypeArgument> {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeIntermediate";
    static readonly $numTypeParams = 2;

    readonly $typeName = TradeIntermediate.$typeName;

    readonly $fullTypeName: `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeIntermediate<${PhantomToTypeStr<T>}, ${PhantomToTypeStr<FT>}>`;

    readonly $typeArgs: [string, string];

    ;

    readonly id:
        ToField<UID>
    ; readonly nftId:
        ToField<ID>
    ; readonly seller:
        ToField<"address">
    ; readonly sellerKiosk:
        ToField<ID>
    ; readonly buyer:
        ToField<"address">
    ; readonly buyerKiosk:
        ToField<ID>
    ; readonly paid:
        ToField<Balance<FT>>
    ; readonly commission:
        ToField<Option<AskCommission>>

    private constructor(typeArgs: [string, string], fields: TradeIntermediateFields<T, FT>,
    ) {
        this.$fullTypeName = composeSuiType(TradeIntermediate.$typeName,
        ...typeArgs) as `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeIntermediate<${PhantomToTypeStr<T>}, ${PhantomToTypeStr<FT>}>`;

        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.nftId = fields.nftId;; this.seller = fields.seller;; this.sellerKiosk = fields.sellerKiosk;; this.buyer = fields.buyer;; this.buyerKiosk = fields.buyerKiosk;; this.paid = fields.paid;; this.commission = fields.commission;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        T: T, FT: FT
    ): TradeIntermediateReified<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return {
            typeName: TradeIntermediate.$typeName,
            fullTypeName: composeSuiType(
                TradeIntermediate.$typeName,
                ...[extractType(T), extractType(FT)]
            ) as `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeIntermediate<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}, ${PhantomToTypeStr<ToPhantomTypeArgument<FT>>}>`,
            typeArgs: [T, FT],
            fromFields: (fields: Record<string, any>) =>
                TradeIntermediate.fromFields(
                    [T, FT],
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TradeIntermediate.fromFieldsWithTypes(
                    [T, FT],
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TradeIntermediate.fromBcs(
                    [T, FT],
                    data,
                ),
            bcs: TradeIntermediate.bcs,
            fromJSONField: (field: any) =>
                TradeIntermediate.fromJSONField(
                    [T, FT],
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TradeIntermediate.fromJSON(
                    [T, FT],
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => TradeIntermediate.fetch(
                client,
                [T, FT],
                id,
            ),
            new: (
                fields: TradeIntermediateFields<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>>,
            ) => {
                return new TradeIntermediate(
                    [extractType(T), extractType(FT)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TradeIntermediate.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        T: T, FT: FT
    ): PhantomReified<ToTypeStr<TradeIntermediate<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>>>> {
        return phantom(TradeIntermediate.reified(
            T, FT
        ));
    }

    static get p() {
        return TradeIntermediate.phantom
    }

    static get bcs() {
        return bcs.struct("TradeIntermediate", {
            id:
                UID.bcs
            , nft_id:
                ID.bcs
            , seller:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , seller_kiosk:
                ID.bcs
            , buyer:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , buyer_kiosk:
                ID.bcs
            , paid:
                Balance.bcs
            , commission:
                Option.bcs(AskCommission.bcs)

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], fields: Record<string, any>
    ): TradeIntermediate<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return TradeIntermediate.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), nftId: decodeFromFields(ID.reified(), fields.nft_id), seller: decodeFromFields("address", fields.seller), sellerKiosk: decodeFromFields(ID.reified(), fields.seller_kiosk), buyer: decodeFromFields("address", fields.buyer), buyerKiosk: decodeFromFields(ID.reified(), fields.buyer_kiosk), paid: decodeFromFields(Balance.reified(typeArgs[1]), fields.paid), commission: decodeFromFields(Option.reified(AskCommission.reified()), fields.commission)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], item: FieldsWithTypes
    ): TradeIntermediate<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (!isTradeIntermediate(item.type)) {
            throw new Error("not a TradeIntermediate type");
        }
        assertFieldsWithTypesArgsMatch(item, typeArgs);

        return TradeIntermediate.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), nftId: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft_id), seller: decodeFromFieldsWithTypes("address", item.fields.seller), sellerKiosk: decodeFromFieldsWithTypes(ID.reified(), item.fields.seller_kiosk), buyer: decodeFromFieldsWithTypes("address", item.fields.buyer), buyerKiosk: decodeFromFieldsWithTypes(ID.reified(), item.fields.buyer_kiosk), paid: decodeFromFieldsWithTypes(Balance.reified(typeArgs[1]), item.fields.paid), commission: decodeFromFieldsWithTypes(Option.reified(AskCommission.reified()), item.fields.commission)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], data: Uint8Array
    ): TradeIntermediate<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {

        return TradeIntermediate.fromFields(
            typeArgs,
            TradeIntermediate.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,nftId: this.nftId,seller: this.seller,sellerKiosk: this.sellerKiosk,buyer: this.buyer,buyerKiosk: this.buyerKiosk,paid: this.paid.toJSONField(),commission: fieldToJSON<Option<AskCommission>>(`0x1::option::Option<0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::AskCommission>`, this.commission),

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
    ): TradeIntermediate<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return TradeIntermediate.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), nftId: decodeFromJSONField(ID.reified(), field.nftId), seller: decodeFromJSONField("address", field.seller), sellerKiosk: decodeFromJSONField(ID.reified(), field.sellerKiosk), buyer: decodeFromJSONField("address", field.buyer), buyerKiosk: decodeFromJSONField(ID.reified(), field.buyerKiosk), paid: decodeFromJSONField(Balance.reified(typeArgs[1]), field.paid), commission: decodeFromJSONField(Option.reified(AskCommission.reified()), field.commission)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], json: Record<string, any>
    ): TradeIntermediate<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (json.$typeName !== TradeIntermediate.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(TradeIntermediate.$typeName,
            ...typeArgs.map(extractType)),
            json.$typeArgs,
            typeArgs,
        )

        return TradeIntermediate.fromJSONField(
            typeArgs,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], content: SuiParsedData
    ): TradeIntermediate<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTradeIntermediate(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TradeIntermediate object`);
        }
        return TradeIntermediate.fromFieldsWithTypes(
            typeArgs,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArgs: [T, FT], id: string
    ): Promise<TradeIntermediate<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TradeIntermediate object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTradeIntermediate(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TradeIntermediate object`);
        }

        return TradeIntermediate.fromBcs(
            typeArgs,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== TradeIntermediateDfKey =============================== */

export function isTradeIntermediateDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeIntermediateDfKey<");
}

export interface TradeIntermediateDfKeyFields<T extends PhantomTypeArgument, FT extends PhantomTypeArgument> {
    tradeId: ToField<ID>
}

export type TradeIntermediateDfKeyReified<T extends PhantomTypeArgument, FT extends PhantomTypeArgument> = Reified<
    TradeIntermediateDfKey<T, FT>,
    TradeIntermediateDfKeyFields<T, FT>
>;

export class TradeIntermediateDfKey<T extends PhantomTypeArgument, FT extends PhantomTypeArgument> {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeIntermediateDfKey";
    static readonly $numTypeParams = 2;

    readonly $typeName = TradeIntermediateDfKey.$typeName;

    readonly $fullTypeName: `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeIntermediateDfKey<${PhantomToTypeStr<T>}, ${PhantomToTypeStr<FT>}>`;

    readonly $typeArgs: [string, string];

    ;

    readonly tradeId:
        ToField<ID>

    private constructor(typeArgs: [string, string], fields: TradeIntermediateDfKeyFields<T, FT>,
    ) {
        this.$fullTypeName = composeSuiType(TradeIntermediateDfKey.$typeName,
        ...typeArgs) as `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeIntermediateDfKey<${PhantomToTypeStr<T>}, ${PhantomToTypeStr<FT>}>`;

        this.$typeArgs = typeArgs;

        this.tradeId = fields.tradeId;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        T: T, FT: FT
    ): TradeIntermediateDfKeyReified<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return {
            typeName: TradeIntermediateDfKey.$typeName,
            fullTypeName: composeSuiType(
                TradeIntermediateDfKey.$typeName,
                ...[extractType(T), extractType(FT)]
            ) as `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::TradeIntermediateDfKey<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}, ${PhantomToTypeStr<ToPhantomTypeArgument<FT>>}>`,
            typeArgs: [T, FT],
            fromFields: (fields: Record<string, any>) =>
                TradeIntermediateDfKey.fromFields(
                    [T, FT],
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TradeIntermediateDfKey.fromFieldsWithTypes(
                    [T, FT],
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TradeIntermediateDfKey.fromBcs(
                    [T, FT],
                    data,
                ),
            bcs: TradeIntermediateDfKey.bcs,
            fromJSONField: (field: any) =>
                TradeIntermediateDfKey.fromJSONField(
                    [T, FT],
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TradeIntermediateDfKey.fromJSON(
                    [T, FT],
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => TradeIntermediateDfKey.fetch(
                client,
                [T, FT],
                id,
            ),
            new: (
                fields: TradeIntermediateDfKeyFields<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>>,
            ) => {
                return new TradeIntermediateDfKey(
                    [extractType(T), extractType(FT)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TradeIntermediateDfKey.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        T: T, FT: FT
    ): PhantomReified<ToTypeStr<TradeIntermediateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>>>> {
        return phantom(TradeIntermediateDfKey.reified(
            T, FT
        ));
    }

    static get p() {
        return TradeIntermediateDfKey.phantom
    }

    static get bcs() {
        return bcs.struct("TradeIntermediateDfKey", {
            trade_id:
                ID.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], fields: Record<string, any>
    ): TradeIntermediateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return TradeIntermediateDfKey.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {tradeId: decodeFromFields(ID.reified(), fields.trade_id)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], item: FieldsWithTypes
    ): TradeIntermediateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (!isTradeIntermediateDfKey(item.type)) {
            throw new Error("not a TradeIntermediateDfKey type");
        }
        assertFieldsWithTypesArgsMatch(item, typeArgs);

        return TradeIntermediateDfKey.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {tradeId: decodeFromFieldsWithTypes(ID.reified(), item.fields.trade_id)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], data: Uint8Array
    ): TradeIntermediateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {

        return TradeIntermediateDfKey.fromFields(
            typeArgs,
            TradeIntermediateDfKey.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            tradeId: this.tradeId,

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
    ): TradeIntermediateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        return TradeIntermediateDfKey.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {tradeId: decodeFromJSONField(ID.reified(), field.tradeId)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], json: Record<string, any>
    ): TradeIntermediateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (json.$typeName !== TradeIntermediateDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(TradeIntermediateDfKey.$typeName,
            ...typeArgs.map(extractType)),
            json.$typeArgs,
            typeArgs,
        )

        return TradeIntermediateDfKey.fromJSONField(
            typeArgs,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, FT], content: SuiParsedData
    ): TradeIntermediateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTradeIntermediateDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TradeIntermediateDfKey object`);
        }
        return TradeIntermediateDfKey.fromFieldsWithTypes(
            typeArgs,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>, FT extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArgs: [T, FT], id: string
    ): Promise<TradeIntermediateDfKey<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<FT>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TradeIntermediateDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTradeIntermediateDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TradeIntermediateDfKey object`);
        }

        return TradeIntermediateDfKey.fromBcs(
            typeArgs,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== UnderMigrationToDfKey =============================== */

export function isUnderMigrationToDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::UnderMigrationToDfKey";
}

export interface UnderMigrationToDfKeyFields {
    dummyField: ToField<"bool">
}

export type UnderMigrationToDfKeyReified = Reified<
    UnderMigrationToDfKey,
    UnderMigrationToDfKeyFields
>;

export class UnderMigrationToDfKey {
    static readonly $typeName = "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::UnderMigrationToDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = UnderMigrationToDfKey.$typeName;

    readonly $fullTypeName: "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::UnderMigrationToDfKey";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: UnderMigrationToDfKeyFields,
    ) {
        this.$fullTypeName = UnderMigrationToDfKey.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): UnderMigrationToDfKeyReified {
        return {
            typeName: UnderMigrationToDfKey.$typeName,
            fullTypeName: composeSuiType(
                UnderMigrationToDfKey.$typeName,
                ...[]
            ) as "0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e::orderbook::UnderMigrationToDfKey",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                UnderMigrationToDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                UnderMigrationToDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                UnderMigrationToDfKey.fromBcs(
                    data,
                ),
            bcs: UnderMigrationToDfKey.bcs,
            fromJSONField: (field: any) =>
                UnderMigrationToDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                UnderMigrationToDfKey.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => UnderMigrationToDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: UnderMigrationToDfKeyFields,
            ) => {
                return new UnderMigrationToDfKey(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return UnderMigrationToDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<UnderMigrationToDfKey>> {
        return phantom(UnderMigrationToDfKey.reified());
    }

    static get p() {
        return UnderMigrationToDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("UnderMigrationToDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): UnderMigrationToDfKey {
        return UnderMigrationToDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): UnderMigrationToDfKey {
        if (!isUnderMigrationToDfKey(item.type)) {
            throw new Error("not a UnderMigrationToDfKey type");
        }

        return UnderMigrationToDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): UnderMigrationToDfKey {

        return UnderMigrationToDfKey.fromFields(
            UnderMigrationToDfKey.bcs.parse(data)
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
    ): UnderMigrationToDfKey {
        return UnderMigrationToDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): UnderMigrationToDfKey {
        if (json.$typeName !== UnderMigrationToDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return UnderMigrationToDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): UnderMigrationToDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isUnderMigrationToDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a UnderMigrationToDfKey object`);
        }
        return UnderMigrationToDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<UnderMigrationToDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching UnderMigrationToDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isUnderMigrationToDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a UnderMigrationToDfKey object`);
        }

        return UnderMigrationToDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== WitnessProtectedActions =============================== */

export function isWitnessProtectedActions(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::WitnessProtectedActions";
}

export interface WitnessProtectedActionsFields {
    buyNft: ToField<"bool">; createAsk: ToField<"bool">; createBid: ToField<"bool">
}

export type WitnessProtectedActionsReified = Reified<
    WitnessProtectedActions,
    WitnessProtectedActionsFields
>;

export class WitnessProtectedActions {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::WitnessProtectedActions";
    static readonly $numTypeParams = 0;

    readonly $typeName = WitnessProtectedActions.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::WitnessProtectedActions";

    ;

    readonly buyNft:
        ToField<"bool">
    ; readonly createAsk:
        ToField<"bool">
    ; readonly createBid:
        ToField<"bool">

    private constructor( fields: WitnessProtectedActionsFields,
    ) {
        this.$fullTypeName = WitnessProtectedActions.$typeName;

        this.buyNft = fields.buyNft;; this.createAsk = fields.createAsk;; this.createBid = fields.createBid;
    }

    static reified(): WitnessProtectedActionsReified {
        return {
            typeName: WitnessProtectedActions.$typeName,
            fullTypeName: composeSuiType(
                WitnessProtectedActions.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::orderbook::WitnessProtectedActions",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                WitnessProtectedActions.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                WitnessProtectedActions.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                WitnessProtectedActions.fromBcs(
                    data,
                ),
            bcs: WitnessProtectedActions.bcs,
            fromJSONField: (field: any) =>
                WitnessProtectedActions.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                WitnessProtectedActions.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => WitnessProtectedActions.fetch(
                client,
                id,
            ),
            new: (
                fields: WitnessProtectedActionsFields,
            ) => {
                return new WitnessProtectedActions(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return WitnessProtectedActions.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<WitnessProtectedActions>> {
        return phantom(WitnessProtectedActions.reified());
    }

    static get p() {
        return WitnessProtectedActions.phantom()
    }

    static get bcs() {
        return bcs.struct("WitnessProtectedActions", {
            buy_nft:
                bcs.bool()
            , create_ask:
                bcs.bool()
            , create_bid:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): WitnessProtectedActions {
        return WitnessProtectedActions.reified().new(
            {buyNft: decodeFromFields("bool", fields.buy_nft), createAsk: decodeFromFields("bool", fields.create_ask), createBid: decodeFromFields("bool", fields.create_bid)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): WitnessProtectedActions {
        if (!isWitnessProtectedActions(item.type)) {
            throw new Error("not a WitnessProtectedActions type");
        }

        return WitnessProtectedActions.reified().new(
            {buyNft: decodeFromFieldsWithTypes("bool", item.fields.buy_nft), createAsk: decodeFromFieldsWithTypes("bool", item.fields.create_ask), createBid: decodeFromFieldsWithTypes("bool", item.fields.create_bid)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): WitnessProtectedActions {

        return WitnessProtectedActions.fromFields(
            WitnessProtectedActions.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            buyNft: this.buyNft,createAsk: this.createAsk,createBid: this.createBid,

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
    ): WitnessProtectedActions {
        return WitnessProtectedActions.reified().new(
            {buyNft: decodeFromJSONField("bool", field.buyNft), createAsk: decodeFromJSONField("bool", field.createAsk), createBid: decodeFromJSONField("bool", field.createBid)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): WitnessProtectedActions {
        if (json.$typeName !== WitnessProtectedActions.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return WitnessProtectedActions.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): WitnessProtectedActions {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWitnessProtectedActions(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a WitnessProtectedActions object`);
        }
        return WitnessProtectedActions.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<WitnessProtectedActions> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching WitnessProtectedActions object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWitnessProtectedActions(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a WitnessProtectedActions object`);
        }

        return WitnessProtectedActions.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
