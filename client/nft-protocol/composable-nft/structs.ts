import {TypeName} from "../../_dependencies/source/0x1/type-name/structs";
import {VecMap} from "../../_dependencies/source/0x2/vec-map/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Key =============================== */

export function isKey(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_nft::Key<");
}

export interface KeyFields<T extends PhantomTypeArgument> {
    dummyField: ToField<"bool">
}

export type KeyReified<T extends PhantomTypeArgument> = Reified<
    Key<T>,
    KeyFields<T>
>;

export class Key<T extends PhantomTypeArgument> {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_nft::Key";
    static readonly $numTypeParams = 1;

    readonly $typeName = Key.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_nft::Key<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArg: string, fields: KeyFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(Key.$typeName,
        typeArg) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_nft::Key<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.dummyField = fields.dummyField;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): KeyReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Key.$typeName,
            fullTypeName: composeSuiType(
                Key.$typeName,
                ...[extractType(T)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_nft::Key<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Key.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Key.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Key.fromBcs(
                    T,
                    data,
                ),
            bcs: Key.bcs,
            fromJSONField: (field: any) =>
                Key.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Key.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Key.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: KeyFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Key(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Key.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Key<ToPhantomTypeArgument<T>>>> {
        return phantom(Key.reified(
            T
        ));
    }

    static get p() {
        return Key.phantom
    }

    static get bcs() {
        return bcs.struct("Key", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Key<ToPhantomTypeArgument<T>> {
        return Key.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Key<ToPhantomTypeArgument<T>> {
        if (!isKey(item.type)) {
            throw new Error("not a Key type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Key.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Key<ToPhantomTypeArgument<T>> {

        return Key.fromFields(
            typeArg,
            Key.bcs.parse(data)
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
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): Key<ToPhantomTypeArgument<T>> {
        return Key.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Key<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Key.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Key.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Key.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Key<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Key object`);
        }
        return Key.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Key<ToPhantomTypeArgument<T>>> {
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
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Composition =============================== */

export function isComposition(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_nft::Composition<");
}

export interface CompositionFields<Schema extends PhantomTypeArgument> {
    limits: ToField<VecMap<TypeName, "u64">>
}

export type CompositionReified<Schema extends PhantomTypeArgument> = Reified<
    Composition<Schema>,
    CompositionFields<Schema>
>;

export class Composition<Schema extends PhantomTypeArgument> {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_nft::Composition";
    static readonly $numTypeParams = 1;

    readonly $typeName = Composition.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_nft::Composition<${PhantomToTypeStr<Schema>}>`;

    readonly $typeArg: string;

    ;

    readonly limits:
        ToField<VecMap<TypeName, "u64">>

    private constructor(typeArg: string, fields: CompositionFields<Schema>,
    ) {
        this.$fullTypeName = composeSuiType(Composition.$typeName,
        typeArg) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_nft::Composition<${PhantomToTypeStr<Schema>}>`;

        this.$typeArg = typeArg;

        this.limits = fields.limits;
    }

    static reified<Schema extends PhantomReified<PhantomTypeArgument>>(
        Schema: Schema
    ): CompositionReified<ToPhantomTypeArgument<Schema>> {
        return {
            typeName: Composition.$typeName,
            fullTypeName: composeSuiType(
                Composition.$typeName,
                ...[extractType(Schema)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::composable_nft::Composition<${PhantomToTypeStr<ToPhantomTypeArgument<Schema>>}>`,
            typeArgs: [Schema],
            fromFields: (fields: Record<string, any>) =>
                Composition.fromFields(
                    Schema,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Composition.fromFieldsWithTypes(
                    Schema,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Composition.fromBcs(
                    Schema,
                    data,
                ),
            bcs: Composition.bcs,
            fromJSONField: (field: any) =>
                Composition.fromJSONField(
                    Schema,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Composition.fromJSON(
                    Schema,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Composition.fetch(
                client,
                Schema,
                id,
            ),
            new: (
                fields: CompositionFields<ToPhantomTypeArgument<Schema>>,
            ) => {
                return new Composition(
                    extractType(Schema),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Composition.reified
    }

    static phantom<Schema extends PhantomReified<PhantomTypeArgument>>(
        Schema: Schema
    ): PhantomReified<ToTypeStr<Composition<ToPhantomTypeArgument<Schema>>>> {
        return phantom(Composition.reified(
            Schema
        ));
    }

    static get p() {
        return Composition.phantom
    }

    static get bcs() {
        return bcs.struct("Composition", {
            limits:
                VecMap.bcs(TypeName.bcs, bcs.u64())

        })
    };

    static fromFields<Schema extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Schema, fields: Record<string, any>
    ): Composition<ToPhantomTypeArgument<Schema>> {
        return Composition.reified(
            typeArg,
        ).new(
            {limits: decodeFromFields(VecMap.reified(TypeName.reified(), "u64"), fields.limits)}
        )
    }

    static fromFieldsWithTypes<Schema extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Schema, item: FieldsWithTypes
    ): Composition<ToPhantomTypeArgument<Schema>> {
        if (!isComposition(item.type)) {
            throw new Error("not a Composition type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Composition.reified(
            typeArg,
        ).new(
            {limits: decodeFromFieldsWithTypes(VecMap.reified(TypeName.reified(), "u64"), item.fields.limits)}
        )
    }

    static fromBcs<Schema extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Schema, data: Uint8Array
    ): Composition<ToPhantomTypeArgument<Schema>> {

        return Composition.fromFields(
            typeArg,
            Composition.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            limits: this.limits.toJSONField(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<Schema extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Schema, field: any
    ): Composition<ToPhantomTypeArgument<Schema>> {
        return Composition.reified(
            typeArg,
        ).new(
            {limits: decodeFromJSONField(VecMap.reified(TypeName.reified(), "u64"), field.limits)}
        )
    }

    static fromJSON<Schema extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Schema, json: Record<string, any>
    ): Composition<ToPhantomTypeArgument<Schema>> {
        if (json.$typeName !== Composition.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Composition.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Composition.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<Schema extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Schema, content: SuiParsedData
    ): Composition<ToPhantomTypeArgument<Schema>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isComposition(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Composition object`);
        }
        return Composition.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<Schema extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: Schema, id: string
    ): Promise<Composition<ToPhantomTypeArgument<Schema>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Composition object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isComposition(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Composition object`);
        }

        return Composition.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
