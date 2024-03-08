import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== I64 =============================== */

export function isI64(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::i64_type::I64";
}

export interface I64Fields {
    bits: ToField<"u64">
}

export type I64Reified = Reified<
    I64,
    I64Fields
>;

export class I64 implements StructClass {
    static readonly $typeName = "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::i64_type::I64";
    static readonly $numTypeParams = 0;

    readonly $typeName = I64.$typeName;

    readonly $fullTypeName: "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::i64_type::I64";

    readonly $typeArgs: [];

    readonly bits:
        ToField<"u64">

    private constructor(typeArgs: [], fields: I64Fields,
    ) {
        this.$fullTypeName = composeSuiType(
            I64.$typeName,
            ...typeArgs
        ) as "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::i64_type::I64";
        this.$typeArgs = typeArgs;

        this.bits = fields.bits;
    }

    static reified(): I64Reified {
        return {
            typeName: I64.$typeName,
            fullTypeName: composeSuiType(
                I64.$typeName,
                ...[]
            ) as "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::i64_type::I64",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                I64.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                I64.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                I64.fromBcs(
                    data,
                ),
            bcs: I64.bcs,
            fromJSONField: (field: any) =>
                I64.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                I64.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                I64.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => I64.fetch(
                client,
                id,
            ),
            new: (
                fields: I64Fields,
            ) => {
                return new I64(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return I64.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<I64>> {
        return phantom(I64.reified());
    }

    static get p() {
        return I64.phantom()
    }

    static get bcs() {
        return bcs.struct("I64", {
            bits:
                bcs.u64()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): I64 {
        return I64.reified().new(
            {bits: decodeFromFields("u64", fields.bits)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): I64 {
        if (!isI64(item.type)) {
            throw new Error("not a I64 type");
        }

        return I64.reified().new(
            {bits: decodeFromFieldsWithTypes("u64", item.fields.bits)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): I64 {

        return I64.fromFields(
            I64.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            bits: this.bits.toString(),

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
    ): I64 {
        return I64.reified().new(
            {bits: decodeFromJSONField("u64", field.bits)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): I64 {
        if (json.$typeName !== I64.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return I64.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): I64 {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isI64(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a I64 object`);
        }
        return I64.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<I64> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching I64 object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isI64(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a I64 object`);
        }

        return I64.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
