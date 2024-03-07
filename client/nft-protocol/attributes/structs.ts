import {String} from "../../_dependencies/source/0x1/ascii/structs";
import {VecMap} from "../../_dependencies/source/0x2/vec-map/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Attributes =============================== */

export function isAttributes(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::attributes::Attributes";
}

export interface AttributesFields {
    map: ToField<VecMap<String, String>>
}

export type AttributesReified = Reified<
    Attributes,
    AttributesFields
>;

export class Attributes implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::attributes::Attributes";
    static readonly $numTypeParams = 0;

    readonly $typeName = Attributes.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::attributes::Attributes";

    readonly $typeArgs: [];

    readonly map:
        ToField<VecMap<String, String>>

    private constructor(typeArgs: [], fields: AttributesFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Attributes.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::attributes::Attributes";
        this.$typeArgs = typeArgs;

        this.map = fields.map;
    }

    static reified(): AttributesReified {
        return {
            typeName: Attributes.$typeName,
            fullTypeName: composeSuiType(
                Attributes.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::attributes::Attributes",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Attributes.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Attributes.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Attributes.fromBcs(
                    data,
                ),
            bcs: Attributes.bcs,
            fromJSONField: (field: any) =>
                Attributes.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Attributes.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Attributes.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Attributes.fetch(
                client,
                id,
            ),
            new: (
                fields: AttributesFields,
            ) => {
                return new Attributes(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Attributes.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Attributes>> {
        return phantom(Attributes.reified());
    }

    static get p() {
        return Attributes.phantom()
    }

    static get bcs() {
        return bcs.struct("Attributes", {
            map:
                VecMap.bcs(String.bcs, String.bcs)

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Attributes {
        return Attributes.reified().new(
            {map: decodeFromFields(VecMap.reified(String.reified(), String.reified()), fields.map)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Attributes {
        if (!isAttributes(item.type)) {
            throw new Error("not a Attributes type");
        }

        return Attributes.reified().new(
            {map: decodeFromFieldsWithTypes(VecMap.reified(String.reified(), String.reified()), item.fields.map)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Attributes {

        return Attributes.fromFields(
            Attributes.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            map: this.map.toJSONField(),

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
    ): Attributes {
        return Attributes.reified().new(
            {map: decodeFromJSONField(VecMap.reified(String.reified(), String.reified()), field.map)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Attributes {
        if (json.$typeName !== Attributes.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Attributes.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Attributes {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAttributes(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Attributes object`);
        }
        return Attributes.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Attributes> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Attributes object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAttributes(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Attributes object`);
        }

        return Attributes.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
