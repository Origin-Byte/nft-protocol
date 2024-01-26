import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Proceeds =============================== */

export function isProceeds(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::proceeds::Proceeds";
}

export interface ProceedsFields {
    id: ToField<UID>; qtSold: ToField<QtSold>
}

export type ProceedsReified = Reified<
    Proceeds,
    ProceedsFields
>;

export class Proceeds {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::proceeds::Proceeds";
    static readonly $numTypeParams = 0;

    readonly $typeName = Proceeds.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::proceeds::Proceeds";

    ;

    readonly id:
        ToField<UID>
    ; readonly qtSold:
        ToField<QtSold>

    private constructor( fields: ProceedsFields,
    ) {
        this.$fullTypeName = Proceeds.$typeName;

        this.id = fields.id;; this.qtSold = fields.qtSold;
    }

    static reified(): ProceedsReified {
        return {
            typeName: Proceeds.$typeName,
            fullTypeName: composeSuiType(
                Proceeds.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::proceeds::Proceeds",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Proceeds.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Proceeds.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Proceeds.fromBcs(
                    data,
                ),
            bcs: Proceeds.bcs,
            fromJSONField: (field: any) =>
                Proceeds.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Proceeds.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Proceeds.fetch(
                client,
                id,
            ),
            new: (
                fields: ProceedsFields,
            ) => {
                return new Proceeds(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Proceeds.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Proceeds>> {
        return phantom(Proceeds.reified());
    }

    static get p() {
        return Proceeds.phantom()
    }

    static get bcs() {
        return bcs.struct("Proceeds", {
            id:
                UID.bcs
            , qt_sold:
                QtSold.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Proceeds {
        return Proceeds.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), qtSold: decodeFromFields(QtSold.reified(), fields.qt_sold)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Proceeds {
        if (!isProceeds(item.type)) {
            throw new Error("not a Proceeds type");
        }

        return Proceeds.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), qtSold: decodeFromFieldsWithTypes(QtSold.reified(), item.fields.qt_sold)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Proceeds {

        return Proceeds.fromFields(
            Proceeds.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,qtSold: this.qtSold.toJSONField(),

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
    ): Proceeds {
        return Proceeds.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), qtSold: decodeFromJSONField(QtSold.reified(), field.qtSold)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Proceeds {
        if (json.$typeName !== Proceeds.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Proceeds.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Proceeds {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isProceeds(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Proceeds object`);
        }
        return Proceeds.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Proceeds> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Proceeds object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isProceeds(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Proceeds object`);
        }

        return Proceeds.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== QtSold =============================== */

export function isQtSold(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::proceeds::QtSold";
}

export interface QtSoldFields {
    collected: ToField<"u64">; total: ToField<"u64">
}

export type QtSoldReified = Reified<
    QtSold,
    QtSoldFields
>;

export class QtSold {
    static readonly $typeName = "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::proceeds::QtSold";
    static readonly $numTypeParams = 0;

    readonly $typeName = QtSold.$typeName;

    readonly $fullTypeName: "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::proceeds::QtSold";

    ;

    readonly collected:
        ToField<"u64">
    ; readonly total:
        ToField<"u64">

    private constructor( fields: QtSoldFields,
    ) {
        this.$fullTypeName = QtSold.$typeName;

        this.collected = fields.collected;; this.total = fields.total;
    }

    static reified(): QtSoldReified {
        return {
            typeName: QtSold.$typeName,
            fullTypeName: composeSuiType(
                QtSold.$typeName,
                ...[]
            ) as "0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::proceeds::QtSold",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                QtSold.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                QtSold.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                QtSold.fromBcs(
                    data,
                ),
            bcs: QtSold.bcs,
            fromJSONField: (field: any) =>
                QtSold.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                QtSold.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => QtSold.fetch(
                client,
                id,
            ),
            new: (
                fields: QtSoldFields,
            ) => {
                return new QtSold(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return QtSold.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<QtSold>> {
        return phantom(QtSold.reified());
    }

    static get p() {
        return QtSold.phantom()
    }

    static get bcs() {
        return bcs.struct("QtSold", {
            collected:
                bcs.u64()
            , total:
                bcs.u64()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): QtSold {
        return QtSold.reified().new(
            {collected: decodeFromFields("u64", fields.collected), total: decodeFromFields("u64", fields.total)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): QtSold {
        if (!isQtSold(item.type)) {
            throw new Error("not a QtSold type");
        }

        return QtSold.reified().new(
            {collected: decodeFromFieldsWithTypes("u64", item.fields.collected), total: decodeFromFieldsWithTypes("u64", item.fields.total)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): QtSold {

        return QtSold.fromFields(
            QtSold.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            collected: this.collected.toString(),total: this.total.toString(),

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
    ): QtSold {
        return QtSold.reified().new(
            {collected: decodeFromJSONField("u64", field.collected), total: decodeFromJSONField("u64", field.total)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): QtSold {
        if (json.$typeName !== QtSold.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return QtSold.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): QtSold {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isQtSold(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a QtSold object`);
        }
        return QtSold.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<QtSold> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching QtSold object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isQtSold(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a QtSold object`);
        }

        return QtSold.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
