import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== TransferToken =============================== */

export function isTransferToken(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_token::TransferToken<");
}

export interface TransferTokenFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; receiver: ToField<"address">
}

export type TransferTokenReified<T extends PhantomTypeArgument> = Reified<
    TransferToken<T>,
    TransferTokenFields<T>
>;

export class TransferToken<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_token::TransferToken";
    static readonly $numTypeParams = 1;

    readonly $typeName = TransferToken.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_token::TransferToken<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly id:
        ToField<UID>
    ; readonly receiver:
        ToField<"address">

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: TransferTokenFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            TransferToken.$typeName,
            ...typeArgs
        ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_token::TransferToken<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.receiver = fields.receiver;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): TransferTokenReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: TransferToken.$typeName,
            fullTypeName: composeSuiType(
                TransferToken.$typeName,
                ...[extractType(T)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_token::TransferToken<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                TransferToken.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TransferToken.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TransferToken.fromBcs(
                    T,
                    data,
                ),
            bcs: TransferToken.bcs,
            fromJSONField: (field: any) =>
                TransferToken.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TransferToken.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                TransferToken.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => TransferToken.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: TransferTokenFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new TransferToken(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TransferToken.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<TransferToken<ToPhantomTypeArgument<T>>>> {
        return phantom(TransferToken.reified(
            T
        ));
    }

    static get p() {
        return TransferToken.phantom
    }

    static get bcs() {
        return bcs.struct("TransferToken", {
            id:
                UID.bcs
            , receiver:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): TransferToken<ToPhantomTypeArgument<T>> {
        return TransferToken.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), receiver: decodeFromFields("address", fields.receiver)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): TransferToken<ToPhantomTypeArgument<T>> {
        if (!isTransferToken(item.type)) {
            throw new Error("not a TransferToken type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return TransferToken.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), receiver: decodeFromFieldsWithTypes("address", item.fields.receiver)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): TransferToken<ToPhantomTypeArgument<T>> {

        return TransferToken.fromFields(
            typeArg,
            TransferToken.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,receiver: this.receiver,

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
    ): TransferToken<ToPhantomTypeArgument<T>> {
        return TransferToken.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), receiver: decodeFromJSONField("address", field.receiver)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): TransferToken<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== TransferToken.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(TransferToken.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return TransferToken.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): TransferToken<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTransferToken(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TransferToken object`);
        }
        return TransferToken.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<TransferToken<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TransferToken object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTransferToken(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TransferToken object`);
        }

        return TransferToken.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== TransferTokenRule =============================== */

export function isTransferTokenRule(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_token::TransferTokenRule";
}

export interface TransferTokenRuleFields {
    dummyField: ToField<"bool">
}

export type TransferTokenRuleReified = Reified<
    TransferTokenRule,
    TransferTokenRuleFields
>;

export class TransferTokenRule implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_token::TransferTokenRule";
    static readonly $numTypeParams = 0;

    readonly $typeName = TransferTokenRule.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_token::TransferTokenRule";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: TransferTokenRuleFields,
    ) {
        this.$fullTypeName = composeSuiType(
            TransferTokenRule.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_token::TransferTokenRule";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): TransferTokenRuleReified {
        return {
            typeName: TransferTokenRule.$typeName,
            fullTypeName: composeSuiType(
                TransferTokenRule.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_token::TransferTokenRule",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                TransferTokenRule.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TransferTokenRule.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TransferTokenRule.fromBcs(
                    data,
                ),
            bcs: TransferTokenRule.bcs,
            fromJSONField: (field: any) =>
                TransferTokenRule.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TransferTokenRule.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                TransferTokenRule.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => TransferTokenRule.fetch(
                client,
                id,
            ),
            new: (
                fields: TransferTokenRuleFields,
            ) => {
                return new TransferTokenRule(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TransferTokenRule.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<TransferTokenRule>> {
        return phantom(TransferTokenRule.reified());
    }

    static get p() {
        return TransferTokenRule.phantom()
    }

    static get bcs() {
        return bcs.struct("TransferTokenRule", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): TransferTokenRule {
        return TransferTokenRule.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): TransferTokenRule {
        if (!isTransferTokenRule(item.type)) {
            throw new Error("not a TransferTokenRule type");
        }

        return TransferTokenRule.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): TransferTokenRule {

        return TransferTokenRule.fromFields(
            TransferTokenRule.bcs.parse(data)
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
    ): TransferTokenRule {
        return TransferTokenRule.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): TransferTokenRule {
        if (json.$typeName !== TransferTokenRule.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return TransferTokenRule.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): TransferTokenRule {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTransferTokenRule(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TransferTokenRule object`);
        }
        return TransferTokenRule.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<TransferTokenRule> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TransferTokenRule object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTransferTokenRule(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TransferTokenRule object`);
        }

        return TransferTokenRule.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
