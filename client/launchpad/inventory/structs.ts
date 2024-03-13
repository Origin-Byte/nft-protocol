import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Inventory =============================== */

export function isInventory(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::inventory::Inventory<");
}

export interface InventoryFields<T extends PhantomTypeArgument> {
    id: ToField<UID>
}

export type InventoryReified<T extends PhantomTypeArgument> = Reified<
    Inventory<T>,
    InventoryFields<T>
>;

export class Inventory<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::inventory::Inventory";
    static readonly $numTypeParams = 1;

    readonly $typeName = Inventory.$typeName;

    readonly $fullTypeName: `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::inventory::Inventory<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly id:
        ToField<UID>

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: InventoryFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            Inventory.$typeName,
            ...typeArgs
        ) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::inventory::Inventory<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): InventoryReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Inventory.$typeName,
            fullTypeName: composeSuiType(
                Inventory.$typeName,
                ...[extractType(T)]
            ) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::inventory::Inventory<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Inventory.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Inventory.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Inventory.fromBcs(
                    T,
                    data,
                ),
            bcs: Inventory.bcs,
            fromJSONField: (field: any) =>
                Inventory.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Inventory.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Inventory.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Inventory.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: InventoryFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Inventory(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Inventory.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Inventory<ToPhantomTypeArgument<T>>>> {
        return phantom(Inventory.reified(
            T
        ));
    }

    static get p() {
        return Inventory.phantom
    }

    static get bcs() {
        return bcs.struct("Inventory", {
            id:
                UID.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Inventory<ToPhantomTypeArgument<T>> {
        return Inventory.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Inventory<ToPhantomTypeArgument<T>> {
        if (!isInventory(item.type)) {
            throw new Error("not a Inventory type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Inventory.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Inventory<ToPhantomTypeArgument<T>> {

        return Inventory.fromFields(
            typeArg,
            Inventory.bcs.parse(data)
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
    ): Inventory<ToPhantomTypeArgument<T>> {
        return Inventory.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Inventory<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Inventory.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Inventory.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return Inventory.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Inventory<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isInventory(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Inventory object`);
        }
        return Inventory.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Inventory<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Inventory object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isInventory(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Inventory object`);
        }

        return Inventory.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== WarehouseKey =============================== */

export function isWarehouseKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::inventory::WarehouseKey";
}

export interface WarehouseKeyFields {
    dummyField: ToField<"bool">
}

export type WarehouseKeyReified = Reified<
    WarehouseKey,
    WarehouseKeyFields
>;

export class WarehouseKey implements StructClass {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::inventory::WarehouseKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = WarehouseKey.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::inventory::WarehouseKey";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: WarehouseKeyFields,
    ) {
        this.$fullTypeName = composeSuiType(
            WarehouseKey.$typeName,
            ...typeArgs
        ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::inventory::WarehouseKey";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): WarehouseKeyReified {
        return {
            typeName: WarehouseKey.$typeName,
            fullTypeName: composeSuiType(
                WarehouseKey.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::inventory::WarehouseKey",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                WarehouseKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                WarehouseKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                WarehouseKey.fromBcs(
                    data,
                ),
            bcs: WarehouseKey.bcs,
            fromJSONField: (field: any) =>
                WarehouseKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                WarehouseKey.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                WarehouseKey.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => WarehouseKey.fetch(
                client,
                id,
            ),
            new: (
                fields: WarehouseKeyFields,
            ) => {
                return new WarehouseKey(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return WarehouseKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<WarehouseKey>> {
        return phantom(WarehouseKey.reified());
    }

    static get p() {
        return WarehouseKey.phantom()
    }

    static get bcs() {
        return bcs.struct("WarehouseKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): WarehouseKey {
        return WarehouseKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): WarehouseKey {
        if (!isWarehouseKey(item.type)) {
            throw new Error("not a WarehouseKey type");
        }

        return WarehouseKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): WarehouseKey {

        return WarehouseKey.fromFields(
            WarehouseKey.bcs.parse(data)
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
    ): WarehouseKey {
        return WarehouseKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): WarehouseKey {
        if (json.$typeName !== WarehouseKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return WarehouseKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): WarehouseKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWarehouseKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a WarehouseKey object`);
        }
        return WarehouseKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<WarehouseKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching WarehouseKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWarehouseKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a WarehouseKey object`);
        }

        return WarehouseKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
