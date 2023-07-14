#[test_only]
/// Tests trading compatibility with locked NFTs
module liquidity_layer_v1::test_orderbook_locked {
    #[test]
    fun test_transfer_to_unlocked() {}

    #[test]
    fun test_transfer_to_unlocked_non_ob() {}

    #[test]
    fun test_transfer_to_locked() {}

    #[test]
    fun test_transfer_to_locked_non_ob() {}

    #[test]
    fun test_transfer_listed_non_ob() {}

    #[test]
    fun test_transfer_exclusively_listed_non_ob() {}

    #[test]
    fun test_request_payment() {}
}