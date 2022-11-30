// module nft_protocol::core_data {
//     use std::option::{Self, Option};

//     use sui::event;
//     use sui::object::{Self, UID, ID};
//     use sui::object_bag::{Self, ObjectBag};
//     use sui::tx_context::{TxContext};

//     use nft_protocol::err;

//     struct CoreData<D: store + drop> has key, store {
//         id: UID,
//         data: D,
//     }

//     struct MintEvent has copy, drop {
//         id: ID,
//     }

//     struct BurnEvent has copy, drop {
//         id: ID,
//     }

//     /// Create a `CoreData` object and returns it.
//     public fun create<D: store>(
//         ctx: &mut TxContext,
//         data: D,
//     ): CoreData<D> {
//         let id = object::new(ctx);

//         event::emit(
//             MintEvent {
//                 id: object::uid_to_inner(&id),
//             }
//         );

//         CoreData {
//             id,
//             data,
//         }
//     }

//     public fun destroy<D: store + drop>(
//         core: CoreData<D>,
//     ) {
//         event::emit(
//             BurnEvent {
//                 id: id(&data),
//             }
//         );

//         let CoreData {
//             id,
//             data,
//         } = core;

//         object::delete(id);
//     }

//     // === Getter Functions  ===

//     public fun id<D: store>(
//         core: &CoreData<D>,
//     ): ID {
//         object::uid_to_inner(&core.id)
//     }

//     public fun id_ref<D: store>(
//         core: &CoreData<D>,
//     ): &ID {
//         object::uid_as_inner(&core.id)
//     }

//     public fun data<D: store>(
//         core: &CoreData<D>,
//     ): &D {
//         &core.data
//     }

//     public fun data_mut<D: store>(
//         core: &mut CoreData<D>,
//     ): &mut D {
//         &mut core.data
//     }
// }
