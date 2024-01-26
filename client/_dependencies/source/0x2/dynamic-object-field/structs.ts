import {PhantomReified, Reified, ToField, ToTypeArgument, ToTypeStr, TypeArgument, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom, toBcs} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {BcsType, bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Wrapper =============================== */

export function isWrapper(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::dynamic_object_field::Wrapper<");
}

export interface WrapperFields<Name extends TypeArgument> {
    name: ToField<Name>
}

export type WrapperReified<Name extends TypeArgument> = Reified<
    Wrapper<Name>,
    WrapperFields<Name>
>;

export class Wrapper<Name extends TypeArgument> {
    static readonly $typeName = "0x2::dynamic_object_field::Wrapper";
    static readonly $numTypeParams = 1;

    readonly $typeName = Wrapper.$typeName;

    readonly $fullTypeName: `0x2::dynamic_object_field::Wrapper<${ToTypeStr<Name>}>`;

    readonly $typeArg: string;

    ;

    readonly name:
        ToField<Name>

    private constructor(typeArg: string, fields: WrapperFields<Name>,
    ) {
        this.$fullTypeName = composeSuiType(Wrapper.$typeName,
        typeArg) as `0x2::dynamic_object_field::Wrapper<${ToTypeStr<Name>}>`;

        this.$typeArg = typeArg;

        this.name = fields.name;
    }

    static reified<Name extends Reified<TypeArgument, any>>(
        Name: Name
    ): WrapperReified<ToTypeArgument<Name>> {
        return {
            typeName: Wrapper.$typeName,
            fullTypeName: composeSuiType(
                Wrapper.$typeName,
                ...[extractType(Name)]
            ) as `0x2::dynamic_object_field::Wrapper<${ToTypeStr<ToTypeArgument<Name>>}>`,
            typeArgs: [Name],
            fromFields: (fields: Record<string, any>) =>
                Wrapper.fromFields(
                    Name,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Wrapper.fromFieldsWithTypes(
                    Name,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Wrapper.fromBcs(
                    Name,
                    data,
                ),
            bcs: Wrapper.bcs(toBcs(Name)),
            fromJSONField: (field: any) =>
                Wrapper.fromJSONField(
                    Name,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Wrapper.fromJSON(
                    Name,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Wrapper.fetch(
                client,
                Name,
                id,
            ),
            new: (
                fields: WrapperFields<ToTypeArgument<Name>>,
            ) => {
                return new Wrapper(
                    extractType(Name),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Wrapper.reified
    }

    static phantom<Name extends Reified<TypeArgument, any>>(
        Name: Name
    ): PhantomReified<ToTypeStr<Wrapper<ToTypeArgument<Name>>>> {
        return phantom(Wrapper.reified(
            Name
        ));
    }

    static get p() {
        return Wrapper.phantom
    }

    static get bcs() {
        return <Name extends BcsType<any>>(Name: Name) => bcs.struct(`Wrapper<${Name.name}>`, {
            name:
                Name

        })
    };

    static fromFields<Name extends Reified<TypeArgument, any>>(
        typeArg: Name, fields: Record<string, any>
    ): Wrapper<ToTypeArgument<Name>> {
        return Wrapper.reified(
            typeArg,
        ).new(
            {name: decodeFromFields(typeArg, fields.name)}
        )
    }

    static fromFieldsWithTypes<Name extends Reified<TypeArgument, any>>(
        typeArg: Name, item: FieldsWithTypes
    ): Wrapper<ToTypeArgument<Name>> {
        if (!isWrapper(item.type)) {
            throw new Error("not a Wrapper type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Wrapper.reified(
            typeArg,
        ).new(
            {name: decodeFromFieldsWithTypes(typeArg, item.fields.name)}
        )
    }

    static fromBcs<Name extends Reified<TypeArgument, any>>(
        typeArg: Name, data: Uint8Array
    ): Wrapper<ToTypeArgument<Name>> {
        const typeArgs = [typeArg];

        return Wrapper.fromFields(
            typeArg,
            Wrapper.bcs(toBcs(typeArgs[0])).parse(data)
        )
    }

    toJSONField() {
        return {
            name: fieldToJSON<Name>(this.$typeArg, this.name),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<Name extends Reified<TypeArgument, any>>(
        typeArg: Name, field: any
    ): Wrapper<ToTypeArgument<Name>> {
        return Wrapper.reified(
            typeArg,
        ).new(
            {name: decodeFromJSONField(typeArg, field.name)}
        )
    }

    static fromJSON<Name extends Reified<TypeArgument, any>>(
        typeArg: Name, json: Record<string, any>
    ): Wrapper<ToTypeArgument<Name>> {
        if (json.$typeName !== Wrapper.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Wrapper.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Wrapper.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<Name extends Reified<TypeArgument, any>>(
        typeArg: Name, content: SuiParsedData
    ): Wrapper<ToTypeArgument<Name>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWrapper(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Wrapper object`);
        }
        return Wrapper.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<Name extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArg: Name, id: string
    ): Promise<Wrapper<ToTypeArgument<Name>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Wrapper object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWrapper(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Wrapper object`);
        }

        return Wrapper.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
