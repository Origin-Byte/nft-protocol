import {String} from "../../_dependencies/source/0x1/string/structs";
import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== DisplayInfo =============================== */

export function isDisplayInfo(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::display_info::DisplayInfo";
}

export interface DisplayInfoFields {
    name: ToField<String>; description: ToField<String>
}

export type DisplayInfoReified = Reified<
    DisplayInfo,
    DisplayInfoFields
>;

export class DisplayInfo {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::display_info::DisplayInfo";
    static readonly $numTypeParams = 0;

    readonly $typeName = DisplayInfo.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::display_info::DisplayInfo";

    ;

    readonly name:
        ToField<String>
    ; readonly description:
        ToField<String>

    private constructor( fields: DisplayInfoFields,
    ) {
        this.$fullTypeName = DisplayInfo.$typeName;

        this.name = fields.name;; this.description = fields.description;
    }

    static reified(): DisplayInfoReified {
        return {
            typeName: DisplayInfo.$typeName,
            fullTypeName: composeSuiType(
                DisplayInfo.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::display_info::DisplayInfo",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                DisplayInfo.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                DisplayInfo.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                DisplayInfo.fromBcs(
                    data,
                ),
            bcs: DisplayInfo.bcs,
            fromJSONField: (field: any) =>
                DisplayInfo.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                DisplayInfo.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => DisplayInfo.fetch(
                client,
                id,
            ),
            new: (
                fields: DisplayInfoFields,
            ) => {
                return new DisplayInfo(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return DisplayInfo.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<DisplayInfo>> {
        return phantom(DisplayInfo.reified());
    }

    static get p() {
        return DisplayInfo.phantom()
    }

    static get bcs() {
        return bcs.struct("DisplayInfo", {
            name:
                String.bcs
            , description:
                String.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): DisplayInfo {
        return DisplayInfo.reified().new(
            {name: decodeFromFields(String.reified(), fields.name), description: decodeFromFields(String.reified(), fields.description)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): DisplayInfo {
        if (!isDisplayInfo(item.type)) {
            throw new Error("not a DisplayInfo type");
        }

        return DisplayInfo.reified().new(
            {name: decodeFromFieldsWithTypes(String.reified(), item.fields.name), description: decodeFromFieldsWithTypes(String.reified(), item.fields.description)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): DisplayInfo {

        return DisplayInfo.fromFields(
            DisplayInfo.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            name: this.name,description: this.description,

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
    ): DisplayInfo {
        return DisplayInfo.reified().new(
            {name: decodeFromJSONField(String.reified(), field.name), description: decodeFromJSONField(String.reified(), field.description)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): DisplayInfo {
        if (json.$typeName !== DisplayInfo.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return DisplayInfo.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): DisplayInfo {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isDisplayInfo(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a DisplayInfo object`);
        }
        return DisplayInfo.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<DisplayInfo> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching DisplayInfo object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isDisplayInfo(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a DisplayInfo object`);
        }

        return DisplayInfo.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
