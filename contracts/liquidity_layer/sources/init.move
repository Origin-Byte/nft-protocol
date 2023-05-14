module liquidity_layer::liquidity_layer {
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct LIQUIDITY_LAYER has drop {}

    fun init(otw: LIQUIDITY_LAYER, ctx: &mut TxContext) {
        let pub = package::claim(otw, ctx);
        transfer::public_transfer(pub, tx_context::sender(ctx));
    }
}
