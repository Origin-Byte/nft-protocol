import {TypeName} from "../../_dependencies/source/0x1/type-name/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {VecSet} from "../../_dependencies/source/0x2/vec-set/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Policy =============================== */

export function isPolicy(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::Policy<");
}

export interface PolicyFields<P extends PhantomTypeArgument> {
    id: ToField<UID>; version: ToField<"u64">; rules: ToField<VecSet<TypeName>>
}

export type PolicyReified<P extends PhantomTypeArgument> = Reified<
    Policy<P>,
    PolicyFields<P>
>;

export class Policy<P extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::Policy";
    static readonly $numTypeParams = 1;

    readonly $typeName = Policy.$typeName;

    readonly $fullTypeName: `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::Policy<${PhantomToTypeStr<P>}>`;

    readonly $typeArgs: [PhantomToTypeStr<P>];

    readonly id:
        ToField<UID>
    ; readonly version:
        ToField<"u64">
    ; readonly rules:
        ToField<VecSet<TypeName>>

    private constructor(typeArgs: [PhantomToTypeStr<P>], fields: PolicyFields<P>,
    ) {
        this.$fullTypeName = composeSuiType(
            Policy.$typeName,
            ...typeArgs
        ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::Policy<${PhantomToTypeStr<P>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.version = fields.version;; this.rules = fields.rules;
    }

    static reified<P extends PhantomReified<PhantomTypeArgument>>(
        P: P
    ): PolicyReified<ToPhantomTypeArgument<P>> {
        return {
            typeName: Policy.$typeName,
            fullTypeName: composeSuiType(
                Policy.$typeName,
                ...[extractType(P)]
            ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::Policy<${PhantomToTypeStr<ToPhantomTypeArgument<P>>}>`,
            typeArgs: [
                extractType(P)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<P>>],
            reifiedTypeArgs: [P],
            fromFields: (fields: Record<string, any>) =>
                Policy.fromFields(
                    P,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Policy.fromFieldsWithTypes(
                    P,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Policy.fromBcs(
                    P,
                    data,
                ),
            bcs: Policy.bcs,
            fromJSONField: (field: any) =>
                Policy.fromJSONField(
                    P,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Policy.fromJSON(
                    P,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Policy.fromSuiParsedData(
                    P,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Policy.fetch(
                client,
                P,
                id,
            ),
            new: (
                fields: PolicyFields<ToPhantomTypeArgument<P>>,
            ) => {
                return new Policy(
                    [extractType(P)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Policy.reified
    }

    static phantom<P extends PhantomReified<PhantomTypeArgument>>(
        P: P
    ): PhantomReified<ToTypeStr<Policy<ToPhantomTypeArgument<P>>>> {
        return phantom(Policy.reified(
            P
        ));
    }

    static get p() {
        return Policy.phantom
    }

    static get bcs() {
        return bcs.struct("Policy", {
            id:
                UID.bcs
            , version:
                bcs.u64()
            , rules:
                VecSet.bcs(TypeName.bcs)

        })
    };

    static fromFields<P extends PhantomReified<PhantomTypeArgument>>(
        typeArg: P, fields: Record<string, any>
    ): Policy<ToPhantomTypeArgument<P>> {
        return Policy.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), version: decodeFromFields("u64", fields.version), rules: decodeFromFields(VecSet.reified(TypeName.reified()), fields.rules)}
        )
    }

    static fromFieldsWithTypes<P extends PhantomReified<PhantomTypeArgument>>(
        typeArg: P, item: FieldsWithTypes
    ): Policy<ToPhantomTypeArgument<P>> {
        if (!isPolicy(item.type)) {
            throw new Error("not a Policy type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Policy.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), version: decodeFromFieldsWithTypes("u64", item.fields.version), rules: decodeFromFieldsWithTypes(VecSet.reified(TypeName.reified()), item.fields.rules)}
        )
    }

    static fromBcs<P extends PhantomReified<PhantomTypeArgument>>(
        typeArg: P, data: Uint8Array
    ): Policy<ToPhantomTypeArgument<P>> {

        return Policy.fromFields(
            typeArg,
            Policy.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,version: this.version.toString(),rules: this.rules.toJSONField(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<P extends PhantomReified<PhantomTypeArgument>>(
        typeArg: P, field: any
    ): Policy<ToPhantomTypeArgument<P>> {
        return Policy.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), version: decodeFromJSONField("u64", field.version), rules: decodeFromJSONField(VecSet.reified(TypeName.reified()), field.rules)}
        )
    }

    static fromJSON<P extends PhantomReified<PhantomTypeArgument>>(
        typeArg: P, json: Record<string, any>
    ): Policy<ToPhantomTypeArgument<P>> {
        if (json.$typeName !== Policy.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Policy.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return Policy.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<P extends PhantomReified<PhantomTypeArgument>>(
        typeArg: P, content: SuiParsedData
    ): Policy<ToPhantomTypeArgument<P>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isPolicy(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Policy object`);
        }
        return Policy.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<P extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: P, id: string
    ): Promise<Policy<ToPhantomTypeArgument<P>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Policy object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isPolicy(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Policy object`);
        }

        return Policy.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== PolicyCap =============================== */

export function isPolicyCap(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::PolicyCap";
}

export interface PolicyCapFields {
    id: ToField<UID>; for: ToField<ID>
}

export type PolicyCapReified = Reified<
    PolicyCap,
    PolicyCapFields
>;

export class PolicyCap implements StructClass {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::PolicyCap";
    static readonly $numTypeParams = 0;

    readonly $typeName = PolicyCap.$typeName;

    readonly $fullTypeName: "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::PolicyCap";

    readonly $typeArgs: [];

    readonly id:
        ToField<UID>
    ; readonly for:
        ToField<ID>

    private constructor(typeArgs: [], fields: PolicyCapFields,
    ) {
        this.$fullTypeName = composeSuiType(
            PolicyCap.$typeName,
            ...typeArgs
        ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::PolicyCap";
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.for = fields.for;
    }

    static reified(): PolicyCapReified {
        return {
            typeName: PolicyCap.$typeName,
            fullTypeName: composeSuiType(
                PolicyCap.$typeName,
                ...[]
            ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::PolicyCap",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                PolicyCap.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                PolicyCap.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                PolicyCap.fromBcs(
                    data,
                ),
            bcs: PolicyCap.bcs,
            fromJSONField: (field: any) =>
                PolicyCap.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                PolicyCap.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                PolicyCap.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => PolicyCap.fetch(
                client,
                id,
            ),
            new: (
                fields: PolicyCapFields,
            ) => {
                return new PolicyCap(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return PolicyCap.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<PolicyCap>> {
        return phantom(PolicyCap.reified());
    }

    static get p() {
        return PolicyCap.phantom()
    }

    static get bcs() {
        return bcs.struct("PolicyCap", {
            id:
                UID.bcs
            , for:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): PolicyCap {
        return PolicyCap.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), for: decodeFromFields(ID.reified(), fields.for)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): PolicyCap {
        if (!isPolicyCap(item.type)) {
            throw new Error("not a PolicyCap type");
        }

        return PolicyCap.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), for: decodeFromFieldsWithTypes(ID.reified(), item.fields.for)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): PolicyCap {

        return PolicyCap.fromFields(
            PolicyCap.bcs.parse(data)
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

    static fromJSONField(
         field: any
    ): PolicyCap {
        return PolicyCap.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), for: decodeFromJSONField(ID.reified(), field.for)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): PolicyCap {
        if (json.$typeName !== PolicyCap.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return PolicyCap.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): PolicyCap {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isPolicyCap(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a PolicyCap object`);
        }
        return PolicyCap.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<PolicyCap> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching PolicyCap object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isPolicyCap(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a PolicyCap object`);
        }

        return PolicyCap.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== RequestBody =============================== */

export function isRequestBody(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::RequestBody<");
}

export interface RequestBodyFields<P extends PhantomTypeArgument> {
    receipts: ToField<VecSet<TypeName>>; metadata: ToField<UID>
}

export type RequestBodyReified<P extends PhantomTypeArgument> = Reified<
    RequestBody<P>,
    RequestBodyFields<P>
>;

export class RequestBody<P extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::RequestBody";
    static readonly $numTypeParams = 1;

    readonly $typeName = RequestBody.$typeName;

    readonly $fullTypeName: `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::RequestBody<${PhantomToTypeStr<P>}>`;

    readonly $typeArgs: [PhantomToTypeStr<P>];

    readonly receipts:
        ToField<VecSet<TypeName>>
    ; readonly metadata:
        ToField<UID>

    private constructor(typeArgs: [PhantomToTypeStr<P>], fields: RequestBodyFields<P>,
    ) {
        this.$fullTypeName = composeSuiType(
            RequestBody.$typeName,
            ...typeArgs
        ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::RequestBody<${PhantomToTypeStr<P>}>`;
        this.$typeArgs = typeArgs;

        this.receipts = fields.receipts;; this.metadata = fields.metadata;
    }

    static reified<P extends PhantomReified<PhantomTypeArgument>>(
        P: P
    ): RequestBodyReified<ToPhantomTypeArgument<P>> {
        return {
            typeName: RequestBody.$typeName,
            fullTypeName: composeSuiType(
                RequestBody.$typeName,
                ...[extractType(P)]
            ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::RequestBody<${PhantomToTypeStr<ToPhantomTypeArgument<P>>}>`,
            typeArgs: [
                extractType(P)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<P>>],
            reifiedTypeArgs: [P],
            fromFields: (fields: Record<string, any>) =>
                RequestBody.fromFields(
                    P,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                RequestBody.fromFieldsWithTypes(
                    P,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                RequestBody.fromBcs(
                    P,
                    data,
                ),
            bcs: RequestBody.bcs,
            fromJSONField: (field: any) =>
                RequestBody.fromJSONField(
                    P,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                RequestBody.fromJSON(
                    P,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                RequestBody.fromSuiParsedData(
                    P,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => RequestBody.fetch(
                client,
                P,
                id,
            ),
            new: (
                fields: RequestBodyFields<ToPhantomTypeArgument<P>>,
            ) => {
                return new RequestBody(
                    [extractType(P)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return RequestBody.reified
    }

    static phantom<P extends PhantomReified<PhantomTypeArgument>>(
        P: P
    ): PhantomReified<ToTypeStr<RequestBody<ToPhantomTypeArgument<P>>>> {
        return phantom(RequestBody.reified(
            P
        ));
    }

    static get p() {
        return RequestBody.phantom
    }

    static get bcs() {
        return bcs.struct("RequestBody", {
            receipts:
                VecSet.bcs(TypeName.bcs)
            , metadata:
                UID.bcs

        })
    };

    static fromFields<P extends PhantomReified<PhantomTypeArgument>>(
        typeArg: P, fields: Record<string, any>
    ): RequestBody<ToPhantomTypeArgument<P>> {
        return RequestBody.reified(
            typeArg,
        ).new(
            {receipts: decodeFromFields(VecSet.reified(TypeName.reified()), fields.receipts), metadata: decodeFromFields(UID.reified(), fields.metadata)}
        )
    }

    static fromFieldsWithTypes<P extends PhantomReified<PhantomTypeArgument>>(
        typeArg: P, item: FieldsWithTypes
    ): RequestBody<ToPhantomTypeArgument<P>> {
        if (!isRequestBody(item.type)) {
            throw new Error("not a RequestBody type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return RequestBody.reified(
            typeArg,
        ).new(
            {receipts: decodeFromFieldsWithTypes(VecSet.reified(TypeName.reified()), item.fields.receipts), metadata: decodeFromFieldsWithTypes(UID.reified(), item.fields.metadata)}
        )
    }

    static fromBcs<P extends PhantomReified<PhantomTypeArgument>>(
        typeArg: P, data: Uint8Array
    ): RequestBody<ToPhantomTypeArgument<P>> {

        return RequestBody.fromFields(
            typeArg,
            RequestBody.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            receipts: this.receipts.toJSONField(),metadata: this.metadata,

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<P extends PhantomReified<PhantomTypeArgument>>(
        typeArg: P, field: any
    ): RequestBody<ToPhantomTypeArgument<P>> {
        return RequestBody.reified(
            typeArg,
        ).new(
            {receipts: decodeFromJSONField(VecSet.reified(TypeName.reified()), field.receipts), metadata: decodeFromJSONField(UID.reified(), field.metadata)}
        )
    }

    static fromJSON<P extends PhantomReified<PhantomTypeArgument>>(
        typeArg: P, json: Record<string, any>
    ): RequestBody<ToPhantomTypeArgument<P>> {
        if (json.$typeName !== RequestBody.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(RequestBody.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return RequestBody.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<P extends PhantomReified<PhantomTypeArgument>>(
        typeArg: P, content: SuiParsedData
    ): RequestBody<ToPhantomTypeArgument<P>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isRequestBody(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a RequestBody object`);
        }
        return RequestBody.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<P extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: P, id: string
    ): Promise<RequestBody<ToPhantomTypeArgument<P>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching RequestBody object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isRequestBody(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a RequestBody object`);
        }

        return RequestBody.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== RuleStateDfKey =============================== */

export function isRuleStateDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::RuleStateDfKey<");
}

export interface RuleStateDfKeyFields<Rule extends PhantomTypeArgument> {
    dummyField: ToField<"bool">
}

export type RuleStateDfKeyReified<Rule extends PhantomTypeArgument> = Reified<
    RuleStateDfKey<Rule>,
    RuleStateDfKeyFields<Rule>
>;

export class RuleStateDfKey<Rule extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::RuleStateDfKey";
    static readonly $numTypeParams = 1;

    readonly $typeName = RuleStateDfKey.$typeName;

    readonly $fullTypeName: `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::RuleStateDfKey<${PhantomToTypeStr<Rule>}>`;

    readonly $typeArgs: [PhantomToTypeStr<Rule>];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [PhantomToTypeStr<Rule>], fields: RuleStateDfKeyFields<Rule>,
    ) {
        this.$fullTypeName = composeSuiType(
            RuleStateDfKey.$typeName,
            ...typeArgs
        ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::RuleStateDfKey<${PhantomToTypeStr<Rule>}>`;
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified<Rule extends PhantomReified<PhantomTypeArgument>>(
        Rule: Rule
    ): RuleStateDfKeyReified<ToPhantomTypeArgument<Rule>> {
        return {
            typeName: RuleStateDfKey.$typeName,
            fullTypeName: composeSuiType(
                RuleStateDfKey.$typeName,
                ...[extractType(Rule)]
            ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::RuleStateDfKey<${PhantomToTypeStr<ToPhantomTypeArgument<Rule>>}>`,
            typeArgs: [
                extractType(Rule)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<Rule>>],
            reifiedTypeArgs: [Rule],
            fromFields: (fields: Record<string, any>) =>
                RuleStateDfKey.fromFields(
                    Rule,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                RuleStateDfKey.fromFieldsWithTypes(
                    Rule,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                RuleStateDfKey.fromBcs(
                    Rule,
                    data,
                ),
            bcs: RuleStateDfKey.bcs,
            fromJSONField: (field: any) =>
                RuleStateDfKey.fromJSONField(
                    Rule,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                RuleStateDfKey.fromJSON(
                    Rule,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                RuleStateDfKey.fromSuiParsedData(
                    Rule,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => RuleStateDfKey.fetch(
                client,
                Rule,
                id,
            ),
            new: (
                fields: RuleStateDfKeyFields<ToPhantomTypeArgument<Rule>>,
            ) => {
                return new RuleStateDfKey(
                    [extractType(Rule)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return RuleStateDfKey.reified
    }

    static phantom<Rule extends PhantomReified<PhantomTypeArgument>>(
        Rule: Rule
    ): PhantomReified<ToTypeStr<RuleStateDfKey<ToPhantomTypeArgument<Rule>>>> {
        return phantom(RuleStateDfKey.reified(
            Rule
        ));
    }

    static get p() {
        return RuleStateDfKey.phantom
    }

    static get bcs() {
        return bcs.struct("RuleStateDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields<Rule extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Rule, fields: Record<string, any>
    ): RuleStateDfKey<ToPhantomTypeArgument<Rule>> {
        return RuleStateDfKey.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes<Rule extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Rule, item: FieldsWithTypes
    ): RuleStateDfKey<ToPhantomTypeArgument<Rule>> {
        if (!isRuleStateDfKey(item.type)) {
            throw new Error("not a RuleStateDfKey type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return RuleStateDfKey.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs<Rule extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Rule, data: Uint8Array
    ): RuleStateDfKey<ToPhantomTypeArgument<Rule>> {

        return RuleStateDfKey.fromFields(
            typeArg,
            RuleStateDfKey.bcs.parse(data)
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

    static fromJSONField<Rule extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Rule, field: any
    ): RuleStateDfKey<ToPhantomTypeArgument<Rule>> {
        return RuleStateDfKey.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON<Rule extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Rule, json: Record<string, any>
    ): RuleStateDfKey<ToPhantomTypeArgument<Rule>> {
        if (json.$typeName !== RuleStateDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(RuleStateDfKey.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return RuleStateDfKey.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<Rule extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Rule, content: SuiParsedData
    ): RuleStateDfKey<ToPhantomTypeArgument<Rule>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isRuleStateDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a RuleStateDfKey object`);
        }
        return RuleStateDfKey.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<Rule extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: Rule, id: string
    ): Promise<RuleStateDfKey<ToPhantomTypeArgument<Rule>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching RuleStateDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isRuleStateDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a RuleStateDfKey object`);
        }

        return RuleStateDfKey.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== WithNft =============================== */

export function isWithNft(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::WithNft<");
}

export interface WithNftFields<T extends PhantomTypeArgument, P extends PhantomTypeArgument> {
    dummyField: ToField<"bool">
}

export type WithNftReified<T extends PhantomTypeArgument, P extends PhantomTypeArgument> = Reified<
    WithNft<T, P>,
    WithNftFields<T, P>
>;

export class WithNft<T extends PhantomTypeArgument, P extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::WithNft";
    static readonly $numTypeParams = 2;

    readonly $typeName = WithNft.$typeName;

    readonly $fullTypeName: `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::WithNft<${PhantomToTypeStr<T>}, ${PhantomToTypeStr<P>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>, PhantomToTypeStr<P>];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [PhantomToTypeStr<T>, PhantomToTypeStr<P>], fields: WithNftFields<T, P>,
    ) {
        this.$fullTypeName = composeSuiType(
            WithNft.$typeName,
            ...typeArgs
        ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::WithNft<${PhantomToTypeStr<T>}, ${PhantomToTypeStr<P>}>`;
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>, P extends PhantomReified<PhantomTypeArgument>>(
        T: T, P: P
    ): WithNftReified<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<P>> {
        return {
            typeName: WithNft.$typeName,
            fullTypeName: composeSuiType(
                WithNft.$typeName,
                ...[extractType(T), extractType(P)]
            ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request::WithNft<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}, ${PhantomToTypeStr<ToPhantomTypeArgument<P>>}>`,
            typeArgs: [
                extractType(T), extractType(P)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>, PhantomToTypeStr<ToPhantomTypeArgument<P>>],
            reifiedTypeArgs: [T, P],
            fromFields: (fields: Record<string, any>) =>
                WithNft.fromFields(
                    [T, P],
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                WithNft.fromFieldsWithTypes(
                    [T, P],
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                WithNft.fromBcs(
                    [T, P],
                    data,
                ),
            bcs: WithNft.bcs,
            fromJSONField: (field: any) =>
                WithNft.fromJSONField(
                    [T, P],
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                WithNft.fromJSON(
                    [T, P],
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                WithNft.fromSuiParsedData(
                    [T, P],
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => WithNft.fetch(
                client,
                [T, P],
                id,
            ),
            new: (
                fields: WithNftFields<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<P>>,
            ) => {
                return new WithNft(
                    [extractType(T), extractType(P)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return WithNft.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>, P extends PhantomReified<PhantomTypeArgument>>(
        T: T, P: P
    ): PhantomReified<ToTypeStr<WithNft<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<P>>>> {
        return phantom(WithNft.reified(
            T, P
        ));
    }

    static get p() {
        return WithNft.phantom
    }

    static get bcs() {
        return bcs.struct("WithNft", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>, P extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, P], fields: Record<string, any>
    ): WithNft<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<P>> {
        return WithNft.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>, P extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, P], item: FieldsWithTypes
    ): WithNft<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<P>> {
        if (!isWithNft(item.type)) {
            throw new Error("not a WithNft type");
        }
        assertFieldsWithTypesArgsMatch(item, typeArgs);

        return WithNft.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>, P extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, P], data: Uint8Array
    ): WithNft<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<P>> {

        return WithNft.fromFields(
            typeArgs,
            WithNft.bcs.parse(data)
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

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>, P extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, P], field: any
    ): WithNft<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<P>> {
        return WithNft.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>, P extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, P], json: Record<string, any>
    ): WithNft<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<P>> {
        if (json.$typeName !== WithNft.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(WithNft.$typeName,
            ...typeArgs.map(extractType)),
            json.$typeArgs,
            typeArgs,
        )

        return WithNft.fromJSONField(
            typeArgs,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>, P extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, P], content: SuiParsedData
    ): WithNft<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<P>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWithNft(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a WithNft object`);
        }
        return WithNft.fromFieldsWithTypes(
            typeArgs,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>, P extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArgs: [T, P], id: string
    ): Promise<WithNft<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<P>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching WithNft object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWithNft(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a WithNft object`);
        }

        return WithNft.fromBcs(
            typeArgs,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
