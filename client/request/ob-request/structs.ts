import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== OB_REQUEST =============================== */

export function isOB_REQUEST(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::ob_request::OB_REQUEST";
}

export interface OB_REQUESTFields {
    dummyField: ToField<"bool">
}

export type OB_REQUESTReified = Reified<
    OB_REQUEST,
    OB_REQUESTFields
>;

export class OB_REQUEST implements StructClass {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::ob_request::OB_REQUEST";
    static readonly $numTypeParams = 0;

    readonly $typeName = OB_REQUEST.$typeName;

    readonly $fullTypeName: "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::ob_request::OB_REQUEST";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: OB_REQUESTFields,
    ) {
        this.$fullTypeName = composeSuiType(
            OB_REQUEST.$typeName,
            ...typeArgs
        ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::ob_request::OB_REQUEST";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): OB_REQUESTReified {
        return {
            typeName: OB_REQUEST.$typeName,
            fullTypeName: composeSuiType(
                OB_REQUEST.$typeName,
                ...[]
            ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::ob_request::OB_REQUEST",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                OB_REQUEST.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                OB_REQUEST.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                OB_REQUEST.fromBcs(
                    data,
                ),
            bcs: OB_REQUEST.bcs,
            fromJSONField: (field: any) =>
                OB_REQUEST.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                OB_REQUEST.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                OB_REQUEST.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => OB_REQUEST.fetch(
                client,
                id,
            ),
            new: (
                fields: OB_REQUESTFields,
            ) => {
                return new OB_REQUEST(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return OB_REQUEST.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<OB_REQUEST>> {
        return phantom(OB_REQUEST.reified());
    }

    static get p() {
        return OB_REQUEST.phantom()
    }

    static get bcs() {
        return bcs.struct("OB_REQUEST", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): OB_REQUEST {
        return OB_REQUEST.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): OB_REQUEST {
        if (!isOB_REQUEST(item.type)) {
            throw new Error("not a OB_REQUEST type");
        }

        return OB_REQUEST.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): OB_REQUEST {

        return OB_REQUEST.fromFields(
            OB_REQUEST.bcs.parse(data)
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
    ): OB_REQUEST {
        return OB_REQUEST.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): OB_REQUEST {
        if (json.$typeName !== OB_REQUEST.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return OB_REQUEST.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): OB_REQUEST {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isOB_REQUEST(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a OB_REQUEST object`);
        }
        return OB_REQUEST.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<OB_REQUEST> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching OB_REQUEST object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isOB_REQUEST(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a OB_REQUEST object`);
        }

        return OB_REQUEST.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
