import {VecSet} from "../../_dependencies/source/0x2/vec-set/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Creators =============================== */

export function isCreators(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::creators::Creators";
}

export interface CreatorsFields {
    creators: ToField<VecSet<"address">>
}

export type CreatorsReified = Reified<
    Creators,
    CreatorsFields
>;

export class Creators implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::creators::Creators";
    static readonly $numTypeParams = 0;

    readonly $typeName = Creators.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::creators::Creators";

    readonly $typeArgs: [];

    readonly creators:
        ToField<VecSet<"address">>

    private constructor(typeArgs: [], fields: CreatorsFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Creators.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::creators::Creators";
        this.$typeArgs = typeArgs;

        this.creators = fields.creators;
    }

    static reified(): CreatorsReified {
        return {
            typeName: Creators.$typeName,
            fullTypeName: composeSuiType(
                Creators.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::creators::Creators",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Creators.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Creators.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Creators.fromBcs(
                    data,
                ),
            bcs: Creators.bcs,
            fromJSONField: (field: any) =>
                Creators.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Creators.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Creators.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Creators.fetch(
                client,
                id,
            ),
            new: (
                fields: CreatorsFields,
            ) => {
                return new Creators(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Creators.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Creators>> {
        return phantom(Creators.reified());
    }

    static get p() {
        return Creators.phantom()
    }

    static get bcs() {
        return bcs.struct("Creators", {
            creators:
                VecSet.bcs(bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),}))

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Creators {
        return Creators.reified().new(
            {creators: decodeFromFields(VecSet.reified("address"), fields.creators)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Creators {
        if (!isCreators(item.type)) {
            throw new Error("not a Creators type");
        }

        return Creators.reified().new(
            {creators: decodeFromFieldsWithTypes(VecSet.reified("address"), item.fields.creators)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Creators {

        return Creators.fromFields(
            Creators.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            creators: this.creators.toJSONField(),

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
    ): Creators {
        return Creators.reified().new(
            {creators: decodeFromJSONField(VecSet.reified("address"), field.creators)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Creators {
        if (json.$typeName !== Creators.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Creators.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Creators {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isCreators(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Creators object`);
        }
        return Creators.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Creators> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Creators object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isCreators(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Creators object`);
        }

        return Creators.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
