import {Balance} from "../../_dependencies/source/0x2/balance/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== AskCommission =============================== */

export function isAskCommission(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::AskCommission";
}

export interface AskCommissionFields {
    cut: ToField<"u64">; beneficiary: ToField<"address">
}

export type AskCommissionReified = Reified<
    AskCommission,
    AskCommissionFields
>;

export class AskCommission {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::AskCommission";
    static readonly $numTypeParams = 0;

    readonly $typeName = AskCommission.$typeName;

    readonly $fullTypeName: "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::AskCommission";

    ;

    readonly cut:
        ToField<"u64">
    ; readonly beneficiary:
        ToField<"address">

    private constructor( fields: AskCommissionFields,
    ) {
        this.$fullTypeName = AskCommission.$typeName;

        this.cut = fields.cut;; this.beneficiary = fields.beneficiary;
    }

    static reified(): AskCommissionReified {
        return {
            typeName: AskCommission.$typeName,
            fullTypeName: composeSuiType(
                AskCommission.$typeName,
                ...[]
            ) as "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::AskCommission",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                AskCommission.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                AskCommission.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                AskCommission.fromBcs(
                    data,
                ),
            bcs: AskCommission.bcs,
            fromJSONField: (field: any) =>
                AskCommission.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                AskCommission.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => AskCommission.fetch(
                client,
                id,
            ),
            new: (
                fields: AskCommissionFields,
            ) => {
                return new AskCommission(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return AskCommission.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<AskCommission>> {
        return phantom(AskCommission.reified());
    }

    static get p() {
        return AskCommission.phantom()
    }

    static get bcs() {
        return bcs.struct("AskCommission", {
            cut:
                bcs.u64()
            , beneficiary:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): AskCommission {
        return AskCommission.reified().new(
            {cut: decodeFromFields("u64", fields.cut), beneficiary: decodeFromFields("address", fields.beneficiary)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): AskCommission {
        if (!isAskCommission(item.type)) {
            throw new Error("not a AskCommission type");
        }

        return AskCommission.reified().new(
            {cut: decodeFromFieldsWithTypes("u64", item.fields.cut), beneficiary: decodeFromFieldsWithTypes("address", item.fields.beneficiary)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): AskCommission {

        return AskCommission.fromFields(
            AskCommission.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            cut: this.cut.toString(),beneficiary: this.beneficiary,

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
    ): AskCommission {
        return AskCommission.reified().new(
            {cut: decodeFromJSONField("u64", field.cut), beneficiary: decodeFromJSONField("address", field.beneficiary)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): AskCommission {
        if (json.$typeName !== AskCommission.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return AskCommission.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): AskCommission {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAskCommission(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a AskCommission object`);
        }
        return AskCommission.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<AskCommission> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching AskCommission object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAskCommission(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a AskCommission object`);
        }

        return AskCommission.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== BidCommission =============================== */

export function isBidCommission(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::BidCommission<");
}

export interface BidCommissionFields<FT extends PhantomTypeArgument> {
    cut: ToField<Balance<FT>>; beneficiary: ToField<"address">
}

export type BidCommissionReified<FT extends PhantomTypeArgument> = Reified<
    BidCommission<FT>,
    BidCommissionFields<FT>
>;

export class BidCommission<FT extends PhantomTypeArgument> {
    static readonly $typeName = "0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::BidCommission";
    static readonly $numTypeParams = 1;

    readonly $typeName = BidCommission.$typeName;

    readonly $fullTypeName: `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::BidCommission<${PhantomToTypeStr<FT>}>`;

    readonly $typeArg: string;

    ;

    readonly cut:
        ToField<Balance<FT>>
    ; readonly beneficiary:
        ToField<"address">

    private constructor(typeArg: string, fields: BidCommissionFields<FT>,
    ) {
        this.$fullTypeName = composeSuiType(BidCommission.$typeName,
        typeArg) as `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::BidCommission<${PhantomToTypeStr<FT>}>`;

        this.$typeArg = typeArg;

        this.cut = fields.cut;; this.beneficiary = fields.beneficiary;
    }

    static reified<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): BidCommissionReified<ToPhantomTypeArgument<FT>> {
        return {
            typeName: BidCommission.$typeName,
            fullTypeName: composeSuiType(
                BidCommission.$typeName,
                ...[extractType(FT)]
            ) as `0x4e0629fa51a62b0c1d7c7b9fc89237ec5b6f630d7798ad3f06d820afb93a995a::trading::BidCommission<${PhantomToTypeStr<ToPhantomTypeArgument<FT>>}>`,
            typeArgs: [FT],
            fromFields: (fields: Record<string, any>) =>
                BidCommission.fromFields(
                    FT,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                BidCommission.fromFieldsWithTypes(
                    FT,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                BidCommission.fromBcs(
                    FT,
                    data,
                ),
            bcs: BidCommission.bcs,
            fromJSONField: (field: any) =>
                BidCommission.fromJSONField(
                    FT,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                BidCommission.fromJSON(
                    FT,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => BidCommission.fetch(
                client,
                FT,
                id,
            ),
            new: (
                fields: BidCommissionFields<ToPhantomTypeArgument<FT>>,
            ) => {
                return new BidCommission(
                    extractType(FT),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return BidCommission.reified
    }

    static phantom<FT extends PhantomReified<PhantomTypeArgument>>(
        FT: FT
    ): PhantomReified<ToTypeStr<BidCommission<ToPhantomTypeArgument<FT>>>> {
        return phantom(BidCommission.reified(
            FT
        ));
    }

    static get p() {
        return BidCommission.phantom
    }

    static get bcs() {
        return bcs.struct("BidCommission", {
            cut:
                Balance.bcs
            , beneficiary:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})

        })
    };

    static fromFields<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, fields: Record<string, any>
    ): BidCommission<ToPhantomTypeArgument<FT>> {
        return BidCommission.reified(
            typeArg,
        ).new(
            {cut: decodeFromFields(Balance.reified(typeArg), fields.cut), beneficiary: decodeFromFields("address", fields.beneficiary)}
        )
    }

    static fromFieldsWithTypes<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, item: FieldsWithTypes
    ): BidCommission<ToPhantomTypeArgument<FT>> {
        if (!isBidCommission(item.type)) {
            throw new Error("not a BidCommission type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return BidCommission.reified(
            typeArg,
        ).new(
            {cut: decodeFromFieldsWithTypes(Balance.reified(typeArg), item.fields.cut), beneficiary: decodeFromFieldsWithTypes("address", item.fields.beneficiary)}
        )
    }

    static fromBcs<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, data: Uint8Array
    ): BidCommission<ToPhantomTypeArgument<FT>> {

        return BidCommission.fromFields(
            typeArg,
            BidCommission.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            cut: this.cut.toJSONField(),beneficiary: this.beneficiary,

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, field: any
    ): BidCommission<ToPhantomTypeArgument<FT>> {
        return BidCommission.reified(
            typeArg,
        ).new(
            {cut: decodeFromJSONField(Balance.reified(typeArg), field.cut), beneficiary: decodeFromJSONField("address", field.beneficiary)}
        )
    }

    static fromJSON<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, json: Record<string, any>
    ): BidCommission<ToPhantomTypeArgument<FT>> {
        if (json.$typeName !== BidCommission.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(BidCommission.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return BidCommission.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<FT extends PhantomReified<PhantomTypeArgument>>(
        typeArg: FT, content: SuiParsedData
    ): BidCommission<ToPhantomTypeArgument<FT>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBidCommission(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a BidCommission object`);
        }
        return BidCommission.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<FT extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: FT, id: string
    ): Promise<BidCommission<ToPhantomTypeArgument<FT>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching BidCommission object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBidCommission(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a BidCommission object`);
        }

        return BidCommission.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
