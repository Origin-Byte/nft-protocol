import {Option} from "../../_dependencies/source/0x1/option/structs";
import {UID} from "../../_dependencies/source/0x2/object/structs";
import {PhantomReified, Reified, StructClass, ToField, ToTypeArgument, ToTypeStr, TypeArgument, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom, toBcs} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {BcsType, bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Escrow =============================== */

export function isEscrow(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::escrow_shared::Escrow<");
}

export interface EscrowFields<T extends TypeArgument> {
    id: ToField<UID>; sender: ToField<"address">; recipient: ToField<"address">; arbitrator: ToField<Option<"address">>; obj: ToField<Option<T>>
}

export type EscrowReified<T extends TypeArgument> = Reified<
    Escrow<T>,
    EscrowFields<T>
>;

export class Escrow<T extends TypeArgument> implements StructClass {
    static readonly $typeName = "0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::escrow_shared::Escrow";
    static readonly $numTypeParams = 1;

    readonly $typeName = Escrow.$typeName;

    readonly $fullTypeName: `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::escrow_shared::Escrow<${ToTypeStr<T>}>`;

    readonly $typeArgs: [ToTypeStr<T>];

    readonly id:
        ToField<UID>
    ; readonly sender:
        ToField<"address">
    ; readonly recipient:
        ToField<"address">
    ; readonly arbitrator:
        ToField<Option<"address">>
    ; readonly obj:
        ToField<Option<T>>

    private constructor(typeArgs: [ToTypeStr<T>], fields: EscrowFields<T>,
    ) {
        this.$fullTypeName = composeSuiType(
            Escrow.$typeName,
            ...typeArgs
        ) as `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::escrow_shared::Escrow<${ToTypeStr<T>}>`;
        this.$typeArgs = typeArgs;

        this.id = fields.id;; this.sender = fields.sender;; this.recipient = fields.recipient;; this.arbitrator = fields.arbitrator;; this.obj = fields.obj;
    }

    static reified<T extends Reified<TypeArgument, any>>(
        T: T
    ): EscrowReified<ToTypeArgument<T>> {
        return {
            typeName: Escrow.$typeName,
            fullTypeName: composeSuiType(
                Escrow.$typeName,
                ...[extractType(T)]
            ) as `0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::escrow_shared::Escrow<${ToTypeStr<ToTypeArgument<T>>}>`,
            typeArgs: [
                extractType(T)
            ] as [ToTypeStr<ToTypeArgument<T>>],
            reifiedTypeArgs: [T],
            fromFields: (fields: Record<string, any>) =>
                Escrow.fromFields(
                    T,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Escrow.fromFieldsWithTypes(
                    T,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Escrow.fromBcs(
                    T,
                    data,
                ),
            bcs: Escrow.bcs(toBcs(T)),
            fromJSONField: (field: any) =>
                Escrow.fromJSONField(
                    T,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Escrow.fromJSON(
                    T,
                    json,
                ),
            fromSuiParsedData: (content: SuiParsedData) =>
                Escrow.fromSuiParsedData(
                    T,
                    content,
                ),
            fetch: async (client: SuiClient, id: string) => Escrow.fetch(
                client,
                T,
                id,
            ),
            new: (
                fields: EscrowFields<ToTypeArgument<T>>,
            ) => {
                return new Escrow(
                    [extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Escrow.reified
    }

    static phantom<T extends Reified<TypeArgument, any>>(
        T: T
    ): PhantomReified<ToTypeStr<Escrow<ToTypeArgument<T>>>> {
        return phantom(Escrow.reified(
            T
        ));
    }

    static get p() {
        return Escrow.phantom
    }

    static get bcs() {
        return <T extends BcsType<any>>(T: T) => bcs.struct(`Escrow<${T.name}>`, {
            id:
                UID.bcs
            , sender:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , recipient:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})
            , arbitrator:
                Option.bcs(bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),}))
            , obj:
                Option.bcs(T)

        })
    };

    static fromFields<T extends Reified<TypeArgument, any>>(
        typeArg: T, fields: Record<string, any>
    ): Escrow<ToTypeArgument<T>> {
        return Escrow.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), sender: decodeFromFields("address", fields.sender), recipient: decodeFromFields("address", fields.recipient), arbitrator: decodeFromFields(Option.reified("address"), fields.arbitrator), obj: decodeFromFields(Option.reified(typeArg), fields.obj)}
        )
    }

    static fromFieldsWithTypes<T extends Reified<TypeArgument, any>>(
        typeArg: T, item: FieldsWithTypes
    ): Escrow<ToTypeArgument<T>> {
        if (!isEscrow(item.type)) {
            throw new Error("not a Escrow type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Escrow.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), sender: decodeFromFieldsWithTypes("address", item.fields.sender), recipient: decodeFromFieldsWithTypes("address", item.fields.recipient), arbitrator: decodeFromFieldsWithTypes(Option.reified("address"), item.fields.arbitrator), obj: decodeFromFieldsWithTypes(Option.reified(typeArg), item.fields.obj)}
        )
    }

    static fromBcs<T extends Reified<TypeArgument, any>>(
        typeArg: T, data: Uint8Array
    ): Escrow<ToTypeArgument<T>> {
        const typeArgs = [typeArg];

        return Escrow.fromFields(
            typeArg,
            Escrow.bcs(toBcs(typeArgs[0])).parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,sender: this.sender,recipient: this.recipient,arbitrator: fieldToJSON<Option<"address">>(`0x1::option::Option<address>`, this.arbitrator),obj: fieldToJSON<Option<T>>(`0x1::option::Option<${this.$typeArgs[0]}>`, this.obj),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArgs: this.$typeArgs,
            ...this.toJSONField()
        }
    }

    static fromJSONField<T extends Reified<TypeArgument, any>>(
        typeArg: T, field: any
    ): Escrow<ToTypeArgument<T>> {
        return Escrow.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), sender: decodeFromJSONField("address", field.sender), recipient: decodeFromJSONField("address", field.recipient), arbitrator: decodeFromJSONField(Option.reified("address"), field.arbitrator), obj: decodeFromJSONField(Option.reified(typeArg), field.obj)}
        )
    }

    static fromJSON<T extends Reified<TypeArgument, any>>(
        typeArg: T, json: Record<string, any>
    ): Escrow<ToTypeArgument<T>> {
        if (json.$typeName !== Escrow.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Escrow.$typeName,
            extractType(typeArg)),
            json.$typeArgs,
            [typeArg],
        )

        return Escrow.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<T extends Reified<TypeArgument, any>>(
        typeArg: T, content: SuiParsedData
    ): Escrow<ToTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isEscrow(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Escrow object`);
        }
        return Escrow.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<T extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArg: T, id: string
    ): Promise<Escrow<ToTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Escrow object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isEscrow(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Escrow object`);
        }

        return Escrow.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
