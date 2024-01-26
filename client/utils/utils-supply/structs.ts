import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Supply =============================== */

export function isSupply(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils_supply::Supply";
}

export interface SupplyFields {
    max: ToField<"u64">; current: ToField<"u64">
}

export type SupplyReified = Reified<
    Supply,
    SupplyFields
>;

export class Supply {
    static readonly $typeName = "0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils_supply::Supply";
    static readonly $numTypeParams = 0;

    readonly $typeName = Supply.$typeName;

    readonly $fullTypeName: "0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils_supply::Supply";

    ;

    readonly max:
        ToField<"u64">
    ; readonly current:
        ToField<"u64">

    private constructor( fields: SupplyFields,
    ) {
        this.$fullTypeName = Supply.$typeName;

        this.max = fields.max;; this.current = fields.current;
    }

    static reified(): SupplyReified {
        return {
            typeName: Supply.$typeName,
            fullTypeName: composeSuiType(
                Supply.$typeName,
                ...[]
            ) as "0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils_supply::Supply",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Supply.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Supply.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Supply.fromBcs(
                    data,
                ),
            bcs: Supply.bcs,
            fromJSONField: (field: any) =>
                Supply.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Supply.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Supply.fetch(
                client,
                id,
            ),
            new: (
                fields: SupplyFields,
            ) => {
                return new Supply(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Supply.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Supply>> {
        return phantom(Supply.reified());
    }

    static get p() {
        return Supply.phantom()
    }

    static get bcs() {
        return bcs.struct("Supply", {
            max:
                bcs.u64()
            , current:
                bcs.u64()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Supply {
        return Supply.reified().new(
            {max: decodeFromFields("u64", fields.max), current: decodeFromFields("u64", fields.current)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Supply {
        if (!isSupply(item.type)) {
            throw new Error("not a Supply type");
        }

        return Supply.reified().new(
            {max: decodeFromFieldsWithTypes("u64", item.fields.max), current: decodeFromFieldsWithTypes("u64", item.fields.current)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Supply {

        return Supply.fromFields(
            Supply.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            max: this.max.toString(),current: this.current.toString(),

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
    ): Supply {
        return Supply.reified().new(
            {max: decodeFromJSONField("u64", field.max), current: decodeFromJSONField("u64", field.current)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Supply {
        if (json.$typeName !== Supply.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Supply.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Supply {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isSupply(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Supply object`);
        }
        return Supply.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Supply> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Supply object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isSupply(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Supply object`);
        }

        return Supply.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
