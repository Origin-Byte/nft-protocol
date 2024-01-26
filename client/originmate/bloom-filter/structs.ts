import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Filter =============================== */

export function isFilter(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::bloom_filter::Filter";
}

export interface FilterFields {
    bitmap: ToField<"u256">; hashCount: ToField<"u8">
}

export type FilterReified = Reified<
    Filter,
    FilterFields
>;

export class Filter {
    static readonly $typeName = "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::bloom_filter::Filter";
    static readonly $numTypeParams = 0;

    readonly $typeName = Filter.$typeName;

    readonly $fullTypeName: "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::bloom_filter::Filter";

    ;

    readonly bitmap:
        ToField<"u256">
    ; readonly hashCount:
        ToField<"u8">

    private constructor( fields: FilterFields,
    ) {
        this.$fullTypeName = Filter.$typeName;

        this.bitmap = fields.bitmap;; this.hashCount = fields.hashCount;
    }

    static reified(): FilterReified {
        return {
            typeName: Filter.$typeName,
            fullTypeName: composeSuiType(
                Filter.$typeName,
                ...[]
            ) as "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::bloom_filter::Filter",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Filter.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Filter.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Filter.fromBcs(
                    data,
                ),
            bcs: Filter.bcs,
            fromJSONField: (field: any) =>
                Filter.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Filter.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Filter.fetch(
                client,
                id,
            ),
            new: (
                fields: FilterFields,
            ) => {
                return new Filter(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Filter.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Filter>> {
        return phantom(Filter.reified());
    }

    static get p() {
        return Filter.phantom()
    }

    static get bcs() {
        return bcs.struct("Filter", {
            bitmap:
                bcs.u256()
            , hash_count:
                bcs.u8()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Filter {
        return Filter.reified().new(
            {bitmap: decodeFromFields("u256", fields.bitmap), hashCount: decodeFromFields("u8", fields.hash_count)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Filter {
        if (!isFilter(item.type)) {
            throw new Error("not a Filter type");
        }

        return Filter.reified().new(
            {bitmap: decodeFromFieldsWithTypes("u256", item.fields.bitmap), hashCount: decodeFromFieldsWithTypes("u8", item.fields.hash_count)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Filter {

        return Filter.fromFields(
            Filter.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            bitmap: this.bitmap.toString(),hashCount: this.hashCount,

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            ...this.toJSONField()
        }
    }

    static fromJSONField(
         field: any
    ): Filter {
        return Filter.reified().new(
            {bitmap: decodeFromJSONField("u256", field.bitmap), hashCount: decodeFromJSONField("u8", field.hashCount)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Filter {
        if (json.$typeName !== Filter.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Filter.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Filter {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isFilter(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Filter object`);
        }
        return Filter.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Filter> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Filter object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isFilter(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Filter object`);
        }

        return Filter.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
