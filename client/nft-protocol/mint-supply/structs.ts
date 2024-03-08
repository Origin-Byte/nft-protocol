import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {Supply} from "../../utils/utils-supply/structs";
import {MintCap} from "../mint-cap/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== MintSupply =============================== */

export function isMintSupply(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_supply::MintSupply<");
}

export interface MintSupplyFields<T extends PhantomTypeArgument> {
    frozen: ToField<"bool">; mintCap: ToField<MintCap<T>>; supply: ToField<Supply>
}

export type MintSupplyReified<T extends PhantomTypeArgument> = Reified<
    MintSupply<T>,
    MintSupplyFields<T>
>;

export class MintSupply<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_supply::MintSupply";
    static readonly $numTypeParams = 1;

    readonly $typeName = MintSupply.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_supply::MintSupply<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly frozen:
        ToField<"bool">
    ; readonly mintCap:
        ToField<MintCap<T>>
    ; readonly supply:
        ToField<Supply>

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: MintSupplyFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            MintSupply.$typeName,
            ...typeArgs
        ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_supply::MintSupply<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.frozen = fields.frozen;; this.mintCap = fields.mintCap;; this.supply = fields.supply;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): MintSupplyReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: MintSupply.$typeName,
            fullTypeName: composeSuiType(
                MintSupply.$typeName,
                ...[extractType(T)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::mint_supply::MintSupply<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                MintSupply.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                MintSupply.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                MintSupply.fromBcs(
                    T,
                    data,
                ),
            bcs: MintSupply.bcs,
            fromJSONField: (field: any) =>
                MintSupply.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                MintSupply.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                MintSupply.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => MintSupply.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: MintSupplyFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new MintSupply(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return MintSupply.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<MintSupply<ToPhantomTypeArgument<T>>>> {
        return phantom(MintSupply.reified(
            T
        ));
    }

    static get p() {
        return MintSupply.phantom
    }

    static get bcs() {
        return bcs.struct("MintSupply", {
            frozen:
                bcs.bool()
            , mint_cap:
                MintCap.bcs
            , supply:
                Supply.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): MintSupply<ToPhantomTypeArgument<T>> {
        return MintSupply.reified(
            typeArg,
        ).new(
            {frozen: decodeFromFields("bool", fields.frozen), mintCap: decodeFromFields(MintCap.reified(typeArg), fields.mint_cap), supply: decodeFromFields(Supply.reified(), fields.supply)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): MintSupply<ToPhantomTypeArgument<T>> {
        if (!isMintSupply(item.type)) {
            throw new Error("not a MintSupply type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return MintSupply.reified(
            typeArg,
        ).new(
            {frozen: decodeFromFieldsWithTypes("bool", item.fields.frozen), mintCap: decodeFromFieldsWithTypes(MintCap.reified(typeArg), item.fields.mint_cap), supply: decodeFromFieldsWithTypes(Supply.reified(), item.fields.supply)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): MintSupply<ToPhantomTypeArgument<T>> {

        return MintSupply.fromFields(
            typeArg,
            MintSupply.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            frozen: this.frozen,mintCap: this.mintCap.toJSONField(),supply: this.supply.toJSONField(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): MintSupply<ToPhantomTypeArgument<T>> {
        return MintSupply.reified(
            typeArg,
        ).new(
            {frozen: decodeFromJSONField("bool", field.frozen), mintCap: decodeFromJSONField(MintCap.reified(typeArg), field.mintCap), supply: decodeFromJSONField(Supply.reified(), field.supply)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): MintSupply<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== MintSupply.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(MintSupply.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return MintSupply.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): MintSupply<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isMintSupply(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a MintSupply object`);
        }
        return MintSupply.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<MintSupply<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching MintSupply object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isMintSupply(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a MintSupply object`);
        }

        return MintSupply.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
