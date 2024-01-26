import * as reified from "../../_framework/reified";
import {String} from "../../_dependencies/source/0x1/ascii/structs";
import {Option} from "../../_dependencies/source/0x1/option/structs";
import {ObjectBag} from "../../_dependencies/source/0x2/object-bag/structs";
import {ObjectTable} from "../../_dependencies/source/0x2/object-table/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, fieldToJSON, phantom, ToTypeStr as ToPhantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {ObjectBox} from "../../originmate/object-box/structs";
import {TypedID} from "../../originmate/typed-id/structs";
import {Marketplace} from "../marketplace/structs";
import {Proceeds} from "../proceeds/structs";
import {Venue} from "../venue/structs";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Listing =============================== */

export function isListing(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::Listing";
}

export interface ListingFields {
    id: ToField<UID>; version: ToField<"u64">; marketplaceId: ToField<Option<TypedID<ToPhantom<Marketplace>>>>; admin: ToField<"address">; receiver: ToField<"address">; proceeds: ToField<Proceeds>; venues: ToField<ObjectTable<ToPhantom<ID>, ToPhantom<Venue>>>; inventories: ToField<ObjectBag>; customFee: ToField<ObjectBox>
}

export type ListingReified = Reified<
    Listing,
    ListingFields
>;

export class Listing {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::Listing";
    static readonly $numTypeParams = 0;

    readonly $typeName = Listing.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::Listing";

    ;

    readonly id:
        ToField<UID>
    ; readonly version:
        ToField<"u64">
    ; readonly marketplaceId:
        ToField<Option<TypedID<ToPhantom<Marketplace>>>>
    ; readonly admin:
        ToField<"address">
    ; readonly receiver:
        ToField<"address">
    ; readonly proceeds:
        ToField<Proceeds>
    ; readonly venues:
        ToField<ObjectTable<ToPhantom<ID>, ToPhantom<Venue>>>
    ; readonly inventories:
        ToField<ObjectBag>
    ; readonly customFee:
        ToField<ObjectBox>

    private constructor( fields: ListingFields,
    ) {
        this.$fullTypeName = Listing.$typeName;

        this.id = fields.id;; this.version = fields.version;; this.marketplaceId = fields.marketplaceId;; this.admin = fields.admin;; this.receiver = fields.receiver;; this.proceeds = fields.proceeds;; this.venues = fields.venues;; this.inventories = fields.inventories;; this.customFee = fields.customFee;
    }

