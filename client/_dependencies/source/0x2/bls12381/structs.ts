import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== G1 =============================== */

export function isG1(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::bls12381::G1";
}

export interface G1Fields {
    dummyField: ToField<"bool">
}

export type G1Reified = Reified<
    G1,
    G1Fields
>;

export class G1 implements StructClass {
    static readonly $typeName = "0x2::bls12381::G1";
    static readonly $numTypeParams = 0;

    readonly $typeName = G1.$typeName;

    readonly $fullTypeName: "0x2::bls12381::G1";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: G1Fields,
    ) {
        this.$fullTypeName = composeSuiType(
            G1.$typeName,
            ...typeArgs
        ) as "0x2::bls12381::G1";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): G1Reified {
        return {
            typeName: G1.$typeName,
            fullTypeName: composeSuiType(
                G1.$typeName,
                ...[]
            ) as "0x2::bls12381::G1",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                G1.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                G1.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                G1.fromBcs(
                    data,
                ),
            bcs: G1.bcs,
            fromJSONField: (field: any) =>
                G1.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                G1.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                G1.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => G1.fetch(
                client,
                id,
            ),
            new: (
                fields: G1Fields,
            ) => {
                return new G1(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return G1.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<G1>> {
        return phantom(G1.reified());
    }

    static get p() {
        return G1.phantom()
    }

    static get bcs() {
        return bcs.struct("G1", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): G1 {
        return G1.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): G1 {
        if (!isG1(item.type)) {
            throw new Error("not a G1 type");
        }

        return G1.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): G1 {

        return G1.fromFields(
            G1.bcs.parse(data)
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
    ): G1 {
        return G1.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): G1 {
        if (json.$typeName !== G1.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return G1.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): G1 {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isG1(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a G1 object`);
        }
        return G1.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<G1> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching G1 object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isG1(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a G1 object`);
        }

        return G1.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== G2 =============================== */

export function isG2(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::bls12381::G2";
}

export interface G2Fields {
    dummyField: ToField<"bool">
}

export type G2Reified = Reified<
    G2,
    G2Fields
>;

export class G2 implements StructClass {
    static readonly $typeName = "0x2::bls12381::G2";
    static readonly $numTypeParams = 0;

    readonly $typeName = G2.$typeName;

    readonly $fullTypeName: "0x2::bls12381::G2";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: G2Fields,
    ) {
        this.$fullTypeName = composeSuiType(
            G2.$typeName,
            ...typeArgs
        ) as "0x2::bls12381::G2";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): G2Reified {
        return {
            typeName: G2.$typeName,
            fullTypeName: composeSuiType(
                G2.$typeName,
                ...[]
            ) as "0x2::bls12381::G2",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                G2.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                G2.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                G2.fromBcs(
                    data,
                ),
            bcs: G2.bcs,
            fromJSONField: (field: any) =>
                G2.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                G2.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                G2.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => G2.fetch(
                client,
                id,
            ),
            new: (
                fields: G2Fields,
            ) => {
                return new G2(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return G2.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<G2>> {
        return phantom(G2.reified());
    }

    static get p() {
        return G2.phantom()
    }

    static get bcs() {
        return bcs.struct("G2", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): G2 {
        return G2.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): G2 {
        if (!isG2(item.type)) {
            throw new Error("not a G2 type");
        }

        return G2.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): G2 {

        return G2.fromFields(
            G2.bcs.parse(data)
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
    ): G2 {
        return G2.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): G2 {
        if (json.$typeName !== G2.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return G2.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): G2 {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isG2(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a G2 object`);
        }
        return G2.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<G2> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching G2 object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isG2(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a G2 object`);
        }

        return G2.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== GT =============================== */

export function isGT(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::bls12381::GT";
}

export interface GTFields {
    dummyField: ToField<"bool">
}

export type GTReified = Reified<
    GT,
    GTFields
>;

export class GT implements StructClass {
    static readonly $typeName = "0x2::bls12381::GT";
    static readonly $numTypeParams = 0;

    readonly $typeName = GT.$typeName;

    readonly $fullTypeName: "0x2::bls12381::GT";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: GTFields,
    ) {
        this.$fullTypeName = composeSuiType(
            GT.$typeName,
            ...typeArgs
        ) as "0x2::bls12381::GT";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): GTReified {
        return {
            typeName: GT.$typeName,
            fullTypeName: composeSuiType(
                GT.$typeName,
                ...[]
            ) as "0x2::bls12381::GT",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                GT.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                GT.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                GT.fromBcs(
                    data,
                ),
            bcs: GT.bcs,
            fromJSONField: (field: any) =>
                GT.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                GT.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                GT.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => GT.fetch(
                client,
                id,
            ),
            new: (
                fields: GTFields,
            ) => {
                return new GT(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return GT.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<GT>> {
        return phantom(GT.reified());
    }

    static get p() {
        return GT.phantom()
    }

    static get bcs() {
        return bcs.struct("GT", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): GT {
        return GT.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): GT {
        if (!isGT(item.type)) {
            throw new Error("not a GT type");
        }

        return GT.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): GT {

        return GT.fromFields(
            GT.bcs.parse(data)
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
    ): GT {
        return GT.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): GT {
        if (json.$typeName !== GT.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return GT.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): GT {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isGT(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a GT object`);
        }
        return GT.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<GT> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching GT object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isGT(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a GT object`);
        }

        return GT.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Scalar =============================== */

export function isScalar(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::bls12381::Scalar";
}

export interface ScalarFields {
    dummyField: ToField<"bool">
}

export type ScalarReified = Reified<
    Scalar,
    ScalarFields
>;

export class Scalar implements StructClass {
    static readonly $typeName = "0x2::bls12381::Scalar";
    static readonly $numTypeParams = 0;

    readonly $typeName = Scalar.$typeName;

    readonly $fullTypeName: "0x2::bls12381::Scalar";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: ScalarFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Scalar.$typeName,
            ...typeArgs
        ) as "0x2::bls12381::Scalar";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): ScalarReified {
        return {
            typeName: Scalar.$typeName,
            fullTypeName: composeSuiType(
                Scalar.$typeName,
                ...[]
            ) as "0x2::bls12381::Scalar",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Scalar.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Scalar.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Scalar.fromBcs(
                    data,
                ),
            bcs: Scalar.bcs,
            fromJSONField: (field: any) =>
                Scalar.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Scalar.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Scalar.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Scalar.fetch(
                client,
                id,
            ),
            new: (
                fields: ScalarFields,
            ) => {
                return new Scalar(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Scalar.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Scalar>> {
        return phantom(Scalar.reified());
    }

    static get p() {
        return Scalar.phantom()
    }

    static get bcs() {
        return bcs.struct("Scalar", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Scalar {
        return Scalar.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Scalar {
        if (!isScalar(item.type)) {
            throw new Error("not a Scalar type");
        }

        return Scalar.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Scalar {

        return Scalar.fromFields(
            Scalar.bcs.parse(data)
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
    ): Scalar {
        return Scalar.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Scalar {
        if (json.$typeName !== Scalar.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Scalar.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Scalar {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isScalar(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Scalar object`);
        }
        return Scalar.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Scalar> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Scalar object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isScalar(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Scalar object`);
        }

        return Scalar.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
