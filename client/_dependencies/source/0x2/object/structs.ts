import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

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

export class ID implements StructClass {
    static readonly $typeName = "0x2::object::ID";
    static readonly $numTypeParams = 0;

    readonly $typeName = ID.$typeName;

    readonly $fullTypeName: "0x2::object::ID";

    readonly $typeArgs: [];

    readonly bytes:
        ToField<"address">

    private constructor(typeArgs: [], fields: IDFields,
    ) {
        this.$fullTypeName = composeSuiType(
            ID.$typeName,
            ...typeArgs
        ) as "0x2::object::ID";
        this.$typeArgs = typeArgs;

        this.bytes = fields.bytes;
    }

    static reified(): IDReified {
        return {
            typeName: ID.$typeName,
            fullTypeName: composeSuiType(
                ID.$typeName,
                ...[]
            ) as "0x2::object::ID",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
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
            fromSuiParsedData: (content: SuiParsedData) =>
                ID.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => ID.fetch(
                client,
                id,
            ),
            new: (
                fields: IDFields,
            ) => {
                return new ID(
                    [],
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
            $typeArgs: this.$typeArgs,
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

export class UID implements StructClass {
    static readonly $typeName = "0x2::object::UID";
    static readonly $numTypeParams = 0;

    readonly $typeName = UID.$typeName;

    readonly $fullTypeName: "0x2::object::UID";

    readonly $typeArgs: [];

    readonly id:
        ToField<ID>

    private constructor(typeArgs: [], fields: UIDFields,
    ) {
        this.$fullTypeName = composeSuiType(
            UID.$typeName,
            ...typeArgs
        ) as "0x2::object::UID";
        this.$typeArgs = typeArgs;

        this.id = fields.id;
    }

    static reified(): UIDReified {
        return {
            typeName: UID.$typeName,
            fullTypeName: composeSuiType(
                UID.$typeName,
                ...[]
            ) as "0x2::object::UID",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
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
            fromSuiParsedData: (content: SuiParsedData) =>
                UID.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => UID.fetch(
                client,
                id,
            ),
            new: (
                fields: UIDFields,
            ) => {
                return new UID(
                    [],
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
            $typeArgs: this.$typeArgs,
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
