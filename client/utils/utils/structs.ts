import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== IsShared =============================== */

export function isIsShared(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils::IsShared";
}

export interface IsSharedFields {
    dummyField: ToField<"bool">
}

export type IsSharedReified = Reified<
    IsShared,
    IsSharedFields
>;

export class IsShared implements StructClass {
    static readonly $typeName = "0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils::IsShared";
    static readonly $numTypeParams = 0;

    readonly $typeName = IsShared.$typeName;

    readonly $fullTypeName: "0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils::IsShared";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: IsSharedFields,
    ) {
        this.$fullTypeName = composeSuiType(
            IsShared.$typeName,
            ...typeArgs
        ) as "0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils::IsShared";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): IsSharedReified {
        return {
            typeName: IsShared.$typeName,
            fullTypeName: composeSuiType(
                IsShared.$typeName,
                ...[]
            ) as "0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils::IsShared",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                IsShared.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                IsShared.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                IsShared.fromBcs(
                    data,
                ),
            bcs: IsShared.bcs,
            fromJSONField: (field: any) =>
                IsShared.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                IsShared.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                IsShared.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => IsShared.fetch(
                client,
                id,
            ),
            new: (
                fields: IsSharedFields,
            ) => {
                return new IsShared(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return IsShared.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<IsShared>> {
        return phantom(IsShared.reified());
    }

    static get p() {
        return IsShared.phantom()
    }

    static get bcs() {
        return bcs.struct("IsShared", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): IsShared {
        return IsShared.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): IsShared {
        if (!isIsShared(item.type)) {
            throw new Error("not a IsShared type");
        }

        return IsShared.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): IsShared {

        return IsShared.fromFields(
            IsShared.bcs.parse(data)
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
    ): IsShared {
        return IsShared.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): IsShared {
        if (json.$typeName !== IsShared.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return IsShared.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): IsShared {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isIsShared(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a IsShared object`);
        }
        return IsShared.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<IsShared> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching IsShared object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isIsShared(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a IsShared object`);
        }

        return IsShared.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Marker =============================== */

export function isMarker(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils::Marker<");
}

export interface MarkerFields<T extends PhantomTypeArgument> {
    dummyField: ToField<"bool">
}

export type MarkerReified<T extends PhantomTypeArgument> = Reified<
    Marker<T>,
    MarkerFields<T>
>;

export class Marker<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils::Marker";
    static readonly $numTypeParams = 1;

    readonly $typeName = Marker.$typeName;

    readonly $fullTypeName: `0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils::Marker<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: MarkerFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            Marker.$typeName,
            ...typeArgs
        ) as `0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils::Marker<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): MarkerReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Marker.$typeName,
            fullTypeName: composeSuiType(
                Marker.$typeName,
                ...[extractType(T)]
            ) as `0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils::Marker<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Marker.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Marker.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Marker.fromBcs(
                    T,
                    data,
                ),
            bcs: Marker.bcs,
            fromJSONField: (field: any) =>
                Marker.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Marker.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Marker.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Marker.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: MarkerFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Marker(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Marker.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Marker<ToPhantomTypeArgument<T>>>> {
        return phantom(Marker.reified(
            T
        ));
    }

    static get p() {
        return Marker.phantom
    }

    static get bcs() {
        return bcs.struct("Marker", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Marker<ToPhantomTypeArgument<T>> {
        return Marker.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Marker<ToPhantomTypeArgument<T>> {
        if (!isMarker(item.type)) {
            throw new Error("not a Marker type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Marker.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Marker<ToPhantomTypeArgument<T>> {

        return Marker.fromFields(
            typeArg,
            Marker.bcs.parse(data)
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

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, field: any
    ): Marker<ToPhantomTypeArgument<T>> {
        return Marker.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Marker<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Marker.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Marker.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return Marker.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Marker<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isMarker(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Marker object`);
        }
        return Marker.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Marker<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Marker object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isMarker(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Marker object`);
        }

        return Marker.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
