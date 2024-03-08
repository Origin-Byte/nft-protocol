import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {String} from "../../0x1/string/structs";
import {ID, UID} from "../object/structs";
import {VecMap} from "../vec-map/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Display =============================== */

export function isDisplay(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::display::Display<");
}

export interface DisplayFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; fields: ToField<VecMap<String, String>>; version: ToField<"u16">
}

export type DisplayReified<T extends PhantomTypeArgument> = Reified<
    Display<T>,
    DisplayFields<T>
>;

export class Display<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x2::display::Display";
    static readonly $numTypeParams = 1;

    readonly $typeName = Display.$typeName;

    readonly $fullTypeName: `0x2::display::Display<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly id:
        ToField<UID>
    ; readonly fields:
        ToField<VecMap<String, String>>
    ; readonly version:
        ToField<"u16">

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: DisplayFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            Display.$typeName,
            ...typeArgs
        ) as `0x2::display::Display<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.fields = fields.fields;; this.version = fields.version;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): DisplayReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: Display.$typeName,
            fullTypeName: composeSuiType(
                Display.$typeName,
                ...[extractType(T)]
            ) as `0x2::display::Display<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Display.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Display.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Display.fromBcs(
                    T,
                    data,
                ),
            bcs: Display.bcs,
            fromJSONField: (field: any) =>
                Display.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Display.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Display.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Display.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: DisplayFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new Display(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Display.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<Display<ToPhantomTypeArgument<T>>>> {
        return phantom(Display.reified(
            T
        ));
    }

    static get p() {
        return Display.phantom
    }

    static get bcs() {
        return bcs.struct("Display", {
            id:
                UID.bcs
            , fields:
                VecMap.bcs(String.bcs, String.bcs)
            , version:
                bcs.u16()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): Display<ToPhantomTypeArgument<T>> {
        return Display.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), fields: decodeFromFields(VecMap.reified(String.reified(), String.reified()), fields.fields), version: decodeFromFields("u16", fields.version)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): Display<ToPhantomTypeArgument<T>> {
        if (!isDisplay(item.type)) {
            throw new Error("not a Display type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Display.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), fields: decodeFromFieldsWithTypes(VecMap.reified(String.reified(), String.reified()), item.fields.fields), version: decodeFromFieldsWithTypes("u16", item.fields.version)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): Display<ToPhantomTypeArgument<T>> {

        return Display.fromFields(
            typeArg,
            Display.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,fields: this.fields.toJSONField(),version: this.version,

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
    ): Display<ToPhantomTypeArgument<T>> {
        return Display.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), fields: decodeFromJSONField(VecMap.reified(String.reified(), String.reified()), field.fields), version: decodeFromJSONField("u16", field.version)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): Display<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== Display.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Display.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return Display.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): Display<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isDisplay(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Display object`);
        }
        return Display.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Display<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Display object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isDisplay(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Display object`);
        }

        return Display.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== DisplayCreated =============================== */

export function isDisplayCreated(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::display::DisplayCreated<");
}

export interface DisplayCreatedFields<T extends PhantomTypeArgument> {
    id: ToField<ID>
}

export type DisplayCreatedReified<T extends PhantomTypeArgument> = Reified<
    DisplayCreated<T>,
    DisplayCreatedFields<T>
>;

export class DisplayCreated<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x2::display::DisplayCreated";
    static readonly $numTypeParams = 1;

    readonly $typeName = DisplayCreated.$typeName;

    readonly $fullTypeName: `0x2::display::DisplayCreated<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly id:
        ToField<ID>

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: DisplayCreatedFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            DisplayCreated.$typeName,
            ...typeArgs
        ) as `0x2::display::DisplayCreated<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): DisplayCreatedReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: DisplayCreated.$typeName,
            fullTypeName: composeSuiType(
                DisplayCreated.$typeName,
                ...[extractType(T)]
            ) as `0x2::display::DisplayCreated<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                DisplayCreated.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                DisplayCreated.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                DisplayCreated.fromBcs(
                    T,
                    data,
                ),
            bcs: DisplayCreated.bcs,
            fromJSONField: (field: any) =>
                DisplayCreated.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                DisplayCreated.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                DisplayCreated.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => DisplayCreated.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: DisplayCreatedFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new DisplayCreated(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return DisplayCreated.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<DisplayCreated<ToPhantomTypeArgument<T>>>> {
        return phantom(DisplayCreated.reified(
            T
        ));
    }

    static get p() {
        return DisplayCreated.phantom
    }

    static get bcs() {
        return bcs.struct("DisplayCreated", {
            id:
                ID.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): DisplayCreated<ToPhantomTypeArgument<T>> {
        return DisplayCreated.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(ID.reified(), fields.id)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): DisplayCreated<ToPhantomTypeArgument<T>> {
        if (!isDisplayCreated(item.type)) {
            throw new Error("not a DisplayCreated type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return DisplayCreated.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): DisplayCreated<ToPhantomTypeArgument<T>> {

        return DisplayCreated.fromFields(
            typeArg,
            DisplayCreated.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,

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
    ): DisplayCreated<ToPhantomTypeArgument<T>> {
        return DisplayCreated.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(ID.reified(), field.id)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): DisplayCreated<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== DisplayCreated.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(DisplayCreated.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return DisplayCreated.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): DisplayCreated<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isDisplayCreated(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a DisplayCreated object`);
        }
        return DisplayCreated.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<DisplayCreated<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching DisplayCreated object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isDisplayCreated(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a DisplayCreated object`);
        }

        return DisplayCreated.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== VersionUpdated =============================== */

export function isVersionUpdated(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::display::VersionUpdated<");
}

export interface VersionUpdatedFields<T extends PhantomTypeArgument> {
    id: ToField<ID>; version: ToField<"u16">; fields: ToField<VecMap<String, String>>
}

export type VersionUpdatedReified<T extends PhantomTypeArgument> = Reified<
    VersionUpdated<T>,
    VersionUpdatedFields<T>
>;

export class VersionUpdated<T extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x2::display::VersionUpdated";
    static readonly $numTypeParams = 1;

    readonly $typeName = VersionUpdated.$typeName;

    readonly $fullTypeName: `0x2::display::VersionUpdated<${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>];

    readonly id:
        ToField<ID>
    ; readonly version:
        ToField<"u16">
    ; readonly fields:
        ToField<VecMap<String, String>>

    private constructor(typeArgs: [PhantomToTypeStr<T>], fields: VersionUpdatedFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            VersionUpdated.$typeName,
            ...typeArgs
        ) as `0x2::display::VersionUpdated<${PhantomToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.version = fields.version;; this.fields = fields.fields;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): VersionUpdatedReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: VersionUpdated.$typeName,
            fullTypeName: composeSuiType(
                VersionUpdated.$typeName,
                ...[extractType(T)]
            ) as `0x2::display::VersionUpdated<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                VersionUpdated.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                VersionUpdated.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                VersionUpdated.fromBcs(
                    T,
                    data,
                ),
            bcs: VersionUpdated.bcs,
            fromJSONField: (field: any) =>
                VersionUpdated.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                VersionUpdated.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                VersionUpdated.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => VersionUpdated.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: VersionUpdatedFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new VersionUpdated(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return VersionUpdated.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<VersionUpdated<ToPhantomTypeArgument<T>>>> {
        return phantom(VersionUpdated.reified(
            T
        ));
    }

    static get p() {
        return VersionUpdated.phantom
    }

    static get bcs() {
        return bcs.struct("VersionUpdated", {
            id:
                ID.bcs
            , version:
                bcs.u16()
            , fields:
                VecMap.bcs(String.bcs, String.bcs)

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): VersionUpdated<ToPhantomTypeArgument<T>> {
        return VersionUpdated.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(ID.reified(), fields.id), version: decodeFromFields("u16", fields.version), fields: decodeFromFields(VecMap.reified(String.reified(), String.reified()), fields.fields)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): VersionUpdated<ToPhantomTypeArgument<T>> {
        if (!isVersionUpdated(item.type)) {
            throw new Error("not a VersionUpdated type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return VersionUpdated.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id), version: decodeFromFieldsWithTypes("u16", item.fields.version), fields: decodeFromFieldsWithTypes(VecMap.reified(String.reified(), String.reified()), item.fields.fields)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): VersionUpdated<ToPhantomTypeArgument<T>> {

        return VersionUpdated.fromFields(
            typeArg,
            VersionUpdated.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,version: this.version,fields: this.fields.toJSONField(),

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
    ): VersionUpdated<ToPhantomTypeArgument<T>> {
        return VersionUpdated.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(ID.reified(), field.id), version: decodeFromJSONField("u16", field.version), fields: decodeFromJSONField(VecMap.reified(String.reified(), String.reified()), field.fields)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): VersionUpdated<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== VersionUpdated.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(VersionUpdated.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return VersionUpdated.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): VersionUpdated<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isVersionUpdated(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a VersionUpdated object`);
        }
        return VersionUpdated.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<VersionUpdated<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching VersionUpdated object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isVersionUpdated(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a VersionUpdated object`);
        }

        return VersionUpdated.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
