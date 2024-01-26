import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {Supply as Supply1} from "../../utils/utils-supply/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Supply =============================== */

export function isSupply(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::supply::Supply<");
}

export interface SupplyFields<T extends PhantomTypeArgument> {
    frozen: ToField<"bool">; inner: ToField<Supply1>
}

export type SupplyReified<T extends PhantomTypeArgument> = Reified<
    Supply<T>,
    SupplyFields<T>
>;

export class Supply<T extends PhantomTypeArgument> {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::supply::Supply";
    static readonly $numTypeParams = 1;

    readonly $typeName = Supply.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::supply::Supply<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly frozen:
        ToField<"bool">
    ; readonly inner:
        ToField<Supply1>

    private constructor(typeArg: string, fields: SupplyFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(Supply.$typeName,
        typeArg) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::supply::Supply<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.frozen = fields.frozen;; this.inner = fields.inner;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): SupplyReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Supply.$typeName,
            fullTypeName: composeSuiType(
                Supply.$typeName,
                ...[extractType(T)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::supply::Supply<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Supply.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Supply.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Supply.fromBcs(
                    T,
                    data,
                ),
            bcs: Supply.bcs,
            fromJSONField: (field: any) =>
                Supply.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Supply.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Supply.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: SupplyFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Supply(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Supply.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Supply<ToPhantomTypeArgument<T>>>> {
        return phantom(Supply.reified(
            T
        ));
    }

    static get p() {
        return Supply.phantom
    }

    static get bcs() {
        return bcs.struct("Supply", {
            frozen:
                bcs.bool()
            , inner:
                Supply1.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Supply<ToPhantomTypeArgument<T>> {
        return Supply.reified(
            typeArg,
        ).new(
            {frozen: decodeFromFields("bool", fields.frozen), inner: decodeFromFields(Supply1.reified(), fields.inner)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Supply<ToPhantomTypeArgument<T>> {
        if (!isSupply(item.type)) {
            throw new Error("not a Supply type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Supply.reified(
            typeArg,
        ).new(
            {frozen: decodeFromFieldsWithTypes("bool", item.fields.frozen), inner: decodeFromFieldsWithTypes(Supply1.reified(), item.fields.inner)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Supply<ToPhantomTypeArgument<T>> {

        return Supply.fromFields(
            typeArg,
            Supply.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            frozen: this.frozen,inner: this.inner.toJSONField(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): Supply<ToPhantomTypeArgument<T>> {
        return Supply.reified(
            typeArg,
        ).new(
            {frozen: decodeFromJSONField("bool", field.frozen), inner: decodeFromJSONField(Supply1.reified(), field.inner)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Supply<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Supply.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Supply.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Supply.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Supply<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isSupply(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Supply object`);
        }
        return Supply.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Supply<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Supply object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isSupply(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Supply object`);
        }

        return Supply.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
