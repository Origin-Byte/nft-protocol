import {Option} from "../../_dependencies/source/0x1/option/structs";
import {TypeName} from "../../_dependencies/source/0x1/type-name/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {VecSet} from "../../_dependencies/source/0x2/vec-set/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, fieldToJSON, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== CollectionKey =============================== */

export function isCollectionKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::CollectionKey";
}

export interface CollectionKeyFields {
    typeName: ToField<TypeName>
}

export type CollectionKeyReified = Reified<
    CollectionKey,
    CollectionKeyFields
>;

export class CollectionKey implements StructClass {
    static readonly $typeName = "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::CollectionKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = CollectionKey.$typeName;

    readonly $fullTypeName: "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::CollectionKey";

    readonly $typeArgs: [];

    readonly typeName:
        ToField<TypeName>

    private constructor(typeArgs: [], fields: CollectionKeyFields,
    ) {
        this.$fullTypeName = composeSuiType(
            CollectionKey.$typeName,
            ...typeArgs
        ) as "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::CollectionKey";
        this.$typeArgs = typeArgs;

        this.typeName = fields.typeName;
    }

    static reified(): CollectionKeyReified {
        return {
            typeName: CollectionKey.$typeName,
            fullTypeName: composeSuiType(
                CollectionKey.$typeName,
                ...[]
            ) as "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::CollectionKey",
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

/* ============================== ALLOWLIST =============================== */

export function isALLOWLIST(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::ALLOWLIST";
}

export interface ALLOWLISTFields {
    dummyField: ToField<"bool">
}

export type ALLOWLISTReified = Reified<
    ALLOWLIST,
    ALLOWLISTFields
>;

export class ALLOWLIST implements StructClass {
    static readonly $typeName = "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::ALLOWLIST";
    static readonly $numTypeParams = 0;

    readonly $typeName = ALLOWLIST.$typeName;

    readonly $fullTypeName: "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::ALLOWLIST";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: ALLOWLISTFields,
    ) {
        this.$fullTypeName = composeSuiType(
            ALLOWLIST.$typeName,
            ...typeArgs
        ) as "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::ALLOWLIST";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): ALLOWLISTReified {
        return {
            typeName: ALLOWLIST.$typeName,
            fullTypeName: composeSuiType(
                ALLOWLIST.$typeName,
                ...[]
            ) as "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::ALLOWLIST",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                ALLOWLIST.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ALLOWLIST.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ALLOWLIST.fromBcs(
                    data,
                ),
            bcs: ALLOWLIST.bcs,
            fromJSONField: (field: any) =>
                ALLOWLIST.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ALLOWLIST.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                ALLOWLIST.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => ALLOWLIST.fetch(
                client,
                id,
            ),
            new: (
                fields: ALLOWLISTFields,
            ) => {
                return new ALLOWLIST(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ALLOWLIST.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<ALLOWLIST>> {
        return phantom(ALLOWLIST.reified());
    }

    static get p() {
        return ALLOWLIST.phantom()
    }

    static get bcs() {
        return bcs.struct("ALLOWLIST", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): ALLOWLIST {
        return ALLOWLIST.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): ALLOWLIST {
        if (!isALLOWLIST(item.type)) {
            throw new Error("not a ALLOWLIST type");
        }

        return ALLOWLIST.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): ALLOWLIST {

        return ALLOWLIST.fromFields(
            ALLOWLIST.bcs.parse(data)
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
    ): ALLOWLIST {
        return ALLOWLIST.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): ALLOWLIST {
        if (json.$typeName !== ALLOWLIST.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return ALLOWLIST.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): ALLOWLIST {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isALLOWLIST(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ALLOWLIST object`);
        }
        return ALLOWLIST.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<ALLOWLIST> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ALLOWLIST object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isALLOWLIST(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ALLOWLIST object`);
        }

        return ALLOWLIST.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Allowlist =============================== */

export function isAllowlist(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::Allowlist";
}

export interface AllowlistFields {
    id: ToField<UID>; version: ToField<"u64">; adminWitness: ToField<Option<TypeName>>; authorities: ToField<VecSet<TypeName>>
}

export type AllowlistReified = Reified<
    Allowlist,
    AllowlistFields
>;

export class Allowlist implements StructClass {
    static readonly $typeName = "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::Allowlist";
    static readonly $numTypeParams = 0;

    readonly $typeName = Allowlist.$typeName;

    readonly $fullTypeName: "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::Allowlist";

    readonly $typeArgs: [];

    readonly id:
        ToField<UID>
    ; readonly version:
        ToField<"u64">
    ; readonly adminWitness:
        ToField<Option<TypeName>>
    ; readonly authorities:
        ToField<VecSet<TypeName>>

    private constructor(typeArgs: [], fields: AllowlistFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Allowlist.$typeName,
            ...typeArgs
        ) as "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::Allowlist";
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.version = fields.version;; this.adminWitness = fields.adminWitness;; this.authorities = fields.authorities;
    }

    static reified(): AllowlistReified {
        return {
            typeName: Allowlist.$typeName,
            fullTypeName: composeSuiType(
                Allowlist.$typeName,
                ...[]
            ) as "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::Allowlist",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Allowlist.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Allowlist.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Allowlist.fromBcs(
                    data,
                ),
            bcs: Allowlist.bcs,
            fromJSONField: (field: any) =>
                Allowlist.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Allowlist.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Allowlist.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Allowlist.fetch(
                client,
                id,
            ),
            new: (
                fields: AllowlistFields,
            ) => {
                return new Allowlist(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Allowlist.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Allowlist>> {
        return phantom(Allowlist.reified());
    }

    static get p() {
        return Allowlist.phantom()
    }

    static get bcs() {
        return bcs.struct("Allowlist", {
            id:
                UID.bcs
            , version:
                bcs.u64()
            , admin_witness:
                Option.bcs(TypeName.bcs)
            , authorities:
                VecSet.bcs(TypeName.bcs)

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Allowlist {
        return Allowlist.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), version: decodeFromFields("u64", fields.version), adminWitness: decodeFromFields(Option.reified(TypeName.reified()), fields.admin_witness), authorities: decodeFromFields(VecSet.reified(TypeName.reified()), fields.authorities)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Allowlist {
        if (!isAllowlist(item.type)) {
            throw new Error("not a Allowlist type");
        }

        return Allowlist.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), version: decodeFromFieldsWithTypes("u64", item.fields.version), adminWitness: decodeFromFieldsWithTypes(Option.reified(TypeName.reified()), item.fields.admin_witness), authorities: decodeFromFieldsWithTypes(VecSet.reified(TypeName.reified()), item.fields.authorities)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Allowlist {

        return Allowlist.fromFields(
            Allowlist.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,version: this.version.toString(),adminWitness: fieldToJSON<Option<TypeName>>(`0x1::option::Option<0x1::type_name::TypeName>`, this.adminWitness),authorities: this.authorities.toJSONField(),

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
    ): Allowlist {
        return Allowlist.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), version: decodeFromJSONField("u64", field.version), adminWitness: decodeFromJSONField(Option.reified(TypeName.reified()), field.adminWitness), authorities: decodeFromJSONField(VecSet.reified(TypeName.reified()), field.authorities)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Allowlist {
        if (json.$typeName !== Allowlist.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Allowlist.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Allowlist {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAllowlist(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Allowlist object`);
        }
        return Allowlist.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Allowlist> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Allowlist object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAllowlist(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Allowlist object`);
        }

        return Allowlist.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== AllowlistOwnerCap =============================== */

export function isAllowlistOwnerCap(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::AllowlistOwnerCap";
}

export interface AllowlistOwnerCapFields {
    id: ToField<UID>; for: ToField<ID>
}

export type AllowlistOwnerCapReified = Reified<
    AllowlistOwnerCap,
    AllowlistOwnerCapFields
>;

export class AllowlistOwnerCap implements StructClass {
    static readonly $typeName = "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::AllowlistOwnerCap";
    static readonly $numTypeParams = 0;

    readonly $typeName = AllowlistOwnerCap.$typeName;

    readonly $fullTypeName: "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::AllowlistOwnerCap";

    readonly $typeArgs: [];

    readonly id:
        ToField<UID>
    ; readonly for:
        ToField<ID>

    private constructor(typeArgs: [], fields: AllowlistOwnerCapFields,
    ) {
        this.$fullTypeName = composeSuiType(
            AllowlistOwnerCap.$typeName,
            ...typeArgs
        ) as "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::AllowlistOwnerCap";
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.for = fields.for;
    }

    static reified(): AllowlistOwnerCapReified {
        return {
            typeName: AllowlistOwnerCap.$typeName,
            fullTypeName: composeSuiType(
                AllowlistOwnerCap.$typeName,
                ...[]
            ) as "0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa::allowlist::AllowlistOwnerCap",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                AllowlistOwnerCap.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                AllowlistOwnerCap.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                AllowlistOwnerCap.fromBcs(
                    data,
                ),
            bcs: AllowlistOwnerCap.bcs,
            fromJSONField: (field: any) =>
                AllowlistOwnerCap.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                AllowlistOwnerCap.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                AllowlistOwnerCap.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => AllowlistOwnerCap.fetch(
                client,
                id,
            ),
            new: (
                fields: AllowlistOwnerCapFields,
            ) => {
                return new AllowlistOwnerCap(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return AllowlistOwnerCap.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<AllowlistOwnerCap>> {
        return phantom(AllowlistOwnerCap.reified());
    }

    static get p() {
        return AllowlistOwnerCap.phantom()
    }

    static get bcs() {
        return bcs.struct("AllowlistOwnerCap", {
            id:
                UID.bcs
            , for:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): AllowlistOwnerCap {
        return AllowlistOwnerCap.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), for: decodeFromFields(ID.reified(), fields.for)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): AllowlistOwnerCap {
        if (!isAllowlistOwnerCap(item.type)) {
            throw new Error("not a AllowlistOwnerCap type");
        }

        return AllowlistOwnerCap.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), for: decodeFromFieldsWithTypes(ID.reified(), item.fields.for)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): AllowlistOwnerCap {

        return AllowlistOwnerCap.fromFields(
            AllowlistOwnerCap.bcs.parse(data)
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
    ): AllowlistOwnerCap {
        return AllowlistOwnerCap.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), for: decodeFromJSONField(ID.reified(), field.for)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): AllowlistOwnerCap {
        if (json.$typeName !== AllowlistOwnerCap.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return AllowlistOwnerCap.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): AllowlistOwnerCap {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAllowlistOwnerCap(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a AllowlistOwnerCap object`);
        }
        return AllowlistOwnerCap.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<AllowlistOwnerCap> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching AllowlistOwnerCap object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAllowlistOwnerCap(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a AllowlistOwnerCap object`);
        }

        return AllowlistOwnerCap.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
