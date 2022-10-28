//! Defines a `Safe` for storing `NFT`s
//! 
//! Enforces transferability rules by ensuring that conditions for withdrawing
//! from a `Safe<L>` are met by declaring a "transferability witness" `L`.
//! 
//! Ensures that `NFTs` can only be transferred between `Safes` by using an
//! enforced `Disposition` token. This ensures that our transferability witness
//! can verify whether the destination `Safe` will also enforce transferability
//! rules.

module nft_protocol::safe {
    use sui::object::{Self, UID, ID};
    use sui::object_bag::{Self, ObjectBag};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::err;

    /// `ED` and `EW` enforces transferability rules on deposit and withdrawal
    struct Safe<phantom ED, phantom EW> has key, store {
        id: UID,
        owner: address,
        // Stores <ID, NFT<T, D:store>>
        table: ObjectBag,
    }

    /// Signal that a `Safe` is expecting an `NFT` to be deposited to it during
    /// the current transaction.
    struct Disposition {
        safe_id: ID,
    }

    /// Gives the holder permission to transfer the nft with id `nft_id` out of
    /// the safe with id `safe_id`
    struct TransferCap has key, store {
        id: UID,
        // TODO: Can we safety store owner here?
        owner: address,
        safe_id: ID,
        nft_id: ID,
    }

    /// Proof of ownership of a `Safe` and in extension all of it's `NFTs`
    /// 
    /// Could be constructed from `TransferCap` or `Safe`
    struct Ownership has key, store {
        id: UID,
        safe_id: ID,
    }

    public fun new<ED, EW>(
        ctx: &mut TxContext,
    ): Safe<ED, EW> {
        Safe {
            id: object::new(ctx),
            owner: tx_context::sender(ctx),
            table: object_bag::new(ctx),
        }
    }

    public fun deposit<ED, EW, T, D: store>(
        safe: &mut Safe<ED, EW>,
        // Ensures that transfer occurs under the transferability rules
        // required by the origin `Safe`.
        //
        // The transaction will be responsible for dropping the witness
        // therefore fulfulling any conditions necessary for a drop, like
        // royalty payments.
        _transferability_witness: &ED,
        nft: Nft<T, D>,
    ) {
        let id = nft::id(&nft);
        assert!(!object_bag::contains(&safe.table, id), err::nft_already_exists());

        object_bag::add(&mut safe.table, id, nft);
    }

    // Use when we need to prove that an `NFT` has been deposited to another
    // `Safe` by consuming `Disposition`
    public fun deposit_with_disposition<ED, EW, T, D: store>(
        safe: &mut Safe<ED, EW>,
        // See [`safe::deposit`]
        _transferability_witness: &ED,
        nft: Nft<T, D>,
        // Drops `Disposition` therefore ensuring that the `NFT` was deposited.
        disposition: Disposition,
    ) {
        let Disposition { safe_id } = disposition;

        assert!(safe_id == object::uid_to_inner(&safe.id), err::incorrect_safe_disposition());

        let id = nft::id(&nft);
        assert!(!object_bag::contains(&safe.table, id), err::nft_already_exists());

        object_bag::add(&mut safe.table, id, nft);
    }

    // Signal to the `Safe` that we intend to deposit an `NFT` and require 
    // proof of deposit
    public fun disposition<ED, EW>(
        safe: &mut Safe<ED, EW>
    ): Disposition {
        Disposition {
            safe_id: object::uid_to_inner(&safe.id)
        }
    }

    public fun withdraw<ED, EW, T, D: store>(
        safe: &mut Safe<ED, EW>,
        // See [`safe::deposit`]
        _transferability_witness: &EW,
        // Since an `NFT` can never leave a `Safe` once it has been
        // deposited then a disposition must be generated and then consumed
        // by the destination `Safe`.
        //
        // See [`safe::deposit_with_disposition`]
        _disposition: &Disposition,
        nft_id: ID,
        ctx: &mut TxContext,
    ): Nft<T, D> {
        assert!(tx_context::sender(ctx) == safe.owner, err::not_owner_of_safe());
        assert!(object_bag::contains(&safe.table, nft_id), err::nft_doesnt_exist());
        
        object_bag::remove(&mut safe.table, nft_id)
    }

    public fun delegated_withdraw<ED, EW, T, D: store>(
        safe: &mut Safe<ED, EW>,
        // See [`safe::deposit`]
        _transferability_witness: &EW,
        // See [`safe::withdraw`]
        _disposition: &Disposition,
        transfer_cap: TransferCap,
    ): Nft<T, D> {
        let TransferCap { id, owner, safe_id, nft_id } = transfer_cap;

        assert!(owner == safe.owner, err::not_owner_of_safe());
        assert!(safe_id == object::uid_to_inner(&safe.id), err::incorrect_safe_disposition());
        
        object::delete(id);
        object_bag::remove(&mut safe.table, nft_id)
    }

    /// Delegation for withdrawal can be made at any point as verification
    /// will be performed during 
    public fun delegate_withdraw<ED, EW>(
        safe: &mut Safe<ED, EW>,
        nft_id: ID,
        ctx: &mut TxContext,
    ): TransferCap {
        assert!(tx_context::sender(ctx) == safe.owner, err::not_owner_of_safe());

        TransferCap {
            id: object::new(ctx),
            owner: safe.owner,
            safe_id: object::uid_to_inner(&safe.id),
            nft_id,
        }
    }

    // === Getter Functions  ===

    public fun borrow<ED, EW, T, D: store>(
        safe: &Safe<ED, EW>,
        nft_id: ID
    ): &Nft<T, D> {
        assert!(object_bag::contains(&safe.table, nft_id), err::nft_doesnt_exist());
        object_bag::borrow(&safe.table, nft_id)
    }

    // === Yeet Functions ==

    public fun destroy<ED, EW> (safe: Safe<ED, EW>) {
        let Safe { id, owner: _, table } = safe;

        object::delete(id);
        object_bag::destroy_empty(table);
    }
}