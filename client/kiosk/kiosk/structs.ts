import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== KIOSK =============================== */

export function isKIOSK(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::kiosk::KIOSK";
}

export interface KIOSKFields {
    dummyField: ToField<"bool">
}

export type KIOSKReified = Reified<
    KIOSK,
    KIOSKFields
>;

export class KIOSK {
    static readonly $typeName = "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::kiosk::KIOSK";
    static readonly $numTypeParams = 0;

    readonly $typeName = KIOSK.$typeName;

    readonly $fullTypeName: "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::kiosk::KIOSK";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: KIOSKFields,
    ) {
        this.$fullTypeName = KIOSK.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): KIOSKReified {
        return {
            typeName: KIOSK.$typeName,
            fullTypeName: composeSuiType(
                KIOSK.$typeName,
                ...[]
            ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::kiosk::KIOSK",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                KIOSK.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                KIOSK.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                KIOSK.fromBcs(
                    data,
                ),
            bcs: KIOSK.bcs,
            fromJSONField: (field: any) =>
                KIOSK.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                KIOSK.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => KIOSK.fetch(
                client,
                id,
            ),
            new: (
                fields: KIOSKFields,
            ) => {
                return new KIOSK(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return KIOSK.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<KIOSK>> {
        return phantom(KIOSK.reified());
    }

    static get p() {
        return KIOSK.phantom()
    }

    static get bcs() {
        return bcs.struct("KIOSK", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): KIOSK {
        return KIOSK.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): KIOSK {
        if (!isKIOSK(item.type)) {
            throw new Error("not a KIOSK type");
        }

        return KIOSK.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): KIOSK {

        return KIOSK.fromFields(
            KIOSK.bcs.parse(data)
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
    ): KIOSK {
        return KIOSK.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): KIOSK {
        if (json.$typeName !== KIOSK.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return KIOSK.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): KIOSK {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isKIOSK(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a KIOSK object`);
        }
        return KIOSK.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<KIOSK> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching KIOSK object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isKIOSK(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a KIOSK object`);
        }

        return KIOSK.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
