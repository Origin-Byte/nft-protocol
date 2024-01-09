module ob_authlist::ob_authlist {
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct OB_AUTHLIST has drop {}

    #[allow(unused_function)]
    fun init(otw: OB_AUTHLIST, ctx: &mut TxContext) {
        let pub = package::claim(otw, ctx);
        transfer::public_transfer(pub, tx_context::sender(ctx));
    }
}
