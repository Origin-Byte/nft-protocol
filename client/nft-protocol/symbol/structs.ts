import {String} from "../../_dependencies/source/0x1/string/structs";
import {PhantomReified, Reified, ToField, ToTypeStr, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== Symbol =============================== */

export function isSymbol(type: string): boolean {
    type = compressSuiType(type);
    return type === "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::symbol::Symbol";
}

export interface SymbolFields {
    symbol: ToField<String>
}

export type SymbolReified = Reified<
    Symbol,
    SymbolFields
>;

export class Symbol {
    static readonly $typeName = "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::symbol::Symbol";
    static readonly $numTypeParams = 0;

    readonly $typeName = Symbol.$typeName;

    readonly $fullTypeName: "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::symbol::Symbol";

    ;

    readonly symbol:
        ToField<String>

    private constructor( fields: SymbolFields,
    ) {
        this.$fullTypeName = Symbol.$typeName;

        this.symbol = fields.symbol;
    }

    static reified(): SymbolReified {
        return {
            typeName: Symbol.$typeName,
            fullTypeName: composeSuiType(
                Symbol.$typeName,
                ...[]
            ) as "0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9::symbol::Symbol",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Symbol.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Symbol.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Symbol.fromBcs(
                    data,
                ),
            bcs: Symbol.bcs,
            fromJSONField: (field: any) =>
                Symbol.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Symbol.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Symbol.fetch(
                client,
                id,
            ),
            new: (
                fields: SymbolFields,
            ) => {
                return new Symbol(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Symbol.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Symbol>> {
        return phantom(Symbol.reified());
    }

    static get p() {
        return Symbol.phantom()
    }

    static get bcs() {
        return bcs.struct("Symbol", {
            symbol:
                String.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Symbol {
        return Symbol.reified().new(
            {symbol: decodeFromFields(String.reified(), fields.symbol)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Symbol {
        if (!isSymbol(item.type)) {
            throw new Error("not a Symbol type");
        }

        return Symbol.reified().new(
            {symbol: decodeFromFieldsWithTypes(String.reified(), item.fields.symbol)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Symbol {

        return Symbol.fromFields(
            Symbol.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            symbol: this.symbol,

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
    ): Symbol {
        return Symbol.reified().new(
            {symbol: decodeFromJSONField(String.reified(), field.symbol)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Symbol {
        if (json.$typeName !== Symbol.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Symbol.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Symbol {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isSymbol(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Symbol object`);
        }
        return Symbol.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Symbol> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Symbol object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isSymbol(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Symbol object`);
        }

        return Symbol.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
