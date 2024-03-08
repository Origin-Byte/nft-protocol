
import { BcsType, bcs, fromHEX, toHEX } from '@mysten/bcs'
import { FieldsWithTypes, compressSuiType, parseTypeName } from './util'
import { SuiClient, SuiParsedData } from '@mysten/sui.js/client'

export interface StructClass {
  $typeName: string
  $fullTypeName: string
  $typeArgs: string[]
  toJSONField(): Record<string, any>
  toJSON(): Record<string, any>
}

export interface VectorClass {
  $fullTypeName: string
  toJSONField(): any[]

  readonly vec: any

  readonly kind: 'VectorClass'
}

export class Vector<T extends TypeArgument> implements VectorClass {
  readonly $fullTypeName: `vector<${ToTypeStr<T>}>`

  readonly vec: Array<ToField<T>>
  constructor(fullTypeName: string, vec: Array<ToField<T>>) {
    this.$fullTypeName = fullTypeName as `vector<${ToTypeStr<T>}>`
    this.vec = vec
  }

  toJSONField(): Array<ToJSON<T>> {
    return null as any
  }

  readonly kind = 'VectorClass'
}

export type Primitive = 'bool' | 'u8' | 'u16' | 'u32' | 'u64' | 'u128' | 'u256' | 'address'
export type TypeArgument = StructClass | Primitive | VectorClass

export interface StructClassReified<T extends StructClass, Fields> {
  typeName: T['$typeName'] // e.g., '0x2::balance::Balance', without type arguments
  fullTypeName: ToTypeStr<T> // e.g., '0x2::balance::Balance<0x2::sui:SUI>'
  typeArgs: T['$typeArgs'] // e.g., ['0x2::sui:SUI']
  reifiedTypeArgs: Array<Reified<TypeArgument, any> | PhantomReified<PhantomTypeArgument>>
  bcs: BcsType<any>
  fromFields(fields: Record<string, any>): T
  fromFieldsWithTypes(item: FieldsWithTypes): T
  fromBcs(data: Uint8Array): T
  fromJSONField: (field: any) => T
  fromJSON: (json: Record<string, any>) => T
  fromSuiParsedData: (content: SuiParsedData) => T
  fetch: (client: SuiClient, id: string) => Promise<T>
  new: (fields: Fields) => T
  kind: 'StructClassReified'
}

export interface VectorClassReified<T extends VectorClass> {
  fullTypeName: ToTypeStr<T>
  bcs: BcsType<any>
  fromFields(fields: any[]): T
  fromFieldsWithTypes(item: FieldsWithTypes): T
  fromJSONField: (field: any) => T
  kind: 'VectorClassReified'
}

export type Reified<T extends TypeArgument, Fields> = T extends Primitive
  ? Primitive
  : T extends StructClass
  ? StructClassReified<T, Fields>
  : T extends VectorClass
  ? VectorClassReified<T>
  : never

export type ToTypeArgument<
  T extends Primitive | StructClassReified<StructClass, any> | VectorClassReified<VectorClass>,
> = T extends Primitive
  ? T
  : T extends StructClassReified<infer U, any>
  ? U
  : T extends VectorClassReified<infer U>
  ? U
  : never

export type ToPhantomTypeArgument<T extends PhantomReified<PhantomTypeArgument>> =
  T extends PhantomReified<infer U> ? U : never

export type PhantomTypeArgument = string

export interface PhantomReified<P> {
  phantomType: P
  kind: 'PhantomReified'
}

export function phantom<T extends Reified<TypeArgument, any>>(
  reified: T
): PhantomReified<ToTypeStr<ToTypeArgument<T>>>
export function phantom<P extends PhantomTypeArgument>(phantomType: P): PhantomReified<P>
export function phantom(type: string | Reified<TypeArgument, any>): PhantomReified<string> {
  if (typeof type === 'string') {
    return {
      phantomType: type,
      kind: 'PhantomReified',
    }
  } else {
    return {
      phantomType: type.fullTypeName,
      kind: 'PhantomReified',
    }
  }
}

export type ToTypeStr<T extends TypeArgument> = T extends Primitive
  ? T
  : T extends StructClass
  ? T['$fullTypeName']
  : T extends VectorClass
  ? T['$fullTypeName']
  : never

export type PhantomToTypeStr<T extends PhantomTypeArgument> = T extends PhantomTypeArgument
  ? T
  : never

