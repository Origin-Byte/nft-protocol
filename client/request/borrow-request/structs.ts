import * as reified from "../../_framework/reified";
import {Option} from "../../_dependencies/source/0x1/option/structs";
import {TypeName} from "../../_dependencies/source/0x1/type-name/structs";
import {Borrow} from "../../_dependencies/source/0x2/kiosk/structs";
import {ID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, StructClass, ToField, ToPhantomTypeArgument, ToTypeArgument, ToTypeStr, TypeArgument, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom, toBcs, ToTypeStr as ToPhantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {RequestBody, WithNft} from "../request/structs";
import {BcsType, bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Witness =============================== */

export function isWitness(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::Witness";
}

export interface WitnessFields {
    dummyField: ToField<"bool">
}

export type WitnessReified = Reified<
    Witness,
    WitnessFields
>;

export class Witness implements StructClass {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::Witness";
    static readonly $numTypeParams = 0;

    readonly $typeName = Witness.$typeName;

    readonly $fullTypeName: "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::Witness";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: WitnessFields,
    ) {
        this.$fullTypeName = composeSuiType(
            Witness.$typeName,
            ...typeArgs
        ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::Witness";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): WitnessReified {
        return {
            typeName: Witness.$typeName,
            fullTypeName: composeSuiType(
                Witness.$typeName,
                ...[]
            ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::Witness",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Witness.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Witness.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Witness.fromBcs(
                    data,
                ),
            bcs: Witness.bcs,
            fromJSONField: (field: any) =>
                Witness.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Witness.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Witness.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Witness.fetch(
                client,
                id,
            ),
            new: (
                fields: WitnessFields,
            ) => {
                return new Witness(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Witness.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Witness>> {
        return phantom(Witness.reified());
    }

    static get p() {
        return Witness.phantom()
    }

    static get bcs() {
        return bcs.struct("Witness", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Witness {
        return Witness.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Witness {
        if (!isWitness(item.type)) {
            throw new Error("not a Witness type");
        }

        return Witness.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Witness {

        return Witness.fromFields(
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
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField(
         field: any
    ): Witness {
        return Witness.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Witness {
        if (json.$typeName !== Witness.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Witness.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Witness {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isWitness(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Witness object`);
        }
        return Witness.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Witness> {
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
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== BORROW_REQ =============================== */

export function isBORROW_REQ(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::BORROW_REQ";
}

export interface BORROW_REQFields {
    dummyField: ToField<"bool">
}

export type BORROW_REQReified = Reified<
    BORROW_REQ,
    BORROW_REQFields
>;

export class BORROW_REQ implements StructClass {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::BORROW_REQ";
    static readonly $numTypeParams = 0;

    readonly $typeName = BORROW_REQ.$typeName;

    readonly $fullTypeName: "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::BORROW_REQ";

    readonly $typeArgs: [];

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [], fields: BORROW_REQFields,
    ) {
        this.$fullTypeName = composeSuiType(
            BORROW_REQ.$typeName,
            ...typeArgs
        ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::BORROW_REQ";
        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified(): BORROW_REQReified {
        return {
            typeName: BORROW_REQ.$typeName,
            fullTypeName: composeSuiType(
                BORROW_REQ.$typeName,
                ...[]
            ) as "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::BORROW_REQ",
            typeArgs: [] as [],
            reifiedTypeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                BORROW_REQ.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                BORROW_REQ.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                BORROW_REQ.fromBcs(
                    data,
                ),
            bcs: BORROW_REQ.bcs,
            fromJSONField: (field: any) =>
                BORROW_REQ.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                BORROW_REQ.fromJSON(
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                BORROW_REQ.fromSuiParsedData(
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => BORROW_REQ.fetch(
                client,
                id,
            ),
            new: (
                fields: BORROW_REQFields,
            ) => {
                return new BORROW_REQ(
                    [],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return BORROW_REQ.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<BORROW_REQ>> {
        return phantom(BORROW_REQ.reified());
    }

    static get p() {
        return BORROW_REQ.phantom()
    }

    static get bcs() {
        return bcs.struct("BORROW_REQ", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): BORROW_REQ {
        return BORROW_REQ.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): BORROW_REQ {
        if (!isBORROW_REQ(item.type)) {
            throw new Error("not a BORROW_REQ type");
        }

        return BORROW_REQ.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): BORROW_REQ {

        return BORROW_REQ.fromFields(
            BORROW_REQ.bcs.parse(data)
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
    ): BORROW_REQ {
        return BORROW_REQ.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): BORROW_REQ {
        if (json.$typeName !== BORROW_REQ.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return BORROW_REQ.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): BORROW_REQ {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBORROW_REQ(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a BORROW_REQ object`);
        }
        return BORROW_REQ.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<BORROW_REQ> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching BORROW_REQ object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBORROW_REQ(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a BORROW_REQ object`);
        }

        return BORROW_REQ.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== BorrowRequest =============================== */

export function isBorrowRequest(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::BorrowRequest<");
}

export interface BorrowRequestFields<Auth extends PhantomTypeArgument, T extends TypeArgument> {
    nftId: ToField<ID>; nft: ToField<Option<T>>; sender: ToField<"address">; field: ToField<Option<TypeName>>; promise: ToField<Borrow>; inner: ToField<RequestBody<ToPhantom<WithNft<ToPhantom<T>, ToPhantom<BORROW_REQ>>>>>
}

export type BorrowRequestReified<Auth extends PhantomTypeArgument, T extends TypeArgument> = Reified<
    BorrowRequest<Auth, T>,
    BorrowRequestFields<Auth, T>
>;

export class BorrowRequest<Auth extends PhantomTypeArgument, T extends TypeArgument> implements StructClass {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::BorrowRequest";
    static readonly $numTypeParams = 2;

    readonly $typeName = BorrowRequest.$typeName;

    readonly $fullTypeName: `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::BorrowRequest<${PhantomToTypeStr<Auth>}, ${ToTypeStr<T>}>`;

    readonly $typeArgs: [PhantomToTypeStr<Auth>, ToTypeStr<T>];

    readonly nftId:
        ToField<ID>
    ; readonly nft:
        ToField<Option<T>>
    ; readonly sender:
        ToField<"address">
    ; readonly field:
        ToField<Option<TypeName>>
    ; readonly promise:
        ToField<Borrow>
    ; readonly inner:
        ToField<RequestBody<ToPhantom<WithNft<ToPhantom<T>, ToPhantom<BORROW_REQ>>>>>

    private constructor(typeArgs: [PhantomToTypeStr<Auth>, ToTypeStr<T>], fields: BorrowRequestFields<Auth, T>,
    ) {
        this.$fullTypeName = composeSuiType(
            BorrowRequest.$typeName,
            ...typeArgs
        ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::BorrowRequest<${PhantomToTypeStr<Auth>}, ${ToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.nftId = fields.nftId;; this.nft = fields.nft;; this.sender = fields.sender;; this.field = fields.field;; this.promise = fields.promise;; this.inner = fields.inner;
    }

    static reified<Auth extends PhantomReified<PhantomTypeArgument>, T extends Reified<TypeArgument, any>>(
        Auth: Auth, T: T
    ): BorrowRequestReified<ToPhantomTypeArgument<Auth>, ToTypeArgument<T>> {
        return {
            typeName: BorrowRequest.$typeName,
            fullTypeName: composeSuiType(
                BorrowRequest.$typeName,
                ...[extractType(Auth), extractType(T)]
            ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::BorrowRequest<${PhantomToTypeStr<ToPhantomTypeArgument<Auth>>}, ${ToTypeStr<ToTypeArgument<T>>}>`,
            typeArgs: [
                extractType(Auth), extractType(T)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<Auth>>, ToTypeStr<ToTypeArgument<T>>],
            reifiedTypeArgs: [Auth, T],
            fromFields: (fields: Record<string, any>) =>
                BorrowRequest.fromFields(
                    [Auth, T],
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                BorrowRequest.fromFieldsWithTypes(
                    [Auth, T],
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                BorrowRequest.fromBcs(
                    [Auth, T],
                    data,
                ),
            bcs: BorrowRequest.bcs(toBcs(T)),
            fromJSONField: (field: any) =>
                BorrowRequest.fromJSONField(
                    [Auth, T],
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                BorrowRequest.fromJSON(
                    [Auth, T],
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                BorrowRequest.fromSuiParsedData(
                    [Auth, T],
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => BorrowRequest.fetch(
                client,
                [Auth, T],
                id,
            ),
            new: (
                fields: BorrowRequestFields<ToPhantomTypeArgument<Auth>, ToTypeArgument<T>>,
            ) => {
                return new BorrowRequest(
                    [extractType(Auth), extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return BorrowRequest.reified
    }

    static phantom<Auth extends PhantomReified<PhantomTypeArgument>, T extends Reified<TypeArgument, any>>(
        Auth: Auth, T: T
    ): PhantomReified<ToTypeStr<BorrowRequest<ToPhantomTypeArgument<Auth>, ToTypeArgument<T>>>> {
        return phantom(BorrowRequest.reified(
            Auth, T
        ));
    }

    static get p() {
        return BorrowRequest.phantom
    }

    static get bcs() {
        return <T extends BcsType<any>>(T: T) => bcs.struct(`BorrowRequest<${T.name}>`, {
            nft_id:
                ID.bcs
            , nft:
                Option.bcs(T)
            , sender:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , field:
                Option.bcs(TypeName.bcs)
            , promise:
                Borrow.bcs
            , inner:
                RequestBody.bcs

        })
    };

    static fromFields<Auth extends PhantomReified<PhantomTypeArgument>, T extends Reified<TypeArgument, any>>(
        typeArgs: [Auth, T], fields: Record<string, any>
    ): BorrowRequest<ToPhantomTypeArgument<Auth>, ToTypeArgument<T>> {
        return BorrowRequest.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {nftId: decodeFromFields(ID.reified(), fields.nft_id), nft: decodeFromFields(Option.reified(typeArgs[1]), fields.nft), sender: decodeFromFields("address", fields.sender), field: decodeFromFields(Option.reified(TypeName.reified()), fields.field), promise: decodeFromFields(Borrow.reified(), fields.promise), inner: decodeFromFields(RequestBody.reified(reified.phantom(WithNft.reified(reified.phantom(typeArgs[1]), reified.phantom(BORROW_REQ.reified())))), fields.inner)}
        )
    }

    static fromFieldsWithTypes<Auth extends PhantomReified<PhantomTypeArgument>, T extends Reified<TypeArgument, any>>(
        typeArgs: [Auth, T], item: FieldsWithTypes
    ): BorrowRequest<ToPhantomTypeArgument<Auth>, ToTypeArgument<T>> {
        if (!isBorrowRequest(item.type)) {
            throw new Error("not a BorrowRequest type");
        }
        assertFieldsWithTypesArgsMatch(item, typeArgs);

        return BorrowRequest.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {nftId: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft_id), nft: decodeFromFieldsWithTypes(Option.reified(typeArgs[1]), item.fields.nft), sender: decodeFromFieldsWithTypes("address", item.fields.sender), field: decodeFromFieldsWithTypes(Option.reified(TypeName.reified()), item.fields.field), promise: decodeFromFieldsWithTypes(Borrow.reified(), item.fields.promise), inner: decodeFromFieldsWithTypes(RequestBody.reified(reified.phantom(WithNft.reified(reified.phantom(typeArgs[1]), reified.phantom(BORROW_REQ.reified())))), item.fields.inner)}
        )
    }

    static fromBcs<Auth extends PhantomReified<PhantomTypeArgument>, T extends Reified<TypeArgument, any>>(
        typeArgs: [Auth, T], data: Uint8Array
    ): BorrowRequest<ToPhantomTypeArgument<Auth>, ToTypeArgument<T>> {

        return BorrowRequest.fromFields(
            typeArgs,
            BorrowRequest.bcs(toBcs(typeArgs[1])).parse(data)
        )
    }

    toJSONField() {
        return {
            nftId: this.nftId,nft: fieldToJSON<Option<T>>(`0x1::option::Option<${this.$typeArgs[1]}>`, this.nft),sender: this.sender,field: fieldToJSON<Option<TypeName>>(`0x1::option::Option<0x1::type_name::TypeName>`, this.field),promise: this.promise.toJSONField(),inner: this.inner.toJSONField(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<Auth extends PhantomReified<PhantomTypeArgument>, T extends Reified<TypeArgument, any>>(
        typeArgs: [Auth, T], field: any
    ): BorrowRequest<ToPhantomTypeArgument<Auth>, ToTypeArgument<T>> {
        return BorrowRequest.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {nftId: decodeFromJSONField(ID.reified(), field.nftId), nft: decodeFromJSONField(Option.reified(typeArgs[1]), field.nft), sender: decodeFromJSONField("address", field.sender), field: decodeFromJSONField(Option.reified(TypeName.reified()), field.field), promise: decodeFromJSONField(Borrow.reified(), field.promise), inner: decodeFromJSONField(RequestBody.reified(reified.phantom(WithNft.reified(reified.phantom(typeArgs[1]), reified.phantom(BORROW_REQ.reified())))), field.inner)}
        )
    }

    static fromJSON<Auth extends PhantomReified<PhantomTypeArgument>, T extends Reified<TypeArgument, any>>(
        typeArgs: [Auth, T], json: Record<string, any>
    ): BorrowRequest<ToPhantomTypeArgument<Auth>, ToTypeArgument<T>> {
        if (json.$typeName !== BorrowRequest.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(BorrowRequest.$typeName,
            ...typeArgs.map(extractType)),
            json.$typeArgs,
            typeArgs,
        )

        return BorrowRequest.fromJSONField(
            typeArgs,
            json,
        )
    }

    static fromSuiParsedData<Auth extends PhantomReified<PhantomTypeArgument>, T extends Reified<TypeArgument, any>>(
        typeArgs: [Auth, T], content: SuiParsedData
    ): BorrowRequest<ToPhantomTypeArgument<Auth>, ToTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isBorrowRequest(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a BorrowRequest object`);
        }
        return BorrowRequest.fromFieldsWithTypes(
            typeArgs,
            content
        );
    }

    static async fetch<Auth extends PhantomReified<PhantomTypeArgument>, T extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArgs: [Auth, T], id: string
    ): Promise<BorrowRequest<ToPhantomTypeArgument<Auth>, ToTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching BorrowRequest object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isBorrowRequest(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a BorrowRequest object`);
        }

        return BorrowRequest.fromBcs(
            typeArgs,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== ReturnPromise =============================== */

export function isReturnPromise(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::ReturnPromise<");
}

export interface ReturnPromiseFields<T extends PhantomTypeArgument, Field extends PhantomTypeArgument> {
    nftId: ToField<ID>
}

export type ReturnPromiseReified<T extends PhantomTypeArgument, Field extends PhantomTypeArgument> = Reified<
    ReturnPromise<T, Field>,
    ReturnPromiseFields<T, Field>
>;

export class ReturnPromise<T extends PhantomTypeArgument, Field extends PhantomTypeArgument> implements StructClass {
    static readonly $typeName = "0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::ReturnPromise";
    static readonly $numTypeParams = 2;

    readonly $typeName = ReturnPromise.$typeName;

    readonly $fullTypeName: `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::ReturnPromise<${PhantomToTypeStr<T>}, ${PhantomToTypeStr<Field>}>`;

    readonly $typeArgs: [PhantomToTypeStr<T>, PhantomToTypeStr<Field>];

    readonly nftId:
        ToField<ID>

    private constructor(typeArgs: [PhantomToTypeStr<T>, PhantomToTypeStr<Field>], fields: ReturnPromiseFields<T, Field>,
    ) {
        this.$fullTypeName = composeSuiType(
            ReturnPromise.$typeName,
            ...typeArgs
        ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::ReturnPromise<${PhantomToTypeStr<T>}, ${PhantomToTypeStr<Field>}>`;
        this.$typeArgs = typeArgs;

        this.nftId = fields.nftId;
    }

    static reified<T extends PhantomReified<PhantomTypeArgument>, Field extends PhantomReified<PhantomTypeArgument>>(
        T: T, Field: Field
    ): ReturnPromiseReified<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<Field>> {
        return {
            typeName: ReturnPromise.$typeName,
            fullTypeName: composeSuiType(
                ReturnPromise.$typeName,
                ...[extractType(T), extractType(Field)]
            ) as `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request::ReturnPromise<${PhantomToTypeStr<ToPhantomTypeArgument<T>>}, ${PhantomToTypeStr<ToPhantomTypeArgument<Field>>}>`,
            typeArgs: [
                extractType(T), extractType(Field)
            ] as [PhantomToTypeStr<ToPhantomTypeArgument<T>>, PhantomToTypeStr<ToPhantomTypeArgument<Field>>],
            reifiedTypeArgs: [T, Field],
            fromFields: (fields: Record<string, any>) =>
                ReturnPromise.fromFields(
                    [T, Field],
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ReturnPromise.fromFieldsWithTypes(
                    [T, Field],
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ReturnPromise.fromBcs(
                    [T, Field],
                    data,
                ),
            bcs: ReturnPromise.bcs,
            fromJSONField: (field: any) =>
                ReturnPromise.fromJSONField(
                    [T, Field],
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ReturnPromise.fromJSON(
                    [T, Field],
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                ReturnPromise.fromSuiParsedData(
                    [T, Field],
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => ReturnPromise.fetch(
                client,
                [T, Field],
                id,
            ),
            new: (
                fields: ReturnPromiseFields<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<Field>>,
            ) => {
                return new ReturnPromise(
                    [extractType(T), extractType(Field)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ReturnPromise.reified
    }

    static phantom<T extends PhantomReified<PhantomTypeArgument>, Field extends PhantomReified<PhantomTypeArgument>>(
        T: T, Field: Field
    ): PhantomReified<ToTypeStr<ReturnPromise<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<Field>>>> {
        return phantom(ReturnPromise.reified(
            T, Field
        ));
    }

    static get p() {
        return ReturnPromise.phantom
    }

    static get bcs() {
        return bcs.struct("ReturnPromise", {
            nft_id:
                ID.bcs

        })
    };

    static fromFields<T extends PhantomReified<PhantomTypeArgument>, Field extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, Field], fields: Record<string, any>
    ): ReturnPromise<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<Field>> {
        return ReturnPromise.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {nftId: decodeFromFields(ID.reified(), fields.nft_id)}
        )
    }

    static fromFieldsWithTypes<T extends PhantomReified<PhantomTypeArgument>, Field extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, Field], item: FieldsWithTypes
    ): ReturnPromise<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<Field>> {
        if (!isReturnPromise(item.type)) {
            throw new Error("not a ReturnPromise type");
        }
        assertFieldsWithTypesArgsMatch(item, typeArgs);

        return ReturnPromise.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {nftId: decodeFromFieldsWithTypes(ID.reified(), item.fields.nft_id)}
        )
    }

    static fromBcs<T extends PhantomReified<PhantomTypeArgument>, Field extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, Field], data: Uint8Array
    ): ReturnPromise<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<Field>> {

        return ReturnPromise.fromFields(
            typeArgs,
            ReturnPromise.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            nftId: this.nftId,

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends PhantomReified<PhantomTypeArgument>, Field extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, Field], field: any
    ): ReturnPromise<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<Field>> {
        return ReturnPromise.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {nftId: decodeFromJSONField(ID.reified(), field.nftId)}
        )
    }

    static fromJSON<T extends PhantomReified<PhantomTypeArgument>, Field extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, Field], json: Record<string, any>
    ): ReturnPromise<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<Field>> {
        if (json.$typeName !== ReturnPromise.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(ReturnPromise.$typeName,
            ...typeArgs.map(extractType)),
            json.$typeArgs,
            typeArgs,
        )

        return ReturnPromise.fromJSONField(
            typeArgs,
            json,
        )
    }

    static fromSuiParsedData<T extends PhantomReified<PhantomTypeArgument>, Field extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [T, Field], content: SuiParsedData
    ): ReturnPromise<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<Field>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isReturnPromise(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ReturnPromise object`);
        }
        return ReturnPromise.fromFieldsWithTypes(
            typeArgs,
            content
        );
    }

    static async fetch<T extends PhantomReified<PhantomTypeArgument>, Field extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArgs: [T, Field], id: string
    ): Promise<ReturnPromise<ToPhantomTypeArgument<T>, ToPhantomTypeArgument<Field>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ReturnPromise object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isReturnPromise(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ReturnPromise object`);
        }

        return ReturnPromise.fromBcs(
            typeArgs,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
