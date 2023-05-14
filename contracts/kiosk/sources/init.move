module ob_kiosk::kiosk {
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct KIOSK has drop {}

    fun init(otw: KIOSK, ctx: &mut TxContext) {
        let pub = package::claim(otw, ctx);
        transfer::public_transfer(pub, tx_context::sender(ctx));
    }
}
