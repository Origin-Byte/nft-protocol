import {Option} from "../../_dependencies/source/0x1/option/structs";
import {TypeName} from "../../_dependencies/source/0x1/type-name/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== SessionToken =============================== */

export function isSessionToken(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::SessionToken<");
}

export interface SessionTokenFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; nftId: ToField<ID>; field: ToField<Option<TypeName>>; expiryMs: ToField<"u64">; timeoutId: ToField<ID>; entity: ToField<"address">
}

export type SessionTokenReified<T extends PhantomTypeArgument> = Reified<
    SessionToken<T>,
    SessionTokenFields<T>
>;

export class SessionToken<T extends PhantomTypeArgument> {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::SessionToken";
    static readonly $numTypeParams = 1;

    readonly $typeName = SessionToken.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::SessionToken<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly nftId:
        ToField<ID>
    ; readonly field:
        ToField<Option<TypeName>>
    ; readonly expiryMs:
        ToField<"u64">
    ; readonly timeoutId:
        ToField<ID>
    ; readonly entity:
        ToField<"address">

    private constructor(typeArg: string, fields: SessionTokenFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(SessionToken.$typeName,
        typeArg) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::SessionToken<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.nftId = fields.nftId;; this.field = fields.field;; this.expiryMs = fields.expiryMs;; this.timeoutId = fields.timeoutId;; this.entity = fields.entity;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): SessionTokenReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: SessionToken.$typeName,
            fullTypeName: composeSuiType(
                SessionToken.$typeName,
                ...[extractType(T)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::SessionToken<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                SessionToken.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                SessionToken.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                SessionToken.fromBcs(
                    T,
                    data,
                ),
            bcs: SessionToken.bcs,
            fromJSONField: (field: any) =>
                SessionToken.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                SessionToken.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => SessionToken.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: SessionTokenFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new SessionToken(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return SessionToken.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<SessionToken<ToPhantomTypeArgument<T>>>> {
        return phantom(SessionToken.reified(
            T
        ));
    }

    static get p() {
        return SessionToken.phantom
    }

    static get bcs() {
        return bcs.struct("SessionToken", {
            id:
                UID.bcs
            , nft_id:
                ID.bcs
            , field:
                Option.bcs(TypeName.bcs)
            , expiry_ms:
                bcs.u64()
            , timeout_id:
                ID.bcs
            , entity:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): SessionToken<ToPhantomTypeArgument<T>> {
        return SessionToken.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), nftId: decodeFromFields(ID.reified(), fields.nft_id), field: decodeFromFields(Option.reified(TypeName.reified()), fields.field), expiryMs: decodeFromFields("u64", fields.expiry_ms), timeoutId: decodeFromFields(ID.reified(), fields.timeout_id), entity: decodeFromFields("address", fields.entity)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): SessionToken<ToPhantomTypeArgument<T>> {
        if (!isSessionToken(item.type)) {
            throw new Error("not a SessionToken type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return SessionToken.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), nftId: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft_id), field: decodeFromFieldsWithTypes(Option.reified(TypeName.reified()), item.fields.field), expiryMs: decodeFromFieldsWithTypes("u64", item.fields.expiry_ms), timeoutId: decodeFromFieldsWithTypes(ID.reified(), item.fields.timeout_id), entity: decodeFromFieldsWithTypes("address", item.fields.entity)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): SessionToken<ToPhantomTypeArgument<T>> {

        return SessionToken.fromFields(
            typeArg,
            SessionToken.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,nftId: this.nftId,field: fieldToJSON<Option<TypeName>>(`0x1::option::Option<0x1::type_name::TypeName>`, this.field),expiryMs: this.expiryMs.toString(),timeoutId: this.timeoutId,entity: this.entity,

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
    ): SessionToken<ToPhantomTypeArgument<T>> {
        return SessionToken.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), nftId: decodeFromJSONField(ID.reified(), field.nftId), field: decodeFromJSONField(Option.reified(TypeName.reified()), field.field), expiryMs: decodeFromJSONField("u64", field.expiryMs), timeoutId: decodeFromJSONField(ID.reified(), field.timeoutId), entity: decodeFromJSONField("address", field.entity)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): SessionToken<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== SessionToken.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(SessionToken.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return SessionToken.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): SessionToken<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isSessionToken(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a SessionToken object`);
        }
        return SessionToken.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<SessionToken<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching SessionToken object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isSessionToken(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a SessionToken object`);
        }

        return SessionToken.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== SessionTokenRule =============================== */

export function isSessionTokenRule(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::SessionTokenRule";
}

export interface SessionTokenRuleFields {
    dummyField: ToField<"bool">
}

export type SessionTokenRuleReified = Reified<
    SessionTokenRule,
    SessionTokenRuleFields
>;

export class SessionTokenRule {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::SessionTokenRule";
    static readonly $numTypeParams = 0;

    readonly $typeName = SessionTokenRule.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::SessionTokenRule";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: SessionTokenRuleFields,
    ) {
        this.$fullTypeName = SessionTokenRule.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): SessionTokenRuleReified {
        return {
            typeName: SessionTokenRule.$typeName,
            fullTypeName: composeSuiType(
                SessionTokenRule.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::SessionTokenRule",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                SessionTokenRule.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                SessionTokenRule.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                SessionTokenRule.fromBcs(
                    data,
                ),
            bcs: SessionTokenRule.bcs,
            fromJSONField: (field: any) =>
                SessionTokenRule.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                SessionTokenRule.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => SessionTokenRule.fetch(
                client,
                id,
            ),
            new: (
                fields: SessionTokenRuleFields,
            ) => {
                return new SessionTokenRule(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return SessionTokenRule.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<SessionTokenRule>> {
        return phantom(SessionTokenRule.reified());
    }

    static get p() {
        return SessionTokenRule.phantom()
    }

    static get bcs() {
        return bcs.struct("SessionTokenRule", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): SessionTokenRule {
        return SessionTokenRule.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): SessionTokenRule {
        if (!isSessionTokenRule(item.type)) {
            throw new Error("not a SessionTokenRule type");
        }

        return SessionTokenRule.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): SessionTokenRule {

        return SessionTokenRule.fromFields(
            SessionTokenRule.bcs.parse(data)
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
    ): SessionTokenRule {
        return SessionTokenRule.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): SessionTokenRule {
        if (json.$typeName !== SessionTokenRule.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return SessionTokenRule.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): SessionTokenRule {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isSessionTokenRule(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a SessionTokenRule object`);
        }
        return SessionTokenRule.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<SessionTokenRule> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching SessionTokenRule object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isSessionTokenRule(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a SessionTokenRule object`);
        }

        return SessionTokenRule.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== TimeOut =============================== */

export function isTimeOut(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::TimeOut<");
}

export interface TimeOutFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; expiryMs: ToField<"u64">; accessToken: ToField<ID>
}

export type TimeOutReified<T extends PhantomTypeArgument> = Reified<
    TimeOut<T>,
    TimeOutFields<T>
>;

export class TimeOut<T extends PhantomTypeArgument> {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::TimeOut";
    static readonly $numTypeParams = 1;

    readonly $typeName = TimeOut.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::TimeOut<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly expiryMs:
        ToField<"u64">
    ; readonly accessToken:
        ToField<ID>

    private constructor(typeArg: string, fields: TimeOutFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(TimeOut.$typeName,
        typeArg) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::TimeOut<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.expiryMs = fields.expiryMs;; this.accessToken = fields.accessToken;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): TimeOutReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: TimeOut.$typeName,
            fullTypeName: composeSuiType(
                TimeOut.$typeName,
                ...[extractType(T)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::TimeOut<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                TimeOut.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TimeOut.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TimeOut.fromBcs(
                    T,
                    data,
                ),
            bcs: TimeOut.bcs,
            fromJSONField: (field: any) =>
                TimeOut.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TimeOut.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => TimeOut.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: TimeOutFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new TimeOut(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TimeOut.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<TimeOut<ToPhantomTypeArgument<T>>>> {
        return phantom(TimeOut.reified(
            T
        ));
    }

    static get p() {
        return TimeOut.phantom
    }

    static get bcs() {
        return bcs.struct("TimeOut", {
            id:
                UID.bcs
            , expiry_ms:
                bcs.u64()
            , access_token:
                ID.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): TimeOut<ToPhantomTypeArgument<T>> {
        return TimeOut.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), expiryMs: decodeFromFields("u64", fields.expiry_ms), accessToken: decodeFromFields(ID.reified(), fields.access_token)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): TimeOut<ToPhantomTypeArgument<T>> {
        if (!isTimeOut(item.type)) {
            throw new Error("not a TimeOut type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return TimeOut.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), expiryMs: decodeFromFieldsWithTypes("u64", item.fields.expiry_ms), accessToken: decodeFromFieldsWithTypes(ID.reified(), item.fields.access_token)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): TimeOut<ToPhantomTypeArgument<T>> {

        return TimeOut.fromFields(
            typeArg,
            TimeOut.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,expiryMs: this.expiryMs.toString(),accessToken: this.accessToken,

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
    ): TimeOut<ToPhantomTypeArgument<T>> {
        return TimeOut.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), expiryMs: decodeFromJSONField("u64", field.expiryMs), accessToken: decodeFromJSONField(ID.reified(), field.accessToken)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): TimeOut<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== TimeOut.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(TimeOut.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return TimeOut.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): TimeOut<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTimeOut(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TimeOut object`);
        }
        return TimeOut.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<TimeOut<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TimeOut object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTimeOut(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TimeOut object`);
        }

        return TimeOut.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== TimeOutDfKey =============================== */

export function isTimeOutDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::TimeOutDfKey";
}

export interface TimeOutDfKeyFields {
    nftId: ToField<ID>
}

export type TimeOutDfKeyReified = Reified<
    TimeOutDfKey,
    TimeOutDfKeyFields
>;

export class TimeOutDfKey {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::TimeOutDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = TimeOutDfKey.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::TimeOutDfKey";

    ;

    readonly nftId:
        ToField<ID>

    private constructor( fields: TimeOutDfKeyFields,
    ) {
        this.$fullTypeName = TimeOutDfKey.$typeName;

        this.nftId = fields.nftId;
    }

    static reified(): TimeOutDfKeyReified {
        return {
            typeName: TimeOutDfKey.$typeName,
            fullTypeName: composeSuiType(
                TimeOutDfKey.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::session_token::TimeOutDfKey",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                TimeOutDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TimeOutDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TimeOutDfKey.fromBcs(
                    data,
                ),
            bcs: TimeOutDfKey.bcs,
            fromJSONField: (field: any) =>
                TimeOutDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TimeOutDfKey.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => TimeOutDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: TimeOutDfKeyFields,
            ) => {
                return new TimeOutDfKey(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TimeOutDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<TimeOutDfKey>> {
        return phantom(TimeOutDfKey.reified());
    }

    static get p() {
        return TimeOutDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("TimeOutDfKey", {
            nft_id:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): TimeOutDfKey {
        return TimeOutDfKey.reified().new(
            {nftId: decodeFromFields(ID.reified(), fields.nft_id)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): TimeOutDfKey {
        if (!isTimeOutDfKey(item.type)) {
            throw new Error("not a TimeOutDfKey type");
        }

        return TimeOutDfKey.reified().new(
            {nftId: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft_id)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): TimeOutDfKey {

        return TimeOutDfKey.fromFields(
            TimeOutDfKey.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            nftId: this.nftId,

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
    ): TimeOutDfKey {
        return TimeOutDfKey.reified().new(
            {nftId: decodeFromJSONField(ID.reified(), field.nftId)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): TimeOutDfKey {
        if (json.$typeName !== TimeOutDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return TimeOutDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): TimeOutDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTimeOutDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TimeOutDfKey object`);
        }
        return TimeOutDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<TimeOutDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TimeOutDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTimeOutDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TimeOutDfKey object`);
        }

        return TimeOutDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
