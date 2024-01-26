import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== FlatFee =============================== */

export function isFlatFee(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::flat_fee::FlatFee";
}

export interface FlatFeeFields {
    id: ToField<UID>; rateBps: ToField<"u64">
}

export type FlatFeeReified = Reified<
    FlatFee,
    FlatFeeFields
>;

export class FlatFee {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::flat_fee::FlatFee";
    static readonly $numTypeParams = 0;

    readonly $typeName = FlatFee.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::flat_fee::FlatFee";

    ;

    readonly id:
        ToField<UID>
    ; readonly rateBps:
        ToField<"u64">

    private constructor( fields: FlatFeeFields,
    ) {
        this.$fullTypeName = FlatFee.$typeName;

        this.id = fields.id;; this.rateBps = fields.rateBps;
    }

    static reified(): FlatFeeReified {
        return {
            typeName: FlatFee.$typeName,
            fullTypeName: composeSuiType(
                FlatFee.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::flat_fee::FlatFee",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                FlatFee.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                FlatFee.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                FlatFee.fromBcs(
                    data,
                ),
            bcs: FlatFee.bcs,
            fromJSONField: (field: any) =>
                FlatFee.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                FlatFee.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => FlatFee.fetch(
                client,
                id,
            ),
            new: (
                fields: FlatFeeFields,
            ) => {
                return new FlatFee(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return FlatFee.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<FlatFee>> {
        return phantom(FlatFee.reified());
    }

    static get p() {
        return FlatFee.phantom()
    }

    static get bcs() {
        return bcs.struct("FlatFee", {
            id:
                UID.bcs
            , rate_bps:
                bcs.u64()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): FlatFee {
        return FlatFee.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), rateBps: decodeFromFields("u64", fields.rate_bps)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): FlatFee {
        if (!isFlatFee(item.type)) {
            throw new Error("not a FlatFee type");
        }

        return FlatFee.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), rateBps: decodeFromFieldsWithTypes("u64", item.fields.rate_bps)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): FlatFee {

        return FlatFee.fromFields(
            FlatFee.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,rateBps: this.rateBps.toString(),

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
    ): FlatFee {
        return FlatFee.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), rateBps: decodeFromJSONField("u64", field.rateBps)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): FlatFee {
        if (json.$typeName !== FlatFee.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return FlatFee.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): FlatFee {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isFlatFee(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a FlatFee object`);
        }
        return FlatFee.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<FlatFee> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching FlatFee object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isFlatFee(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a FlatFee object`);
        }

        return FlatFee.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
