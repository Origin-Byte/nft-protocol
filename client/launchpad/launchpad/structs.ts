import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== LAUNCHPAD =============================== */

export function isLAUNCHPAD(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::launchpad::LAUNCHPAD";
}

export interface LAUNCHPADFields {
    dummyField: ToField<"bool">
}

export type LAUNCHPADReified = Reified<
    LAUNCHPAD,
    LAUNCHPADFields
>;

export class LAUNCHPAD {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::launchpad::LAUNCHPAD";
    static readonly $numTypeParams = 0;

    readonly $typeName = LAUNCHPAD.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::launchpad::LAUNCHPAD";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: LAUNCHPADFields,
    ) {
        this.$fullTypeName = LAUNCHPAD.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): LAUNCHPADReified {
        return {
            typeName: LAUNCHPAD.$typeName,
            fullTypeName: composeSuiType(
                LAUNCHPAD.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::launchpad::LAUNCHPAD",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                LAUNCHPAD.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                LAUNCHPAD.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                LAUNCHPAD.fromBcs(
                    data,
                ),
            bcs: LAUNCHPAD.bcs,
            fromJSONField: (field: any) =>
                LAUNCHPAD.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                LAUNCHPAD.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => LAUNCHPAD.fetch(
                client,
                id,
            ),
            new: (
                fields: LAUNCHPADFields,
            ) => {
                return new LAUNCHPAD(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return LAUNCHPAD.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<LAUNCHPAD>> {
        return phantom(LAUNCHPAD.reified());
    }

    static get p() {
        return LAUNCHPAD.phantom()
    }

    static get bcs() {
        return bcs.struct("LAUNCHPAD", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): LAUNCHPAD {
        return LAUNCHPAD.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): LAUNCHPAD {
        if (!isLAUNCHPAD(item.type)) {
            throw new Error("not a LAUNCHPAD type");
        }

        return LAUNCHPAD.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): LAUNCHPAD {

        return LAUNCHPAD.fromFields(
            LAUNCHPAD.bcs.parse(data)
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
    ): LAUNCHPAD {
        return LAUNCHPAD.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): LAUNCHPAD {
        if (json.$typeName !== LAUNCHPAD.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return LAUNCHPAD.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): LAUNCHPAD {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isLAUNCHPAD(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a LAUNCHPAD object`);
        }
        return LAUNCHPAD.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<LAUNCHPAD> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching LAUNCHPAD object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isLAUNCHPAD(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a LAUNCHPAD object`);
        }

        return LAUNCHPAD.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
