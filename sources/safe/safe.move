// /// This module extends the functionality of the `UnprotectedSafe` with
// /// an additional feature of restricting deposits into it.
// module nft_protocol::safe {
//     use std::type_name::{Self, TypeName};

//     use sui::object::{Self, ID, UID};
//     use sui::vec_set::{Self, VecSet};
//     use sui::tx_context::{Self, TxContext};
//     use sui::transfer::{share_object, transfer};

//     use nft_protocol::err;
//     use nft_protocol::nft::Nft;
//     use nft_protocol::transfer_allowlist::Allowlist;
//     use nft_protocol::unprotected_safe::{Self, UnprotectedSafe};

//     struct Safe has key, store {
//         id: UID,
//         inner: UnprotectedSafe,
//         /// Enables depositing any collection, bypassing enabled deposits
//         enable_any_deposit: bool,
//         /// Collections which can be deposited into the `Safe`
//         collections_with_enabled_deposits: VecSet<TypeName>,
//     }

//     /// Whoever owns this object can perform some admin actions against the
//     /// `Safe` shared object with the corresponding id.
//     struct OwnerCap has key, store {
//         id: UID,
//         safe: ID,
//         inner: unprotected_safe::OwnerCap,
//     }

//     /// Enables the owner to transfer given NFT out of the `Safe`.
//     struct TransferCap has key, store {
//         id: UID,
//         safe: ID,
//         inner: unprotected_safe::TransferCap,
//     }

//     /// Creates a new safe.
//     ///
//     /// Enables all deposits by default.
//     public fun new(
//         ctx: &mut TxContext,
//     ): (Safe, OwnerCap) {
//         let (inner, cap) = unprotected_safe::new(ctx);
//         let safe = Safe {
//             id: object::new(ctx),
//             inner,
//             enable_any_deposit: true,
//             collections_with_enabled_deposits: vec_set::empty(),
//         };
//         let cap = OwnerCap {
//             id: object::new(ctx),
//             safe: object::id(&safe),
//             inner: cap,
//         };

//         (safe, cap)
//     }

//     /// Instantiates a new shared object `Safe` and transfer
//     /// `OwnerCap` to the tx sender.
//     ///
//     /// Enables all deposits by default.
//     public entry fun create_for_sender(
//         ctx: &mut TxContext,
//     ) {
//         let (safe, cap) = new(ctx);
//         share_object(safe);

//         transfer(cap, tx_context::sender(ctx));
//     }


//     /// Creates a new `Safe` shared object and returns the
//     /// authority capability that grants authority over this safe.
//     ///
//     /// Enables all deposits by default.
//     public fun create_safe(
//         ctx: &mut TxContext,
//     ): OwnerCap {
//         let (safe, cap) = new(ctx);
//         share_object(safe);

//         cap
//     }

//     /// Creates a `TransferCap` which must be claimed atomically.
//     ///
//     /// Otherwise, there's a risk of a race condition as multiple non-exclusive
//     /// transfer caps can be created.
//     public fun create_transfer_cap(
//         nft: ID,
//         owner_cap: &OwnerCap,
//         safe: &mut Safe,
//         ctx: &mut TxContext,
//     ): TransferCap {
//         TransferCap {
//             id: object::new(ctx),
//             safe: object::id(safe),
//             inner: unprotected_safe::create_transfer_cap(
//                 nft, &owner_cap.inner, &mut safe.inner, ctx
//             ),
//         }
//     }

//     public entry fun create_transfer_cap_for_sender(
//         nft: ID,
//         owner_cap: &OwnerCap,
//         safe: &mut Safe,
//         ctx: &mut TxContext,
//     ) {
//         let cap = create_transfer_cap(nft, owner_cap, safe, ctx);
//         transfer(cap, tx_context::sender(ctx));
//     }

