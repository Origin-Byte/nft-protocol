module liquidity_layer_v1::liquidity_layer {
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct LIQUIDITY_LAYER has drop {}

    #[allow(unused_function)]
    fun init(otw: LIQUIDITY_LAYER, ctx: &mut TxContext) {
        let pub = package::claim(otw, ctx);
        transfer::public_transfer(pub, tx_context::sender(ctx));
    }
}
