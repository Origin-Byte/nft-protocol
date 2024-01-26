import * as reified from "../../_framework/reified";
import {Table} from "../../_dependencies/source/0x2/table/structs";
import {PhantomReified, Reified, ToField, ToTypeArgument, ToTypeStr, TypeArgument, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, fieldToJSON, phantom, toBcs, ToTypeStr as ToPhantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {BcsType, bcs, fromB64} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== CritbitTree =============================== */

export function isCritbitTree(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64::CritbitTree<");
}

export interface CritbitTreeFields<V extends TypeArgument> {
    root: ToField<"u64">; internalNodes: ToField<Table<"u64", ToPhantom<InternalNode>>>; leaves: ToField<Table<"u64", ToPhantom<Leaf<V>>>>; minLeaf: ToField<"u64">; maxLeaf: ToField<"u64">; nextInternalNodeIndex: ToField<"u64">; nextLeafIndex: ToField<"u64">
}

export type CritbitTreeReified<V extends TypeArgument> = Reified<
    CritbitTree<V>,
    CritbitTreeFields<V>
>;

export class CritbitTree<V extends TypeArgument> {
    static readonly $typeName = "0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64::CritbitTree";
    static readonly $numTypeParams = 1;

    readonly $typeName = CritbitTree.$typeName;

    readonly $fullTypeName: `0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64::CritbitTree<${ToTypeStr<V>}>`;

    readonly $typeArg: string;

    ;

    readonly root:
        ToField<"u64">
    ; readonly internalNodes:
        ToField<Table<"u64", ToPhantom<InternalNode>>>
    ; readonly leaves:
        ToField<Table<"u64", ToPhantom<Leaf<V>>>>
    ; readonly minLeaf:
        ToField<"u64">
    ; readonly maxLeaf:
        ToField<"u64">
    ; readonly nextInternalNodeIndex:
        ToField<"u64">
    ; readonly nextLeafIndex:
        ToField<"u64">

    private constructor(typeArg: string, fields: CritbitTreeFields<V>,
    ) {
        this.$fullTypeName = composeSuiType(CritbitTree.$typeName,
        typeArg) as `0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64::CritbitTree<${ToTypeStr<V>}>`;

        this.$typeArg = typeArg;

        this.root = fields.root;; this.internalNodes = fields.internalNodes;; this.leaves = fields.leaves;; this.minLeaf = fields.minLeaf;; this.maxLeaf = fields.maxLeaf;; this.nextInternalNodeIndex = fields.nextInternalNodeIndex;; this.nextLeafIndex = fields.nextLeafIndex;
    }

    static reified<V extends Reified<TypeArgument, any>>(
        V: V
    ): CritbitTreeReified<ToTypeArgument<V>> {
        return {
            typeName: CritbitTree.$typeName,
            fullTypeName: composeSuiType(
                CritbitTree.$typeName,
                ...[extractType(V)]
            ) as `0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64::CritbitTree<${ToTypeStr<ToTypeArgument<V>>}>`,
            typeArgs: [V],
            fromFields: (fields: Record<string, any>) =>
                CritbitTree.fromFields(
                    V,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                CritbitTree.fromFieldsWithTypes(
                    V,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                CritbitTree.fromBcs(
                    V,
                    data,
                ),
            bcs: CritbitTree.bcs(toBcs(V)),
            fromJSONField: (field: any) =>
                CritbitTree.fromJSONField(
                    V,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                CritbitTree.fromJSON(
                    V,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => CritbitTree.fetch(
                client,
                V,
                id,
            ),
            new: (
                fields: CritbitTreeFields<ToTypeArgument<V>>,
            ) => {
                return new CritbitTree(
                    extractType(V),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return CritbitTree.reified
    }

    static phantom<V extends Reified<TypeArgument, any>>(
        V: V
    ): PhantomReified<ToTypeStr<CritbitTree<ToTypeArgument<V>>>> {
        return phantom(CritbitTree.reified(
            V
        ));
    }

    static get p() {
        return CritbitTree.phantom
    }

    static get bcs() {
        return <V extends BcsType<any>>(V: V) => bcs.struct(`CritbitTree<${V.name}>`, {
            root:
                bcs.u64()
            , internal_nodes:
                Table.bcs
            , leaves:
                Table.bcs
            , min_leaf:
                bcs.u64()
            , max_leaf:
                bcs.u64()
            , next_internal_node_index:
                bcs.u64()
            , next_leaf_index:
                bcs.u64()

        })
    };

    static fromFields<V extends Reified<TypeArgument, any>>(
        typeArg: V, fields: Record<string, any>
    ): CritbitTree<ToTypeArgument<V>> {
        return CritbitTree.reified(
            typeArg,
        ).new(
            {root: decodeFromFields("u64", fields.root), internalNodes: decodeFromFields(Table.reified(reified.phantom("u64"), reified.phantom(InternalNode.reified())), fields.internal_nodes), leaves: decodeFromFields(Table.reified(reified.phantom("u64"), reified.phantom(Leaf.reified(typeArg))), fields.leaves), minLeaf: decodeFromFields("u64", fields.min_leaf), maxLeaf: decodeFromFields("u64", fields.max_leaf), nextInternalNodeIndex: decodeFromFields("u64", fields.next_internal_node_index), nextLeafIndex: decodeFromFields("u64", fields.next_leaf_index)}
        )
    }

    static fromFieldsWithTypes<V extends Reified<TypeArgument, any>>(
        typeArg: V, item: FieldsWithTypes
    ): CritbitTree<ToTypeArgument<V>> {
        if (!isCritbitTree(item.type)) {
            throw new Error("not a CritbitTree type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return CritbitTree.reified(
            typeArg,
        ).new(
            {root: decodeFromFieldsWithTypes("u64", item.fields.root), internalNodes: decodeFromFieldsWithTypes(Table.reified(reified.phantom("u64"), reified.phantom(InternalNode.reified())), item.fields.internal_nodes), leaves: decodeFromFieldsWithTypes(Table.reified(reified.phantom("u64"), reified.phantom(Leaf.reified(typeArg))), item.fields.leaves), minLeaf: decodeFromFieldsWithTypes("u64", item.fields.min_leaf), maxLeaf: decodeFromFieldsWithTypes("u64", item.fields.max_leaf), nextInternalNodeIndex: decodeFromFieldsWithTypes("u64", item.fields.next_internal_node_index), nextLeafIndex: decodeFromFieldsWithTypes("u64", item.fields.next_leaf_index)}
        )
    }

    static fromBcs<V extends Reified<TypeArgument, any>>(
        typeArg: V, data: Uint8Array
    ): CritbitTree<ToTypeArgument<V>> {
        const typeArgs = [typeArg];

        return CritbitTree.fromFields(
            typeArg,
            CritbitTree.bcs(toBcs(typeArgs[0])).parse(data)
        )
    }

    toJSONField() {
        return {
            root: this.root.toString(),internalNodes: this.internalNodes.toJSONField(),leaves: this.leaves.toJSONField(),minLeaf: this.minLeaf.toString(),maxLeaf: this.maxLeaf.toString(),nextInternalNodeIndex: this.nextInternalNodeIndex.toString(),nextLeafIndex: this.nextLeafIndex.toString(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<V extends Reified<TypeArgument, any>>(
        typeArg: V, field: any
    ): CritbitTree<ToTypeArgument<V>> {
        return CritbitTree.reified(
            typeArg,
        ).new(
            {root: decodeFromJSONField("u64", field.root), internalNodes: decodeFromJSONField(Table.reified(reified.phantom("u64"), reified.phantom(InternalNode.reified())), field.internalNodes), leaves: decodeFromJSONField(Table.reified(reified.phantom("u64"), reified.phantom(Leaf.reified(typeArg))), field.leaves), minLeaf: decodeFromJSONField("u64", field.minLeaf), maxLeaf: decodeFromJSONField("u64", field.maxLeaf), nextInternalNodeIndex: decodeFromJSONField("u64", field.nextInternalNodeIndex), nextLeafIndex: decodeFromJSONField("u64", field.nextLeafIndex)}
        )
    }

    static fromJSON<V extends Reified<TypeArgument, any>>(
        typeArg: V, json: Record<string, any>
    ): CritbitTree<ToTypeArgument<V>> {
        if (json.$typeName !== CritbitTree.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(CritbitTree.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return CritbitTree.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<V extends Reified<TypeArgument, any>>(
        typeArg: V, content: SuiParsedData
    ): CritbitTree<ToTypeArgument<V>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isCritbitTree(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a CritbitTree object`);
        }
        return CritbitTree.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<V extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArg: V, id: string
    ): Promise<CritbitTree<ToTypeArgument<V>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching CritbitTree object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isCritbitTree(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a CritbitTree object`);
        }

        return CritbitTree.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== InternalNode =============================== */

export function isInternalNode(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64::InternalNode";
}

export interface InternalNodeFields {
    mask: ToField<"u64">; leftChild: ToField<"u64">; rightChild: ToField<"u64">; parent: ToField<"u64">
}

export type InternalNodeReified = Reified<
    InternalNode,
    InternalNodeFields
>;

export class InternalNode {
    static readonly $typeName = "0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64::InternalNode";
    static readonly $numTypeParams = 0;

    readonly $typeName = InternalNode.$typeName;

    readonly $fullTypeName: "0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64::InternalNode";

    ;

    readonly mask:
        ToField<"u64">
    ; readonly leftChild:
        ToField<"u64">
    ; readonly rightChild:
        ToField<"u64">
    ; readonly parent:
        ToField<"u64">

    private constructor( fields: InternalNodeFields,
    ) {
        this.$fullTypeName = InternalNode.$typeName;

        this.mask = fields.mask;; this.leftChild = fields.leftChild;; this.rightChild = fields.rightChild;; this.parent = fields.parent;
    }

    static reified(): InternalNodeReified {
        return {
            typeName: InternalNode.$typeName,
            fullTypeName: composeSuiType(
                InternalNode.$typeName,
                ...[]
            ) as "0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64::InternalNode",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                InternalNode.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                InternalNode.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                InternalNode.fromBcs(
                    data,
                ),
            bcs: InternalNode.bcs,
            fromJSONField: (field: any) =>
                InternalNode.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                InternalNode.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => InternalNode.fetch(
                client,
                id,
            ),
            new: (
                fields: InternalNodeFields,
            ) => {
                return new InternalNode(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return InternalNode.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<InternalNode>> {
        return phantom(InternalNode.reified());
    }

    static get p() {
        return InternalNode.phantom()
    }

    static get bcs() {
        return bcs.struct("InternalNode", {
            mask:
                bcs.u64()
            , left_child:
                bcs.u64()
            , right_child:
                bcs.u64()
            , parent:
                bcs.u64()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): InternalNode {
        return InternalNode.reified().new(
            {mask: decodeFromFields("u64", fields.mask), leftChild: decodeFromFields("u64", fields.left_child), rightChild: decodeFromFields("u64", fields.right_child), parent: decodeFromFields("u64", fields.parent)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): InternalNode {
        if (!isInternalNode(item.type)) {
            throw new Error("not a InternalNode type");
        }

        return InternalNode.reified().new(
            {mask: decodeFromFieldsWithTypes("u64", item.fields.mask), leftChild: decodeFromFieldsWithTypes("u64", item.fields.left_child), rightChild: decodeFromFieldsWithTypes("u64", item.fields.right_child), parent: decodeFromFieldsWithTypes("u64", item.fields.parent)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): InternalNode {

        return InternalNode.fromFields(
            InternalNode.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            mask: this.mask.toString(),leftChild: this.leftChild.toString(),rightChild: this.rightChild.toString(),parent: this.parent.toString(),

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
    ): InternalNode {
        return InternalNode.reified().new(
            {mask: decodeFromJSONField("u64", field.mask), leftChild: decodeFromJSONField("u64", field.leftChild), rightChild: decodeFromJSONField("u64", field.rightChild), parent: decodeFromJSONField("u64", field.parent)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): InternalNode {
        if (json.$typeName !== InternalNode.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return InternalNode.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): InternalNode {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isInternalNode(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a InternalNode object`);
        }
        return InternalNode.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<InternalNode> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching InternalNode object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isInternalNode(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a InternalNode object`);
        }

        return InternalNode.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Leaf =============================== */

export function isLeaf(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64::Leaf<");
}

export interface LeafFields<V extends TypeArgument> {
    key: ToField<"u64">; value: ToField<V>; parent: ToField<"u64">
}

export type LeafReified<V extends TypeArgument> = Reified<
    Leaf<V>,
    LeafFields<V>
>;

export class Leaf<V extends TypeArgument> {
    static readonly $typeName = "0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64::Leaf";
    static readonly $numTypeParams = 1;

    readonly $typeName = Leaf.$typeName;

    readonly $fullTypeName: `0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64::Leaf<${ToTypeStr<V>}>`;

    readonly $typeArg: string;

    ;

    readonly key:
        ToField<"u64">
    ; readonly value:
        ToField<V>
    ; readonly parent:
        ToField<"u64">

    private constructor(typeArg: string, fields: LeafFields<V>,
    ) {
        this.$fullTypeName = composeSuiType(Leaf.$typeName,
        typeArg) as `0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64::Leaf<${ToTypeStr<V>}>`;

        this.$typeArg = typeArg;

        this.key = fields.key;; this.value = fields.value;; this.parent = fields.parent;
    }

    static reified<V extends Reified<TypeArgument, any>>(
        V: V
    ): LeafReified<ToTypeArgument<V>> {
        return {
            typeName: Leaf.$typeName,
            fullTypeName: composeSuiType(
                Leaf.$typeName,
                ...[extractType(V)]
            ) as `0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64::Leaf<${ToTypeStr<ToTypeArgument<V>>}>`,
            typeArgs: [V],
            fromFields: (fields: Record<string, any>) =>
                Leaf.fromFields(
                    V,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Leaf.fromFieldsWithTypes(
                    V,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Leaf.fromBcs(
                    V,
                    data,
                ),
            bcs: Leaf.bcs(toBcs(V)),
            fromJSONField: (field: any) =>
                Leaf.fromJSONField(
                    V,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Leaf.fromJSON(
                    V,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Leaf.fetch(
                client,
                V,
                id,
            ),
            new: (
                fields: LeafFields<ToTypeArgument<V>>,
            ) => {
                return new Leaf(
                    extractType(V),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Leaf.reified
    }

    static phantom<V extends Reified<TypeArgument, any>>(
        V: V
    ): PhantomReified<ToTypeStr<Leaf<ToTypeArgument<V>>>> {
        return phantom(Leaf.reified(
            V
        ));
    }

    static get p() {
        return Leaf.phantom
    }

    static get bcs() {
        return <V extends BcsType<any>>(V: V) => bcs.struct(`Leaf<${V.name}>`, {
            key:
                bcs.u64()
            , value:
                V
            , parent:
                bcs.u64()

        })
    };

    static fromFields<V extends Reified<TypeArgument, any>>(
        typeArg: V, fields: Record<string, any>
    ): Leaf<ToTypeArgument<V>> {
        return Leaf.reified(
            typeArg,
        ).new(
            {key: decodeFromFields("u64", fields.key), value: decodeFromFields(typeArg, fields.value), parent: decodeFromFields("u64", fields.parent)}
        )
    }

    static fromFieldsWithTypes<V extends Reified<TypeArgument, any>>(
        typeArg: V, item: FieldsWithTypes
    ): Leaf<ToTypeArgument<V>> {
        if (!isLeaf(item.type)) {
            throw new Error("not a Leaf type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Leaf.reified(
            typeArg,
        ).new(
            {key: decodeFromFieldsWithTypes("u64", item.fields.key), value: decodeFromFieldsWithTypes(typeArg, item.fields.value), parent: decodeFromFieldsWithTypes("u64", item.fields.parent)}
        )
    }

    static fromBcs<V extends Reified<TypeArgument, any>>(
        typeArg: V, data: Uint8Array
    ): Leaf<ToTypeArgument<V>> {
        const typeArgs = [typeArg];

        return Leaf.fromFields(
            typeArg,
            Leaf.bcs(toBcs(typeArgs[0])).parse(data)
        )
    }

    toJSONField() {
        return {
            key: this.key.toString(),value: fieldToJSON<V>(this.$typeArg, this.value),parent: this.parent.toString(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<V extends Reified<TypeArgument, any>>(
        typeArg: V, field: any
    ): Leaf<ToTypeArgument<V>> {
        return Leaf.reified(
            typeArg,
        ).new(
            {key: decodeFromJSONField("u64", field.key), value: decodeFromJSONField(typeArg, field.value), parent: decodeFromJSONField("u64", field.parent)}
        )
    }

    static fromJSON<V extends Reified<TypeArgument, any>>(
        typeArg: V, json: Record<string, any>
    ): Leaf<ToTypeArgument<V>> {
        if (json.$typeName !== Leaf.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Leaf.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Leaf.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<V extends Reified<TypeArgument, any>>(
        typeArg: V, content: SuiParsedData
    ): Leaf<ToTypeArgument<V>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isLeaf(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Leaf object`);
        }
        return Leaf.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<V extends Reified<TypeArgument, any>>(
        client: SuiClient, typeArg: V, id: string
    ): Promise<Leaf<ToTypeArgument<V>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Leaf object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isLeaf(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Leaf object`);
        }

        return Leaf.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
