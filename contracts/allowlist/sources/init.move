module ob_allowlist::ob_allowlist {
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct OB_ALLOWLIST has drop {}

    fun init(otw: OB_ALLOWLIST, ctx: &mut TxContext) {
        let pub = package::claim(otw, ctx);
        transfer::public_transfer(pub, tx_context::sender(ctx));
    }
}
