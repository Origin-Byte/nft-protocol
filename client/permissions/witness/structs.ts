import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::witness::Witness<");
}

export interface WitnessFields<T extends PhantomTypeArgument> {
    dummyField: ToField<"bool">
}

export type WitnessReified<T extends PhantomTypeArgument> = Reified<
    Witness<T>,
    WitnessFields<T>
>;

export class Witness<T extends PhantomTypeArgument> {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::witness::Witness";
    static readonly $numTypeParams = 1;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::witness::Witness<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArg: string, fields: WitnessFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(Witness.$typeName,
        typeArg) as `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::witness::Witness<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.dummyField = fields.dummyField;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): WitnessReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Witness.$typeName,
            fullTypeName: composeSuiType(
                Witness.$typeName,
                ...[extractType(T)]
            ) as `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::witness::Witness<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Witness.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Witness.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Witness.fromBcs(
                    T,
                    data,
                ),
            bcs: Witness.bcs,
            fromJSONField: (field: any) =>
                Witness.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Witness.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Witness.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: WitnessFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Witness(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Witness.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Witness<ToPhantomTypeArgument<T>>>> {
        return phantom(Witness.reified(
            T
        ));
    }

    static get p() {
        return Witness.phantom
    }

    static get bcs() {
        return bcs.struct("Witness", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Witness<ToPhantomTypeArgument<T>> {
        return Witness.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Witness<ToPhantomTypeArgument<T>> {
        if (!isWitness(item.type)) {
            throw new Error("not a Witness type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Witness.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Witness<ToPhantomTypeArgument<T>> {

        return Witness.fromFields(
            typeArg,
            Witness.bcs.parse(data)
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
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): Witness<ToPhantomTypeArgument<T>> {
        return Witness.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Witness<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Witness.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Witness.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Witness.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Witness<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWitness(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Witness object`);
        }
        return Witness.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Witness<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Witness object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWitness(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Witness object`);
        }

        return Witness.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== WitnessGenerator =============================== */

export function isWitnessGenerator(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::witness::WitnessGenerator<");
}

export interface WitnessGeneratorFields<T extends PhantomTypeArgument> {
    dummyField: ToField<"bool">
}

export type WitnessGeneratorReified<T extends PhantomTypeArgument> = Reified<
    WitnessGenerator<T>,
    WitnessGeneratorFields<T>
>;

export class WitnessGenerator<T extends PhantomTypeArgument> {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::witness::WitnessGenerator";
    static readonly $numTypeParams = 1;

    readonly $typeName = WitnessGenerator.$typeName;

    readonly $fullTypeName: `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::witness::WitnessGenerator<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArg: string, fields: WitnessGeneratorFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(WitnessGenerator.$typeName,
        typeArg) as `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::witness::WitnessGenerator<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.dummyField = fields.dummyField;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): WitnessGeneratorReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: WitnessGenerator.$typeName,
            fullTypeName: composeSuiType(
                WitnessGenerator.$typeName,
                ...[extractType(T)]
            ) as `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::witness::WitnessGenerator<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                WitnessGenerator.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                WitnessGenerator.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                WitnessGenerator.fromBcs(
                    T,
                    data,
                ),
            bcs: WitnessGenerator.bcs,
            fromJSONField: (field: any) =>
                WitnessGenerator.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                WitnessGenerator.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => WitnessGenerator.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: WitnessGeneratorFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new WitnessGenerator(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return WitnessGenerator.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<WitnessGenerator<ToPhantomTypeArgument<T>>>> {
        return phantom(WitnessGenerator.reified(
            T
        ));
    }

    static get p() {
        return WitnessGenerator.phantom
    }

    static get bcs() {
        return bcs.struct("WitnessGenerator", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): WitnessGenerator<ToPhantomTypeArgument<T>> {
        return WitnessGenerator.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): WitnessGenerator<ToPhantomTypeArgument<T>> {
        if (!isWitnessGenerator(item.type)) {
            throw new Error("not a WitnessGenerator type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return WitnessGenerator.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): WitnessGenerator<ToPhantomTypeArgument<T>> {

        return WitnessGenerator.fromFields(
            typeArg,
            WitnessGenerator.bcs.parse(data)
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
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): WitnessGenerator<ToPhantomTypeArgument<T>> {
        return WitnessGenerator.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): WitnessGenerator<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== WitnessGenerator.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(WitnessGenerator.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return WitnessGenerator.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): WitnessGenerator<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWitnessGenerator(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a WitnessGenerator object`);
        }
        return WitnessGenerator.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<WitnessGenerator<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching WitnessGenerator object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWitnessGenerator(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a WitnessGenerator object`);
        }

        return WitnessGenerator.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
