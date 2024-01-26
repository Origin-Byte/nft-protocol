import {String} from "../../_dependencies/source/0x1/ascii/structs";
import {Option} from "../../_dependencies/source/0x1/option/structs";
import {Balance} from "../../_dependencies/source/0x2/balance/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {BidCommission} from "../trading/structs";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::Witness";

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
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::Witness",
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
    return type.startsWith("0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::Bid<");
}

export interface BidFields<FT extends PhantomTypeArgument> {
    id: ToField<UID>; nft: ToField<ID>; buyer: ToField<"address">; kiosk: ToField<ID>; offer: ToField<Balance<FT>>; commission: ToField<Option<BidCommission<FT>>>
}

export type BidReified<FT extends PhantomTypeArgument> = Reified<
    Bid<FT>,
    BidFields<FT>
>;

export class Bid<FT extends PhantomTypeArgument> {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::Bid";
    static readonly $numTypeParams = 1;

    readonly $typeName = Bid.$typeName;

    readonly $fullTypeName: `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::Bid<${PhantomToTypeStr<FT>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly nft:
        ToField<ID>
    ; readonly buyer:
        ToField<"address">
    ; readonly kiosk:
        ToField<ID>
    ; readonly offer:
        ToField<Balance<FT>>
    ; readonly commission:
        ToField<Option<BidCommission<FT>>>

    private constructor(typeArg: string, fields: BidFields<FT>,
    ) {
        this.$fullTypeName = composeSuiType(Bid.$typeName,
        typeArg) as `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::Bid<${PhantomToTypeStr<FT>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.nft = fields.nft;; this.buyer = fields.buyer;; this.kiosk = fields.kiosk;; this.offer = fields.offer;; this.commission = fields.commission;
    }

    static reified<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): BidReified<ToPhantomTypeArgument<FT>> {
        return {
            typeName: Bid.$typeName,
            fullTypeName: composeSuiType(
                Bid.$typeName,
                ...[extractType(FT)]
            ) as `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::Bid<${PhantomToTypeStr<ToPhantomTypeArgument<FT>>}>`,
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
            id:
                UID.bcs
            , nft:
                ID.bcs
            , buyer:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , kiosk:
                ID.bcs
            , offer:
                Balance.bcs
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
            {id: decodeFromFields(UID.reified(), fields.id), nft: decodeFromFields(ID.reified(), fields.nft), buyer: decodeFromFields("address", fields.buyer), kiosk: decodeFromFields(ID.reified(), fields.kiosk), offer: decodeFromFields(Balance.reified(typeArg), fields.offer), commission: decodeFromFields(Option.reified(BidCommission.reified(typeArg)), fields.commission)}
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
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), nft: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft), buyer: decodeFromFieldsWithTypes("address", item.fields.buyer), kiosk: decodeFromFieldsWithTypes(ID.reified(), item.fields.kiosk), offer: decodeFromFieldsWithTypes(Balance.reified(typeArg), item.fields.offer), commission: decodeFromFieldsWithTypes(Option.reified(BidCommission.reified(typeArg)), item.fields.commission)}
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
            id: this.id,nft: this.nft,buyer: this.buyer,kiosk: this.kiosk,offer: this.offer.toJSONField(),commission: fieldToJSON<Option<BidCommission<FT>>>(`0x1::option::Option<0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::BidCommission<${this.$typeArg}>>`, this.commission),

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
            {id: decodeFromJSONField(UID.reified(), field.id), nft: decodeFromJSONField(ID.reified(), field.nft), buyer: decodeFromJSONField("address", field.buyer), kiosk: decodeFromJSONField(ID.reified(), field.kiosk), offer: decodeFromJSONField(Balance.reified(typeArg), field.offer), commission: decodeFromJSONField(Option.reified(BidCommission.reified(typeArg)), field.commission)}
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
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::BidClosedEvent";
}

export interface BidClosedEventFields {
    bid: ToField<ID>; nft: ToField<ID>; buyer: ToField<"address">; price: ToField<"u64">; ftType: ToField<String>
}

export type BidClosedEventReified = Reified<
    BidClosedEvent,
    BidClosedEventFields
>;

export class BidClosedEvent {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::BidClosedEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = BidClosedEvent.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::BidClosedEvent";

    ;

    readonly bid:
        ToField<ID>
    ; readonly nft:
        ToField<ID>
    ; readonly buyer:
        ToField<"address">
    ; readonly price:
        ToField<"u64">
    ; readonly ftType:
        ToField<String>

    private constructor( fields: BidClosedEventFields,
    ) {
        this.$fullTypeName = BidClosedEvent.$typeName;

        this.bid = fields.bid;; this.nft = fields.nft;; this.buyer = fields.buyer;; this.price = fields.price;; this.ftType = fields.ftType;
    }

