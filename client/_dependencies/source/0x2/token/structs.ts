import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {Option} from "../../0x1/option/structs";
import {String} from "../../0x1/string/structs";
import {TypeName} from "../../0x1/type-name/structs";
import {Balance} from "../balance/structs";
import {ID, UID} from "../object/structs";
import {VecMap} from "../vec-map/structs";
import {VecSet} from "../vec-set/structs";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== RuleKey =============================== */

export function isRuleKey(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::token::RuleKey<");
}

export interface RuleKeyFields<T extends PhantomTypeArgument> {
    isProtected: ToField<"bool">
}

export type RuleKeyReified<T extends PhantomTypeArgument> = Reified<
    RuleKey<T>,
    RuleKeyFields<T>
>;

export class RuleKey<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x2::token::RuleKey";
    static readonly $numTypeParams = 1;

    readonly $typeName = RuleKey.$typeName;

    readonly $fullTypeName: `0x2::token::RuleKey<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly isProtected:
        ToField<"bool">

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: RuleKeyFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            RuleKey.$typeName,
            ...typeArgs
        ) as `0x2::token::RuleKey<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.isProtected = fields.isProtected;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): RuleKeyReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: RuleKey.$typeName,
            fullTypeName: composeSuiType(
                RuleKey.$typeName,
                ...[extractType(T)]
            ) as `0x2::token::RuleKey<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                RuleKey.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                RuleKey.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                RuleKey.fromBcs(
                    T,
                    data,
                ),
            bcs: RuleKey.bcs,
            fromJSONField: (field: any) =>
                RuleKey.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                RuleKey.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                RuleKey.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => RuleKey.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: RuleKeyFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new RuleKey(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return RuleKey.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<RuleKey<ToPhantomTypeArgument<T>>>> {
        return phantom(RuleKey.reified(
            T
        ));
    }

    static get p() {
        return RuleKey.phantom
    }

    static get bcs() {
        return bcs.struct("RuleKey", {
            is_protected:
                bcs.bool()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): RuleKey<ToPhantomTypeArgument<T>> {
        return RuleKey.reified(
            typeArg,
        ).new(
            {isProtected: decodeFromFields("bool", fields.is_protected)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): RuleKey<ToPhantomTypeArgument<T>> {
        if (!isRuleKey(item.type)) {
            throw new Error("not a RuleKey type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return RuleKey.reified(
            typeArg,
        ).new(
            {isProtected: decodeFromFieldsWithTypes("bool", item.fields.is_protected)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): RuleKey<ToPhantomTypeArgument<T>> {

        return RuleKey.fromFields(
            typeArg,
            RuleKey.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            isProtected: this.isProtected,

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
    ): RuleKey<ToPhantomTypeArgument<T>> {
        return RuleKey.reified(
            typeArg,
        ).new(
            {isProtected: decodeFromJSONField("bool", field.isProtected)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): RuleKey<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== RuleKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(RuleKey.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return RuleKey.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): RuleKey<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isRuleKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a RuleKey object`);
        }
        return RuleKey.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<RuleKey<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching RuleKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isRuleKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a RuleKey object`);
        }

        return RuleKey.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== ActionRequest =============================== */

export function isActionRequest(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::token::ActionRequest<");
}

export interface ActionRequestFields<T extends PhantomTypeArgument> {
    name: ToField<String>; amount: ToField<"u64">; sender: ToField<"address">; recipient: ToField<Option<"address">>; spentBalance: ToField<Option<Balance<T>>>; approvals: ToField<VecSet<TypeName>>
}

export type ActionRequestReified<T extends PhantomTypeArgument> = Reified<
    ActionRequest<T>,
    ActionRequestFields<T>
>;

export class ActionRequest<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x2::token::ActionRequest";
    static readonly $numTypeParams = 1;

    readonly $typeName = ActionRequest.$typeName;

    readonly $fullTypeName: `0x2::token::ActionRequest<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly name:
        ToField<String>
    ; readonly amount:
        ToField<"u64">
    ; readonly sender:
        ToField<"address">
    ; readonly recipient:
        ToField<Option<"address">>
    ; readonly spentBalance:
        ToField<Option<Balance<T>>>
    ; readonly approvals:
        ToField<VecSet<TypeName>>

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: ActionRequestFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            ActionRequest.$typeName,
            ...typeArgs
        ) as `0x2::token::ActionRequest<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.name = fields.name;; this.amount = fields.amount;; this.sender = fields.sender;; this.recipient = fields.recipient;; this.spentBalance = fields.spentBalance;; this.approvals = fields.approvals;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): ActionRequestReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: ActionRequest.$typeName,
            fullTypeName: composeSuiType(
                ActionRequest.$typeName,
                ...[extractType(T)]
            ) as `0x2::token::ActionRequest<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                ActionRequest.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ActionRequest.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ActionRequest.fromBcs(
                    T,
                    data,
                ),
            bcs: ActionRequest.bcs,
            fromJSONField: (field: any) =>
                ActionRequest.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ActionRequest.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                ActionRequest.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => ActionRequest.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: ActionRequestFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new ActionRequest(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ActionRequest.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<ActionRequest<ToPhantomTypeArgument<T>>>> {
        return phantom(ActionRequest.reified(
            T
        ));
    }

    static get p() {
        return ActionRequest.phantom
    }

    static get bcs() {
        return bcs.struct("ActionRequest", {
            name:
                String.bcs
            , amount:
                bcs.u64()
            , sender:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , recipient:
                Option.bcs(bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),}))
            , spent_balance:
                Option.bcs(Balance.bcs)
            , approvals:
                VecSet.bcs(TypeName.bcs)

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): ActionRequest<ToPhantomTypeArgument<T>> {
        return ActionRequest.reified(
            typeArg,
        ).new(
            {name: decodeFromFields(String.reified(), fields.name), amount: decodeFromFields("u64", fields.amount), sender: decodeFromFields("address", fields.sender), recipient: decodeFromFields(Option.reified("address"), fields.recipient), spentBalance: decodeFromFields(Option.reified(Balance.reified(typeArg)), fields.spent_balance), approvals: decodeFromFields(VecSet.reified(TypeName.reified()), fields.approvals)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): ActionRequest<ToPhantomTypeArgument<T>> {
        if (!isActionRequest(item.type)) {
            throw new Error("not a ActionRequest type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return ActionRequest.reified(
            typeArg,
        ).new(
            {name: decodeFromFieldsWithTypes(String.reified(), item.fields.name), amount: decodeFromFieldsWithTypes("u64", item.fields.amount), sender: decodeFromFieldsWithTypes("address", item.fields.sender), recipient: decodeFromFieldsWithTypes(Option.reified("address"), item.fields.recipient), spentBalance: decodeFromFieldsWithTypes(Option.reified(Balance.reified(typeArg)), item.fields.spent_balance), approvals: decodeFromFieldsWithTypes(VecSet.reified(TypeName.reified()), item.fields.approvals)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): ActionRequest<ToPhantomTypeArgument<T>> {

        return ActionRequest.fromFields(
            typeArg,
            ActionRequest.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            name: this.name,amount: this.amount.toString(),sender: this.sender,recipient: fieldToJSON<Option<"address">>(`0x1::option::Option<address>`, this.recipient),spentBalance: fieldToJSON<Option<Balance<T>>>(`0x1::option::Option<0x2::balance::Balance<${this.$typeArgs[0]}>>`, this.spentBalance),approvals: this.approvals.toJSONField(),

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
    ): ActionRequest<ToPhantomTypeArgument<T>> {
        return ActionRequest.reified(
            typeArg,
        ).new(
            {name: decodeFromJSONField(String.reified(), field.name), amount: decodeFromJSONField("u64", field.amount), sender: decodeFromJSONField("address", field.sender), recipient: decodeFromJSONField(Option.reified("address"), field.recipient), spentBalance: decodeFromJSONField(Option.reified(Balance.reified(typeArg)), field.spentBalance), approvals: decodeFromJSONField(VecSet.reified(TypeName.reified()), field.approvals)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): ActionRequest<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== ActionRequest.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(ActionRequest.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return ActionRequest.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): ActionRequest<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isActionRequest(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ActionRequest object`);
        }
        return ActionRequest.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<ActionRequest<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ActionRequest object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isActionRequest(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ActionRequest object`);
        }

        return ActionRequest.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Token =============================== */

export function isToken(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::token::Token<");
}

export interface TokenFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; balance: ToField<Balance<T>>
}

export type TokenReified<T extends PhantomTypeArgument> = Reified<
    Token<T>,
    TokenFields<T>
>;

export class Token<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x2::token::Token";
    static readonly $numTypeParams = 1;

    readonly $typeName = Token.$typeName;

    readonly $fullTypeName: `0x2::token::Token<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly id:
        ToField<UID>
    ; readonly balance:
        ToField<Balance<T>>

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: TokenFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            Token.$typeName,
            ...typeArgs
        ) as `0x2::token::Token<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.balance = fields.balance;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): TokenReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Token.$typeName,
            fullTypeName: composeSuiType(
                Token.$typeName,
                ...[extractType(T)]
            ) as `0x2::token::Token<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Token.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Token.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Token.fromBcs(
                    T,
                    data,
                ),
            bcs: Token.bcs,
            fromJSONField: (field: any) =>
                Token.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Token.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Token.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Token.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: TokenFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Token(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Token.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Token<ToPhantomTypeArgument<T>>>> {
        return phantom(Token.reified(
            T
        ));
    }

    static get p() {
        return Token.phantom
    }

    static get bcs() {
        return bcs.struct("Token", {
            id:
                UID.bcs
            , balance:
                Balance.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Token<ToPhantomTypeArgument<T>> {
        return Token.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), balance: decodeFromFields(Balance.reified(typeArg), fields.balance)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Token<ToPhantomTypeArgument<T>> {
        if (!isToken(item.type)) {
            throw new Error("not a Token type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Token.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), balance: decodeFromFieldsWithTypes(Balance.reified(typeArg), item.fields.balance)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Token<ToPhantomTypeArgument<T>> {

        return Token.fromFields(
            typeArg,
            Token.bcs.parse(data)
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
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): Token<ToPhantomTypeArgument<T>> {
        return Token.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), balance: decodeFromJSONField(Balance.reified(typeArg), field.balance)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Token<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Token.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Token.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return Token.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Token<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isToken(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Token object`);
        }
        return Token.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Token<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Token object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isToken(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Token object`);
        }

        return Token.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== TokenPolicy =============================== */

export function isTokenPolicy(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::token::TokenPolicy<");
}

export interface TokenPolicyFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; spentBalance: ToField<Balance<T>>; rules: ToField<VecMap<String, VecSet<TypeName>>>
}

export type TokenPolicyReified<T extends PhantomTypeArgument> = Reified<
    TokenPolicy<T>,
    TokenPolicyFields<T>
>;

export class TokenPolicy<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x2::token::TokenPolicy";
    static readonly $numTypeParams = 1;

    readonly $typeName = TokenPolicy.$typeName;

    readonly $fullTypeName: `0x2::token::TokenPolicy<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly id:
        ToField<UID>
    ; readonly spentBalance:
        ToField<Balance<T>>
    ; readonly rules:
        ToField<VecMap<String, VecSet<TypeName>>>

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: TokenPolicyFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            TokenPolicy.$typeName,
            ...typeArgs
        ) as `0x2::token::TokenPolicy<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.spentBalance = fields.spentBalance;; this.rules = fields.rules;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): TokenPolicyReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: TokenPolicy.$typeName,
            fullTypeName: composeSuiType(
                TokenPolicy.$typeName,
                ...[extractType(T)]
            ) as `0x2::token::TokenPolicy<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                TokenPolicy.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TokenPolicy.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TokenPolicy.fromBcs(
                    T,
                    data,
                ),
            bcs: TokenPolicy.bcs,
            fromJSONField: (field: any) =>
                TokenPolicy.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TokenPolicy.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                TokenPolicy.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => TokenPolicy.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: TokenPolicyFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new TokenPolicy(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TokenPolicy.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<TokenPolicy<ToPhantomTypeArgument<T>>>> {
        return phantom(TokenPolicy.reified(
            T
        ));
    }

    static get p() {
        return TokenPolicy.phantom
    }

    static get bcs() {
        return bcs.struct("TokenPolicy", {
            id:
                UID.bcs
            , spent_balance:
                Balance.bcs
            , rules:
                VecMap.bcs(String.bcs, VecSet.bcs(TypeName.bcs))

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): TokenPolicy<ToPhantomTypeArgument<T>> {
        return TokenPolicy.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), spentBalance: decodeFromFields(Balance.reified(typeArg), fields.spent_balance), rules: decodeFromFields(VecMap.reified(String.reified(), VecSet.reified(TypeName.reified())), fields.rules)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): TokenPolicy<ToPhantomTypeArgument<T>> {
        if (!isTokenPolicy(item.type)) {
            throw new Error("not a TokenPolicy type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return TokenPolicy.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), spentBalance: decodeFromFieldsWithTypes(Balance.reified(typeArg), item.fields.spent_balance), rules: decodeFromFieldsWithTypes(VecMap.reified(String.reified(), VecSet.reified(TypeName.reified())), item.fields.rules)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): TokenPolicy<ToPhantomTypeArgument<T>> {

        return TokenPolicy.fromFields(
            typeArg,
            TokenPolicy.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,spentBalance: this.spentBalance.toJSONField(),rules: this.rules.toJSONField(),

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
    ): TokenPolicy<ToPhantomTypeArgument<T>> {
        return TokenPolicy.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), spentBalance: decodeFromJSONField(Balance.reified(typeArg), field.spentBalance), rules: decodeFromJSONField(VecMap.reified(String.reified(), VecSet.reified(TypeName.reified())), field.rules)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): TokenPolicy<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== TokenPolicy.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(TokenPolicy.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return TokenPolicy.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): TokenPolicy<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTokenPolicy(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TokenPolicy object`);
        }
        return TokenPolicy.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<TokenPolicy<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TokenPolicy object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTokenPolicy(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TokenPolicy object`);
        }

        return TokenPolicy.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== TokenPolicyCap =============================== */

export function isTokenPolicyCap(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::token::TokenPolicyCap<");
}

export interface TokenPolicyCapFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; for: ToField<ID>
}

export type TokenPolicyCapReified<T extends PhantomTypeArgument> = Reified<
    TokenPolicyCap<T>,
    TokenPolicyCapFields<T>
>;

export class TokenPolicyCap<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x2::token::TokenPolicyCap";
    static readonly $numTypeParams = 1;

    readonly $typeName = TokenPolicyCap.$typeName;

    readonly $fullTypeName: `0x2::token::TokenPolicyCap<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly id:
        ToField<UID>
    ; readonly for:
        ToField<ID>

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: TokenPolicyCapFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            TokenPolicyCap.$typeName,
            ...typeArgs
        ) as `0x2::token::TokenPolicyCap<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.for = fields.for;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): TokenPolicyCapReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: TokenPolicyCap.$typeName,
            fullTypeName: composeSuiType(
                TokenPolicyCap.$typeName,
                ...[extractType(T)]
            ) as `0x2::token::TokenPolicyCap<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                TokenPolicyCap.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TokenPolicyCap.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TokenPolicyCap.fromBcs(
                    T,
                    data,
                ),
            bcs: TokenPolicyCap.bcs,
            fromJSONField: (field: any) =>
                TokenPolicyCap.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TokenPolicyCap.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                TokenPolicyCap.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => TokenPolicyCap.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: TokenPolicyCapFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new TokenPolicyCap(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TokenPolicyCap.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<TokenPolicyCap<ToPhantomTypeArgument<T>>>> {
        return phantom(TokenPolicyCap.reified(
            T
        ));
    }

    static get p() {
        return TokenPolicyCap.phantom
    }

    static get bcs() {
        return bcs.struct("TokenPolicyCap", {
            id:
                UID.bcs
            , for:
                ID.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): TokenPolicyCap<ToPhantomTypeArgument<T>> {
        return TokenPolicyCap.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), for: decodeFromFields(ID.reified(), fields.for)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): TokenPolicyCap<ToPhantomTypeArgument<T>> {
        if (!isTokenPolicyCap(item.type)) {
            throw new Error("not a TokenPolicyCap type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return TokenPolicyCap.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), for: decodeFromFieldsWithTypes(ID.reified(), item.fields.for)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): TokenPolicyCap<ToPhantomTypeArgument<T>> {

        return TokenPolicyCap.fromFields(
            typeArg,
            TokenPolicyCap.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,for: this.for,

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
    ): TokenPolicyCap<ToPhantomTypeArgument<T>> {
        return TokenPolicyCap.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), for: decodeFromJSONField(ID.reified(), field.for)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): TokenPolicyCap<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== TokenPolicyCap.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(TokenPolicyCap.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return TokenPolicyCap.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): TokenPolicyCap<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTokenPolicyCap(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TokenPolicyCap object`);
        }
        return TokenPolicyCap.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<TokenPolicyCap<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TokenPolicyCap object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTokenPolicyCap(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TokenPolicyCap object`);
        }

        return TokenPolicyCap.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== TokenPolicyCreated =============================== */

export function isTokenPolicyCreated(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::token::TokenPolicyCreated<");
}

export interface TokenPolicyCreatedFields<T extends PhantomTypeArgument> {
    id: ToField<ID>; isMutable: ToField<"bool">
}

export type TokenPolicyCreatedReified<T extends PhantomTypeArgument> = Reified<
    TokenPolicyCreated<T>,
    TokenPolicyCreatedFields<T>
>;

export class TokenPolicyCreated<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x2::token::TokenPolicyCreated";
    static readonly $numTypeParams = 1;

    readonly $typeName = TokenPolicyCreated.$typeName;

    readonly $fullTypeName: `0x2::token::TokenPolicyCreated<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly id:
        ToField<ID>
    ; readonly isMutable:
        ToField<"bool">

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: TokenPolicyCreatedFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            TokenPolicyCreated.$typeName,
            ...typeArgs
        ) as `0x2::token::TokenPolicyCreated<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.isMutable = fields.isMutable;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): TokenPolicyCreatedReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: TokenPolicyCreated.$typeName,
            fullTypeName: composeSuiType(
                TokenPolicyCreated.$typeName,
                ...[extractType(T)]
            ) as `0x2::token::TokenPolicyCreated<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                TokenPolicyCreated.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TokenPolicyCreated.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TokenPolicyCreated.fromBcs(
                    T,
                    data,
                ),
            bcs: TokenPolicyCreated.bcs,
            fromJSONField: (field: any) =>
                TokenPolicyCreated.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TokenPolicyCreated.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                TokenPolicyCreated.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => TokenPolicyCreated.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: TokenPolicyCreatedFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new TokenPolicyCreated(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TokenPolicyCreated.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<TokenPolicyCreated<ToPhantomTypeArgument<T>>>> {
        return phantom(TokenPolicyCreated.reified(
            T
        ));
    }

    static get p() {
        return TokenPolicyCreated.phantom
    }

    static get bcs() {
        return bcs.struct("TokenPolicyCreated", {
            id:
                ID.bcs
            , is_mutable:
                bcs.bool()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): TokenPolicyCreated<ToPhantomTypeArgument<T>> {
        return TokenPolicyCreated.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(ID.reified(), fields.id), isMutable: decodeFromFields("bool", fields.is_mutable)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): TokenPolicyCreated<ToPhantomTypeArgument<T>> {
        if (!isTokenPolicyCreated(item.type)) {
            throw new Error("not a TokenPolicyCreated type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return TokenPolicyCreated.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id), isMutable: decodeFromFieldsWithTypes("bool", item.fields.is_mutable)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): TokenPolicyCreated<ToPhantomTypeArgument<T>> {

        return TokenPolicyCreated.fromFields(
            typeArg,
            TokenPolicyCreated.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,isMutable: this.isMutable,

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
    ): TokenPolicyCreated<ToPhantomTypeArgument<T>> {
        return TokenPolicyCreated.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(ID.reified(), field.id), isMutable: decodeFromJSONField("bool", field.isMutable)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): TokenPolicyCreated<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== TokenPolicyCreated.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(TokenPolicyCreated.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return TokenPolicyCreated.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): TokenPolicyCreated<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTokenPolicyCreated(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TokenPolicyCreated object`);
        }
        return TokenPolicyCreated.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<TokenPolicyCreated<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TokenPolicyCreated object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTokenPolicyCreated(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TokenPolicyCreated object`);
        }

        return TokenPolicyCreated.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
