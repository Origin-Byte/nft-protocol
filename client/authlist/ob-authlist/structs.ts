import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== OB_AUTHLIST =============================== */

export function isOB_AUTHLIST(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::ob_authlist::OB_AUTHLIST";
}

export interface OB_AUTHLISTFields {
    dummyField: ToField<"bool">
}

export type OB_AUTHLISTReified = Reified<
    OB_AUTHLIST,
    OB_AUTHLISTFields
>;

export class OB_AUTHLIST {
    static readonly $typeName = "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::ob_authlist::OB_AUTHLIST";
    static readonly $numTypeParams = 0;

    readonly $typeName = OB_AUTHLIST.$typeName;

    readonly $fullTypeName: "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::ob_authlist::OB_AUTHLIST";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: OB_AUTHLISTFields,
    ) {
        this.$fullTypeName = OB_AUTHLIST.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): OB_AUTHLISTReified {
        return {
            typeName: OB_AUTHLIST.$typeName,
            fullTypeName: composeSuiType(
                OB_AUTHLIST.$typeName,
                ...[]
            ) as "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::ob_authlist::OB_AUTHLIST",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                OB_AUTHLIST.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                OB_AUTHLIST.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                OB_AUTHLIST.fromBcs(
                    data,
                ),
            bcs: OB_AUTHLIST.bcs,
            fromJSONField: (field: any) =>
                OB_AUTHLIST.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                OB_AUTHLIST.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => OB_AUTHLIST.fetch(
                client,
                id,
            ),
            new: (
                fields: OB_AUTHLISTFields,
            ) => {
                return new OB_AUTHLIST(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return OB_AUTHLIST.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<OB_AUTHLIST>> {
        return phantom(OB_AUTHLIST.reified());
    }

    static get p() {
        return OB_AUTHLIST.phantom()
    }

    static get bcs() {
        return bcs.struct("OB_AUTHLIST", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): OB_AUTHLIST {
        return OB_AUTHLIST.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): OB_AUTHLIST {
        if (!isOB_AUTHLIST(item.type)) {
            throw new Error("not a OB_AUTHLIST type");
        }

        return OB_AUTHLIST.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): OB_AUTHLIST {

        return OB_AUTHLIST.fromFields(
            OB_AUTHLIST.bcs.parse(data)
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
    ): OB_AUTHLIST {
        return OB_AUTHLIST.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): OB_AUTHLIST {
        if (json.$typeName !== OB_AUTHLIST.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return OB_AUTHLIST.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): OB_AUTHLIST {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isOB_AUTHLIST(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a OB_AUTHLIST object`);
        }
        return OB_AUTHLIST.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<OB_AUTHLIST> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching OB_AUTHLIST object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isOB_AUTHLIST(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a OB_AUTHLIST object`);
        }

        return OB_AUTHLIST.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
