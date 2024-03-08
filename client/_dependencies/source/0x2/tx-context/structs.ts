import * as reified from "../../../../_framework/reified";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, Vector, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, fieldToJSON, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== TxContext =============================== */

export function isTxContext(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::tx_context::TxContext";
}

export interface TxContextFields {
    sender: ToField<"address">; txHash: ToField<Vector<"u8">>; epoch: ToField<"u64">; epochTimestampMs: ToField<"u64">; idsCreated: ToField<"u64">
}

export type TxContextReified = Reified<
    TxContext,
    TxContextFields
>;

export class TxContext implements StructClass {
    static readonly $typeName = "0x2::tx_context::TxContext";
    static readonly $numTypeParams = 0;

    readonly $typeName = TxContext.$typeName;

    readonly $fullTypeName: "0x2::tx_context::TxContext";

    readonly $typeArgs: [];

    readonly sender:
        ToField<"address">
    ; readonly txHash:
        ToField<Vector<"u8">>
    ; readonly epoch:
        ToField<"u64">
    ; readonly epochTimestampMs:
        ToField<"u64">
    ; readonly idsCreated:
        ToField<"u64">

    private constructor(typeArgs: [], fields: TxContextFields,
    ) {
        this.$fullTypeName = composeSuiType(
            TxContext.$typeName,
            ...typeArgs
        ) as "0x2::tx_context::TxContext";
        this.$typeArgs = typeArgs;

        this.sender = fields.sender;; this.txHash = fields.txHash;; this.epoch = fields.epoch;; this.epochTimestampMs = fields.epochTimestampMs;; this.idsCreated = fields.idsCreated;
    }

    static reified(): TxContextReified {
        return {
            typeName: TxContext.$typeName,
            fullTypeName: composeSuiType(
                TxContext.$typeName,
                ...[]
            ) as "0x2::tx_context::TxContext",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                TxContext.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TxContext.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TxContext.fromBcs(
                    data,
                ),
            bcs: TxContext.bcs,
            fromJSONField: (field: any) =>
                TxContext.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TxContext.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                TxContext.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => TxContext.fetch(
                client,
                id,
            ),
            new: (
                fields: TxContextFields,
            ) => {
                return new TxContext(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TxContext.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<TxContext>> {
        return phantom(TxContext.reified());
    }

    static get p() {
        return TxContext.phantom()
    }

    static get bcs() {
        return bcs.struct("TxContext", {
            sender:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , tx_hash:
                bcs.vector(bcs.u8())
            , epoch:
                bcs.u64()
            , epoch_timestamp_ms:
                bcs.u64()
            , ids_created:
                bcs.u64()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): TxContext {
        return TxContext.reified().new(
            {sender: decodeFromFields("address", fields.sender), txHash: decodeFromFields(reified.vector("u8"), fields.tx_hash), epoch: decodeFromFields("u64", fields.epoch), epochTimestampMs: decodeFromFields("u64", fields.epoch_timestamp_ms), idsCreated: decodeFromFields("u64", fields.ids_created)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): TxContext {
        if (!isTxContext(item.type)) {
            throw new Error("not a TxContext type");
        }

        return TxContext.reified().new(
            {sender: decodeFromFieldsWithTypes("address", item.fields.sender), txHash: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.tx_hash), epoch: decodeFromFieldsWithTypes("u64", item.fields.epoch), epochTimestampMs: decodeFromFieldsWithTypes("u64", item.fields.epoch_timestamp_ms), idsCreated: decodeFromFieldsWithTypes("u64", item.fields.ids_created)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): TxContext {

        return TxContext.fromFields(
            TxContext.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            sender: this.sender,txHash: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.txHash),epoch: this.epoch.toString(),epochTimestampMs: this.epochTimestampMs.toString(),idsCreated: this.idsCreated.toString(),

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
    ): TxContext {
        return TxContext.reified().new(
            {sender: decodeFromJSONField("address", field.sender), txHash: decodeFromJSONField(reified.vector("u8"), field.txHash), epoch: decodeFromJSONField("u64", field.epoch), epochTimestampMs: decodeFromJSONField("u64", field.epochTimestampMs), idsCreated: decodeFromJSONField("u64", field.idsCreated)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): TxContext {
        if (json.$typeName !== TxContext.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return TxContext.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): TxContext {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTxContext(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TxContext object`);
        }
        return TxContext.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<TxContext> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TxContext object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTxContext(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TxContext object`);
        }

        return TxContext.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
