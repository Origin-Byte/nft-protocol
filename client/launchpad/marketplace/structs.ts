import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {ObjectBox} from "../../originmate/object-box/structs";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Marketplace =============================== */

export function isMarketplace(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::marketplace::Marketplace";
}

export interface MarketplaceFields {
    id: ToField<UID>; version: ToField<"u64">; admin: ToField<"address">; receiver: ToField<"address">; defaultFee: ToField<ObjectBox>
}

export type MarketplaceReified = Reified<
    Marketplace,
    MarketplaceFields
>;

export class Marketplace {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::marketplace::Marketplace";
    static readonly $numTypeParams = 0;

    readonly $typeName = Marketplace.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::marketplace::Marketplace";

    ;

    readonly id:
        ToField<UID>
    ; readonly version:
        ToField<"u64">
    ; readonly admin:
        ToField<"address">
    ; readonly receiver:
        ToField<"address">
    ; readonly defaultFee:
        ToField<ObjectBox>

    private constructor( fields: MarketplaceFields,
    ) {
        this.$fullTypeName = Marketplace.$typeName;

        this.id = fields.id;; this.version = fields.version;; this.admin = fields.admin;; this.receiver = fields.receiver;; this.defaultFee = fields.defaultFee;
    }

    static reified(): MarketplaceReified {
        return {
            typeName: Marketplace.$typeName,
            fullTypeName: composeSuiType(
                Marketplace.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::marketplace::Marketplace",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Marketplace.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Marketplace.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Marketplace.fromBcs(
                    data,
                ),
            bcs: Marketplace.bcs,
            fromJSONField: (field: any) =>
                Marketplace.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Marketplace.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Marketplace.fetch(
                client,
                id,
            ),
            new: (
                fields: MarketplaceFields,
            ) => {
                return new Marketplace(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Marketplace.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Marketplace>> {
        return phantom(Marketplace.reified());
    }

    static get p() {
        return Marketplace.phantom()
    }

    static get bcs() {
        return bcs.struct("Marketplace", {
            id:
                UID.bcs
            , version:
                bcs.u64()
            , admin:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , receiver:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , default_fee:
                ObjectBox.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Marketplace {
        return Marketplace.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), version: decodeFromFields("u64", fields.version), admin: decodeFromFields("address", fields.admin), receiver: decodeFromFields("address", fields.receiver), defaultFee: decodeFromFields(ObjectBox.reified(), fields.default_fee)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Marketplace {
        if (!isMarketplace(item.type)) {
            throw new Error("not a Marketplace type");
        }

        return Marketplace.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), version: decodeFromFieldsWithTypes("u64", item.fields.version), admin: decodeFromFieldsWithTypes("address", item.fields.admin), receiver: decodeFromFieldsWithTypes("address", item.fields.receiver), defaultFee: decodeFromFieldsWithTypes(ObjectBox.reified(), item.fields.default_fee)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Marketplace {

        return Marketplace.fromFields(
            Marketplace.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,version: this.version.toString(),admin: this.admin,receiver: this.receiver,defaultFee: this.defaultFee.toJSONField(),

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
    ): Marketplace {
        return Marketplace.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), version: decodeFromJSONField("u64", field.version), admin: decodeFromJSONField("address", field.admin), receiver: decodeFromJSONField("address", field.receiver), defaultFee: decodeFromJSONField(ObjectBox.reified(), field.defaultFee)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Marketplace {
        if (json.$typeName !== Marketplace.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Marketplace.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Marketplace {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isMarketplace(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Marketplace object`);
        }
        return Marketplace.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Marketplace> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Marketplace object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isMarketplace(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Marketplace object`);
        }

        return Marketplace.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== MembersDfKey =============================== */

export function isMembersDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc0c5ca1e59bbb0e7330c8f182cbad262717faf7d8d0d7f7da4b3146391ecbbe1::marketplace::MembersDfKey";
}

export interface MembersDfKeyFields {
    dummyField: ToField<"bool">
}

export type MembersDfKeyReified = Reified<
    MembersDfKey,
    MembersDfKeyFields
>;

export class MembersDfKey {
    static readonly $typeName = "0xc0c5ca1e59bbb0e7330c8f182cbad262717faf7d8d0d7f7da4b3146391ecbbe1::marketplace::MembersDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = MembersDfKey.$typeName;

    readonly $fullTypeName: "0xc0c5ca1e59bbb0e7330c8f182cbad262717faf7d8d0d7f7da4b3146391ecbbe1::marketplace::MembersDfKey";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: MembersDfKeyFields,
    ) {
        this.$fullTypeName = MembersDfKey.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): MembersDfKeyReified {
        return {
            typeName: MembersDfKey.$typeName,
            fullTypeName: composeSuiType(
                MembersDfKey.$typeName,
                ...[]
            ) as "0xc0c5ca1e59bbb0e7330c8f182cbad262717faf7d8d0d7f7da4b3146391ecbbe1::marketplace::MembersDfKey",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                MembersDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                MembersDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                MembersDfKey.fromBcs(
                    data,
                ),
            bcs: MembersDfKey.bcs,
            fromJSONField: (field: any) =>
                MembersDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                MembersDfKey.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => MembersDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: MembersDfKeyFields,
            ) => {
                return new MembersDfKey(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return MembersDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<MembersDfKey>> {
        return phantom(MembersDfKey.reified());
    }

    static get p() {
        return MembersDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("MembersDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): MembersDfKey {
        return MembersDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): MembersDfKey {
        if (!isMembersDfKey(item.type)) {
            throw new Error("not a MembersDfKey type");
        }

        return MembersDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): MembersDfKey {

        return MembersDfKey.fromFields(
            MembersDfKey.bcs.parse(data)
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
    ): MembersDfKey {
        return MembersDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): MembersDfKey {
        if (json.$typeName !== MembersDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return MembersDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): MembersDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isMembersDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a MembersDfKey object`);
        }
        return MembersDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<MembersDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching MembersDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isMembersDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a MembersDfKey object`);
        }

        return MembersDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
