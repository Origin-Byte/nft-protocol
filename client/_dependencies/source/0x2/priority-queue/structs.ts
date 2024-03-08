import * as reified from "../../../../_framework/reified";
import {PhantomReified, Reified, StructClass, ToField, ToTypeArgument, ToTypeStr, TypeArgument, Vector, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom, toBcs} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {BcsType, bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Entry =============================== */

export function isEntry(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::priority_queue::Entry<");
}

export interface EntryFields<T extends TypeArgument> {
    priority: ToField<"u64">; value: ToField<T>
}

export type EntryReified<T extends TypeArgument> = Reified<
    Entry<T>,
    EntryFields<T>
>;

export class Entry<T extends TypeArgument> implements StructClass {
    static readonly $typeName = "0x2::priority_queue::Entry";
    static readonly $numTypeParams = 1;

    readonly $typeName = Entry.$typeName;

    readonly $fullTypeName: `0x2::priority_queue::Entry<${ToTypeStr<T>}>`;

    readonly $typeArgs: [ToTypeStr<T>];

    readonly priority:
        ToField<"u64">
    ; readonly value:
        ToField<T>

    private constructor(typeArgs: [ToTypeStr<T>], fields: EntryFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            Entry.$typeName,
            ...typeArgs
        ) as `0x2::priority_queue::Entry<${ToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.priority = fields.priority;; this.value = fields.value;
    }

    static reified<T extends Reified<TypeArgument, any>>(
        T: T
    ): EntryReified<ToTypeArgument<T>> {
        return {
            typeName: Entry.$typeName,
            fullTypeName: composeSuiType(
                Entry.$typeName,
                ...[extractType(T)]
            ) as `0x2::priority_queue::Entry<${ToTypeStr<ToTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [ToTypeStr<ToTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Entry.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Entry.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Entry.fromBcs(
                    T,
                    data,
                ),
            bcs: Entry.bcs(toBcs(T)),
            fromJSONField: (field: any) =>
                Entry.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Entry.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Entry.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Entry.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: EntryFields<ToTypeArgument<T>>,
            ) => {
                return new Entry(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Entry.reified
    }

    static phantom<T extends Reified<TypeArgument, any>>(
        T: T
    ): PhantomReified<ToTypeStr<Entry<ToTypeArgument<T>>>> {
        return phantom(Entry.reified(
            T
        ));
    }

    static get p() {
        return Entry.phantom
    }

    static get bcs() {
        return <T extends BcsType<any>>(T: T) => bcs.struct(`Entry<${T.name}>`, {
            priority:
                bcs.u64()
            , value:
                T

        })
    };

    static fromFields<T extends Reified<TypeArgument, any>>(
        typeArg: T, fields: Record<string, any>
    ): Entry<ToTypeArgument<T>> {
        return Entry.reified(
            typeArg,
        ).new(
            {priority: decodeFromFields("u64", fields.priority), value: decodeFromFields(typeArg, fields.value)}
        )
    }

    static fromFieldsWithTypes<T extends Reified<TypeArgument, any>>(
        typeArg: T, item: FieldsWithTypes
    ): Entry<ToTypeArgument<T>> {
        if (!isEntry(item.type)) {
            throw new Error("not a Entry type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Entry.reified(
            typeArg,
        ).new(
            {priority: decodeFromFieldsWithTypes("u64", item.fields.priority), value: decodeFromFieldsWithTypes(typeArg, item.fields.value)}
        )
    }

    static fromBcs<T extends Reified<TypeArgument, any>>(
        typeArg: T, data: Uint8Array
    ): Entry<ToTypeArgument<T>> {
        const typeArgs = [typeArg];

        return Entry.fromFields(
            typeArg,
            Entry.bcs(toBcs(typeArgs[0])).parse(data)
        )
    }

    toJSONField() {
        return {
            priority: this.priority.toString(),value: fieldToJSON<T>(this.$typeArgs[0], this.value),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends Reified<TypeArgument, any>>(
        typeArg: T, field: any
    ): Entry<ToTypeArgument<T>> {
        return Entry.reified(
            typeArg,
        ).new(
            {priority: decodeFromJSONField("u64", field.priority), value: decodeFromJSONField(typeArg, field.value)}
        )
    }

    static fromJSON<T extends Reified<TypeArgument, any>>(
        typeArg: T, json: Record<string, any>
    ): Entry<ToTypeArgument<T>> {
        if (json.$typeName !== Entry.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Entry.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return Entry.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends Reified<TypeArgument, any>>(
        typeArg: T, content: SuiParsedData
    ): Entry<ToTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isEntry(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Entry object`);
        }
        return Entry.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Entry<ToTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Entry object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isEntry(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Entry object`);
        }

        return Entry.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== PriorityQueue =============================== */

export function isPriorityQueue(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::priority_queue::PriorityQueue<");
}

export interface PriorityQueueFields<T extends TypeArgument> {
    entries: ToField<Vector<Entry<T>>>
}

export type PriorityQueueReified<T extends TypeArgument> = Reified<
    PriorityQueue<T>,
    PriorityQueueFields<T>
>;

export class PriorityQueue<T extends TypeArgument> implements StructClass {
    static readonly $typeName = "0x2::priority_queue::PriorityQueue";
    static readonly $numTypeParams = 1;

    readonly $typeName = PriorityQueue.$typeName;

    readonly $fullTypeName: `0x2::priority_queue::PriorityQueue<${ToTypeStr<T>}>`;

    readonly $typeArgs: [ToTypeStr<T>];

    readonly entries:
        ToField<Vector<Entry<T>>>

    private constructor(typeArgs: [ToTypeStr<T>], fields: PriorityQueueFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            PriorityQueue.$typeName,
            ...typeArgs
        ) as `0x2::priority_queue::PriorityQueue<${ToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.entries = fields.entries;
    }

    static reified<T extends Reified<TypeArgument, any>>(
        T: T
    ): PriorityQueueReified<ToTypeArgument<T>> {
        return {
            typeName: PriorityQueue.$typeName,
            fullTypeName: composeSuiType(
                PriorityQueue.$typeName,
                ...[extractType(T)]
            ) as `0x2::priority_queue::PriorityQueue<${ToTypeStr<ToTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [ToTypeStr<ToTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                PriorityQueue.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                PriorityQueue.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                PriorityQueue.fromBcs(
                    T,
                    data,
                ),
            bcs: PriorityQueue.bcs(toBcs(T)),
            fromJSONField: (field: any) =>
                PriorityQueue.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                PriorityQueue.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                PriorityQueue.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => PriorityQueue.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: PriorityQueueFields<ToTypeArgument<T>>,
            ) => {
                return new PriorityQueue(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return PriorityQueue.reified
    }

    static phantom<T extends Reified<TypeArgument, any>>(
        T: T
    ): PhantomReified<ToTypeStr<PriorityQueue<ToTypeArgument<T>>>> {
        return phantom(PriorityQueue.reified(
            T
        ));
    }

    static get p() {
        return PriorityQueue.phantom
    }

    static get bcs() {
        return <T extends BcsType<any>>(T: T) => bcs.struct(`PriorityQueue<${T.name}>`, {
            entries:
                bcs.vector(Entry.bcs(T))

        })
    };

    static fromFields<T extends Reified<TypeArgument, any>>(
        typeArg: T, fields: Record<string, any>
    ): PriorityQueue<ToTypeArgument<T>> {
        return PriorityQueue.reified(
            typeArg,
        ).new(
            {entries: decodeFromFields(reified.vector(Entry.reified(typeArg)), fields.entries)}
        )
    }

    static fromFieldsWithTypes<T extends Reified<TypeArgument, any>>(
        typeArg: T, item: FieldsWithTypes
    ): PriorityQueue<ToTypeArgument<T>> {
        if (!isPriorityQueue(item.type)) {
            throw new Error("not a PriorityQueue type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return PriorityQueue.reified(
            typeArg,
        ).new(
            {entries: decodeFromFieldsWithTypes(reified.vector(Entry.reified(typeArg)), item.fields.entries)}
        )
    }

    static fromBcs<T extends Reified<TypeArgument, any>>(
        typeArg: T, data: Uint8Array
    ): PriorityQueue<ToTypeArgument<T>> {
        const typeArgs = [typeArg];

        return PriorityQueue.fromFields(
            typeArg,
            PriorityQueue.bcs(toBcs(typeArgs[0])).parse(data)
        )
    }

    toJSONField() {
        return {
            entries: fieldToJSON<Vector<Entry<T>>>(`vector<0x2::priority_queue::Entry<${this.$typeArgs[0]}>>`, this.entries),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends Reified<TypeArgument, any>>(
        typeArg: T, field: any
    ): PriorityQueue<ToTypeArgument<T>> {
        return PriorityQueue.reified(
            typeArg,
        ).new(
            {entries: decodeFromJSONField(reified.vector(Entry.reified(typeArg)), field.entries)}
        )
    }

    static fromJSON<T extends Reified<TypeArgument, any>>(
        typeArg: T, json: Record<string, any>
    ): PriorityQueue<ToTypeArgument<T>> {
        if (json.$typeName !== PriorityQueue.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(PriorityQueue.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return PriorityQueue.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends Reified<TypeArgument, any>>(
        typeArg: T, content: SuiParsedData
    ): PriorityQueue<ToTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isPriorityQueue(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a PriorityQueue object`);
        }
        return PriorityQueue.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<PriorityQueue<ToTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching PriorityQueue object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isPriorityQueue(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a PriorityQueue object`);
        }

        return PriorityQueue.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
