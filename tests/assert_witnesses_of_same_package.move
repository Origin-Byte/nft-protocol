#[test_only]
module nft_protocol::test_assert_witnesses_of_same_package {
    use nft_protocol::utils::get_package_and_type;
    use std::string;
    use std::debug::print;

    struct Witness {}

    #[test]
    public fun it_works() {
        let (_package, type) = get_package_and_type<Witness>();
        print(&type);

        assert!(type == string::utf8(b"Witness"), 0);
    }
}
