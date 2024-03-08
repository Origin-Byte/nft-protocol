import * as reified from "../../_framework/reified";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, Vector, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, fieldToJSON, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Svg =============================== */

export function isSvg(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::svg::Svg";
}

export interface SvgFields {
    svg: ToField<Vector<"u8">>
}

export type SvgReified = Reified<
    Svg,
    SvgFields
>;

export class Svg implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::svg::Svg";
    static readonly $numTypeParams = 0;

    readonly $typeName = Svg.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::svg::Svg";

    readonly $typeArgs: [];

    readonly svg:
        ToField<Vector<"u8">>

    private constructor(typeArgs: [], fields: SvgFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Svg.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::svg::Svg";
        this.$typeArgs = typeArgs;

        this.svg = fields.svg;
    }

    static reified(): SvgReified {
        return {
            typeName: Svg.$typeName,
            fullTypeName: composeSuiType(
                Svg.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::svg::Svg",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Svg.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Svg.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Svg.fromBcs(
                    data,
                ),
            bcs: Svg.bcs,
            fromJSONField: (field: any) =>
                Svg.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Svg.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Svg.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Svg.fetch(
                client,
                id,
            ),
            new: (
                fields: SvgFields,
            ) => {
                return new Svg(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Svg.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Svg>> {
        return phantom(Svg.reified());
    }

    static get p() {
        return Svg.phantom()
    }

    static get bcs() {
        return bcs.struct("Svg", {
            svg:
                bcs.vector(bcs.u8())

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Svg {
        return Svg.reified().new(
            {svg: decodeFromFields(reified.vector("u8"), fields.svg)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Svg {
        if (!isSvg(item.type)) {
            throw new Error("not a Svg type");
        }

        return Svg.reified().new(
            {svg: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.svg)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Svg {

        return Svg.fromFields(
            Svg.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            svg: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.svg),

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
    ): Svg {
        return Svg.reified().new(
            {svg: decodeFromJSONField(reified.vector("u8"), field.svg)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Svg {
        if (json.$typeName !== Svg.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Svg.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Svg {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isSvg(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Svg object`);
        }
        return Svg.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Svg> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Svg object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isSvg(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Svg object`);
        }

        return Svg.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
