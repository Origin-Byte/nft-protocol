import {TypeName} from "../../_dependencies/source/0x1/type-name/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::collection::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::collection::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::collection::Witness";

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
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::collection::Witness",
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

/* ============================== Collection =============================== */

export function isCollection(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::collection::Collection<");
}

export interface CollectionFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; version: ToField<"u64">
}

export type CollectionReified<T extends PhantomTypeArgument> = Reified<
    Collection<T>,
    CollectionFields<T>
>;

export class Collection<T extends PhantomTypeArgument> {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::collection::Collection";
    static readonly $numTypeParams = 1;

    readonly $typeName = Collection.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::collection::Collection<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly version:
        ToField<"u64">

    private constructor(typeArg: string, fields: CollectionFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(Collection.$typeName,
        typeArg) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::collection::Collection<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.version = fields.version;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): CollectionReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Collection.$typeName,
            fullTypeName: composeSuiType(
                Collection.$typeName,
                ...[extractType(T)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::collection::Collection<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Collection.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Collection.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Collection.fromBcs(
                    T,
                    data,
                ),
            bcs: Collection.bcs,
            fromJSONField: (field: any) =>
                Collection.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Collection.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Collection.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: CollectionFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Collection(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Collection.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Collection<ToPhantomTypeArgument<T>>>> {
        return phantom(Collection.reified(
            T
        ));
    }

    static get p() {
        return Collection.phantom
    }

    static get bcs() {
        return bcs.struct("Collection", {
            id:
                UID.bcs
            , version:
                bcs.u64()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Collection<ToPhantomTypeArgument<T>> {
        return Collection.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), version: decodeFromFields("u64", fields.version)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Collection<ToPhantomTypeArgument<T>> {
        if (!isCollection(item.type)) {
            throw new Error("not a Collection type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Collection.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), version: decodeFromFieldsWithTypes("u64", item.fields.version)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Collection<ToPhantomTypeArgument<T>> {

        return Collection.fromFields(
            typeArg,
            Collection.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,version: this.version.toString(),

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
    ): Collection<ToPhantomTypeArgument<T>> {
        return Collection.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), version: decodeFromJSONField("u64", field.version)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Collection<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Collection.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Collection.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Collection.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Collection<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isCollection(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Collection object`);
        }
        return Collection.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Collection<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Collection object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isCollection(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Collection object`);
        }

        return Collection.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== MintCollectionEvent =============================== */

export function isMintCollectionEvent(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::collection::MintCollectionEvent";
}

export interface MintCollectionEventFields {
    collectionId: ToField<ID>; typeName: ToField<TypeName>
}

export type MintCollectionEventReified = Reified<
    MintCollectionEvent,
    MintCollectionEventFields
>;

export class MintCollectionEvent {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::collection::MintCollectionEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = MintCollectionEvent.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::collection::MintCollectionEvent";

    ;

    readonly collectionId:
        ToField<ID>
    ; readonly typeName:
        ToField<TypeName>

    private constructor( fields: MintCollectionEventFields,
    ) {
        this.$fullTypeName = MintCollectionEvent.$typeName;

        this.collectionId = fields.collectionId;; this.typeName = fields.typeName;
    }

    static reified(): MintCollectionEventReified {
        return {
            typeName: MintCollectionEvent.$typeName,
            fullTypeName: composeSuiType(
                MintCollectionEvent.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::collection::MintCollectionEvent",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                MintCollectionEvent.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                MintCollectionEvent.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                MintCollectionEvent.fromBcs(
                    data,
                ),
            bcs: MintCollectionEvent.bcs,
            fromJSONField: (field: any) =>
                MintCollectionEvent.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                MintCollectionEvent.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => MintCollectionEvent.fetch(
                client,
                id,
            ),
            new: (
                fields: MintCollectionEventFields,
            ) => {
                return new MintCollectionEvent(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return MintCollectionEvent.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<MintCollectionEvent>> {
        return phantom(MintCollectionEvent.reified());
    }

    static get p() {
        return MintCollectionEvent.phantom()
    }

    static get bcs() {
        return bcs.struct("MintCollectionEvent", {
            collection_id:
                ID.bcs
            , type_name:
                TypeName.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): MintCollectionEvent {
        return MintCollectionEvent.reified().new(
            {collectionId: decodeFromFields(ID.reified(), fields.collection_id), typeName: decodeFromFields(TypeName.reified(), fields.type_name)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): MintCollectionEvent {
        if (!isMintCollectionEvent(item.type)) {
            throw new Error("not a MintCollectionEvent type");
        }

        return MintCollectionEvent.reified().new(
            {collectionId: decodeFromFieldsWithTypes(ID.reified(), item.fields.collection_id), typeName: decodeFromFieldsWithTypes(TypeName.reified(), item.fields.type_name)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): MintCollectionEvent {

        return MintCollectionEvent.fromFields(
            MintCollectionEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            collectionId: this.collectionId,typeName: this.typeName.toJSONField(),

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
    ): MintCollectionEvent {
        return MintCollectionEvent.reified().new(
            {collectionId: decodeFromJSONField(ID.reified(), field.collectionId), typeName: decodeFromJSONField(TypeName.reified(), field.typeName)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): MintCollectionEvent {
        if (json.$typeName !== MintCollectionEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return MintCollectionEvent.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): MintCollectionEvent {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isMintCollectionEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a MintCollectionEvent object`);
        }
        return MintCollectionEvent.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<MintCollectionEvent> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching MintCollectionEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isMintCollectionEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a MintCollectionEvent object`);
        }

        return MintCollectionEvent.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
