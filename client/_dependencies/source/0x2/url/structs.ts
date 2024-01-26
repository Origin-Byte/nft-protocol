import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {String} from "../../0x1/ascii/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Url =============================== */

export function isUrl(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::url::Url";
}

export interface UrlFields {
    url: ToField<String>
}

export type UrlReified = Reified<
    Url,
    UrlFields
>;

export class Url {
    static readonly $typeName = "0x2::url::Url";
    static readonly $numTypeParams = 0;

    readonly $typeName = Url.$typeName;

    readonly $fullTypeName: "0x2::url::Url";

    ;

    readonly url:
        ToField<String>

    private constructor( fields: UrlFields,
    ) {
        this.$fullTypeName = Url.$typeName;

        this.url = fields.url;
    }

    static reified(): UrlReified {
        return {
            typeName: Url.$typeName,
            fullTypeName: composeSuiType(
                Url.$typeName,
                ...[]
            ) as "0x2::url::Url",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Url.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Url.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Url.fromBcs(
                    data,
                ),
            bcs: Url.bcs,
            fromJSONField: (field: any) =>
                Url.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Url.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Url.fetch(
                client,
                id,
            ),
            new: (
                fields: UrlFields,
            ) => {
                return new Url(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Url.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Url>> {
        return phantom(Url.reified());
    }

    static get p() {
        return Url.phantom()
    }

    static get bcs() {
        return bcs.struct("Url", {
            url:
                String.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Url {
        return Url.reified().new(
            {url: decodeFromFields(String.reified(), fields.url)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Url {
        if (!isUrl(item.type)) {
            throw new Error("not a Url type");
        }

        return Url.reified().new(
            {url: decodeFromFieldsWithTypes(String.reified(), item.fields.url)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Url {

        return Url.fromFields(
            Url.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            url: this.url,

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
    ): Url {
        return Url.reified().new(
            {url: decodeFromJSONField(String.reified(), field.url)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Url {
        if (json.$typeName !== Url.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Url.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Url {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isUrl(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Url object`);
        }
        return Url.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Url> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Url object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isUrl(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Url object`);
        }

        return Url.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
