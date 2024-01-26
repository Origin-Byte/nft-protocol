import {ID} from "../../_dependencies/source/0x2/object/structs";
import {VecSet} from "../../_dependencies/source/0x2/vec-set/structs";
import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list_domain::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list_domain::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list_domain::Witness";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: WitnessFields,
    ) {
        this.$fullTypeName = Witness.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): WitnessReified {
        return {
            typeName: Witness.$typeName,
            fullTypeName: composeSuiType(
                Witness.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list_domain::Witness",
            typeArgs: [],
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
            fetch: async (client: SuiClient, id: string) => Witness.fetch(
                client,
                id,
            ),
            new: (
                fields: WitnessFields,
            ) => {
                return new Witness(
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

/* ============================== P2PListDomain =============================== */

export function isP2PListDomain(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list_domain::P2PListDomain";
}

export interface P2PListDomainFields {
    lists: ToField<VecSet<ID>>
}

export type P2PListDomainReified = Reified<
    P2PListDomain,
    P2PListDomainFields
>;

export class P2PListDomain {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list_domain::P2PListDomain";
    static readonly $numTypeParams = 0;

    readonly $typeName = P2PListDomain.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list_domain::P2PListDomain";

    ;

    readonly lists:
        ToField<VecSet<ID>>

    private constructor( fields: P2PListDomainFields,
    ) {
        this.$fullTypeName = P2PListDomain.$typeName;

        this.lists = fields.lists;
    }

    static reified(): P2PListDomainReified {
        return {
            typeName: P2PListDomain.$typeName,
            fullTypeName: composeSuiType(
                P2PListDomain.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list_domain::P2PListDomain",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                P2PListDomain.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                P2PListDomain.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                P2PListDomain.fromBcs(
                    data,
                ),
            bcs: P2PListDomain.bcs,
            fromJSONField: (field: any) =>
                P2PListDomain.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                P2PListDomain.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => P2PListDomain.fetch(
                client,
                id,
            ),
            new: (
                fields: P2PListDomainFields,
            ) => {
                return new P2PListDomain(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return P2PListDomain.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<P2PListDomain>> {
        return phantom(P2PListDomain.reified());
    }

    static get p() {
        return P2PListDomain.phantom()
    }

    static get bcs() {
        return bcs.struct("P2PListDomain", {
            lists:
                VecSet.bcs(ID.bcs)

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): P2PListDomain {
        return P2PListDomain.reified().new(
            {lists: decodeFromFields(VecSet.reified(ID.reified()), fields.lists)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): P2PListDomain {
        if (!isP2PListDomain(item.type)) {
            throw new Error("not a P2PListDomain type");
        }

        return P2PListDomain.reified().new(
            {lists: decodeFromFieldsWithTypes(VecSet.reified(ID.reified()), item.fields.lists)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): P2PListDomain {

        return P2PListDomain.fromFields(
            P2PListDomain.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            lists: this.lists.toJSONField(),

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
    ): P2PListDomain {
        return P2PListDomain.reified().new(
            {lists: decodeFromJSONField(VecSet.reified(ID.reified()), field.lists)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): P2PListDomain {
        if (json.$typeName !== P2PListDomain.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return P2PListDomain.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): P2PListDomain {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isP2PListDomain(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a P2PListDomain object`);
        }
        return P2PListDomain.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<P2PListDomain> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching P2PListDomain object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isP2PListDomain(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a P2PListDomain object`);
        }

        return P2PListDomain.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
