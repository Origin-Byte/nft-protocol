import {TypeName} from "../../_dependencies/source/0x1/type-name/structs";
import {ID, UID} from "../../_dependencies/source/0x2/object/structs";
import {VecSet} from "../../_dependencies/source/0x2/vec-set/structs";
import {PhantomReified, PhantomToTypeStr, PhantomTypeArgument, Reified, ToField, ToPhantomTypeArgument, ToTypeStr, assertFieldsWithTypesArgsMatch, assertReifiedTypeArgsMatch, decodeFromFields, decodeFromFieldsWithTypes, decodeFromJSONField, extractType, phantom} from "../../_framework/reified";
import {FieldsWithTypes, composeSuiType, compressSuiType} from "../../_framework/util";
import {bcs, fromB64, fromHEX, toHEX} from "@mysten/bcs";
import {SuiClient, SuiParsedData} from "@mysten/sui.js/client";

/* ============================== AddAdmin =============================== */

export function isAddAdmin(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::AddAdmin";
}

export interface AddAdminFields {
    admin: ToField<"address">
}

export type AddAdminReified = Reified<
    AddAdmin,
    AddAdminFields
>;

export class AddAdmin {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::AddAdmin";
    static readonly $numTypeParams = 0;

    readonly $typeName = AddAdmin.$typeName;

    readonly $fullTypeName: "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::AddAdmin";

    ;

    readonly admin:
        ToField<"address">

    private constructor( fields: AddAdminFields,
    ) {
        this.$fullTypeName = AddAdmin.$typeName;

        this.admin = fields.admin;
    }

