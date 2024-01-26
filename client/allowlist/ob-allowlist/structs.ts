import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== OB_ALLOWLIST =============================== */

export function isOB_ALLOWLIST(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::ob_allowlist::OB_ALLOWLIST";
}

export interface OB_ALLOWLISTFields {
    dummyField: ToField<"bool">
}

export type OB_ALLOWLISTReified = Reified<
    OB_ALLOWLIST,
    OB_ALLOWLISTFields
>;

export class OB_ALLOWLIST {
    static readonly $typeName = "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::ob_allowlist::OB_ALLOWLIST";
    static readonly $numTypeParams = 0;

    readonly $typeName = OB_ALLOWLIST.$typeName;

    readonly $fullTypeName: "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::ob_allowlist::OB_ALLOWLIST";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: OB_ALLOWLISTFields,
    ) {
        this.$fullTypeName = OB_ALLOWLIST.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): OB_ALLOWLISTReified {
        return {
            typeName: OB_ALLOWLIST.$typeName,
            fullTypeName: composeSuiType(
                OB_ALLOWLIST.$typeName,
                ...[]
            ) as "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::ob_allowlist::OB_ALLOWLIST",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                OB_ALLOWLIST.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                OB_ALLOWLIST.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                OB_ALLOWLIST.fromBcs(
                    data,
                ),
            bcs: OB_ALLOWLIST.bcs,
            fromJSONField: (field: any) =>
                OB_ALLOWLIST.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                OB_ALLOWLIST.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => OB_ALLOWLIST.fetch(
                client,
                id,
            ),
            new: (
                fields: OB_ALLOWLISTFields,
            ) => {
                return new OB_ALLOWLIST(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return OB_ALLOWLIST.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<OB_ALLOWLIST>> {
        return phantom(OB_ALLOWLIST.reified());
    }

    static get p() {
        return OB_ALLOWLIST.phantom()
    }

    static get bcs() {
        return bcs.struct("OB_ALLOWLIST", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): OB_ALLOWLIST {
        return OB_ALLOWLIST.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): OB_ALLOWLIST {
        if (!isOB_ALLOWLIST(item.type)) {
            throw new Error("not a OB_ALLOWLIST type");
        }

        return OB_ALLOWLIST.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): OB_ALLOWLIST {

        return OB_ALLOWLIST.fromFields(
            OB_ALLOWLIST.bcs.parse(data)
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
    ): OB_ALLOWLIST {
        return OB_ALLOWLIST.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): OB_ALLOWLIST {
        if (json.$typeName !== OB_ALLOWLIST.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return OB_ALLOWLIST.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): OB_ALLOWLIST {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isOB_ALLOWLIST(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a OB_ALLOWLIST object`);
        }
        return OB_ALLOWLIST.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<OB_ALLOWLIST> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching OB_ALLOWLIST object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isOB_ALLOWLIST(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a OB_ALLOWLIST object`);
        }

        return OB_ALLOWLIST.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
