import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, Reified, ToField, ToTypeArgument, ToTypeStr, TypeArgument, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom, toBcs} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {BcsType, bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Box =============================== */

export function isBox(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::box::Box<");
}

export interface BoxFields<T extends TypeArgument> {
    id: ToField<UID>; obj: ToField<T>
}

export type BoxReified<T extends TypeArgument> = Reified<
    Box<T>,
    BoxFields<T>
>;

export class Box<T extends TypeArgument> {
    static readonly $typeName = "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::box::Box";
    static readonly $numTypeParams = 1;

    readonly $typeName = Box.$typeName;

    readonly $fullTypeName: `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::box::Box<${ToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly obj:
        ToField<T>

    private constructor(typeArg: string, fields: BoxFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(Box.$typeName,
        typeArg) as `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::box::Box<${ToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.obj = fields.obj;
    }

    static reified<T extends Reified<TypeArgument, any>>(
        T: T
    ): BoxReified<ToTypeArgument<T>> {
        return {
            typeName: Box.$typeName,
            fullTypeName: composeSuiType(
                Box.$typeName,
                ...[extractType(T)]
            ) as `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::box::Box<${ToTypeStr<ToTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Box.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Box.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Box.fromBcs(
                    T,
                    data,
                ),
            bcs: Box.bcs(toBcs(T)),
            fromJSONField: (field: any) =>
                Box.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Box.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Box.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: BoxFields<ToTypeArgument<T>>,
            ) => {
                return new Box(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Box.reified
    }

    static phantom<T extends Reified<TypeArgument, any>>(
        T: T
    ): PhantomReified<ToTypeStr<Box<ToTypeArgument<T>>>> {
        return phantom(Box.reified(
            T
        ));
    }

    static get p() {
        return Box.phantom
    }

    static get bcs() {
        return <T extends BcsType<any>>(T: T) => bcs.struct(`Box<${T.name}>`, {
            id:
                UID.bcs
            , obj:
                T

        })
    };

    static fromFields<T extends Reified<TypeArgument, any>>(
        typeArg: T, fields: Record<string, any>
    ): Box<ToTypeArgument<T>> {
        return Box.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), obj: decodeFromFields(typeArg, fields.obj)}
        )
    }

    static fromFieldsWithTypes<T extends Reified<TypeArgument, any>>(
        typeArg: T, item: FieldsWithTypes
    ): Box<ToTypeArgument<T>> {
        if (!isBox(item.type)) {
            throw new Error("not a Box type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Box.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), obj: decodeFromFieldsWithTypes(typeArg, item.fields.obj)}
        )
    }

    static fromBcs<T extends Reified<TypeArgument, any>>(
        typeArg: T, data: Uint8Array
    ): Box<ToTypeArgument<T>> {
        const typeArgs = [typeArg];

        return Box.fromFields(
            typeArg,
            Box.bcs(toBcs(typeArgs[0])).parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,obj: fieldToJSON<T>(this.$typeArg, this.obj),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends Reified<TypeArgument, any>>(
        typeArg: T, field: any
    ): Box<ToTypeArgument<T>> {
        return Box.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), obj: decodeFromJSONField(typeArg, field.obj)}
        )
    }

    static fromJSON<T extends Reified<TypeArgument, any>>(
        typeArg: T, json: Record<string, any>
    ): Box<ToTypeArgument<T>> {
        if (json.$typeName !== Box.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Box.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Box.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends Reified<TypeArgument, any>>(
        typeArg: T, content: SuiParsedData
    ): Box<ToTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBox(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Box object`);
        }
        return Box.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Box<ToTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Box object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBox(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Box object`);
        }

        return Box.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
