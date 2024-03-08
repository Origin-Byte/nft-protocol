import {UID} from "../../_dependencies/source/0x2/object/structs";
import {Publisher} from "../../_dependencies/source/0x2/package/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== FROZEN_PUBLISHER =============================== */

export function isFROZEN_PUBLISHER(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::frozen_publisher::FROZEN_PUBLISHER";
}

export interface FROZEN_PUBLISHERFields {
    dummyField: ToField<"bool">
}

export type FROZEN_PUBLISHERReified = Reified<
    FROZEN_PUBLISHER,
    FROZEN_PUBLISHERFields
>;

export class FROZEN_PUBLISHER implements StructClass {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::frozen_publisher::FROZEN_PUBLISHER";
    static readonly $numTypeParams = 0;

    readonly $typeName = FROZEN_PUBLISHER.$typeName;

    readonly $fullTypeName: "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::frozen_publisher::FROZEN_PUBLISHER";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: FROZEN_PUBLISHERFields,
    ) {
        this.$fullTypeName = composeSuiType(
            FROZEN_PUBLISHER.$typeName,
            ...typeArgs
        ) as "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::frozen_publisher::FROZEN_PUBLISHER";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): FROZEN_PUBLISHERReified {
        return {
            typeName: FROZEN_PUBLISHER.$typeName,
            fullTypeName: composeSuiType(
                FROZEN_PUBLISHER.$typeName,
                ...[]
            ) as "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::frozen_publisher::FROZEN_PUBLISHER",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                FROZEN_PUBLISHER.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                FROZEN_PUBLISHER.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                FROZEN_PUBLISHER.fromBcs(
                    data,
                ),
            bcs: FROZEN_PUBLISHER.bcs,
            fromJSONField: (field: any) =>
                FROZEN_PUBLISHER.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                FROZEN_PUBLISHER.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                FROZEN_PUBLISHER.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => FROZEN_PUBLISHER.fetch(
                client,
                id,
            ),
            new: (
                fields: FROZEN_PUBLISHERFields,
            ) => {
                return new FROZEN_PUBLISHER(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return FROZEN_PUBLISHER.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<FROZEN_PUBLISHER>> {
        return phantom(FROZEN_PUBLISHER.reified());
    }

    static get p() {
        return FROZEN_PUBLISHER.phantom()
    }

    static get bcs() {
        return bcs.struct("FROZEN_PUBLISHER", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): FROZEN_PUBLISHER {
        return FROZEN_PUBLISHER.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): FROZEN_PUBLISHER {
        if (!isFROZEN_PUBLISHER(item.type)) {
            throw new Error("not a FROZEN_PUBLISHER type");
        }

        return FROZEN_PUBLISHER.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): FROZEN_PUBLISHER {

        return FROZEN_PUBLISHER.fromFields(
            FROZEN_PUBLISHER.bcs.parse(data)
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
    ): FROZEN_PUBLISHER {
        return FROZEN_PUBLISHER.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): FROZEN_PUBLISHER {
        if (json.$typeName !== FROZEN_PUBLISHER.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return FROZEN_PUBLISHER.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): FROZEN_PUBLISHER {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isFROZEN_PUBLISHER(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a FROZEN_PUBLISHER object`);
        }
        return FROZEN_PUBLISHER.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<FROZEN_PUBLISHER> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching FROZEN_PUBLISHER object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isFROZEN_PUBLISHER(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a FROZEN_PUBLISHER object`);
        }

        return FROZEN_PUBLISHER.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== FrozenPublisher =============================== */

export function isFrozenPublisher(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::frozen_publisher::FrozenPublisher";
}

export interface FrozenPublisherFields {
    id: ToField<UID>; inner: ToField<Publisher>
}

export type FrozenPublisherReified = Reified<
    FrozenPublisher,
    FrozenPublisherFields
>;

export class FrozenPublisher implements StructClass {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::frozen_publisher::FrozenPublisher";
    static readonly $numTypeParams = 0;

    readonly $typeName = FrozenPublisher.$typeName;

    readonly $fullTypeName: "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::frozen_publisher::FrozenPublisher";

    readonly $typeArgs: [];

    readonly id:
        ToField<UID>
    ; readonly inner:
        ToField<Publisher>

    private constructor(typeArgs: [], fields: FrozenPublisherFields,
    ) {
        this.$fullTypeName = composeSuiType(
            FrozenPublisher.$typeName,
            ...typeArgs
        ) as "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::frozen_publisher::FrozenPublisher";
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.inner = fields.inner;
    }

    static reified(): FrozenPublisherReified {
        return {
            typeName: FrozenPublisher.$typeName,
            fullTypeName: composeSuiType(
                FrozenPublisher.$typeName,
                ...[]
            ) as "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::frozen_publisher::FrozenPublisher",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                FrozenPublisher.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                FrozenPublisher.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                FrozenPublisher.fromBcs(
                    data,
                ),
            bcs: FrozenPublisher.bcs,
            fromJSONField: (field: any) =>
                FrozenPublisher.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                FrozenPublisher.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                FrozenPublisher.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => FrozenPublisher.fetch(
                client,
                id,
            ),
            new: (
                fields: FrozenPublisherFields,
            ) => {
                return new FrozenPublisher(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return FrozenPublisher.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<FrozenPublisher>> {
        return phantom(FrozenPublisher.reified());
    }

    static get p() {
        return FrozenPublisher.phantom()
    }

    static get bcs() {
        return bcs.struct("FrozenPublisher", {
            id:
                UID.bcs
            , inner:
                Publisher.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): FrozenPublisher {
        return FrozenPublisher.reified().new(
            {id: decodeFromFields(UID.reified(), fields.id), inner: decodeFromFields(Publisher.reified(), fields.inner)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): FrozenPublisher {
        if (!isFrozenPublisher(item.type)) {
            throw new Error("not a FrozenPublisher type");
        }

        return FrozenPublisher.reified().new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), inner: decodeFromFieldsWithTypes(Publisher.reified(), item.fields.inner)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): FrozenPublisher {

        return FrozenPublisher.fromFields(
            FrozenPublisher.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,inner: this.inner.toJSONField(),

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
    ): FrozenPublisher {
        return FrozenPublisher.reified().new(
            {id: decodeFromJSONField(UID.reified(), field.id), inner: decodeFromJSONField(Publisher.reified(), field.inner)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): FrozenPublisher {
        if (json.$typeName !== FrozenPublisher.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return FrozenPublisher.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): FrozenPublisher {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isFrozenPublisher(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a FrozenPublisher object`);
        }
        return FrozenPublisher.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<FrozenPublisher> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching FrozenPublisher object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isFrozenPublisher(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a FrozenPublisher object`);
        }

        return FrozenPublisher.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
