module ob_launchpad::launchpad {
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct LAUNCHPAD has drop {}

    #[allow(unused_function)]
    fun init(otw: LAUNCHPAD, ctx: &mut TxContext) {
        let pub = package::claim(otw, ctx);
        transfer::public_transfer(pub, tx_context::sender(ctx));
    }
}
