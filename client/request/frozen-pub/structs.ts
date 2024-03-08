import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== FROZEN_PUB =============================== */

export function isFROZEN_PUB(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::frozen_pub::FROZEN_PUB";
}

export interface FROZEN_PUBFields {
    dummyField: ToField<"bool">
}

export type FROZEN_PUBReified = Reified<
    FROZEN_PUB,
    FROZEN_PUBFields
>;

export class FROZEN_PUB implements StructClass {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::frozen_pub::FROZEN_PUB";
    static readonly $numTypeParams = 0;

    readonly $typeName = FROZEN_PUB.$typeName;

    readonly $fullTypeName: "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::frozen_pub::FROZEN_PUB";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: FROZEN_PUBFields,
    ) {
        this.$fullTypeName = composeSuiType(
            FROZEN_PUB.$typeName,
            ...typeArgs
        ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::frozen_pub::FROZEN_PUB";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): FROZEN_PUBReified {
        return {
            typeName: FROZEN_PUB.$typeName,
            fullTypeName: composeSuiType(
                FROZEN_PUB.$typeName,
                ...[]
            ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::frozen_pub::FROZEN_PUB",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                FROZEN_PUB.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                FROZEN_PUB.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                FROZEN_PUB.fromBcs(
                    data,
                ),
            bcs: FROZEN_PUB.bcs,
            fromJSONField: (field: any) =>
                FROZEN_PUB.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                FROZEN_PUB.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                FROZEN_PUB.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => FROZEN_PUB.fetch(
                client,
                id,
            ),
            new: (
                fields: FROZEN_PUBFields,
            ) => {
                return new FROZEN_PUB(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return FROZEN_PUB.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<FROZEN_PUB>> {
        return phantom(FROZEN_PUB.reified());
    }

    static get p() {
        return FROZEN_PUB.phantom()
    }

    static get bcs() {
        return bcs.struct("FROZEN_PUB", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): FROZEN_PUB {
        return FROZEN_PUB.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): FROZEN_PUB {
        if (!isFROZEN_PUB(item.type)) {
            throw new Error("not a FROZEN_PUB type");
        }

        return FROZEN_PUB.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): FROZEN_PUB {

        return FROZEN_PUB.fromFields(
            FROZEN_PUB.bcs.parse(data)
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
    ): FROZEN_PUB {
        return FROZEN_PUB.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): FROZEN_PUB {
        if (json.$typeName !== FROZEN_PUB.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return FROZEN_PUB.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): FROZEN_PUB {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isFROZEN_PUB(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a FROZEN_PUB object`);
        }
        return FROZEN_PUB.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<FROZEN_PUB> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching FROZEN_PUB object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isFROZEN_PUB(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a FROZEN_PUB object`);
        }

        return FROZEN_PUB.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
