import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== PERMISSIONS =============================== */

export function isPERMISSIONS(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::permissions::PERMISSIONS";
}

export interface PERMISSIONSFields {
    dummyField: ToField<"bool">
}

export type PERMISSIONSReified = Reified<
    PERMISSIONS,
    PERMISSIONSFields
>;

export class PERMISSIONS implements StructClass {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::permissions::PERMISSIONS";
    static readonly $numTypeParams = 0;

    readonly $typeName = PERMISSIONS.$typeName;

    readonly $fullTypeName: "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::permissions::PERMISSIONS";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: PERMISSIONSFields,
    ) {
        this.$fullTypeName = composeSuiType(
            PERMISSIONS.$typeName,
            ...typeArgs
        ) as "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::permissions::PERMISSIONS";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): PERMISSIONSReified {
        return {
            typeName: PERMISSIONS.$typeName,
            fullTypeName: composeSuiType(
                PERMISSIONS.$typeName,
                ...[]
            ) as "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::permissions::PERMISSIONS",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                PERMISSIONS.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                PERMISSIONS.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                PERMISSIONS.fromBcs(
                    data,
                ),
            bcs: PERMISSIONS.bcs,
            fromJSONField: (field: any) =>
                PERMISSIONS.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                PERMISSIONS.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                PERMISSIONS.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => PERMISSIONS.fetch(
                client,
                id,
            ),
            new: (
                fields: PERMISSIONSFields,
            ) => {
                return new PERMISSIONS(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return PERMISSIONS.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<PERMISSIONS>> {
        return phantom(PERMISSIONS.reified());
    }

    static get p() {
        return PERMISSIONS.phantom()
    }

    static get bcs() {
        return bcs.struct("PERMISSIONS", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): PERMISSIONS {
        return PERMISSIONS.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): PERMISSIONS {
        if (!isPERMISSIONS(item.type)) {
            throw new Error("not a PERMISSIONS type");
        }

        return PERMISSIONS.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): PERMISSIONS {

        return PERMISSIONS.fromFields(
            PERMISSIONS.bcs.parse(data)
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
    ): PERMISSIONS {
        return PERMISSIONS.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): PERMISSIONS {
        if (json.$typeName !== PERMISSIONS.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return PERMISSIONS.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): PERMISSIONS {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isPERMISSIONS(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a PERMISSIONS object`);
        }
        return PERMISSIONS.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<PERMISSIONS> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching PERMISSIONS object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isPERMISSIONS(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a PERMISSIONS object`);
        }

        return PERMISSIONS.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
