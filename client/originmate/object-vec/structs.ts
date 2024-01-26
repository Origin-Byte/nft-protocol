import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== ObjectVec =============================== */

export function isObjectVec(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::object_vec::ObjectVec<");
}

export interface ObjectVecFields<V extends PhantomTypeArgument> {
    id: ToField<UID>; size: ToField<"u64">
}

export type ObjectVecReified<V extends PhantomTypeArgument> = Reified<
    ObjectVec<V>,
    ObjectVecFields<V>
>;

export class ObjectVec<V extends PhantomTypeArgument> {
    static readonly $typeName = "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::object_vec::ObjectVec";
    static readonly $numTypeParams = 1;

    readonly $typeName = ObjectVec.$typeName;

    readonly $fullTypeName: `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::object_vec::ObjectVec<${PhantomToTypeStr<V>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly size:
        ToField<"u64">

    private constructor(typeArg: string, fields: ObjectVecFields<V>,
    ) {
        this.$fullTypeName = composeSuiType(ObjectVec.$typeName,
        typeArg) as `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::object_vec::ObjectVec<${PhantomToTypeStr<V>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.size = fields.size;
    }

    static reified<V extends PhantomReified<PhantomTypeArgument>>(
        V: V
    ): ObjectVecReified<ToPhantomTypeArgument<V>> {
        return {
            typeName: ObjectVec.$typeName,
            fullTypeName: composeSuiType(
                ObjectVec.$typeName,
                ...[extractType(V)]
            ) as `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::object_vec::ObjectVec<${PhantomToTypeStr<ToPhantomTypeArgument<V>>}>`,
            typeArgs: [V],
            fromFields: (fields: Record<string, any>) =>
                ObjectVec.fromFields(
                    V,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ObjectVec.fromFieldsWithTypes(
                    V,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ObjectVec.fromBcs(
                    V,
                    data,
                ),
            bcs: ObjectVec.bcs,
            fromJSONField: (field: any) =>
                ObjectVec.fromJSONField(
                    V,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ObjectVec.fromJSON(
                    V,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => ObjectVec.fetch(
                client,
                V,
                id,
            ),
            new: (
                fields: ObjectVecFields<ToPhantomTypeArgument<V>>,
            ) => {
                return new ObjectVec(
                    extractType(V),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ObjectVec.reified
    }

    static phantom<V extends PhantomReified<PhantomTypeArgument>>(
        V: V
    ): PhantomReified<ToTypeStr<ObjectVec<ToPhantomTypeArgument<V>>>> {
        return phantom(ObjectVec.reified(
            V
        ));
    }

    static get p() {
        return ObjectVec.phantom
    }

    static get bcs() {
        return bcs.struct("ObjectVec", {
            id:
                UID.bcs
            , size:
                bcs.u64()

        })
    };

    static fromFields<V extends PhantomReified<PhantomTypeArgument>>(
        typeArg: V, fields: Record<string, any>
    ): ObjectVec<ToPhantomTypeArgument<V>> {
        return ObjectVec.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), size: decodeFromFields("u64", fields.size)}
        )
    }

    static fromFieldsWithTypes<V extends PhantomReified<PhantomTypeArgument>>(
        typeArg: V, item: FieldsWithTypes
    ): ObjectVec<ToPhantomTypeArgument<V>> {
        if (!isObjectVec(item.type)) {
            throw new Error("not a ObjectVec type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return ObjectVec.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), size: decodeFromFieldsWithTypes("u64", item.fields.size)}
        )
    }

    static fromBcs<V extends PhantomReified<PhantomTypeArgument>>(
        typeArg: V, data: Uint8Array
    ): ObjectVec<ToPhantomTypeArgument<V>> {

        return ObjectVec.fromFields(
            typeArg,
            ObjectVec.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,size: this.size.toString(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<V extends PhantomReified<PhantomTypeArgument>>(
        typeArg: V, field: any
    ): ObjectVec<ToPhantomTypeArgument<V>> {
        return ObjectVec.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), size: decodeFromJSONField("u64", field.size)}
        )
    }

    static fromJSON<V extends PhantomReified<PhantomTypeArgument>>(
        typeArg: V, json: Record<string, any>
    ): ObjectVec<ToPhantomTypeArgument<V>> {
        if (json.$typeName !== ObjectVec.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(ObjectVec.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return ObjectVec.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<V extends PhantomReified<PhantomTypeArgument>>(
        typeArg: V, content: SuiParsedData
    ): ObjectVec<ToPhantomTypeArgument<V>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isObjectVec(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ObjectVec object`);
        }
        return ObjectVec.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<V extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: V, id: string
    ): Promise<ObjectVec<ToPhantomTypeArgument<V>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ObjectVec object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isObjectVec(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ObjectVec object`);
        }

        return ObjectVec.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