//     /// Creates an irrevocable and exclusive transfer cap.
//     ///
//     /// Useful for trading contracts which cannot claim an NFT atomically.
//     public fun create_exclusive_transfer_cap(
//         nft: ID,
//         owner_cap: &OwnerCap,
//         safe: &mut Safe,
//         ctx: &mut TxContext,
//     ): TransferCap {
//         TransferCap {
//             id: object::new(ctx),
//             safe: object::id(safe),
//             inner: unprotected_safe::create_exclusive_transfer_cap(
//                 nft, &owner_cap.inner, &mut safe.inner, ctx
//             )
//         }
//     }

//     public entry fun create_exclusive_transfer_cap_for_sender(
//         nft: ID,
//         owner_cap: &OwnerCap,
//         safe: &mut Safe,
//         ctx: &mut TxContext,
//     ) {
//         let cap = create_exclusive_transfer_cap(nft, owner_cap, safe, ctx);
//         transfer(cap, tx_context::sender(ctx));
//     }

//     /// Only owner or allowlisted collections can deposit.
//     public entry fun restrict_deposits(
//         owner_cap: &OwnerCap,
//         safe: &mut Safe,
//     ) {
//         assert_owner_cap(owner_cap, safe);
//         safe.enable_any_deposit = false;
//     }

//     /// No restriction on deposits.
//     public entry fun enable_any_deposit(
//         owner_cap: &OwnerCap,
//         safe: &mut Safe,
//     ) {
//         assert_owner_cap(owner_cap, safe);
//         safe.enable_any_deposit = true;
//     }

//     /// The owner can restrict deposits into the `Safe` from given
//     /// collection.
//     ///
//     /// However, if the flag `Safe::enable_any_deposit` is set to
//     /// true, then it takes precedence.
//     public entry fun disable_deposits_of_collection<C>(
//         owner_cap: &OwnerCap,
//         safe: &mut Safe,
//     ) {
//         assert_owner_cap(owner_cap, safe);

//         let col_type = type_name::get<C>();
//         vec_set::remove(&mut safe.collections_with_enabled_deposits, &col_type);
//     }

//     /// The owner can enable deposits into the `Safe` from given
//     /// collection.
//     ///
//     /// However, if the flag `Safe::enable_any_deposit` is set to
//     /// true, then it takes precedence anyway.
//     public entry fun enable_deposits_of_collection<C>(
//         owner_cap: &OwnerCap,
//         safe: &mut Safe,
//     ) {
//         assert_owner_cap(owner_cap, safe);

//         let col_type = type_name::get<C>();
//         vec_set::insert(&mut safe.collections_with_enabled_deposits, col_type);
//     }

//     /// Transfer an NFT into the `Safe`.
//     ///
//     /// Requires that `enable_any_deposit` flag is set to true, or that the
//     /// `Safe` owner enabled NFTs of given collection to be inserted.
//     public entry fun deposit_nft<T>(
//         nft: Nft<T>,
//         safe: &mut Safe,
//         ctx: &mut TxContext,
//     ) {
//         assert_can_deposit<T>(safe);
//         unprotected_safe::deposit_nft(nft, &mut safe.inner, ctx);
//     }

//     /// Transfer an NFT into the `Safe`.
//     ///
//     /// The type T here can refer to any object, not just the NFT protocol's
//     /// exported NFT type.
//     public entry fun deposit_generic_nft<T: key + store>(
//         nft: T,
//         safe: &mut Safe,
//         ctx: &mut TxContext,
//     ) {
//         assert_can_deposit<T>(safe);
//         unprotected_safe::deposit_generic_nft(nft, &mut safe.inner, ctx);
//     }

//     /// Transfer an NFT from owner to the `Safe`.
//     public entry fun deposit_nft_privileged<T>(
//         nft: Nft<T>,
//         owner_cap: &OwnerCap,
//         safe: &mut Safe,
//         ctx: &mut TxContext,
//     ) {
//         assert_owner_cap(owner_cap, safe);
//         unprotected_safe::deposit_nft(nft, &mut safe.inner, ctx);
//     }

//     public entry fun deposit_generic_nft_privileged<T: key + store>(
//         nft: T,
//         owner_cap: &OwnerCap,
//         safe: &mut Safe,
//         ctx: &mut TxContext,
//     ) {
//         assert_owner_cap(owner_cap, safe);
//         unprotected_safe::deposit_generic_nft(nft, &mut safe.inner, ctx);
//     }

