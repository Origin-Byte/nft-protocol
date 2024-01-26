import * as reified from "../../../../_framework/reified";
import {PhantomReified, Reified, ToField, ToTypeStr, Vector, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, fieldToJSON, phantom} from "../../../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../../../_framework/util";
import {String} from "../../0x1/ascii/structs";
import {ID, UID} from "../object/structs";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Publisher =============================== */

export function isPublisher(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::package::Publisher";
}

export interface PublisherFields {
    id: ToField<UID>; package: ToField<String>; moduleName: ToField<String>
}

export type PublisherReified = Reified<
    Publisher,
    PublisherFields
>;

export class Publisher {
    static readonly $typeName = "0x2::package::Publisher";
    static readonly $numTypeParams = 0;

    readonly $typeName = Publisher.$typeName;

    readonly $fullTypeName: "0x2::package::Publisher";

    ;

    readonly id:
        ToField<UID>
    ; readonly package:
        ToField<String>
    ; readonly moduleName:
        ToField<String>

    private constructor( fields: PublisherFields,
    ) {
        this.$fullTypeName = Publisher.$typeName;

        this.id = fields.id;; this.package = fields.package;; this.moduleName = fields.moduleName;
    }

    static reified(): PublisherReified {
        return {
            typeName: Publisher.$typeName,
            fullTypeName: composeSuiType(
                Publisher.$typeName,
                ...[]
            ) as "0x2::package::Publisher",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Publisher.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Publisher.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Publisher.fromBcs(
                    data,
                ),
            bcs: Publisher.bcs,
            fromJSONField: (field: any) =>
                Publisher.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Publisher.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Publisher.fetch(
                client,
                id,
            ),
            new: (
                fields: PublisherFields,
            ) => {
                return new Publisher(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Publisher.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Publisher>> {
        return phantom(Publisher.reified());
    }

    static get p() {
        return Publisher.phantom()
    }

    static get bcs() {
        return bcs.struct("Publisher", {
            id:
                UID.bcs
            , package:
                String.bcs
            , module_name:
                String.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Publisher {
        return Publisher.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), package: decodeFromFields(String.reified(), fields.package), moduleName: decodeFromFields(String.reified(), fields.module_name)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Publisher {
        if (!isPublisher(item.type)) {
            throw new Error("not a Publisher type");
        }

        return Publisher.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), package: decodeFromFieldsWithTypes(String.reified(), item.fields.package), moduleName: decodeFromFieldsWithTypes(String.reified(), item.fields.module_name)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Publisher {

        return Publisher.fromFields(
            Publisher.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,package: this.package,moduleName: this.moduleName,

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
    ): Publisher {
        return Publisher.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), package: decodeFromJSONField(String.reified(), field.package), moduleName: decodeFromJSONField(String.reified(), field.moduleName)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Publisher {
        if (json.$typeName !== Publisher.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Publisher.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Publisher {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isPublisher(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Publisher object`);
        }
        return Publisher.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Publisher> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Publisher object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isPublisher(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Publisher object`);
        }

        return Publisher.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== UpgradeCap =============================== */

export function isUpgradeCap(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::package::UpgradeCap";
}

export interface UpgradeCapFields {
    id: ToField<UID>; package: ToField<ID>; version: ToField<"u64">; policy: ToField<"u8">
}

export type UpgradeCapReified = Reified<
    UpgradeCap,
    UpgradeCapFields
>;

export class UpgradeCap {
    static readonly $typeName = "0x2::package::UpgradeCap";
    static readonly $numTypeParams = 0;

    readonly $typeName = UpgradeCap.$typeName;

    readonly $fullTypeName: "0x2::package::UpgradeCap";

    ;

    readonly id:
        ToField<UID>
    ; readonly package:
        ToField<ID>
    ; readonly version:
        ToField<"u64">
    ; readonly policy:
        ToField<"u8">

    private constructor( fields: UpgradeCapFields,
    ) {
        this.$fullTypeName = UpgradeCap.$typeName;

        this.id = fields.id;; this.package = fields.package;; this.version = fields.version;; this.policy = fields.policy;
    }

    static reified(): UpgradeCapReified {
        return {
            typeName: UpgradeCap.$typeName,
            fullTypeName: composeSuiType(
                UpgradeCap.$typeName,
                ...[]
            ) as "0x2::package::UpgradeCap",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                UpgradeCap.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                UpgradeCap.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                UpgradeCap.fromBcs(
                    data,
                ),
            bcs: UpgradeCap.bcs,
            fromJSONField: (field: any) =>
                UpgradeCap.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                UpgradeCap.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => UpgradeCap.fetch(
                client,
                id,
            ),
            new: (
                fields: UpgradeCapFields,
            ) => {
                return new UpgradeCap(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return UpgradeCap.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<UpgradeCap>> {
        return phantom(UpgradeCap.reified());
    }

    static get p() {
        return UpgradeCap.phantom()
    }

    static get bcs() {
        return bcs.struct("UpgradeCap", {
            id:
                UID.bcs
            , package:
                ID.bcs
            , version:
                bcs.u64()
            , policy:
                bcs.u8()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): UpgradeCap {
        return UpgradeCap.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), package: decodeFromFields(ID.reified(), fields.package), version: decodeFromFields("u64", fields.version), policy: decodeFromFields("u8", fields.policy)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): UpgradeCap {
        if (!isUpgradeCap(item.type)) {
            throw new Error("not a UpgradeCap type");
        }

        return UpgradeCap.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), package: decodeFromFieldsWithTypes(ID.reified(), item.fields.package), version: decodeFromFieldsWithTypes("u64", item.fields.version), policy: decodeFromFieldsWithTypes("u8", item.fields.policy)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): UpgradeCap {

        return UpgradeCap.fromFields(
            UpgradeCap.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,package: this.package,version: this.version.toString(),policy: this.policy,

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
    ): UpgradeCap {
        return UpgradeCap.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), package: decodeFromJSONField(ID.reified(), field.package), version: decodeFromJSONField("u64", field.version), policy: decodeFromJSONField("u8", field.policy)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): UpgradeCap {
        if (json.$typeName !== UpgradeCap.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return UpgradeCap.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): UpgradeCap {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isUpgradeCap(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a UpgradeCap object`);
        }
        return UpgradeCap.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<UpgradeCap> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching UpgradeCap object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isUpgradeCap(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a UpgradeCap object`);
        }

        return UpgradeCap.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== UpgradeReceipt =============================== */

export function isUpgradeReceipt(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::package::UpgradeReceipt";
}

export interface UpgradeReceiptFields {
    cap: ToField<ID>; package: ToField<ID>
}

export type UpgradeReceiptReified = Reified<
    UpgradeReceipt,
    UpgradeReceiptFields
>;

export class UpgradeReceipt {
    static readonly $typeName = "0x2::package::UpgradeReceipt";
    static readonly $numTypeParams = 0;

    readonly $typeName = UpgradeReceipt.$typeName;

    readonly $fullTypeName: "0x2::package::UpgradeReceipt";

    ;

    readonly cap:
        ToField<ID>
    ; readonly package:
        ToField<ID>

    private constructor( fields: UpgradeReceiptFields,
    ) {
        this.$fullTypeName = UpgradeReceipt.$typeName;

        this.cap = fields.cap;; this.package = fields.package;
    }

    static reified(): UpgradeReceiptReified {
        return {
            typeName: UpgradeReceipt.$typeName,
            fullTypeName: composeSuiType(
                UpgradeReceipt.$typeName,
                ...[]
            ) as "0x2::package::UpgradeReceipt",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                UpgradeReceipt.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                UpgradeReceipt.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                UpgradeReceipt.fromBcs(
                    data,
                ),
            bcs: UpgradeReceipt.bcs,
            fromJSONField: (field: any) =>
                UpgradeReceipt.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                UpgradeReceipt.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => UpgradeReceipt.fetch(
                client,
                id,
            ),
            new: (
                fields: UpgradeReceiptFields,
            ) => {
                return new UpgradeReceipt(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return UpgradeReceipt.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<UpgradeReceipt>> {
        return phantom(UpgradeReceipt.reified());
    }

    static get p() {
        return UpgradeReceipt.phantom()
    }

    static get bcs() {
        return bcs.struct("UpgradeReceipt", {
            cap:
                ID.bcs
            , package:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): UpgradeReceipt {
        return UpgradeReceipt.reified().new(
            {cap: decodeFromFields(ID.reified(), fields.cap), package: decodeFromFields(ID.reified(), fields.package)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): UpgradeReceipt {
        if (!isUpgradeReceipt(item.type)) {
            throw new Error("not a UpgradeReceipt type");
        }

        return UpgradeReceipt.reified().new(
            {cap: decodeFromFieldsWithTypes(ID.reified(), item.fields.cap), package: decodeFromFieldsWithTypes(ID.reified(), item.fields.package)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): UpgradeReceipt {

        return UpgradeReceipt.fromFields(
            UpgradeReceipt.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            cap: this.cap,package: this.package,

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
    ): UpgradeReceipt {
        return UpgradeReceipt.reified().new(
            {cap: decodeFromJSONField(ID.reified(), field.cap), package: decodeFromJSONField(ID.reified(), field.package)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): UpgradeReceipt {
        if (json.$typeName !== UpgradeReceipt.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return UpgradeReceipt.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): UpgradeReceipt {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isUpgradeReceipt(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a UpgradeReceipt object`);
        }
        return UpgradeReceipt.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<UpgradeReceipt> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching UpgradeReceipt object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isUpgradeReceipt(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a UpgradeReceipt object`);
        }

        return UpgradeReceipt.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== UpgradeTicket =============================== */

export function isUpgradeTicket(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x2::package::UpgradeTicket";
}

export interface UpgradeTicketFields {
    cap: ToField<ID>; package: ToField<ID>; policy: ToField<"u8">; digest: ToField<Vector<"u8">>
}

export type UpgradeTicketReified = Reified<
    UpgradeTicket,
    UpgradeTicketFields
>;

export class UpgradeTicket {
    static readonly $typeName = "0x2::package::UpgradeTicket";
    static readonly $numTypeParams = 0;

    readonly $typeName = UpgradeTicket.$typeName;

    readonly $fullTypeName: "0x2::package::UpgradeTicket";

    ;

    readonly cap:
        ToField<ID>
    ; readonly package:
        ToField<ID>
    ; readonly policy:
        ToField<"u8">
    ; readonly digest:
        ToField<Vector<"u8">>

    private constructor( fields: UpgradeTicketFields,
    ) {
        this.$fullTypeName = UpgradeTicket.$typeName;

        this.cap = fields.cap;; this.package = fields.package;; this.policy = fields.policy;; this.digest = fields.digest;
    }

    static reified(): UpgradeTicketReified {
        return {
            typeName: UpgradeTicket.$typeName,
            fullTypeName: composeSuiType(
                UpgradeTicket.$typeName,
                ...[]
            ) as "0x2::package::UpgradeTicket",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                UpgradeTicket.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                UpgradeTicket.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                UpgradeTicket.fromBcs(
                    data,
                ),
            bcs: UpgradeTicket.bcs,
            fromJSONField: (field: any) =>
                UpgradeTicket.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                UpgradeTicket.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => UpgradeTicket.fetch(
                client,
                id,
            ),
            new: (
                fields: UpgradeTicketFields,
            ) => {
                return new UpgradeTicket(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return UpgradeTicket.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<UpgradeTicket>> {
        return phantom(UpgradeTicket.reified());
    }

    static get p() {
        return UpgradeTicket.phantom()
    }

    static get bcs() {
        return bcs.struct("UpgradeTicket", {
            cap:
                ID.bcs
            , package:
                ID.bcs
            , policy:
                bcs.u8()
            , digest:
                bcs.vector(bcs.u8())

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): UpgradeTicket {
        return UpgradeTicket.reified().new(
            {cap: decodeFromFields(ID.reified(), fields.cap), package: decodeFromFields(ID.reified(), fields.package), policy: decodeFromFields("u8", fields.policy), digest: decodeFromFields(reified.vector("u8"), fields.digest)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): UpgradeTicket {
        if (!isUpgradeTicket(item.type)) {
            throw new Error("not a UpgradeTicket type");
        }

        return UpgradeTicket.reified().new(
            {cap: decodeFromFieldsWithTypes(ID.reified(), item.fields.cap), package: decodeFromFieldsWithTypes(ID.reified(), item.fields.package), policy: decodeFromFieldsWithTypes("u8", item.fields.policy), digest: decodeFromFieldsWithTypes(reified.vector("u8"), item.fields.digest)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): UpgradeTicket {

        return UpgradeTicket.fromFields(
            UpgradeTicket.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            cap: this.cap,package: this.package,policy: this.policy,digest: fieldToJSON<Vector<"u8">>(`vector<u8>`, this.digest),

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
    ): UpgradeTicket {
        return UpgradeTicket.reified().new(
            {cap: decodeFromJSONField(ID.reified(), field.cap), package: decodeFromJSONField(ID.reified(), field.package), policy: decodeFromJSONField("u8", field.policy), digest: decodeFromJSONField(reified.vector("u8"), field.digest)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): UpgradeTicket {
        if (json.$typeName !== UpgradeTicket.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return UpgradeTicket.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): UpgradeTicket {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isUpgradeTicket(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a UpgradeTicket object`);
        }
        return UpgradeTicket.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<UpgradeTicket> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching UpgradeTicket object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isUpgradeTicket(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a UpgradeTicket object`);
        }

        return UpgradeTicket.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
