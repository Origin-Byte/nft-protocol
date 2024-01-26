import * as reified from "../../_framework/reified";
import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, Reified, ToField, ToTypeArgument, ToTypeStr, TypeArgument, Vector, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom, toBcs} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {BcsType, bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== DynVec =============================== */

export function isDynVec(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::dynamic_vector::DynVec<");
}

export interface DynVecFields<Element extends TypeArgument> {
    vec0: ToField<Vector<Element>>; vecs: ToField<UID>; currentChunk: ToField<"u64">; tipLength: ToField<"u64">; totalLength: ToField<"u64">; limit: ToField<"u64">
}

export type DynVecReified<Element extends TypeArgument> = Reified<
    DynVec<Element>,
    DynVecFields<Element>
>;

export class DynVec<Element extends TypeArgument> {
    static readonly $typeName = "0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::dynamic_vector::DynVec";
    static readonly $numTypeParams = 1;

    readonly $typeName = DynVec.$typeName;

    readonly $fullTypeName: `0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::dynamic_vector::DynVec<${ToTypeStr<Element>}>`;

    readonly $typeArg: string;

    ;

    readonly vec0:
        ToField<Vector<Element>>
    ; readonly vecs:
        ToField<UID>
    ; readonly currentChunk:
        ToField<"u64">
    ; readonly tipLength:
        ToField<"u64">
    ; readonly totalLength:
        ToField<"u64">
    ; readonly limit:
        ToField<"u64">

    private constructor(typeArg: string, fields: DynVecFields<Element>,
    ) {
        this.$fullTypeName = composeSuiType(DynVec.$typeName,
        typeArg) as `0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::dynamic_vector::DynVec<${ToTypeStr<Element>}>`;

        this.$typeArg = typeArg;

        this.vec0 = fields.vec0;; this.vecs = fields.vecs;; this.currentChunk = fields.currentChunk;; this.tipLength = fields.tipLength;; this.totalLength = fields.totalLength;; this.limit = fields.limit;
    }

    static reified<Element extends Reified<TypeArgument, any>>(
        Element: Element
    ): DynVecReified<ToTypeArgument<Element>> {
        return {
            typeName: DynVec.$typeName,
            fullTypeName: composeSuiType(
                DynVec.$typeName,
                ...[extractType(Element)]
            ) as `0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::dynamic_vector::DynVec<${ToTypeStr<ToTypeArgument<Element>>}>`,
            typeArgs: [Element],
            fromFields: (fields: Record<string, any>) =>
                DynVec.fromFields(
                    Element,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                DynVec.fromFieldsWithTypes(
                    Element,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                DynVec.fromBcs(
                    Element,
                    data,
                ),
            bcs: DynVec.bcs(toBcs(Element)),
            fromJSONField: (field: any) =>
                DynVec.fromJSONField(
                    Element,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                DynVec.fromJSON(
                    Element,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => DynVec.fetch(
                client,
                Element,
                id,
            ),
            new: (
                fields: DynVecFields<ToTypeArgument<Element>>,
            ) => {
                return new DynVec(
                    extractType(Element),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return DynVec.reified
    }

    static phantom<Element extends Reified<TypeArgument, any>>(
        Element: Element
    ): PhantomReified<ToTypeStr<DynVec<ToTypeArgument<Element>>>> {
        return phantom(DynVec.reified(
            Element
        ));
    }

    static get p() {
        return DynVec.phantom
    }

    static get bcs() {
        return <Element extends BcsType<any>>(Element: Element) => bcs.struct(`DynVec<${Element.name}>`, {
            vec_0:
                bcs.vector(Element)
            , vecs:
                UID.bcs
            , current_chunk:
                bcs.u64()
            , tip_length:
                bcs.u64()
            , total_length:
                bcs.u64()
            , limit:
                bcs.u64()

        })
    };

    static fromFields<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, fields: Record<string, any>
    ): DynVec<ToTypeArgument<Element>> {
        return DynVec.reified(
            typeArg,
        ).new(
            {vec0: decodeFromFields(reified.vector(typeArg), fields.vec_0), vecs: decodeFromFields(UID.reified(), fields.vecs), currentChunk: decodeFromFields("u64", fields.current_chunk), tipLength: decodeFromFields("u64", fields.tip_length), totalLength: decodeFromFields("u64", fields.total_length), limit: decodeFromFields("u64", fields.limit)}
        )
    }

    static fromFieldsWithTypes<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, item: FieldsWithTypes
    ): DynVec<ToTypeArgument<Element>> {
        if (!isDynVec(item.type)) {
            throw new Error("not a DynVec type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return DynVec.reified(
            typeArg,
        ).new(
            {vec0: decodeFromFieldsWithTypes(reified.vector(typeArg), item.fields.vec_0), vecs: decodeFromFieldsWithTypes(UID.reified(), item.fields.vecs), currentChunk: decodeFromFieldsWithTypes("u64", item.fields.current_chunk), tipLength: decodeFromFieldsWithTypes("u64", item.fields.tip_length), totalLength: decodeFromFieldsWithTypes("u64", item.fields.total_length), limit: decodeFromFieldsWithTypes("u64", item.fields.limit)}
        )
    }

    static fromBcs<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, data: Uint8Array
    ): DynVec<ToTypeArgument<Element>> {
        const typeArgs = [typeArg];

        return DynVec.fromFields(
            typeArg,
            DynVec.bcs(toBcs(typeArgs[0])).parse(data)
        )
    }

    toJSONField() {
        return {
            vec0: fieldToJSON<Vector<Element>>(`vector<${this.$typeArg}>`, this.vec0),vecs: this.vecs,currentChunk: this.currentChunk.toString(),tipLength: this.tipLength.toString(),totalLength: this.totalLength.toString(),limit: this.limit.toString(),

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
    ): DynVec<ToTypeArgument<Element>> {
        return DynVec.reified(
            typeArg,
        ).new(
            {vec0: decodeFromJSONField(reified.vector(typeArg), field.vec0), vecs: decodeFromJSONField(UID.reified(), field.vecs), currentChunk: decodeFromJSONField("u64", field.currentChunk), tipLength: decodeFromJSONField("u64", field.tipLength), totalLength: decodeFromJSONField("u64", field.totalLength), limit: decodeFromJSONField("u64", field.limit)}
        )
    }

    static fromJSON<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, json: Record<string, any>
    ): DynVec<ToTypeArgument<Element>> {
        if (json.$typeName !== DynVec.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(DynVec.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return DynVec.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<Element extends Reified<TypeArgument, any>>(
        typeArg: Element, content: SuiParsedData
    ): DynVec<ToTypeArgument<Element>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isDynVec(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a DynVec object`);
        }
        return DynVec.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<Element extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArg: Element, id: string
    ): Promise<DynVec<ToTypeArgument<Element>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching DynVec object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isDynVec(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a DynVec object`);
        }

        return DynVec.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