    static reified(): BidClosedEventReified {
        return {
            typeName: BidClosedEvent.$typeName,
            fullTypeName: composeSuiType(
                BidClosedEvent.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::BidClosedEvent",
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
            bid:
                ID.bcs
            , nft:
                ID.bcs
            , buyer:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , price:
                bcs.u64()
            , ft_type:
                String.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): BidClosedEvent {
        return BidClosedEvent.reified().new(
            {bid: decodeFromFields(ID.reified(), fields.bid), nft: decodeFromFields(ID.reified(), fields.nft), buyer: decodeFromFields("address", fields.buyer), price: decodeFromFields("u64", fields.price), ftType: decodeFromFields(String.reified(), fields.ft_type)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): BidClosedEvent {
        if (!isBidClosedEvent(item.type)) {
            throw new Error("not a BidClosedEvent type");
        }

        return BidClosedEvent.reified().new(
            {bid: decodeFromFieldsWithTypes(ID.reified(), item.fields.bid), nft: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft), buyer: decodeFromFieldsWithTypes("address", item.fields.buyer), price: decodeFromFieldsWithTypes("u64", item.fields.price), ftType: decodeFromFieldsWithTypes(String.reified(), item.fields.ft_type)}
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
            bid: this.bid,nft: this.nft,buyer: this.buyer,price: this.price.toString(),ftType: this.ftType,

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
            {bid: decodeFromJSONField(ID.reified(), field.bid), nft: decodeFromJSONField(ID.reified(), field.nft), buyer: decodeFromJSONField("address", field.buyer), price: decodeFromJSONField("u64", field.price), ftType: decodeFromJSONField(String.reified(), field.ftType)}
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
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::BidCreatedEvent";
}

export interface BidCreatedEventFields {
    bid: ToField<ID>; nft: ToField<ID>; price: ToField<"u64">; commission: ToField<"u64">; buyer: ToField<"address">; buyerKiosk: ToField<ID>; ftType: ToField<String>
}

export type BidCreatedEventReified = Reified<
    BidCreatedEvent,
    BidCreatedEventFields
>;

export class BidCreatedEvent {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::BidCreatedEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = BidCreatedEvent.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::BidCreatedEvent";

    ;

    readonly bid:
        ToField<ID>
    ; readonly nft:
        ToField<ID>
    ; readonly price:
        ToField<"u64">
    ; readonly commission:
        ToField<"u64">
    ; readonly buyer:
        ToField<"address">
    ; readonly buyerKiosk:
        ToField<ID>
    ; readonly ftType:
        ToField<String>

    private constructor( fields: BidCreatedEventFields,
    ) {
        this.$fullTypeName = BidCreatedEvent.$typeName;

        this.bid = fields.bid;; this.nft = fields.nft;; this.price = fields.price;; this.commission = fields.commission;; this.buyer = fields.buyer;; this.buyerKiosk = fields.buyerKiosk;; this.ftType = fields.ftType;
    }

    static reified(): BidCreatedEventReified {
        return {
            typeName: BidCreatedEvent.$typeName,
            fullTypeName: composeSuiType(
                BidCreatedEvent.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::BidCreatedEvent",
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
            bid:
                ID.bcs
            , nft:
                ID.bcs
            , price:
                bcs.u64()
            , commission:
                bcs.u64()
            , buyer:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , buyer_kiosk:
                ID.bcs
            , ft_type:
                String.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): BidCreatedEvent {
        return BidCreatedEvent.reified().new(
            {bid: decodeFromFields(ID.reified(), fields.bid), nft: decodeFromFields(ID.reified(), fields.nft), price: decodeFromFields("u64", fields.price), commission: decodeFromFields("u64", fields.commission), buyer: decodeFromFields("address", fields.buyer), buyerKiosk: decodeFromFields(ID.reified(), fields.buyer_kiosk), ftType: decodeFromFields(String.reified(), fields.ft_type)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): BidCreatedEvent {
        if (!isBidCreatedEvent(item.type)) {
            throw new Error("not a BidCreatedEvent type");
        }

        return BidCreatedEvent.reified().new(
            {bid: decodeFromFieldsWithTypes(ID.reified(), item.fields.bid), nft: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft), price: decodeFromFieldsWithTypes("u64", item.fields.price), commission: decodeFromFieldsWithTypes("u64", item.fields.commission), buyer: decodeFromFieldsWithTypes("address", item.fields.buyer), buyerKiosk: decodeFromFieldsWithTypes(ID.reified(), item.fields.buyer_kiosk), ftType: decodeFromFieldsWithTypes(String.reified(), item.fields.ft_type)}
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
            bid: this.bid,nft: this.nft,price: this.price.toString(),commission: this.commission.toString(),buyer: this.buyer,buyerKiosk: this.buyerKiosk,ftType: this.ftType,

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
            {bid: decodeFromJSONField(ID.reified(), field.bid), nft: decodeFromJSONField(ID.reified(), field.nft), price: decodeFromJSONField("u64", field.price), commission: decodeFromJSONField("u64", field.commission), buyer: decodeFromJSONField("address", field.buyer), buyerKiosk: decodeFromJSONField(ID.reified(), field.buyerKiosk), ftType: decodeFromJSONField(String.reified(), field.ftType)}
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

/* ============================== BidMatchedEvent =============================== */

export function isBidMatchedEvent(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::BidMatchedEvent";
}

export interface BidMatchedEventFields {
    bid: ToField<ID>; nft: ToField<ID>; price: ToField<"u64">; seller: ToField<"address">; buyer: ToField<"address">; ftType: ToField<String>; nftType: ToField<String>
}

export type BidMatchedEventReified = Reified<
    BidMatchedEvent,
    BidMatchedEventFields
>;

export class BidMatchedEvent {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::BidMatchedEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = BidMatchedEvent.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::BidMatchedEvent";

    ;

    readonly bid:
        ToField<ID>
    ; readonly nft:
        ToField<ID>
    ; readonly price:
        ToField<"u64">
    ; readonly seller:
        ToField<"address">
    ; readonly buyer:
        ToField<"address">
    ; readonly ftType:
        ToField<String>
    ; readonly nftType:
        ToField<String>

    private constructor( fields: BidMatchedEventFields,
    ) {
        this.$fullTypeName = BidMatchedEvent.$typeName;

        this.bid = fields.bid;; this.nft = fields.nft;; this.price = fields.price;; this.seller = fields.seller;; this.buyer = fields.buyer;; this.ftType = fields.ftType;; this.nftType = fields.nftType;
    }

    static reified(): BidMatchedEventReified {
        return {
            typeName: BidMatchedEvent.$typeName,
            fullTypeName: composeSuiType(
                BidMatchedEvent.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::bidding::BidMatchedEvent",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                BidMatchedEvent.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                BidMatchedEvent.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                BidMatchedEvent.fromBcs(
                    data,
                ),
            bcs: BidMatchedEvent.bcs,
            fromJSONField: (field: any) =>
                BidMatchedEvent.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                BidMatchedEvent.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => BidMatchedEvent.fetch(
                client,
                id,
            ),
            new: (
                fields: BidMatchedEventFields,
            ) => {
                return new BidMatchedEvent(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return BidMatchedEvent.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<BidMatchedEvent>> {
        return phantom(BidMatchedEvent.reified());
    }

    static get p() {
        return BidMatchedEvent.phantom()
    }

    static get bcs() {
        return bcs.struct("BidMatchedEvent", {
            bid:
                ID.bcs
            , nft:
                ID.bcs
            , price:
                bcs.u64()
            , seller:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , buyer:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , ft_type:
                String.bcs
            , nft_type:
                String.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): BidMatchedEvent {
        return BidMatchedEvent.reified().new(
            {bid: decodeFromFields(ID.reified(), fields.bid), nft: decodeFromFields(ID.reified(), fields.nft), price: decodeFromFields("u64", fields.price), seller: decodeFromFields("address", fields.seller), buyer: decodeFromFields("address", fields.buyer), ftType: decodeFromFields(String.reified(), fields.ft_type), nftType: decodeFromFields(String.reified(), fields.nft_type)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): BidMatchedEvent {
        if (!isBidMatchedEvent(item.type)) {
            throw new Error("not a BidMatchedEvent type");
        }

        return BidMatchedEvent.reified().new(
            {bid: decodeFromFieldsWithTypes(ID.reified(), item.fields.bid), nft: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft), price: decodeFromFieldsWithTypes("u64", item.fields.price), seller: decodeFromFieldsWithTypes("address", item.fields.seller), buyer: decodeFromFieldsWithTypes("address", item.fields.buyer), ftType: decodeFromFieldsWithTypes(String.reified(), item.fields.ft_type), nftType: decodeFromFieldsWithTypes(String.reified(), item.fields.nft_type)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): BidMatchedEvent {

        return BidMatchedEvent.fromFields(
            BidMatchedEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            bid: this.bid,nft: this.nft,price: this.price.toString(),seller: this.seller,buyer: this.buyer,ftType: this.ftType,nftType: this.nftType,

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
    ): BidMatchedEvent {
        return BidMatchedEvent.reified().new(
            {bid: decodeFromJSONField(ID.reified(), field.bid), nft: decodeFromJSONField(ID.reified(), field.nft), price: decodeFromJSONField("u64", field.price), seller: decodeFromJSONField("address", field.seller), buyer: decodeFromJSONField("address", field.buyer), ftType: decodeFromJSONField(String.reified(), field.ftType), nftType: decodeFromJSONField(String.reified(), field.nftType)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): BidMatchedEvent {
        if (json.$typeName !== BidMatchedEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return BidMatchedEvent.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): BidMatchedEvent {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBidMatchedEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a BidMatchedEvent object`);
        }
        return BidMatchedEvent.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<BidMatchedEvent> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching BidMatchedEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBidMatchedEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a BidMatchedEvent object`);
        }

        return BidMatchedEvent.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
