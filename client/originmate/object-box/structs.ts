import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== ObjectBox =============================== */

export function isObjectBox(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::object_box::ObjectBox";
}

export interface ObjectBoxFields {
    id: ToField<UID>; len: ToField<"u64">
}

export type ObjectBoxReified = Reified<
    ObjectBox,
    ObjectBoxFields
>;

export class ObjectBox implements StructClass {
    static readonly $typeName = "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::object_box::ObjectBox";
    static readonly $numTypeParams = 0;

    readonly $typeName = ObjectBox.$typeName;

    readonly $fullTypeName: "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::object_box::ObjectBox";

    readonly $typeArgs: [];

    readonly id:
        ToField<UID>
    ; readonly len:
        ToField<"u64">

    private constructor(typeArgs: [], fields: ObjectBoxFields,
    ) {
        this.$fullTypeName = composeSuiType(
            ObjectBox.$typeName,
            ...typeArgs
        ) as "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::object_box::ObjectBox";
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.len = fields.len;
    }

    static reified(): ObjectBoxReified {
        return {
            typeName: ObjectBox.$typeName,
            fullTypeName: composeSuiType(
                ObjectBox.$typeName,
                ...[]
            ) as "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::object_box::ObjectBox",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                ObjectBox.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ObjectBox.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ObjectBox.fromBcs(
                    data,
                ),
            bcs: ObjectBox.bcs,
            fromJSONField: (field: any) =>
                ObjectBox.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ObjectBox.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                ObjectBox.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => ObjectBox.fetch(
                client,
                id,
            ),
            new: (
                fields: ObjectBoxFields,
            ) => {
                return new ObjectBox(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ObjectBox.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<ObjectBox>> {
        return phantom(ObjectBox.reified());
    }

    static get p() {
        return ObjectBox.phantom()
    }

    static get bcs() {
        return bcs.struct("ObjectBox", {
            id:
                UID.bcs
            , len:
                bcs.u64()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): ObjectBox {
        return ObjectBox.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), len: decodeFromFields("u64", fields.len)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): ObjectBox {
        if (!isObjectBox(item.type)) {
            throw new Error("not a ObjectBox type");
        }

        return ObjectBox.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), len: decodeFromFieldsWithTypes("u64", item.fields.len)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): ObjectBox {

        return ObjectBox.fromFields(
            ObjectBox.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,len: this.len.toString(),

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
    ): ObjectBox {
        return ObjectBox.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), len: decodeFromJSONField("u64", field.len)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): ObjectBox {
        if (json.$typeName !== ObjectBox.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return ObjectBox.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): ObjectBox {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isObjectBox(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ObjectBox object`);
        }
        return ObjectBox.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<ObjectBox> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ObjectBox object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isObjectBox(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ObjectBox object`);
        }

        return ObjectBox.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
