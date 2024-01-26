import {TypeName} from "../../_dependencies/source/0x1/type-name/structs";
import {VecSet} from "../../_dependencies/source/0x2/vec-set/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {WitnessGenerator} from "../../permissions/witness/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Plugins =============================== */

export function isPlugins(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::plugins::Plugins<");
}

export interface PluginsFields<T extends PhantomTypeArgument> {
    generator: ToField<WitnessGenerator<T>>; packages: ToField<VecSet<TypeName>>
}

export type PluginsReified<T extends PhantomTypeArgument> = Reified<
    Plugins<T>,
    PluginsFields<T>
>;

export class Plugins<T extends PhantomTypeArgument> {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::plugins::Plugins";
    static readonly $numTypeParams = 1;

    readonly $typeName = Plugins.$typeName;

    readonly $fullTypeName: `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::plugins::Plugins<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly generator:
        ToField<WitnessGenerator<T>>
    ; readonly packages:
        ToField<VecSet<TypeName>>

    private constructor(typeArg: string, fields: PluginsFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(Plugins.$typeName,
        typeArg) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::plugins::Plugins<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.generator = fields.generator;; this.packages = fields.packages;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PluginsReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Plugins.$typeName,
            fullTypeName: composeSuiType(
                Plugins.$typeName,
                ...[extractType(T)]
            ) as `0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::plugins::Plugins<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Plugins.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Plugins.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Plugins.fromBcs(
                    T,
                    data,
                ),
            bcs: Plugins.bcs,
            fromJSONField: (field: any) =>
                Plugins.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Plugins.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Plugins.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: PluginsFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Plugins(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Plugins.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Plugins<ToPhantomTypeArgument<T>>>> {
        return phantom(Plugins.reified(
            T
        ));
    }

    static get p() {
        return Plugins.phantom
    }

    static get bcs() {
        return bcs.struct("Plugins", {
            generator:
                WitnessGenerator.bcs
            , packages:
                VecSet.bcs(TypeName.bcs)

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Plugins<ToPhantomTypeArgument<T>> {
        return Plugins.reified(
            typeArg,
        ).new(
            {generator: decodeFromFields(WitnessGenerator.reified(typeArg), fields.generator), packages: decodeFromFields(VecSet.reified(TypeName.reified()), fields.packages)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Plugins<ToPhantomTypeArgument<T>> {
        if (!isPlugins(item.type)) {
            throw new Error("not a Plugins type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Plugins.reified(
            typeArg,
        ).new(
            {generator: decodeFromFieldsWithTypes(WitnessGenerator.reified(typeArg), item.fields.generator), packages: decodeFromFieldsWithTypes(VecSet.reified(TypeName.reified()), item.fields.packages)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Plugins<ToPhantomTypeArgument<T>> {

        return Plugins.fromFields(
            typeArg,
            Plugins.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            generator: this.generator.toJSONField(),packages: this.packages.toJSONField(),

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
    ): Plugins<ToPhantomTypeArgument<T>> {
        return Plugins.reified(
            typeArg,
        ).new(
            {generator: decodeFromJSONField(WitnessGenerator.reified(typeArg), field.generator), packages: decodeFromJSONField(VecSet.reified(TypeName.reified()), field.packages)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Plugins<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Plugins.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Plugins.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Plugins.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Plugins<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isPlugins(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Plugins object`);
        }
        return Plugins.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Plugins<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Plugins object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isPlugins(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Plugins object`);
        }

        return Plugins.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