export function vector<T extends Reified<TypeArgument, any>>(
  T: T
): VectorClassReified<Vector<ToTypeArgument<T>>> {
  const fullTypeName = `vector<${extractType(T)}>` as `vector<${ToTypeStr<ToTypeArgument<T>>}>`

  return {
    fullTypeName,
    bcs: bcs.vector(toBcs(T)),
    fromFieldsWithTypes: (item: FieldsWithTypes) => {
      return new Vector(
        fullTypeName,
        (item as unknown as any[]).map((field: any) => decodeFromFieldsWithTypes(T, field))
      )
    },
    fromFields: (fields: any[]) => {
      return new Vector(
        fullTypeName,
        fields.map(field => decodeFromFields(T, field))
      )
    },

    fromJSONField: (field: any) =>
      new Vector(
        fullTypeName,
        field.map((field: any) => decodeFromJSONField(T, field))
      ),
    kind: 'VectorClassReified',
  }
}

export type ToJSON<T extends TypeArgument> = T extends 'bool'
  ? boolean
  : T extends 'u8'
  ? number
  : T extends 'u16'
  ? number
  : T extends 'u32'
  ? number
  : T extends 'u64'
  ? string
  : T extends 'u128'
  ? string
  : T extends 'u256'
  ? string
  : T extends 'address'
  ? string
  : T extends { $typeName: '0x1::string::String' }
  ? string
  : T extends { $typeName: '0x1::ascii::String' }
  ? string
  : T extends { $typeName: '0x2::object::UID' }
  ? string
  : T extends { $typeName: '0x2::object::ID' }
  ? string
  : T extends { $typeName: '0x2::url::Url' }
  ? string
  : T extends {
      $typeName: '0x1::option::Option'
      __inner: infer U extends TypeArgument
    }
  ? ToJSON<U> | null
  : T extends VectorClass
  ? ReturnType<T['toJSONField']>
  : T extends StructClass
  ? ReturnType<T['toJSONField']>
  : never

export type ToField<T extends TypeArgument> = T extends 'bool'
  ? boolean
  : T extends 'u8'
  ? number
  : T extends 'u16'
  ? number
  : T extends 'u32'
  ? number
  : T extends 'u64'
  ? bigint
  : T extends 'u128'
  ? bigint
  : T extends 'u256'
  ? bigint
  : T extends 'address'
  ? string
  : T extends { $typeName: '0x1::string::String' }
  ? string
  : T extends { $typeName: '0x1::ascii::String' }
  ? string
  : T extends { $typeName: '0x2::object::UID' }
  ? string
  : T extends { $typeName: '0x2::object::ID' }
  ? string
  : T extends { $typeName: '0x2::url::Url' }
  ? string
  : T extends {
      $typeName: '0x1::option::Option'
      __inner: infer U extends TypeArgument
    }
  ? ToField<U> | null
  : T extends VectorClass
  ? T['vec']
  : T extends StructClass
  ? T
  : never

const Address = bcs.bytes(32).transform({
  input: (val: string) => fromHEX(val),
  output: val => toHEX(val),
})

export function toBcs<T extends Reified<TypeArgument, any>>(arg: T): BcsType<any> {
  switch (arg) {
    case 'bool':
      return bcs.bool()
    case 'u8':
      return bcs.u8()
    case 'u16':
      return bcs.u16()
    case 'u32':
      return bcs.u32()
    case 'u64':
      return bcs.u64()
    case 'u128':
      return bcs.u128()
    case 'u256':
      return bcs.u256()
    case 'address':
      return Address
    default:
      return arg.bcs
  }
}

export function extractType<T extends Reified<TypeArgument, any>>(
  reified: T
): ToTypeStr<ToTypeArgument<T>>
export function extractType<T extends PhantomReified<PhantomTypeArgument>>(
  reified: T
): PhantomToTypeStr<ToPhantomTypeArgument<T>>
export function extractType<
  T extends Reified<TypeArgument, any> | PhantomReified<PhantomTypeArgument>,
>(reified: T): string
export function extractType(reified: Reified<TypeArgument, any> | PhantomReified<string>): string {
  switch (reified) {
    case 'u8':
    case 'u16':
    case 'u32':
    case 'u64':
    case 'u128':
    case 'u256':
    case 'bool':
    case 'address':
      return reified
  }
  switch (reified.kind) {
    case 'PhantomReified':
      return reified.phantomType
    case 'StructClassReified':
      return reified.fullTypeName
    case 'VectorClassReified':
      return reified.fullTypeName
  }

  throw new Error('unreachable')
}

