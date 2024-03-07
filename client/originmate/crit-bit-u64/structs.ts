import * as reified from "../../_framework/reified";
import {PhantomReified, Reified, StructClass, ToField, ToTypeArgument, ToTypeStr, TypeArgument, Vector, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom, toBcs} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {BcsType, bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== CB =============================== */

export function isCB(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::CB<");
}

export interface CBFields<V extends TypeArgument> {
    r: ToField<"u64">; i: ToField<Vector<I>>; o: ToField<Vector<O<V>>>
}

export type CBReified<V extends TypeArgument> = Reified<
    CB<V>,
    CBFields<V>
>;

export class CB<V extends TypeArgument> implements StructClass {
    static readonly $typeName = "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::CB";
    static readonly $numTypeParams = 1;

    readonly $typeName = CB.$typeName;

    readonly $fullTypeName: `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::CB<${ToTypeStr<V>}>`;

    readonly $typeArgs: [ToTypeStr<V>];

    readonly r:
        ToField<"u64">
    ; readonly i:
        ToField<Vector<I>>
    ; readonly o:
        ToField<Vector<O<V>>>

    private constructor(typeArgs: [ToTypeStr<V>], fields: CBFields<V>,
    ) {
        this.$fullTypeName = composeSuiType(
            CB.$typeName,
            ...typeArgs
        ) as `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::CB<${ToTypeStr<V>}>`;
        this.$typeArgs = typeArgs;

        this.r = fields.r;; this.i = fields.i;; this.o = fields.o;
    }

    static reified<V extends Reified<TypeArgument, any>>(
        V: V
    ): CBReified<ToTypeArgument<V>> {
        return {
            typeName: CB.$typeName,
            fullTypeName: composeSuiType(
                CB.$typeName,
                ...[extractType(V)]
            ) as `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::CB<${ToTypeStr<ToTypeArgument<V>>}>`,
            typeArgs: [
                extractType(V)
            ] as [ToTypeStr<ToTypeArgument<V>>],
            reifiedTypeArgs: [V],
            fromFields: (fields: Record<string, any>) =>
                CB.fromFields(
                    V,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                CB.fromFieldsWithTypes(
                    V,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                CB.fromBcs(
                    V,
                    data,
                ),
            bcs: CB.bcs(toBcs(V)),
            fromJSONField: (field: any) =>
                CB.fromJSONField(
                    V,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                CB.fromJSON(
                    V,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                CB.fromSuiParsedData(
                    V,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => CB.fetch(
                client,
                V,
                id,
            ),
            new: (
                fields: CBFields<ToTypeArgument<V>>,
            ) => {
                return new CB(
                    [extractType(V)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return CB.reified
    }

    static phantom<V extends Reified<TypeArgument, any>>(
        V: V
    ): PhantomReified<ToTypeStr<CB<ToTypeArgument<V>>>> {
        return phantom(CB.reified(
            V
        ));
    }

    static get p() {
        return CB.phantom
    }

    static get bcs() {
        return <V extends BcsType<any>>(V: V) => bcs.struct(`CB<${V.name}>`, {
            r:
                bcs.u64()
            , i:
                bcs.vector(I.bcs)
            , o:
                bcs.vector(O.bcs(V))

        })
    };

    static fromFields<V extends Reified<TypeArgument, any>>(
        typeArg: V, fields: Record<string, any>
    ): CB<ToTypeArgument<V>> {
        return CB.reified(
            typeArg,
        ).new(
            {r: decodeFromFields("u64", fields.r), i: decodeFromFields(reified.vector(I.reified()), fields.i), o: decodeFromFields(reified.vector(O.reified(typeArg)), fields.o)}
        )
    }

    static fromFieldsWithTypes<V extends Reified<TypeArgument, any>>(
        typeArg: V, item: FieldsWithTypes
    ): CB<ToTypeArgument<V>> {
        if (!isCB(item.type)) {
            throw new Error("not a CB type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return CB.reified(
            typeArg,
        ).new(
            {r: decodeFromFieldsWithTypes("u64", item.fields.r), i: decodeFromFieldsWithTypes(reified.vector(I.reified()), item.fields.i), o: decodeFromFieldsWithTypes(reified.vector(O.reified(typeArg)), item.fields.o)}
        )
    }

    static fromBcs<V extends Reified<TypeArgument, any>>(
        typeArg: V, data: Uint8Array
    ): CB<ToTypeArgument<V>> {
        const typeArgs = [typeArg];

        return CB.fromFields(
            typeArg,
            CB.bcs(toBcs(typeArgs[0])).parse(data)
        )
    }

    toJSONField() {
        return {
            r: this.r.toString(),i: fieldToJSON<Vector<I>>(`vector<0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::I>`, this.i),o: fieldToJSON<Vector<O<V>>>(`vector<0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::O<${this.$typeArgs[0]}>>`, this.o),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<V extends Reified<TypeArgument, any>>(
        typeArg: V, field: any
    ): CB<ToTypeArgument<V>> {
        return CB.reified(
            typeArg,
        ).new(
            {r: decodeFromJSONField("u64", field.r), i: decodeFromJSONField(reified.vector(I.reified()), field.i), o: decodeFromJSONField(reified.vector(O.reified(typeArg)), field.o)}
        )
    }

    static fromJSON<V extends Reified<TypeArgument, any>>(
        typeArg: V, json: Record<string, any>
    ): CB<ToTypeArgument<V>> {
        if (json.$typeName !== CB.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(CB.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return CB.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<V extends Reified<TypeArgument, any>>(
        typeArg: V, content: SuiParsedData
    ): CB<ToTypeArgument<V>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isCB(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a CB object`);
        }
        return CB.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<V extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArg: V, id: string
    ): Promise<CB<ToTypeArgument<V>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching CB object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isCB(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a CB object`);
        }

        return CB.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== I =============================== */

export function isI(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::I";
}

export interface IFields {
    c: ToField<"u8">; p: ToField<"u64">; l: ToField<"u64">; r: ToField<"u64">
}

export type IReified = Reified<
    I,
    IFields
>;

export class I implements StructClass {
    static readonly $typeName = "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::I";
    static readonly $numTypeParams = 0;

    readonly $typeName = I.$typeName;

    readonly $fullTypeName: "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::I";

    readonly $typeArgs: [];

    readonly c:
        ToField<"u8">
    ; readonly p:
        ToField<"u64">
    ; readonly l:
        ToField<"u64">
    ; readonly r:
        ToField<"u64">

    private constructor(typeArgs: [], fields: IFields,
    ) {
        this.$fullTypeName = composeSuiType(
            I.$typeName,
            ...typeArgs
        ) as "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::I";
        this.$typeArgs = typeArgs;

        this.c = fields.c;; this.p = fields.p;; this.l = fields.l;; this.r = fields.r;
    }

    static reified(): IReified {
        return {
            typeName: I.$typeName,
            fullTypeName: composeSuiType(
                I.$typeName,
                ...[]
            ) as "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::I",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                I.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                I.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                I.fromBcs(
                    data,
                ),
            bcs: I.bcs,
            fromJSONField: (field: any) =>
                I.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                I.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                I.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => I.fetch(
                client,
                id,
            ),
            new: (
                fields: IFields,
            ) => {
                return new I(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return I.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<I>> {
        return phantom(I.reified());
    }

    static get p() {
        return I.phantom()
    }

    static get bcs() {
        return bcs.struct("I", {
            c:
                bcs.u8()
            , p:
                bcs.u64()
            , l:
                bcs.u64()
            , r:
                bcs.u64()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): I {
        return I.reified().new(
            {c: decodeFromFields("u8", fields.c), p: decodeFromFields("u64", fields.p), l: decodeFromFields("u64", fields.l), r: decodeFromFields("u64", fields.r)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): I {
        if (!isI(item.type)) {
            throw new Error("not a I type");
        }

        return I.reified().new(
            {c: decodeFromFieldsWithTypes("u8", item.fields.c), p: decodeFromFieldsWithTypes("u64", item.fields.p), l: decodeFromFieldsWithTypes("u64", item.fields.l), r: decodeFromFieldsWithTypes("u64", item.fields.r)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): I {

        return I.fromFields(
            I.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            c: this.c,p: this.p.toString(),l: this.l.toString(),r: this.r.toString(),

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
    ): I {
        return I.reified().new(
            {c: decodeFromJSONField("u8", field.c), p: decodeFromJSONField("u64", field.p), l: decodeFromJSONField("u64", field.l), r: decodeFromJSONField("u64", field.r)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): I {
        if (json.$typeName !== I.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return I.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): I {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isI(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a I object`);
        }
        return I.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<I> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching I object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isI(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a I object`);
        }

        return I.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== O =============================== */

export function isO(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::O<");
}

export interface OFields<V extends TypeArgument> {
    k: ToField<"u64">; v: ToField<V>; p: ToField<"u64">
}

export type OReified<V extends TypeArgument> = Reified<
    O<V>,
    OFields<V>
>;

export class O<V extends TypeArgument> implements StructClass {
    static readonly $typeName = "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::O";
    static readonly $numTypeParams = 1;

    readonly $typeName = O.$typeName;

    readonly $fullTypeName: `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::O<${ToTypeStr<V>}>`;

    readonly $typeArgs: [ToTypeStr<V>];

    readonly k:
        ToField<"u64">
    ; readonly v:
        ToField<V>
    ; readonly p:
        ToField<"u64">

    private constructor(typeArgs: [ToTypeStr<V>], fields: OFields<V>,
    ) {
        this.$fullTypeName = composeSuiType(
            O.$typeName,
            ...typeArgs
        ) as `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::O<${ToTypeStr<V>}>`;
        this.$typeArgs = typeArgs;

        this.k = fields.k;; this.v = fields.v;; this.p = fields.p;
    }

    static reified<V extends Reified<TypeArgument, any>>(
        V: V
    ): OReified<ToTypeArgument<V>> {
        return {
            typeName: O.$typeName,
            fullTypeName: composeSuiType(
                O.$typeName,
                ...[extractType(V)]
            ) as `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::crit_bit_u64::O<${ToTypeStr<ToTypeArgument<V>>}>`,
            typeArgs: [
                extractType(V)
            ] as [ToTypeStr<ToTypeArgument<V>>],
            reifiedTypeArgs: [V],
            fromFields: (fields: Record<string, any>) =>
                O.fromFields(
                    V,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                O.fromFieldsWithTypes(
                    V,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                O.fromBcs(
                    V,
                    data,
                ),
            bcs: O.bcs(toBcs(V)),
            fromJSONField: (field: any) =>
                O.fromJSONField(
                    V,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                O.fromJSON(
                    V,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                O.fromSuiParsedData(
                    V,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => O.fetch(
                client,
                V,
                id,
            ),
            new: (
                fields: OFields<ToTypeArgument<V>>,
            ) => {
                return new O(
                    [extractType(V)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return O.reified
    }

    static phantom<V extends Reified<TypeArgument, any>>(
        V: V
    ): PhantomReified<ToTypeStr<O<ToTypeArgument<V>>>> {
        return phantom(O.reified(
            V
        ));
    }

    static get p() {
        return O.phantom
    }

    static get bcs() {
        return <V extends BcsType<any>>(V: V) => bcs.struct(`O<${V.name}>`, {
            k:
                bcs.u64()
            , v:
                V
            , p:
                bcs.u64()

        })
    };

    static fromFields<V extends Reified<TypeArgument, any>>(
        typeArg: V, fields: Record<string, any>
    ): O<ToTypeArgument<V>> {
        return O.reified(
            typeArg,
        ).new(
            {k: decodeFromFields("u64", fields.k), v: decodeFromFields(typeArg, fields.v), p: decodeFromFields("u64", fields.p)}
        )
    }

    static fromFieldsWithTypes<V extends Reified<TypeArgument, any>>(
        typeArg: V, item: FieldsWithTypes
    ): O<ToTypeArgument<V>> {
        if (!isO(item.type)) {
            throw new Error("not a O type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return O.reified(
            typeArg,
        ).new(
            {k: decodeFromFieldsWithTypes("u64", item.fields.k), v: decodeFromFieldsWithTypes(typeArg, item.fields.v), p: decodeFromFieldsWithTypes("u64", item.fields.p)}
        )
    }

    static fromBcs<V extends Reified<TypeArgument, any>>(
        typeArg: V, data: Uint8Array
    ): O<ToTypeArgument<V>> {
        const typeArgs = [typeArg];

        return O.fromFields(
            typeArg,
            O.bcs(toBcs(typeArgs[0])).parse(data)
        )
    }

    toJSONField() {
        return {
            k: this.k.toString(),v: fieldToJSON<V>(this.$typeArgs[0], this.v),p: this.p.toString(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<V extends Reified<TypeArgument, any>>(
        typeArg: V, field: any
    ): O<ToTypeArgument<V>> {
        return O.reified(
            typeArg,
        ).new(
            {k: decodeFromJSONField("u64", field.k), v: decodeFromJSONField(typeArg, field.v), p: decodeFromJSONField("u64", field.p)}
        )
    }

    static fromJSON<V extends Reified<TypeArgument, any>>(
        typeArg: V, json: Record<string, any>
    ): O<ToTypeArgument<V>> {
        if (json.$typeName !== O.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(O.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return O.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<V extends Reified<TypeArgument, any>>(
        typeArg: V, content: SuiParsedData
    ): O<ToTypeArgument<V>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isO(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a O object`);
        }
        return O.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<V extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArg: V, id: string
    ): Promise<O<ToTypeArgument<V>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching O object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isO(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a O object`);
        }

        return O.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
