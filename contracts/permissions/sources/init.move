module ob_permissions::permissions {
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct PERMISSIONS has drop {}

    #[allow(unused_function)]
    fun init(otw: PERMISSIONS, ctx: &mut TxContext) {
        let pub = package::claim(otw, ctx);
        transfer::public_transfer(pub, tx_context::sender(ctx));
    }
}