    static reified(): ListingReified {
        return {
            typeName: Listing.$typeName,
            fullTypeName: composeSuiType(
                Listing.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::Listing",
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
                UID.bcs
            , version:
                bcs.u64()
            , marketplace_id:
                Option.bcs(TypedID.bcs)
            , admin:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , receiver:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , proceeds:
                Proceeds.bcs
            , venues:
                ObjectTable.bcs
            , inventories:
                ObjectBag.bcs
            , custom_fee:
                ObjectBox.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Listing {
        return Listing.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), version: decodeFromFields("u64", fields.version), marketplaceId: decodeFromFields(Option.reified(TypedID.reified(reified.phantom(Marketplace.reified()))), fields.marketplace_id), admin: decodeFromFields("address", fields.admin), receiver: decodeFromFields("address", fields.receiver), proceeds: decodeFromFields(Proceeds.reified(), fields.proceeds), venues: decodeFromFields(ObjectTable.reified(reified.phantom(ID.reified()), reified.phantom(Venue.reified())), fields.venues), inventories: decodeFromFields(ObjectBag.reified(), fields.inventories), customFee: decodeFromFields(ObjectBox.reified(), fields.custom_fee)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Listing {
        if (!isListing(item.type)) {
            throw new Error("not a Listing type");
        }

        return Listing.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), version: decodeFromFieldsWithTypes("u64", item.fields.version), marketplaceId: decodeFromFieldsWithTypes(Option.reified(TypedID.reified(reified.phantom(Marketplace.reified()))), item.fields.marketplace_id), admin: decodeFromFieldsWithTypes("address", item.fields.admin), receiver: decodeFromFieldsWithTypes("address", item.fields.receiver), proceeds: decodeFromFieldsWithTypes(Proceeds.reified(), item.fields.proceeds), venues: decodeFromFieldsWithTypes(ObjectTable.reified(reified.phantom(ID.reified()), reified.phantom(Venue.reified())), item.fields.venues), inventories: decodeFromFieldsWithTypes(ObjectBag.reified(), item.fields.inventories), customFee: decodeFromFieldsWithTypes(ObjectBox.reified(), item.fields.custom_fee)}
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
            id: this.id,version: this.version.toString(),marketplaceId: fieldToJSON<Option<TypedID<ToPhantom<Marketplace>>>>(`0x1::option::Option<0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::typed_id::TypedID<0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::marketplace::Marketplace>>`, this.marketplaceId),admin: this.admin,receiver: this.receiver,proceeds: this.proceeds.toJSONField(),venues: this.venues.toJSONField(),inventories: this.inventories.toJSONField(),customFee: this.customFee.toJSONField(),

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
            {id: decodeFromJSONField(UID.reified(), field.id), version: decodeFromJSONField("u64", field.version), marketplaceId: decodeFromJSONField(Option.reified(TypedID.reified(reified.phantom(Marketplace.reified()))), field.marketplaceId), admin: decodeFromJSONField("address", field.admin), receiver: decodeFromJSONField("address", field.receiver), proceeds: decodeFromJSONField(Proceeds.reified(), field.proceeds), venues: decodeFromJSONField(ObjectTable.reified(reified.phantom(ID.reified()), reified.phantom(Venue.reified())), field.venues), inventories: decodeFromJSONField(ObjectBag.reified(), field.inventories), customFee: decodeFromJSONField(ObjectBox.reified(), field.customFee)}
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

/* ============================== MembersDfKey =============================== */

export function isMembersDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc0c5ca1e59bbb0e7330c8f182cbad262717faf7d8d0d7f7da4b3146391ecbbe1::listing::MembersDfKey";
}

export interface MembersDfKeyFields {
    dummyField: ToField<"bool">
}

export type MembersDfKeyReified = Reified<
    MembersDfKey,
    MembersDfKeyFields
>;

export class MembersDfKey {
    static readonly $typeName = "0xc0c5ca1e59bbb0e7330c8f182cbad262717faf7d8d0d7f7da4b3146391ecbbe1::listing::MembersDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = MembersDfKey.$typeName;

    readonly $fullTypeName: "0xc0c5ca1e59bbb0e7330c8f182cbad262717faf7d8d0d7f7da4b3146391ecbbe1::listing::MembersDfKey";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: MembersDfKeyFields,
    ) {
        this.$fullTypeName = MembersDfKey.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): MembersDfKeyReified {
        return {
            typeName: MembersDfKey.$typeName,
            fullTypeName: composeSuiType(
                MembersDfKey.$typeName,
                ...[]
            ) as "0xc0c5ca1e59bbb0e7330c8f182cbad262717faf7d8d0d7f7da4b3146391ecbbe1::listing::MembersDfKey",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                MembersDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                MembersDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                MembersDfKey.fromBcs(
                    data,
                ),
            bcs: MembersDfKey.bcs,
            fromJSONField: (field: any) =>
                MembersDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                MembersDfKey.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => MembersDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: MembersDfKeyFields,
            ) => {
                return new MembersDfKey(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return MembersDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<MembersDfKey>> {
        return phantom(MembersDfKey.reified());
    }

    static get p() {
        return MembersDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("MembersDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): MembersDfKey {
        return MembersDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): MembersDfKey {
        if (!isMembersDfKey(item.type)) {
            throw new Error("not a MembersDfKey type");
        }

        return MembersDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): MembersDfKey {

        return MembersDfKey.fromFields(
            MembersDfKey.bcs.parse(data)
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
            ...this.toJSONField()
        }
    }

    static fromJSONField(
         field: any
    ): MembersDfKey {
        return MembersDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): MembersDfKey {
        if (json.$typeName !== MembersDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return MembersDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): MembersDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isMembersDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a MembersDfKey object`);
        }
        return MembersDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<MembersDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching MembersDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isMembersDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a MembersDfKey object`);
        }

        return MembersDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== CreateListingEvent =============================== */

export function isCreateListingEvent(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::CreateListingEvent";
}

export interface CreateListingEventFields {
    listingId: ToField<ID>
}

export type CreateListingEventReified = Reified<
    CreateListingEvent,
    CreateListingEventFields
>;

export class CreateListingEvent {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::CreateListingEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = CreateListingEvent.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::CreateListingEvent";

    ;

    readonly listingId:
        ToField<ID>

    private constructor( fields: CreateListingEventFields,
    ) {
        this.$fullTypeName = CreateListingEvent.$typeName;

        this.listingId = fields.listingId;
    }

    static reified(): CreateListingEventReified {
        return {
            typeName: CreateListingEvent.$typeName,
            fullTypeName: composeSuiType(
                CreateListingEvent.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::CreateListingEvent",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                CreateListingEvent.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                CreateListingEvent.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                CreateListingEvent.fromBcs(
                    data,
                ),
            bcs: CreateListingEvent.bcs,
            fromJSONField: (field: any) =>
                CreateListingEvent.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                CreateListingEvent.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => CreateListingEvent.fetch(
                client,
                id,
            ),
            new: (
                fields: CreateListingEventFields,
            ) => {
                return new CreateListingEvent(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return CreateListingEvent.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<CreateListingEvent>> {
        return phantom(CreateListingEvent.reified());
    }

    static get p() {
        return CreateListingEvent.phantom()
    }

    static get bcs() {
        return bcs.struct("CreateListingEvent", {
            listing_id:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): CreateListingEvent {
        return CreateListingEvent.reified().new(
            {listingId: decodeFromFields(ID.reified(), fields.listing_id)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): CreateListingEvent {
        if (!isCreateListingEvent(item.type)) {
            throw new Error("not a CreateListingEvent type");
        }

        return CreateListingEvent.reified().new(
            {listingId: decodeFromFieldsWithTypes(ID.reified(), item.fields.listing_id)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): CreateListingEvent {

        return CreateListingEvent.fromFields(
            CreateListingEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            listingId: this.listingId,

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
    ): CreateListingEvent {
        return CreateListingEvent.reified().new(
            {listingId: decodeFromJSONField(ID.reified(), field.listingId)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): CreateListingEvent {
        if (json.$typeName !== CreateListingEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return CreateListingEvent.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): CreateListingEvent {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isCreateListingEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a CreateListingEvent object`);
        }
        return CreateListingEvent.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<CreateListingEvent> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching CreateListingEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isCreateListingEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a CreateListingEvent object`);
        }

        return CreateListingEvent.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== DeleteListingEvent =============================== */

export function isDeleteListingEvent(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::DeleteListingEvent";
}

export interface DeleteListingEventFields {
    listingId: ToField<ID>
}

export type DeleteListingEventReified = Reified<
    DeleteListingEvent,
    DeleteListingEventFields
>;

export class DeleteListingEvent {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::DeleteListingEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = DeleteListingEvent.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::DeleteListingEvent";

    ;

    readonly listingId:
        ToField<ID>

    private constructor( fields: DeleteListingEventFields,
    ) {
        this.$fullTypeName = DeleteListingEvent.$typeName;

        this.listingId = fields.listingId;
    }

    static reified(): DeleteListingEventReified {
        return {
            typeName: DeleteListingEvent.$typeName,
            fullTypeName: composeSuiType(
                DeleteListingEvent.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::DeleteListingEvent",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                DeleteListingEvent.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                DeleteListingEvent.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                DeleteListingEvent.fromBcs(
                    data,
                ),
            bcs: DeleteListingEvent.bcs,
            fromJSONField: (field: any) =>
                DeleteListingEvent.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                DeleteListingEvent.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => DeleteListingEvent.fetch(
                client,
                id,
            ),
            new: (
                fields: DeleteListingEventFields,
            ) => {
                return new DeleteListingEvent(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return DeleteListingEvent.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<DeleteListingEvent>> {
        return phantom(DeleteListingEvent.reified());
    }

    static get p() {
        return DeleteListingEvent.phantom()
    }

    static get bcs() {
        return bcs.struct("DeleteListingEvent", {
            listing_id:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): DeleteListingEvent {
        return DeleteListingEvent.reified().new(
            {listingId: decodeFromFields(ID.reified(), fields.listing_id)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): DeleteListingEvent {
        if (!isDeleteListingEvent(item.type)) {
            throw new Error("not a DeleteListingEvent type");
        }

        return DeleteListingEvent.reified().new(
            {listingId: decodeFromFieldsWithTypes(ID.reified(), item.fields.listing_id)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): DeleteListingEvent {

        return DeleteListingEvent.fromFields(
            DeleteListingEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            listingId: this.listingId,

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
    ): DeleteListingEvent {
        return DeleteListingEvent.reified().new(
            {listingId: decodeFromJSONField(ID.reified(), field.listingId)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): DeleteListingEvent {
        if (json.$typeName !== DeleteListingEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return DeleteListingEvent.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): DeleteListingEvent {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isDeleteListingEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a DeleteListingEvent object`);
        }
        return DeleteListingEvent.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<DeleteListingEvent> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching DeleteListingEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isDeleteListingEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a DeleteListingEvent object`);
        }

        return DeleteListingEvent.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== NftSoldEvent =============================== */

export function isNftSoldEvent(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::NftSoldEvent";
}

export interface NftSoldEventFields {
    nft: ToField<ID>; price: ToField<"u64">; ftType: ToField<String>; nftType: ToField<String>; buyer: ToField<"address">
}

export type NftSoldEventReified = Reified<
    NftSoldEvent,
    NftSoldEventFields
>;

export class NftSoldEvent {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::NftSoldEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = NftSoldEvent.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::NftSoldEvent";

    ;

    readonly nft:
        ToField<ID>
    ; readonly price:
        ToField<"u64">
    ; readonly ftType:
        ToField<String>
    ; readonly nftType:
        ToField<String>
    ; readonly buyer:
        ToField<"address">

    private constructor( fields: NftSoldEventFields,
    ) {
        this.$fullTypeName = NftSoldEvent.$typeName;

        this.nft = fields.nft;; this.price = fields.price;; this.ftType = fields.ftType;; this.nftType = fields.nftType;; this.buyer = fields.buyer;
    }

    static reified(): NftSoldEventReified {
        return {
            typeName: NftSoldEvent.$typeName,
            fullTypeName: composeSuiType(
                NftSoldEvent.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::NftSoldEvent",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                NftSoldEvent.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                NftSoldEvent.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                NftSoldEvent.fromBcs(
                    data,
                ),
            bcs: NftSoldEvent.bcs,
            fromJSONField: (field: any) =>
                NftSoldEvent.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                NftSoldEvent.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => NftSoldEvent.fetch(
                client,
                id,
            ),
            new: (
                fields: NftSoldEventFields,
            ) => {
                return new NftSoldEvent(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return NftSoldEvent.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<NftSoldEvent>> {
        return phantom(NftSoldEvent.reified());
    }

    static get p() {
        return NftSoldEvent.phantom()
    }

    static get bcs() {
        return bcs.struct("NftSoldEvent", {
            nft:
                ID.bcs
            , price:
                bcs.u64()
            , ft_type:
                String.bcs
            , nft_type:
                String.bcs
            , buyer:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): NftSoldEvent {
        return NftSoldEvent.reified().new(
            {nft: decodeFromFields(ID.reified(), fields.nft), price: decodeFromFields("u64", fields.price), ftType: decodeFromFields(String.reified(), fields.ft_type), nftType: decodeFromFields(String.reified(), fields.nft_type), buyer: decodeFromFields("address", fields.buyer)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): NftSoldEvent {
        if (!isNftSoldEvent(item.type)) {
            throw new Error("not a NftSoldEvent type");
        }

        return NftSoldEvent.reified().new(
            {nft: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft), price: decodeFromFieldsWithTypes("u64", item.fields.price), ftType: decodeFromFieldsWithTypes(String.reified(), item.fields.ft_type), nftType: decodeFromFieldsWithTypes(String.reified(), item.fields.nft_type), buyer: decodeFromFieldsWithTypes("address", item.fields.buyer)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): NftSoldEvent {

        return NftSoldEvent.fromFields(
            NftSoldEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            nft: this.nft,price: this.price.toString(),ftType: this.ftType,nftType: this.nftType,buyer: this.buyer,

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
    ): NftSoldEvent {
        return NftSoldEvent.reified().new(
            {nft: decodeFromJSONField(ID.reified(), field.nft), price: decodeFromJSONField("u64", field.price), ftType: decodeFromJSONField(String.reified(), field.ftType), nftType: decodeFromJSONField(String.reified(), field.nftType), buyer: decodeFromJSONField("address", field.buyer)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): NftSoldEvent {
        if (json.$typeName !== NftSoldEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return NftSoldEvent.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): NftSoldEvent {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isNftSoldEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a NftSoldEvent object`);
        }
        return NftSoldEvent.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<NftSoldEvent> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching NftSoldEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isNftSoldEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a NftSoldEvent object`);
        }

        return NftSoldEvent.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== RequestToJoin =============================== */

export function isRequestToJoin(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::RequestToJoin";
}

export interface RequestToJoinFields {
    id: ToField<UID>; marketplaceId: ToField<TypedID<ToPhantom<Marketplace>>>
}

export type RequestToJoinReified = Reified<
    RequestToJoin,
    RequestToJoinFields
>;

export class RequestToJoin {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::RequestToJoin";
    static readonly $numTypeParams = 0;

    readonly $typeName = RequestToJoin.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::RequestToJoin";

    ;

    readonly id:
        ToField<UID>
    ; readonly marketplaceId:
        ToField<TypedID<ToPhantom<Marketplace>>>

    private constructor( fields: RequestToJoinFields,
    ) {
        this.$fullTypeName = RequestToJoin.$typeName;

        this.id = fields.id;; this.marketplaceId = fields.marketplaceId;
    }

    static reified(): RequestToJoinReified {
        return {
            typeName: RequestToJoin.$typeName,
            fullTypeName: composeSuiType(
                RequestToJoin.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::RequestToJoin",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                RequestToJoin.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                RequestToJoin.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                RequestToJoin.fromBcs(
                    data,
                ),
            bcs: RequestToJoin.bcs,
            fromJSONField: (field: any) =>
                RequestToJoin.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                RequestToJoin.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => RequestToJoin.fetch(
                client,
                id,
            ),
            new: (
                fields: RequestToJoinFields,
            ) => {
                return new RequestToJoin(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return RequestToJoin.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<RequestToJoin>> {
        return phantom(RequestToJoin.reified());
    }

    static get p() {
        return RequestToJoin.phantom()
    }

    static get bcs() {
        return bcs.struct("RequestToJoin", {
            id:
                UID.bcs
            , marketplace_id:
                TypedID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): RequestToJoin {
        return RequestToJoin.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), marketplaceId: decodeFromFields(TypedID.reified(reified.phantom(Marketplace.reified())), fields.marketplace_id)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): RequestToJoin {
        if (!isRequestToJoin(item.type)) {
            throw new Error("not a RequestToJoin type");
        }

        return RequestToJoin.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), marketplaceId: decodeFromFieldsWithTypes(TypedID.reified(reified.phantom(Marketplace.reified())), item.fields.marketplace_id)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): RequestToJoin {

        return RequestToJoin.fromFields(
            RequestToJoin.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,marketplaceId: this.marketplaceId.toJSONField(),

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
    ): RequestToJoin {
        return RequestToJoin.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), marketplaceId: decodeFromJSONField(TypedID.reified(reified.phantom(Marketplace.reified())), field.marketplaceId)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): RequestToJoin {
        if (json.$typeName !== RequestToJoin.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return RequestToJoin.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): RequestToJoin {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isRequestToJoin(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a RequestToJoin object`);
        }
        return RequestToJoin.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<RequestToJoin> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching RequestToJoin object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isRequestToJoin(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a RequestToJoin object`);
        }

        return RequestToJoin.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== RequestToJoinDfKey =============================== */

export function isRequestToJoinDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::RequestToJoinDfKey";
}

export interface RequestToJoinDfKeyFields {
    dummyField: ToField<"bool">
}

export type RequestToJoinDfKeyReified = Reified<
    RequestToJoinDfKey,
    RequestToJoinDfKeyFields
>;

export class RequestToJoinDfKey {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::RequestToJoinDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = RequestToJoinDfKey.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::RequestToJoinDfKey";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: RequestToJoinDfKeyFields,
    ) {
        this.$fullTypeName = RequestToJoinDfKey.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): RequestToJoinDfKeyReified {
        return {
            typeName: RequestToJoinDfKey.$typeName,
            fullTypeName: composeSuiType(
                RequestToJoinDfKey.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::RequestToJoinDfKey",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                RequestToJoinDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                RequestToJoinDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                RequestToJoinDfKey.fromBcs(
                    data,
                ),
            bcs: RequestToJoinDfKey.bcs,
            fromJSONField: (field: any) =>
                RequestToJoinDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                RequestToJoinDfKey.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => RequestToJoinDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: RequestToJoinDfKeyFields,
            ) => {
                return new RequestToJoinDfKey(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return RequestToJoinDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<RequestToJoinDfKey>> {
        return phantom(RequestToJoinDfKey.reified());
    }

    static get p() {
        return RequestToJoinDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("RequestToJoinDfKey", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): RequestToJoinDfKey {
        return RequestToJoinDfKey.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): RequestToJoinDfKey {
        if (!isRequestToJoinDfKey(item.type)) {
            throw new Error("not a RequestToJoinDfKey type");
        }

        return RequestToJoinDfKey.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): RequestToJoinDfKey {

        return RequestToJoinDfKey.fromFields(
            RequestToJoinDfKey.bcs.parse(data)
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
            ...this.toJSONField()
        }
    }

    static fromJSONField(
         field: any
    ): RequestToJoinDfKey {
        return RequestToJoinDfKey.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): RequestToJoinDfKey {
        if (json.$typeName !== RequestToJoinDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return RequestToJoinDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): RequestToJoinDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isRequestToJoinDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a RequestToJoinDfKey object`);
        }
        return RequestToJoinDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<RequestToJoinDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching RequestToJoinDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isRequestToJoinDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a RequestToJoinDfKey object`);
        }

        return RequestToJoinDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== WhitelistDfKey =============================== */

export function isWhitelistDfKey(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::WhitelistDfKey";
}

export interface WhitelistDfKeyFields {
    venueId: ToField<ID>
}

export type WhitelistDfKeyReified = Reified<
    WhitelistDfKey,
    WhitelistDfKeyFields
>;

export class WhitelistDfKey {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::WhitelistDfKey";
    static readonly $numTypeParams = 0;

    readonly $typeName = WhitelistDfKey.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::WhitelistDfKey";

    ;

    readonly venueId:
        ToField<ID>

    private constructor( fields: WhitelistDfKeyFields,
    ) {
        this.$fullTypeName = WhitelistDfKey.$typeName;

        this.venueId = fields.venueId;
    }

    static reified(): WhitelistDfKeyReified {
        return {
            typeName: WhitelistDfKey.$typeName,
            fullTypeName: composeSuiType(
                WhitelistDfKey.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing::WhitelistDfKey",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                WhitelistDfKey.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                WhitelistDfKey.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                WhitelistDfKey.fromBcs(
                    data,
                ),
            bcs: WhitelistDfKey.bcs,
            fromJSONField: (field: any) =>
                WhitelistDfKey.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                WhitelistDfKey.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => WhitelistDfKey.fetch(
                client,
                id,
            ),
            new: (
                fields: WhitelistDfKeyFields,
            ) => {
                return new WhitelistDfKey(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return WhitelistDfKey.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<WhitelistDfKey>> {
        return phantom(WhitelistDfKey.reified());
    }

    static get p() {
        return WhitelistDfKey.phantom()
    }

    static get bcs() {
        return bcs.struct("WhitelistDfKey", {
            venue_id:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): WhitelistDfKey {
        return WhitelistDfKey.reified().new(
            {venueId: decodeFromFields(ID.reified(), fields.venue_id)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): WhitelistDfKey {
        if (!isWhitelistDfKey(item.type)) {
            throw new Error("not a WhitelistDfKey type");
        }

        return WhitelistDfKey.reified().new(
            {venueId: decodeFromFieldsWithTypes(ID.reified(), item.fields.venue_id)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): WhitelistDfKey {

        return WhitelistDfKey.fromFields(
            WhitelistDfKey.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            venueId: this.venueId,

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
    ): WhitelistDfKey {
        return WhitelistDfKey.reified().new(
            {venueId: decodeFromJSONField(ID.reified(), field.venueId)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): WhitelistDfKey {
        if (json.$typeName !== WhitelistDfKey.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return WhitelistDfKey.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): WhitelistDfKey {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWhitelistDfKey(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a WhitelistDfKey object`);
        }
        return WhitelistDfKey.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<WhitelistDfKey> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching WhitelistDfKey object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isWhitelistDfKey(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a WhitelistDfKey object`);
        }

        return WhitelistDfKey.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
