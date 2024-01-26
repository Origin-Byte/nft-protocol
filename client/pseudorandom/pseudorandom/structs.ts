import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Counter =============================== */

export function isCounter(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb::pseudorandom::Counter";
}

export interface CounterFields {
    id: ToField<UID>; value: ToField<"u256">
}

export type CounterReified = Reified<
    Counter,
    CounterFields
>;

export class Counter {
    static readonly $typeName = "0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb::pseudorandom::Counter";
    static readonly $numTypeParams = 0;

    readonly $typeName = Counter.$typeName;

    readonly $fullTypeName: "0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb::pseudorandom::Counter";

    ;

    readonly id:
        ToField<UID>
    ; readonly value:
        ToField<"u256">

    private constructor( fields: CounterFields,
    ) {
        this.$fullTypeName = Counter.$typeName;

        this.id = fields.id;; this.value = fields.value;
    }

    static reified(): CounterReified {
        return {
            typeName: Counter.$typeName,
            fullTypeName: composeSuiType(
                Counter.$typeName,
                ...[]
            ) as "0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb::pseudorandom::Counter",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Counter.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Counter.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Counter.fromBcs(
                    data,
                ),
            bcs: Counter.bcs,
            fromJSONField: (field: any) =>
                Counter.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Counter.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Counter.fetch(
                client,
                id,
            ),
            new: (
                fields: CounterFields,
            ) => {
                return new Counter(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Counter.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Counter>> {
        return phantom(Counter.reified());
    }

    static get p() {
        return Counter.phantom()
    }

    static get bcs() {
        return bcs.struct("Counter", {
            id:
                UID.bcs
            , value:
                bcs.u256()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Counter {
        return Counter.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), value: decodeFromFields("u256", fields.value)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Counter {
        if (!isCounter(item.type)) {
            throw new Error("not a Counter type");
        }

        return Counter.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), value: decodeFromFieldsWithTypes("u256", item.fields.value)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Counter {

        return Counter.fromFields(
            Counter.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,value: this.value.toString(),

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
    ): Counter {
        return Counter.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), value: decodeFromJSONField("u256", field.value)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Counter {
        if (json.$typeName !== Counter.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Counter.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Counter {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isCounter(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Counter object`);
        }
        return Counter.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Counter> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Counter object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isCounter(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Counter object`);
        }

        return Counter.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
