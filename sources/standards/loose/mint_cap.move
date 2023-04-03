// module nft_protocol::loose_mint_cap {
//     use sui::transfer;
//     use sui::object::{Self, ID, UID};
//     use sui::tx_context::{Self, TxContext};

//     use nft_protocol::mint_cap::MintCap;

//     friend nft_protocol::metadata;

//     /// Attempted to redeem an object from `Factory<C>` that wasnt `Nft<C>`
//     ///
//     /// `LooseMintCap<C>` is only capable of minting `Nft<C>` but erases the
//     /// type to `T` in order to be compatible with `Inventory`.
//     const ENFT_TYPE_MISMATCH: u64 = 1;

//     // === PointerDomain ===

//     struct Pointer<phantom T> has key, store {
//         /// `Pointer` ID
//         id: UID,
//         /// `Metadata` ID that this NFT is a loose representation of
//         metadata_id: ID,
//     }

//     /// Return `ID` of `Metadata` associated with this pointer
//     public fun metadata_id<T>(pointer: &Pointer<T>): ID {
//         pointer.metadata_id
//     }

//     // === LooseMintCap ===

//     /// `LooseMintCap` object
//     ///
//     /// `LooseMintCap` ensures that supply policy on `Collection` and
//     /// `Metadata` are not violated.
//     struct LooseMintCap<phantom T> has key, store {
//         /// `LooseMintCap` ID
//         id: UID,
//         /// `Metadata` ID for which this `LooseMintCap` is allowed to mint
//         /// NFTs
//         metadata_id: ID,
//         /// Inner `MintCap`
//         mint_cap: MintCap<T>,
//     }

//     public(friend) fun new<T>(
//         mint_cap: MintCap<T>,
//         metadata_id: ID,
//         ctx: &mut TxContext,
//     ): LooseMintCap<T> {
//         LooseMintCap {
//             id: object::new(ctx),
//             metadata_id,
//             mint_cap,
//         }
//     }

//     /// Mints `Nft` from `LooseMintCap`
//     ///
//     /// #### Panics
//     ///
//     /// Panics if supply was exceeded.
//     public fun mint_pointer<T>(
//         loose_mint_cap: &mut LooseMintCap<T>,
//         ctx: &mut TxContext,
//     ): Pointer<T> {
//         Pointer {
//             id: object::new(ctx),
//             metadata_id: loose_mint_cap.metadata_id,
//         }
//     }

//     /// Mints `Nft` from `LooseMintCap` and transfer
//     ///
//     /// #### Panics
//     ///
//     /// Panics if supply was exceeded
//     public fun mint_pointer_and_transfer<T>(
//         mint_cap: &mut LooseMintCap<T>,
//         ctx: &mut TxContext,
//     ) {
//         let nft = mint_pointer(mint_cap, ctx);
//         transfer::public_transfer(nft, tx_context::sender(ctx))
//     }
// }
