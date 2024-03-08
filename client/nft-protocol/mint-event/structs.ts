import {ID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== BurnEvent =============================== */

export function isBurnEvent(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::BurnEvent<");
}

export interface BurnEventFields<T extends PhantomTypeArgument> {
    collectionId: ToField<ID>; object: ToField<ID>
}

export type BurnEventReified<T extends PhantomTypeArgument> = Reified<
    BurnEvent<T>,
    BurnEventFields<T>
>;

export class BurnEvent<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::BurnEvent";
    static readonly $numTypeParams = 1;

    readonly $typeName = BurnEvent.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::BurnEvent<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly collectionId:
        ToField<ID>
    ; readonly object:
        ToField<ID>

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: BurnEventFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            BurnEvent.$typeName,
            ...typeArgs
        ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::BurnEvent<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.collectionId = fields.collectionId;; this.object = fields.object;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): BurnEventReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: BurnEvent.$typeName,
            fullTypeName: composeSuiType(
                BurnEvent.$typeName,
                ...[extractType(T)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::BurnEvent<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                BurnEvent.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                BurnEvent.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                BurnEvent.fromBcs(
                    T,
                    data,
                ),
            bcs: BurnEvent.bcs,
            fromJSONField: (field: any) =>
                BurnEvent.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                BurnEvent.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                BurnEvent.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => BurnEvent.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: BurnEventFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new BurnEvent(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return BurnEvent.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<BurnEvent<ToPhantomTypeArgument<T>>>> {
        return phantom(BurnEvent.reified(
            T
        ));
    }

    static get p() {
        return BurnEvent.phantom
    }

    static get bcs() {
        return bcs.struct("BurnEvent", {
            collection_id:
                ID.bcs
            , object:
                ID.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): BurnEvent<ToPhantomTypeArgument<T>> {
        return BurnEvent.reified(
            typeArg,
        ).new(
            {collectionId: decodeFromFields(ID.reified(), fields.collection_id), object: decodeFromFields(ID.reified(), fields.object)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): BurnEvent<ToPhantomTypeArgument<T>> {
        if (!isBurnEvent(item.type)) {
            throw new Error("not a BurnEvent type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return BurnEvent.reified(
            typeArg,
        ).new(
            {collectionId: decodeFromFieldsWithTypes(ID.reified(), item.fields.collection_id), object: decodeFromFieldsWithTypes(ID.reified(), item.fields.object)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): BurnEvent<ToPhantomTypeArgument<T>> {

        return BurnEvent.fromFields(
            typeArg,
            BurnEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            collectionId: this.collectionId,object: this.object,

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): BurnEvent<ToPhantomTypeArgument<T>> {
        return BurnEvent.reified(
            typeArg,
        ).new(
            {collectionId: decodeFromJSONField(ID.reified(), field.collectionId), object: decodeFromJSONField(ID.reified(), field.object)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): BurnEvent<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== BurnEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(BurnEvent.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return BurnEvent.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): BurnEvent<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBurnEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a BurnEvent object`);
        }
        return BurnEvent.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<BurnEvent<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching BurnEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBurnEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a BurnEvent object`);
        }

        return BurnEvent.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== BurnGuard =============================== */

export function isBurnGuard(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::BurnGuard<");
}

export interface BurnGuardFields<T extends PhantomTypeArgument> {
    id: ToField<ID>
}

export type BurnGuardReified<T extends PhantomTypeArgument> = Reified<
    BurnGuard<T>,
    BurnGuardFields<T>
>;

export class BurnGuard<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::BurnGuard";
    static readonly $numTypeParams = 1;

    readonly $typeName = BurnGuard.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::BurnGuard<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly id:
        ToField<ID>

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: BurnGuardFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            BurnGuard.$typeName,
            ...typeArgs
        ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::BurnGuard<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): BurnGuardReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: BurnGuard.$typeName,
            fullTypeName: composeSuiType(
                BurnGuard.$typeName,
                ...[extractType(T)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::BurnGuard<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                BurnGuard.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                BurnGuard.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                BurnGuard.fromBcs(
                    T,
                    data,
                ),
            bcs: BurnGuard.bcs,
            fromJSONField: (field: any) =>
                BurnGuard.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                BurnGuard.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                BurnGuard.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => BurnGuard.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: BurnGuardFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new BurnGuard(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return BurnGuard.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<BurnGuard<ToPhantomTypeArgument<T>>>> {
        return phantom(BurnGuard.reified(
            T
        ));
    }

    static get p() {
        return BurnGuard.phantom
    }

    static get bcs() {
        return bcs.struct("BurnGuard", {
            id:
                ID.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): BurnGuard<ToPhantomTypeArgument<T>> {
        return BurnGuard.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(ID.reified(), fields.id)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): BurnGuard<ToPhantomTypeArgument<T>> {
        if (!isBurnGuard(item.type)) {
            throw new Error("not a BurnGuard type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return BurnGuard.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): BurnGuard<ToPhantomTypeArgument<T>> {

        return BurnGuard.fromFields(
            typeArg,
            BurnGuard.bcs.parse(data)
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

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): BurnGuard<ToPhantomTypeArgument<T>> {
        return BurnGuard.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(ID.reified(), field.id)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): BurnGuard<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== BurnGuard.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(BurnGuard.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return BurnGuard.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): BurnGuard<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBurnGuard(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a BurnGuard object`);
        }
        return BurnGuard.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<BurnGuard<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching BurnGuard object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBurnGuard(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a BurnGuard object`);
        }

        return BurnGuard.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== MintEvent =============================== */

export function isMintEvent(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::MintEvent<");
}

export interface MintEventFields<T extends PhantomTypeArgument> {
    collectionId: ToField<ID>; object: ToField<ID>
}

export type MintEventReified<T extends PhantomTypeArgument> = Reified<
    MintEvent<T>,
    MintEventFields<T>
>;

export class MintEvent<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::MintEvent";
    static readonly $numTypeParams = 1;

    readonly $typeName = MintEvent.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::MintEvent<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly collectionId:
        ToField<ID>
    ; readonly object:
        ToField<ID>

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: MintEventFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            MintEvent.$typeName,
            ...typeArgs
        ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::MintEvent<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.collectionId = fields.collectionId;; this.object = fields.object;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): MintEventReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: MintEvent.$typeName,
            fullTypeName: composeSuiType(
                MintEvent.$typeName,
                ...[extractType(T)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_event::MintEvent<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                MintEvent.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                MintEvent.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                MintEvent.fromBcs(
                    T,
                    data,
                ),
            bcs: MintEvent.bcs,
            fromJSONField: (field: any) =>
                MintEvent.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                MintEvent.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                MintEvent.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => MintEvent.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: MintEventFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new MintEvent(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return MintEvent.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<MintEvent<ToPhantomTypeArgument<T>>>> {
        return phantom(MintEvent.reified(
            T
        ));
    }

    static get p() {
        return MintEvent.phantom
    }

    static get bcs() {
        return bcs.struct("MintEvent", {
            collection_id:
                ID.bcs
            , object:
                ID.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): MintEvent<ToPhantomTypeArgument<T>> {
        return MintEvent.reified(
            typeArg,
        ).new(
            {collectionId: decodeFromFields(ID.reified(), fields.collection_id), object: decodeFromFields(ID.reified(), fields.object)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): MintEvent<ToPhantomTypeArgument<T>> {
        if (!isMintEvent(item.type)) {
            throw new Error("not a MintEvent type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return MintEvent.reified(
            typeArg,
        ).new(
            {collectionId: decodeFromFieldsWithTypes(ID.reified(), item.fields.collection_id), object: decodeFromFieldsWithTypes(ID.reified(), item.fields.object)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): MintEvent<ToPhantomTypeArgument<T>> {

        return MintEvent.fromFields(
            typeArg,
            MintEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            collectionId: this.collectionId,object: this.object,

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): MintEvent<ToPhantomTypeArgument<T>> {
        return MintEvent.reified(
            typeArg,
        ).new(
            {collectionId: decodeFromJSONField(ID.reified(), field.collectionId), object: decodeFromJSONField(ID.reified(), field.object)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): MintEvent<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== MintEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(MintEvent.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return MintEvent.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): MintEvent<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isMintEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a MintEvent object`);
        }
        return MintEvent.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<MintEvent<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching MintEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isMintEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a MintEvent object`);
        }

        return MintEvent.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
