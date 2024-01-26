import {String} from "../../_dependencies/source/0x1/ascii/structs";
import {String as String1} from "../../_dependencies/source/0x1/string/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {Url} from "../../_dependencies/source/0x2/url/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft::Witness";

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
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft::Witness",
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

/* ============================== MintNftEvent =============================== */

export function isMintNftEvent(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft::MintNftEvent";
}

export interface MintNftEventFields {
    nftId: ToField<ID>; nftType: ToField<String>
}

export type MintNftEventReified = Reified<
    MintNftEvent,
    MintNftEventFields
>;

export class MintNftEvent {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft::MintNftEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = MintNftEvent.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft::MintNftEvent";

    ;

    readonly nftId:
        ToField<ID>
    ; readonly nftType:
        ToField<String>

    private constructor( fields: MintNftEventFields,
    ) {
        this.$fullTypeName = MintNftEvent.$typeName;

        this.nftId = fields.nftId;; this.nftType = fields.nftType;
    }

    static reified(): MintNftEventReified {
        return {
            typeName: MintNftEvent.$typeName,
            fullTypeName: composeSuiType(
                MintNftEvent.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft::MintNftEvent",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                MintNftEvent.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                MintNftEvent.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                MintNftEvent.fromBcs(
                    data,
                ),
            bcs: MintNftEvent.bcs,
            fromJSONField: (field: any) =>
                MintNftEvent.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                MintNftEvent.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => MintNftEvent.fetch(
                client,
                id,
            ),
            new: (
                fields: MintNftEventFields,
            ) => {
                return new MintNftEvent(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return MintNftEvent.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<MintNftEvent>> {
        return phantom(MintNftEvent.reified());
    }

    static get p() {
        return MintNftEvent.phantom()
    }

    static get bcs() {
        return bcs.struct("MintNftEvent", {
            nft_id:
                ID.bcs
            , nft_type:
                String.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): MintNftEvent {
        return MintNftEvent.reified().new(
            {nftId: decodeFromFields(ID.reified(), fields.nft_id), nftType: decodeFromFields(String.reified(), fields.nft_type)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): MintNftEvent {
        if (!isMintNftEvent(item.type)) {
            throw new Error("not a MintNftEvent type");
        }

        return MintNftEvent.reified().new(
            {nftId: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft_id), nftType: decodeFromFieldsWithTypes(String.reified(), item.fields.nft_type)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): MintNftEvent {

        return MintNftEvent.fromFields(
            MintNftEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            nftId: this.nftId,nftType: this.nftType,

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
    ): MintNftEvent {
        return MintNftEvent.reified().new(
            {nftId: decodeFromJSONField(ID.reified(), field.nftId), nftType: decodeFromJSONField(String.reified(), field.nftType)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): MintNftEvent {
        if (json.$typeName !== MintNftEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return MintNftEvent.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): MintNftEvent {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isMintNftEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a MintNftEvent object`);
        }
        return MintNftEvent.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<MintNftEvent> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching MintNftEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isMintNftEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a MintNftEvent object`);
        }

        return MintNftEvent.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Nft =============================== */

export function isNft(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft::Nft<");
}

export interface NftFields<C extends PhantomTypeArgument> {
    id: ToField<UID>; name: ToField<String1>; url: ToField<Url>
}

export type NftReified<C extends PhantomTypeArgument> = Reified<
    Nft<C>,
    NftFields<C>
>;

export class Nft<C extends PhantomTypeArgument> {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft::Nft";
    static readonly $numTypeParams = 1;

    readonly $typeName = Nft.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft::Nft<${PhantomToTypeStr<C>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly name:
        ToField<String1>
    ; readonly url:
        ToField<Url>

    private constructor(typeArg: string, fields: NftFields<C>,
    ) {
        this.$fullTypeName = composeSuiType(Nft.$typeName,
        typeArg) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft::Nft<${PhantomToTypeStr<C>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.name = fields.name;; this.url = fields.url;
    }

    static reified<C extends PhantomReified<PhantomTypeArgument>>(
        C: C
    ): NftReified<ToPhantomTypeArgument<C>> {
        return {
            typeName: Nft.$typeName,
            fullTypeName: composeSuiType(
                Nft.$typeName,
                ...[extractType(C)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft::Nft<${PhantomToTypeStr<ToPhantomTypeArgument<C>>}>`,
            typeArgs: [C],
            fromFields: (fields: Record<string, any>) =>
                Nft.fromFields(
                    C,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Nft.fromFieldsWithTypes(
                    C,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Nft.fromBcs(
                    C,
                    data,
                ),
            bcs: Nft.bcs,
            fromJSONField: (field: any) =>
                Nft.fromJSONField(
                    C,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Nft.fromJSON(
                    C,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Nft.fetch(
                client,
                C,
                id,
            ),
            new: (
                fields: NftFields<ToPhantomTypeArgument<C>>,
            ) => {
                return new Nft(
                    extractType(C),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Nft.reified
    }

    static phantom<C extends PhantomReified<PhantomTypeArgument>>(
        C: C
    ): PhantomReified<ToTypeStr<Nft<ToPhantomTypeArgument<C>>>> {
        return phantom(Nft.reified(
            C
        ));
    }

    static get p() {
        return Nft.phantom
    }

    static get bcs() {
        return bcs.struct("Nft", {
            id:
                UID.bcs
            , name:
                String1.bcs
            , url:
                Url.bcs

        })
    };

    static fromFields<C extends PhantomReified<PhantomTypeArgument>>(
        typeArg: C, fields: Record<string, any>
    ): Nft<ToPhantomTypeArgument<C>> {
        return Nft.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), name: decodeFromFields(String1.reified(), fields.name), url: decodeFromFields(Url.reified(), fields.url)}
        )
    }

    static fromFieldsWithTypes<C extends PhantomReified<PhantomTypeArgument>>(
        typeArg: C, item: FieldsWithTypes
    ): Nft<ToPhantomTypeArgument<C>> {
        if (!isNft(item.type)) {
            throw new Error("not a Nft type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Nft.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), name: decodeFromFieldsWithTypes(String1.reified(), item.fields.name), url: decodeFromFieldsWithTypes(Url.reified(), item.fields.url)}
        )
    }

    static fromBcs<C extends PhantomReified<PhantomTypeArgument>>(
        typeArg: C, data: Uint8Array
    ): Nft<ToPhantomTypeArgument<C>> {

        return Nft.fromFields(
            typeArg,
            Nft.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,name: this.name,url: this.url,

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<C extends PhantomReified<PhantomTypeArgument>>(
        typeArg: C, field: any
    ): Nft<ToPhantomTypeArgument<C>> {
        return Nft.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), name: decodeFromJSONField(String1.reified(), field.name), url: decodeFromJSONField(Url.reified(), field.url)}
        )
    }

    static fromJSON<C extends PhantomReified<PhantomTypeArgument>>(
        typeArg: C, json: Record<string, any>
    ): Nft<ToPhantomTypeArgument<C>> {
        if (json.$typeName !== Nft.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Nft.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Nft.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<C extends PhantomReified<PhantomTypeArgument>>(
        typeArg: C, content: SuiParsedData
    ): Nft<ToPhantomTypeArgument<C>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isNft(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Nft object`);
        }
        return Nft.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<C extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: C, id: string
    ): Promise<Nft<ToPhantomTypeArgument<C>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Nft object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isNft(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Nft object`);
        }

        return Nft.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
