import * as reified from "../../_framework/reified";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, Vector, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {DynVec} from "../../utils/dynamic-vector/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== RedeemCommitment =============================== */

export function isRedeemCommitment(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::warehouse::RedeemCommitment";
}

export interface RedeemCommitmentFields {
    id: ToField<UID>; hashedSenderCommitment: ToField<Vector<"u8">>; contractCommitment: ToField<Vector<"u8">>
}

export type RedeemCommitmentReified = Reified<
    RedeemCommitment,
    RedeemCommitmentFields
>;

export class RedeemCommitment {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::warehouse::RedeemCommitment";
    static readonly $numTypeParams = 0;

    readonly $typeName = RedeemCommitment.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::warehouse::RedeemCommitment";

    ;

    readonly id:
        ToField<UID>
    ; readonly hashedSenderCommitment:
        ToField<Vector<"u8">>
    ; readonly contractCommitment:
        ToField<Vector<"u8">>

    private constructor( fields: RedeemCommitmentFields,
    ) {
        this.$fullTypeName = RedeemCommitment.$typeName;

        this.id = fields.id;; this.hashedSenderCommitment = fields.hashedSenderCommitment;; this.contractCommitment = fields.contractCommitment;
    }

    static reified(): RedeemCommitmentReified {
        return {
            typeName: RedeemCommitment.$typeName,
            fullTypeName: composeSuiType(
                RedeemCommitment.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::warehouse::RedeemCommitment",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                RedeemCommitment.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                RedeemCommitment.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                RedeemCommitment.fromBcs(
                    data,
                ),
            bcs: RedeemCommitment.bcs,
            fromJSONField: (field: any) =>
                RedeemCommitment.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                RedeemCommitment.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => RedeemCommitment.fetch(
                client,
                id,
            ),
            new: (
                fields: RedeemCommitmentFields,
            ) => {
                return new RedeemCommitment(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return RedeemCommitment.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<RedeemCommitment>> {
        return phantom(RedeemCommitment.reified());
    }

    static get p() {
        return RedeemCommitment.phantom()
    }

    static get bcs() {
        return bcs.struct("RedeemCommitment", {
            id:
                UID.bcs
            , hashed_sender_commitment:
                bcs.vector(bcs.u8())
            , contract_commitment:
                bcs.vector(bcs.u8())

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): RedeemCommitment {
        return RedeemCommitment.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), hashedSenderCommitment: decodeFromFields(reified.vector("u8"), fields.hashed_sender_commitment), contractCommitment: decodeFromFields(reified.vector("u8"), fields.contract_commitment)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): RedeemCommitment {
        if (!isRedeemCommitment(item.type)) {
            throw new Error("not a RedeemCommitment type");
        }

        return RedeemCommitment.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), hashedSenderCommitment: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.hashed_sender_commitment), contractCommitment: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.contract_commitment)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): RedeemCommitment {

        return RedeemCommitment.fromFields(
            RedeemCommitment.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,hashedSenderCommitment: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.hashedSenderCommitment),contractCommitment: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.contractCommitment),

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
    ): RedeemCommitment {
        return RedeemCommitment.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), hashedSenderCommitment: decodeFromJSONField(reified.vector("u8"), field.hashedSenderCommitment), contractCommitment: decodeFromJSONField(reified.vector("u8"), field.contractCommitment)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): RedeemCommitment {
        if (json.$typeName !== RedeemCommitment.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return RedeemCommitment.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): RedeemCommitment {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isRedeemCommitment(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a RedeemCommitment object`);
        }
        return RedeemCommitment.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<RedeemCommitment> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching RedeemCommitment object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isRedeemCommitment(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a RedeemCommitment object`);
        }

        return RedeemCommitment.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Warehouse =============================== */

export function isWarehouse(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::warehouse::Warehouse<");
}

export interface WarehouseFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; nfts: ToField<DynVec<ID>>; totalDeposited: ToField<"u64">
}

export type WarehouseReified<T extends PhantomTypeArgument> = Reified<
    Warehouse<T>,
    WarehouseFields<T>
>;

export class Warehouse<T extends PhantomTypeArgument> {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::warehouse::Warehouse";
    static readonly $numTypeParams = 1;

    readonly $typeName = Warehouse.$typeName;

    readonly $fullTypeName: `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::warehouse::Warehouse<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly nfts:
        ToField<DynVec<ID>>
    ; readonly totalDeposited:
        ToField<"u64">

    private constructor(typeArg: string, fields: WarehouseFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(Warehouse.$typeName,
        typeArg) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::warehouse::Warehouse<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.nfts = fields.nfts;; this.totalDeposited = fields.totalDeposited;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): WarehouseReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Warehouse.$typeName,
            fullTypeName: composeSuiType(
                Warehouse.$typeName,
                ...[extractType(T)]
            ) as `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::warehouse::Warehouse<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Warehouse.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Warehouse.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Warehouse.fromBcs(
                    T,
                    data,
                ),
            bcs: Warehouse.bcs,
            fromJSONField: (field: any) =>
                Warehouse.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Warehouse.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Warehouse.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: WarehouseFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Warehouse(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Warehouse.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Warehouse<ToPhantomTypeArgument<T>>>> {
        return phantom(Warehouse.reified(
            T
        ));
    }

    static get p() {
        return Warehouse.phantom
    }

    static get bcs() {
        return bcs.struct("Warehouse", {
            id:
                UID.bcs
            , nfts:
                DynVec.bcs(ID.bcs)
            , total_deposited:
                bcs.u64()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Warehouse<ToPhantomTypeArgument<T>> {
        return Warehouse.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), nfts: decodeFromFields(DynVec.reified(ID.reified()), fields.nfts), totalDeposited: decodeFromFields("u64", fields.total_deposited)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Warehouse<ToPhantomTypeArgument<T>> {
        if (!isWarehouse(item.type)) {
            throw new Error("not a Warehouse type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Warehouse.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), nfts: decodeFromFieldsWithTypes(DynVec.reified(ID.reified()), item.fields.nfts), totalDeposited: decodeFromFieldsWithTypes("u64", item.fields.total_deposited)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Warehouse<ToPhantomTypeArgument<T>> {

        return Warehouse.fromFields(
            typeArg,
            Warehouse.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,nfts: this.nfts.toJSONField(),totalDeposited: this.totalDeposited.toString(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): Warehouse<ToPhantomTypeArgument<T>> {
        return Warehouse.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), nfts: decodeFromJSONField(DynVec.reified(ID.reified()), field.nfts), totalDeposited: decodeFromJSONField("u64", field.totalDeposited)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Warehouse<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Warehouse.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Warehouse.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Warehouse.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Warehouse<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWarehouse(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Warehouse object`);
        }
        return Warehouse.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Warehouse<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Warehouse object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWarehouse(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Warehouse object`);
        }

        return Warehouse.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
