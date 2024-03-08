import {ID} from "../../_dependencies/source/0x2/object/structs";
import {VecSet} from "../../_dependencies/source/0x2/vec-set/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_allowlist_domain::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_allowlist_domain::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_allowlist_domain::Witness";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: WitnessFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Witness.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_allowlist_domain::Witness";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): WitnessReified {
        return {
            typeName: Witness.$typeName,
            fullTypeName: composeSuiType(
                Witness.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_allowlist_domain::Witness",
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

/* ============================== TransferAllowlistDomain =============================== */

export function isTransferAllowlistDomain(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_allowlist_domain::TransferAllowlistDomain";
}

export interface TransferAllowlistDomainFields {
    allowlists: ToField<VecSet<ID>>
}

export type TransferAllowlistDomainReified = Reified<
    TransferAllowlistDomain,
    TransferAllowlistDomainFields
>;

export class TransferAllowlistDomain implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_allowlist_domain::TransferAllowlistDomain";
    static readonly $numTypeParams = 0;

    readonly $typeName = TransferAllowlistDomain.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_allowlist_domain::TransferAllowlistDomain";

    readonly $typeArgs: [];

    readonly allowlists:
        ToField<VecSet<ID>>

    private constructor(typeArgs: [], fields: TransferAllowlistDomainFields,
    ) {
        this.$fullTypeName = composeSuiType(
            TransferAllowlistDomain.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_allowlist_domain::TransferAllowlistDomain";
        this.$typeArgs = typeArgs;

        this.allowlists = fields.allowlists;
    }

    static reified(): TransferAllowlistDomainReified {
        return {
            typeName: TransferAllowlistDomain.$typeName,
            fullTypeName: composeSuiType(
                TransferAllowlistDomain.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_allowlist_domain::TransferAllowlistDomain",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                TransferAllowlistDomain.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                TransferAllowlistDomain.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                TransferAllowlistDomain.fromBcs(
                    data,
                ),
            bcs: TransferAllowlistDomain.bcs,
            fromJSONField: (field: any) =>
                TransferAllowlistDomain.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                TransferAllowlistDomain.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                TransferAllowlistDomain.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => TransferAllowlistDomain.fetch(
                client,
                id,
            ),
            new: (
                fields: TransferAllowlistDomainFields,
            ) => {
                return new TransferAllowlistDomain(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return TransferAllowlistDomain.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<TransferAllowlistDomain>> {
        return phantom(TransferAllowlistDomain.reified());
    }

    static get p() {
        return TransferAllowlistDomain.phantom()
    }

    static get bcs() {
        return bcs.struct("TransferAllowlistDomain", {
            allowlists:
                VecSet.bcs(ID.bcs)

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): TransferAllowlistDomain {
        return TransferAllowlistDomain.reified().new(
            {allowlists: decodeFromFields(VecSet.reified(ID.reified()), fields.allowlists)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): TransferAllowlistDomain {
        if (!isTransferAllowlistDomain(item.type)) {
            throw new Error("not a TransferAllowlistDomain type");
        }

        return TransferAllowlistDomain.reified().new(
            {allowlists: decodeFromFieldsWithTypes(VecSet.reified(ID.reified()), item.fields.allowlists)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): TransferAllowlistDomain {

        return TransferAllowlistDomain.fromFields(
            TransferAllowlistDomain.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            allowlists: this.allowlists.toJSONField(),

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
    ): TransferAllowlistDomain {
        return TransferAllowlistDomain.reified().new(
            {allowlists: decodeFromJSONField(VecSet.reified(ID.reified()), field.allowlists)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): TransferAllowlistDomain {
        if (json.$typeName !== TransferAllowlistDomain.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return TransferAllowlistDomain.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): TransferAllowlistDomain {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isTransferAllowlistDomain(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a TransferAllowlistDomain object`);
        }
        return TransferAllowlistDomain.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<TransferAllowlistDomain> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching TransferAllowlistDomain object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isTransferAllowlistDomain(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a TransferAllowlistDomain object`);
        }

        return TransferAllowlistDomain.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
