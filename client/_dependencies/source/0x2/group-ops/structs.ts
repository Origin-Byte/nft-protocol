import * as reified from "../../../../_framework/reified";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, Vector, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Element =============================== */

export function isElement(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::group_ops::Element<");
}

export interface ElementFields<T extends PhantomTypeArgument> {
    bytes: ToField<Vector<"u8">>
}

export type ElementReified<T extends PhantomTypeArgument> = Reified<
    Element<T>,
    ElementFields<T>
>;

export class Element<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x2::group_ops::Element";
    static readonly $numTypeParams = 1;

    readonly $typeName = Element.$typeName;

    readonly $fullTypeName: `0x2::group_ops::Element<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly bytes:
        ToField<Vector<"u8">>

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: ElementFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            Element.$typeName,
            ...typeArgs
        ) as `0x2::group_ops::Element<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.bytes = fields.bytes;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): ElementReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Element.$typeName,
            fullTypeName: composeSuiType(
                Element.$typeName,
                ...[extractType(T)]
            ) as `0x2::group_ops::Element<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Element.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Element.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Element.fromBcs(
                    T,
                    data,
                ),
            bcs: Element.bcs,
            fromJSONField: (field: any) =>
                Element.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Element.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Element.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Element.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: ElementFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Element(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Element.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Element<ToPhantomTypeArgument<T>>>> {
        return phantom(Element.reified(
            T
        ));
    }

    static get p() {
        return Element.phantom
    }

    static get bcs() {
        return bcs.struct("Element", {
            bytes:
                bcs.vector(bcs.u8())

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Element<ToPhantomTypeArgument<T>> {
        return Element.reified(
            typeArg,
        ).new(
            {bytes: decodeFromFields(reified.vector("u8"), fields.bytes)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Element<ToPhantomTypeArgument<T>> {
        if (!isElement(item.type)) {
            throw new Error("not a Element type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Element.reified(
            typeArg,
        ).new(
            {bytes: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.bytes)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Element<ToPhantomTypeArgument<T>> {

        return Element.fromFields(
            typeArg,
            Element.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            bytes: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.bytes),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): Element<ToPhantomTypeArgument<T>> {
        return Element.reified(
            typeArg,
        ).new(
            {bytes: decodeFromJSONField(reified.vector("u8"), field.bytes)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Element<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Element.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Element.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return Element.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Element<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isElement(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Element object`);
        }
        return Element.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Element<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Element object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isElement(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Element object`);
        }

        return Element.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
