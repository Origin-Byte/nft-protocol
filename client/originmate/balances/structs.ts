import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Balances =============================== */

export function isBalances(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::balances::Balances";
}

export interface BalancesFields {
    inner: ToField<UID>; items: ToField<"u64">
}

export type BalancesReified = Reified<
    Balances,
    BalancesFields
>;

export class Balances implements StructClass {
    static readonly $typeName = "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::balances::Balances";
    static readonly $numTypeParams = 0;

    readonly $typeName = Balances.$typeName;

    readonly $fullTypeName: "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::balances::Balances";

    readonly $typeArgs: [];

    readonly inner:
        ToField<UID>
    ; readonly items:
        ToField<"u64">

    private constructor(typeArgs: [], fields: BalancesFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Balances.$typeName,
            ...typeArgs
        ) as "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::balances::Balances";
        this.$typeArgs = typeArgs;

        this.inner = fields.inner;; this.items = fields.items;
    }

    static reified(): BalancesReified {
        return {
            typeName: Balances.$typeName,
            fullTypeName: composeSuiType(
                Balances.$typeName,
                ...[]
            ) as "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::balances::Balances",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Balances.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Balances.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Balances.fromBcs(
                    data,
                ),
            bcs: Balances.bcs,
            fromJSONField: (field: any) =>
                Balances.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Balances.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Balances.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Balances.fetch(
                client,
                id,
            ),
            new: (
                fields: BalancesFields,
            ) => {
                return new Balances(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Balances.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Balances>> {
        return phantom(Balances.reified());
    }

    static get p() {
        return Balances.phantom()
    }

    static get bcs() {
        return bcs.struct("Balances", {
            inner:
                UID.bcs
            , items:
                bcs.u64()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Balances {
        return Balances.reified().new(
            {inner: decodeFromFields(UID.reified(), fields.inner), items: decodeFromFields("u64", fields.items)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Balances {
        if (!isBalances(item.type)) {
            throw new Error("not a Balances type");
        }

        return Balances.reified().new(
            {inner: decodeFromFieldsWithTypes(UID.reified(), item.fields.inner), items: decodeFromFieldsWithTypes("u64", item.fields.items)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Balances {

        return Balances.fromFields(
            Balances.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            inner: this.inner,items: this.items.toString(),

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
    ): Balances {
        return Balances.reified().new(
            {inner: decodeFromJSONField(UID.reified(), field.inner), items: decodeFromJSONField("u64", field.items)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Balances {
        if (json.$typeName !== Balances.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Balances.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Balances {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBalances(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Balances object`);
        }
        return Balances.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Balances> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Balances object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBalances(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Balances object`);
        }

        return Balances.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
