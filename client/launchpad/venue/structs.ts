import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Venue =============================== */

export function isVenue(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::venue::Venue";
}

export interface VenueFields {
    id: ToField<UID>; isLive: ToField<"bool">; isWhitelisted: ToField<"bool">
}

export type VenueReified = Reified<
    Venue,
    VenueFields
>;

export class Venue {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::venue::Venue";
    static readonly $numTypeParams = 0;

    readonly $typeName = Venue.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::venue::Venue";

    ;

    readonly id:
        ToField<UID>
    ; readonly isLive:
        ToField<"bool">
    ; readonly isWhitelisted:
        ToField<"bool">

    private constructor( fields: VenueFields,
    ) {
        this.$fullTypeName = Venue.$typeName;

        this.id = fields.id;; this.isLive = fields.isLive;; this.isWhitelisted = fields.isWhitelisted;
    }

    static reified(): VenueReified {
        return {
            typeName: Venue.$typeName,
            fullTypeName: composeSuiType(
                Venue.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::venue::Venue",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Venue.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Venue.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Venue.fromBcs(
                    data,
                ),
            bcs: Venue.bcs,
            fromJSONField: (field: any) =>
                Venue.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Venue.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Venue.fetch(
                client,
                id,
            ),
            new: (
                fields: VenueFields,
            ) => {
                return new Venue(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Venue.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Venue>> {
        return phantom(Venue.reified());
    }

    static get p() {
        return Venue.phantom()
    }

    static get bcs() {
        return bcs.struct("Venue", {
            id:
                UID.bcs
            , is_live:
                bcs.bool()
            , is_whitelisted:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Venue {
        return Venue.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), isLive: decodeFromFields("bool", fields.is_live), isWhitelisted: decodeFromFields("bool", fields.is_whitelisted)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Venue {
        if (!isVenue(item.type)) {
            throw new Error("not a Venue type");
        }

        return Venue.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), isLive: decodeFromFieldsWithTypes("bool", item.fields.is_live), isWhitelisted: decodeFromFieldsWithTypes("bool", item.fields.is_whitelisted)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Venue {

        return Venue.fromFields(
            Venue.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,isLive: this.isLive,isWhitelisted: this.isWhitelisted,

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
    ): Venue {
        return Venue.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), isLive: decodeFromJSONField("bool", field.isLive), isWhitelisted: decodeFromJSONField("bool", field.isWhitelisted)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Venue {
        if (json.$typeName !== Venue.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Venue.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Venue {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isVenue(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Venue object`);
        }
        return Venue.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Venue> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Venue object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isVenue(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Venue object`);
        }

        return Venue.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
