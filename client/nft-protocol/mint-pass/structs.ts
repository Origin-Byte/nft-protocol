import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {Supply} from "../../utils/utils-supply/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_pass::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_pass::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_pass::Witness";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: WitnessFields,
    ) {
        this.$fullTypeName = Witness.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): WitnessReified {
        return {
            typeName: Witness.$typeName,
            fullTypeName: composeSuiType(
                Witness.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_pass::Witness",
            typeArgs: [],
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
            fetch: async (client: SuiClient, id: string) => Witness.fetch(
                client,
                id,
            ),
            new: (
                fields: WitnessFields,
            ) => {
                return new Witness(
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

/* ============================== MetadataDfKey =============================== */

export function isMetadataDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_pass::MetadataDfKey";
}

export interface MetadataDfKeyFields {
    dummyField: ToField<"bool">
}

export type MetadataDfKeyReified = Reified<
    MetadataDfKey,
    MetadataDfKeyFields
>;

export class MetadataDfKey {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_pass::MetadataDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = MetadataDfKey.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_pass::MetadataDfKey";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: MetadataDfKeyFields,
    ) {
        this.$fullTypeName = MetadataDfKey.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): MetadataDfKeyReified {
        return {
            typeName: MetadataDfKey.$typeName,
            fullTypeName: composeSuiType(
                MetadataDfKey.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_pass::MetadataDfKey",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                MetadataDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                MetadataDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                MetadataDfKey.fromBcs(
                    data,
                ),
            bcs: MetadataDfKey.bcs,
            fromJSONField: (field: any) =>
                MetadataDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                MetadataDfKey.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => MetadataDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: MetadataDfKeyFields,
            ) => {
                return new MetadataDfKey(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return MetadataDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<MetadataDfKey>> {
        return phantom(MetadataDfKey.reified());
    }

    static get p() {
        return MetadataDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("MetadataDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): MetadataDfKey {
        return MetadataDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): MetadataDfKey {
        if (!isMetadataDfKey(item.type)) {
            throw new Error("not a MetadataDfKey type");
        }

        return MetadataDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): MetadataDfKey {

        return MetadataDfKey.fromFields(
            MetadataDfKey.bcs.parse(data)
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
            ...this.toJSONField()
        }
    }

    static fromJSONField(
         field: any
    ): MetadataDfKey {
        return MetadataDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): MetadataDfKey {
        if (json.$typeName !== MetadataDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return MetadataDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): MetadataDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isMetadataDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a MetadataDfKey object`);
        }
        return MetadataDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<MetadataDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching MetadataDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isMetadataDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a MetadataDfKey object`);
        }

        return MetadataDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== MintPass =============================== */

export function isMintPass(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_pass::MintPass<");
}

export interface MintPassFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; supply: ToField<Supply>
}

export type MintPassReified<T extends PhantomTypeArgument> = Reified<
    MintPass<T>,
    MintPassFields<T>
>;

export class MintPass<T extends PhantomTypeArgument> {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_pass::MintPass";
    static readonly $numTypeParams = 1;

    readonly $typeName = MintPass.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_pass::MintPass<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly supply:
        ToField<Supply>

    private constructor(typeArg: string, fields: MintPassFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(MintPass.$typeName,
        typeArg) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_pass::MintPass<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.supply = fields.supply;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): MintPassReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: MintPass.$typeName,
            fullTypeName: composeSuiType(
                MintPass.$typeName,
                ...[extractType(T)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_pass::MintPass<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                MintPass.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                MintPass.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                MintPass.fromBcs(
                    T,
                    data,
                ),
            bcs: MintPass.bcs,
            fromJSONField: (field: any) =>
                MintPass.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                MintPass.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => MintPass.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: MintPassFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new MintPass(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return MintPass.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<MintPass<ToPhantomTypeArgument<T>>>> {
        return phantom(MintPass.reified(
            T
        ));
    }

    static get p() {
        return MintPass.phantom
    }

    static get bcs() {
        return bcs.struct("MintPass", {
            id:
                UID.bcs
            , supply:
                Supply.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): MintPass<ToPhantomTypeArgument<T>> {
        return MintPass.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), supply: decodeFromFields(Supply.reified(), fields.supply)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): MintPass<ToPhantomTypeArgument<T>> {
        if (!isMintPass(item.type)) {
            throw new Error("not a MintPass type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return MintPass.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), supply: decodeFromFieldsWithTypes(Supply.reified(), item.fields.supply)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): MintPass<ToPhantomTypeArgument<T>> {

        return MintPass.fromFields(
            typeArg,
            MintPass.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,supply: this.supply.toJSONField(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): MintPass<ToPhantomTypeArgument<T>> {
        return MintPass.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), supply: decodeFromJSONField(Supply.reified(), field.supply)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): MintPass<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== MintPass.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(MintPass.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return MintPass.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): MintPass<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isMintPass(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a MintPass object`);
        }
        return MintPass.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<MintPass<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching MintPass object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isMintPass(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a MintPass object`);
        }

        return MintPass.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
