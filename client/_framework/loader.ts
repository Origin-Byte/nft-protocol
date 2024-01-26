
import { compressSuiType, parseTypeName } from './util'
import {
  PhantomReified,
  PhantomTypeArgument,
  Primitive,
  Reified,
  StructClass,
  StructClassReified,
  TypeArgument,
  VectorClass,
  VectorClassReified,
  vector,
} from './reified'

export type PrimitiveValue = string | number | boolean | bigint

interface _StructClass {
  $typeName: string
  $numTypeParams: number
  reified(
    ...Ts: Array<Reified<TypeArgument, any> | PhantomReified<PhantomTypeArgument>>
  ): StructClassReified<StructClass, any>
}

export class StructClassLoader {
  private map: Map<string, _StructClass> = new Map()

  register(...classes: _StructClass[]) {
    for (const cls of classes) {
      this.map.set(cls.$typeName, cls)
    }
  }

  reified<T extends Primitive>(type: T): T
  reified(type: `vector<${string}>`): VectorClassReified<VectorClass>
  reified(type: string): StructClassReified<StructClass, any>
  reified(
    type: string
  ): StructClassReified<StructClass, any> | VectorClassReified<VectorClass> | string {
    const { typeName, typeArgs } = parseTypeName(compressSuiType(type))
    switch (typeName) {
      case 'bool':
      case 'u8':
      case 'u16':
      case 'u32':
      case 'u64':
      case 'u128':
      case 'u256':
      case 'address':
        return typeName
      case 'vector': {
        if (typeArgs.length !== 1) {
          throw new Error(`Vector expects 1 type argument, but got ${typeArgs.length}`)
        }
        return vector(this.reified(typeArgs[0]))
      }
    }

    if (!this.map.has(typeName)) {
      throw new Error(`Unknown type ${typeName}`)
    }

    const cls = this.map.get(typeName)!
    if (cls.$numTypeParams !== typeArgs.length) {
      throw new Error(
        `Type ${typeName} expects ${cls.$numTypeParams} type arguments, but got ${typeArgs.length}`
      )
    }

    return cls.reified(...typeArgs.map(t => this.reified(t)))
  }
}

export const structClassLoaderSource = new StructClassLoader()
export const structClassLoaderOnchain = new StructClassLoader()

