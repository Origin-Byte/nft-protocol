module ob_request::ob_request {
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct OB_REQUEST has drop {}

    #[allow(unused_function)]
    fun init(otw: OB_REQUEST, ctx: &mut TxContext) {
        let pub = package::claim(otw, ctx);
        transfer::public_transfer(pub, tx_context::sender(ctx));
    }
}
