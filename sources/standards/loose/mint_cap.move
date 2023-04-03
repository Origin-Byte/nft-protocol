// module nft_protocol::loose_mint_cap {
//     use std::string::String;

//     use sui::url::Url;
//     use sui::transfer;
//     use sui::object::{Self, ID, UID};
//     use sui::tx_context::{Self, TxContext};

//     use nft_protocol::nft::{Self, Nft};
//     use nft_protocol::mint_cap::MintCap;

//     friend nft_protocol::metadata;

//     /// Attempted to redeem an object from `Factory<C>` that wasnt `Nft<C>`
//     ///
//     /// `LooseMintCap<C>` is only capable of minting `Nft<C>` but erases the
//     /// type to `T` in order to be compatible with `Inventory`.
//     const ENFT_TYPE_MISMATCH: u64 = 1;

//     // === PointerDomain ===

//     struct PointerDomain has store {
//         /// `Metadata` ID that this NFT is a loose representation of
//         metadata_id: ID,
//     }

//     /// Return `ID` of `Metadata` associated with this pointer
//     public fun metadata_id(pointer: &PointerDomain): ID {
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
//         /// `Nft` name
//         name: String,
//         /// `Nft` URL
//         url: Url,
//         /// `Metadata` ID for which this `LooseMintCap` is allowed to mint
//         /// NFTs
//         metadata_id: ID,
//         /// Inner `MintCap`
//         mint_cap: MintCap<T>,
//     }

//     public(friend) fun new<T>(
//         mint_cap: MintCap<T>,
//         metadata_id: ID,
//         name: String,
//         url: Url,
//         ctx: &mut TxContext,
//     ): LooseMintCap<T> {
//         LooseMintCap {
//             id: object::new(ctx),
//             name,
//             url,
//             metadata_id,
//             mint_cap,
//         }
//     }

//     // === Getters ===

//     /// Get loose `Nft` name
//     public fun name<T>(mint_cap: &LooseMintCap<T>): &String {
//         &mint_cap.name
//     }

//     /// Get loose `Nft` URL
//     public fun url<T>(mint_cap: &LooseMintCap<T>): &Url {
//         &mint_cap.url
//     }

//     /// Mints `Nft` from `LooseMintCap`
//     ///
//     /// #### Panics
//     ///
//     /// Panics if supply was exceeded.
//     public fun mint_nft<C>(
//         loose_mint_cap: &mut LooseMintCap<Nft<C>>,
//         ctx: &mut TxContext,
//     ): Nft<C> {
//         let pointer =
//             PointerDomain { metadata_id: loose_mint_cap.metadata_id };

//         let name = *name(loose_mint_cap);
//         let url = *url(loose_mint_cap);

//         let nft: Nft<C> = nft::from_mint_cap(
//             &mut loose_mint_cap.mint_cap, name, url, ctx,
//         );

//         nft::add_domain_with_mint_cap(
//             &loose_mint_cap.mint_cap, &mut nft, pointer,
//         );

//         nft
//     }

//     /// Mints `Nft` from `LooseMintCap` and transfer
//     ///
//     /// #### Panics
//     ///
//     /// Panics if supply was exceeded
//     public fun mint_nft_and_transfer<C>(
//         mint_cap: &mut LooseMintCap<Nft<C>>,
//         ctx: &mut TxContext,
//     ) {
//         let nft = mint_nft(mint_cap, ctx);
//         transfer::public_transfer(nft, tx_context::sender(ctx))
//     }
// }
