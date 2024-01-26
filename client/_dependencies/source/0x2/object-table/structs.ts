import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {UID} from "../object/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== ObjectTable =============================== */

export function isObjectTable(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::object_table::ObjectTable<");
}

export interface ObjectTableFields<K extends PhantomTypeArgument, V extends PhantomTypeArgument> {
    id: ToField<UID>; size: ToField<"u64">
}

export type ObjectTableReified<K extends PhantomTypeArgument, V extends PhantomTypeArgument> = Reified<
    ObjectTable<K, V>,
    ObjectTableFields<K, V>
>;

export class ObjectTable<K extends PhantomTypeArgument, V extends PhantomTypeArgument> {
    static readonly $typeName = "0x2::object_table::ObjectTable";
    static readonly $numTypeParams = 2;

    readonly $typeName = ObjectTable.$typeName;

    readonly $fullTypeName: `0x2::object_table::ObjectTable<${PhantomToTypeStr<K>}, ${PhantomToTypeStr<V>}>`;

    readonly $typeArgs: [string, string];

    ;

    readonly id:
        ToField<UID>
    ; readonly size:
        ToField<"u64">

    private constructor(typeArgs: [string, string], fields: ObjectTableFields<K, V>,
    ) {
        this.$fullTypeName = composeSuiType(ObjectTable.$typeName,
        ...typeArgs) as `0x2::object_table::ObjectTable<${PhantomToTypeStr<K>}, ${PhantomToTypeStr<V>}>`;

        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.size = fields.size;
    }

    static reified<K extends PhantomReified<PhantomTypeArgument>, V extends PhantomReified<PhantomTypeArgument>>(
        K: K, V: V
    ): ObjectTableReified<ToPhantomTypeArgument<K>, ToPhantomTypeArgument<V>> {
        return {
            typeName: ObjectTable.$typeName,
            fullTypeName: composeSuiType(
                ObjectTable.$typeName,
                ...[extractType(K), extractType(V)]
            ) as `0x2::object_table::ObjectTable<${PhantomToTypeStr<ToPhantomTypeArgument<K>>}, ${PhantomToTypeStr<ToPhantomTypeArgument<V>>}>`,
            typeArgs: [K, V],
            fromFields: (fields: Record<string, any>) =>
                ObjectTable.fromFields(
                    [K, V],
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ObjectTable.fromFieldsWithTypes(
                    [K, V],
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ObjectTable.fromBcs(
                    [K, V],
                    data,
                ),
            bcs: ObjectTable.bcs,
            fromJSONField: (field: any) =>
                ObjectTable.fromJSONField(
                    [K, V],
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ObjectTable.fromJSON(
                    [K, V],
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => ObjectTable.fetch(
                client,
                [K, V],
                id,
            ),
            new: (
                fields: ObjectTableFields<ToPhantomTypeArgument<K>, ToPhantomTypeArgument<V>>,
            ) => {
                return new ObjectTable(
                    [extractType(K), extractType(V)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ObjectTable.reified
    }

    static phantom<K extends PhantomReified<PhantomTypeArgument>, V extends PhantomReified<PhantomTypeArgument>>(
        K: K, V: V
    ): PhantomReified<ToTypeStr<ObjectTable<ToPhantomTypeArgument<K>, ToPhantomTypeArgument<V>>>> {
        return phantom(ObjectTable.reified(
            K, V
        ));
    }

    static get p() {
        return ObjectTable.phantom
    }

    static get bcs() {
        return bcs.struct("ObjectTable", {
            id:
                UID.bcs
            , size:
                bcs.u64()

        })
    };

    static fromFields<K extends PhantomReified<PhantomTypeArgument>, V extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [K, V], fields: Record<string, any>
    ): ObjectTable<ToPhantomTypeArgument<K>, ToPhantomTypeArgument<V>> {
        return ObjectTable.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), size: decodeFromFields("u64", fields.size)}
        )
    }

    static fromFieldsWithTypes<K extends PhantomReified<PhantomTypeArgument>, V extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [K, V], item: FieldsWithTypes
    ): ObjectTable<ToPhantomTypeArgument<K>, ToPhantomTypeArgument<V>> {
        if (!isObjectTable(item.type)) {
            throw new Error("not a ObjectTable type");
        }
        assertFieldsWithTypesArgsMatch(item, typeArgs);

        return ObjectTable.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), size: decodeFromFieldsWithTypes("u64", item.fields.size)}
        )
    }

    static fromBcs<K extends PhantomReified<PhantomTypeArgument>, V extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [K, V], data: Uint8Array
    ): ObjectTable<ToPhantomTypeArgument<K>, ToPhantomTypeArgument<V>> {

        return ObjectTable.fromFields(
            typeArgs,
            ObjectTable.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,size: this.size.toString(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<K extends PhantomReified<PhantomTypeArgument>, V extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [K, V], field: any
    ): ObjectTable<ToPhantomTypeArgument<K>, ToPhantomTypeArgument<V>> {
        return ObjectTable.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), size: decodeFromJSONField("u64", field.size)}
        )
    }

    static fromJSON<K extends PhantomReified<PhantomTypeArgument>, V extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [K, V], json: Record<string, any>
    ): ObjectTable<ToPhantomTypeArgument<K>, ToPhantomTypeArgument<V>> {
        if (json.$typeName !== ObjectTable.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(ObjectTable.$typeName,
            ...typeArgs.map(extractType)),
            json.$typeArgs,
            typeArgs,
        )

        return ObjectTable.fromJSONField(
            typeArgs,
            json,
        )
    }

    static fromSuiParsedData<K extends PhantomReified<PhantomTypeArgument>, V extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [K, V], content: SuiParsedData
    ): ObjectTable<ToPhantomTypeArgument<K>, ToPhantomTypeArgument<V>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isObjectTable(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ObjectTable object`);
        }
        return ObjectTable.fromFieldsWithTypes(
            typeArgs,
            content
        );
    }

    static async fetch<K extends PhantomReified<PhantomTypeArgument>, V extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArgs: [K, V], id: string
    ): Promise<ObjectTable<ToPhantomTypeArgument<K>, ToPhantomTypeArgument<V>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ObjectTable object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isObjectTable(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ObjectTable object`);
        }

        return ObjectTable.fromBcs(
            typeArgs,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
