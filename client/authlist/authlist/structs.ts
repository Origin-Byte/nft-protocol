import * as reified from "../../_framework/reified";
import {Option} from "../../_dependencies/source/0x1/option/structs";
import {String} from "../../_dependencies/source/0x1/string/structs";
import {TypeName} from "../../_dependencies/source/0x1/type-name/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {VecMap} from "../../_dependencies/source/0x2/vec-map/structs";
import {VecSet} from "../../_dependencies/source/0x2/vec-set/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, Vector, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, fieldToJSON, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== AUTHLIST =============================== */

export function isAUTHLIST(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::AUTHLIST";
}

export interface AUTHLISTFields {
    dummyField: ToField<"bool">
}

export type AUTHLISTReified = Reified<
    AUTHLIST,
    AUTHLISTFields
>;

export class AUTHLIST implements StructClass {
    static readonly $typeName = "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::AUTHLIST";
    static readonly $numTypeParams = 0;

    readonly $typeName = AUTHLIST.$typeName;

    readonly $fullTypeName: "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::AUTHLIST";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: AUTHLISTFields,
    ) {
        this.$fullTypeName = composeSuiType(
            AUTHLIST.$typeName,
            ...typeArgs
        ) as "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::AUTHLIST";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): AUTHLISTReified {
        return {
            typeName: AUTHLIST.$typeName,
            fullTypeName: composeSuiType(
                AUTHLIST.$typeName,
                ...[]
            ) as "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::AUTHLIST",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                AUTHLIST.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                AUTHLIST.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                AUTHLIST.fromBcs(
                    data,
                ),
            bcs: AUTHLIST.bcs,
            fromJSONField: (field: any) =>
                AUTHLIST.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                AUTHLIST.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                AUTHLIST.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => AUTHLIST.fetch(
                client,
                id,
            ),
            new: (
                fields: AUTHLISTFields,
            ) => {
                return new AUTHLIST(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return AUTHLIST.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<AUTHLIST>> {
        return phantom(AUTHLIST.reified());
    }

    static get p() {
        return AUTHLIST.phantom()
    }

    static get bcs() {
        return bcs.struct("AUTHLIST", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): AUTHLIST {
        return AUTHLIST.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): AUTHLIST {
        if (!isAUTHLIST(item.type)) {
            throw new Error("not a AUTHLIST type");
        }

        return AUTHLIST.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): AUTHLIST {

        return AUTHLIST.fromFields(
            AUTHLIST.bcs.parse(data)
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
    ): AUTHLIST {
        return AUTHLIST.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): AUTHLIST {
        if (json.$typeName !== AUTHLIST.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return AUTHLIST.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): AUTHLIST {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAUTHLIST(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a AUTHLIST object`);
        }
        return AUTHLIST.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<AUTHLIST> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching AUTHLIST object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAUTHLIST(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a AUTHLIST object`);
        }

        return AUTHLIST.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Authlist =============================== */

export function isAuthlist(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::Authlist";
}

export interface AuthlistFields {
    id: ToField<UID>; version: ToField<"u64">; adminWitness: ToField<Option<TypeName>>; names: ToField<VecMap<Vector<"u8">, String>>; authorities: ToField<VecSet<Vector<"u8">>>
}

export type AuthlistReified = Reified<
    Authlist,
    AuthlistFields
>;

export class Authlist implements StructClass {
    static readonly $typeName = "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::Authlist";
    static readonly $numTypeParams = 0;

    readonly $typeName = Authlist.$typeName;

    readonly $fullTypeName: "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::Authlist";

    readonly $typeArgs: [];

    readonly id:
        ToField<UID>
    ; readonly version:
        ToField<"u64">
    ; readonly adminWitness:
        ToField<Option<TypeName>>
    ; readonly names:
        ToField<VecMap<Vector<"u8">, String>>
    ; readonly authorities:
        ToField<VecSet<Vector<"u8">>>

    private constructor(typeArgs: [], fields: AuthlistFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Authlist.$typeName,
            ...typeArgs
        ) as "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::Authlist";
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.version = fields.version;; this.adminWitness = fields.adminWitness;; this.names = fields.names;; this.authorities = fields.authorities;
    }

    static reified(): AuthlistReified {
        return {
            typeName: Authlist.$typeName,
            fullTypeName: composeSuiType(
                Authlist.$typeName,
                ...[]
            ) as "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::Authlist",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Authlist.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Authlist.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Authlist.fromBcs(
                    data,
                ),
            bcs: Authlist.bcs,
            fromJSONField: (field: any) =>
                Authlist.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Authlist.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Authlist.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Authlist.fetch(
                client,
                id,
            ),
            new: (
                fields: AuthlistFields,
            ) => {
                return new Authlist(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Authlist.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Authlist>> {
        return phantom(Authlist.reified());
    }

    static get p() {
        return Authlist.phantom()
    }

    static get bcs() {
        return bcs.struct("Authlist", {
            id:
                UID.bcs
            , version:
                bcs.u64()
            , admin_witness:
                Option.bcs(TypeName.bcs)
            , names:
                VecMap.bcs(bcs.vector(bcs.u8()), String.bcs)
            , authorities:
                VecSet.bcs(bcs.vector(bcs.u8()))

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Authlist {
        return Authlist.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), version: decodeFromFields("u64", fields.version), adminWitness: decodeFromFields(Option.reified(TypeName.reified()), fields.admin_witness), names: decodeFromFields(VecMap.reified(reified.vector("u8"), String.reified()), fields.names), authorities: decodeFromFields(VecSet.reified(reified.vector("u8")), fields.authorities)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Authlist {
        if (!isAuthlist(item.type)) {
            throw new Error("not a Authlist type");
        }

        return Authlist.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), version: decodeFromFieldsWithTypes("u64", item.fields.version), adminWitness: decodeFromFieldsWithTypes(Option.reified(TypeName.reified()), item.fields.admin_witness), names: decodeFromFieldsWithTypes(VecMap.reified(reified.vector("u8"), String.reified()), item.fields.names), authorities: decodeFromFieldsWithTypes(VecSet.reified(reified.vector("u8")), item.fields.authorities)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Authlist {

        return Authlist.fromFields(
            Authlist.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,version: this.version.toString(),adminWitness: fieldToJSON<Option<TypeName>>(`0x1::option::Option<0x1::type_name::TypeName>`, this.adminWitness),names: this.names.toJSONField(),authorities: this.authorities.toJSONField(),

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
    ): Authlist {
        return Authlist.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), version: decodeFromJSONField("u64", field.version), adminWitness: decodeFromJSONField(Option.reified(TypeName.reified()), field.adminWitness), names: decodeFromJSONField(VecMap.reified(reified.vector("u8"), String.reified()), field.names), authorities: decodeFromJSONField(VecSet.reified(reified.vector("u8")), field.authorities)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Authlist {
        if (json.$typeName !== Authlist.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Authlist.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Authlist {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAuthlist(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Authlist object`);
        }
        return Authlist.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Authlist> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Authlist object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAuthlist(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Authlist object`);
        }

        return Authlist.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== AuthlistOwnerCap =============================== */

export function isAuthlistOwnerCap(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::AuthlistOwnerCap";
}

export interface AuthlistOwnerCapFields {
    id: ToField<UID>; for: ToField<ID>
}

export type AuthlistOwnerCapReified = Reified<
    AuthlistOwnerCap,
    AuthlistOwnerCapFields
>;

export class AuthlistOwnerCap implements StructClass {
    static readonly $typeName = "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::AuthlistOwnerCap";
    static readonly $numTypeParams = 0;

    readonly $typeName = AuthlistOwnerCap.$typeName;

    readonly $fullTypeName: "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::AuthlistOwnerCap";

    readonly $typeArgs: [];

    readonly id:
        ToField<UID>
    ; readonly for:
        ToField<ID>

    private constructor(typeArgs: [], fields: AuthlistOwnerCapFields,
    ) {
        this.$fullTypeName = composeSuiType(
            AuthlistOwnerCap.$typeName,
            ...typeArgs
        ) as "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::AuthlistOwnerCap";
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.for = fields.for;
    }

    static reified(): AuthlistOwnerCapReified {
        return {
            typeName: AuthlistOwnerCap.$typeName,
            fullTypeName: composeSuiType(
                AuthlistOwnerCap.$typeName,
                ...[]
            ) as "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::AuthlistOwnerCap",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                AuthlistOwnerCap.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                AuthlistOwnerCap.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                AuthlistOwnerCap.fromBcs(
                    data,
                ),
            bcs: AuthlistOwnerCap.bcs,
            fromJSONField: (field: any) =>
                AuthlistOwnerCap.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                AuthlistOwnerCap.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                AuthlistOwnerCap.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => AuthlistOwnerCap.fetch(
                client,
                id,
            ),
            new: (
                fields: AuthlistOwnerCapFields,
            ) => {
                return new AuthlistOwnerCap(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return AuthlistOwnerCap.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<AuthlistOwnerCap>> {
        return phantom(AuthlistOwnerCap.reified());
    }

    static get p() {
        return AuthlistOwnerCap.phantom()
    }

    static get bcs() {
        return bcs.struct("AuthlistOwnerCap", {
            id:
                UID.bcs
            , for:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): AuthlistOwnerCap {
        return AuthlistOwnerCap.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), for: decodeFromFields(ID.reified(), fields.for)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): AuthlistOwnerCap {
        if (!isAuthlistOwnerCap(item.type)) {
            throw new Error("not a AuthlistOwnerCap type");
        }

        return AuthlistOwnerCap.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), for: decodeFromFieldsWithTypes(ID.reified(), item.fields.for)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): AuthlistOwnerCap {

        return AuthlistOwnerCap.fromFields(
            AuthlistOwnerCap.bcs.parse(data)
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
    ): AuthlistOwnerCap {
        return AuthlistOwnerCap.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), for: decodeFromJSONField(ID.reified(), field.for)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): AuthlistOwnerCap {
        if (json.$typeName !== AuthlistOwnerCap.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return AuthlistOwnerCap.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): AuthlistOwnerCap {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAuthlistOwnerCap(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a AuthlistOwnerCap object`);
        }
        return AuthlistOwnerCap.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<AuthlistOwnerCap> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching AuthlistOwnerCap object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAuthlistOwnerCap(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a AuthlistOwnerCap object`);
        }

        return AuthlistOwnerCap.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== CollectionKey =============================== */

export function isCollectionKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::CollectionKey";
}

export interface CollectionKeyFields {
    typeName: ToField<TypeName>
}

export type CollectionKeyReified = Reified<
    CollectionKey,
    CollectionKeyFields
>;

export class CollectionKey implements StructClass {
    static readonly $typeName = "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::CollectionKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = CollectionKey.$typeName;

    readonly $fullTypeName: "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::CollectionKey";

    readonly $typeArgs: [];

    readonly typeName:
        ToField<TypeName>

    private constructor(typeArgs: [], fields: CollectionKeyFields,
    ) {
        this.$fullTypeName = composeSuiType(
            CollectionKey.$typeName,
            ...typeArgs
        ) as "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::CollectionKey";
        this.$typeArgs = typeArgs;

        this.typeName = fields.typeName;
    }

    static reified(): CollectionKeyReified {
        return {
            typeName: CollectionKey.$typeName,
            fullTypeName: composeSuiType(
                CollectionKey.$typeName,
                ...[]
            ) as "0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4::authlist::CollectionKey",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                CollectionKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                CollectionKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                CollectionKey.fromBcs(
                    data,
                ),
            bcs: CollectionKey.bcs,
            fromJSONField: (field: any) =>
                CollectionKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                CollectionKey.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                CollectionKey.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => CollectionKey.fetch(
                client,
                id,
            ),
            new: (
                fields: CollectionKeyFields,
            ) => {
                return new CollectionKey(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return CollectionKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<CollectionKey>> {
        return phantom(CollectionKey.reified());
    }

    static get p() {
        return CollectionKey.phantom()
    }

    static get bcs() {
        return bcs.struct("CollectionKey", {
            type_name:
                TypeName.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): CollectionKey {
        return CollectionKey.reified().new(
            {typeName: decodeFromFields(TypeName.reified(), fields.type_name)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): CollectionKey {
        if (!isCollectionKey(item.type)) {
            throw new Error("not a CollectionKey type");
        }

        return CollectionKey.reified().new(
            {typeName: decodeFromFieldsWithTypes(TypeName.reified(), item.fields.type_name)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): CollectionKey {

        return CollectionKey.fromFields(
            CollectionKey.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            typeName: this.typeName.toJSONField(),

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
    ): CollectionKey {
        return CollectionKey.reified().new(
            {typeName: decodeFromJSONField(TypeName.reified(), field.typeName)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): CollectionKey {
        if (json.$typeName !== CollectionKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return CollectionKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): CollectionKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isCollectionKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a CollectionKey object`);
        }
        return CollectionKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<CollectionKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching CollectionKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isCollectionKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a CollectionKey object`);
        }

        return CollectionKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
