module ob_launchpad_v2::launchpad_v2 {
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct LAUNCHPAD_V2 has drop {}

    fun init(otw: LAUNCHPAD_V2, ctx: &mut TxContext) {
        let pub = package::claim(otw, ctx);
        transfer::public_transfer(pub, tx_context::sender(ctx));
    }
}
