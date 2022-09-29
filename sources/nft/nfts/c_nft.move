// // TODO: Mint to launchpad functions
// // TODO: Push Nfts to c_NFT
// module nft_protocol::c_nft {
//     use sui::event;
//     use sui::object::{Self, UID, ID};
//     use std::string::{String};
//     use std::option::{Self, Option};
//     use std::vector;
    
//     use sui::transfer;
//     use sui::tx_context::{TxContext};
//     use sui::url::{Url};
    
//     use nft_protocol::collection::{Self, Collection};
//     use nft_protocol::supply::{Self, Supply};
//     use nft_protocol::nft::{Self, Nft};
//     use nft_protocol::cap::{Limited, Unlimited};

//     struct Data has key, store {
//         id: UID,
//         index: u64,
//         name: String,
//         description: String,
//         collection_id: ID,
//         url: Url,
//         attributes: Attributes,
//         supply: Supply,
//     }

//     struct ComboData<Data> has key, store {
//         id: UID,
//         collection_id: ID,
//         data: vector<Data>,
//     }

//     struct CombinableData has store {
//         data_id: ID,
//         index: u64,
//         name: String,
//         description: String,
//         collection_id: ID,
//         url: Url,
//         attributes: Attributes,
//     }

//     struct Attributes has store, drop, copy {
//         keys: vector<String>,
//         values: vector<String>,
//     }

//     struct MintArgs has drop {
//         index: u64,
//         name: String,
//         description: String,
//         url: Url,
//         attributes: Attributes,
//         max_supply: Option<u64>,
//     }

//     struct MintDataEvent has copy, drop {
//         object_id: ID,
//         collection_id: ID,
//     }

//     struct BurnDataEvent has copy, drop {
//         object_id: ID,
//         collection_id: ID,
//     }

//     struct MintComboDataEvent has copy, drop {
//         data_ids: vector<ID>,
//         collection_id: ID,
//     }

//     // TODO: Must use this event
//     struct BurnComboDataEvent has copy, drop {
//         object_id: ID,
//         collection_id: ID,
//     }

//     // === Entrypoints ===

//     public entry fun mint_unlimited_collection_nft_data<MetaColl: store>(
//         index: u64,
//         name: String,
//         description: String,
//         url: Url,
//         attribute_keys: vector<String>,
//         attribute_values: vector<String>,
//         collection: &Collection<MetaColl, Unlimited>,
//         recipient: address,
//         ctx: &mut TxContext,
//     ) {
//         let args = mint_args(
//             index,
//             name,
//             description,
//             url,
//             attribute_keys,
//             attribute_values,
//             option::none(),
//         );

//         mint_and_share_data(
//             args,
//             collection::id(collection),
//             recipient,
//             ctx,
//         );
//     }

//     /// Mint one `Nft` with `Data` and send it to `recipient`.
//     /// Invokes `mint_and_transfer()`.
//     /// Mints an NFT from a `Collection` with `Limited` supply.
//     /// The only way to mint the NFT for a collection is to give a reference to
//     /// [`UID`]. Since this a property, it can be only accessed in the smart 
//     /// contract which creates the collection. That contract can then define
//     /// their own logic for restriction on minting.
//     public entry fun mint_limited_collection_nft_data<MetaColl: store>(
//         index: u64,
//         name: String,
//         description: String,
//         url: Url,
//         attribute_keys: vector<String>,
//         attribute_values: vector<String>,
//         max_supply: Option<u64>,
//         recipient: address,
//         collection: &mut Collection<MetaColl, Limited>,
//         ctx: &mut TxContext,
//     ) {
//         let args = mint_args(
//             index,
//             name,
//             description,
//             url,
//             attribute_keys,
//             attribute_values,
//             max_supply,
//         );

//         collection::increase_supply(collection, 1);

//         mint_and_share_data(
//             args,
//             collection::id(collection),
//             recipient,
//             ctx,
//         );
//     }

