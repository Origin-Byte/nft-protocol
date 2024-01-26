import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {VecSet} from "../../_dependencies/source/0x2/vec-set/structs";
import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Certificate =============================== */

export function isCertificate(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::market_whitelist::Certificate";
}

export interface CertificateFields {
    id: ToField<UID>; listingId: ToField<ID>; venueId: ToField<ID>
}

export type CertificateReified = Reified<
    Certificate,
    CertificateFields
>;

export class Certificate {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::market_whitelist::Certificate";
    static readonly $numTypeParams = 0;

    readonly $typeName = Certificate.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::market_whitelist::Certificate";

    ;

    readonly id:
        ToField<UID>
    ; readonly listingId:
        ToField<ID>
    ; readonly venueId:
        ToField<ID>

    private constructor( fields: CertificateFields,
    ) {
        this.$fullTypeName = Certificate.$typeName;

        this.id = fields.id;; this.listingId = fields.listingId;; this.venueId = fields.venueId;
    }

    static reified(): CertificateReified {
        return {
            typeName: Certificate.$typeName,
            fullTypeName: composeSuiType(
                Certificate.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::market_whitelist::Certificate",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Certificate.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Certificate.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Certificate.fromBcs(
                    data,
                ),
            bcs: Certificate.bcs,
            fromJSONField: (field: any) =>
                Certificate.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Certificate.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Certificate.fetch(
                client,
                id,
            ),
            new: (
                fields: CertificateFields,
            ) => {
                return new Certificate(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Certificate.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Certificate>> {
        return phantom(Certificate.reified());
    }

    static get p() {
        return Certificate.phantom()
    }

    static get bcs() {
        return bcs.struct("Certificate", {
            id:
                UID.bcs
            , listing_id:
                ID.bcs
            , venue_id:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Certificate {
        return Certificate.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), listingId: decodeFromFields(ID.reified(), fields.listing_id), venueId: decodeFromFields(ID.reified(), fields.venue_id)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Certificate {
        if (!isCertificate(item.type)) {
            throw new Error("not a Certificate type");
        }

        return Certificate.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), listingId: decodeFromFieldsWithTypes(ID.reified(), item.fields.listing_id), venueId: decodeFromFieldsWithTypes(ID.reified(), item.fields.venue_id)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Certificate {

        return Certificate.fromFields(
            Certificate.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,listingId: this.listingId,venueId: this.venueId,

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
    ): Certificate {
        return Certificate.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), listingId: decodeFromJSONField(ID.reified(), field.listingId), venueId: decodeFromJSONField(ID.reified(), field.venueId)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Certificate {
        if (json.$typeName !== Certificate.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Certificate.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Certificate {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isCertificate(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Certificate object`);
        }
        return Certificate.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Certificate> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Certificate object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isCertificate(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Certificate object`);
        }

        return Certificate.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Whitelist =============================== */

export function isWhitelist(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::market_whitelist::Whitelist";
}

export interface WhitelistFields {
    id: ToField<UID>; listingId: ToField<ID>; venueId: ToField<ID>; list: ToField<VecSet<"address">>
}

export type WhitelistReified = Reified<
    Whitelist,
    WhitelistFields
>;

export class Whitelist {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::market_whitelist::Whitelist";
    static readonly $numTypeParams = 0;

    readonly $typeName = Whitelist.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::market_whitelist::Whitelist";

    ;

    readonly id:
        ToField<UID>
    ; readonly listingId:
        ToField<ID>
    ; readonly venueId:
        ToField<ID>
    ; readonly list:
        ToField<VecSet<"address">>

    private constructor( fields: WhitelistFields,
    ) {
        this.$fullTypeName = Whitelist.$typeName;

        this.id = fields.id;; this.listingId = fields.listingId;; this.venueId = fields.venueId;; this.list = fields.list;
    }

    static reified(): WhitelistReified {
        return {
            typeName: Whitelist.$typeName,
            fullTypeName: composeSuiType(
                Whitelist.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::market_whitelist::Whitelist",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Whitelist.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Whitelist.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Whitelist.fromBcs(
                    data,
                ),
            bcs: Whitelist.bcs,
            fromJSONField: (field: any) =>
                Whitelist.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Whitelist.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Whitelist.fetch(
                client,
                id,
            ),
            new: (
                fields: WhitelistFields,
            ) => {
                return new Whitelist(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Whitelist.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Whitelist>> {
        return phantom(Whitelist.reified());
    }

    static get p() {
        return Whitelist.phantom()
    }

    static get bcs() {
        return bcs.struct("Whitelist", {
            id:
                UID.bcs
            , listing_id:
                ID.bcs
            , venue_id:
                ID.bcs
            , list:
                VecSet.bcs(bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),}))

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Whitelist {
        return Whitelist.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), listingId: decodeFromFields(ID.reified(), fields.listing_id), venueId: decodeFromFields(ID.reified(), fields.venue_id), list: decodeFromFields(VecSet.reified("address"), fields.list)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Whitelist {
        if (!isWhitelist(item.type)) {
            throw new Error("not a Whitelist type");
        }

        return Whitelist.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), listingId: decodeFromFieldsWithTypes(ID.reified(), item.fields.listing_id), venueId: decodeFromFieldsWithTypes(ID.reified(), item.fields.venue_id), list: decodeFromFieldsWithTypes(VecSet.reified("address"), item.fields.list)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Whitelist {

        return Whitelist.fromFields(
            Whitelist.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,listingId: this.listingId,venueId: this.venueId,list: this.list.toJSONField(),

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
    ): Whitelist {
        return Whitelist.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), listingId: decodeFromJSONField(ID.reified(), field.listingId), venueId: decodeFromJSONField(ID.reified(), field.venueId), list: decodeFromJSONField(VecSet.reified("address"), field.list)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Whitelist {
        if (json.$typeName !== Whitelist.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Whitelist.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Whitelist {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWhitelist(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Whitelist object`);
        }
        return Whitelist.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Whitelist> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Whitelist object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWhitelist(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Whitelist object`);
        }

        return Whitelist.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
