import * as reified from "../../../../_framework/reified";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, Vector, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, fieldToJSON, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Curve =============================== */

export function isCurve(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::groth16::Curve";
}

export interface CurveFields {
    id: ToField<"u8">
}

export type CurveReified = Reified<
    Curve,
    CurveFields
>;

export class Curve implements StructClass {
    static readonly $typeName = "0x2::groth16::Curve";
    static readonly $numTypeParams = 0;

    readonly $typeName = Curve.$typeName;

    readonly $fullTypeName: "0x2::groth16::Curve";

    readonly $typeArgs: [];

    readonly id:
        ToField<"u8">

    private constructor(typeArgs: [], fields: CurveFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Curve.$typeName,
            ...typeArgs
        ) as "0x2::groth16::Curve";
        this.$typeArgs = typeArgs;

        this.id = fields.id;
    }

    static reified(): CurveReified {
        return {
            typeName: Curve.$typeName,
            fullTypeName: composeSuiType(
                Curve.$typeName,
                ...[]
            ) as "0x2::groth16::Curve",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Curve.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Curve.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Curve.fromBcs(
                    data,
                ),
            bcs: Curve.bcs,
            fromJSONField: (field: any) =>
                Curve.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Curve.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Curve.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Curve.fetch(
                client,
                id,
            ),
            new: (
                fields: CurveFields,
            ) => {
                return new Curve(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Curve.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Curve>> {
        return phantom(Curve.reified());
    }

    static get p() {
        return Curve.phantom()
    }

    static get bcs() {
        return bcs.struct("Curve", {
            id:
                bcs.u8()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Curve {
        return Curve.reified().new(
            {id: decodeFromFields("u8", fields.id)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Curve {
        if (!isCurve(item.type)) {
            throw new Error("not a Curve type");
        }

        return Curve.reified().new(
            {id: decodeFromFieldsWithTypes("u8", item.fields.id)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Curve {

        return Curve.fromFields(
            Curve.bcs.parse(data)
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
    ): Curve {
        return Curve.reified().new(
            {id: decodeFromJSONField("u8", field.id)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Curve {
        if (json.$typeName !== Curve.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Curve.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Curve {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isCurve(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Curve object`);
        }
        return Curve.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Curve> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Curve object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isCurve(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Curve object`);
        }

        return Curve.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== PreparedVerifyingKey =============================== */

export function isPreparedVerifyingKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::groth16::PreparedVerifyingKey";
}

export interface PreparedVerifyingKeyFields {
    vkGammaAbcG1Bytes: ToField<Vector<"u8">>; alphaG1BetaG2Bytes: ToField<Vector<"u8">>; gammaG2NegPcBytes: ToField<Vector<"u8">>; deltaG2NegPcBytes: ToField<Vector<"u8">>
}

export type PreparedVerifyingKeyReified = Reified<
    PreparedVerifyingKey,
    PreparedVerifyingKeyFields
>;

export class PreparedVerifyingKey implements StructClass {
    static readonly $typeName = "0x2::groth16::PreparedVerifyingKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = PreparedVerifyingKey.$typeName;

    readonly $fullTypeName: "0x2::groth16::PreparedVerifyingKey";

    readonly $typeArgs: [];

    readonly vkGammaAbcG1Bytes:
        ToField<Vector<"u8">>
    ; readonly alphaG1BetaG2Bytes:
        ToField<Vector<"u8">>
    ; readonly gammaG2NegPcBytes:
        ToField<Vector<"u8">>
    ; readonly deltaG2NegPcBytes:
        ToField<Vector<"u8">>

    private constructor(typeArgs: [], fields: PreparedVerifyingKeyFields,
    ) {
        this.$fullTypeName = composeSuiType(
            PreparedVerifyingKey.$typeName,
            ...typeArgs
        ) as "0x2::groth16::PreparedVerifyingKey";
        this.$typeArgs = typeArgs;

        this.vkGammaAbcG1Bytes = fields.vkGammaAbcG1Bytes;; this.alphaG1BetaG2Bytes = fields.alphaG1BetaG2Bytes;; this.gammaG2NegPcBytes = fields.gammaG2NegPcBytes;; this.deltaG2NegPcBytes = fields.deltaG2NegPcBytes;
    }

    static reified(): PreparedVerifyingKeyReified {
        return {
            typeName: PreparedVerifyingKey.$typeName,
            fullTypeName: composeSuiType(
                PreparedVerifyingKey.$typeName,
                ...[]
            ) as "0x2::groth16::PreparedVerifyingKey",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                PreparedVerifyingKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                PreparedVerifyingKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                PreparedVerifyingKey.fromBcs(
                    data,
                ),
            bcs: PreparedVerifyingKey.bcs,
            fromJSONField: (field: any) =>
                PreparedVerifyingKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                PreparedVerifyingKey.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                PreparedVerifyingKey.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => PreparedVerifyingKey.fetch(
                client,
                id,
            ),
            new: (
                fields: PreparedVerifyingKeyFields,
            ) => {
                return new PreparedVerifyingKey(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return PreparedVerifyingKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<PreparedVerifyingKey>> {
        return phantom(PreparedVerifyingKey.reified());
    }

    static get p() {
        return PreparedVerifyingKey.phantom()
    }

    static get bcs() {
        return bcs.struct("PreparedVerifyingKey", {
            vk_gamma_abc_g1_bytes:
                bcs.vector(bcs.u8())
            , alpha_g1_beta_g2_bytes:
                bcs.vector(bcs.u8())
            , gamma_g2_neg_pc_bytes:
                bcs.vector(bcs.u8())
            , delta_g2_neg_pc_bytes:
                bcs.vector(bcs.u8())

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): PreparedVerifyingKey {
        return PreparedVerifyingKey.reified().new(
            {vkGammaAbcG1Bytes: decodeFromFields(reified.vector("u8"), fields.vk_gamma_abc_g1_bytes), alphaG1BetaG2Bytes: decodeFromFields(reified.vector("u8"), fields.alpha_g1_beta_g2_bytes), gammaG2NegPcBytes: decodeFromFields(reified.vector("u8"), fields.gamma_g2_neg_pc_bytes), deltaG2NegPcBytes: decodeFromFields(reified.vector("u8"), fields.delta_g2_neg_pc_bytes)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): PreparedVerifyingKey {
        if (!isPreparedVerifyingKey(item.type)) {
            throw new Error("not a PreparedVerifyingKey type");
        }

        return PreparedVerifyingKey.reified().new(
            {vkGammaAbcG1Bytes: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.vk_gamma_abc_g1_bytes), alphaG1BetaG2Bytes: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.alpha_g1_beta_g2_bytes), gammaG2NegPcBytes: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.gamma_g2_neg_pc_bytes), deltaG2NegPcBytes: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.delta_g2_neg_pc_bytes)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): PreparedVerifyingKey {

        return PreparedVerifyingKey.fromFields(
            PreparedVerifyingKey.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            vkGammaAbcG1Bytes: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.vkGammaAbcG1Bytes),alphaG1BetaG2Bytes: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.alphaG1BetaG2Bytes),gammaG2NegPcBytes: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.gammaG2NegPcBytes),deltaG2NegPcBytes: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.deltaG2NegPcBytes),

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
    ): PreparedVerifyingKey {
        return PreparedVerifyingKey.reified().new(
            {vkGammaAbcG1Bytes: decodeFromJSONField(reified.vector("u8"), field.vkGammaAbcG1Bytes), alphaG1BetaG2Bytes: decodeFromJSONField(reified.vector("u8"), field.alphaG1BetaG2Bytes), gammaG2NegPcBytes: decodeFromJSONField(reified.vector("u8"), field.gammaG2NegPcBytes), deltaG2NegPcBytes: decodeFromJSONField(reified.vector("u8"), field.deltaG2NegPcBytes)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): PreparedVerifyingKey {
        if (json.$typeName !== PreparedVerifyingKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return PreparedVerifyingKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): PreparedVerifyingKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isPreparedVerifyingKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a PreparedVerifyingKey object`);
        }
        return PreparedVerifyingKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<PreparedVerifyingKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching PreparedVerifyingKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isPreparedVerifyingKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a PreparedVerifyingKey object`);
        }

        return PreparedVerifyingKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== ProofPoints =============================== */

export function isProofPoints(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::groth16::ProofPoints";
}

export interface ProofPointsFields {
    bytes: ToField<Vector<"u8">>
}

export type ProofPointsReified = Reified<
    ProofPoints,
    ProofPointsFields
>;

export class ProofPoints implements StructClass {
    static readonly $typeName = "0x2::groth16::ProofPoints";
    static readonly $numTypeParams = 0;

    readonly $typeName = ProofPoints.$typeName;

    readonly $fullTypeName: "0x2::groth16::ProofPoints";

    readonly $typeArgs: [];

    readonly bytes:
        ToField<Vector<"u8">>

    private constructor(typeArgs: [], fields: ProofPointsFields,
    ) {
        this.$fullTypeName = composeSuiType(
            ProofPoints.$typeName,
            ...typeArgs
        ) as "0x2::groth16::ProofPoints";
        this.$typeArgs = typeArgs;

        this.bytes = fields.bytes;
    }

    static reified(): ProofPointsReified {
        return {
            typeName: ProofPoints.$typeName,
            fullTypeName: composeSuiType(
                ProofPoints.$typeName,
                ...[]
            ) as "0x2::groth16::ProofPoints",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                ProofPoints.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ProofPoints.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ProofPoints.fromBcs(
                    data,
                ),
            bcs: ProofPoints.bcs,
            fromJSONField: (field: any) =>
                ProofPoints.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ProofPoints.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                ProofPoints.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => ProofPoints.fetch(
                client,
                id,
            ),
            new: (
                fields: ProofPointsFields,
            ) => {
                return new ProofPoints(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ProofPoints.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<ProofPoints>> {
        return phantom(ProofPoints.reified());
    }

    static get p() {
        return ProofPoints.phantom()
    }

    static get bcs() {
        return bcs.struct("ProofPoints", {
            bytes:
                bcs.vector(bcs.u8())

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): ProofPoints {
        return ProofPoints.reified().new(
            {bytes: decodeFromFields(reified.vector("u8"), fields.bytes)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): ProofPoints {
        if (!isProofPoints(item.type)) {
            throw new Error("not a ProofPoints type");
        }

        return ProofPoints.reified().new(
            {bytes: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.bytes)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): ProofPoints {

        return ProofPoints.fromFields(
            ProofPoints.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            bytes: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.bytes),

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
    ): ProofPoints {
        return ProofPoints.reified().new(
            {bytes: decodeFromJSONField(reified.vector("u8"), field.bytes)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): ProofPoints {
        if (json.$typeName !== ProofPoints.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return ProofPoints.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): ProofPoints {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isProofPoints(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ProofPoints object`);
        }
        return ProofPoints.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<ProofPoints> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ProofPoints object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isProofPoints(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ProofPoints object`);
        }

        return ProofPoints.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== PublicProofInputs =============================== */

export function isPublicProofInputs(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::groth16::PublicProofInputs";
}

export interface PublicProofInputsFields {
    bytes: ToField<Vector<"u8">>
}

export type PublicProofInputsReified = Reified<
    PublicProofInputs,
    PublicProofInputsFields
>;

export class PublicProofInputs implements StructClass {
    static readonly $typeName = "0x2::groth16::PublicProofInputs";
    static readonly $numTypeParams = 0;

    readonly $typeName = PublicProofInputs.$typeName;

    readonly $fullTypeName: "0x2::groth16::PublicProofInputs";

    readonly $typeArgs: [];

    readonly bytes:
        ToField<Vector<"u8">>

    private constructor(typeArgs: [], fields: PublicProofInputsFields,
    ) {
        this.$fullTypeName = composeSuiType(
            PublicProofInputs.$typeName,
            ...typeArgs
        ) as "0x2::groth16::PublicProofInputs";
        this.$typeArgs = typeArgs;

        this.bytes = fields.bytes;
    }

    static reified(): PublicProofInputsReified {
        return {
            typeName: PublicProofInputs.$typeName,
            fullTypeName: composeSuiType(
                PublicProofInputs.$typeName,
                ...[]
            ) as "0x2::groth16::PublicProofInputs",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                PublicProofInputs.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                PublicProofInputs.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                PublicProofInputs.fromBcs(
                    data,
                ),
            bcs: PublicProofInputs.bcs,
            fromJSONField: (field: any) =>
                PublicProofInputs.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                PublicProofInputs.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                PublicProofInputs.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => PublicProofInputs.fetch(
                client,
                id,
            ),
            new: (
                fields: PublicProofInputsFields,
            ) => {
                return new PublicProofInputs(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return PublicProofInputs.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<PublicProofInputs>> {
        return phantom(PublicProofInputs.reified());
    }

    static get p() {
        return PublicProofInputs.phantom()
    }

    static get bcs() {
        return bcs.struct("PublicProofInputs", {
            bytes:
                bcs.vector(bcs.u8())

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): PublicProofInputs {
        return PublicProofInputs.reified().new(
            {bytes: decodeFromFields(reified.vector("u8"), fields.bytes)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): PublicProofInputs {
        if (!isPublicProofInputs(item.type)) {
            throw new Error("not a PublicProofInputs type");
        }

        return PublicProofInputs.reified().new(
            {bytes: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.bytes)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): PublicProofInputs {

        return PublicProofInputs.fromFields(
            PublicProofInputs.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            bytes: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.bytes),

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
    ): PublicProofInputs {
        return PublicProofInputs.reified().new(
            {bytes: decodeFromJSONField(reified.vector("u8"), field.bytes)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): PublicProofInputs {
        if (json.$typeName !== PublicProofInputs.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return PublicProofInputs.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): PublicProofInputs {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isPublicProofInputs(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a PublicProofInputs object`);
        }
        return PublicProofInputs.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<PublicProofInputs> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching PublicProofInputs object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isPublicProofInputs(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a PublicProofInputs object`);
        }

        return PublicProofInputs.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
