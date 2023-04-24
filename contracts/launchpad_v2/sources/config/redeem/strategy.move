module launchpad_v2::redeem_strategy {
    use sui::object::{ID, UID};
    use sui::dynamic_field as df;

    use launchpad_v2::redeem_random::RedeemCommitment;

    /// Could not register redeem parameters as they already exist
    const EConflictingParameters: u64 = 1;

    /// Could not extract redeem parameters as they were not registered on the
    /// object
    const EInvalidParameters: u64 = 2;

    struct RedeemStrategy has store, copy, drop {
        /// Redeem strategy flag
        ///
        /// Valid values:
        ///
        /// 0 - Sequential
        ///
        /// 1 - Pseudorandom
        ///
        /// 2 - Random
        ///
        /// 3 - ByIndex
        ///
        /// 4 - ByID
        ///
        /// Note that random, index, and ID strategies will registed
        flag: u8,
    }

    public fun new(flag: u8): RedeemStrategy {
        RedeemStrategy { flag }
    }

    /// Sequential redeem strategy
    public fun sequential(): RedeemStrategy {
        new(0)
    }

    /// Pseudorandom redeem strategy
    public fun pseudorandom(): RedeemStrategy {
        new(1)
    }

    /// Random redeem strategy
    public fun random(): RedeemStrategy {
        new(2)
    }

    /// Redeem strategy by NFT index
    public fun by_index(): RedeemStrategy {
        new(3)
    }

    /// Redeem strategy by NFT ID
    public fun by_id(): RedeemStrategy {
        new(4)
    }

    /// Return raw `RedeemStrategy` flag
    public fun flag(strategy: &RedeemStrategy): &u8 {
        &strategy.flag
    }

    /// Return whether strategy is sequential
    public fun is_sequential(strategy: &RedeemStrategy): bool {
        strategy.flag == 0
    }

    /// Return whether strategy is pseudorandom
    public fun is_pseudorandom(strategy: &RedeemStrategy): bool {
        strategy.flag == 1
    }

    /// Return whether strategy is random
    public fun is_random(strategy: &RedeemStrategy): bool {
        strategy.flag == 2
    }

    /// Return whether strategy is by index
    public fun is_by_index(strategy: &RedeemStrategy): bool {
        strategy.flag == 3
    }

    /// Return whether strategy is by ID
    public fun is_by_id(strategy: &RedeemStrategy): bool {
        strategy.flag == 4
    }

    struct ParametersKey has copy, drop, store {}

    struct RandomCommitment has store {
        commitment: RedeemCommitment,
        user_commitment: vector<u8>,
    }

    public fun register_parameters_random(
        object: &mut UID,
        commitment: RedeemCommitment,
        user_commitment: vector<u8>,
    ) {
        add_parameters(
            object, RandomCommitment { commitment, user_commitment },
        )
    }

    public fun register_parameters_by_index(object: &mut UID, index: u64) {
        add_parameters(object, index)
    }

    public fun register_parameters_by_id(object: &mut UID, id: ID) {
        add_parameters(object, id)
    }

    public fun extract_parameters_random(
        object: &mut UID,
    ): (RedeemCommitment, vector<u8>) {
        let commitment: RandomCommitment = remove_parameters(object);
        let RandomCommitment { commitment, user_commitment } = commitment;
        (commitment, user_commitment)
    }

    public fun extract_parameters_by_index(object: &mut UID): u64 {
        remove_parameters(object)
    }

    public fun extract_parameters_by_id(object: &mut UID): ID {
        remove_parameters(object)
    }

    // === Helpers ===

    public fun add_parameters<T: store>(object: &mut UID, parameters: T) {
        assert_no_parameters<T>(object);
        df::add(object, ParametersKey {}, parameters)
    }

    public fun remove_parameters<T: store>(object: &mut UID, ): T {
        assert_parameters<T>(object);
        df::remove(object, ParametersKey {})
    }

    public fun has_parameters<T: store>(object: &UID): bool {
        df::exists_with_type<ParametersKey, T>(
            object, ParametersKey {},
        )
    }

    public fun assert_parameters<T: store>(object: &UID) {
        assert!(has_parameters<T>(object),  EInvalidParameters);
    }

    public fun assert_no_parameters<T: store>(object: &UID) {
        assert!(!has_parameters<T>(object),  EConflictingParameters);
    }
}
