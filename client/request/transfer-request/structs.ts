import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {TransferRequest as TransferRequest1} from "../../_dependencies/source/0x2/transfer-policy/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== TransferRequest =============================== */

export function isTransferRequest(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::TransferRequest<");
}

export interface TransferRequestFields<T extends PhantomTypeArgument> {
    nft: ToField<ID>; originator: ToField<"address">; beneficiary: ToField<"address">; inner: ToField<TransferRequest1<T>>; metadata: ToField<UID>
}

export type TransferRequestReified<T extends PhantomTypeArgument> = Reified<
    TransferRequest<T>,
    TransferRequestFields<T>
>;

export class TransferRequest<T extends PhantomTypeArgument> {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::TransferRequest";
    static readonly $numTypeParams = 1;

    readonly $typeName = TransferRequest.$typeName;

    readonly $fullTypeName: `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::TransferRequest<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly nft:
        ToField<ID>
    ; readonly originator:
        ToField<"address">
    ; readonly beneficiary:
        ToField<"address">
    ; readonly inner:
        ToField<TransferRequest1<T>>
    ; readonly metadata:
        ToField<UID>

    private constructor(typeArg: string, fields: TransferRequestFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(TransferRequest.$typeName,
        typeArg) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::TransferRequest<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.nft = fields.nft;; this.originator = fields.originator;; this.beneficiary = fields.beneficiary;; this.inner = fields.inner;; this.metadata = fields.metadata;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): TransferRequestReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: TransferRequest.$typeName,
            fullTypeName: composeSuiType(
                TransferRequest.$typeName,
                ...[extractType(T)]
            ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::TransferRequest<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                TransferRequest.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TransferRequest.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TransferRequest.fromBcs(
                    T,
                    data,
                ),
            bcs: TransferRequest.bcs,
            fromJSONField: (field: any) =>
                TransferRequest.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TransferRequest.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => TransferRequest.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: TransferRequestFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new TransferRequest(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TransferRequest.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<TransferRequest<ToPhantomTypeArgument<T>>>> {
        return phantom(TransferRequest.reified(
            T
        ));
    }

    static get p() {
        return TransferRequest.phantom
    }

    static get bcs() {
        return bcs.struct("TransferRequest", {
            nft:
                ID.bcs
            , originator:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , beneficiary:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , inner:
                TransferRequest1.bcs
            , metadata:
                UID.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): TransferRequest<ToPhantomTypeArgument<T>> {
        return TransferRequest.reified(
            typeArg,
        ).new(
            {nft: decodeFromFields(ID.reified(), fields.nft), originator: decodeFromFields("address", fields.originator), beneficiary: decodeFromFields("address", fields.beneficiary), inner: decodeFromFields(TransferRequest1.reified(typeArg), fields.inner), metadata: decodeFromFields(UID.reified(), fields.metadata)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): TransferRequest<ToPhantomTypeArgument<T>> {
        if (!isTransferRequest(item.type)) {
            throw new Error("not a TransferRequest type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return TransferRequest.reified(
            typeArg,
        ).new(
            {nft: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft), originator: decodeFromFieldsWithTypes("address", item.fields.originator), beneficiary: decodeFromFieldsWithTypes("address", item.fields.beneficiary), inner: decodeFromFieldsWithTypes(TransferRequest1.reified(typeArg), item.fields.inner), metadata: decodeFromFieldsWithTypes(UID.reified(), item.fields.metadata)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): TransferRequest<ToPhantomTypeArgument<T>> {

        return TransferRequest.fromFields(
            typeArg,
            TransferRequest.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            nft: this.nft,originator: this.originator,beneficiary: this.beneficiary,inner: this.inner.toJSONField(),metadata: this.metadata,

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
    ): TransferRequest<ToPhantomTypeArgument<T>> {
        return TransferRequest.reified(
            typeArg,
        ).new(
            {nft: decodeFromJSONField(ID.reified(), field.nft), originator: decodeFromJSONField("address", field.originator), beneficiary: decodeFromJSONField("address", field.beneficiary), inner: decodeFromJSONField(TransferRequest1.reified(typeArg), field.inner), metadata: decodeFromJSONField(UID.reified(), field.metadata)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): TransferRequest<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== TransferRequest.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(TransferRequest.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return TransferRequest.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): TransferRequest<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTransferRequest(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TransferRequest object`);
        }
        return TransferRequest.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<TransferRequest<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TransferRequest object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTransferRequest(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TransferRequest object`);
        }

        return TransferRequest.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::Witness";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: WitnessFields,
    ) {
        this.$fullTypeName = Witness.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): WitnessReified {
        return {
            typeName: Witness.$typeName,
            fullTypeName: composeSuiType(
                Witness.$typeName,
                ...[]
            ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::Witness",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Witness.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Witness.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Witness.fromBcs(
                    data,
                ),
            bcs: Witness.bcs,
            fromJSONField: (field: any) =>
                Witness.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Witness.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Witness.fetch(
                client,
                id,
            ),
            new: (
                fields: WitnessFields,
            ) => {
                return new Witness(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Witness.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Witness>> {
        return phantom(Witness.reified());
    }

    static get p() {
        return Witness.phantom()
    }

    static get bcs() {
        return bcs.struct("Witness", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Witness {
        return Witness.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Witness {
        if (!isWitness(item.type)) {
            throw new Error("not a Witness type");
        }

        return Witness.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Witness {

        return Witness.fromFields(
            Witness.bcs.parse(data)
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
            ...this.toJSONField()
        }
    }

    static fromJSONField(
         field: any
    ): Witness {
        return Witness.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Witness {
        if (json.$typeName !== Witness.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Witness.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Witness {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWitness(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Witness object`);
        }
        return Witness.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Witness> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Witness object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWitness(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Witness object`);
        }

        return Witness.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== BalanceAccessCap =============================== */

export function isBalanceAccessCap(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::BalanceAccessCap<");
}

export interface BalanceAccessCapFields<T extends PhantomTypeArgument> {
    dummyField: ToField<"bool">
}

export type BalanceAccessCapReified<T extends PhantomTypeArgument> = Reified<
    BalanceAccessCap<T>,
    BalanceAccessCapFields<T>
>;

export class BalanceAccessCap<T extends PhantomTypeArgument> {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::BalanceAccessCap";
    static readonly $numTypeParams = 1;

    readonly $typeName = BalanceAccessCap.$typeName;

    readonly $fullTypeName: `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::BalanceAccessCap<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArg: string, fields: BalanceAccessCapFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(BalanceAccessCap.$typeName,
        typeArg) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::BalanceAccessCap<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.dummyField = fields.dummyField;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): BalanceAccessCapReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: BalanceAccessCap.$typeName,
            fullTypeName: composeSuiType(
                BalanceAccessCap.$typeName,
                ...[extractType(T)]
            ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::BalanceAccessCap<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                BalanceAccessCap.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                BalanceAccessCap.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                BalanceAccessCap.fromBcs(
                    T,
                    data,
                ),
            bcs: BalanceAccessCap.bcs,
            fromJSONField: (field: any) =>
                BalanceAccessCap.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                BalanceAccessCap.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => BalanceAccessCap.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: BalanceAccessCapFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new BalanceAccessCap(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return BalanceAccessCap.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<BalanceAccessCap<ToPhantomTypeArgument<T>>>> {
        return phantom(BalanceAccessCap.reified(
            T
        ));
    }

    static get p() {
        return BalanceAccessCap.phantom
    }

    static get bcs() {
        return bcs.struct("BalanceAccessCap", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): BalanceAccessCap<ToPhantomTypeArgument<T>> {
        return BalanceAccessCap.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): BalanceAccessCap<ToPhantomTypeArgument<T>> {
        if (!isBalanceAccessCap(item.type)) {
            throw new Error("not a BalanceAccessCap type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return BalanceAccessCap.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): BalanceAccessCap<ToPhantomTypeArgument<T>> {

        return BalanceAccessCap.fromFields(
            typeArg,
            BalanceAccessCap.bcs.parse(data)
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
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): BalanceAccessCap<ToPhantomTypeArgument<T>> {
        return BalanceAccessCap.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): BalanceAccessCap<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== BalanceAccessCap.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(BalanceAccessCap.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return BalanceAccessCap.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): BalanceAccessCap<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBalanceAccessCap(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a BalanceAccessCap object`);
        }
        return BalanceAccessCap.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<BalanceAccessCap<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching BalanceAccessCap object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBalanceAccessCap(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a BalanceAccessCap object`);
        }

        return BalanceAccessCap.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== BalanceDfKey =============================== */

export function isBalanceDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::BalanceDfKey";
}

export interface BalanceDfKeyFields {
    dummyField: ToField<"bool">
}

export type BalanceDfKeyReified = Reified<
    BalanceDfKey,
    BalanceDfKeyFields
>;

export class BalanceDfKey {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::BalanceDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = BalanceDfKey.$typeName;

    readonly $fullTypeName: "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::BalanceDfKey";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: BalanceDfKeyFields,
    ) {
        this.$fullTypeName = BalanceDfKey.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): BalanceDfKeyReified {
        return {
            typeName: BalanceDfKey.$typeName,
            fullTypeName: composeSuiType(
                BalanceDfKey.$typeName,
                ...[]
            ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::BalanceDfKey",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                BalanceDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                BalanceDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                BalanceDfKey.fromBcs(
                    data,
                ),
            bcs: BalanceDfKey.bcs,
            fromJSONField: (field: any) =>
                BalanceDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                BalanceDfKey.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => BalanceDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: BalanceDfKeyFields,
            ) => {
                return new BalanceDfKey(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return BalanceDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<BalanceDfKey>> {
        return phantom(BalanceDfKey.reified());
    }

    static get p() {
        return BalanceDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("BalanceDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): BalanceDfKey {
        return BalanceDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): BalanceDfKey {
        if (!isBalanceDfKey(item.type)) {
            throw new Error("not a BalanceDfKey type");
        }

        return BalanceDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): BalanceDfKey {

        return BalanceDfKey.fromFields(
            BalanceDfKey.bcs.parse(data)
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
            ...this.toJSONField()
        }
    }

    static fromJSONField(
         field: any
    ): BalanceDfKey {
        return BalanceDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): BalanceDfKey {
        if (json.$typeName !== BalanceDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return BalanceDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): BalanceDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBalanceDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a BalanceDfKey object`);
        }
        return BalanceDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<BalanceDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching BalanceDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBalanceDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a BalanceDfKey object`);
        }

        return BalanceDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== OBCustomRulesDfKey =============================== */

export function isOBCustomRulesDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::OBCustomRulesDfKey";
}

export interface OBCustomRulesDfKeyFields {
    dummyField: ToField<"bool">
}

export type OBCustomRulesDfKeyReified = Reified<
    OBCustomRulesDfKey,
    OBCustomRulesDfKeyFields
>;

export class OBCustomRulesDfKey {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::OBCustomRulesDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = OBCustomRulesDfKey.$typeName;

    readonly $fullTypeName: "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::OBCustomRulesDfKey";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: OBCustomRulesDfKeyFields,
    ) {
        this.$fullTypeName = OBCustomRulesDfKey.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): OBCustomRulesDfKeyReified {
        return {
            typeName: OBCustomRulesDfKey.$typeName,
            fullTypeName: composeSuiType(
                OBCustomRulesDfKey.$typeName,
                ...[]
            ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request::OBCustomRulesDfKey",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                OBCustomRulesDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                OBCustomRulesDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                OBCustomRulesDfKey.fromBcs(
                    data,
                ),
            bcs: OBCustomRulesDfKey.bcs,
            fromJSONField: (field: any) =>
                OBCustomRulesDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                OBCustomRulesDfKey.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => OBCustomRulesDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: OBCustomRulesDfKeyFields,
            ) => {
                return new OBCustomRulesDfKey(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return OBCustomRulesDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<OBCustomRulesDfKey>> {
        return phantom(OBCustomRulesDfKey.reified());
    }

    static get p() {
        return OBCustomRulesDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("OBCustomRulesDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): OBCustomRulesDfKey {
        return OBCustomRulesDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): OBCustomRulesDfKey {
        if (!isOBCustomRulesDfKey(item.type)) {
            throw new Error("not a OBCustomRulesDfKey type");
        }

        return OBCustomRulesDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): OBCustomRulesDfKey {

        return OBCustomRulesDfKey.fromFields(
            OBCustomRulesDfKey.bcs.parse(data)
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
            ...this.toJSONField()
        }
    }

    static fromJSONField(
         field: any
    ): OBCustomRulesDfKey {
        return OBCustomRulesDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): OBCustomRulesDfKey {
        if (json.$typeName !== OBCustomRulesDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return OBCustomRulesDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): OBCustomRulesDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isOBCustomRulesDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a OBCustomRulesDfKey object`);
        }
        return OBCustomRulesDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<OBCustomRulesDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching OBCustomRulesDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isOBCustomRulesDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a OBCustomRulesDfKey object`);
        }

        return OBCustomRulesDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