    static reified(): AddAdminReified {
        return {
            typeName: AddAdmin.$typeName,
            fullTypeName: composeSuiType(
                AddAdmin.$typeName,
                ...[]
            ) as "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::AddAdmin",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                AddAdmin.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                AddAdmin.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                AddAdmin.fromBcs(
                    data,
                ),
            bcs: AddAdmin.bcs,
            fromJSONField: (field: any) =>
                AddAdmin.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                AddAdmin.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => AddAdmin.fetch(
                client,
                id,
            ),
            new: (
                fields: AddAdminFields,
            ) => {
                return new AddAdmin(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return AddAdmin.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<AddAdmin>> {
        return phantom(AddAdmin.reified());
    }

    static get p() {
        return AddAdmin.phantom()
    }

    static get bcs() {
        return bcs.struct("AddAdmin", {
            admin:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): AddAdmin {
        return AddAdmin.reified().new(
            {admin: decodeFromFields("address", fields.admin)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): AddAdmin {
        if (!isAddAdmin(item.type)) {
            throw new Error("not a AddAdmin type");
        }

        return AddAdmin.reified().new(
            {admin: decodeFromFieldsWithTypes("address", item.fields.admin)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): AddAdmin {

        return AddAdmin.fromFields(
            AddAdmin.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            admin: this.admin,

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
    ): AddAdmin {
        return AddAdmin.reified().new(
            {admin: decodeFromJSONField("address", field.admin)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): AddAdmin {
        if (json.$typeName !== AddAdmin.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return AddAdmin.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): AddAdmin {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAddAdmin(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a AddAdmin object`);
        }
        return AddAdmin.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<AddAdmin> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching AddAdmin object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAddAdmin(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a AddAdmin object`);
        }

        return AddAdmin.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== AddDelegate =============================== */

export function isAddDelegate(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::AddDelegate";
}

export interface AddDelegateFields {
    entity: ToField<ID>
}

export type AddDelegateReified = Reified<
    AddDelegate,
    AddDelegateFields
>;

export class AddDelegate {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::AddDelegate";
    static readonly $numTypeParams = 0;

    readonly $typeName = AddDelegate.$typeName;

    readonly $fullTypeName: "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::AddDelegate";

    ;

    readonly entity:
        ToField<ID>

    private constructor( fields: AddDelegateFields,
    ) {
        this.$fullTypeName = AddDelegate.$typeName;

        this.entity = fields.entity;
    }

    static reified(): AddDelegateReified {
        return {
            typeName: AddDelegate.$typeName,
            fullTypeName: composeSuiType(
                AddDelegate.$typeName,
                ...[]
            ) as "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::AddDelegate",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                AddDelegate.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                AddDelegate.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                AddDelegate.fromBcs(
                    data,
                ),
            bcs: AddDelegate.bcs,
            fromJSONField: (field: any) =>
                AddDelegate.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                AddDelegate.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => AddDelegate.fetch(
                client,
                id,
            ),
            new: (
                fields: AddDelegateFields,
            ) => {
                return new AddDelegate(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return AddDelegate.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<AddDelegate>> {
        return phantom(AddDelegate.reified());
    }

    static get p() {
        return AddDelegate.phantom()
    }

    static get bcs() {
        return bcs.struct("AddDelegate", {
            entity:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): AddDelegate {
        return AddDelegate.reified().new(
            {entity: decodeFromFields(ID.reified(), fields.entity)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): AddDelegate {
        if (!isAddDelegate(item.type)) {
            throw new Error("not a AddDelegate type");
        }

        return AddDelegate.reified().new(
            {entity: decodeFromFieldsWithTypes(ID.reified(), item.fields.entity)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): AddDelegate {

        return AddDelegate.fromFields(
            AddDelegate.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            entity: this.entity,

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
    ): AddDelegate {
        return AddDelegate.reified().new(
            {entity: decodeFromJSONField(ID.reified(), field.entity)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): AddDelegate {
        if (json.$typeName !== AddDelegate.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return AddDelegate.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): AddDelegate {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAddDelegate(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a AddDelegate object`);
        }
        return AddDelegate.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<AddDelegate> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching AddDelegate object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAddDelegate(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a AddDelegate object`);
        }

        return AddDelegate.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== AdminField =============================== */

export function isAdminField(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::AdminField";
}

export interface AdminFieldFields {
    typeName: ToField<TypeName>
}

export type AdminFieldReified = Reified<
    AdminField,
    AdminFieldFields
>;

export class AdminField {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::AdminField";
    static readonly $numTypeParams = 0;

    readonly $typeName = AdminField.$typeName;

    readonly $fullTypeName: "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::AdminField";

    ;

    readonly typeName:
        ToField<TypeName>

    private constructor( fields: AdminFieldFields,
    ) {
        this.$fullTypeName = AdminField.$typeName;

        this.typeName = fields.typeName;
    }

    static reified(): AdminFieldReified {
        return {
            typeName: AdminField.$typeName,
            fullTypeName: composeSuiType(
                AdminField.$typeName,
                ...[]
            ) as "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::AdminField",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                AdminField.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                AdminField.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                AdminField.fromBcs(
                    data,
                ),
            bcs: AdminField.bcs,
            fromJSONField: (field: any) =>
                AdminField.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                AdminField.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => AdminField.fetch(
                client,
                id,
            ),
            new: (
                fields: AdminFieldFields,
            ) => {
                return new AdminField(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return AdminField.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<AdminField>> {
        return phantom(AdminField.reified());
    }

    static get p() {
        return AdminField.phantom()
    }

    static get bcs() {
        return bcs.struct("AdminField", {
            type_name:
                TypeName.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): AdminField {
        return AdminField.reified().new(
            {typeName: decodeFromFields(TypeName.reified(), fields.type_name)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): AdminField {
        if (!isAdminField(item.type)) {
            throw new Error("not a AdminField type");
        }

        return AdminField.reified().new(
            {typeName: decodeFromFieldsWithTypes(TypeName.reified(), item.fields.type_name)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): AdminField {

        return AdminField.fromFields(
            AdminField.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            typeName: this.typeName.toJSONField(),

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
    ): AdminField {
        return AdminField.reified().new(
            {typeName: decodeFromJSONField(TypeName.reified(), field.typeName)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): AdminField {
        if (json.$typeName !== AdminField.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return AdminField.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): AdminField {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isAdminField(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a AdminField object`);
        }
        return AdminField.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<AdminField> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching AdminField object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isAdminField(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a AdminField object`);
        }

        return AdminField.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== CreateQuorumEvent =============================== */

export function isCreateQuorumEvent(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::CreateQuorumEvent";
}

export interface CreateQuorumEventFields {
    quorumId: ToField<ID>; typeName: ToField<TypeName>
}

export type CreateQuorumEventReified = Reified<
    CreateQuorumEvent,
    CreateQuorumEventFields
>;

export class CreateQuorumEvent {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::CreateQuorumEvent";
    static readonly $numTypeParams = 0;

    readonly $typeName = CreateQuorumEvent.$typeName;

    readonly $fullTypeName: "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::CreateQuorumEvent";

    ;

    readonly quorumId:
        ToField<ID>
    ; readonly typeName:
        ToField<TypeName>

    private constructor( fields: CreateQuorumEventFields,
    ) {
        this.$fullTypeName = CreateQuorumEvent.$typeName;

        this.quorumId = fields.quorumId;; this.typeName = fields.typeName;
    }

    static reified(): CreateQuorumEventReified {
        return {
            typeName: CreateQuorumEvent.$typeName,
            fullTypeName: composeSuiType(
                CreateQuorumEvent.$typeName,
                ...[]
            ) as "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::CreateQuorumEvent",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                CreateQuorumEvent.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                CreateQuorumEvent.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                CreateQuorumEvent.fromBcs(
                    data,
                ),
            bcs: CreateQuorumEvent.bcs,
            fromJSONField: (field: any) =>
                CreateQuorumEvent.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                CreateQuorumEvent.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => CreateQuorumEvent.fetch(
                client,
                id,
            ),
            new: (
                fields: CreateQuorumEventFields,
            ) => {
                return new CreateQuorumEvent(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return CreateQuorumEvent.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<CreateQuorumEvent>> {
        return phantom(CreateQuorumEvent.reified());
    }

    static get p() {
        return CreateQuorumEvent.phantom()
    }

    static get bcs() {
        return bcs.struct("CreateQuorumEvent", {
            quorum_id:
                ID.bcs
            , type_name:
                TypeName.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): CreateQuorumEvent {
        return CreateQuorumEvent.reified().new(
            {quorumId: decodeFromFields(ID.reified(), fields.quorum_id), typeName: decodeFromFields(TypeName.reified(), fields.type_name)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): CreateQuorumEvent {
        if (!isCreateQuorumEvent(item.type)) {
            throw new Error("not a CreateQuorumEvent type");
        }

        return CreateQuorumEvent.reified().new(
            {quorumId: decodeFromFieldsWithTypes(ID.reified(), item.fields.quorum_id), typeName: decodeFromFieldsWithTypes(TypeName.reified(), item.fields.type_name)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): CreateQuorumEvent {

        return CreateQuorumEvent.fromFields(
            CreateQuorumEvent.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            quorumId: this.quorumId,typeName: this.typeName.toJSONField(),

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
    ): CreateQuorumEvent {
        return CreateQuorumEvent.reified().new(
            {quorumId: decodeFromJSONField(ID.reified(), field.quorumId), typeName: decodeFromJSONField(TypeName.reified(), field.typeName)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): CreateQuorumEvent {
        if (json.$typeName !== CreateQuorumEvent.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return CreateQuorumEvent.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): CreateQuorumEvent {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isCreateQuorumEvent(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a CreateQuorumEvent object`);
        }
        return CreateQuorumEvent.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<CreateQuorumEvent> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching CreateQuorumEvent object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isCreateQuorumEvent(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a CreateQuorumEvent object`);
        }

        return CreateQuorumEvent.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== ExtensionToken =============================== */

export function isExtensionToken(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::ExtensionToken<");
}

export interface ExtensionTokenFields<F extends PhantomTypeArgument> {
    quorumId: ToField<ID>
}

export type ExtensionTokenReified<F extends PhantomTypeArgument> = Reified<
    ExtensionToken<F>,
    ExtensionTokenFields<F>
>;

export class ExtensionToken<F extends PhantomTypeArgument> {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::ExtensionToken";
    static readonly $numTypeParams = 1;

    readonly $typeName = ExtensionToken.$typeName;

    readonly $fullTypeName: `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::ExtensionToken<${PhantomToTypeStr<F>}>`;

    readonly $typeArg: string;

    ;

    readonly quorumId:
        ToField<ID>

    private constructor(typeArg: string, fields: ExtensionTokenFields<F>,
    ) {
        this.$fullTypeName = composeSuiType(ExtensionToken.$typeName,
        typeArg) as `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::ExtensionToken<${PhantomToTypeStr<F>}>`;

        this.$typeArg = typeArg;

        this.quorumId = fields.quorumId;
    }

    static reified<F extends PhantomReified<PhantomTypeArgument>>(
        F: F
    ): ExtensionTokenReified<ToPhantomTypeArgument<F>> {
        return {
            typeName: ExtensionToken.$typeName,
            fullTypeName: composeSuiType(
                ExtensionToken.$typeName,
                ...[extractType(F)]
            ) as `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::ExtensionToken<${PhantomToTypeStr<ToPhantomTypeArgument<F>>}>`,
            typeArgs: [F],
            fromFields: (fields: Record<string, any>) =>
                ExtensionToken.fromFields(
                    F,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ExtensionToken.fromFieldsWithTypes(
                    F,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ExtensionToken.fromBcs(
                    F,
                    data,
                ),
            bcs: ExtensionToken.bcs,
            fromJSONField: (field: any) =>
                ExtensionToken.fromJSONField(
                    F,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ExtensionToken.fromJSON(
                    F,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => ExtensionToken.fetch(
                client,
                F,
                id,
            ),
            new: (
                fields: ExtensionTokenFields<ToPhantomTypeArgument<F>>,
            ) => {
                return new ExtensionToken(
                    extractType(F),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ExtensionToken.reified
    }

    static phantom<F extends PhantomReified<PhantomTypeArgument>>(
        F: F
    ): PhantomReified<ToTypeStr<ExtensionToken<ToPhantomTypeArgument<F>>>> {
        return phantom(ExtensionToken.reified(
            F
        ));
    }

    static get p() {
        return ExtensionToken.phantom
    }

    static get bcs() {
        return bcs.struct("ExtensionToken", {
            quorum_id:
                ID.bcs

        })
    };

    static fromFields<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, fields: Record<string, any>
    ): ExtensionToken<ToPhantomTypeArgument<F>> {
        return ExtensionToken.reified(
            typeArg,
        ).new(
            {quorumId: decodeFromFields(ID.reified(), fields.quorum_id)}
        )
    }

    static fromFieldsWithTypes<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, item: FieldsWithTypes
    ): ExtensionToken<ToPhantomTypeArgument<F>> {
        if (!isExtensionToken(item.type)) {
            throw new Error("not a ExtensionToken type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return ExtensionToken.reified(
            typeArg,
        ).new(
            {quorumId: decodeFromFieldsWithTypes(ID.reified(), item.fields.quorum_id)}
        )
    }

    static fromBcs<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, data: Uint8Array
    ): ExtensionToken<ToPhantomTypeArgument<F>> {

        return ExtensionToken.fromFields(
            typeArg,
            ExtensionToken.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            quorumId: this.quorumId,

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, field: any
    ): ExtensionToken<ToPhantomTypeArgument<F>> {
        return ExtensionToken.reified(
            typeArg,
        ).new(
            {quorumId: decodeFromJSONField(ID.reified(), field.quorumId)}
        )
    }

    static fromJSON<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, json: Record<string, any>
    ): ExtensionToken<ToPhantomTypeArgument<F>> {
        if (json.$typeName !== ExtensionToken.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(ExtensionToken.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return ExtensionToken.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, content: SuiParsedData
    ): ExtensionToken<ToPhantomTypeArgument<F>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isExtensionToken(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ExtensionToken object`);
        }
        return ExtensionToken.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<F extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: F, id: string
    ): Promise<ExtensionToken<ToPhantomTypeArgument<F>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ExtensionToken object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isExtensionToken(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ExtensionToken object`);
        }

        return ExtensionToken.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Foo =============================== */

export function isFoo(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::Foo";
}

export interface FooFields {
    dummyField: ToField<"bool">
}

export type FooReified = Reified<
    Foo,
    FooFields
>;

export class Foo {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::Foo";
    static readonly $numTypeParams = 0;

    readonly $typeName = Foo.$typeName;

    readonly $fullTypeName: "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::Foo";

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor( fields: FooFields,
    ) {
        this.$fullTypeName = Foo.$typeName;

        this.dummyField = fields.dummyField;
    }

    static reified(): FooReified {
        return {
            typeName: Foo.$typeName,
            fullTypeName: composeSuiType(
                Foo.$typeName,
                ...[]
            ) as "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::Foo",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                Foo.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Foo.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Foo.fromBcs(
                    data,
                ),
            bcs: Foo.bcs,
            fromJSONField: (field: any) =>
                Foo.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Foo.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Foo.fetch(
                client,
                id,
            ),
            new: (
                fields: FooFields,
            ) => {
                return new Foo(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Foo.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<Foo>> {
        return phantom(Foo.reified());
    }

    static get p() {
        return Foo.phantom()
    }

    static get bcs() {
        return bcs.struct("Foo", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): Foo {
        return Foo.reified().new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): Foo {
        if (!isFoo(item.type)) {
            throw new Error("not a Foo type");
        }

        return Foo.reified().new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): Foo {

        return Foo.fromFields(
            Foo.bcs.parse(data)
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
    ): Foo {
        return Foo.reified().new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): Foo {
        if (json.$typeName !== Foo.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return Foo.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): Foo {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isFoo(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Foo object`);
        }
        return Foo.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<Foo> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Foo object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isFoo(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Foo object`);
        }

        return Foo.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== MemberField =============================== */

export function isMemberField(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::MemberField";
}

export interface MemberFieldFields {
    typeName: ToField<TypeName>
}

export type MemberFieldReified = Reified<
    MemberField,
    MemberFieldFields
>;

export class MemberField {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::MemberField";
    static readonly $numTypeParams = 0;

    readonly $typeName = MemberField.$typeName;

    readonly $fullTypeName: "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::MemberField";

    ;

    readonly typeName:
        ToField<TypeName>

    private constructor( fields: MemberFieldFields,
    ) {
        this.$fullTypeName = MemberField.$typeName;

        this.typeName = fields.typeName;
    }

    static reified(): MemberFieldReified {
        return {
            typeName: MemberField.$typeName,
            fullTypeName: composeSuiType(
                MemberField.$typeName,
                ...[]
            ) as "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::MemberField",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                MemberField.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                MemberField.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                MemberField.fromBcs(
                    data,
                ),
            bcs: MemberField.bcs,
            fromJSONField: (field: any) =>
                MemberField.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                MemberField.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => MemberField.fetch(
                client,
                id,
            ),
            new: (
                fields: MemberFieldFields,
            ) => {
                return new MemberField(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return MemberField.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<MemberField>> {
        return phantom(MemberField.reified());
    }

    static get p() {
        return MemberField.phantom()
    }

    static get bcs() {
        return bcs.struct("MemberField", {
            type_name:
                TypeName.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): MemberField {
        return MemberField.reified().new(
            {typeName: decodeFromFields(TypeName.reified(), fields.type_name)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): MemberField {
        if (!isMemberField(item.type)) {
            throw new Error("not a MemberField type");
        }

        return MemberField.reified().new(
            {typeName: decodeFromFieldsWithTypes(TypeName.reified(), item.fields.type_name)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): MemberField {

        return MemberField.fromFields(
            MemberField.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            typeName: this.typeName.toJSONField(),

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
    ): MemberField {
        return MemberField.reified().new(
            {typeName: decodeFromJSONField(TypeName.reified(), field.typeName)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): MemberField {
        if (json.$typeName !== MemberField.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return MemberField.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): MemberField {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isMemberField(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a MemberField object`);
        }
        return MemberField.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<MemberField> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching MemberField object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isMemberField(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a MemberField object`);
        }

        return MemberField.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Quorum =============================== */

export function isQuorum(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::Quorum<");
}

export interface QuorumFields<F extends PhantomTypeArgument> {
    id: ToField<UID>; version: ToField<"u64">; admins: ToField<VecSet<"address">>; members: ToField<VecSet<"address">>; delegates: ToField<VecSet<ID>>; adminCount: ToField<"u64">
}

export type QuorumReified<F extends PhantomTypeArgument> = Reified<
    Quorum<F>,
    QuorumFields<F>
>;

export class Quorum<F extends PhantomTypeArgument> {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::Quorum";
    static readonly $numTypeParams = 1;

    readonly $typeName = Quorum.$typeName;

    readonly $fullTypeName: `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::Quorum<${PhantomToTypeStr<F>}>`;

    readonly $typeArg: string;

    ;

    readonly id:
        ToField<UID>
    ; readonly version:
        ToField<"u64">
    ; readonly admins:
        ToField<VecSet<"address">>
    ; readonly members:
        ToField<VecSet<"address">>
    ; readonly delegates:
        ToField<VecSet<ID>>
    ; readonly adminCount:
        ToField<"u64">

    private constructor(typeArg: string, fields: QuorumFields<F>,
    ) {
        this.$fullTypeName = composeSuiType(Quorum.$typeName,
        typeArg) as `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::Quorum<${PhantomToTypeStr<F>}>`;

        this.$typeArg = typeArg;

        this.id = fields.id;; this.version = fields.version;; this.admins = fields.admins;; this.members = fields.members;; this.delegates = fields.delegates;; this.adminCount = fields.adminCount;
    }

    static reified<F extends PhantomReified<PhantomTypeArgument>>(
        F: F
    ): QuorumReified<ToPhantomTypeArgument<F>> {
        return {
            typeName: Quorum.$typeName,
            fullTypeName: composeSuiType(
                Quorum.$typeName,
                ...[extractType(F)]
            ) as `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::Quorum<${PhantomToTypeStr<ToPhantomTypeArgument<F>>}>`,
            typeArgs: [F],
            fromFields: (fields: Record<string, any>) =>
                Quorum.fromFields(
                    F,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Quorum.fromFieldsWithTypes(
                    F,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Quorum.fromBcs(
                    F,
                    data,
                ),
            bcs: Quorum.bcs,
            fromJSONField: (field: any) =>
                Quorum.fromJSONField(
                    F,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Quorum.fromJSON(
                    F,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Quorum.fetch(
                client,
                F,
                id,
            ),
            new: (
                fields: QuorumFields<ToPhantomTypeArgument<F>>,
            ) => {
                return new Quorum(
                    extractType(F),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Quorum.reified
    }

    static phantom<F extends PhantomReified<PhantomTypeArgument>>(
        F: F
    ): PhantomReified<ToTypeStr<Quorum<ToPhantomTypeArgument<F>>>> {
        return phantom(Quorum.reified(
            F
        ));
    }

    static get p() {
        return Quorum.phantom
    }

    static get bcs() {
        return bcs.struct("Quorum", {
            id:
                UID.bcs
            , version:
                bcs.u64()
            , admins:
                VecSet.bcs(bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),}))
            , members:
                VecSet.bcs(bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),}))
            , delegates:
                VecSet.bcs(ID.bcs)
            , admin_count:
                bcs.u64()

        })
    };

    static fromFields<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, fields: Record<string, any>
    ): Quorum<ToPhantomTypeArgument<F>> {
        return Quorum.reified(
            typeArg,
        ).new(
            {id: decodeFromFields(UID.reified(), fields.id), version: decodeFromFields("u64", fields.version), admins: decodeFromFields(VecSet.reified("address"), fields.admins), members: decodeFromFields(VecSet.reified("address"), fields.members), delegates: decodeFromFields(VecSet.reified(ID.reified()), fields.delegates), adminCount: decodeFromFields("u64", fields.admin_count)}
        )
    }

    static fromFieldsWithTypes<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, item: FieldsWithTypes
    ): Quorum<ToPhantomTypeArgument<F>> {
        if (!isQuorum(item.type)) {
            throw new Error("not a Quorum type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Quorum.reified(
            typeArg,
        ).new(
            {id: decodeFromFieldsWithTypes(UID.reified(), item.fields.id), version: decodeFromFieldsWithTypes("u64", item.fields.version), admins: decodeFromFieldsWithTypes(VecSet.reified("address"), item.fields.admins), members: decodeFromFieldsWithTypes(VecSet.reified("address"), item.fields.members), delegates: decodeFromFieldsWithTypes(VecSet.reified(ID.reified()), item.fields.delegates), adminCount: decodeFromFieldsWithTypes("u64", item.fields.admin_count)}
        )
    }

    static fromBcs<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, data: Uint8Array
    ): Quorum<ToPhantomTypeArgument<F>> {

        return Quorum.fromFields(
            typeArg,
            Quorum.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            id: this.id,version: this.version.toString(),admins: this.admins.toJSONField(),members: this.members.toJSONField(),delegates: this.delegates.toJSONField(),adminCount: this.adminCount.toString(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, field: any
    ): Quorum<ToPhantomTypeArgument<F>> {
        return Quorum.reified(
            typeArg,
        ).new(
            {id: decodeFromJSONField(UID.reified(), field.id), version: decodeFromJSONField("u64", field.version), admins: decodeFromJSONField(VecSet.reified("address"), field.admins), members: decodeFromJSONField(VecSet.reified("address"), field.members), delegates: decodeFromJSONField(VecSet.reified(ID.reified()), field.delegates), adminCount: decodeFromJSONField("u64", field.adminCount)}
        )
    }

    static fromJSON<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, json: Record<string, any>
    ): Quorum<ToPhantomTypeArgument<F>> {
        if (json.$typeName !== Quorum.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Quorum.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Quorum.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, content: SuiParsedData
    ): Quorum<ToPhantomTypeArgument<F>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isQuorum(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Quorum object`);
        }
        return Quorum.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<F extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: F, id: string
    ): Promise<Quorum<ToPhantomTypeArgument<F>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Quorum object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isQuorum(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Quorum object`);
        }

        return Quorum.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== RemoveAdmin =============================== */

export function isRemoveAdmin(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::RemoveAdmin";
}

export interface RemoveAdminFields {
    admin: ToField<"address">
}

export type RemoveAdminReified = Reified<
    RemoveAdmin,
    RemoveAdminFields
>;

export class RemoveAdmin {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::RemoveAdmin";
    static readonly $numTypeParams = 0;

    readonly $typeName = RemoveAdmin.$typeName;

    readonly $fullTypeName: "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::RemoveAdmin";

    ;

    readonly admin:
        ToField<"address">

    private constructor( fields: RemoveAdminFields,
    ) {
        this.$fullTypeName = RemoveAdmin.$typeName;

        this.admin = fields.admin;
    }

    static reified(): RemoveAdminReified {
        return {
            typeName: RemoveAdmin.$typeName,
            fullTypeName: composeSuiType(
                RemoveAdmin.$typeName,
                ...[]
            ) as "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::RemoveAdmin",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                RemoveAdmin.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                RemoveAdmin.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                RemoveAdmin.fromBcs(
                    data,
                ),
            bcs: RemoveAdmin.bcs,
            fromJSONField: (field: any) =>
                RemoveAdmin.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                RemoveAdmin.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => RemoveAdmin.fetch(
                client,
                id,
            ),
            new: (
                fields: RemoveAdminFields,
            ) => {
                return new RemoveAdmin(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return RemoveAdmin.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<RemoveAdmin>> {
        return phantom(RemoveAdmin.reified());
    }

    static get p() {
        return RemoveAdmin.phantom()
    }

    static get bcs() {
        return bcs.struct("RemoveAdmin", {
            admin:
                bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),})

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): RemoveAdmin {
        return RemoveAdmin.reified().new(
            {admin: decodeFromFields("address", fields.admin)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): RemoveAdmin {
        if (!isRemoveAdmin(item.type)) {
            throw new Error("not a RemoveAdmin type");
        }

        return RemoveAdmin.reified().new(
            {admin: decodeFromFieldsWithTypes("address", item.fields.admin)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): RemoveAdmin {

        return RemoveAdmin.fromFields(
            RemoveAdmin.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            admin: this.admin,

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
    ): RemoveAdmin {
        return RemoveAdmin.reified().new(
            {admin: decodeFromJSONField("address", field.admin)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): RemoveAdmin {
        if (json.$typeName !== RemoveAdmin.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return RemoveAdmin.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): RemoveAdmin {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isRemoveAdmin(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a RemoveAdmin object`);
        }
        return RemoveAdmin.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<RemoveAdmin> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching RemoveAdmin object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isRemoveAdmin(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a RemoveAdmin object`);
        }

        return RemoveAdmin.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== RemoveDelegate =============================== */

export function isRemoveDelegate(type: string): boolean {
    type = compressSuiType(type);
    return type === "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::RemoveDelegate";
}

export interface RemoveDelegateFields {
    entity: ToField<ID>
}

export type RemoveDelegateReified = Reified<
    RemoveDelegate,
    RemoveDelegateFields
>;

export class RemoveDelegate {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::RemoveDelegate";
    static readonly $numTypeParams = 0;

    readonly $typeName = RemoveDelegate.$typeName;

    readonly $fullTypeName: "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::RemoveDelegate";

    ;

    readonly entity:
        ToField<ID>

    private constructor( fields: RemoveDelegateFields,
    ) {
        this.$fullTypeName = RemoveDelegate.$typeName;

        this.entity = fields.entity;
    }

    static reified(): RemoveDelegateReified {
        return {
            typeName: RemoveDelegate.$typeName,
            fullTypeName: composeSuiType(
                RemoveDelegate.$typeName,
                ...[]
            ) as "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::RemoveDelegate",
            typeArgs: [],
            fromFields: (fields: Record<string, any>) =>
                RemoveDelegate.fromFields(
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                RemoveDelegate.fromFieldsWithTypes(
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                RemoveDelegate.fromBcs(
                    data,
                ),
            bcs: RemoveDelegate.bcs,
            fromJSONField: (field: any) =>
                RemoveDelegate.fromJSONField(
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                RemoveDelegate.fromJSON(
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => RemoveDelegate.fetch(
                client,
                id,
            ),
            new: (
                fields: RemoveDelegateFields,
            ) => {
                return new RemoveDelegate(
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return RemoveDelegate.reified()
    }

    static phantom(): PhantomReified<ToTypeStr<RemoveDelegate>> {
        return phantom(RemoveDelegate.reified());
    }

    static get p() {
        return RemoveDelegate.phantom()
    }

    static get bcs() {
        return bcs.struct("RemoveDelegate", {
            entity:
                ID.bcs

        })
    };

    static fromFields(
         fields: Record<string, any>
    ): RemoveDelegate {
        return RemoveDelegate.reified().new(
            {entity: decodeFromFields(ID.reified(), fields.entity)}
        )
    }

    static fromFieldsWithTypes(
         item: FieldsWithTypes
    ): RemoveDelegate {
        if (!isRemoveDelegate(item.type)) {
            throw new Error("not a RemoveDelegate type");
        }

        return RemoveDelegate.reified().new(
            {entity: decodeFromFieldsWithTypes(ID.reified(), item.fields.entity)}
        )
    }

    static fromBcs(
         data: Uint8Array
    ): RemoveDelegate {

        return RemoveDelegate.fromFields(
            RemoveDelegate.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            entity: this.entity,

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
    ): RemoveDelegate {
        return RemoveDelegate.reified().new(
            {entity: decodeFromJSONField(ID.reified(), field.entity)}
        )
    }

    static fromJSON(
         json: Record<string, any>
    ): RemoveDelegate {
        if (json.$typeName !== RemoveDelegate.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };

        return RemoveDelegate.fromJSONField(
            json,
        )
    }

    static fromSuiParsedData(
         content: SuiParsedData
    ): RemoveDelegate {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isRemoveDelegate(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a RemoveDelegate object`);
        }
        return RemoveDelegate.fromFieldsWithTypes(
            content
        );
    }

    static async fetch(
        client: SuiClient, id: string
    ): Promise<RemoveDelegate> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching RemoveDelegate object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isRemoveDelegate(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a RemoveDelegate object`);
        }

        return RemoveDelegate.fromBcs(
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== ReturnReceipt =============================== */

export function isReturnReceipt(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::ReturnReceipt<");
}

export interface ReturnReceiptFields<F extends PhantomTypeArgument, T extends PhantomTypeArgument> {
    dummyField: ToField<"bool">
}

export type ReturnReceiptReified<F extends PhantomTypeArgument, T extends PhantomTypeArgument> = Reified<
    ReturnReceipt<F, T>,
    ReturnReceiptFields<F, T>
>;

export class ReturnReceipt<F extends PhantomTypeArgument, T extends PhantomTypeArgument> {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::ReturnReceipt";
    static readonly $numTypeParams = 2;

    readonly $typeName = ReturnReceipt.$typeName;

    readonly $fullTypeName: `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::ReturnReceipt<${PhantomToTypeStr<F>}, ${PhantomToTypeStr<T>}>`;

    readonly $typeArgs: [string, string];

    ;

    readonly dummyField:
        ToField<"bool">

    private constructor(typeArgs: [string, string], fields: ReturnReceiptFields<F, T>,
    ) {
        this.$fullTypeName = composeSuiType(ReturnReceipt.$typeName,
        ...typeArgs) as `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::ReturnReceipt<${PhantomToTypeStr<F>}, ${PhantomToTypeStr<T>}>`;

        this.$typeArgs = typeArgs;

        this.dummyField = fields.dummyField;
    }

    static reified<F extends PhantomReified<PhantomTypeArgument>, T extends PhantomReified<PhantomTypeArgument>>(
        F: F, T: T
    ): ReturnReceiptReified<ToPhantomTypeArgument<F>, ToPhantomTypeArgument<T>> {
        return {
            typeName: ReturnReceipt.$typeName,
            fullTypeName: composeSuiType(
                ReturnReceipt.$typeName,
                ...[extractType(F), extractType(T)]
            ) as `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::ReturnReceipt<${PhantomToTypeStr<ToPhantomTypeArgument<F>>}, ${PhantomToTypeStr<ToPhantomTypeArgument<T>>}>`,
            typeArgs: [F, T],
            fromFields: (fields: Record<string, any>) =>
                ReturnReceipt.fromFields(
                    [F, T],
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                ReturnReceipt.fromFieldsWithTypes(
                    [F, T],
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                ReturnReceipt.fromBcs(
                    [F, T],
                    data,
                ),
            bcs: ReturnReceipt.bcs,
            fromJSONField: (field: any) =>
                ReturnReceipt.fromJSONField(
                    [F, T],
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                ReturnReceipt.fromJSON(
                    [F, T],
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => ReturnReceipt.fetch(
                client,
                [F, T],
                id,
            ),
            new: (
                fields: ReturnReceiptFields<ToPhantomTypeArgument<F>, ToPhantomTypeArgument<T>>,
            ) => {
                return new ReturnReceipt(
                    [extractType(F), extractType(T)],
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return ReturnReceipt.reified
    }

    static phantom<F extends PhantomReified<PhantomTypeArgument>, T extends PhantomReified<PhantomTypeArgument>>(
        F: F, T: T
    ): PhantomReified<ToTypeStr<ReturnReceipt<ToPhantomTypeArgument<F>, ToPhantomTypeArgument<T>>>> {
        return phantom(ReturnReceipt.reified(
            F, T
        ));
    }

    static get p() {
        return ReturnReceipt.phantom
    }

    static get bcs() {
        return bcs.struct("ReturnReceipt", {
            dummy_field:
                bcs.bool()

        })
    };

    static fromFields<F extends PhantomReified<PhantomTypeArgument>, T extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [F, T], fields: Record<string, any>
    ): ReturnReceipt<ToPhantomTypeArgument<F>, ToPhantomTypeArgument<T>> {
        return ReturnReceipt.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {dummyField: decodeFromFields("bool", fields.dummy_field)}
        )
    }

    static fromFieldsWithTypes<F extends PhantomReified<PhantomTypeArgument>, T extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [F, T], item: FieldsWithTypes
    ): ReturnReceipt<ToPhantomTypeArgument<F>, ToPhantomTypeArgument<T>> {
        if (!isReturnReceipt(item.type)) {
            throw new Error("not a ReturnReceipt type");
        }
        assertFieldsWithTypesArgsMatch(item, typeArgs);

        return ReturnReceipt.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {dummyField: decodeFromFieldsWithTypes("bool", item.fields.dummy_field)}
        )
    }

    static fromBcs<F extends PhantomReified<PhantomTypeArgument>, T extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [F, T], data: Uint8Array
    ): ReturnReceipt<ToPhantomTypeArgument<F>, ToPhantomTypeArgument<T>> {

        return ReturnReceipt.fromFields(
            typeArgs,
            ReturnReceipt.bcs.parse(data)
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

    static fromJSONField<F extends PhantomReified<PhantomTypeArgument>, T extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [F, T], field: any
    ): ReturnReceipt<ToPhantomTypeArgument<F>, ToPhantomTypeArgument<T>> {
        return ReturnReceipt.reified(
            typeArgs[0], typeArgs[1],
        ).new(
            {dummyField: decodeFromJSONField("bool", field.dummyField)}
        )
    }

    static fromJSON<F extends PhantomReified<PhantomTypeArgument>, T extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [F, T], json: Record<string, any>
    ): ReturnReceipt<ToPhantomTypeArgument<F>, ToPhantomTypeArgument<T>> {
        if (json.$typeName !== ReturnReceipt.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(ReturnReceipt.$typeName,
            ...typeArgs.map(extractType)),
            json.$typeArgs,
            typeArgs,
        )

        return ReturnReceipt.fromJSONField(
            typeArgs,
            json,
        )
    }

    static fromSuiParsedData<F extends PhantomReified<PhantomTypeArgument>, T extends PhantomReified<PhantomTypeArgument>>(
        typeArgs: [F, T], content: SuiParsedData
    ): ReturnReceipt<ToPhantomTypeArgument<F>, ToPhantomTypeArgument<T>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isReturnReceipt(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a ReturnReceipt object`);
        }
        return ReturnReceipt.fromFieldsWithTypes(
            typeArgs,
            content
        );
    }

    static async fetch<F extends PhantomReified<PhantomTypeArgument>, T extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArgs: [F, T], id: string
    ): Promise<ReturnReceipt<ToPhantomTypeArgument<F>, ToPhantomTypeArgument<T>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching ReturnReceipt object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isReturnReceipt(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a ReturnReceipt object`);
        }

        return ReturnReceipt.fromBcs(
            typeArgs,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}

/* ============================== Signatures =============================== */

export function isSignatures(type: string): boolean {
    type = compressSuiType(type);
    return type.startsWith("0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::Signatures<");
}

export interface SignaturesFields<F extends PhantomTypeArgument> {
    list: ToField<VecSet<"address">>
}

export type SignaturesReified<F extends PhantomTypeArgument> = Reified<
    Signatures<F>,
    SignaturesFields<F>
>;

export class Signatures<F extends PhantomTypeArgument> {
    static readonly $typeName = "0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::Signatures";
    static readonly $numTypeParams = 1;

    readonly $typeName = Signatures.$typeName;

    readonly $fullTypeName: `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::Signatures<${PhantomToTypeStr<F>}>`;

    readonly $typeArg: string;

    ;

    readonly list:
        ToField<VecSet<"address">>

    private constructor(typeArg: string, fields: SignaturesFields<F>,
    ) {
        this.$fullTypeName = composeSuiType(Signatures.$typeName,
        typeArg) as `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::Signatures<${PhantomToTypeStr<F>}>`;

        this.$typeArg = typeArg;

        this.list = fields.list;
    }

    static reified<F extends PhantomReified<PhantomTypeArgument>>(
        F: F
    ): SignaturesReified<ToPhantomTypeArgument<F>> {
        return {
            typeName: Signatures.$typeName,
            fullTypeName: composeSuiType(
                Signatures.$typeName,
                ...[extractType(F)]
            ) as `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum::Signatures<${PhantomToTypeStr<ToPhantomTypeArgument<F>>}>`,
            typeArgs: [F],
            fromFields: (fields: Record<string, any>) =>
                Signatures.fromFields(
                    F,
                    fields,
                ),
            fromFieldsWithTypes: (item: FieldsWithTypes) =>
                Signatures.fromFieldsWithTypes(
                    F,
                    item,
                ),
            fromBcs: (data: Uint8Array) =>
                Signatures.fromBcs(
                    F,
                    data,
                ),
            bcs: Signatures.bcs,
            fromJSONField: (field: any) =>
                Signatures.fromJSONField(
                    F,
                    field,
                ),
            fromJSON: (json: Record<string, any>) =>
                Signatures.fromJSON(
                    F,
                    json,
                ),
            fetch: async (client: SuiClient, id: string) => Signatures.fetch(
                client,
                F,
                id,
            ),
            new: (
                fields: SignaturesFields<ToPhantomTypeArgument<F>>,
            ) => {
                return new Signatures(
                    extractType(F),
                    fields
                )
            },
            kind: "StructClassReified",
        }
    }

    static get r() {
        return Signatures.reified
    }

    static phantom<F extends PhantomReified<PhantomTypeArgument>>(
        F: F
    ): PhantomReified<ToTypeStr<Signatures<ToPhantomTypeArgument<F>>>> {
        return phantom(Signatures.reified(
            F
        ));
    }

    static get p() {
        return Signatures.phantom
    }

    static get bcs() {
        return bcs.struct("Signatures", {
            list:
                VecSet.bcs(bcs.bytes(32).transform({input: (val: string) => fromHEX(val),
                output: (val: Uint8Array) => toHEX(val),}))

        })
    };

    static fromFields<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, fields: Record<string, any>
    ): Signatures<ToPhantomTypeArgument<F>> {
        return Signatures.reified(
            typeArg,
        ).new(
            {list: decodeFromFields(VecSet.reified("address"), fields.list)}
        )
    }

    static fromFieldsWithTypes<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, item: FieldsWithTypes
    ): Signatures<ToPhantomTypeArgument<F>> {
        if (!isSignatures(item.type)) {
            throw new Error("not a Signatures type");
        }
        assertFieldsWithTypesArgsMatch(item, [typeArg]);

        return Signatures.reified(
            typeArg,
        ).new(
            {list: decodeFromFieldsWithTypes(VecSet.reified("address"), item.fields.list)}
        )
    }

    static fromBcs<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, data: Uint8Array
    ): Signatures<ToPhantomTypeArgument<F>> {

        return Signatures.fromFields(
            typeArg,
            Signatures.bcs.parse(data)
        )
    }

    toJSONField() {
        return {
            list: this.list.toJSONField(),

        }
    }

    toJSON() {
        return {
            $typeName: this.$typeName,
            $typeArg: this.$typeArg,
            ...this.toJSONField()
        }
    }

    static fromJSONField<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, field: any
    ): Signatures<ToPhantomTypeArgument<F>> {
        return Signatures.reified(
            typeArg,
        ).new(
            {list: decodeFromJSONField(VecSet.reified("address"), field.list)}
        )
    }

    static fromJSON<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, json: Record<string, any>
    ): Signatures<ToPhantomTypeArgument<F>> {
        if (json.$typeName !== Signatures.$typeName) {
            throw new Error("not a WithTwoGenerics json object")
        };
        assertReifiedTypeArgsMatch(
            composeSuiType(Signatures.$typeName,
            extractType(typeArg)),
            [json.$typeArg],
            [typeArg],
        )

        return Signatures.fromJSONField(
            typeArg,
            json,
        )
    }

    static fromSuiParsedData<F extends PhantomReified<PhantomTypeArgument>>(
        typeArg: F, content: SuiParsedData
    ): Signatures<ToPhantomTypeArgument<F>> {
        if (content.dataType !== "moveObject") {
            throw new Error("not an object");
        }
        if (!isSignatures(content.type)) {
            throw new Error(`object at ${(content.fields as any).id} is not a Signatures object`);
        }
        return Signatures.fromFieldsWithTypes(
            typeArg,
            content
        );
    }

    static async fetch<F extends PhantomReified<PhantomTypeArgument>>(
        client: SuiClient, typeArg: F, id: string
    ): Promise<Signatures<ToPhantomTypeArgument<F>>> {
        const res = await client.getObject({
            id,
            options: {
                showBcs: true,
            },
        });
        if (res.error) {
            throw new Error(`error fetching Signatures object at id ${id}: ${res.error.code}`);
        }
        if (res.data?.bcs?.dataType !== "moveObject" || !isSignatures(res.data.bcs.type)) {
            throw new Error(`object at id ${id} is not a Signatures object`);
        }

        return Signatures.fromBcs(
            typeArg,
            fromB64(res.data.bcs.bcsBytes)
        );
    }
}
