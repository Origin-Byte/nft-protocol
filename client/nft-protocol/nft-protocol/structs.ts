import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== NFT_PROTOCOL =============================== */

export function isNFT_PROTOCOL(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_protocol::NFT_PROTOCOL";
}

export interface NFT_PROTOCOLFields {
    dummyField: ToField<"bool">
}

export type NFT_PROTOCOLReified = Reified<
    NFT_PROTOCOL,
    NFT_PROTOCOLFields
>;

export class NFT_PROTOCOL implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_protocol::NFT_PROTOCOL";
    static readonly $numTypeParams = 0;

    readonly $typeName = NFT_PROTOCOL.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_protocol::NFT_PROTOCOL";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: NFT_PROTOCOLFields,
    ) {
        this.$fullTypeName = composeSuiType(
            NFT_PROTOCOL.$typeName,
            ...typeArgs
        ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_protocol::NFT_PROTOCOL";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): NFT_PROTOCOLReified {
        return {
            typeName: NFT_PROTOCOL.$typeName,
            fullTypeName: composeSuiType(
                NFT_PROTOCOL.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::nft_protocol::NFT_PROTOCOL",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                NFT_PROTOCOL.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                NFT_PROTOCOL.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                NFT_PROTOCOL.fromBcs(
                    data,
                ),
            bcs: NFT_PROTOCOL.bcs,
            fromJSONField: (field: any) =>
                NFT_PROTOCOL.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                NFT_PROTOCOL.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                NFT_PROTOCOL.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => NFT_PROTOCOL.fetch(
                client,
                id,
            ),
            new: (
                fields: NFT_PROTOCOLFields,
            ) => {
                return new NFT_PROTOCOL(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return NFT_PROTOCOL.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<NFT_PROTOCOL>> {
        return phantom(NFT_PROTOCOL.reified());
    }

    static get p() {
        return NFT_PROTOCOL.phantom()
    }

    static get bcs() {
        return bcs.struct("NFT_PROTOCOL", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): NFT_PROTOCOL {
        return NFT_PROTOCOL.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): NFT_PROTOCOL {
        if (!isNFT_PROTOCOL(item.type)) {
            throw new Error("not a NFT_PROTOCOL type");
        }

        return NFT_PROTOCOL.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): NFT_PROTOCOL {

        return NFT_PROTOCOL.fromFields(
            NFT_PROTOCOL.bcs.parse(data)
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
    ): NFT_PROTOCOL {
        return NFT_PROTOCOL.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): NFT_PROTOCOL {
        if (json.$typeName !== NFT_PROTOCOL.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return NFT_PROTOCOL.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): NFT_PROTOCOL {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isNFT_PROTOCOL(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a NFT_PROTOCOL object`);
        }
        return NFT_PROTOCOL.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<NFT_PROTOCOL> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching NFT_PROTOCOL object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isNFT_PROTOCOL(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a NFT_PROTOCOL object`);
        }

        return NFT_PROTOCOL.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
