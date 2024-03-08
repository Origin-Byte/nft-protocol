import {TypeName} from "../../_dependencies/source/0x1/type-name/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {VecSet} from "../../_dependencies/source/0x2/vec-set/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness implements StructClass {
    static readonly $typeName = "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::Witness";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: WitnessFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Witness.$typeName,
            ...typeArgs
        ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::Witness";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): WitnessReified {
        return {
            typeName: Witness.$typeName,
            fullTypeName: composeSuiType(
                Witness.$typeName,
                ...[]
            ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::Witness",
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

/* ============================== AuthTransferRequestDfKey =============================== */

export function isAuthTransferRequestDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::AuthTransferRequestDfKey";
}

export interface AuthTransferRequestDfKeyFields {
    dummyField: ToField<"bool">
}

export type AuthTransferRequestDfKeyReified = Reified<
    AuthTransferRequestDfKey,
    AuthTransferRequestDfKeyFields
>;

export class AuthTransferRequestDfKey implements StructClass {
    static readonly $typeName = "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::AuthTransferRequestDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = AuthTransferRequestDfKey.$typeName;

    readonly $fullTypeName: "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::AuthTransferRequestDfKey";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: AuthTransferRequestDfKeyFields,
    ) {
        this.$fullTypeName = composeSuiType(
            AuthTransferRequestDfKey.$typeName,
            ...typeArgs
        ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::AuthTransferRequestDfKey";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): AuthTransferRequestDfKeyReified {
        return {
            typeName: AuthTransferRequestDfKey.$typeName,
            fullTypeName: composeSuiType(
                AuthTransferRequestDfKey.$typeName,
                ...[]
            ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::AuthTransferRequestDfKey",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                AuthTransferRequestDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                AuthTransferRequestDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                AuthTransferRequestDfKey.fromBcs(
                    data,
                ),
            bcs: AuthTransferRequestDfKey.bcs,
            fromJSONField: (field: any) =>
                AuthTransferRequestDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                AuthTransferRequestDfKey.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                AuthTransferRequestDfKey.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => AuthTransferRequestDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: AuthTransferRequestDfKeyFields,
            ) => {
                return new AuthTransferRequestDfKey(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return AuthTransferRequestDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<AuthTransferRequestDfKey>> {
        return phantom(AuthTransferRequestDfKey.reified());
    }

    static get p() {
        return AuthTransferRequestDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("AuthTransferRequestDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): AuthTransferRequestDfKey {
        return AuthTransferRequestDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): AuthTransferRequestDfKey {
        if (!isAuthTransferRequestDfKey(item.type)) {
            throw new Error("not a AuthTransferRequestDfKey type");
        }

        return AuthTransferRequestDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): AuthTransferRequestDfKey {

        return AuthTransferRequestDfKey.fromFields(
            AuthTransferRequestDfKey.bcs.parse(data)
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
    ): AuthTransferRequestDfKey {
        return AuthTransferRequestDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): AuthTransferRequestDfKey {
        if (json.$typeName !== AuthTransferRequestDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return AuthTransferRequestDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): AuthTransferRequestDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAuthTransferRequestDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a AuthTransferRequestDfKey object`);
        }
        return AuthTransferRequestDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<AuthTransferRequestDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching AuthTransferRequestDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAuthTransferRequestDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a AuthTransferRequestDfKey object`);
        }

        return AuthTransferRequestDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== DepositSetting =============================== */

export function isDepositSetting(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::DepositSetting";
}

export interface DepositSettingFields {
    enableAnyDeposit: ToField<"bool">; collectionsWithEnabledDeposits: ToField<VecSet<TypeName>>
}

export type DepositSettingReified = Reified<
    DepositSetting,
    DepositSettingFields
>;

export class DepositSetting implements StructClass {
    static readonly $typeName = "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::DepositSetting";
    static readonly $numTypeParams = 0;

    readonly $typeName = DepositSetting.$typeName;

    readonly $fullTypeName: "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::DepositSetting";

    readonly $typeArgs: [];

    readonly enableAnyDeposit:
        ToField<"bool">
    ; readonly collectionsWithEnabledDeposits:
        ToField<VecSet<TypeName>>

    private constructor(typeArgs: [], fields: DepositSettingFields,
    ) {
        this.$fullTypeName = composeSuiType(
            DepositSetting.$typeName,
            ...typeArgs
        ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::DepositSetting";
        this.$typeArgs = typeArgs;

        this.enableAnyDeposit = fields.enableAnyDeposit;; this.collectionsWithEnabledDeposits = fields.collectionsWithEnabledDeposits;
    }

    static reified(): DepositSettingReified {
        return {
            typeName: DepositSetting.$typeName,
            fullTypeName: composeSuiType(
                DepositSetting.$typeName,
                ...[]
            ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::DepositSetting",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                DepositSetting.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                DepositSetting.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                DepositSetting.fromBcs(
                    data,
                ),
            bcs: DepositSetting.bcs,
            fromJSONField: (field: any) =>
                DepositSetting.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                DepositSetting.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                DepositSetting.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => DepositSetting.fetch(
                client,
                id,
            ),
            new: (
                fields: DepositSettingFields,
            ) => {
                return new DepositSetting(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return DepositSetting.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<DepositSetting>> {
        return phantom(DepositSetting.reified());
    }

    static get p() {
        return DepositSetting.phantom()
    }

    static get bcs() {
        return bcs.struct("DepositSetting", {
            enable_any_deposit:
                bcs.bool()
            , collections_with_enabled_deposits:
                VecSet.bcs(TypeName.bcs)

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): DepositSetting {
        return DepositSetting.reified().new(
            {enableAnyDeposit: decodeFromFields("bool", fields.enable_any_deposit), collectionsWithEnabledDeposits: decodeFromFields(VecSet.reified(TypeName.reified()), fields.collections_with_enabled_deposits)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): DepositSetting {
        if (!isDepositSetting(item.type)) {
            throw new Error("not a DepositSetting type");
        }

        return DepositSetting.reified().new(
            {enableAnyDeposit: decodeFromFieldsWithTypes("bool", item.fields.enable_any_deposit), collectionsWithEnabledDeposits: decodeFromFieldsWithTypes(VecSet.reified(TypeName.reified()), item.fields.collections_with_enabled_deposits)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): DepositSetting {

        return DepositSetting.fromFields(
            DepositSetting.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            enableAnyDeposit: this.enableAnyDeposit,collectionsWithEnabledDeposits: this.collectionsWithEnabledDeposits.toJSONField(),

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
    ): DepositSetting {
        return DepositSetting.reified().new(
            {enableAnyDeposit: decodeFromJSONField("bool", field.enableAnyDeposit), collectionsWithEnabledDeposits: decodeFromJSONField(VecSet.reified(TypeName.reified()), field.collectionsWithEnabledDeposits)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): DepositSetting {
        if (json.$typeName !== DepositSetting.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return DepositSetting.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): DepositSetting {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isDepositSetting(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a DepositSetting object`);
        }
        return DepositSetting.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<DepositSetting> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching DepositSetting object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isDepositSetting(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a DepositSetting object`);
        }

        return DepositSetting.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== DepositSettingDfKey =============================== */

export function isDepositSettingDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::DepositSettingDfKey";
}

export interface DepositSettingDfKeyFields {
    dummyField: ToField<"bool">
}

export type DepositSettingDfKeyReified = Reified<
    DepositSettingDfKey,
    DepositSettingDfKeyFields
>;

export class DepositSettingDfKey implements StructClass {
    static readonly $typeName = "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::DepositSettingDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = DepositSettingDfKey.$typeName;

    readonly $fullTypeName: "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::DepositSettingDfKey";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: DepositSettingDfKeyFields,
    ) {
        this.$fullTypeName = composeSuiType(
            DepositSettingDfKey.$typeName,
            ...typeArgs
        ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::DepositSettingDfKey";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): DepositSettingDfKeyReified {
        return {
            typeName: DepositSettingDfKey.$typeName,
            fullTypeName: composeSuiType(
                DepositSettingDfKey.$typeName,
                ...[]
            ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::DepositSettingDfKey",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                DepositSettingDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                DepositSettingDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                DepositSettingDfKey.fromBcs(
                    data,
                ),
            bcs: DepositSettingDfKey.bcs,
            fromJSONField: (field: any) =>
                DepositSettingDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                DepositSettingDfKey.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                DepositSettingDfKey.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => DepositSettingDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: DepositSettingDfKeyFields,
            ) => {
                return new DepositSettingDfKey(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return DepositSettingDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<DepositSettingDfKey>> {
        return phantom(DepositSettingDfKey.reified());
    }

    static get p() {
        return DepositSettingDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("DepositSettingDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): DepositSettingDfKey {
        return DepositSettingDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): DepositSettingDfKey {
        if (!isDepositSettingDfKey(item.type)) {
            throw new Error("not a DepositSettingDfKey type");
        }

        return DepositSettingDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): DepositSettingDfKey {

        return DepositSettingDfKey.fromFields(
            DepositSettingDfKey.bcs.parse(data)
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
    ): DepositSettingDfKey {
        return DepositSettingDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): DepositSettingDfKey {
        if (json.$typeName !== DepositSettingDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return DepositSettingDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): DepositSettingDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isDepositSettingDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a DepositSettingDfKey object`);
        }
        return DepositSettingDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<DepositSettingDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching DepositSettingDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isDepositSettingDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a DepositSettingDfKey object`);
        }

        return DepositSettingDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== KioskOwnerCapDfKey =============================== */

export function isKioskOwnerCapDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::KioskOwnerCapDfKey";
}

export interface KioskOwnerCapDfKeyFields {
    dummyField: ToField<"bool">
}

export type KioskOwnerCapDfKeyReified = Reified<
    KioskOwnerCapDfKey,
    KioskOwnerCapDfKeyFields
>;

export class KioskOwnerCapDfKey implements StructClass {
    static readonly $typeName = "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::KioskOwnerCapDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = KioskOwnerCapDfKey.$typeName;

    readonly $fullTypeName: "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::KioskOwnerCapDfKey";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: KioskOwnerCapDfKeyFields,
    ) {
        this.$fullTypeName = composeSuiType(
            KioskOwnerCapDfKey.$typeName,
            ...typeArgs
        ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::KioskOwnerCapDfKey";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): KioskOwnerCapDfKeyReified {
        return {
            typeName: KioskOwnerCapDfKey.$typeName,
            fullTypeName: composeSuiType(
                KioskOwnerCapDfKey.$typeName,
                ...[]
            ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::KioskOwnerCapDfKey",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                KioskOwnerCapDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                KioskOwnerCapDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                KioskOwnerCapDfKey.fromBcs(
                    data,
                ),
            bcs: KioskOwnerCapDfKey.bcs,
            fromJSONField: (field: any) =>
                KioskOwnerCapDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                KioskOwnerCapDfKey.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                KioskOwnerCapDfKey.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => KioskOwnerCapDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: KioskOwnerCapDfKeyFields,
            ) => {
                return new KioskOwnerCapDfKey(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return KioskOwnerCapDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<KioskOwnerCapDfKey>> {
        return phantom(KioskOwnerCapDfKey.reified());
    }

    static get p() {
        return KioskOwnerCapDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("KioskOwnerCapDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): KioskOwnerCapDfKey {
        return KioskOwnerCapDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): KioskOwnerCapDfKey {
        if (!isKioskOwnerCapDfKey(item.type)) {
            throw new Error("not a KioskOwnerCapDfKey type");
        }

        return KioskOwnerCapDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): KioskOwnerCapDfKey {

        return KioskOwnerCapDfKey.fromFields(
            KioskOwnerCapDfKey.bcs.parse(data)
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
    ): KioskOwnerCapDfKey {
        return KioskOwnerCapDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): KioskOwnerCapDfKey {
        if (json.$typeName !== KioskOwnerCapDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return KioskOwnerCapDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): KioskOwnerCapDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isKioskOwnerCapDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a KioskOwnerCapDfKey object`);
        }
        return KioskOwnerCapDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<KioskOwnerCapDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching KioskOwnerCapDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isKioskOwnerCapDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a KioskOwnerCapDfKey object`);
        }

        return KioskOwnerCapDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== NftRef =============================== */

export function isNftRef(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::NftRef";
}

export interface NftRefFields {
    auths: ToField<VecSet<"address">>; isExclusivelyListed: ToField<"bool">
}

export type NftRefReified = Reified<
    NftRef,
    NftRefFields
>;

export class NftRef implements StructClass {
    static readonly $typeName = "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::NftRef";
    static readonly $numTypeParams = 0;

    readonly $typeName = NftRef.$typeName;

    readonly $fullTypeName: "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::NftRef";

    readonly $typeArgs: [];

    readonly auths:
        ToField<VecSet<"address">>
    ; readonly isExclusivelyListed:
        ToField<"bool">

    private constructor(typeArgs: [], fields: NftRefFields,
    ) {
        this.$fullTypeName = composeSuiType(
            NftRef.$typeName,
            ...typeArgs
        ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::NftRef";
        this.$typeArgs = typeArgs;

        this.auths = fields.auths;; this.isExclusivelyListed = fields.isExclusivelyListed;
    }

    static reified(): NftRefReified {
        return {
            typeName: NftRef.$typeName,
            fullTypeName: composeSuiType(
                NftRef.$typeName,
                ...[]
            ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::NftRef",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                NftRef.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                NftRef.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                NftRef.fromBcs(
                    data,
                ),
            bcs: NftRef.bcs,
            fromJSONField: (field: any) =>
                NftRef.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                NftRef.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                NftRef.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => NftRef.fetch(
                client,
                id,
            ),
            new: (
                fields: NftRefFields,
            ) => {
                return new NftRef(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return NftRef.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<NftRef>> {
        return phantom(NftRef.reified());
    }

    static get p() {
        return NftRef.phantom()
    }

    static get bcs() {
        return bcs.struct("NftRef", {
            auths:
                VecSet.bcs(bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),}))
            , is_exclusively_listed:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): NftRef {
        return NftRef.reified().new(
            {auths: decodeFromFields(VecSet.reified("address"), fields.auths), isExclusivelyListed: decodeFromFields("bool", fields.is_exclusively_listed)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): NftRef {
        if (!isNftRef(item.type)) {
            throw new Error("not a NftRef type");
        }

        return NftRef.reified().new(
            {auths: decodeFromFieldsWithTypes(VecSet.reified("address"), item.fields.auths), isExclusivelyListed: decodeFromFieldsWithTypes("bool", item.fields.is_exclusively_listed)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): NftRef {

        return NftRef.fromFields(
            NftRef.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            auths: this.auths.toJSONField(),isExclusivelyListed: this.isExclusivelyListed,

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
    ): NftRef {
        return NftRef.reified().new(
            {auths: decodeFromJSONField(VecSet.reified("address"), field.auths), isExclusivelyListed: decodeFromJSONField("bool", field.isExclusivelyListed)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): NftRef {
        if (json.$typeName !== NftRef.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return NftRef.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): NftRef {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isNftRef(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a NftRef object`);
        }
        return NftRef.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<NftRef> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching NftRef object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isNftRef(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a NftRef object`);
        }

        return NftRef.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== NftRefsDfKey =============================== */

export function isNftRefsDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::NftRefsDfKey";
}

export interface NftRefsDfKeyFields {
    dummyField: ToField<"bool">
}

export type NftRefsDfKeyReified = Reified<
    NftRefsDfKey,
    NftRefsDfKeyFields
>;

export class NftRefsDfKey implements StructClass {
    static readonly $typeName = "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::NftRefsDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = NftRefsDfKey.$typeName;

    readonly $fullTypeName: "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::NftRefsDfKey";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: NftRefsDfKeyFields,
    ) {
        this.$fullTypeName = composeSuiType(
            NftRefsDfKey.$typeName,
            ...typeArgs
        ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::NftRefsDfKey";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): NftRefsDfKeyReified {
        return {
            typeName: NftRefsDfKey.$typeName,
            fullTypeName: composeSuiType(
                NftRefsDfKey.$typeName,
                ...[]
            ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::NftRefsDfKey",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                NftRefsDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                NftRefsDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                NftRefsDfKey.fromBcs(
                    data,
                ),
            bcs: NftRefsDfKey.bcs,
            fromJSONField: (field: any) =>
                NftRefsDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                NftRefsDfKey.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                NftRefsDfKey.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => NftRefsDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: NftRefsDfKeyFields,
            ) => {
                return new NftRefsDfKey(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return NftRefsDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<NftRefsDfKey>> {
        return phantom(NftRefsDfKey.reified());
    }

    static get p() {
        return NftRefsDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("NftRefsDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): NftRefsDfKey {
        return NftRefsDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): NftRefsDfKey {
        if (!isNftRefsDfKey(item.type)) {
            throw new Error("not a NftRefsDfKey type");
        }

        return NftRefsDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): NftRefsDfKey {

        return NftRefsDfKey.fromFields(
            NftRefsDfKey.bcs.parse(data)
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
    ): NftRefsDfKey {
        return NftRefsDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): NftRefsDfKey {
        if (json.$typeName !== NftRefsDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return NftRefsDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): NftRefsDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isNftRefsDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a NftRefsDfKey object`);
        }
        return NftRefsDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<NftRefsDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching NftRefsDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isNftRefsDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a NftRefsDfKey object`);
        }

        return NftRefsDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== OB_KIOSK =============================== */

export function isOB_KIOSK(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::OB_KIOSK";
}

export interface OB_KIOSKFields {
    dummyField: ToField<"bool">
}

export type OB_KIOSKReified = Reified<
    OB_KIOSK,
    OB_KIOSKFields
>;

export class OB_KIOSK implements StructClass {
    static readonly $typeName = "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::OB_KIOSK";
    static readonly $numTypeParams = 0;

    readonly $typeName = OB_KIOSK.$typeName;

    readonly $fullTypeName: "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::OB_KIOSK";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: OB_KIOSKFields,
    ) {
        this.$fullTypeName = composeSuiType(
            OB_KIOSK.$typeName,
            ...typeArgs
        ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::OB_KIOSK";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): OB_KIOSKReified {
        return {
            typeName: OB_KIOSK.$typeName,
            fullTypeName: composeSuiType(
                OB_KIOSK.$typeName,
                ...[]
            ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::OB_KIOSK",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                OB_KIOSK.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                OB_KIOSK.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                OB_KIOSK.fromBcs(
                    data,
                ),
            bcs: OB_KIOSK.bcs,
            fromJSONField: (field: any) =>
                OB_KIOSK.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                OB_KIOSK.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                OB_KIOSK.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => OB_KIOSK.fetch(
                client,
                id,
            ),
            new: (
                fields: OB_KIOSKFields,
            ) => {
                return new OB_KIOSK(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return OB_KIOSK.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<OB_KIOSK>> {
        return phantom(OB_KIOSK.reified());
    }

    static get p() {
        return OB_KIOSK.phantom()
    }

    static get bcs() {
        return bcs.struct("OB_KIOSK", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): OB_KIOSK {
        return OB_KIOSK.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): OB_KIOSK {
        if (!isOB_KIOSK(item.type)) {
            throw new Error("not a OB_KIOSK type");
        }

        return OB_KIOSK.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): OB_KIOSK {

        return OB_KIOSK.fromFields(
            OB_KIOSK.bcs.parse(data)
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
    ): OB_KIOSK {
        return OB_KIOSK.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): OB_KIOSK {
        if (json.$typeName !== OB_KIOSK.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return OB_KIOSK.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): OB_KIOSK {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isOB_KIOSK(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a OB_KIOSK object`);
        }
        return OB_KIOSK.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<OB_KIOSK> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching OB_KIOSK object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isOB_KIOSK(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a OB_KIOSK object`);
        }

        return OB_KIOSK.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== OwnerToken =============================== */

export function isOwnerToken(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::OwnerToken";
}

export interface OwnerTokenFields {
    id: ToField<UID>; kiosk: ToField<ID>; owner: ToField<"address">
}

export type OwnerTokenReified = Reified<
    OwnerToken,
    OwnerTokenFields
>;

export class OwnerToken implements StructClass {
    static readonly $typeName = "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::OwnerToken";
    static readonly $numTypeParams = 0;

    readonly $typeName = OwnerToken.$typeName;

    readonly $fullTypeName: "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::OwnerToken";

    readonly $typeArgs: [];

    readonly id:
        ToField<UID>
    ; readonly kiosk:
        ToField<ID>
    ; readonly owner:
        ToField<"address">

    private constructor(typeArgs: [], fields: OwnerTokenFields,
    ) {
        this.$fullTypeName = composeSuiType(
            OwnerToken.$typeName,
            ...typeArgs
        ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::OwnerToken";
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.kiosk = fields.kiosk;; this.owner = fields.owner;
    }

    static reified(): OwnerTokenReified {
        return {
            typeName: OwnerToken.$typeName,
            fullTypeName: composeSuiType(
                OwnerToken.$typeName,
                ...[]
            ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::OwnerToken",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                OwnerToken.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                OwnerToken.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                OwnerToken.fromBcs(
                    data,
                ),
            bcs: OwnerToken.bcs,
            fromJSONField: (field: any) =>
                OwnerToken.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                OwnerToken.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                OwnerToken.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => OwnerToken.fetch(
                client,
                id,
            ),
            new: (
                fields: OwnerTokenFields,
            ) => {
                return new OwnerToken(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return OwnerToken.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<OwnerToken>> {
        return phantom(OwnerToken.reified());
    }

    static get p() {
        return OwnerToken.phantom()
    }

    static get bcs() {
        return bcs.struct("OwnerToken", {
            id:
                UID.bcs
            , kiosk:
                ID.bcs
            , owner:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): OwnerToken {
        return OwnerToken.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), kiosk: decodeFromFields(ID.reified(), fields.kiosk), owner: decodeFromFields("address", fields.owner)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): OwnerToken {
        if (!isOwnerToken(item.type)) {
            throw new Error("not a OwnerToken type");
        }

        return OwnerToken.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), kiosk: decodeFromFieldsWithTypes(ID.reified(), item.fields.kiosk), owner: decodeFromFieldsWithTypes("address", item.fields.owner)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): OwnerToken {

        return OwnerToken.fromFields(
            OwnerToken.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,kiosk: this.kiosk,owner: this.owner,

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
    ): OwnerToken {
        return OwnerToken.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), kiosk: decodeFromJSONField(ID.reified(), field.kiosk), owner: decodeFromJSONField("address", field.owner)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): OwnerToken {
        if (json.$typeName !== OwnerToken.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return OwnerToken.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): OwnerToken {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isOwnerToken(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a OwnerToken object`);
        }
        return OwnerToken.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<OwnerToken> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching OwnerToken object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isOwnerToken(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a OwnerToken object`);
        }

        return OwnerToken.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== VersionDfKey =============================== */

export function isVersionDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::VersionDfKey";
}

export interface VersionDfKeyFields {
    dummyField: ToField<"bool">
}

export type VersionDfKeyReified = Reified<
    VersionDfKey,
    VersionDfKeyFields
>;

export class VersionDfKey implements StructClass {
    static readonly $typeName = "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::VersionDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = VersionDfKey.$typeName;

    readonly $fullTypeName: "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::VersionDfKey";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: VersionDfKeyFields,
    ) {
        this.$fullTypeName = composeSuiType(
            VersionDfKey.$typeName,
            ...typeArgs
        ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::VersionDfKey";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): VersionDfKeyReified {
        return {
            typeName: VersionDfKey.$typeName,
            fullTypeName: composeSuiType(
                VersionDfKey.$typeName,
                ...[]
            ) as "0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk::VersionDfKey",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                VersionDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                VersionDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                VersionDfKey.fromBcs(
                    data,
                ),
            bcs: VersionDfKey.bcs,
            fromJSONField: (field: any) =>
                VersionDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                VersionDfKey.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                VersionDfKey.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => VersionDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: VersionDfKeyFields,
            ) => {
                return new VersionDfKey(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return VersionDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<VersionDfKey>> {
        return phantom(VersionDfKey.reified());
    }

    static get p() {
        return VersionDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("VersionDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): VersionDfKey {
        return VersionDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): VersionDfKey {
        if (!isVersionDfKey(item.type)) {
            throw new Error("not a VersionDfKey type");
        }

        return VersionDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): VersionDfKey {

        return VersionDfKey.fromFields(
            VersionDfKey.bcs.parse(data)
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
    ): VersionDfKey {
        return VersionDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): VersionDfKey {
        if (json.$typeName !== VersionDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return VersionDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): VersionDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isVersionDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a VersionDfKey object`);
        }
        return VersionDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<VersionDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching VersionDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isVersionDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a VersionDfKey object`);
        }

        return VersionDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
