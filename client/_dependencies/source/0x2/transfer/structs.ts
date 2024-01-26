import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {ID} from "../object/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Receiving =============================== */

export function isReceiving(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::transfer::Receiving<");
}

export interface ReceivingFields<T extends PhantomTypeArgument> {
    id: ToField<ID>; version: ToField<"u64">
}

export type ReceivingReified<T extends PhantomTypeArgument> = Reified<
    Receiving<T>,
    ReceivingFields<T>
>;

export class Receiving<T extends PhantomTypeArgument> {
    static readonly $typeName = "0x2::transfer::Receiving";
    static readonly $numTypeParams = 1;

    readonly $typeName = Receiving.$typeName;

    readonly $fullTypeName: `0x2::transfer::Receiving<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<ID>
    ; readonly version:
        ToField<"u64">

    private constructor(typeArg: string, fields: ReceivingFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(Receiving.$typeName,
        typeArg) as `0x2::transfer::Receiving<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.version = fields.version;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): ReceivingReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Receiving.$typeName,
            fullTypeName: composeSuiType(
                Receiving.$typeName,
                ...[extractType(T)]
            ) as `0x2::transfer::Receiving<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Receiving.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Receiving.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Receiving.fromBcs(
                    T,
                    data,
                ),
            bcs: Receiving.bcs,
            fromJSONField: (field: any) =>
                Receiving.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Receiving.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Receiving.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: ReceivingFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Receiving(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Receiving.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Receiving<ToPhantomTypeArgument<T>>>> {
        return phantom(Receiving.reified(
            T
        ));
    }

    static get p() {
        return Receiving.phantom
    }

    static get bcs() {
        return bcs.struct("Receiving", {
            id:
                ID.bcs
            , version:
                bcs.u64()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Receiving<ToPhantomTypeArgument<T>> {
        return Receiving.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(ID.reified(), fields.id), version: decodeFromFields("u64", fields.version)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Receiving<ToPhantomTypeArgument<T>> {
        if (!isReceiving(item.type)) {
            throw new Error("not a Receiving type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Receiving.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id), version: decodeFromFieldsWithTypes("u64", item.fields.version)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Receiving<ToPhantomTypeArgument<T>> {

        return Receiving.fromFields(
            typeArg,
            Receiving.bcs.parse(data)
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
    ): Receiving<ToPhantomTypeArgument<T>> {
        return Receiving.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(ID.reified(), field.id), version: decodeFromJSONField("u64", field.version)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Receiving<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Receiving.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Receiving.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Receiving.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Receiving<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isReceiving(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Receiving object`);
        }
        return Receiving.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Receiving<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Receiving object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isReceiving(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Receiving object`);
        }

        return Receiving.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
