import * as reified from "../../../../_framework/reified";
import {PhantomReified, Reified, ToField, ToTypeArgument, ToTypeStr, TypeArgument, Vector, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom, toBcs} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {BcsType, bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== DynamicFields =============================== */

export function isDynamicFields(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::object::DynamicFields<");
}

export interface DynamicFieldsFields<K extends TypeArgument> {
    names: ToField<Vector<K>>
}

export type DynamicFieldsReified<K extends TypeArgument> = Reified<
    DynamicFields<K>,
    DynamicFieldsFields<K>
>;

export class DynamicFields<K extends TypeArgument> {
    static readonly $typeName = "0x2::object::DynamicFields";
    static readonly $numTypeParams = 1;

    readonly $typeName = DynamicFields.$typeName;

    readonly $fullTypeName: `0x2::object::DynamicFields<${ToTypeStr<K>}>`;

    readonly $typeArg: string;

    ;

    readonly names:
        ToField<Vector<K>>

    private constructor(typeArg: string, fields: DynamicFieldsFields<K>,
    ) {
        this.$fullTypeName = composeSuiType(DynamicFields.$typeName,
        typeArg) as `0x2::object::DynamicFields<${ToTypeStr<K>}>`;

        this.$typeArg = typeArg;

        this.names = fields.names;
    }

    static reified<K extends Reified<TypeArgument, any>>(
        K: K
    ): DynamicFieldsReified<ToTypeArgument<K>> {
        return {
            typeName: DynamicFields.$typeName,
            fullTypeName: composeSuiType(
                DynamicFields.$typeName,
                ...[extractType(K)]
            ) as `0x2::object::DynamicFields<${ToTypeStr<ToTypeArgument<K>>}>`,
            typeArgs: [K],
            fromFields: (fields: Record<string, any>) =>
                DynamicFields.fromFields(
                    K,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                DynamicFields.fromFieldsWithTypes(
                    K,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                DynamicFields.fromBcs(
                    K,
                    data,
                ),
            bcs: DynamicFields.bcs(toBcs(K)),
            fromJSONField: (field: any) =>
                DynamicFields.fromJSONField(
                    K,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                DynamicFields.fromJSON(
                    K,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => DynamicFields.fetch(
                client,
                K,
                id,
            ),
            new: (
                fields: DynamicFieldsFields<ToTypeArgument<K>>,
            ) => {
                return new DynamicFields(
                    extractType(K),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return DynamicFields.reified
    }

    static phantom<K extends Reified<TypeArgument, any>>(
        K: K
    ): PhantomReified<ToTypeStr<DynamicFields<ToTypeArgument<K>>>> {
        return phantom(DynamicFields.reified(
            K
        ));
    }

    static get p() {
        return DynamicFields.phantom
    }

    static get bcs() {
        return <K extends BcsType<any>>(K: K) => bcs.struct(`DynamicFields<${K.name}>`, {
            names:
                bcs.vector(K)

        })
    };

    static fromFields<K extends Reified<TypeArgument, any>>(
        typeArg: K, fields: Record<string, any>
    ): DynamicFields<ToTypeArgument<K>> {
        return DynamicFields.reified(
            typeArg,
        ).new(
            {names: decodeFromFields(reified.vector(typeArg), fields.names)}
        )
    }

    static fromFieldsWithTypes<K extends Reified<TypeArgument, any>>(
        typeArg: K, item: FieldsWithTypes
    ): DynamicFields<ToTypeArgument<K>> {
        if (!isDynamicFields(item.type)) {
            throw new Error("not a DynamicFields type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return DynamicFields.reified(
            typeArg,
        ).new(
            {names: decodeFromFieldsWithTypes(reified.vector(typeArg), item.fields.names)}
        )
    }

    static fromBcs<K extends Reified<TypeArgument, any>>(
        typeArg: K, data: Uint8Array
    ): DynamicFields<ToTypeArgument<K>> {
        const typeArgs = [typeArg];

        return DynamicFields.fromFields(
            typeArg,
            DynamicFields.bcs(toBcs(typeArgs[0])).parse(data)
        )
    }

    toJSONField() {
        return {
            names: fieldToJSON<Vector<K>>(`vector<${this.$typeArg}>`, this.names),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<K extends Reified<TypeArgument, any>>(
        typeArg: K, field: any
    ): DynamicFields<ToTypeArgument<K>> {
        return DynamicFields.reified(
            typeArg,
        ).new(
            {names: decodeFromJSONField(reified.vector(typeArg), field.names)}
        )
    }

    static fromJSON<K extends Reified<TypeArgument, any>>(
        typeArg: K, json: Record<string, any>
    ): DynamicFields<ToTypeArgument<K>> {
        if (json.$typeName !== DynamicFields.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(DynamicFields.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return DynamicFields.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<K extends Reified<TypeArgument, any>>(
        typeArg: K, content: SuiParsedData
    ): DynamicFields<ToTypeArgument<K>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isDynamicFields(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a DynamicFields object`);
        }
        return DynamicFields.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<K extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArg: K, id: string
    ): Promise<DynamicFields<ToTypeArgument<K>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching DynamicFields object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isDynamicFields(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a DynamicFields object`);
        }

        return DynamicFields.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== ID =============================== */

export function isID(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::object::ID";
}

export interface IDFields {
    bytes: ToField<"address">
}

export type IDReified = Reified<
    ID,
    IDFields
>;

export class ID {
    static readonly $typeName = "0x2::object::ID";
    static readonly $numTypeParams = 0;

    readonly $typeName = ID.$typeName;

    readonly $fullTypeName: "0x2::object::ID";

    ;

    readonly bytes:
        ToField<"address">

    private constructor( fields: IDFields,
    ) {
        this.$fullTypeName = ID.$typeName;

        this.bytes = fields.bytes;
    }

    static reified(): IDReified {
        return {
            typeName: ID.$typeName,
            fullTypeName: composeSuiType(
                ID.$typeName,
                ...[]
            ) as "0x2::object::ID",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                ID.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ID.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ID.fromBcs(
                    data,
                ),
            bcs: ID.bcs,
            fromJSONField: (field: any) =>
                ID.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ID.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => ID.fetch(
                client,
                id,
            ),
            new: (
                fields: IDFields,
            ) => {
                return new ID(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ID.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<ID>> {
        return phantom(ID.reified());
    }

    static get p() {
        return ID.phantom()
    }

    static get bcs() {
        return bcs.struct("ID", {
            bytes:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): ID {
        return ID.reified().new(
            {bytes: decodeFromFields("address", fields.bytes)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): ID {
        if (!isID(item.type)) {
            throw new Error("not a ID type");
        }

        return ID.reified().new(
            {bytes: decodeFromFieldsWithTypes("address", item.fields.bytes)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): ID {

        return ID.fromFields(
            ID.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            bytes: this.bytes,

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
    ): ID {
        return ID.reified().new(
            {bytes: decodeFromJSONField("address", field.bytes)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): ID {
        if (json.$typeName !== ID.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return ID.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): ID {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isID(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ID object`);
        }
        return ID.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<ID> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ID object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isID(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ID object`);
        }

        return ID.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Ownership =============================== */

export function isOwnership(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::object::Ownership";
}

export interface OwnershipFields {
    owner: ToField<"address">; status: ToField<"u64">
}

export type OwnershipReified = Reified<
    Ownership,
    OwnershipFields
>;

export class Ownership {
    static readonly $typeName = "0x2::object::Ownership";
    static readonly $numTypeParams = 0;

    readonly $typeName = Ownership.$typeName;

    readonly $fullTypeName: "0x2::object::Ownership";

    ;

    readonly owner:
        ToField<"address">
    ; readonly status:
        ToField<"u64">

    private constructor( fields: OwnershipFields,
    ) {
        this.$fullTypeName = Ownership.$typeName;

        this.owner = fields.owner;; this.status = fields.status;
    }

    static reified(): OwnershipReified {
        return {
            typeName: Ownership.$typeName,
            fullTypeName: composeSuiType(
                Ownership.$typeName,
                ...[]
            ) as "0x2::object::Ownership",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Ownership.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Ownership.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Ownership.fromBcs(
                    data,
                ),
            bcs: Ownership.bcs,
            fromJSONField: (field: any) =>
                Ownership.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Ownership.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Ownership.fetch(
                client,
                id,
            ),
            new: (
                fields: OwnershipFields,
            ) => {
                return new Ownership(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Ownership.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Ownership>> {
        return phantom(Ownership.reified());
    }

    static get p() {
        return Ownership.phantom()
    }

    static get bcs() {
        return bcs.struct("Ownership", {
            owner:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , status:
                bcs.u64()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Ownership {
        return Ownership.reified().new(
            {owner: decodeFromFields("address", fields.owner), status: decodeFromFields("u64", fields.status)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Ownership {
        if (!isOwnership(item.type)) {
            throw new Error("not a Ownership type");
        }

        return Ownership.reified().new(
            {owner: decodeFromFieldsWithTypes("address", item.fields.owner), status: decodeFromFieldsWithTypes("u64", item.fields.status)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Ownership {

        return Ownership.fromFields(
            Ownership.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            owner: this.owner,status: this.status.toString(),

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
    ): Ownership {
        return Ownership.reified().new(
            {owner: decodeFromJSONField("address", field.owner), status: decodeFromJSONField("u64", field.status)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Ownership {
        if (json.$typeName !== Ownership.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Ownership.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Ownership {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isOwnership(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Ownership object`);
        }
        return Ownership.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Ownership> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Ownership object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isOwnership(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Ownership object`);
        }

        return Ownership.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== UID =============================== */

export function isUID(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::object::UID";
}

export interface UIDFields {
    id: ToField<ID>
}

export type UIDReified = Reified<
    UID,
    UIDFields
>;

export class UID {
    static readonly $typeName = "0x2::object::UID";
    static readonly $numTypeParams = 0;

    readonly $typeName = UID.$typeName;

    readonly $fullTypeName: "0x2::object::UID";

    ;

    readonly id:
        ToField<ID>

    private constructor( fields: UIDFields,
    ) {
        this.$fullTypeName = UID.$typeName;

        this.id = fields.id;
    }

    static reified(): UIDReified {
        return {
            typeName: UID.$typeName,
            fullTypeName: composeSuiType(
                UID.$typeName,
                ...[]
            ) as "0x2::object::UID",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                UID.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                UID.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                UID.fromBcs(
                    data,
                ),
            bcs: UID.bcs,
            fromJSONField: (field: any) =>
                UID.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                UID.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => UID.fetch(
                client,
                id,
            ),
            new: (
                fields: UIDFields,
            ) => {
                return new UID(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return UID.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<UID>> {
        return phantom(UID.reified());
    }

    static get p() {
        return UID.phantom()
    }

    static get bcs() {
        return bcs.struct("UID", {
            id:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): UID {
        return UID.reified().new(
            {id: decodeFromFields(ID.reified(), fields.id)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): UID {
        if (!isUID(item.type)) {
            throw new Error("not a UID type");
        }

        return UID.reified().new(
            {id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): UID {

        return UID.fromFields(
            UID.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,

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
    ): UID {
        return UID.reified().new(
            {id: decodeFromJSONField(ID.reified(), field.id)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): UID {
        if (json.$typeName !== UID.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return UID.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): UID {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isUID(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a UID object`);
        }
        return UID.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<UID> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching UID object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isUID(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a UID object`);
        }

        return UID.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
