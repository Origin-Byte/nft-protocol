/// A module for Pseudo-Randomness
module ob_pseudorandom::pseudorandom {
    use std::hash;
    use std::vector;

    use sui::bcs;
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    /// Conversion to integer would truncate bytes
    const ETruncatedBytes: u64 = 1;

    /// Require that at least 32 bytes of entropy is provided to generate 32
    /// byte random numbers.
    const ELowEntropy: u64 = 1;

    /// Resource that wraps an integer counter
    struct Counter has key {
        id: UID,
        value: u256
    }

    #[allow(unused_function)]
    /// Share a `Counter` resource with value `i`
    fun init(ctx: &mut TxContext) {
        // Create and share a Counter resource. This is a privileged operation that
        // can only be done inside the module that declares the `Counter` resource
        transfer::share_object(Counter { id: object::new(ctx), value: 0 });
    }

    /// Increment the value of the supplied `Counter` resource
    fun increment(counter: &mut Counter): u256 {
        let c_ref = &mut counter.value;
        *c_ref = *c_ref + 1;
        *c_ref
    }

    /// Acquire pseudo-random value using `Counter`, transaction primitives,
    /// and user-provided nonce
    public fun rand(
        nonce: vector<u8>,
        counter: &mut Counter,
        ctx: &mut TxContext,
    ): vector<u8> {
        vector::append(&mut nonce, nonce_counter(counter));
        vector::append(&mut nonce, nonce_primitives(ctx));
        rand_with_nonce(nonce)
    }

    /// Acquire pseudo-random value using transaction primitives and
    /// user-provided nonce
    public fun rand_no_counter(
        nonce: vector<u8>,
        ctx: &mut TxContext,
    ): vector<u8> {
        vector::append(&mut nonce, nonce_primitives(ctx));
        rand_with_nonce(nonce)
    }

    /// Acquire pseudo-random value using `Counter` and transaction primitives
    ///
    /// It is recommended that the user use a method that allows passing a
    /// custom nonce that would allow greater randomization.
    public fun rand_no_nonce(
        counter: &mut Counter,
        ctx: &mut TxContext,
    ): vector<u8> {
        let nonce = vector::empty();
        vector::append(&mut nonce, nonce_counter(counter));
        vector::append(&mut nonce, nonce_primitives(ctx));
        rand_with_nonce(nonce)
    }

    /// Acquire pseudo-random value using `Counter` and user-provided nonce
    public fun rand_no_ctx(
        nonce: vector<u8>,
        counter: &mut Counter,
    ): vector<u8> {
        vector::append(&mut nonce, nonce_counter(counter));
        rand_with_nonce(nonce)
    }

    /// Acquire pseudo-random value using `Counter`
    ///
    /// It is recommended that the user use a method that allows passing a
    /// custom nonce that would allow greater randomization, or at least
    /// use more than one source of randomness.
    public fun rand_with_counter(counter: &mut Counter): vector<u8> {
        let nonce = vector::empty();
        vector::append(&mut nonce, nonce_counter(counter));
        rand_with_nonce(nonce)
    }

    /// Acquire pseudo-random value using transaction primitives
    ///
    /// It is recommended that the user use a method that allows passing a
    /// custom nonce that would allow greater randomization, or at least
    /// use more than one source of randomness.
    public fun rand_with_ctx(ctx: &mut TxContext): vector<u8> {
        let nonce = vector::empty();
        vector::append(&mut nonce, nonce_primitives(ctx));
        rand_with_nonce(nonce)
    }

    /// Acquire pseudo-random value using user-provided nonce
    ///
    /// It is recommended that the user use at least more than one source of
    /// randomness.
    public fun rand_with_nonce(nonce: vector<u8>): vector<u8> {
        assert!(vector::length(&nonce) >= 32, ELowEntropy);
        hash::sha3_256(nonce)
    }

    // === Helpers ===

    /// Generate nonce from transaction primitives
    fun nonce_primitives(ctx: &mut TxContext): vector<u8> {
        let uid = object::new(ctx);
        let object_nonce = object::uid_to_bytes(&uid);
        object::delete(uid);

        let epoch_nonce = bcs::to_bytes(&tx_context::epoch(ctx));
        let sender_nonce = bcs::to_bytes(&tx_context::sender(ctx));

        vector::append(&mut object_nonce, epoch_nonce);
        vector::append(&mut object_nonce, sender_nonce);

        object_nonce
    }

