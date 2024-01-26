import * as reified from "../../_framework/reified";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom, ToTypeStr as ToPhantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {RequestBody, WithNft} from "../request/structs";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request::Witness";

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
            ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request::Witness",
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

/* ============================== WITHDRAW_REQ =============================== */

export function isWITHDRAW_REQ(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request::WITHDRAW_REQ";
}

export interface WITHDRAW_REQFields {
    dummyField: ToField<"bool">
}

export type WITHDRAW_REQReified = Reified<
    WITHDRAW_REQ,
    WITHDRAW_REQFields
>;

export class WITHDRAW_REQ {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request::WITHDRAW_REQ";
    static readonly $numTypeParams = 0;

    readonly $typeName = WITHDRAW_REQ.$typeName;

    readonly $fullTypeName: "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request::WITHDRAW_REQ";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: WITHDRAW_REQFields,
    ) {
        this.$fullTypeName = WITHDRAW_REQ.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): WITHDRAW_REQReified {
        return {
            typeName: WITHDRAW_REQ.$typeName,
            fullTypeName: composeSuiType(
                WITHDRAW_REQ.$typeName,
                ...[]
            ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request::WITHDRAW_REQ",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                WITHDRAW_REQ.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                WITHDRAW_REQ.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                WITHDRAW_REQ.fromBcs(
                    data,
                ),
            bcs: WITHDRAW_REQ.bcs,
            fromJSONField: (field: any) =>
                WITHDRAW_REQ.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                WITHDRAW_REQ.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => WITHDRAW_REQ.fetch(
                client,
                id,
            ),
            new: (
                fields: WITHDRAW_REQFields,
            ) => {
                return new WITHDRAW_REQ(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return WITHDRAW_REQ.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<WITHDRAW_REQ>> {
        return phantom(WITHDRAW_REQ.reified());
    }

    static get p() {
        return WITHDRAW_REQ.phantom()
    }

    static get bcs() {
        return bcs.struct("WITHDRAW_REQ", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): WITHDRAW_REQ {
        return WITHDRAW_REQ.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): WITHDRAW_REQ {
        if (!isWITHDRAW_REQ(item.type)) {
            throw new Error("not a WITHDRAW_REQ type");
        }

        return WITHDRAW_REQ.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): WITHDRAW_REQ {

        return WITHDRAW_REQ.fromFields(
            WITHDRAW_REQ.bcs.parse(data)
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
    ): WITHDRAW_REQ {
        return WITHDRAW_REQ.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): WITHDRAW_REQ {
        if (json.$typeName !== WITHDRAW_REQ.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return WITHDRAW_REQ.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): WITHDRAW_REQ {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWITHDRAW_REQ(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a WITHDRAW_REQ object`);
        }
        return WITHDRAW_REQ.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<WITHDRAW_REQ> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching WITHDRAW_REQ object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWITHDRAW_REQ(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a WITHDRAW_REQ object`);
        }

        return WITHDRAW_REQ.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== WithdrawRequest =============================== */

export function isWithdrawRequest(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request::WithdrawRequest<");
}

export interface WithdrawRequestFields<T extends PhantomTypeArgument> {
    sender: ToField<"address">; inner: ToField<RequestBody<ToPhantom<WithNft<T, ToPhantom<WITHDRAW_REQ>>>>>
}

export type WithdrawRequestReified<T extends PhantomTypeArgument> = Reified<
    WithdrawRequest<T>,
    WithdrawRequestFields<T>
>;

export class WithdrawRequest<T extends PhantomTypeArgument> {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request::WithdrawRequest";
    static readonly $numTypeParams = 1;

    readonly $typeName = WithdrawRequest.$typeName;

    readonly $fullTypeName: `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request::WithdrawRequest<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly sender:
        ToField<"address">
    ; readonly inner:
        ToField<RequestBody<ToPhantom<WithNft<T, ToPhantom<WITHDRAW_REQ>>>>>

    private constructor(typeArg: string, fields: WithdrawRequestFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(WithdrawRequest.$typeName,
        typeArg) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request::WithdrawRequest<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.sender = fields.sender;; this.inner = fields.inner;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): WithdrawRequestReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: WithdrawRequest.$typeName,
            fullTypeName: composeSuiType(
                WithdrawRequest.$typeName,
                ...[extractType(T)]
            ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request::WithdrawRequest<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                WithdrawRequest.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                WithdrawRequest.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                WithdrawRequest.fromBcs(
                    T,
                    data,
                ),
            bcs: WithdrawRequest.bcs,
            fromJSONField: (field: any) =>
                WithdrawRequest.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                WithdrawRequest.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => WithdrawRequest.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: WithdrawRequestFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new WithdrawRequest(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return WithdrawRequest.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<WithdrawRequest<ToPhantomTypeArgument<T>>>> {
        return phantom(WithdrawRequest.reified(
            T
        ));
    }

    static get p() {
        return WithdrawRequest.phantom
    }

    static get bcs() {
        return bcs.struct("WithdrawRequest", {
            sender:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , inner:
                RequestBody.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): WithdrawRequest<ToPhantomTypeArgument<T>> {
        return WithdrawRequest.reified(
            typeArg,
        ).new(
            {sender: decodeFromFields("address", fields.sender), inner: decodeFromFields(RequestBody.reified(reified.phantom(WithNft.reified(typeArg, reified.phantom(WITHDRAW_REQ.reified())))), fields.inner)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): WithdrawRequest<ToPhantomTypeArgument<T>> {
        if (!isWithdrawRequest(item.type)) {
            throw new Error("not a WithdrawRequest type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return WithdrawRequest.reified(
            typeArg,
        ).new(
            {sender: decodeFromFieldsWithTypes("address", item.fields.sender), inner: decodeFromFieldsWithTypes(RequestBody.reified(reified.phantom(WithNft.reified(typeArg, reified.phantom(WITHDRAW_REQ.reified())))), item.fields.inner)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): WithdrawRequest<ToPhantomTypeArgument<T>> {

        return WithdrawRequest.fromFields(
            typeArg,
            WithdrawRequest.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            sender: this.sender,inner: this.inner.toJSONField(),

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
    ): WithdrawRequest<ToPhantomTypeArgument<T>> {
        return WithdrawRequest.reified(
            typeArg,
        ).new(
            {sender: decodeFromJSONField("address", field.sender), inner: decodeFromJSONField(RequestBody.reified(reified.phantom(WithNft.reified(typeArg, reified.phantom(WITHDRAW_REQ.reified())))), field.inner)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): WithdrawRequest<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== WithdrawRequest.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(WithdrawRequest.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return WithdrawRequest.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): WithdrawRequest<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWithdrawRequest(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a WithdrawRequest object`);
        }
        return WithdrawRequest.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<WithdrawRequest<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching WithdrawRequest object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWithdrawRequest(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a WithdrawRequest object`);
        }

        return WithdrawRequest.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