//     /// Use a transfer cap to get an NFT out of the `Safe`.
//     ///
//     /// If the NFT is not exclusively listed, it can happen that the transfer
//     /// cap is no longer valid. The NFT could've been traded or the trading cap
//     /// revoked.
//     public fun transfer_nft_to_recipient<T, Auth: drop>(
//         transfer_cap: TransferCap,
//         recipient: address,
//         authority: Auth,
//         allowlist: &Allowlist,
//         safe: &mut Safe,
//     ) {
//         let TransferCap {
//             id, inner, safe: _,
//         } = transfer_cap;
//         object::delete(id);

//         unprotected_safe::transfer_nft_to_recipient<T, Auth>(
//             inner,
//             recipient,
//             authority,
//             allowlist,
//             &mut safe.inner
//         )
//     }

//     public fun transfer_generic_nft_to_recipient<T: key + store>(
//         transfer_cap: TransferCap,
//         recipient: address,
//         safe: &mut Safe,
//     ) {
//         let TransferCap {
//             id, inner, safe: _,
//         } = transfer_cap;
//         object::delete(id);

//         unprotected_safe::transfer_generic_nft_to_recipient<T>(
//             inner,
//             recipient,
//             &mut safe.inner
//         )
//     }

//     /// Use a transfer cap to get an NFT out of source `Safe` and
//     /// deposit it to the target `Safe`. The recipient address should match the
//     /// owner of the target `Safe`.
//     ///
//     /// If the NFT is not exclusively listed, it can happen that the transfer
//     /// cap is no longer valid. The NFT could've been traded or the trading cap
//     /// revoked.
//     public fun transfer_nft_to_safe<T, Auth: drop>(
//         transfer_cap: TransferCap,
//         recipient: address,
//         authority: Auth,
//         allowlist: &Allowlist,
//         source: &mut Safe,
//         target: &mut Safe,
//         ctx: &mut TxContext,
//     ) {
//         let TransferCap {
//             id, inner, safe: _,
//         } = transfer_cap;
//         object::delete(id);

//         unprotected_safe::transfer_nft_to_safe<T, Auth>(
//             inner,
//             recipient,
//             authority,
//             allowlist,
//             &mut source.inner,
//             &mut target.inner,
//             ctx,
//         )
//     }

//     public fun transfer_generic_nft_to_safe<T: key + store>(
//         transfer_cap: TransferCap,
//         source: &mut Safe,
//         target: &mut Safe,
//         ctx: &mut TxContext,
//     ) {
//         let TransferCap {
//             id, inner, safe: _,
//         } = transfer_cap;
//         object::delete(id);

//         unprotected_safe::transfer_generic_nft_to_safe<T>(
//             inner,
//             &mut source.inner,
//             &mut target.inner,
//             ctx,
//         )
//     }

//     /// Destroys given transfer cap. This is mainly useful for exclusively listed
//     /// NFTs.
//     public entry fun burn_transfer_cap(
//         transfer_cap: TransferCap,
//         safe: &mut Safe,
//     ) {
//         let TransferCap {
//             id, inner, safe: _,
//         } = transfer_cap;
//         object::delete(id);

//         unprotected_safe::burn_transfer_cap(inner, &mut safe.inner)
//     }

//     /// Changes the transfer ref version, thereby invalidating all existing
//     /// `TransferCap` objects.
//     ///
//     /// Can happen only if the NFT is not listed exclusively.
//     public entry fun delist_nft(
//         nft: ID,
//         owner_cap: &OwnerCap,
//         safe: &mut Safe,
//         ctx: &mut TxContext,
//     ) {
//         unprotected_safe::delist_nft(nft, &owner_cap.inner, &mut safe.inner, ctx)
//     }

//     // === Getters ===

//     public fun inner(safe: &Safe): &UnprotectedSafe {
//         &safe.inner
//     }

//     public fun borrow_nft<C>(nft: ID, safe: &Safe): &Nft<C> {
//         unprotected_safe::borrow_nft<C>(nft, &safe.inner)
//     }

