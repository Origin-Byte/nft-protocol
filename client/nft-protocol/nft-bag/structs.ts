import * as reified from "../../_framework/reified";
import {TypeName} from "../../_dependencies/source/0x1/type-name/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {VecMap} from "../../_dependencies/source/0x2/vec-map/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, Vector, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, fieldToJSON, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Key =============================== */

export function isKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_bag::Key";
}

export interface KeyFields {
    id: ToField<ID>
}

export type KeyReified = Reified<
    Key,
    KeyFields
>;

export class Key implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_bag::Key";
    static readonly $numTypeParams = 0;

    readonly $typeName = Key.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_bag::Key";

    readonly $typeArgs: [];

    readonly id:
        ToField<ID>

    private constructor(typeArgs: [], fields: KeyFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Key.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_bag::Key";
        this.$typeArgs = typeArgs;

        this.id = fields.id;
    }

    static reified(): KeyReified {
        return {
            typeName: Key.$typeName,
            fullTypeName: composeSuiType(
                Key.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_bag::Key",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Key.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Key.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Key.fromBcs(
                    data,
                ),
            bcs: Key.bcs,
            fromJSONField: (field: any) =>
                Key.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Key.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Key.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Key.fetch(
                client,
                id,
            ),
            new: (
                fields: KeyFields,
            ) => {
                return new Key(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Key.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Key>> {
        return phantom(Key.reified());
    }

    static get p() {
        return Key.phantom()
    }

    static get bcs() {
        return bcs.struct("Key", {
            id:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Key {
        return Key.reified().new(
            {id: decodeFromFields(ID.reified(), fields.id)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Key {
        if (!isKey(item.type)) {
            throw new Error("not a Key type");
        }

        return Key.reified().new(
            {id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Key {

        return Key.fromFields(
            Key.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,

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
    ): Key {
        return Key.reified().new(
            {id: decodeFromJSONField(ID.reified(), field.id)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Key {
        if (json.$typeName !== Key.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Key.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Key {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Key object`);
        }
        return Key.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Key> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Key object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Key object`);
        }

        return Key.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== NftBag =============================== */

export function isNftBag(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_bag::NftBag";
}

export interface NftBagFields {
    id: ToField<UID>; authorities: ToField<Vector<TypeName>>; nfts: ToField<VecMap<ID, "u64">>
}

export type NftBagReified = Reified<
    NftBag,
    NftBagFields
>;

export class NftBag implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_bag::NftBag";
    static readonly $numTypeParams = 0;

    readonly $typeName = NftBag.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_bag::NftBag";

    readonly $typeArgs: [];

    readonly id:
        ToField<UID>
    ; readonly authorities:
        ToField<Vector<TypeName>>
    ; readonly nfts:
        ToField<VecMap<ID, "u64">>

    private constructor(typeArgs: [], fields: NftBagFields,
    ) {
        this.$fullTypeName = composeSuiType(
            NftBag.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_bag::NftBag";
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.authorities = fields.authorities;; this.nfts = fields.nfts;
    }

    static reified(): NftBagReified {
        return {
            typeName: NftBag.$typeName,
            fullTypeName: composeSuiType(
                NftBag.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_bag::NftBag",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                NftBag.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                NftBag.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                NftBag.fromBcs(
                    data,
                ),
            bcs: NftBag.bcs,
            fromJSONField: (field: any) =>
                NftBag.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                NftBag.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                NftBag.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => NftBag.fetch(
                client,
                id,
            ),
            new: (
                fields: NftBagFields,
            ) => {
                return new NftBag(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return NftBag.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<NftBag>> {
        return phantom(NftBag.reified());
    }

    static get p() {
        return NftBag.phantom()
    }

    static get bcs() {
        return bcs.struct("NftBag", {
            id:
                UID.bcs
            , authorities:
                bcs.vector(TypeName.bcs)
            , nfts:
                VecMap.bcs(ID.bcs, bcs.u64())

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): NftBag {
        return NftBag.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), authorities: decodeFromFields(reified.vector(TypeName.reified()), fields.authorities), nfts: decodeFromFields(VecMap.reified(ID.reified(), "u64"), fields.nfts)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): NftBag {
        if (!isNftBag(item.type)) {
            throw new Error("not a NftBag type");
        }

        return NftBag.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), authorities: decodeFromFieldsWithTypes(reified.vector(TypeName.reified()), item.fields.authorities), nfts: decodeFromFieldsWithTypes(VecMap.reified(ID.reified(), "u64"), item.fields.nfts)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): NftBag {

        return NftBag.fromFields(
            NftBag.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,authorities: fieldToJSON<Vector<TypeName>>(`vector<0x1::type_name::TypeName>`, this.authorities),nfts: this.nfts.toJSONField(),

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
    ): NftBag {
        return NftBag.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), authorities: decodeFromJSONField(reified.vector(TypeName.reified()), field.authorities), nfts: decodeFromJSONField(VecMap.reified(ID.reified(), "u64"), field.nfts)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): NftBag {
        if (json.$typeName !== NftBag.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return NftBag.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): NftBag {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isNftBag(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a NftBag object`);
        }
        return NftBag.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<NftBag> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching NftBag object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isNftBag(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a NftBag object`);
        }

        return NftBag.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