//     public entry fun init_combo_data<MetaColl: store, Cap: store>(
//         nfts_data: vector<Data>,
//         collection: &mut Collection<MetaColl, Cap>,
//         ctx: &mut TxContext,
//     ): ComboData<CombinableData> {
//         let data_vec: vector<CombinableData> = vector::empty();
//         let data_ids: vector<ID> = vector::empty();
//         let collection_id = collection::id(collection);

//         let len = vector::length(&nfts_data);

//         while (len > 0) {
//             let nft_data = vector::pop_back(&mut nfts_data);

//             assert!(nft_data.collection_id == collection_id, 0);

//             let data_id = nft_data_id(&nft_data);
            
//             let data = CombinableData {
//                 data_id: nft_data_id(&nft_data),
//                 index: nft_data.index,
//                 name: nft_data.name,
//                 description: nft_data.description,
//                 collection_id: nft_data.collection_id,
//                 url: nft_data.url,
//                 attributes: nft_data.attributes,
//             };

//             vector::push_back(&mut data_ids, data_id);
//             vector::push_back(&mut data_vec, data);
            
//             len = len - 1;
//         };

//         event::emit(
//             MintComboDataEvent {
//                 data_ids: data_ids,
//                 collection_id: collection_id,
//             }
//         );

//         let id = object::new(ctx);

//         ComboData {
//             id: id,
//             collection_id: collection_id,
//             data: data_vec,
//         }
//     }

//     public entry fun combine_combo_data<MetaColl: store, Cap: store, CData: store>(
//         nft_combos_data: vector<ComboData<CData>>,
//         collection: &mut Collection<MetaColl, Cap>,
//         ctx: &mut TxContext,
//     ): ComboData<ComboData<CData>> {
//         let collection_id = collection::id(collection);
//         let data_ids: vector<ID> = vector::empty();
//         let data: vector<ComboData<CData>> = vector::empty();

//         let len = vector::length(&nft_combos_data);

//         while (len > 0) {
//             let combo_data = vector::pop_back(&mut nft_combos_data);
            
//             assert!(combo_data.collection_id == collection_id, 0);

//             let data_id = c_nft_data_id(&combo_data);

//             vector::push_back(&mut data, combo_data);
//             vector::push_back(&mut data_ids, data_id);
            
//             len = len - 1;
//         };

//         event::emit(
//             MintComboDataEvent {
//                 data_ids: data_ids,
//                 collection_id: collection_id,
//             }
//         );

//         let id = object::new(ctx);

//         ComboData {
//             id: id,
//             collection_id: collection_id,
//             data: data,
//         }
//     }

//     // Burn two NFT pointers
//     // Loose allows for the creation of many NFTs out of the metadata
//     public entry fun mint_combo_nft_loose<CData: store>(
//         nfts: vector<Nft<Data>>,
//         nfts_data: vector<Data>, // TODO: Ideally we would pass &Data
//         combo_data: &ComboData<CData>,
//         recipient: address,
//         ctx: &mut TxContext,
//     ) {
//         // TODO: Check that only loose NFTs can be combined
//         // this is checked when burning nft loose function is called
//         let len = vector::length(&nfts);

//         while (len > 0) {
//             let nft = vector::pop_back(&mut nfts);
//             let data = vector::pop_back(&mut nfts_data);
//             assert!(nft::data_id(&nft) == id(&data), 0);

//             nft::burn_loose_nft(nft);
//             // TODO: This is really not ideal - ideally we would use a reference
//             // to the object
//             transfer::share_object(data);
            
//             len = len - 1;
//         };
//         vector::destroy_empty(nfts);
//         vector::destroy_empty(nfts_data);

//         // TODO: Need to assert that the combo data object is the right object
//         let nft = nft::mint_nft_loose<Data>(
//             object::uid_to_inner(&combo_data.id),
//             ctx,
//         );

//         transfer::transfer(
//             nft,
//             recipient,
//         );
//     }

//     // Burn two NFT pointers
//     // Loose allows for the creation of many NFTs out of the metadata
//     public entry fun mint_combo_nft_embedded<CData: store>(
//         nfts: vector<Nft<Data>>,
//         combo_data: &ComboData<CData>,
//         recipient: address,
//         ctx: &mut TxContext,
//     ) {
//         // TODO: Check that only loose NFTs can be combined
//         // this is checked when burning nft loose function is called
//         let len = vector::length(&nfts);

