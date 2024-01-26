import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {String as String1} from "../../0x1/ascii/structs";
import {Option} from "../../0x1/option/structs";
import {String} from "../../0x1/string/structs";
import {Balance, Supply} from "../balance/structs";
import {UID} from "../object/structs";
import {Url} from "../url/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Coin =============================== */

export function isCoin(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::coin::Coin<");
}

export interface CoinFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; balance: ToField<Balance<T>>
}

export type CoinReified<T extends PhantomTypeArgument> = Reified<
    Coin<T>,
    CoinFields<T>
>;

export class Coin<T extends PhantomTypeArgument> {
    static readonly $typeName = "0x2::coin::Coin";
    static readonly $numTypeParams = 1;

    readonly $typeName = Coin.$typeName;

    readonly $fullTypeName: `0x2::coin::Coin<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly balance:
        ToField<Balance<T>>

    private constructor(typeArg: string, fields: CoinFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(Coin.$typeName,
        typeArg) as `0x2::coin::Coin<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.balance = fields.balance;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): CoinReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Coin.$typeName,
            fullTypeName: composeSuiType(
                Coin.$typeName,
                ...[extractType(T)]
            ) as `0x2::coin::Coin<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Coin.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Coin.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Coin.fromBcs(
                    T,
                    data,
                ),
            bcs: Coin.bcs,
            fromJSONField: (field: any) =>
                Coin.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Coin.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Coin.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: CoinFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Coin(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Coin.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Coin<ToPhantomTypeArgument<T>>>> {
        return phantom(Coin.reified(
            T
        ));
    }

    static get p() {
        return Coin.phantom
    }

    static get bcs() {
        return bcs.struct("Coin", {
            id:
                UID.bcs
            , balance:
                Balance.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Coin<ToPhantomTypeArgument<T>> {
        return Coin.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), balance: decodeFromFields(Balance.reified(typeArg), fields.balance)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Coin<ToPhantomTypeArgument<T>> {
        if (!isCoin(item.type)) {
            throw new Error("not a Coin type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Coin.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), balance: decodeFromFieldsWithTypes(Balance.reified(typeArg), item.fields.balance)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Coin<ToPhantomTypeArgument<T>> {

        return Coin.fromFields(
            typeArg,
            Coin.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,balance: this.balance.toJSONField(),

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
    ): Coin<ToPhantomTypeArgument<T>> {
        return Coin.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), balance: decodeFromJSONField(Balance.reified(typeArg), field.balance)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Coin<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Coin.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Coin.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Coin.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Coin<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isCoin(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Coin object`);
        }
        return Coin.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Coin<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Coin object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isCoin(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Coin object`);
        }

        return Coin.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== CoinMetadata =============================== */

export function isCoinMetadata(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::coin::CoinMetadata<");
}

export interface CoinMetadataFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; decimals: ToField<"u8">; name: ToField<String>; symbol: ToField<String1>; description: ToField<String>; iconUrl: ToField<Option<Url>>
}

export type CoinMetadataReified<T extends PhantomTypeArgument> = Reified<
    CoinMetadata<T>,
    CoinMetadataFields<T>
>;

export class CoinMetadata<T extends PhantomTypeArgument> {
    static readonly $typeName = "0x2::coin::CoinMetadata";
    static readonly $numTypeParams = 1;

    readonly $typeName = CoinMetadata.$typeName;

    readonly $fullTypeName: `0x2::coin::CoinMetadata<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly decimals:
        ToField<"u8">
    ; readonly name:
        ToField<String>
    ; readonly symbol:
        ToField<String1>
    ; readonly description:
        ToField<String>
    ; readonly iconUrl:
        ToField<Option<Url>>

    private constructor(typeArg: string, fields: CoinMetadataFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(CoinMetadata.$typeName,
        typeArg) as `0x2::coin::CoinMetadata<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.decimals = fields.decimals;; this.name = fields.name;; this.symbol = fields.symbol;; this.description = fields.description;; this.iconUrl = fields.iconUrl;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): CoinMetadataReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: CoinMetadata.$typeName,
            fullTypeName: composeSuiType(
                CoinMetadata.$typeName,
                ...[extractType(T)]
            ) as `0x2::coin::CoinMetadata<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                CoinMetadata.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                CoinMetadata.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                CoinMetadata.fromBcs(
                    T,
                    data,
                ),
            bcs: CoinMetadata.bcs,
            fromJSONField: (field: any) =>
                CoinMetadata.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                CoinMetadata.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => CoinMetadata.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: CoinMetadataFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new CoinMetadata(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return CoinMetadata.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<CoinMetadata<ToPhantomTypeArgument<T>>>> {
        return phantom(CoinMetadata.reified(
            T
        ));
    }

    static get p() {
        return CoinMetadata.phantom
    }

    static get bcs() {
        return bcs.struct("CoinMetadata", {
            id:
                UID.bcs
            , decimals:
                bcs.u8()
            , name:
                String.bcs
            , symbol:
                String1.bcs
            , description:
                String.bcs
            , icon_url:
                Option.bcs(Url.bcs)

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): CoinMetadata<ToPhantomTypeArgument<T>> {
        return CoinMetadata.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), decimals: decodeFromFields("u8", fields.decimals), name: decodeFromFields(String.reified(), fields.name), symbol: decodeFromFields(String1.reified(), fields.symbol), description: decodeFromFields(String.reified(), fields.description), iconUrl: decodeFromFields(Option.reified(Url.reified()), fields.icon_url)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): CoinMetadata<ToPhantomTypeArgument<T>> {
        if (!isCoinMetadata(item.type)) {
            throw new Error("not a CoinMetadata type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return CoinMetadata.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), decimals: decodeFromFieldsWithTypes("u8", item.fields.decimals), name: decodeFromFieldsWithTypes(String.reified(), item.fields.name), symbol: decodeFromFieldsWithTypes(String1.reified(), item.fields.symbol), description: decodeFromFieldsWithTypes(String.reified(), item.fields.description), iconUrl: decodeFromFieldsWithTypes(Option.reified(Url.reified()), item.fields.icon_url)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): CoinMetadata<ToPhantomTypeArgument<T>> {

        return CoinMetadata.fromFields(
            typeArg,
            CoinMetadata.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,decimals: this.decimals,name: this.name,symbol: this.symbol,description: this.description,iconUrl: fieldToJSON<Option<Url>>(`0x1::option::Option<0x2::url::Url>`, this.iconUrl),

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
    ): CoinMetadata<ToPhantomTypeArgument<T>> {
        return CoinMetadata.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), decimals: decodeFromJSONField("u8", field.decimals), name: decodeFromJSONField(String.reified(), field.name), symbol: decodeFromJSONField(String1.reified(), field.symbol), description: decodeFromJSONField(String.reified(), field.description), iconUrl: decodeFromJSONField(Option.reified(Url.reified()), field.iconUrl)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): CoinMetadata<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== CoinMetadata.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(CoinMetadata.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return CoinMetadata.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): CoinMetadata<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isCoinMetadata(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a CoinMetadata object`);
        }
        return CoinMetadata.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<CoinMetadata<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching CoinMetadata object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isCoinMetadata(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a CoinMetadata object`);
        }

        return CoinMetadata.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== CurrencyCreated =============================== */

export function isCurrencyCreated(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::coin::CurrencyCreated<");
}

export interface CurrencyCreatedFields<T extends PhantomTypeArgument> {
    decimals: ToField<"u8">
}

export type CurrencyCreatedReified<T extends PhantomTypeArgument> = Reified<
    CurrencyCreated<T>,
    CurrencyCreatedFields<T>
>;

export class CurrencyCreated<T extends PhantomTypeArgument> {
    static readonly $typeName = "0x2::coin::CurrencyCreated";
    static readonly $numTypeParams = 1;

    readonly $typeName = CurrencyCreated.$typeName;

    readonly $fullTypeName: `0x2::coin::CurrencyCreated<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly decimals:
        ToField<"u8">

    private constructor(typeArg: string, fields: CurrencyCreatedFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(CurrencyCreated.$typeName,
        typeArg) as `0x2::coin::CurrencyCreated<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.decimals = fields.decimals;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): CurrencyCreatedReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: CurrencyCreated.$typeName,
            fullTypeName: composeSuiType(
                CurrencyCreated.$typeName,
                ...[extractType(T)]
            ) as `0x2::coin::CurrencyCreated<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                CurrencyCreated.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                CurrencyCreated.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                CurrencyCreated.fromBcs(
                    T,
                    data,
                ),
            bcs: CurrencyCreated.bcs,
            fromJSONField: (field: any) =>
                CurrencyCreated.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                CurrencyCreated.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => CurrencyCreated.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: CurrencyCreatedFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new CurrencyCreated(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return CurrencyCreated.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<CurrencyCreated<ToPhantomTypeArgument<T>>>> {
        return phantom(CurrencyCreated.reified(
            T
        ));
    }

    static get p() {
        return CurrencyCreated.phantom
    }

    static get bcs() {
        return bcs.struct("CurrencyCreated", {
            decimals:
                bcs.u8()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): CurrencyCreated<ToPhantomTypeArgument<T>> {
        return CurrencyCreated.reified(
            typeArg,
        ).new(
            {decimals: decodeFromFields("u8", fields.decimals)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): CurrencyCreated<ToPhantomTypeArgument<T>> {
        if (!isCurrencyCreated(item.type)) {
            throw new Error("not a CurrencyCreated type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return CurrencyCreated.reified(
            typeArg,
        ).new(
            {decimals: decodeFromFieldsWithTypes("u8", item.fields.decimals)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): CurrencyCreated<ToPhantomTypeArgument<T>> {

        return CurrencyCreated.fromFields(
            typeArg,
            CurrencyCreated.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            decimals: this.decimals,

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
    ): CurrencyCreated<ToPhantomTypeArgument<T>> {
        return CurrencyCreated.reified(
            typeArg,
        ).new(
            {decimals: decodeFromJSONField("u8", field.decimals)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): CurrencyCreated<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== CurrencyCreated.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(CurrencyCreated.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return CurrencyCreated.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): CurrencyCreated<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isCurrencyCreated(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a CurrencyCreated object`);
        }
        return CurrencyCreated.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<CurrencyCreated<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching CurrencyCreated object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isCurrencyCreated(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a CurrencyCreated object`);
        }

        return CurrencyCreated.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== TreasuryCap =============================== */

export function isTreasuryCap(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::coin::TreasuryCap<");
}

export interface TreasuryCapFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; totalSupply: ToField<Supply<T>>
}

export type TreasuryCapReified<T extends PhantomTypeArgument> = Reified<
    TreasuryCap<T>,
    TreasuryCapFields<T>
>;

export class TreasuryCap<T extends PhantomTypeArgument> {
    static readonly $typeName = "0x2::coin::TreasuryCap";
    static readonly $numTypeParams = 1;

    readonly $typeName = TreasuryCap.$typeName;

    readonly $fullTypeName: `0x2::coin::TreasuryCap<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly totalSupply:
        ToField<Supply<T>>

    private constructor(typeArg: string, fields: TreasuryCapFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(TreasuryCap.$typeName,
        typeArg) as `0x2::coin::TreasuryCap<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.totalSupply = fields.totalSupply;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): TreasuryCapReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: TreasuryCap.$typeName,
            fullTypeName: composeSuiType(
                TreasuryCap.$typeName,
                ...[extractType(T)]
            ) as `0x2::coin::TreasuryCap<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                TreasuryCap.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TreasuryCap.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TreasuryCap.fromBcs(
                    T,
                    data,
                ),
            bcs: TreasuryCap.bcs,
            fromJSONField: (field: any) =>
                TreasuryCap.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TreasuryCap.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => TreasuryCap.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: TreasuryCapFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new TreasuryCap(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TreasuryCap.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<TreasuryCap<ToPhantomTypeArgument<T>>>> {
        return phantom(TreasuryCap.reified(
            T
        ));
    }

    static get p() {
        return TreasuryCap.phantom
    }

    static get bcs() {
        return bcs.struct("TreasuryCap", {
            id:
                UID.bcs
            , total_supply:
                Supply.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): TreasuryCap<ToPhantomTypeArgument<T>> {
        return TreasuryCap.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), totalSupply: decodeFromFields(Supply.reified(typeArg), fields.total_supply)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): TreasuryCap<ToPhantomTypeArgument<T>> {
        if (!isTreasuryCap(item.type)) {
            throw new Error("not a TreasuryCap type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return TreasuryCap.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), totalSupply: decodeFromFieldsWithTypes(Supply.reified(typeArg), item.fields.total_supply)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): TreasuryCap<ToPhantomTypeArgument<T>> {

        return TreasuryCap.fromFields(
            typeArg,
            TreasuryCap.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,totalSupply: this.totalSupply.toJSONField(),

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
    ): TreasuryCap<ToPhantomTypeArgument<T>> {
        return TreasuryCap.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), totalSupply: decodeFromJSONField(Supply.reified(typeArg), field.totalSupply)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): TreasuryCap<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== TreasuryCap.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(TreasuryCap.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return TreasuryCap.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): TreasuryCap<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTreasuryCap(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TreasuryCap object`);
        }
        return TreasuryCap.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<TreasuryCap<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TreasuryCap object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTreasuryCap(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TreasuryCap object`);
        }

        return TreasuryCap.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
