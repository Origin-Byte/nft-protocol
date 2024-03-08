import {Url} from "../../_dependencies/source/0x2/url/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_url::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_url::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_url::Witness";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: WitnessFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Witness.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_url::Witness";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): WitnessReified {
        return {
            typeName: Witness.$typeName,
            fullTypeName: composeSuiType(
                Witness.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_url::Witness",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Witness.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Witness.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Witness.fromBcs(
                    data,
                ),
            bcs: Witness.bcs,
            fromJSONField: (field: any) =>
                Witness.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Witness.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Witness.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Witness.fetch(
                client,
                id,
            ),
            new: (
                fields: WitnessFields,
            ) => {
                return new Witness(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Witness.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Witness>> {
        return phantom(Witness.reified());
    }

    static get p() {
        return Witness.phantom()
    }

    static get bcs() {
        return bcs.struct("Witness", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Witness {
        return Witness.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Witness {
        if (!isWitness(item.type)) {
            throw new Error("not a Witness type");
        }

        return Witness.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Witness {

        return Witness.fromFields(
            Witness.bcs.parse(data)
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
    ): Witness {
        return Witness.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Witness {
        if (json.$typeName !== Witness.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Witness.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Witness {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWitness(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Witness object`);
        }
        return Witness.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Witness> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Witness object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWitness(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Witness object`);
        }

        return Witness.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== ComposableUrl =============================== */

export function isComposableUrl(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_url::ComposableUrl";
}

export interface ComposableUrlFields {
    url: ToField<Url>
}

export type ComposableUrlReified = Reified<
    ComposableUrl,
    ComposableUrlFields
>;

export class ComposableUrl implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_url::ComposableUrl";
    static readonly $numTypeParams = 0;

    readonly $typeName = ComposableUrl.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_url::ComposableUrl";

    readonly $typeArgs: [];

    readonly url:
        ToField<Url>

    private constructor(typeArgs: [], fields: ComposableUrlFields,
    ) {
        this.$fullTypeName = composeSuiType(
            ComposableUrl.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_url::ComposableUrl";
        this.$typeArgs = typeArgs;

        this.url = fields.url;
    }

    static reified(): ComposableUrlReified {
        return {
            typeName: ComposableUrl.$typeName,
            fullTypeName: composeSuiType(
                ComposableUrl.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_url::ComposableUrl",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                ComposableUrl.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ComposableUrl.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ComposableUrl.fromBcs(
                    data,
                ),
            bcs: ComposableUrl.bcs,
            fromJSONField: (field: any) =>
                ComposableUrl.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ComposableUrl.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                ComposableUrl.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => ComposableUrl.fetch(
                client,
                id,
            ),
            new: (
                fields: ComposableUrlFields,
            ) => {
                return new ComposableUrl(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ComposableUrl.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<ComposableUrl>> {
        return phantom(ComposableUrl.reified());
    }

    static get p() {
        return ComposableUrl.phantom()
    }

    static get bcs() {
        return bcs.struct("ComposableUrl", {
            url:
                Url.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): ComposableUrl {
        return ComposableUrl.reified().new(
            {url: decodeFromFields(Url.reified(), fields.url)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): ComposableUrl {
        if (!isComposableUrl(item.type)) {
            throw new Error("not a ComposableUrl type");
        }

        return ComposableUrl.reified().new(
            {url: decodeFromFieldsWithTypes(Url.reified(), item.fields.url)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): ComposableUrl {

        return ComposableUrl.fromFields(
            ComposableUrl.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            url: this.url,

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
    ): ComposableUrl {
        return ComposableUrl.reified().new(
            {url: decodeFromJSONField(Url.reified(), field.url)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): ComposableUrl {
        if (json.$typeName !== ComposableUrl.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return ComposableUrl.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): ComposableUrl {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isComposableUrl(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ComposableUrl object`);
        }
        return ComposableUrl.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<ComposableUrl> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ComposableUrl object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isComposableUrl(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ComposableUrl object`);
        }

        return ComposableUrl.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
