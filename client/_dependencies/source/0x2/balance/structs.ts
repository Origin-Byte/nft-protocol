import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Balance =============================== */

export function isBalance(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::balance::Balance<");
}

export interface BalanceFields<T extends PhantomTypeArgument> {
    value: ToField<"u64">
}

export type BalanceReified<T extends PhantomTypeArgument> = Reified<
    Balance<T>,
    BalanceFields<T>
>;

export class Balance<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x2::balance::Balance";
    static readonly $numTypeParams = 1;

    readonly $typeName = Balance.$typeName;

    readonly $fullTypeName: `0x2::balance::Balance<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly value:
        ToField<"u64">

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: BalanceFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            Balance.$typeName,
            ...typeArgs
        ) as `0x2::balance::Balance<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.value = fields.value;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): BalanceReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Balance.$typeName,
            fullTypeName: composeSuiType(
                Balance.$typeName,
                ...[extractType(T)]
            ) as `0x2::balance::Balance<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Balance.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Balance.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Balance.fromBcs(
                    T,
                    data,
                ),
            bcs: Balance.bcs,
            fromJSONField: (field: any) =>
                Balance.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Balance.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Balance.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Balance.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: BalanceFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Balance(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Balance.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Balance<ToPhantomTypeArgument<T>>>> {
        return phantom(Balance.reified(
            T
        ));
    }

    static get p() {
        return Balance.phantom
    }

    static get bcs() {
        return bcs.struct("Balance", {
            value:
                bcs.u64()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Balance<ToPhantomTypeArgument<T>> {
        return Balance.reified(
            typeArg,
        ).new(
            {value: decodeFromFields("u64", fields.value)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Balance<ToPhantomTypeArgument<T>> {
        if (!isBalance(item.type)) {
            throw new Error("not a Balance type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Balance.reified(
            typeArg,
        ).new(
            {value: decodeFromFieldsWithTypes("u64", item.fields.value)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Balance<ToPhantomTypeArgument<T>> {

        return Balance.fromFields(
            typeArg,
            Balance.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            value: this.value.toString(),

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
    ): Balance<ToPhantomTypeArgument<T>> {
        return Balance.reified(
            typeArg,
        ).new(
            {value: decodeFromJSONField("u64", field.value)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Balance<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Balance.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Balance.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return Balance.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Balance<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBalance(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Balance object`);
        }
        return Balance.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Balance<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Balance object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBalance(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Balance object`);
        }

        return Balance.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Supply =============================== */

export function isSupply(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::balance::Supply<");
}

export interface SupplyFields<T extends PhantomTypeArgument> {
    value: ToField<"u64">
}

export type SupplyReified<T extends PhantomTypeArgument> = Reified<
    Supply<T>,
    SupplyFields<T>
>;

export class Supply<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x2::balance::Supply";
    static readonly $numTypeParams = 1;

    readonly $typeName = Supply.$typeName;

    readonly $fullTypeName: `0x2::balance::Supply<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly value:
        ToField<"u64">

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: SupplyFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            Supply.$typeName,
            ...typeArgs
        ) as `0x2::balance::Supply<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.value = fields.value;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): SupplyReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Supply.$typeName,
            fullTypeName: composeSuiType(
                Supply.$typeName,
                ...[extractType(T)]
            ) as `0x2::balance::Supply<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Supply.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Supply.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Supply.fromBcs(
                    T,
                    data,
                ),
            bcs: Supply.bcs,
            fromJSONField: (field: any) =>
                Supply.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Supply.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Supply.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Supply.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: SupplyFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Supply(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Supply.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Supply<ToPhantomTypeArgument<T>>>> {
        return phantom(Supply.reified(
            T
        ));
    }

    static get p() {
        return Supply.phantom
    }

    static get bcs() {
        return bcs.struct("Supply", {
            value:
                bcs.u64()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Supply<ToPhantomTypeArgument<T>> {
        return Supply.reified(
            typeArg,
        ).new(
            {value: decodeFromFields("u64", fields.value)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Supply<ToPhantomTypeArgument<T>> {
        if (!isSupply(item.type)) {
            throw new Error("not a Supply type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Supply.reified(
            typeArg,
        ).new(
            {value: decodeFromFieldsWithTypes("u64", item.fields.value)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Supply<ToPhantomTypeArgument<T>> {

        return Supply.fromFields(
            typeArg,
            Supply.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            value: this.value.toString(),

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
    ): Supply<ToPhantomTypeArgument<T>> {
        return Supply.reified(
            typeArg,
        ).new(
            {value: decodeFromJSONField("u64", field.value)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Supply<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Supply.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Supply.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return Supply.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Supply<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isSupply(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Supply object`);
        }
        return Supply.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Supply<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Supply object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isSupply(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Supply object`);
        }

        return Supply.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
