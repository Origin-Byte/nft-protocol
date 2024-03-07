import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {Bag} from "../bag/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Extension =============================== */

export function isExtension(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::kiosk_extension::Extension";
}

export interface ExtensionFields {
    storage: ToField<Bag>; permissions: ToField<"u128">; isEnabled: ToField<"bool">
}

export type ExtensionReified = Reified<
    Extension,
    ExtensionFields
>;

export class Extension implements StructClass {
    static readonly $typeName = "0x2::kiosk_extension::Extension";
    static readonly $numTypeParams = 0;

    readonly $typeName = Extension.$typeName;

    readonly $fullTypeName: "0x2::kiosk_extension::Extension";

    readonly $typeArgs: [];

    readonly storage:
        ToField<Bag>
    ; readonly permissions:
        ToField<"u128">
    ; readonly isEnabled:
        ToField<"bool">

    private constructor(typeArgs: [], fields: ExtensionFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Extension.$typeName,
            ...typeArgs
        ) as "0x2::kiosk_extension::Extension";
        this.$typeArgs = typeArgs;

        this.storage = fields.storage;; this.permissions = fields.permissions;; this.isEnabled = fields.isEnabled;
    }

    static reified(): ExtensionReified {
        return {
            typeName: Extension.$typeName,
            fullTypeName: composeSuiType(
                Extension.$typeName,
                ...[]
            ) as "0x2::kiosk_extension::Extension",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Extension.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Extension.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Extension.fromBcs(
                    data,
                ),
            bcs: Extension.bcs,
            fromJSONField: (field: any) =>
                Extension.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Extension.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Extension.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Extension.fetch(
                client,
                id,
            ),
            new: (
                fields: ExtensionFields,
            ) => {
                return new Extension(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Extension.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Extension>> {
        return phantom(Extension.reified());
    }

    static get p() {
        return Extension.phantom()
    }

    static get bcs() {
        return bcs.struct("Extension", {
            storage:
                Bag.bcs
            , permissions:
                bcs.u128()
            , is_enabled:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Extension {
        return Extension.reified().new(
            {storage: decodeFromFields(Bag.reified(), fields.storage), permissions: decodeFromFields("u128", fields.permissions), isEnabled: decodeFromFields("bool", fields.is_enabled)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Extension {
        if (!isExtension(item.type)) {
            throw new Error("not a Extension type");
        }

        return Extension.reified().new(
            {storage: decodeFromFieldsWithTypes(Bag.reified(), item.fields.storage), permissions: decodeFromFieldsWithTypes("u128", item.fields.permissions), isEnabled: decodeFromFieldsWithTypes("bool", item.fields.is_enabled)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Extension {

        return Extension.fromFields(
            Extension.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            storage: this.storage.toJSONField(),permissions: this.permissions.toString(),isEnabled: this.isEnabled,

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
    ): Extension {
        return Extension.reified().new(
            {storage: decodeFromJSONField(Bag.reified(), field.storage), permissions: decodeFromJSONField("u128", field.permissions), isEnabled: decodeFromJSONField("bool", field.isEnabled)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Extension {
        if (json.$typeName !== Extension.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Extension.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Extension {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isExtension(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Extension object`);
        }
        return Extension.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Extension> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Extension object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isExtension(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Extension object`);
        }

        return Extension.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== ExtensionKey =============================== */

export function isExtensionKey(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::kiosk_extension::ExtensionKey<");
}

export interface ExtensionKeyFields<Ext extends PhantomTypeArgument> {
    dummyField: ToField<"bool">
}

export type ExtensionKeyReified<Ext extends PhantomTypeArgument> = Reified<
    ExtensionKey<Ext>,
    ExtensionKeyFields<Ext>
>;

export class ExtensionKey<Ext extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0x2::kiosk_extension::ExtensionKey";
    static readonly $numTypeParams = 1;

    readonly $typeName = ExtensionKey.$typeName;

    readonly $fullTypeName: `0x2::kiosk_extension::ExtensionKey<${PhantomToTypeStr<Ext>}>`;

    readonly $typeArgs: [PhantomToTypeStr<Ext>];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [PhantomToTypeStr<Ext>], fields: ExtensionKeyFields<Ext>,
    ) {
        this.$fullTypeName = composeSuiType(
            ExtensionKey.$typeName,
            ...typeArgs
        ) as `0x2::kiosk_extension::ExtensionKey<${PhantomToTypeStr<Ext>}>`;
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified<Ext extends PhantomReified<PhantomTypeArgument>>(
        Ext: Ext
    ): ExtensionKeyReified<ToPhantomTypeArgument<Ext>> {
        return {
            typeName: ExtensionKey.$typeName,
            fullTypeName: composeSuiType(
                ExtensionKey.$typeName,
                ...[extractType(Ext)]
            ) as `0x2::kiosk_extension::ExtensionKey<${PhantomToTypeStr<ToPhantomTypeArgument<Ext>>}>`,
            typeArgs: [
                extractType(Ext)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<Ext>>],
            reifiedTypeArgs: [Ext],
            fromFields: (fields: Record<string, any>) =>
                ExtensionKey.fromFields(
                    Ext,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ExtensionKey.fromFieldsWithTypes(
                    Ext,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ExtensionKey.fromBcs(
                    Ext,
                    data,
                ),
            bcs: ExtensionKey.bcs,
            fromJSONField: (field: any) =>
                ExtensionKey.fromJSONField(
                    Ext,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ExtensionKey.fromJSON(
                    Ext,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                ExtensionKey.fromSuiParsedData(
                    Ext,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => ExtensionKey.fetch(
                client,
                Ext,
                id,
            ),
            new: (
                fields: ExtensionKeyFields<ToPhantomTypeArgument<Ext>>,
            ) => {
                return new ExtensionKey(
                    [extractType(Ext)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ExtensionKey.reified
    }

    static phantom<Ext extends PhantomReified<PhantomTypeArgument>>(
        Ext: Ext
    ): PhantomReified<ToTypeStr<ExtensionKey<ToPhantomTypeArgument<Ext>>>> {
        return phantom(ExtensionKey.reified(
            Ext
        ));
    }

    static get p() {
        return ExtensionKey.phantom
    }

    static get bcs() {
        return bcs.struct("ExtensionKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields<Ext extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Ext, fields: Record<string, any>
    ): ExtensionKey<ToPhantomTypeArgument<Ext>> {
        return ExtensionKey.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes<Ext extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Ext, item: FieldsWithTypes
    ): ExtensionKey<ToPhantomTypeArgument<Ext>> {
        if (!isExtensionKey(item.type)) {
            throw new Error("not a ExtensionKey type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return ExtensionKey.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs<Ext extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Ext, data: Uint8Array
    ): ExtensionKey<ToPhantomTypeArgument<Ext>> {

        return ExtensionKey.fromFields(
            typeArg,
            ExtensionKey.bcs.parse(data)
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

    static fromJSONField<Ext extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Ext, field: any
    ): ExtensionKey<ToPhantomTypeArgument<Ext>> {
        return ExtensionKey.reified(
            typeArg,
        ).new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON<Ext extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Ext, json: Record<string, any>
    ): ExtensionKey<ToPhantomTypeArgument<Ext>> {
        if (json.$typeName !== ExtensionKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(ExtensionKey.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return ExtensionKey.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<Ext extends PhantomReified<PhantomTypeArgument>>(
        typeArg: Ext, content: SuiParsedData
    ): ExtensionKey<ToPhantomTypeArgument<Ext>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isExtensionKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ExtensionKey object`);
        }
        return ExtensionKey.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<Ext extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: Ext, id: string
    ): Promise<ExtensionKey<ToPhantomTypeArgument<Ext>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ExtensionKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isExtensionKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ExtensionKey object`);
        }

        return ExtensionKey.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
