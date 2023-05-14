module ob_permissions::frozen_pub {
    use sui::tx_context::TxContext;

    use ob_permissions::frozen_publisher;

    struct FROZEN_PUB has drop {}

    fun init(otw: FROZEN_PUB, ctx: &mut TxContext) {
        frozen_publisher::freeze_from_otw(otw, ctx);
    }
}
