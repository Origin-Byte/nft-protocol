import * as reified from "../../_framework/reified";
import {PhantomReified, Reified, ToField, ToTypeArgument, ToTypeStr, TypeArgument, Vector, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom, toBcs} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {BcsType, bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== SizedVec =============================== */

export function isSizedVec(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::sized_vec::SizedVec<");
}

export interface SizedVecFields<Element extends TypeArgument> {
    capacity: ToField<"u64">; vec: ToField<Vector<Element>>
}

export type SizedVecReified<Element extends TypeArgument> = Reified<
    SizedVec<Element>,
    SizedVecFields<Element>
>;

export class SizedVec<Element extends TypeArgument> {
    static readonly $typeName = "0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::sized_vec::SizedVec";
    static readonly $numTypeParams = 1;

    readonly $typeName = SizedVec.$typeName;

    readonly $fullTypeName: `0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::sized_vec::SizedVec<${ToTypeStr<Element>}>`;

    readonly $typeArg: string;

    ;

    readonly capacity:
        ToField<"u64">
    ; readonly vec:
        ToField<Vector<Element>>

    private constructor(typeArg: string, fields: SizedVecFields<Element>,
    ) {
        this.$fullTypeName = composeSuiType(SizedVec.$typeName,
        typeArg) as `0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::sized_vec::SizedVec<${ToTypeStr<Element>}>`;

        this.$typeArg = typeArg;

        this.capacity = fields.capacity;; this.vec = fields.vec;
    }

    static reified<Element extends Reified<TypeArgument, any>>(
        Element: Element
    ): SizedVecReified<ToTypeArgument<Element>> {
        return {
            typeName: SizedVec.$typeName,
            fullTypeName: composeSuiType(
                SizedVec.$typeName,
                ...[extractType(Element)]
            ) as `0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::sized_vec::SizedVec<${ToTypeStr<ToTypeArgument<Element>>}>`,
            typeArgs: [Element],
            fromFields: (fields: Record<string, any>) =>
                SizedVec.fromFields(
                    Element,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                SizedVec.fromFieldsWithTypes(
                    Element,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                SizedVec.fromBcs(
                    Element,
                    data,
                ),
            bcs: SizedVec.bcs(toBcs(Element)),
            fromJSONField: (field: any) =>
                SizedVec.fromJSONField(
                    Element,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                SizedVec.fromJSON(
                    Element,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => SizedVec.fetch(
                client,
                Element,
                id,
            ),
            new: (
                fields: SizedVecFields<ToTypeArgument<Element>>,
            ) => {
                return new SizedVec(
                    extractType(Element),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return SizedVec.reified
    }

    static phantom<Element extends Reified<TypeArgument, any>>(
        Element: Element
    ): PhantomReified<ToTypeStr<SizedVec<ToTypeArgument<Element>>>> {
        return phantom(SizedVec.reified(
            Element
        ));
    }

    static get p() {
        return SizedVec.phantom
    }

    static get bcs() {
        return <Element extends BcsType<any>>(Element: Element) => bcs.struct(`SizedVec<${Element.name}>`, {
            capacity:
                bcs.u64()
            , vec:
                bcs.vector(Element)

        })
    };

    static fromFields<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, fields: Record<string, any>
    ): SizedVec<ToTypeArgument<Element>> {
        return SizedVec.reified(
            typeArg,
        ).new(
            {capacity: decodeFromFields("u64", fields.capacity), vec: decodeFromFields(reified.vector(typeArg), fields.vec)}
        )
    }

    static fromFieldsWithTypes<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, item: FieldsWithTypes
    ): SizedVec<ToTypeArgument<Element>> {
        if (!isSizedVec(item.type)) {
            throw new Error("not a SizedVec type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return SizedVec.reified(
            typeArg,
        ).new(
            {capacity: decodeFromFieldsWithTypes("u64", item.fields.capacity), vec: decodeFromFieldsWithTypes(reified.vector(typeArg), item.fields.vec)}
        )
    }

    static fromBcs<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, data: Uint8Array
    ): SizedVec<ToTypeArgument<Element>> {
        const typeArgs = [typeArg];

        return SizedVec.fromFields(
            typeArg,
            SizedVec.bcs(toBcs(typeArgs[0])).parse(data)
        )
    }

    toJSONField() {
        return {
            capacity: this.capacity.toString(),vec: fieldToJSON<Vector<Element>>(`vector<${this.$typeArg}>`, this.vec),

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
    ): SizedVec<ToTypeArgument<Element>> {
        return SizedVec.reified(
            typeArg,
        ).new(
            {capacity: decodeFromJSONField("u64", field.capacity), vec: decodeFromJSONField(reified.vector(typeArg), field.vec)}
        )
    }

    static fromJSON<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, json: Record<string, any>
    ): SizedVec<ToTypeArgument<Element>> {
        if (json.$typeName !== SizedVec.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(SizedVec.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return SizedVec.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, content: SuiParsedData
    ): SizedVec<ToTypeArgument<Element>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isSizedVec(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a SizedVec object`);
        }
        return SizedVec.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<Element extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArg: Element, id: string
    ): Promise<SizedVec<ToTypeArgument<Element>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching SizedVec object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isSizedVec(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a SizedVec object`);
        }

        return SizedVec.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
