import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== AllowlistRule =============================== */

export function isAllowlistRule(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_allowlist::AllowlistRule";
}

export interface AllowlistRuleFields {
    dummyField: ToField<"bool">
}

export type AllowlistRuleReified = Reified<
    AllowlistRule,
    AllowlistRuleFields
>;

export class AllowlistRule {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_allowlist::AllowlistRule";
    static readonly $numTypeParams = 0;

    readonly $typeName = AllowlistRule.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_allowlist::AllowlistRule";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: AllowlistRuleFields,
    ) {
        this.$fullTypeName = AllowlistRule.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): AllowlistRuleReified {
        return {
            typeName: AllowlistRule.$typeName,
            fullTypeName: composeSuiType(
                AllowlistRule.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::transfer_allowlist::AllowlistRule",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                AllowlistRule.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                AllowlistRule.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                AllowlistRule.fromBcs(
                    data,
                ),
            bcs: AllowlistRule.bcs,
            fromJSONField: (field: any) =>
                AllowlistRule.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                AllowlistRule.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => AllowlistRule.fetch(
                client,
                id,
            ),
            new: (
                fields: AllowlistRuleFields,
            ) => {
                return new AllowlistRule(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return AllowlistRule.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<AllowlistRule>> {
        return phantom(AllowlistRule.reified());
    }

    static get p() {
        return AllowlistRule.phantom()
    }

    static get bcs() {
        return bcs.struct("AllowlistRule", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): AllowlistRule {
        return AllowlistRule.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): AllowlistRule {
        if (!isAllowlistRule(item.type)) {
            throw new Error("not a AllowlistRule type");
        }

        return AllowlistRule.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): AllowlistRule {

        return AllowlistRule.fromFields(
            AllowlistRule.bcs.parse(data)
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
    ): AllowlistRule {
        return AllowlistRule.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): AllowlistRule {
        if (json.$typeName !== AllowlistRule.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return AllowlistRule.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): AllowlistRule {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAllowlistRule(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a AllowlistRule object`);
        }
        return AllowlistRule.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<AllowlistRule> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching AllowlistRule object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAllowlistRule(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a AllowlistRule object`);
        }

        return AllowlistRule.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
