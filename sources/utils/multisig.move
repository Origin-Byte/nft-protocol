/// A multisig is a mechanism to allow multiple signers to agree on some
/// action.
///
/// This module exports a generic multisig which can be used for any action.
/// Define an action with the `A`ction generic.
/// Then, use the `&mut Multisig<A>` as a parameter to an endpoint you want to
/// protect with a multisig.
/// In this endpoint, consume the multisig with `consume`.
/// Calling `consume` will fail if the multisig has not been signed by enough
/// signers.
/// What's "enough" is defined by the caller of `consume` (ie. determined at the
/// time of writing the action.)
module nft_protocol::multisig {
    use std::option::{Self, Option};
    use std::vector;

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map::{Self, VecMap};
    use sui::vec_set;

    use nft_protocol::collection::Collection;
    use nft_protocol::creators;
    use nft_protocol::err;

    struct Multisig<A> has key, store {
        id: UID,
        /// Signer's address as the key, their weight as the int.
        ///
        /// Signing the multisig removes the signer from this map.
        remaining_signers: VecMap<address, u16>,
        /// initial # of signers = len(remaining_signers) + signature_count
        signature_count: u64,
        /// Sum of weights of those who have signed
        signed_signers_weight_share: u16,
        /// Data which can define what action does this multisig apply to, or
        /// e.g. expected args, function etc
        ///
        /// It's an option because we need to extract the data and cannot
        /// drop a shared object.
        ///
        /// # Important
        /// If the action is `None`, then this multisig has already been used.
        action: Option<A>,
    }

    /// Given a map of signers to their weight, creates a new multisig.
    ///
    /// The threshold weight or signature count is not specified here, but in
    /// the function which consumes the multisig.
    public fun new<A: store>(
        action: A,
        signers: VecMap<address, u16>,
        ctx: &mut TxContext,
    ): Multisig<A> {
        assert!(
            vec_map::size(&signers) > 0,
            err::multisig_signers_must_not_be_empty(),
        );

        Multisig {
            id: object::new(ctx),
            signature_count: 0,
            remaining_signers: signers,
            signed_signers_weight_share: 0,
            action: option::some(action),
        }
    }


    /// Checks that the multisig has been signed by at least
    /// `min_signature_count` AND those signers have at least
    /// `min_signed_signers_weight_share` of the total weight share.
    ///
    /// The invocation will also fail if multisig has been used already.
    public fun consume<A>(
        min_signature_count: u64,
        min_signed_signers_weight_share: u16,
        multisig: &mut Multisig<A>,
    ): A {
        assert!(option::is_some(&multisig.action), err::multisig_already_used());
        assert!(
            multisig.signature_count >= min_signature_count,
            err::multisig_not_enough_signatures(),
        );
        assert!(
            multisig.signed_signers_weight_share
                >= min_signed_signers_weight_share,
            err::multisig_not_enough_signers_weight(),
        );

        option::extract(&mut multisig.action)
    }

    /// Adds a signature to the multisig.
    public entry fun sign<A: store>(
        multisig: &mut Multisig<A>,
        ctx: &mut TxContext,
    ) {
        assert!(option::is_some(&multisig.action), err::multisig_already_used());

        let sender = tx_context::sender(ctx);

        let (_, signer_share) =
            vec_map::remove(&mut multisig.remaining_signers, &sender);

        multisig.signature_count = multisig.signature_count + 1;
        multisig.signed_signers_weight_share =
            multisig.signed_signers_weight_share + signer_share;
    }

    // === Integration with creators domain ===

    /// A helper struct which enables conveniently creating a multisig that
    /// needs to be signed by the creators of a collection.
    struct FromCreatorsDomain<A> has store {
        action: A,
    }


    /// Creates a new multisig from the creators domain.
    /// The weight of each creator is equal.
    ///
    /// If the creators domain of the collection has changed after this
    /// point, the multisig becomes invalid.
    public fun from_creators_domain<C, A: store>(
        action: A,
        collection: &Collection<C>,
        ctx: &mut TxContext,
    ): Multisig<FromCreatorsDomain<A>> {
        let attr = creators::creators_domain(collection);
        let creators = creators::borrow_creators(attr);

        let creators_len = vec_set::size(creators);
        assert!(creators_len > 0, err::multisig_signers_must_not_be_empty());

        let i = 0;
        let signers = vec_map::empty();
        let creator_addresses = vec_set::into_keys(*creators);
        while (i < creators_len) {
            let addr = vector::pop_back(&mut creator_addresses);
            vec_map::insert(&mut signers, addr, 1);
            i = i + 1;
        };

        new(
            FromCreatorsDomain { action },
            signers,
            ctx,
        )
    }

    /// Checks that the multisig has been signed by at least
    /// `min_signature_count`.
    ///
    /// #### Fails
    /// - multisig has been used already;
    /// - the creators domain has been mutated since the creation of the
    ///     multisig.
    public fun consume_from_creators_domain<A, C>(
        min_signature_count: u64,
        multisig: &mut Multisig<FromCreatorsDomain<A>>,
    ): A {
        let FromCreatorsDomain {
            action,
        } = consume(
            min_signature_count,
            0,
            multisig,
        );

        action
    }
}