    /// Generate nonce from `Counter`
    fun nonce_counter(counter: &mut Counter): vector<u8> {
        bcs::to_bytes(&increment(counter))
    }

    /// Deserialize `u8` from BCS bytes
    public fun bcs_u8_from_bytes(bytes: vector<u8>): u8 {
        bcs::peel_u8(&mut bcs::new(bytes))
    }

    /// Deserialize `u64` from BCS bytes
    public fun bcs_u64_from_bytes(bytes: vector<u8>): u64 {
        bcs::peel_u64(&mut bcs::new(bytes))
    }

    /// Deserialize `u128` from BCS bytes
    public fun bcs_u128_from_bytes(bytes: vector<u8>): u128 {
        bcs::peel_u128(&mut bcs::new(bytes))
    }

    /// Transpose bytes into `u8`
    ///
    /// Zero byte will be used for empty vector.
    ///
    /// #### Panics
    ///
    /// Panics if bytes vector is longer than 1 byte due to potential to
    /// truncate data unexpectedly
    public fun u8_from_bytes(bytes: &vector<u8>): u8 {
        // Cap length at 1 byte
        let len = vector::length(bytes);
        assert!(len <= 1, ETruncatedBytes);

        if (vector::length(bytes) < 1) {
            0
        } else {
            *vector::borrow(bytes, 0)
        }
    }

    /// Transpose bytes into `u64`
    ///
    /// Zero bytes will be used for vectors shorter than 8 bytes
    ///
    /// #### Panics
    ///
    /// Panics if bytes vector is longer than 8 bytes due to potential to
    /// truncate data unexpectedly
    public fun u64_from_bytes(bytes: &vector<u8>): u64 {
        let m: u64 = 0;

        // Cap length at 8 bytes
        let len = vector::length(bytes);
        assert!(len <= 8, ETruncatedBytes);

        let i = 0;
        while (i < len) {
            m = m << 8;
            let byte = *vector::borrow(bytes, i);
            m = m + (byte as u64);
            i = i + 1;
        };

        m
    }

    /// Transpose bytes into `u64`
    ///
    /// Zero bytes will be used for vectors shorter than 16 bytes
    ///
    /// #### Panics
    ///
    /// Panics if bytes vector is longer than 16 bytes due to potential to
    /// truncate data unexpectedly
    public fun u128_from_bytes(bytes: &vector<u8>): u128 {
        let m: u128 = 0;

        // Cap length at 16 bytes
        let len = vector::length(bytes);
        assert!(len <= 16, ETruncatedBytes);

        let i = 0;
        while (i < len) {
            m = m << 8;
            let byte = *vector::borrow(bytes, i);
            m = m + (byte as u128);
            i = i + 1;
        };

        m
    }

    /// Transpose bytes into `u256`
    ///
    /// Zero bytes will be used for vectors shorter than 32 bytes
    ///
    /// #### Panics
    ///
    /// Panics if bytes vector is longer than 32 bytes due to potential to
    /// truncate data unexpectedly
    public fun u256_from_bytes(bytes: &vector<u8>): u256 {
        let m: u256 = 0;

        // Cap length at 32 bytes
        let len = vector::length(bytes);
        assert!(len <= 32, ETruncatedBytes);

        let i = 0;
        while (i < len) {
            m = m << 8;
            let byte = *vector::borrow(bytes, i);
            m = m + (byte as u256);
            i = i + 1;
        };

        m
    }

    // === Select ===

    /// Selects a random 8 byte number within given bound using 32 byte random
    /// vector.
    ///
    /// #### Panics
    ///
    /// Panics if random vector is not 32 bytes long.
    public fun select_u64(bound: u64, random: &vector<u8>): u64 {
        assert!(vector::length(random) >= 32, ELowEntropy);
        let random = u256_from_bytes(random);

        let mod  = random % (bound as u256);
        (mod as u64)
    }
}
