import * as reified from "../../_framework/reified";
import {TypeName} from "../../_dependencies/source/0x1/type-name/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {Table} from "../../_dependencies/source/0x2/table/structs";
import {VecSet} from "../../_dependencies/source/0x2/vec-set/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom, ToTypeStr as ToPhantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::Witness";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: WitnessFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Witness.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::Witness";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): WitnessReified {
        return {
            typeName: Witness.$typeName,
            fullTypeName: composeSuiType(
                Witness.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::Witness",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
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
            fromSuiParsedData: (content: SuiParsedData) =>
                Witness.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Witness.fetch(
                client,
                id,
            ),
            new: (
                fields: WitnessFields,
            ) => {
                return new Witness(
                    [],
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
            $typeArgs: this.$typeArgs,
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

/* ============================== AccessPolicy =============================== */

export function isAccessPolicy(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::AccessPolicy<");
}

export interface AccessPolicyFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; version: ToField<"u64">; parentAccess: ToField<VecSet<"address">>; fieldAccess: ToField<Table<ToPhantom<TypeName>, ToPhantom<VecSet<"address">>>>
}

export type AccessPolicyReified<T extends PhantomTypeArgument> = Reified<
    AccessPolicy<T>,
    AccessPolicyFields<T>
>;

export class AccessPolicy<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::AccessPolicy";
    static readonly $numTypeParams = 1;

    readonly $typeName = AccessPolicy.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::AccessPolicy<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly id:
        ToField<UID>
    ; readonly version:
        ToField<"u64">
    ; readonly parentAccess:
        ToField<VecSet<"address">>
    ; readonly fieldAccess:
        ToField<Table<ToPhantom<TypeName>, ToPhantom<VecSet<"address">>>>

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: AccessPolicyFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            AccessPolicy.$typeName,
            ...typeArgs
        ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::AccessPolicy<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.version = fields.version;; this.parentAccess = fields.parentAccess;; this.fieldAccess = fields.fieldAccess;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): AccessPolicyReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: AccessPolicy.$typeName,
            fullTypeName: composeSuiType(
                AccessPolicy.$typeName,
                ...[extractType(T)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::AccessPolicy<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                AccessPolicy.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                AccessPolicy.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                AccessPolicy.fromBcs(
                    T,
                    data,
                ),
            bcs: AccessPolicy.bcs,
            fromJSONField: (field: any) =>
                AccessPolicy.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                AccessPolicy.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                AccessPolicy.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => AccessPolicy.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: AccessPolicyFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new AccessPolicy(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return AccessPolicy.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<AccessPolicy<ToPhantomTypeArgument<T>>>> {
        return phantom(AccessPolicy.reified(
            T
        ));
    }

    static get p() {
        return AccessPolicy.phantom
    }

    static get bcs() {
        return bcs.struct("AccessPolicy", {
            id:
                UID.bcs
            , version:
                bcs.u64()
            , parent_access:
                VecSet.bcs(bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),}))
            , field_access:
                Table.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): AccessPolicy<ToPhantomTypeArgument<T>> {
        return AccessPolicy.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), version: decodeFromFields("u64", fields.version), parentAccess: decodeFromFields(VecSet.reified("address"), fields.parent_access), fieldAccess: decodeFromFields(Table.reified(reified.phantom(TypeName.reified()), reified.phantom(VecSet.reified("address"))), fields.field_access)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): AccessPolicy<ToPhantomTypeArgument<T>> {
        if (!isAccessPolicy(item.type)) {
            throw new Error("not a AccessPolicy type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return AccessPolicy.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), version: decodeFromFieldsWithTypes("u64", item.fields.version), parentAccess: decodeFromFieldsWithTypes(VecSet.reified("address"), item.fields.parent_access), fieldAccess: decodeFromFieldsWithTypes(Table.reified(reified.phantom(TypeName.reified()), reified.phantom(VecSet.reified("address"))), item.fields.field_access)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): AccessPolicy<ToPhantomTypeArgument<T>> {

        return AccessPolicy.fromFields(
            typeArg,
            AccessPolicy.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,version: this.version.toString(),parentAccess: this.parentAccess.toJSONField(),fieldAccess: this.fieldAccess.toJSONField(),

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
    ): AccessPolicy<ToPhantomTypeArgument<T>> {
        return AccessPolicy.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), version: decodeFromJSONField("u64", field.version), parentAccess: decodeFromJSONField(VecSet.reified("address"), field.parentAccess), fieldAccess: decodeFromJSONField(Table.reified(reified.phantom(TypeName.reified()), reified.phantom(VecSet.reified("address"))), field.fieldAccess)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): AccessPolicy<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== AccessPolicy.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(AccessPolicy.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return AccessPolicy.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): AccessPolicy<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAccessPolicy(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a AccessPolicy object`);
        }
        return AccessPolicy.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<AccessPolicy<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching AccessPolicy object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAccessPolicy(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a AccessPolicy object`);
        }

        return AccessPolicy.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== AccessPolicyRule =============================== */

export function isAccessPolicyRule(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::AccessPolicyRule";
}

export interface AccessPolicyRuleFields {
    dummyField: ToField<"bool">
}

export type AccessPolicyRuleReified = Reified<
    AccessPolicyRule,
    AccessPolicyRuleFields
>;

export class AccessPolicyRule implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::AccessPolicyRule";
    static readonly $numTypeParams = 0;

    readonly $typeName = AccessPolicyRule.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::AccessPolicyRule";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: AccessPolicyRuleFields,
    ) {
        this.$fullTypeName = composeSuiType(
            AccessPolicyRule.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::AccessPolicyRule";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): AccessPolicyRuleReified {
        return {
            typeName: AccessPolicyRule.$typeName,
            fullTypeName: composeSuiType(
                AccessPolicyRule.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::AccessPolicyRule",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                AccessPolicyRule.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                AccessPolicyRule.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                AccessPolicyRule.fromBcs(
                    data,
                ),
            bcs: AccessPolicyRule.bcs,
            fromJSONField: (field: any) =>
                AccessPolicyRule.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                AccessPolicyRule.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                AccessPolicyRule.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => AccessPolicyRule.fetch(
                client,
                id,
            ),
            new: (
                fields: AccessPolicyRuleFields,
            ) => {
                return new AccessPolicyRule(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return AccessPolicyRule.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<AccessPolicyRule>> {
        return phantom(AccessPolicyRule.reified());
    }

    static get p() {
        return AccessPolicyRule.phantom()
    }

    static get bcs() {
        return bcs.struct("AccessPolicyRule", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): AccessPolicyRule {
        return AccessPolicyRule.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): AccessPolicyRule {
        if (!isAccessPolicyRule(item.type)) {
            throw new Error("not a AccessPolicyRule type");
        }

        return AccessPolicyRule.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): AccessPolicyRule {

        return AccessPolicyRule.fromFields(
            AccessPolicyRule.bcs.parse(data)
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
    ): AccessPolicyRule {
        return AccessPolicyRule.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): AccessPolicyRule {
        if (json.$typeName !== AccessPolicyRule.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return AccessPolicyRule.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): AccessPolicyRule {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAccessPolicyRule(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a AccessPolicyRule object`);
        }
        return AccessPolicyRule.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<AccessPolicyRule> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching AccessPolicyRule object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAccessPolicyRule(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a AccessPolicyRule object`);
        }

        return AccessPolicyRule.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== NewPolicyEvent =============================== */

export function isNewPolicyEvent(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::NewPolicyEvent";
}

export interface NewPolicyEventFields {
    policyId: ToField<ID>; typeName: ToField<TypeName>
}

export type NewPolicyEventReified = Reified<
    NewPolicyEvent,
    NewPolicyEventFields
>;

export class NewPolicyEvent implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::NewPolicyEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = NewPolicyEvent.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::NewPolicyEvent";

    readonly $typeArgs: [];

    readonly policyId:
        ToField<ID>
    ; readonly typeName:
        ToField<TypeName>

    private constructor(typeArgs: [], fields: NewPolicyEventFields,
    ) {
        this.$fullTypeName = composeSuiType(
            NewPolicyEvent.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::NewPolicyEvent";
        this.$typeArgs = typeArgs;

        this.policyId = fields.policyId;; this.typeName = fields.typeName;
    }

    static reified(): NewPolicyEventReified {
        return {
            typeName: NewPolicyEvent.$typeName,
            fullTypeName: composeSuiType(
                NewPolicyEvent.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::access_policy::NewPolicyEvent",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                NewPolicyEvent.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                NewPolicyEvent.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                NewPolicyEvent.fromBcs(
                    data,
                ),
            bcs: NewPolicyEvent.bcs,
            fromJSONField: (field: any) =>
                NewPolicyEvent.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                NewPolicyEvent.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                NewPolicyEvent.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => NewPolicyEvent.fetch(
                client,
                id,
            ),
            new: (
                fields: NewPolicyEventFields,
            ) => {
                return new NewPolicyEvent(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return NewPolicyEvent.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<NewPolicyEvent>> {
        return phantom(NewPolicyEvent.reified());
    }

    static get p() {
        return NewPolicyEvent.phantom()
    }

    static get bcs() {
        return bcs.struct("NewPolicyEvent", {
            policy_id:
                ID.bcs
            , type_name:
                TypeName.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): NewPolicyEvent {
        return NewPolicyEvent.reified().new(
            {policyId: decodeFromFields(ID.reified(), fields.policy_id), typeName: decodeFromFields(TypeName.reified(), fields.type_name)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): NewPolicyEvent {
        if (!isNewPolicyEvent(item.type)) {
            throw new Error("not a NewPolicyEvent type");
        }

        return NewPolicyEvent.reified().new(
            {policyId: decodeFromFieldsWithTypes(ID.reified(), item.fields.policy_id), typeName: decodeFromFieldsWithTypes(TypeName.reified(), item.fields.type_name)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): NewPolicyEvent {

        return NewPolicyEvent.fromFields(
            NewPolicyEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            policyId: this.policyId,typeName: this.typeName.toJSONField(),

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
    ): NewPolicyEvent {
        return NewPolicyEvent.reified().new(
            {policyId: decodeFromJSONField(ID.reified(), field.policyId), typeName: decodeFromJSONField(TypeName.reified(), field.typeName)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): NewPolicyEvent {
        if (json.$typeName !== NewPolicyEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return NewPolicyEvent.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): NewPolicyEvent {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isNewPolicyEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a NewPolicyEvent object`);
        }
        return NewPolicyEvent.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<NewPolicyEvent> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching NewPolicyEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isNewPolicyEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a NewPolicyEvent object`);
        }

        return NewPolicyEvent.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
