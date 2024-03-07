import * as reified from "../../../../_framework/reified";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {Table} from "../table/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== TableVec =============================== */

export function isTableVec(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::table_vec::TableVec<");
}

export interface TableVecFields<Element extends PhantomTypeArgument> {
    contents: ToField<Table<"u64", Element>>
}

export type TableVecReified<Element extends PhantomTypeArgument> = Reified<
    TableVec<Element>,
    TableVecFields<Element>
>;

export class TableVec<Element extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x2::table_vec::TableVec";
    static readonly $numTypeParams = 1;

    readonly $typeName = TableVec.$typeName;

    readonly $fullTypeName: `0x2::table_vec::TableVec<${PhantomToTypeStr<Element>}>`;

    readonly $typeArgs: [PhantomToTypeStr<Element>];

    readonly contents:
        ToField<Table<"u64", Element>>

    private constructor(typeArgs: [PhantomToTypeStr<Element>], fields: TableVecFields<Element>,
    ) {
        this.$fullTypeName = composeSuiType(
            TableVec.$typeName,
            ...typeArgs
        ) as `0x2::table_vec::TableVec<${PhantomToTypeStr<Element>}>`;
        this.$typeArgs = typeArgs;

        this.contents = fields.contents;
    }

    static reified<Element extends PhantomReified<PhantomTypeArgument>>(
        Element: Element
    ): TableVecReified<ToPhantomTypeArgument<Element>> {
        return {
            typeName: TableVec.$typeName,
            fullTypeName: composeSuiType(
                TableVec.$typeName,
                ...[extractType(Element)]
            ) as `0x2::table_vec::TableVec<${PhantomToTypeStr<ToPhantomTypeArgument<Element>>}>`,
            typeArgs: [
                extractType(Element)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<Element>>],
            reifiedTypeArgs: [Element],
            fromFields: (fields: Record<string, any>) =>
                TableVec.fromFields(
                    Element,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TableVec.fromFieldsWithTypes(
                    Element,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TableVec.fromBcs(
                    Element,
                    data,
                ),
            bcs: TableVec.bcs,
            fromJSONField: (field: any) =>
                TableVec.fromJSONField(
                    Element,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TableVec.fromJSON(
                    Element,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                TableVec.fromSuiParsedData(
                    Element,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => TableVec.fetch(
                client,
                Element,
                id,
            ),
            new: (
                fields: TableVecFields<ToPhantomTypeArgument<Element>>,
            ) => {
                return new TableVec(
                    [extractType(Element)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TableVec.reified
    }

    static phantom<Element extends PhantomReified<PhantomTypeArgument>>(
        Element: Element
    ): PhantomReified<ToTypeStr<TableVec<ToPhantomTypeArgument<Element>>>> {
        return phantom(TableVec.reified(
            Element
        ));
    }

    static get p() {
        return TableVec.phantom
    }

    static get bcs() {
        return bcs.struct("TableVec", {
            contents:
                Table.bcs

        })
    };

    static fromFields<Element extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Element, fields: Record<string, any>
    ): TableVec<ToPhantomTypeArgument<Element>> {
        return TableVec.reified(
            typeArg,
        ).new(
            {contents: decodeFromFields(Table.reified(reified.phantom("u64"), typeArg), fields.contents)}
        )
    }

    static fromFieldsWithTypes<Element extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Element, item: FieldsWithTypes
    ): TableVec<ToPhantomTypeArgument<Element>> {
        if (!isTableVec(item.type)) {
            throw new Error("not a TableVec type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return TableVec.reified(
            typeArg,
        ).new(
            {contents: decodeFromFieldsWithTypes(Table.reified(reified.phantom("u64"), typeArg), item.fields.contents)}
        )
    }

    static fromBcs<Element extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Element, data: Uint8Array
    ): TableVec<ToPhantomTypeArgument<Element>> {

        return TableVec.fromFields(
            typeArg,
            TableVec.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            contents: this.contents.toJSONField(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<Element extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Element, field: any
    ): TableVec<ToPhantomTypeArgument<Element>> {
        return TableVec.reified(
            typeArg,
        ).new(
            {contents: decodeFromJSONField(Table.reified(reified.phantom("u64"), typeArg), field.contents)}
        )
    }

    static fromJSON<Element extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Element, json: Record<string, any>
    ): TableVec<ToPhantomTypeArgument<Element>> {
        if (json.$typeName !== TableVec.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(TableVec.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return TableVec.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<Element extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Element, content: SuiParsedData
    ): TableVec<ToPhantomTypeArgument<Element>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTableVec(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TableVec object`);
        }
        return TableVec.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<Element extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: Element, id: string
    ): Promise<TableVec<ToPhantomTypeArgument<Element>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TableVec object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTableVec(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TableVec object`);
        }

        return TableVec.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
