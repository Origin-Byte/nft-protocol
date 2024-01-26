import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== SUI =============================== */

export function isSUI(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::sui::SUI";
}

export interface SUIFields {
    dummyField: ToField<"bool">
}

export type SUIReified = Reified<
    SUI,
    SUIFields
>;

export class SUI {
    static readonly $typeName = "0x2::sui::SUI";
    static readonly $numTypeParams = 0;

    readonly $typeName = SUI.$typeName;

    readonly $fullTypeName: "0x2::sui::SUI";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: SUIFields,
    ) {
        this.$fullTypeName = SUI.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): SUIReified {
        return {
            typeName: SUI.$typeName,
            fullTypeName: composeSuiType(
                SUI.$typeName,
                ...[]
            ) as "0x2::sui::SUI",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                SUI.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                SUI.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                SUI.fromBcs(
                    data,
                ),
            bcs: SUI.bcs,
            fromJSONField: (field: any) =>
                SUI.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                SUI.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => SUI.fetch(
                client,
                id,
            ),
            new: (
                fields: SUIFields,
            ) => {
                return new SUI(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return SUI.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<SUI>> {
        return phantom(SUI.reified());
    }

    static get p() {
        return SUI.phantom()
    }

    static get bcs() {
        return bcs.struct("SUI", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): SUI {
        return SUI.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): SUI {
        if (!isSUI(item.type)) {
            throw new Error("not a SUI type");
        }

        return SUI.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): SUI {

        return SUI.fromFields(
            SUI.bcs.parse(data)
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
    ): SUI {
        return SUI.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): SUI {
        if (json.$typeName !== SUI.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return SUI.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): SUI {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isSUI(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a SUI object`);
        }
        return SUI.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<SUI> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching SUI object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isSUI(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a SUI object`);
        }

        return SUI.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