//     public fun has_nft<C>(nft: ID, safe: &Safe): bool {
//         unprotected_safe::has_nft<C>(nft, &safe.inner)
//     }

//     public fun borrow_generic_nft<C: key + store>(nft: ID, safe: &Safe): &C {
//         unprotected_safe::borrow_generic_nft<C>(nft, &safe.inner)
//     }

//     public fun has_generic_nft<T: key + store>(nft: ID, safe: &Safe): bool {
//         unprotected_safe::has_generic_nft<T>(nft, &safe.inner)
//     }

//     public fun owner_cap_safe(cap: &OwnerCap): ID {
//         cap.safe
//     }

//     public fun transfer_cap_safe(cap: &TransferCap): ID {
//         cap.safe
//     }

//     public fun transfer_cap_nft(cap: &TransferCap): ID {
//         unprotected_safe::transfer_cap_nft(&cap.inner)
//     }

//     public fun transfer_cap_version(cap: &TransferCap): ID {
//         unprotected_safe::transfer_cap_version(&cap.inner)
//     }

//     public fun transfer_cap_is_exclusive(cap: &TransferCap): bool {
//         unprotected_safe::transfer_cap_is_exclusive(&cap.inner)
//     }

//     public fun transfer_cap_is_nft_generic(cap: &TransferCap): bool {
//         unprotected_safe::transfer_cap_is_nft_generic(&cap.inner)
//     }

//     public fun transfer_cap_object_type(cap: &TransferCap): TypeName {
//         unprotected_safe::transfer_cap_object_type(&cap.inner)
//     }

//     public fun are_all_deposits_enabled(safe: &Safe): bool {
//         safe.enable_any_deposit
//     }

//     // === Assertions ===

//     public fun assert_owner_cap(cap: &OwnerCap, safe: &Safe) {
//         unprotected_safe::assert_owner_cap(&cap.inner, &safe.inner)
//     }

//     public fun assert_transfer_cap_of_safe(cap: &TransferCap, safe: &Safe) {
//         unprotected_safe::assert_transfer_cap_of_safe(&cap.inner, &safe.inner)
//     }

//     public fun assert_nft_of_transfer_cap(nft: &ID, cap: &TransferCap) {
//         unprotected_safe::assert_nft_of_transfer_cap(nft, &cap.inner)
//     }

//     public fun assert_has_nft(nft: &ID, safe: &Safe) {
//         unprotected_safe::assert_has_nft(nft, &safe.inner)
//     }

//     public fun assert_not_exclusively_listed(cap: &TransferCap) {
//         unprotected_safe::assert_not_exclusively_listed(&cap.inner)
//     }

//     public fun assert_transfer_cap_exclusive(cap: &TransferCap) {
//         unprotected_safe::assert_transfer_cap_exclusive(&cap.inner)
//     }

//     public fun assert_transfer_cap_of_native_nft(cap: &TransferCap) {
//         unprotected_safe::assert_transfer_cap_of_native_nft(&cap.inner)
//     }

//     /// Checks that the transfer cap is issued for an NFT of type `Nft<C>`
//     public fun assert_nft_type<C>(cap: &TransferCap) {
//         unprotected_safe::assert_nft_type<C>(&cap.inner)
//     }

//     /// Checks that the transfer cap is issued for an NFT of type `C`
//     public fun assert_generic_nft_type<C>(cap: &TransferCap) {
//         unprotected_safe::assert_generic_nft_type<C>(&cap.inner)
//     }

//     public fun assert_can_deposit<T>(safe: &Safe) {
//         if (!safe.enable_any_deposit) {
//             assert!(
//                 vec_set::contains(
//                     &safe.collections_with_enabled_deposits,
//                     &type_name::get<T>(),
//                 ),
//                 err::safe_does_not_accept_deposits(),
//             );
//         }
//     }

//     public fun assert_id(safe: &Safe, id: ID) {
//         assert!(object::id(safe) == id, err::safe_id_mismatch());
//     }
// }