export function decodeFromFields(reified: Reified<TypeArgument, any>, field: any) {
  switch (reified) {
    case 'bool':
    case 'u8':
    case 'u16':
    case 'u32':
      return field
    case 'u64':
    case 'u128':
    case 'u256':
      return BigInt(field)
    case 'address':
      return `0x${field}`
  }
  if (reified.kind === 'VectorClassReified') {
    return reified.fromFields(field).vec
  }
  switch (reified.typeName) {
    case '0x1::string::String':
    case '0x1::ascii::String':
      return new TextDecoder().decode(Uint8Array.from(field.bytes)).toString()
    case '0x2::url::Url':
      return new TextDecoder().decode(Uint8Array.from(field.url.bytes)).toString()
    case '0x2::object::ID':
      return `0x${field.bytes}`
    case '0x2::object::UID':
      return `0x${field.id.bytes}`
    case '0x1::option::Option': {
      if (field.vec.length === 0) {
        return null
      }
      return (reified.fromFields(field) as any).vec[0]
    }
    default:
      return reified.fromFields(field)
  }
}

export function decodeFromFieldsWithTypes(reified: Reified<TypeArgument, any>, item: any) {
  switch (reified) {
    case 'bool':
    case 'u8':
    case 'u16':
    case 'u32':
      return item
    case 'u64':
    case 'u128':
    case 'u256':
      return BigInt(item)
    case 'address':
      return item
  }
  if (reified.kind === 'VectorClassReified') {
    return reified.fromFieldsWithTypes(item).vec
  }
  switch (reified.typeName) {
    case '0x1::string::String':
    case '0x1::ascii::String':
    case '0x2::url::Url':
    case '0x2::object::ID':
      return item
    case '0x2::object::UID':
      return item.id
    case '0x2::balance::Balance':
      return reified.fromFields({ value: BigInt(item) })
    case '0x1::option::Option': {
      if (item === null) {
        return null
      }
      return decodeFromFieldsWithTypes((reified as any).reifiedTypeArgs[0], item)
    }
    default:
      return reified.fromFieldsWithTypes(item)
  }
}

export function assertReifiedTypeArgsMatch(
  fullType: string,
  typeArgs: string[],
  reifiedTypeArgs: Array<Reified<TypeArgument, any> | PhantomReified<string>>
) {
  if (reifiedTypeArgs.length !== typeArgs.length) {
    throw new Error(
      `provided item has mismatching number of type argments ${fullType} (expected ${reifiedTypeArgs.length}, got ${typeArgs.length}))`
    )
  }
  for (let i = 0; i < typeArgs.length; i++) {
    if (compressSuiType(typeArgs[i]) !== compressSuiType(extractType(reifiedTypeArgs[i]))) {
      throw new Error(
        `provided item has mismatching type argments ${fullType} (expected ${extractType(
          reifiedTypeArgs[i]
        )}, got ${typeArgs[i]}))`
      )
    }
  }
}

export function assertFieldsWithTypesArgsMatch(
  item: FieldsWithTypes,
  reifiedTypeArgs: Array<Reified<TypeArgument, any> | PhantomReified<string>>
) {
  const { typeArgs: itemTypeArgs } = parseTypeName(item.type)
  assertReifiedTypeArgsMatch(item.type, itemTypeArgs, reifiedTypeArgs)
}

export function fieldToJSON<T extends TypeArgument>(type: string, field: ToField<T>): ToJSON<T> {
  const { typeName, typeArgs } = parseTypeName(type)
  switch (typeName) {
    case 'bool':
      return field as any
    case 'u8':
    case 'u16':
    case 'u32':
      return field as any
    case 'u64':
    case 'u128':
    case 'u256':
      return field.toString() as any
    case 'address':
    case 'signer':
      return field as any
    case 'vector':
      return (field as any[]).map((item: any) => fieldToJSON(typeArgs[0], item)) as any
    // handle special types
    case '0x1::string::String':
    case '0x1::ascii::String':
    case '0x2::url::Url':
    case '0x2::object::ID':
    case '0x2::object::UID':
      return field as any
    case '0x1::option::Option': {
      if (field === null) {
        return null as any
      }
      return fieldToJSON(typeArgs[0], field)
    }
    default:
      return (field as any).toJSONField()
  }
}

export function decodeFromJSONField(typeArg: Reified<TypeArgument, any>, field: any) {
  switch (typeArg) {
    case 'bool':
    case 'u8':
    case 'u16':
    case 'u32':
      return field
    case 'u64':
    case 'u128':
    case 'u256':
      return BigInt(field)
    case 'address':
      return field
  }
  if (typeArg.kind === 'VectorClassReified') {
    return typeArg.fromJSONField(field).vec
  }
  switch (typeArg.typeName) {
    case '0x1::string::String':
    case '0x1::ascii::String':
    case '0x2::url::Url':
    case '0x2::object::ID':
    case '0x2::object::UID':
      return field
    case '0x1::option::Option': {
      if (field === null) {
        return null
      }
      return decodeFromJSONField(typeArg.reifiedTypeArgs[0] as any, field)
    }
    default:
      return typeArg.fromJSONField(field)
  }
}

