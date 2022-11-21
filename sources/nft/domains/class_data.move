// TODO: Where does it make sense to control supply?
// TODO: Where does it make sense to control ownership of the shared data object?
// This should ideally be controlled solely by the NFT Creators..
module nft_protocol::class_data {
    use std::option::{Self, Option};

    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::object_bag::{Self, ObjectBag};
    use sui::tx_context::{TxContext};

    use nft_protocol::err;

    struct Class has key, store {
        id: UID,
        data: ID,
    }

    struct ClassData<D: store + drop> has key, store {
        id: UID,
        supply: Supply,
        data: D,
    }

    struct MintEvent has copy, drop {
        id: ID,
    }

    struct BurnEvent has copy, drop {
        id: ID,
    }

    /// Create a `ClassData` object and shares it.
    public fun create<D: store>(
        ctx: &mut TxContext,
        supply: u64,
        data: D,
    ) {
        let id = object::new(ctx);

        event::emit(
            MintEvent {
                id: object::uid_to_inner(&id),
            }
        );

        let class_data = ClassData {
            id,
            supply: supply::new(supply, false),
            data,
        };

        transfer::share_object(class_data);
    }

    public fun destroy<D: store + drop>(
        class_data: ClassData<D>,
    ) {
        event::emit(
            BurnEvent {
                id: id(&data),
            }
        );

        let ClassData {
            id,
            data,
        } = class_data;

        object::delete(id);
    }

    // === Getter Functions  ===

    public fun id<D: store>(
        core: &ClassData<D>,
    ): ID {
        object::uid_to_inner(&core.id)
    }

    public fun id_ref<D: store>(
        core: &ClassData<D>,
    ): &ID {
        object::uid_as_inner(&core.id)
    }

    public fun data<D: store>(
        core: &ClassData<D>,
    ): &D {
        &core.data
    }

    public fun data_mut<D: store>(
        core: &mut ClassData<D>,
    ): &mut D {
        &mut core.data
    }
}