//         while (len > 0) {
//             let nft = vector::pop_back(&mut nfts);

//             let data = option::extract(&mut nft::burn_embedded_nft(nft));

//             transfer::share_object(data);
            
//             len = len - 1;
//         };
//         vector::destroy_empty(nfts);

//         // TODO: Need to assert that the combo data object is the right object
//         let nft = nft::mint_nft_loose<Data>(
//             object::uid_to_inner(&combo_data.id),
//             ctx,
//         );

//         transfer::transfer(
//             nft,
//             recipient,
//         );
//     }

//     public entry fun mint_nft(
//         nft_data: &mut Data,
//         recipient: address,
//         ctx: &mut TxContext,
//     ) {
//         // TODO: should we allow for the minting of more than one NFT at 
//         // a time?
//         supply::increase_supply(&mut nft_data.supply, 1);

//         let nft = nft::mint_nft_loose<Data>(
//             nft_data_id(nft_data),
//             ctx,
//         );

//         transfer::transfer(
//             nft,
//             recipient,
//         );
//     }

//     // === Getter Functions  ===

//     /// Get the Nft Data's `id`
//     public fun id(
//         nft_data: &Data,
//     ): ID {
//         object::uid_to_inner(&nft_data.id)
//     }
    
//     /// Get the Nft Data's `id` as reference
//     public fun id_ref(
//         nft_data: &Data,
//     ): &ID {
//         object::uid_as_inner(&nft_data.id)
//     }

//     /// Get the Nft Data's `index`
//     public fun index(
//         nft_data: &Data,
//     ): u64 {
//         nft_data.index
//     }

//     /// Get the Nft Data's `name`
//     public fun name(
//         nft_data: &Data,
//     ): String {
//         nft_data.name
//     }

//     /// Get the Nft Data's `description`
//     public fun description(
//         nft_data: &Data,
//     ): String {
//         nft_data.name
//     }

//     /// Get the Nft Data's `collection_id`
//     public fun collection_id(
//         nft_data: &Data,
//     ): &ID {
//         &nft_data.collection_id
//     }

//     /// Get the Nft Data's `url`
//     public fun url(
//         nft_data: &Data,
//     ): Url {
//         nft_data.url
//     }

//     /// Get the Nft Data's `attributes`
//     public fun attributes(
//         nft_data: &Data,
//     ): &Attributes {
//         &nft_data.attributes
//     }

//     /// Get the Nft Data's `supply`
//     public fun supply(
//         nft_data: &Data,
//     ): &Supply {
//         &nft_data.supply
//     }

//     // === Private Functions ===

//     fun nft_data_id(nft_data: &Data): ID {
//         object::uid_to_inner(&nft_data.id)
//     }

//     fun c_nft_data_id<Data: store>(nft_data: &ComboData<Data>): ID {
//         object::uid_to_inner(&nft_data.id)
//     }

//     fun mint_and_share_data(
//         args: MintArgs,
//         collection_id: ID,
//         recipient: address,
//         ctx: &mut TxContext,
//     ) {
//         let data_id = object::new(ctx);

//         event::emit(
//             MintDataEvent {
//                 object_id: object::uid_to_inner(&data_id),
//                 collection_id: collection_id,
//             }
//         );

//         let data = Data {
//             id: data_id,
//             index: args.index,
//             name: args.name,
//             supply: supply::new(args.max_supply, true),
//             description: args.description,
//             collection_id: collection_id,
//             url: args.url,
//             attributes: args.attributes,
//         };

//         transfer::share_object(data);
//     }

//     fun mint_args(
//         index: u64,
//         name: String,
//         description: String,
//         url: Url,
//         attribute_keys: vector<String>,
//         attribute_values: vector<String>,
//         max_supply: Option<u64>,
//     ): MintArgs {
//         let attributes = Attributes {
//             keys: attribute_keys,
//             values: attribute_values,
//         };

//         MintArgs {
//             index,
//             name,
//             description,
//             url,
//             attributes,
//             max_supply,
//         }
//     }
// }