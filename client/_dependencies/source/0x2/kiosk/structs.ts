import * as reified from "../../../../_framework/reified";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom, ToTypeStr as ToPhantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {Balance} from "../balance/structs";
import {ID, UID} from "../object/structs";
import {SUI} from "../sui/structs";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Borrow =============================== */

export function isBorrow(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::kiosk::Borrow";
}

export interface BorrowFields {
    kioskId: ToField<ID>; itemId: ToField<ID>
}

export type BorrowReified = Reified<
    Borrow,
    BorrowFields
>;

export class Borrow {
    static readonly $typeName = "0x2::kiosk::Borrow";
    static readonly $numTypeParams = 0;

    readonly $typeName = Borrow.$typeName;

    readonly $fullTypeName: "0x2::kiosk::Borrow";

    ;

    readonly kioskId:
        ToField<ID>
    ; readonly itemId:
        ToField<ID>

    private constructor( fields: BorrowFields,
    ) {
        this.$fullTypeName = Borrow.$typeName;

        this.kioskId = fields.kioskId;; this.itemId = fields.itemId;
    }

    static reified(): BorrowReified {
        return {
            typeName: Borrow.$typeName,
            fullTypeName: composeSuiType(
                Borrow.$typeName,
                ...[]
            ) as "0x2::kiosk::Borrow",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Borrow.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Borrow.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Borrow.fromBcs(
                    data,
                ),
            bcs: Borrow.bcs,
            fromJSONField: (field: any) =>
                Borrow.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Borrow.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Borrow.fetch(
                client,
                id,
            ),
            new: (
                fields: BorrowFields,
            ) => {
                return new Borrow(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Borrow.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Borrow>> {
        return phantom(Borrow.reified());
    }

    static get p() {
        return Borrow.phantom()
    }

    static get bcs() {
        return bcs.struct("Borrow", {
            kiosk_id:
                ID.bcs
            , item_id:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Borrow {
        return Borrow.reified().new(
            {kioskId: decodeFromFields(ID.reified(), fields.kiosk_id), itemId: decodeFromFields(ID.reified(), fields.item_id)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Borrow {
        if (!isBorrow(item.type)) {
            throw new Error("not a Borrow type");
        }

        return Borrow.reified().new(
            {kioskId: decodeFromFieldsWithTypes(ID.reified(), item.fields.kiosk_id), itemId: decodeFromFieldsWithTypes(ID.reified(), item.fields.item_id)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Borrow {

        return Borrow.fromFields(
            Borrow.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            kioskId: this.kioskId,itemId: this.itemId,

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
    ): Borrow {
        return Borrow.reified().new(
            {kioskId: decodeFromJSONField(ID.reified(), field.kioskId), itemId: decodeFromJSONField(ID.reified(), field.itemId)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Borrow {
        if (json.$typeName !== Borrow.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Borrow.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Borrow {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBorrow(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Borrow object`);
        }
        return Borrow.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Borrow> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Borrow object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBorrow(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Borrow object`);
        }

        return Borrow.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Item =============================== */

export function isItem(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::kiosk::Item";
}

export interface ItemFields {
    id: ToField<ID>
}

export type ItemReified = Reified<
    Item,
    ItemFields
>;

export class Item {
    static readonly $typeName = "0x2::kiosk::Item";
    static readonly $numTypeParams = 0;

    readonly $typeName = Item.$typeName;

    readonly $fullTypeName: "0x2::kiosk::Item";

    ;

    readonly id:
        ToField<ID>

    private constructor( fields: ItemFields,
    ) {
        this.$fullTypeName = Item.$typeName;

        this.id = fields.id;
    }

    static reified(): ItemReified {
        return {
            typeName: Item.$typeName,
            fullTypeName: composeSuiType(
                Item.$typeName,
                ...[]
            ) as "0x2::kiosk::Item",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Item.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Item.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Item.fromBcs(
                    data,
                ),
            bcs: Item.bcs,
            fromJSONField: (field: any) =>
                Item.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Item.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Item.fetch(
                client,
                id,
            ),
            new: (
                fields: ItemFields,
            ) => {
                return new Item(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Item.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Item>> {
        return phantom(Item.reified());
    }

    static get p() {
        return Item.phantom()
    }

    static get bcs() {
        return bcs.struct("Item", {
            id:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Item {
        return Item.reified().new(
            {id: decodeFromFields(ID.reified(), fields.id)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Item {
        if (!isItem(item.type)) {
            throw new Error("not a Item type");
        }

        return Item.reified().new(
            {id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Item {

        return Item.fromFields(
            Item.bcs.parse(data)
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
            ...this.toJSONField()
        }
    }

    static fromJSONField(
         field: any
    ): Item {
        return Item.reified().new(
            {id: decodeFromJSONField(ID.reified(), field.id)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Item {
        if (json.$typeName !== Item.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Item.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Item {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isItem(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Item object`);
        }
        return Item.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Item> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Item object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isItem(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Item object`);
        }

        return Item.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== ItemDelisted =============================== */

export function isItemDelisted(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::kiosk::ItemDelisted<");
}

export interface ItemDelistedFields<T extends PhantomTypeArgument> {
    kiosk: ToField<ID>; id: ToField<ID>
}

export type ItemDelistedReified<T extends PhantomTypeArgument> = Reified<
    ItemDelisted<T>,
    ItemDelistedFields<T>
>;

export class ItemDelisted<T extends PhantomTypeArgument> {
    static readonly $typeName = "0x2::kiosk::ItemDelisted";
    static readonly $numTypeParams = 1;

    readonly $typeName = ItemDelisted.$typeName;

    readonly $fullTypeName: `0x2::kiosk::ItemDelisted<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly kiosk:
        ToField<ID>
    ; readonly id:
        ToField<ID>

    private constructor(typeArg: string, fields: ItemDelistedFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(ItemDelisted.$typeName,
        typeArg) as `0x2::kiosk::ItemDelisted<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.kiosk = fields.kiosk;; this.id = fields.id;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): ItemDelistedReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: ItemDelisted.$typeName,
            fullTypeName: composeSuiType(
                ItemDelisted.$typeName,
                ...[extractType(T)]
            ) as `0x2::kiosk::ItemDelisted<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                ItemDelisted.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ItemDelisted.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ItemDelisted.fromBcs(
                    T,
                    data,
                ),
            bcs: ItemDelisted.bcs,
            fromJSONField: (field: any) =>
                ItemDelisted.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ItemDelisted.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => ItemDelisted.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: ItemDelistedFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new ItemDelisted(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ItemDelisted.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<ItemDelisted<ToPhantomTypeArgument<T>>>> {
        return phantom(ItemDelisted.reified(
            T
        ));
    }

    static get p() {
        return ItemDelisted.phantom
    }

    static get bcs() {
        return bcs.struct("ItemDelisted", {
            kiosk:
                ID.bcs
            , id:
                ID.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): ItemDelisted<ToPhantomTypeArgument<T>> {
        return ItemDelisted.reified(
            typeArg,
        ).new(
            {kiosk: decodeFromFields(ID.reified(), fields.kiosk), id: decodeFromFields(ID.reified(), fields.id)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): ItemDelisted<ToPhantomTypeArgument<T>> {
        if (!isItemDelisted(item.type)) {
            throw new Error("not a ItemDelisted type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return ItemDelisted.reified(
            typeArg,
        ).new(
            {kiosk: decodeFromFieldsWithTypes(ID.reified(), item.fields.kiosk), id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): ItemDelisted<ToPhantomTypeArgument<T>> {

        return ItemDelisted.fromFields(
            typeArg,
            ItemDelisted.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            kiosk: this.kiosk,id: this.id,

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
    ): ItemDelisted<ToPhantomTypeArgument<T>> {
        return ItemDelisted.reified(
            typeArg,
        ).new(
            {kiosk: decodeFromJSONField(ID.reified(), field.kiosk), id: decodeFromJSONField(ID.reified(), field.id)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): ItemDelisted<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== ItemDelisted.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(ItemDelisted.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return ItemDelisted.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): ItemDelisted<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isItemDelisted(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ItemDelisted object`);
        }
        return ItemDelisted.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<ItemDelisted<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ItemDelisted object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isItemDelisted(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ItemDelisted object`);
        }

        return ItemDelisted.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== ItemListed =============================== */

export function isItemListed(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::kiosk::ItemListed<");
}

export interface ItemListedFields<T extends PhantomTypeArgument> {
    kiosk: ToField<ID>; id: ToField<ID>; price: ToField<"u64">
}

export type ItemListedReified<T extends PhantomTypeArgument> = Reified<
    ItemListed<T>,
    ItemListedFields<T>
>;

export class ItemListed<T extends PhantomTypeArgument> {
    static readonly $typeName = "0x2::kiosk::ItemListed";
    static readonly $numTypeParams = 1;

    readonly $typeName = ItemListed.$typeName;

    readonly $fullTypeName: `0x2::kiosk::ItemListed<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly kiosk:
        ToField<ID>
    ; readonly id:
        ToField<ID>
    ; readonly price:
        ToField<"u64">

    private constructor(typeArg: string, fields: ItemListedFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(ItemListed.$typeName,
        typeArg) as `0x2::kiosk::ItemListed<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.kiosk = fields.kiosk;; this.id = fields.id;; this.price = fields.price;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): ItemListedReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: ItemListed.$typeName,
            fullTypeName: composeSuiType(
                ItemListed.$typeName,
                ...[extractType(T)]
            ) as `0x2::kiosk::ItemListed<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                ItemListed.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ItemListed.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ItemListed.fromBcs(
                    T,
                    data,
                ),
            bcs: ItemListed.bcs,
            fromJSONField: (field: any) =>
                ItemListed.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ItemListed.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => ItemListed.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: ItemListedFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new ItemListed(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ItemListed.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<ItemListed<ToPhantomTypeArgument<T>>>> {
        return phantom(ItemListed.reified(
            T
        ));
    }

    static get p() {
        return ItemListed.phantom
    }

    static get bcs() {
        return bcs.struct("ItemListed", {
            kiosk:
                ID.bcs
            , id:
                ID.bcs
            , price:
                bcs.u64()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): ItemListed<ToPhantomTypeArgument<T>> {
        return ItemListed.reified(
            typeArg,
        ).new(
            {kiosk: decodeFromFields(ID.reified(), fields.kiosk), id: decodeFromFields(ID.reified(), fields.id), price: decodeFromFields("u64", fields.price)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): ItemListed<ToPhantomTypeArgument<T>> {
        if (!isItemListed(item.type)) {
            throw new Error("not a ItemListed type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return ItemListed.reified(
            typeArg,
        ).new(
            {kiosk: decodeFromFieldsWithTypes(ID.reified(), item.fields.kiosk), id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id), price: decodeFromFieldsWithTypes("u64", item.fields.price)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): ItemListed<ToPhantomTypeArgument<T>> {

        return ItemListed.fromFields(
            typeArg,
            ItemListed.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            kiosk: this.kiosk,id: this.id,price: this.price.toString(),

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
    ): ItemListed<ToPhantomTypeArgument<T>> {
        return ItemListed.reified(
            typeArg,
        ).new(
            {kiosk: decodeFromJSONField(ID.reified(), field.kiosk), id: decodeFromJSONField(ID.reified(), field.id), price: decodeFromJSONField("u64", field.price)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): ItemListed<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== ItemListed.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(ItemListed.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return ItemListed.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): ItemListed<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isItemListed(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ItemListed object`);
        }
        return ItemListed.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<ItemListed<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ItemListed object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isItemListed(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ItemListed object`);
        }

        return ItemListed.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== ItemPurchased =============================== */

export function isItemPurchased(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::kiosk::ItemPurchased<");
}

export interface ItemPurchasedFields<T extends PhantomTypeArgument> {
    kiosk: ToField<ID>; id: ToField<ID>; price: ToField<"u64">
}

export type ItemPurchasedReified<T extends PhantomTypeArgument> = Reified<
    ItemPurchased<T>,
    ItemPurchasedFields<T>
>;

export class ItemPurchased<T extends PhantomTypeArgument> {
    static readonly $typeName = "0x2::kiosk::ItemPurchased";
    static readonly $numTypeParams = 1;

    readonly $typeName = ItemPurchased.$typeName;

    readonly $fullTypeName: `0x2::kiosk::ItemPurchased<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly kiosk:
        ToField<ID>
    ; readonly id:
        ToField<ID>
    ; readonly price:
        ToField<"u64">

    private constructor(typeArg: string, fields: ItemPurchasedFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(ItemPurchased.$typeName,
        typeArg) as `0x2::kiosk::ItemPurchased<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.kiosk = fields.kiosk;; this.id = fields.id;; this.price = fields.price;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): ItemPurchasedReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: ItemPurchased.$typeName,
            fullTypeName: composeSuiType(
                ItemPurchased.$typeName,
                ...[extractType(T)]
            ) as `0x2::kiosk::ItemPurchased<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                ItemPurchased.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ItemPurchased.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ItemPurchased.fromBcs(
                    T,
                    data,
                ),
            bcs: ItemPurchased.bcs,
            fromJSONField: (field: any) =>
                ItemPurchased.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ItemPurchased.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => ItemPurchased.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: ItemPurchasedFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new ItemPurchased(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ItemPurchased.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<ItemPurchased<ToPhantomTypeArgument<T>>>> {
        return phantom(ItemPurchased.reified(
            T
        ));
    }

    static get p() {
        return ItemPurchased.phantom
    }

    static get bcs() {
        return bcs.struct("ItemPurchased", {
            kiosk:
                ID.bcs
            , id:
                ID.bcs
            , price:
                bcs.u64()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): ItemPurchased<ToPhantomTypeArgument<T>> {
        return ItemPurchased.reified(
            typeArg,
        ).new(
            {kiosk: decodeFromFields(ID.reified(), fields.kiosk), id: decodeFromFields(ID.reified(), fields.id), price: decodeFromFields("u64", fields.price)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): ItemPurchased<ToPhantomTypeArgument<T>> {
        if (!isItemPurchased(item.type)) {
            throw new Error("not a ItemPurchased type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return ItemPurchased.reified(
            typeArg,
        ).new(
            {kiosk: decodeFromFieldsWithTypes(ID.reified(), item.fields.kiosk), id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id), price: decodeFromFieldsWithTypes("u64", item.fields.price)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): ItemPurchased<ToPhantomTypeArgument<T>> {

        return ItemPurchased.fromFields(
            typeArg,
            ItemPurchased.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            kiosk: this.kiosk,id: this.id,price: this.price.toString(),

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
    ): ItemPurchased<ToPhantomTypeArgument<T>> {
        return ItemPurchased.reified(
            typeArg,
        ).new(
            {kiosk: decodeFromJSONField(ID.reified(), field.kiosk), id: decodeFromJSONField(ID.reified(), field.id), price: decodeFromJSONField("u64", field.price)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): ItemPurchased<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== ItemPurchased.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(ItemPurchased.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return ItemPurchased.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): ItemPurchased<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isItemPurchased(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ItemPurchased object`);
        }
        return ItemPurchased.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<ItemPurchased<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ItemPurchased object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isItemPurchased(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ItemPurchased object`);
        }

        return ItemPurchased.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Kiosk =============================== */

export function isKiosk(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::kiosk::Kiosk";
}

export interface KioskFields {
    id: ToField<UID>; profits: ToField<Balance<ToPhantom<SUI>>>; owner: ToField<"address">; itemCount: ToField<"u32">; allowExtensions: ToField<"bool">
}

export type KioskReified = Reified<
    Kiosk,
    KioskFields
>;

export class Kiosk {
    static readonly $typeName = "0x2::kiosk::Kiosk";
    static readonly $numTypeParams = 0;

    readonly $typeName = Kiosk.$typeName;

    readonly $fullTypeName: "0x2::kiosk::Kiosk";

    ;

    readonly id:
        ToField<UID>
    ; readonly profits:
        ToField<Balance<ToPhantom<SUI>>>
    ; readonly owner:
        ToField<"address">
    ; readonly itemCount:
        ToField<"u32">
    ; readonly allowExtensions:
        ToField<"bool">

    private constructor( fields: KioskFields,
    ) {
        this.$fullTypeName = Kiosk.$typeName;

        this.id = fields.id;; this.profits = fields.profits;; this.owner = fields.owner;; this.itemCount = fields.itemCount;; this.allowExtensions = fields.allowExtensions;
    }

    static reified(): KioskReified {
        return {
            typeName: Kiosk.$typeName,
            fullTypeName: composeSuiType(
                Kiosk.$typeName,
                ...[]
            ) as "0x2::kiosk::Kiosk",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Kiosk.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Kiosk.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Kiosk.fromBcs(
                    data,
                ),
            bcs: Kiosk.bcs,
            fromJSONField: (field: any) =>
                Kiosk.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Kiosk.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Kiosk.fetch(
                client,
                id,
            ),
            new: (
                fields: KioskFields,
            ) => {
                return new Kiosk(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Kiosk.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Kiosk>> {
        return phantom(Kiosk.reified());
    }

    static get p() {
        return Kiosk.phantom()
    }

    static get bcs() {
        return bcs.struct("Kiosk", {
            id:
                UID.bcs
            , profits:
                Balance.bcs
            , owner:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , item_count:
                bcs.u32()
            , allow_extensions:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Kiosk {
        return Kiosk.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), profits: decodeFromFields(Balance.reified(reified.phantom(SUI.reified())), fields.profits), owner: decodeFromFields("address", fields.owner), itemCount: decodeFromFields("u32", fields.item_count), allowExtensions: decodeFromFields("bool", fields.allow_extensions)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Kiosk {
        if (!isKiosk(item.type)) {
            throw new Error("not a Kiosk type");
        }

        return Kiosk.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), profits: decodeFromFieldsWithTypes(Balance.reified(reified.phantom(SUI.reified())), item.fields.profits), owner: decodeFromFieldsWithTypes("address", item.fields.owner), itemCount: decodeFromFieldsWithTypes("u32", item.fields.item_count), allowExtensions: decodeFromFieldsWithTypes("bool", item.fields.allow_extensions)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Kiosk {

        return Kiosk.fromFields(
            Kiosk.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,profits: this.profits.toJSONField(),owner: this.owner,itemCount: this.itemCount,allowExtensions: this.allowExtensions,

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
    ): Kiosk {
        return Kiosk.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), profits: decodeFromJSONField(Balance.reified(reified.phantom(SUI.reified())), field.profits), owner: decodeFromJSONField("address", field.owner), itemCount: decodeFromJSONField("u32", field.itemCount), allowExtensions: decodeFromJSONField("bool", field.allowExtensions)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Kiosk {
        if (json.$typeName !== Kiosk.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Kiosk.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Kiosk {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isKiosk(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Kiosk object`);
        }
        return Kiosk.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Kiosk> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Kiosk object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isKiosk(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Kiosk object`);
        }

        return Kiosk.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== KioskOwnerCap =============================== */

export function isKioskOwnerCap(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::kiosk::KioskOwnerCap";
}

export interface KioskOwnerCapFields {
    id: ToField<UID>; for: ToField<ID>
}

export type KioskOwnerCapReified = Reified<
    KioskOwnerCap,
    KioskOwnerCapFields
>;

export class KioskOwnerCap {
    static readonly $typeName = "0x2::kiosk::KioskOwnerCap";
    static readonly $numTypeParams = 0;

    readonly $typeName = KioskOwnerCap.$typeName;

    readonly $fullTypeName: "0x2::kiosk::KioskOwnerCap";

    ;

    readonly id:
        ToField<UID>
    ; readonly for:
        ToField<ID>

    private constructor( fields: KioskOwnerCapFields,
    ) {
        this.$fullTypeName = KioskOwnerCap.$typeName;

        this.id = fields.id;; this.for = fields.for;
    }

    static reified(): KioskOwnerCapReified {
        return {
            typeName: KioskOwnerCap.$typeName,
            fullTypeName: composeSuiType(
                KioskOwnerCap.$typeName,
                ...[]
            ) as "0x2::kiosk::KioskOwnerCap",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                KioskOwnerCap.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                KioskOwnerCap.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                KioskOwnerCap.fromBcs(
                    data,
                ),
            bcs: KioskOwnerCap.bcs,
            fromJSONField: (field: any) =>
                KioskOwnerCap.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                KioskOwnerCap.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => KioskOwnerCap.fetch(
                client,
                id,
            ),
            new: (
                fields: KioskOwnerCapFields,
            ) => {
                return new KioskOwnerCap(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return KioskOwnerCap.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<KioskOwnerCap>> {
        return phantom(KioskOwnerCap.reified());
    }

    static get p() {
        return KioskOwnerCap.phantom()
    }

    static get bcs() {
        return bcs.struct("KioskOwnerCap", {
            id:
                UID.bcs
            , for:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): KioskOwnerCap {
        return KioskOwnerCap.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), for: decodeFromFields(ID.reified(), fields.for)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): KioskOwnerCap {
        if (!isKioskOwnerCap(item.type)) {
            throw new Error("not a KioskOwnerCap type");
        }

        return KioskOwnerCap.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), for: decodeFromFieldsWithTypes(ID.reified(), item.fields.for)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): KioskOwnerCap {

        return KioskOwnerCap.fromFields(
            KioskOwnerCap.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,for: this.for,

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
    ): KioskOwnerCap {
        return KioskOwnerCap.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), for: decodeFromJSONField(ID.reified(), field.for)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): KioskOwnerCap {
        if (json.$typeName !== KioskOwnerCap.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return KioskOwnerCap.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): KioskOwnerCap {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isKioskOwnerCap(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a KioskOwnerCap object`);
        }
        return KioskOwnerCap.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<KioskOwnerCap> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching KioskOwnerCap object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isKioskOwnerCap(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a KioskOwnerCap object`);
        }

        return KioskOwnerCap.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Listing =============================== */

export function isListing(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::kiosk::Listing";
}

export interface ListingFields {
    id: ToField<ID>; isExclusive: ToField<"bool">
}

export type ListingReified = Reified<
    Listing,
    ListingFields
>;

export class Listing {
    static readonly $typeName = "0x2::kiosk::Listing";
    static readonly $numTypeParams = 0;

    readonly $typeName = Listing.$typeName;

    readonly $fullTypeName: "0x2::kiosk::Listing";

    ;

    readonly id:
        ToField<ID>
    ; readonly isExclusive:
        ToField<"bool">

    private constructor( fields: ListingFields,
    ) {
        this.$fullTypeName = Listing.$typeName;

        this.id = fields.id;; this.isExclusive = fields.isExclusive;
    }

    static reified(): ListingReified {
        return {
            typeName: Listing.$typeName,
            fullTypeName: composeSuiType(
                Listing.$typeName,
                ...[]
            ) as "0x2::kiosk::Listing",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Listing.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Listing.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Listing.fromBcs(
                    data,
                ),
            bcs: Listing.bcs,
            fromJSONField: (field: any) =>
                Listing.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Listing.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Listing.fetch(
                client,
                id,
            ),
            new: (
                fields: ListingFields,
            ) => {
                return new Listing(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Listing.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Listing>> {
        return phantom(Listing.reified());
    }

    static get p() {
        return Listing.phantom()
    }

    static get bcs() {
        return bcs.struct("Listing", {
            id:
                ID.bcs
            , is_exclusive:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Listing {
        return Listing.reified().new(
            {id: decodeFromFields(ID.reified(), fields.id), isExclusive: decodeFromFields("bool", fields.is_exclusive)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Listing {
        if (!isListing(item.type)) {
            throw new Error("not a Listing type");
        }

        return Listing.reified().new(
            {id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id), isExclusive: decodeFromFieldsWithTypes("bool", item.fields.is_exclusive)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Listing {

        return Listing.fromFields(
            Listing.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,isExclusive: this.isExclusive,

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
    ): Listing {
        return Listing.reified().new(
            {id: decodeFromJSONField(ID.reified(), field.id), isExclusive: decodeFromJSONField("bool", field.isExclusive)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Listing {
        if (json.$typeName !== Listing.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Listing.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Listing {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isListing(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Listing object`);
        }
        return Listing.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Listing> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Listing object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isListing(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Listing object`);
        }

        return Listing.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Lock =============================== */

export function isLock(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::kiosk::Lock";
}

export interface LockFields {
    id: ToField<ID>
}

export type LockReified = Reified<
    Lock,
    LockFields
>;

export class Lock {
    static readonly $typeName = "0x2::kiosk::Lock";
    static readonly $numTypeParams = 0;

    readonly $typeName = Lock.$typeName;

    readonly $fullTypeName: "0x2::kiosk::Lock";

    ;

    readonly id:
        ToField<ID>

    private constructor( fields: LockFields,
    ) {
        this.$fullTypeName = Lock.$typeName;

        this.id = fields.id;
    }

    static reified(): LockReified {
        return {
            typeName: Lock.$typeName,
            fullTypeName: composeSuiType(
                Lock.$typeName,
                ...[]
            ) as "0x2::kiosk::Lock",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Lock.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Lock.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Lock.fromBcs(
                    data,
                ),
            bcs: Lock.bcs,
            fromJSONField: (field: any) =>
                Lock.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Lock.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Lock.fetch(
                client,
                id,
            ),
            new: (
                fields: LockFields,
            ) => {
                return new Lock(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Lock.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Lock>> {
        return phantom(Lock.reified());
    }

    static get p() {
        return Lock.phantom()
    }

    static get bcs() {
        return bcs.struct("Lock", {
            id:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Lock {
        return Lock.reified().new(
            {id: decodeFromFields(ID.reified(), fields.id)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Lock {
        if (!isLock(item.type)) {
            throw new Error("not a Lock type");
        }

        return Lock.reified().new(
            {id: decodeFromFieldsWithTypes(ID.reified(), item.fields.id)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Lock {

        return Lock.fromFields(
            Lock.bcs.parse(data)
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
            ...this.toJSONField()
        }
    }

    static fromJSONField(
         field: any
    ): Lock {
        return Lock.reified().new(
            {id: decodeFromJSONField(ID.reified(), field.id)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Lock {
        if (json.$typeName !== Lock.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Lock.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Lock {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isLock(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Lock object`);
        }
        return Lock.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Lock> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Lock object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isLock(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Lock object`);
        }

        return Lock.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== PurchaseCap =============================== */

export function isPurchaseCap(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x2::kiosk::PurchaseCap<");
}

export interface PurchaseCapFields<T extends PhantomTypeArgument> {
    id: ToField<UID>; kioskId: ToField<ID>; itemId: ToField<ID>; minPrice: ToField<"u64">
}

export type PurchaseCapReified<T extends PhantomTypeArgument> = Reified<
    PurchaseCap<T>,
    PurchaseCapFields<T>
>;

export class PurchaseCap<T extends PhantomTypeArgument> {
    static readonly $typeName = "0x2::kiosk::PurchaseCap";
    static readonly $numTypeParams = 1;

    readonly $typeName = PurchaseCap.$typeName;

    readonly $fullTypeName: `0x2::kiosk::PurchaseCap<${PhantomToTypeStr<T>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly kioskId:
        ToField<ID>
    ; readonly itemId:
        ToField<ID>
    ; readonly minPrice:
        ToField<"u64">

    private constructor(typeArg: string, fields: PurchaseCapFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(PurchaseCap.$typeName,
        typeArg) as `0x2::kiosk::PurchaseCap<${PhantomToTypeStr<T>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.kioskId = fields.kioskId;; this.itemId = fields.itemId;; this.minPrice = fields.minPrice;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PurchaseCapReified<ToPhantomTypeArgument<T>> {
        return {
            typeName: PurchaseCap.$typeName,
            fullTypeName: composeSuiType(
                PurchaseCap.$typeName,
                ...[extractType(T)]
            ) as `0x2::kiosk::PurchaseCap<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                PurchaseCap.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                PurchaseCap.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                PurchaseCap.fromBcs(
                    T,
                    data,
                ),
            bcs: PurchaseCap.bcs,
            fromJSONField: (field: any) =>
                PurchaseCap.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                PurchaseCap.fromJSON(
                    T,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => PurchaseCap.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: PurchaseCapFields<ToPhantomTypeArgument<T>>,
            ) => {
                return new PurchaseCap(
                    extractType(T),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return PurchaseCap.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>>(
        T: T
    ): PhantomReified<ToTypeStr<PurchaseCap<ToPhantomTypeArgument<T>>>> {
        return phantom(PurchaseCap.reified(
            T
        ));
    }

    static get p() {
        return PurchaseCap.phantom
    }

    static get bcs() {
        return bcs.struct("PurchaseCap", {
            id:
                UID.bcs
            , kiosk_id:
                ID.bcs
            , item_id:
                ID.bcs
            , min_price:
                bcs.u64()

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, fields: Record<string, any>
    ): PurchaseCap<ToPhantomTypeArgument<T>> {
        return PurchaseCap.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), kioskId: decodeFromFields(ID.reified(), fields.kiosk_id), itemId: decodeFromFields(ID.reified(), fields.item_id), minPrice: decodeFromFields("u64", fields.min_price)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, item: FieldsWithTypes
    ): PurchaseCap<ToPhantomTypeArgument<T>> {
        if (!isPurchaseCap(item.type)) {
            throw new Error("not a PurchaseCap type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return PurchaseCap.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), kioskId: decodeFromFieldsWithTypes(ID.reified(), item.fields.kiosk_id), itemId: decodeFromFieldsWithTypes(ID.reified(), item.fields.item_id), minPrice: decodeFromFieldsWithTypes("u64", item.fields.min_price)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, data: Uint8Array
    ): PurchaseCap<ToPhantomTypeArgument<T>> {

        return PurchaseCap.fromFields(
            typeArg,
            PurchaseCap.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,kioskId: this.kioskId,itemId: this.itemId,minPrice: this.minPrice.toString(),

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
    ): PurchaseCap<ToPhantomTypeArgument<T>> {
        return PurchaseCap.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), kioskId: decodeFromJSONField(ID.reified(), field.kioskId), itemId: decodeFromJSONField(ID.reified(), field.itemId), minPrice: decodeFromJSONField("u64", field.minPrice)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, json: Record<string, any>
    ): PurchaseCap<ToPhantomTypeArgument<T>> {
        if (json.$typeName !== PurchaseCap.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(PurchaseCap.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return PurchaseCap.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>>(
        typeArg: T, content: SuiParsedData
    ): PurchaseCap<ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isPurchaseCap(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a PurchaseCap object`);
        }
        return PurchaseCap.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<PurchaseCap<ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching PurchaseCap object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isPurchaseCap(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a PurchaseCap object`);
        }

        return PurchaseCap.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
