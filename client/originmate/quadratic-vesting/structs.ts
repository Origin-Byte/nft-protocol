import {Coin} from "../../_dependencies/source/0x2/coin/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== ClawbackCapability =============================== */

export function isClawbackCapability(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::quadratic_vesting::ClawbackCapability";
}

export interface ClawbackCapabilityFields {
    id: ToField<UID>; walletId: ToField<ID>
}

export type ClawbackCapabilityReified = Reified<
    ClawbackCapability,
    ClawbackCapabilityFields
>;

export class ClawbackCapability {
    static readonly $typeName = "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::quadratic_vesting::ClawbackCapability";
    static readonly $numTypeParams = 0;

    readonly $typeName = ClawbackCapability.$typeName;

    readonly $fullTypeName: "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::quadratic_vesting::ClawbackCapability";

    ;

    readonly id:
        ToField<UID>
    ; readonly walletId:
        ToField<ID>

    private constructor( fields: ClawbackCapabilityFields,
    ) {
        this.$fullTypeName = ClawbackCapability.$typeName;

        this.id = fields.id;; this.walletId = fields.walletId;
    }

    static reified(): ClawbackCapabilityReified {
        return {
            typeName: ClawbackCapability.$typeName,
            fullTypeName: composeSuiType(
                ClawbackCapability.$typeName,
                ...[]
            ) as "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::quadratic_vesting::ClawbackCapability",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                ClawbackCapability.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ClawbackCapability.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ClawbackCapability.fromBcs(
                    data,
                ),
            bcs: ClawbackCapability.bcs,
            fromJSONField: (field: any) =>
                ClawbackCapability.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ClawbackCapability.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => ClawbackCapability.fetch(
                client,
                id,
            ),
            new: (
                fields: ClawbackCapabilityFields,
            ) => {
                return new ClawbackCapability(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ClawbackCapability.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<ClawbackCapability>> {
        return phantom(ClawbackCapability.reified());
    }

    static get p() {
        return ClawbackCapability.phantom()
    }

    static get bcs() {
        return bcs.struct("ClawbackCapability", {
            id:
                UID.bcs
            , wallet_id:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): ClawbackCapability {
        return ClawbackCapability.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), walletId: decodeFromFields(ID.reified(), fields.wallet_id)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): ClawbackCapability {
        if (!isClawbackCapability(item.type)) {
            throw new Error("not a ClawbackCapability type");
        }

        return ClawbackCapability.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), walletId: decodeFromFieldsWithTypes(ID.reified(), item.fields.wallet_id)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): ClawbackCapability {

        return ClawbackCapability.fromFields(
            ClawbackCapability.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,walletId: this.walletId,

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
    ): ClawbackCapability {
        return ClawbackCapability.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), walletId: decodeFromJSONField(ID.reified(), field.walletId)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): ClawbackCapability {
        if (json.$typeName !== ClawbackCapability.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return ClawbackCapability.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): ClawbackCapability {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isClawbackCapability(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ClawbackCapability object`);
        }
        return ClawbackCapability.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<ClawbackCapability> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ClawbackCapability object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isClawbackCapability(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ClawbackCapability object`);
        }

        return ClawbackCapability.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Wallet =============================== */

export function isWallet(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::quadratic_vesting::Wallet<");
}

export interface WalletFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; beneficiary: ToField<"address">; coin: ToField<Coin<T>>; released: ToField<"u64">; vestingCurveA: ToField<"u64">; vestingCurveB: ToField<"u64">; vestingCurveC: ToField<"u64">; start: ToField<"u64">; cliff: ToField<"u64">; duration: ToField<"u64">
}

export type WalletReified<T extends PhantomTypeArgument> = Reified<
    Wallet<T>,
    WalletFields<T>
>;

export class Wallet<T extends PhantomTypeArgument> {
    static readonly $typeName = "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::quadratic_vesting::Wallet";
    static readonly $numTypeParams = 1;

    readonly $typeName = Wallet.$typeName;

    readonly $fullTypeName: `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::quadratic_vesting::Wallet<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly beneficiary:
        ToField<"address">
    ; readonly coin:
        ToField<Coin<T>>
    ; readonly released:
        ToField<"u64">
    ; readonly vestingCurveA:
        ToField<"u64">
    ; readonly vestingCurveB:
        ToField<"u64">
    ; readonly vestingCurveC:
        ToField<"u64">
    ; readonly start:
        ToField<"u64">
    ; readonly cliff:
        ToField<"u64">
    ; readonly duration:
        ToField<"u64">

    private constructor(typeArg: string, fields: WalletFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(Wallet.$typeName,
        typeArg) as `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::quadratic_vesting::Wallet<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.beneficiary = fields.beneficiary;; this.coin = fields.coin;; this.released = fields.released;; this.vestingCurveA = fields.vestingCurveA;; this.vestingCurveB = fields.vestingCurveB;; this.vestingCurveC = fields.vestingCurveC;; this.start = fields.start;; this.cliff = fields.cliff;; this.duration = fields.duration;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): WalletReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Wallet.$typeName,
            fullTypeName: composeSuiType(
                Wallet.$typeName,
                ...[extractType(T)]
            ) as `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::quadratic_vesting::Wallet<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Wallet.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Wallet.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Wallet.fromBcs(
                    T,
                    data,
                ),
            bcs: Wallet.bcs,
            fromJSONField: (field: any) =>
                Wallet.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Wallet.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Wallet.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: WalletFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Wallet(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Wallet.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Wallet<ToPhantomTypeArgument<T>>>> {
        return phantom(Wallet.reified(
            T
        ));
    }

    static get p() {
        return Wallet.phantom
    }

    static get bcs() {
        return bcs.struct("Wallet", {
            id:
                UID.bcs
            , beneficiary:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , coin:
                Coin.bcs
            , released:
                bcs.u64()
            , vesting_curve_a:
                bcs.u64()
            , vesting_curve_b:
                bcs.u64()
            , vesting_curve_c:
                bcs.u64()
            , start:
                bcs.u64()
            , cliff:
                bcs.u64()
            , duration:
                bcs.u64()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Wallet<ToPhantomTypeArgument<T>> {
        return Wallet.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), beneficiary: decodeFromFields("address", fields.beneficiary), coin: decodeFromFields(Coin.reified(typeArg), fields.coin), released: decodeFromFields("u64", fields.released), vestingCurveA: decodeFromFields("u64", fields.vesting_curve_a), vestingCurveB: decodeFromFields("u64", fields.vesting_curve_b), vestingCurveC: decodeFromFields("u64", fields.vesting_curve_c), start: decodeFromFields("u64", fields.start), cliff: decodeFromFields("u64", fields.cliff), duration: decodeFromFields("u64", fields.duration)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Wallet<ToPhantomTypeArgument<T>> {
        if (!isWallet(item.type)) {
            throw new Error("not a Wallet type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Wallet.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), beneficiary: decodeFromFieldsWithTypes("address", item.fields.beneficiary), coin: decodeFromFieldsWithTypes(Coin.reified(typeArg), item.fields.coin), released: decodeFromFieldsWithTypes("u64", item.fields.released), vestingCurveA: decodeFromFieldsWithTypes("u64", item.fields.vesting_curve_a), vestingCurveB: decodeFromFieldsWithTypes("u64", item.fields.vesting_curve_b), vestingCurveC: decodeFromFieldsWithTypes("u64", item.fields.vesting_curve_c), start: decodeFromFieldsWithTypes("u64", item.fields.start), cliff: decodeFromFieldsWithTypes("u64", item.fields.cliff), duration: decodeFromFieldsWithTypes("u64", item.fields.duration)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Wallet<ToPhantomTypeArgument<T>> {

        return Wallet.fromFields(
            typeArg,
            Wallet.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,beneficiary: this.beneficiary,coin: this.coin.toJSONField(),released: this.released.toString(),vestingCurveA: this.vestingCurveA.toString(),vestingCurveB: this.vestingCurveB.toString(),vestingCurveC: this.vestingCurveC.toString(),start: this.start.toString(),cliff: this.cliff.toString(),duration: this.duration.toString(),

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
    ): Wallet<ToPhantomTypeArgument<T>> {
        return Wallet.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), beneficiary: decodeFromJSONField("address", field.beneficiary), coin: decodeFromJSONField(Coin.reified(typeArg), field.coin), released: decodeFromJSONField("u64", field.released), vestingCurveA: decodeFromJSONField("u64", field.vestingCurveA), vestingCurveB: decodeFromJSONField("u64", field.vestingCurveB), vestingCurveC: decodeFromJSONField("u64", field.vestingCurveC), start: decodeFromJSONField("u64", field.start), cliff: decodeFromJSONField("u64", field.cliff), duration: decodeFromJSONField("u64", field.duration)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Wallet<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Wallet.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Wallet.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Wallet.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Wallet<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWallet(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Wallet object`);
        }
        return Wallet.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Wallet<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Wallet object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWallet(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Wallet object`);
        }

        return Wallet.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
