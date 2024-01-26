import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list::Witness";

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
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list::Witness",
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

/* ============================== P2PListRule =============================== */

export function isP2PListRule(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list::P2PListRule";
}

export interface P2PListRuleFields {
    dummyField: ToField<"bool">
}

export type P2PListRuleReified = Reified<
    P2PListRule,
    P2PListRuleFields
>;

export class P2PListRule {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list::P2PListRule";
    static readonly $numTypeParams = 0;

    readonly $typeName = P2PListRule.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list::P2PListRule";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: P2PListRuleFields,
    ) {
        this.$fullTypeName = P2PListRule.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): P2PListRuleReified {
        return {
            typeName: P2PListRule.$typeName,
            fullTypeName: composeSuiType(
                P2PListRule.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::p2p_list::P2PListRule",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                P2PListRule.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                P2PListRule.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                P2PListRule.fromBcs(
                    data,
                ),
            bcs: P2PListRule.bcs,
            fromJSONField: (field: any) =>
                P2PListRule.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                P2PListRule.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => P2PListRule.fetch(
                client,
                id,
            ),
            new: (
                fields: P2PListRuleFields,
            ) => {
                return new P2PListRule(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return P2PListRule.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<P2PListRule>> {
        return phantom(P2PListRule.reified());
    }

    static get p() {
        return P2PListRule.phantom()
    }

    static get bcs() {
        return bcs.struct("P2PListRule", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): P2PListRule {
        return P2PListRule.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): P2PListRule {
        if (!isP2PListRule(item.type)) {
            throw new Error("not a P2PListRule type");
        }

        return P2PListRule.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): P2PListRule {

        return P2PListRule.fromFields(
            P2PListRule.bcs.parse(data)
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
    ): P2PListRule {
        return P2PListRule.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): P2PListRule {
        if (json.$typeName !== P2PListRule.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return P2PListRule.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): P2PListRule {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isP2PListRule(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a P2PListRule object`);
        }
        return P2PListRule.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<P2PListRule> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching P2PListRule object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isP2PListRule(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a P2PListRule object`);
        }

        return P2PListRule.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
