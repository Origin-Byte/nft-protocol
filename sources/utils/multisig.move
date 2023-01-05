/// A multisig is a mechanism to allow multiple signers to sign off on some
/// action.
module nft_protocol::multisig {
    use std::vector;
    use std::option::{Self, Option};

    use sui::vec_map::{Self, VecMap};
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::creators;
    use nft_protocol::collection::Collection;

    struct Multisig<T> has key, store {
        id: UID,
        /// Version of collection's creators domain at the time of creation
        /// of the multisig.
        /// Important to avoid machinations where a signer is removed in favour
        /// of a new signer.
        creators_version: u64,
        /// Signer's address as the key, their BPS share as the int
        remaining_signers: VecMap<address, u16>,
        /// initial # of signers = len(remaining_signers) + signature_count
        signature_count: u64,
        /// Sum of BPS shares of those who have signed
        signers_bps_share: u16,
        /// Whether this multisig has been used already
        used: bool,
        /// Optional data which can define e.g. expected args to a functions
        inner: Option<T>,
    }

    /// Creates a new multisig with the given inner data.
    ///
    /// If the creators domain of the collection has changed after this
    /// point, the multisig becomes invalid.
    public fun new<C, T: store>(
        inner: T,
        collection: &Collection<C>,
        ctx: &mut TxContext,
    ): Multisig<T> {
        let attr = creators::creators_domain(collection);
        let creators = *creators::creators(attr);

        let creators_len = vec_map::size(&creators);
        assert!(creators_len > 0, 0); // TODO

        let i = 0;
        let signers = vec_map::empty();
        let (creator_addresses, creators) = vec_map::into_keys_values(creators);
        while (i < creators_len) {
            let addr = vector::pop_back(&mut creator_addresses);
            let creator = vector::pop_back(&mut creators);
            vec_map::insert(
                &mut signers,
                addr,
                creators::share_of_royalty_bps(&creator),
            );
            i = i + 1;
        };

        Multisig {
            id: object::new(ctx),
            inner: option::some(inner),
            used: false,
            signature_count: 0,
            remaining_signers: signers,
            signers_bps_share: 0,
            creators_version: creators::version(attr),
        }
    }

    /// Adds a signature to the multisig.
    public entry fun sign<T: store>(
        multisig: &mut Multisig<T>,
        ctx: &mut TxContext,
    ) {
        assert!(!multisig.used, 0); // TODO

        let sender = tx_context::sender(ctx);

        let (_, signer_share) =
            vec_map::remove(&mut multisig.remaining_signers, &sender);

        multisig.signature_count = multisig.signature_count + 1;
        multisig.signers_bps_share = multisig.signers_bps_share + signer_share;
    }

    public fun consume_with_min_sig_count<T, C>(
        min_signature_count: u64,
        collection: &Collection<C>,
        multisig: &mut Multisig<T>,
        ctx: &mut TxContext,
    ): Option<T> {
        consume(
            min_signature_count,
            0,
            collection,
            multisig,
            ctx,
        )
    }

    public fun consume_with_min_bps_share<T, C>(
        min_signers_bps_share: u16,
        collection: &Collection<C>,
        multisig: &mut Multisig<T>,
        ctx: &mut TxContext,
    ): Option<T> {
        consume(
            0,
            min_signers_bps_share,
            collection,
            multisig,
            ctx,
        )
    }

    /// Checks that the multisig has been signed by at least
    /// `min_signature_count` AND those signers have at least
    /// `min_signers_bps_share` of the total BPS share.
    ///
    /// The invocation will also fail if
    /// - signer is not in the creators domain of the collection;
    /// - multisig has been used already;
    /// - the creators domain has been mutated since the creation of the
    ///     multisig.
    public fun consume<T, C>(
        min_signature_count: u64,
        min_signers_bps_share: u16,
        collection: &Collection<C>,
        multisig: &mut Multisig<T>,
        ctx: &mut TxContext,
    ): Option<T> {
        assert!(!multisig.used, 0); // TODO
        assert!(multisig.signature_count >= min_signature_count, 0);  // TODO
        assert!(multisig.signers_bps_share >= min_signers_bps_share, 0); // TODO

        let attr = creators::creators_domain(collection);
        assert!(multisig.creators_version == creators::version(attr), 0); // TODO

        creators::assert_collection_has_creator(
            collection, tx_context::sender(ctx)
        );

        multisig.used = true;

        if (option::is_some(&multisig.inner)) {
            option::some(option::extract(&mut multisig.inner))
        } else {
            option::none()
        }
    }
}
