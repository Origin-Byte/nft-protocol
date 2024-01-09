module ob_allowlist::frozen_pub {
    use sui::tx_context::TxContext;

    use ob_permissions::frozen_publisher;

    struct FROZEN_PUB has drop {}

    #[allow(unused_function)]
    fun init(otw: FROZEN_PUB, ctx: &mut TxContext) {
        frozen_publisher::freeze_from_otw(otw, ctx);
    }
}
