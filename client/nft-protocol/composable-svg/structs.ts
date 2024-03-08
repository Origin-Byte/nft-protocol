import * as reified from "../../_framework/reified";
import {String} from "../../_dependencies/source/0x1/ascii/structs";
import {ID} from "../../_dependencies/source/0x2/object/structs";
import {VecMap} from "../../_dependencies/source/0x2/vec-map/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, Vector, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, fieldToJSON, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::Witness";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: WitnessFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Witness.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::Witness";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): WitnessReified {
        return {
            typeName: Witness.$typeName,
            fullTypeName: composeSuiType(
                Witness.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::Witness",
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

/* ============================== ComposableSvg =============================== */

export function isComposableSvg(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::ComposableSvg";
}

export interface ComposableSvgFields {
    nfts: ToField<Vector<ID>>; attributes: ToField<VecMap<String, String>>; svg: ToField<Vector<"u8">>
}

export type ComposableSvgReified = Reified<
    ComposableSvg,
    ComposableSvgFields
>;

export class ComposableSvg implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::ComposableSvg";
    static readonly $numTypeParams = 0;

    readonly $typeName = ComposableSvg.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::ComposableSvg";

    readonly $typeArgs: [];

    readonly nfts:
        ToField<Vector<ID>>
    ; readonly attributes:
        ToField<VecMap<String, String>>
    ; readonly svg:
        ToField<Vector<"u8">>

    private constructor(typeArgs: [], fields: ComposableSvgFields,
    ) {
        this.$fullTypeName = composeSuiType(
            ComposableSvg.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::ComposableSvg";
        this.$typeArgs = typeArgs;

        this.nfts = fields.nfts;; this.attributes = fields.attributes;; this.svg = fields.svg;
    }

    static reified(): ComposableSvgReified {
        return {
            typeName: ComposableSvg.$typeName,
            fullTypeName: composeSuiType(
                ComposableSvg.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::ComposableSvg",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                ComposableSvg.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ComposableSvg.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ComposableSvg.fromBcs(
                    data,
                ),
            bcs: ComposableSvg.bcs,
            fromJSONField: (field: any) =>
                ComposableSvg.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ComposableSvg.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                ComposableSvg.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => ComposableSvg.fetch(
                client,
                id,
            ),
            new: (
                fields: ComposableSvgFields,
            ) => {
                return new ComposableSvg(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ComposableSvg.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<ComposableSvg>> {
        return phantom(ComposableSvg.reified());
    }

    static get p() {
        return ComposableSvg.phantom()
    }

    static get bcs() {
        return bcs.struct("ComposableSvg", {
            nfts:
                bcs.vector(ID.bcs)
            , attributes:
                VecMap.bcs(String.bcs, String.bcs)
            , svg:
                bcs.vector(bcs.u8())

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): ComposableSvg {
        return ComposableSvg.reified().new(
            {nfts: decodeFromFields(reified.vector(ID.reified()), fields.nfts), attributes: decodeFromFields(VecMap.reified(String.reified(), String.reified()), fields.attributes), svg: decodeFromFields(reified.vector("u8"), fields.svg)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): ComposableSvg {
        if (!isComposableSvg(item.type)) {
            throw new Error("not a ComposableSvg type");
        }

        return ComposableSvg.reified().new(
            {nfts: decodeFromFieldsWithTypes(reified.vector(ID.reified()), item.fields.nfts), attributes: decodeFromFieldsWithTypes(VecMap.reified(String.reified(), String.reified()), item.fields.attributes), svg: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.svg)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): ComposableSvg {

        return ComposableSvg.fromFields(
            ComposableSvg.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            nfts: fieldToJSON<Vector<ID>>(`vector<0x2::object::ID>`, this.nfts),attributes: this.attributes.toJSONField(),svg: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.svg),

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
    ): ComposableSvg {
        return ComposableSvg.reified().new(
            {nfts: decodeFromJSONField(reified.vector(ID.reified()), field.nfts), attributes: decodeFromJSONField(VecMap.reified(String.reified(), String.reified()), field.attributes), svg: decodeFromJSONField(reified.vector("u8"), field.svg)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): ComposableSvg {
        if (json.$typeName !== ComposableSvg.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return ComposableSvg.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): ComposableSvg {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isComposableSvg(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ComposableSvg object`);
        }
        return ComposableSvg.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<ComposableSvg> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ComposableSvg object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isComposableSvg(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ComposableSvg object`);
        }

        return ComposableSvg.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== RenderGuard =============================== */

export function isRenderGuard(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::RenderGuard";
}

export interface RenderGuardFields {
    children: ToField<Vector<ID>>; svg: ToField<Vector<"u8">>
}

export type RenderGuardReified = Reified<
    RenderGuard,
    RenderGuardFields
>;

export class RenderGuard implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::RenderGuard";
    static readonly $numTypeParams = 0;

    readonly $typeName = RenderGuard.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::RenderGuard";

    readonly $typeArgs: [];

    readonly children:
        ToField<Vector<ID>>
    ; readonly svg:
        ToField<Vector<"u8">>

    private constructor(typeArgs: [], fields: RenderGuardFields,
    ) {
        this.$fullTypeName = composeSuiType(
            RenderGuard.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::RenderGuard";
        this.$typeArgs = typeArgs;

        this.children = fields.children;; this.svg = fields.svg;
    }

    static reified(): RenderGuardReified {
        return {
            typeName: RenderGuard.$typeName,
            fullTypeName: composeSuiType(
                RenderGuard.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_svg::RenderGuard",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                RenderGuard.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                RenderGuard.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                RenderGuard.fromBcs(
                    data,
                ),
            bcs: RenderGuard.bcs,
            fromJSONField: (field: any) =>
                RenderGuard.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                RenderGuard.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                RenderGuard.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => RenderGuard.fetch(
                client,
                id,
            ),
            new: (
                fields: RenderGuardFields,
            ) => {
                return new RenderGuard(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return RenderGuard.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<RenderGuard>> {
        return phantom(RenderGuard.reified());
    }

    static get p() {
        return RenderGuard.phantom()
    }

    static get bcs() {
        return bcs.struct("RenderGuard", {
            children:
                bcs.vector(ID.bcs)
            , svg:
                bcs.vector(bcs.u8())

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): RenderGuard {
        return RenderGuard.reified().new(
            {children: decodeFromFields(reified.vector(ID.reified()), fields.children), svg: decodeFromFields(reified.vector("u8"), fields.svg)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): RenderGuard {
        if (!isRenderGuard(item.type)) {
            throw new Error("not a RenderGuard type");
        }

        return RenderGuard.reified().new(
            {children: decodeFromFieldsWithTypes(reified.vector(ID.reified()), item.fields.children), svg: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.svg)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): RenderGuard {

        return RenderGuard.fromFields(
            RenderGuard.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            children: fieldToJSON<Vector<ID>>(`vector<0x2::object::ID>`, this.children),svg: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.svg),

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
    ): RenderGuard {
        return RenderGuard.reified().new(
            {children: decodeFromJSONField(reified.vector(ID.reified()), field.children), svg: decodeFromJSONField(reified.vector("u8"), field.svg)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): RenderGuard {
        if (json.$typeName !== RenderGuard.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return RenderGuard.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): RenderGuard {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isRenderGuard(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a RenderGuard object`);
        }
        return RenderGuard.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<RenderGuard> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching RenderGuard object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isRenderGuard(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a RenderGuard object`);
        }

        return RenderGuard.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
