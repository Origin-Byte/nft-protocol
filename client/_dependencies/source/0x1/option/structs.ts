import * as reified from "../../../../_framework/reified";
import {PhantomReified, Reified, ToField, ToTypeArgument, ToTypeStr, TypeArgument, Vector, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom, toBcs} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {BcsType, bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Option =============================== */

export function isOption(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x1::option::Option<");
}

export interface OptionFields<Element extends TypeArgument> {
    vec: ToField<Vector<Element>>
}

export type OptionReified<Element extends TypeArgument> = Reified<
    Option<Element>,
    OptionFields<Element>
>;

export class Option<Element extends TypeArgument> {
    static readonly $typeName = "0x1::option::Option";
    static readonly $numTypeParams = 1;

    __inner: Element = null as unknown as Element; // for type checking in reified.ts

    ;

    readonly $typeName = Option.$typeName;

    readonly $fullTypeName: `0x1::option::Option<${ToTypeStr<Element>}>`;

    readonly $typeArg: string;

    ;

    readonly vec:
        ToField<Vector<Element>>

    private constructor(typeArg: string, fields: OptionFields<Element>,
    ) {
        this.$fullTypeName = composeSuiType(Option.$typeName,
        typeArg) as `0x1::option::Option<${ToTypeStr<Element>}>`;

        this.$typeArg = typeArg;

        this.vec = fields.vec;
    }

    static reified<Element extends Reified<TypeArgument, any>>(
        Element: Element
    ): OptionReified<ToTypeArgument<Element>> {
        return {
            typeName: Option.$typeName,
            fullTypeName: composeSuiType(
                Option.$typeName,
                ...[extractType(Element)]
            ) as `0x1::option::Option<${ToTypeStr<ToTypeArgument<Element>>}>`,
            typeArgs: [Element],
            fromFields: (fields: Record<string, any>) =>
                Option.fromFields(
                    Element,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Option.fromFieldsWithTypes(
                    Element,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Option.fromBcs(
                    Element,
                    data,
                ),
            bcs: Option.bcs(toBcs(Element)),
            fromJSONField: (field: any) =>
                Option.fromJSONField(
                    Element,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Option.fromJSON(
                    Element,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Option.fetch(
                client,
                Element,
                id,
            ),
            new: (
                fields: OptionFields<ToTypeArgument<Element>>,
            ) => {
                return new Option(
                    extractType(Element),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Option.reified
    }

    static phantom<Element extends Reified<TypeArgument, any>>(
        Element: Element
    ): PhantomReified<ToTypeStr<Option<ToTypeArgument<Element>>>> {
        return phantom(Option.reified(
            Element
        ));
    }

    static get p() {
        return Option.phantom
    }

    static get bcs() {
        return <Element extends BcsType<any>>(Element: Element) => bcs.struct(`Option<${Element.name}>`, {
            vec:
                bcs.vector(Element)

        })
    };

    static fromFields<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, fields: Record<string, any>
    ): Option<ToTypeArgument<Element>> {
        return Option.reified(
            typeArg,
        ).new(
            {vec: decodeFromFields(reified.vector(typeArg), fields.vec)}
        )
    }

    static fromFieldsWithTypes<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, item: FieldsWithTypes
    ): Option<ToTypeArgument<Element>> {
        if (!isOption(item.type)) {
            throw new Error("not a Option type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Option.reified(
            typeArg,
        ).new(
            {vec: decodeFromFieldsWithTypes(reified.vector(typeArg), item.fields.vec)}
        )
    }

    static fromBcs<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, data: Uint8Array
    ): Option<ToTypeArgument<Element>> {
        const typeArgs = [typeArg];

        return Option.fromFields(
            typeArg,
            Option.bcs(toBcs(typeArgs[0])).parse(data)
        )
    }

    toJSONField() {
        return {
            vec: fieldToJSON<Vector<Element>>(`vector<${this.$typeArg}>`, this.vec),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, field: any
    ): Option<ToTypeArgument<Element>> {
        return Option.reified(
            typeArg,
        ).new(
            {vec: decodeFromJSONField(reified.vector(typeArg), field.vec)}
        )
    }

    static fromJSON<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, json: Record<string, any>
    ): Option<ToTypeArgument<Element>> {
        if (json.$typeName !== Option.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Option.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Option.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, content: SuiParsedData
    ): Option<ToTypeArgument<Element>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isOption(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Option object`);
        }
        return Option.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<Element extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArg: Element, id: string
    ): Promise<Option<ToTypeArgument<Element>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Option object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isOption(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Option object`);
        }

        return Option.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
