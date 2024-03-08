import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== LIQUIDITY_LAYER =============================== */

export function isLIQUIDITY_LAYER(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::liquidity_layer::LIQUIDITY_LAYER";
}

export interface LIQUIDITY_LAYERFields {
    dummyField: ToField<"bool">
}

export type LIQUIDITY_LAYERReified = Reified<
    LIQUIDITY_LAYER,
    LIQUIDITY_LAYERFields
>;

export class LIQUIDITY_LAYER implements StructClass {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::liquidity_layer::LIQUIDITY_LAYER";
    static readonly $numTypeParams = 0;

    readonly $typeName = LIQUIDITY_LAYER.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::liquidity_layer::LIQUIDITY_LAYER";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: LIQUIDITY_LAYERFields,
    ) {
        this.$fullTypeName = composeSuiType(
            LIQUIDITY_LAYER.$typeName,
            ...typeArgs
        ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::liquidity_layer::LIQUIDITY_LAYER";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): LIQUIDITY_LAYERReified {
        return {
            typeName: LIQUIDITY_LAYER.$typeName,
            fullTypeName: composeSuiType(
                LIQUIDITY_LAYER.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::liquidity_layer::LIQUIDITY_LAYER",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                LIQUIDITY_LAYER.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                LIQUIDITY_LAYER.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                LIQUIDITY_LAYER.fromBcs(
                    data,
                ),
            bcs: LIQUIDITY_LAYER.bcs,
            fromJSONField: (field: any) =>
                LIQUIDITY_LAYER.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                LIQUIDITY_LAYER.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                LIQUIDITY_LAYER.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => LIQUIDITY_LAYER.fetch(
                client,
                id,
            ),
            new: (
                fields: LIQUIDITY_LAYERFields,
            ) => {
                return new LIQUIDITY_LAYER(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return LIQUIDITY_LAYER.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<LIQUIDITY_LAYER>> {
        return phantom(LIQUIDITY_LAYER.reified());
    }

    static get p() {
        return LIQUIDITY_LAYER.phantom()
    }

    static get bcs() {
        return bcs.struct("LIQUIDITY_LAYER", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): LIQUIDITY_LAYER {
        return LIQUIDITY_LAYER.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): LIQUIDITY_LAYER {
        if (!isLIQUIDITY_LAYER(item.type)) {
            throw new Error("not a LIQUIDITY_LAYER type");
        }

        return LIQUIDITY_LAYER.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): LIQUIDITY_LAYER {

        return LIQUIDITY_LAYER.fromFields(
            LIQUIDITY_LAYER.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            dummyField: this.dummyField,

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField(
         field: any
    ): LIQUIDITY_LAYER {
        return LIQUIDITY_LAYER.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): LIQUIDITY_LAYER {
        if (json.$typeName !== LIQUIDITY_LAYER.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return LIQUIDITY_LAYER.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): LIQUIDITY_LAYER {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isLIQUIDITY_LAYER(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a LIQUIDITY_LAYER object`);
        }
        return LIQUIDITY_LAYER.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<LIQUIDITY_LAYER> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching LIQUIDITY_LAYER object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isLIQUIDITY_LAYER(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a LIQUIDITY_LAYER object`);
        }

        return LIQUIDITY_LAYER.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
