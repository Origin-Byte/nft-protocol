import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== I128 =============================== */

export function isI128(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::i128_type::I128";
}

export interface I128Fields {
    bits: ToField<"u128">
}

export type I128Reified = Reified<
    I128,
    I128Fields
>;

export class I128 implements StructClass {
    static readonly $typeName = "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::i128_type::I128";
    static readonly $numTypeParams = 0;

    readonly $typeName = I128.$typeName;

    readonly $fullTypeName: "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::i128_type::I128";

    readonly $typeArgs: [];

    readonly bits:
        ToField<"u128">

    private constructor(typeArgs: [], fields: I128Fields,
    ) {
        this.$fullTypeName = composeSuiType(
            I128.$typeName,
            ...typeArgs
        ) as "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::i128_type::I128";
        this.$typeArgs = typeArgs;

        this.bits = fields.bits;
    }

    static reified(): I128Reified {
        return {
            typeName: I128.$typeName,
            fullTypeName: composeSuiType(
                I128.$typeName,
                ...[]
            ) as "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::i128_type::I128",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                I128.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                I128.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                I128.fromBcs(
                    data,
                ),
            bcs: I128.bcs,
            fromJSONField: (field: any) =>
                I128.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                I128.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                I128.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => I128.fetch(
                client,
                id,
            ),
            new: (
                fields: I128Fields,
            ) => {
                return new I128(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return I128.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<I128>> {
        return phantom(I128.reified());
    }

    static get p() {
        return I128.phantom()
    }

    static get bcs() {
        return bcs.struct("I128", {
            bits:
                bcs.u128()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): I128 {
        return I128.reified().new(
            {bits: decodeFromFields("u128", fields.bits)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): I128 {
        if (!isI128(item.type)) {
            throw new Error("not a I128 type");
        }

        return I128.reified().new(
            {bits: decodeFromFieldsWithTypes("u128", item.fields.bits)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): I128 {

        return I128.fromFields(
            I128.bcs.parse(data)
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
    ): I128 {
        return I128.reified().new(
            {bits: decodeFromJSONField("u128", field.bits)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): I128 {
        if (json.$typeName !== I128.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return I128.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): I128 {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isI128(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a I128 object`);
        }
        return I128.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<I128> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching I128 object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isI128(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a I128 object`);
        }

        return I128.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
