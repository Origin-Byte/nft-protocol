import {ID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== TypedID =============================== */

export function isTypedID(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::typed_id::TypedID<");
}

export interface TypedIDFields<T extends PhantomTypeArgument> {
    id: ToField<ID>
}

export type TypedIDReified<T extends PhantomTypeArgument> = Reified<
    TypedID<T>,
    TypedIDFields<T>
>;

export class TypedID<T extends PhantomTypeArgument> {
    static readonly $typeName = "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::typed_id::TypedID";
    static readonly $numTypeParams = 1;

    readonly $typeName = TypedID.$typeName;

    readonly $fullTypeName: `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::typed_id::TypedID<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<ID>

    private constructor(typeArg: string, fields: TypedIDFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(TypedID.$typeName,
        typeArg) as `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::typed_id::TypedID<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): TypedIDReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: TypedID.$typeName,
            fullTypeName: composeSuiType(
                TypedID.$typeName,
                ...[extractType(T)]
            ) as `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::typed_id::TypedID<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                TypedID.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TypedID.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TypedID.fromBcs(
                    T,
                    data,
                ),
            bcs: TypedID.bcs,
            fromJSONField: (field: any) =>
                TypedID.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TypedID.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => TypedID.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: TypedIDFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new TypedID(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TypedID.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<TypedID<ToPhantomTypeArgument<T>>>> {
        return phantom(TypedID.reified(
            T
        ));
    }

    static get p() {
        return TypedID.phantom
    }

    static get bcs() {
        return bcs.struct("TypedID", {
            id:
                ID.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): TypedID<ToPhantomTypeArgument<T>> {
        return TypedID.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(ID.reified(), fields.id)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): TypedID<ToPhantomTypeArgument<T>> {
        if (!isTypedID(item.type)) {
            throw new Error("not a TypedID type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return TypedID.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): TypedID<ToPhantomTypeArgument<T>> {

        return TypedID.fromFields(
            typeArg,
            TypedID.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): TypedID<ToPhantomTypeArgument<T>> {
        return TypedID.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(ID.reified(), field.id)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): TypedID<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== TypedID.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(TypedID.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return TypedID.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): TypedID<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTypedID(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TypedID object`);
        }
        return TypedID.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<TypedID<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TypedID object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTypedID(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TypedID object`);
        }

        return TypedID.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
