import {PhantomReified, Reified, StructClass, ToField, ToTypeArgument, ToTypeStr, TypeArgument, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom, toBcs} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {UID} from "../object/structs";
import {BcsType, bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Field =============================== */

export function isField(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::dynamic_field::Field<");
}

export interface FieldFields<Name extends TypeArgument, Value extends TypeArgument> {
    id: ToField<UID>; name: ToField<Name>; value: ToField<Value>
}

export type FieldReified<Name extends TypeArgument, Value extends TypeArgument> = Reified<
    Field<Name, Value>,
    FieldFields<Name, Value>
>;

export class Field<Name extends TypeArgument, Value extends TypeArgument> implements StructClass {
    static readonly $typeName = "0x2::dynamic_field::Field";
    static readonly $numTypeParams = 2;

    readonly $typeName = Field.$typeName;

    readonly $fullTypeName: `0x2::dynamic_field::Field<${ToTypeStr<Name>}, ${ToTypeStr<Value>}>`;

    readonly $typeArgs: [ToTypeStr<Name>, ToTypeStr<Value>];

    readonly id:
        ToField<UID>
    ; readonly name:
        ToField<Name>
    ; readonly value:
        ToField<Value>

    private constructor(typeArgs: [ToTypeStr<Name>, ToTypeStr<Value>], fields: FieldFields<Name, Value>,
    ) {
        this.$fullTypeName = composeSuiType(
            Field.$typeName,
            ...typeArgs
        ) as `0x2::dynamic_field::Field<${ToTypeStr<Name>}, ${ToTypeStr<Value>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.name = fields.name;; this.value = fields.value;
    }

    static reified<Name extends Reified<TypeArgument, any>, Value extends Reified<TypeArgument, any>>(
        Name: Name, Value: Value
    ): FieldReified<ToTypeArgument<Name>, ToTypeArgument<Value>> {
        return {
            typeName: Field.$typeName,
            fullTypeName: composeSuiType(
                Field.$typeName,
                ...[extractType(Name), extractType(Value)]
            ) as `0x2::dynamic_field::Field<${ToTypeStr<ToTypeArgument<Name>>}, ${ToTypeStr<ToTypeArgument<Value>>}>`,
            typeArgs: [
                extractType(Name), extractType(Value)
            ] as [ToTypeStr<ToTypeArgument<Name>>, ToTypeStr<ToTypeArgument<Value>>],
            reifiedTypeArgs: [Name, Value],
            fromFields: (fields: Record<string, any>) =>
                Field.fromFields(
                    [Name, Value],
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Field.fromFieldsWithTypes(
                    [Name, Value],
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Field.fromBcs(
                    [Name, Value],
                    data,
                ),
            bcs: Field.bcs(toBcs(Name), toBcs(Value)),
            fromJSONField: (field: any) =>
                Field.fromJSONField(
                    [Name, Value],
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Field.fromJSON(
                    [Name, Value],
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Field.fromSuiParsedData(
                    [Name, Value],
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Field.fetch(
                client,
                [Name, Value],
                id,
            ),
            new: (
                fields: FieldFields<ToTypeArgument<Name>, ToTypeArgument<Value>>,
            ) => {
                return new Field(
                    [extractType(Name), extractType(Value)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Field.reified
    }

    static phantom<Name extends Reified<TypeArgument, any>, Value extends Reified<TypeArgument, any>>(
        Name: Name, Value: Value
    ): PhantomReified<ToTypeStr<Field<ToTypeArgument<Name>, ToTypeArgument<Value>>>> {
        return phantom(Field.reified(
            Name, Value
        ));
    }

    static get p() {
        return Field.phantom
    }

    static get bcs() {
        return <Name extends BcsType<any>, Value extends BcsType<any>>(Name: Name, Value: Value) => bcs.struct(`Field<${Name.name}, ${Value.name}>`, {
            id:
                UID.bcs
            , name:
                Name
            , value:
                Value

        })
    };

    static fromFields<Name extends Reified<TypeArgument, any>, Value extends Reified<TypeArgument, any>>(
        typeArgs: [Name, Value], fields: Record<string, any>
    ): Field<ToTypeArgument<Name>, ToTypeArgument<Value>> {
        return Field.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), name: decodeFromFields(typeArgs[0], fields.name), value: decodeFromFields(typeArgs[1], fields.value)}
        )
    }

    static fromFieldsWithTypes<Name extends Reified<TypeArgument, any>, Value extends Reified<TypeArgument, any>>(
        typeArgs: [Name, Value], item: FieldsWithTypes
    ): Field<ToTypeArgument<Name>, ToTypeArgument<Value>> {
        if (!isField(item.type)) {
            throw new Error("not a Field type");
        }
        assertFieldsWithTypesArgsMatch(item, typeArgs);

        return Field.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), name: decodeFromFieldsWithTypes(typeArgs[0], item.fields.name), value: decodeFromFieldsWithTypes(typeArgs[1], item.fields.value)}
        )
    }

    static fromBcs<Name extends Reified<TypeArgument, any>, Value extends Reified<TypeArgument, any>>(
        typeArgs: [Name, Value], data: Uint8Array
    ): Field<ToTypeArgument<Name>, ToTypeArgument<Value>> {

        return Field.fromFields(
            typeArgs,
            Field.bcs(toBcs(typeArgs[0]), toBcs(typeArgs[1])).parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,name: fieldToJSON<Name>(this.$typeArgs[0], this.name),value: fieldToJSON<Value>(this.$typeArgs[1], this.value),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<Name extends Reified<TypeArgument, any>, Value extends Reified<TypeArgument, any>>(
        typeArgs: [Name, Value], field: any
    ): Field<ToTypeArgument<Name>, ToTypeArgument<Value>> {
        return Field.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), name: decodeFromJSONField(typeArgs[0], field.name), value: decodeFromJSONField(typeArgs[1], field.value)}
        )
    }

    static fromJSON<Name extends Reified<TypeArgument, any>, Value extends Reified<TypeArgument, any>>(
        typeArgs: [Name, Value], json: Record<string, any>
    ): Field<ToTypeArgument<Name>, ToTypeArgument<Value>> {
        if (json.$typeName !== Field.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Field.$typeName,
            ...typeArgs.map(extractType)),
            json.$typeArgs,
            typeArgs,
        )

        return Field.fromJSONField(
            typeArgs,
            json,
        )
    }

    static fromSuiParsedData<Name extends Reified<TypeArgument, any>, Value extends Reified<TypeArgument, any>>(
        typeArgs: [Name, Value], content: SuiParsedData
    ): Field<ToTypeArgument<Name>, ToTypeArgument<Value>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isField(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Field object`);
        }
        return Field.fromFieldsWithTypes(
            typeArgs,
            content
        );
    }

    static async fetch<Name extends Reified<TypeArgument, any>, Value extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArgs: [Name, Value], id: string
    ): Promise<Field<ToTypeArgument<Name>, ToTypeArgument<Value>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Field object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isField(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Field object`);
        }

        return Field.fromBcs(
            typeArgs,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
