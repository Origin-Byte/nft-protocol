- Sui v0.10.0

# Install

This codebase requires installation of the [Sui CLI](https://docs.sui.io/build/install).

# Built and Test

1. `$ sui move build` to build the available move modules
2. `$ sui move test` to run the move tests
3. `./bin/publish.sh` to publish the modules on localnet or devnet

# OriginByte

A new approach to NFTs.

Origin-Byte is an ecosystem of tools, standards and smart contracts designed to make life easier for Web3 Game Developers and NFT creators. From simple artwork to complex gaming assets, we want to help you reach the public, and provide on-chain market infrastructure.

In Move, the powers of transferability and mutability are commingled, such that only the owner of a single writer object can transfer the object and mutate it within the bounds defined by its module.

Considering the broad range of NFT use cases, there are situations in which we will want NFTs to be mutated by the collection creators (e.g. Upgrading an Art collection; Increasing the damage level of an NFT in-game weapon), even though the NFTs themselves will be owned by users. There are mainly two ways to achieve this:

- The NFT owner can send the NFT to a shared object, to be mutated accordingly
- We can separate the NFT object from its Data object, hence allowing the Data object itself to be shared and mutated accordingly

In the OriginByte protocol, an `NFT` object is a hybrid object that can take two shapes:
- The shape of an NFT that embeds is own data, aka an Embedded NFT; 
- The shape of an NFT which does not embed its own data and contains solely a pointer to its data object, aka a Loose NFT.

This design allows us to keep only one ultimate type while simultaneously allowing the NFT to embed its data or to loosely pointing to it, depending on the use case. It is also possible to dynamically join or split the data object from the NFT object, therefore allowing for arbitrary dynamic behaviour.

The NFT struct is as follows:

```
struct Nft<phantom T, D: store> has key, store {
        id: UID,
        data_id: ID,
        data: Option<D>,
    }
```

By default it contains a pointer to its data object. A loose NFT will have the `data` field empty, in other words `option::none()`, whilst an embedded NFT will have its data object in the `data` field. Using the functions `nft::join_nft_data()` and `nft::split_nft_data()` we can convert back and forth between loose and embedded NFT.
### Embedded NFTs

As stated, embedded NFTs have their data object wrapped within itself. A core difference between embedded and loose NFTs is that, since the embedded NFT forces its data to be wrapped by itself, it can only represent a 1-to-1 relationship with the data object. This is ideal to represent simple collections of unique NFTs such as Art or PFP collections.

In embedded NFTs, the `Data` object and the `NFT` object are minted at the same time, or in other words, in the same entry function call.

### Loose NFTs

In contrast, since loose NFTs do not wrap the data object within itself, the can represent 1-to-many relationships between the data object and the NFT objects. Basically, one can mint any amount of NFTs pointing to a single data object. This is ideal to represent digital collectibles, such as digital football or baseball cards, as well as gaming items that more than one user should have access to.

In loose NFTs, the `Data` object is first minted and only then the NFTs associated to that object are minted.
### Type Exporting

In the spirit of the design philosophy presented in this [RFC](https://github.com/MystenLabs/sui/blob/a49613a52d1556386464be7d138c379773f35499/sui_programmability/examples/nft_standard/README.md), NFTs of a given NFT Collection have their own type `T` which is expressed as:
- `Nft<T, D>`
- `Collection<T, M, C>`

Where the following generics represent:
- `T` NFT type export that types the `Nft` and `Collection` object
- `D` a generic for the NFT `Data` object type
- `M` a generic for the Collection `Metadta` object type
- `C` a generic for the Collection `Cap` object type

TODO: Add something of this sort:
- Our understanding is that this is useful for human readability as well as to facilitate clients distinguish which collection a given NFT belongs to. Do we miss any other benefits?
- The result of this is that each NFT creator will have to deploy its own module. This is fine and can be abstracted by an SDK, nevertheless these modules should be as light as possible (if we assume 1KB per deployed module 50,000 collections would roughly equate to 50 MB, that’s fine)
- We believe this module deployed by the NFT creators should serve solely as a type exporter and should not contain any custom logic. Instead, the custom logic would be offloaded to another layer of modules that do not need to be deployed every time there is a new collection


### A 3-layered approach

Since the NFTs are type exported, each NFT collection will have to deploy its type-specific contract that interfaces with OriginByte modules.

Consider two sample NFT collections: Suimarines and Suiway Surfers. To launch these collections on Sui, the creators will deploy the contracts `suimarines` and `suiway_surfers` (this deployment will in the future be made via an OriginByte SDK). Creators will be able to choose which NFT implementation they want their collection to have (i.e. Unique NFTs, Collectibles, Composable NFTs, Tickets, Loyalty Points, etc.):

<img src="assets/3_layer.png" width="632" height="395" />

The core vision is that any developer can build a custom implementation on top of the base NFT contract. Currently we have implemented the following domain-specific modules:
- `nft_protocol::unique_nft`
- `nft_protocol::collectibles`
- `nft_protocol::c_nft`

These domain-specific modules in turn communicate with the base module `nft_protocol::nft` to mint the NFTs and to perform basic actions such as morphing the NFT from loose to embeeded and vice-versa.

### Relationship to Collection object
Conceptually, we can think of NFTs being organized into collections. It is in essence a 1-to-many relational data model, that could, in a traditional database setup, be represented by two relational database tables, `collection` and `nfts`, where `collection_id` would serve as the primary key for the `collection` table and foreign key to the `nfts` table.

In Move, the way we represent this relational model is to guarantee that the NFT objects themselves have a `ID` pointer to the collection `UID`.

To mint an NFT, projects must first create the NFT collection object, where metadata and configurations about the project will be stored. The NFT collection objects are meant to be owned by the project owners, who maintain control over the collection and its NFTs while the collection is mutable (TODO: We should separate the concept of Freezing the Collection and inherent mutability of its NFTS).

At any point in time, the collection owner can decide to make the collection immutable which involves freezing the collection object and its associated NFTs. However, not all fields of the Collection are frozen:

- The field current_supply will still mutate every time an NFT is minted or burned
- Collection owners will still be able to push and pop tags onto the field tags

When minting an NFT, you need to pass on a mutable reference to the Collection object. This means that only the collection owner can perform the initial mint, unless it is a shared-object in which case anybody can or anyone can.
## Minting an NFT Collection


// TODO: CONTINUE FROM HERE...


 This collection ownership pattern is useful since many projects will want to transfer NFTs to a Launchpad as part of the initial mint process. Therefore we expose three methods:

- `mint_and_transfer` to mint to an address
- `mint_to_launchpad` to mint to a `Slingshot<T, Config>` object


Let us now describe the `Collection` and `CollectionMeta` objects, instantiated by the `collection` and `std_collection` modules, as well as the `NftOwned` and `NftMeta` objects, instantiated by the `nft` and `std_nft` modules.

### Collection

The collection object, `Collection<phantom T, Meta>`, has the following data model:

| Field            | Type          | Description |
| ---------------- | ------------- | ----------- |
| `id`             | `UID`         | The UID of the collection object |
| `name`           | `String`      | The name of the collection |
| `symbol`         | `String`      | The symbol/ticker of the collection |
| `current_supply` | `u64`         | The current number of instantiated NFT objects for this collection |
| `total_supply`   | `u64`         | The maximum number of NFT objects instantiated at any given time for this collection |
| `initial_price`  | `u64`         | Initial mint price in Sui |
| `receiver`       | `address`     | Address that receives the mint price in Sui |
| `tags`           | `Tags`        | A set of strings that categorize the domain in which the NFT operates |
| `is_mutable`     | `bool`        | A configuration field that dictates whether NFTs are mutable |
| `metadata`       | `Meta`        | A generic type representing the metadata object embedded in the NFT collection |

Where `Tags` is a struct with the field `enumerations` as a `VecMap<u64, String>` being the set of strings representing the domains of the NFT (e.g. Art, Gaming Asset, Tickets, Loyalty Points, etc.)

The collection object has the following functions that mutate state:

- `create` which mints a collection object and returns it
- `init_args` returns `InitCollection` struct from the inputs which acts as input to `create` function
- `increase_supply` which increments `current_supply` by one 
- `decrease_supply` which decreases `current_supply` by one
- `burn` which burns the collection object if `current_supply` is zero

and the following modifier functions:
- `rename`
- `change_symbol`
- `change_total_supply`
- `change_initial_price`
- `change_receiver`
- `freeze_collection` (irreversible)
- `push_tag`

and the following getter functions:
- `name`
- `symbol`
- `current_supply`
- `total_supply`
- `tags`
- `metadata`
- `metadata_mut` returns a mutable reference to metadata object
- `initial_price`
- `receiver`
- `is_mutable`
- `id`
- `id_ref`


### Standard Collection Metadata

The standard collection metadata object, `CollectionMeta`, has the following data model:

| Field             | Type              | Description |
| ----------------- | ----------------- | ----------- |
| `id`              | `UID`             | The UID of the standard collection metadata object |
| `royalty_fee_bps` | `u64`             | The royalty fees creators accumulate on the sale of NFTs * |
| `creators`        | `vector<Creator>` | A vector containing the information of the creators |
| `data`            | `String`          | An open string field to add any arbitrary data |

* `royalty_fee_bps` is currently not being utilized but will be used in the standard launchpad module.

Where `Creators` is a struct with the following fields:
- `id` representing the address of the creator
- `verified` which is a bool value that represents if the creator address has been verified via signed transaction (this functionality is still not implemented)
- `share_of_royalty` as the percentage share that the creator has over `royalty_fee_bps`.

The collection metadata object has the following functions that mutate state:

- `mint_and_transfer` mints a collection object, it's corresponding metadata object, and transfers it to a recipient
- `mint_and_share` mints a collection object, it's corresponding metadata object, and makes it a shared object
- `add_creator` pushes a `Creator` to the `creators` field
- `remove_creator` pops a `Creator` from the `creators` field
- `change_royalty` changes the field `royalty_fee_bps`
- `burn` which burns the collection object and subsequently the metadata object

and the following getter functions:
- `royalty`
- `creators`
- `data`


### NFT

Generic NFT object, `NftOwned<phantom T, Meta>`, has the following data model:

| Field             | Type              | Description |
| ----------------- | ----------------- | ----------- |
| `id`              | `UID`             | The UID of the generic NFT object |
| `collection_id`   | `ID`              | A pointer to the collection object |
| `metadata`        | `u64`             |  A generic type representing the metadata object embedded in the NFT |

The generic NFT object has the following init and drop functions:
- `create_owned` to create the NFT (called by the Domain-specific module)
- `destroy_owned` to destroy the NFT (called by the Domain-specific module) 

the following modifier functions:
- `owned_metadata_mut`

and the following getter functions:

- `owned_metadata`
- `uid_ref`
- `id`
- `id_ref`
- `collection_id`

### NFT Standard Metadata

Standard NFT metadata object, `NftMeta`, has the following data model:

| Field             | Type              | Description |
| ----------------- | ----------------- | ----------- |
| `id`              | `UID`             | The UID of the NFT metadata object |
| `name`            | `String`          | Name of the NFT object |
| `index`           | `u64`             | The index of the NFT in relation to the whole collection |
| `url`             | `Url`             | The URL of the NFT |
| `attributes`      | `Attributes`      | Attributes of a given NFT |


Where `Attributes` is a struct with the field `keys`, the attribute keys represented as string vector, in other words the set of traits (e.g. Hat, Color of T-shirt, Fur type, etc.) and NFT has, and `values` of such traits (e.g. Straw Hat, White T-shirt, Blue Fur, etc.).

The standard NFT metadata object has the following init and drop functions:
- `mint_and_transfer` which mint and NFT and transfer it to a recipient. Currently, the only way to mint the NFT is if the call is made by the Collection owner (or by anyone if the collection is a shared object). This last option allows for anyone to mint their desired metadata which is suboptimal.

For the time being we are allowing for this so that marketplaces can allow users to mint devnet NFT mints from temporary collections. However, we plan to deprecate this as soon as we deploy the launchpad module, which will allow collection owners to mint and transfer the NFT to a launchpad object which will configure the primary market sale strategy.
- `burn` which burns the NFT

and the following getter functions:

- `name`
- `index`
- `url`
- `attributes`

### Slingshot Launchpad

The Slingshot object, `Slingshot<phantom T, Config>`, has the following data model:

| Field             | Type              | Description |
| ----------------- | ----------------- | ----------- |
| `id`              | `UID`             | The UID of the Slingshot object |
| `collection_id`   | `ID`              | The ID of the NFT Collection object |
| `live`            | `bool`            | Boolean indicating if the sale is live |
| `admin`           | `address`         | The address of the administrator |
| `receiver`        | `address`         | The address of the receiver of funds |
| `nfts`            | `vector<ID>`      | Vector of all IDs owned by the slingshot |
| `config`          | `Config`          | Config object |

It has the following init and drop functions:
- `create` to create the Slingshot launchpad (called by the Domain-specific module)
- `delete` to destroy the Slingshot launchpad (called by the Domain-specific module) 

the following transfer functions:
- `transfer_back` which allows the administrator to transfer back nfts from the Slingshot to a recipient address

the following modifier functions:
- `add_nft` (called by the NFT contract when an NFT is transferred to the Slingshot)
- `pop_nft` (called by the Domain-specific launchpad module when NFTs are transferred out of the Slingshot)
- `sale_on` to start the sale
- `sale_off` to pause or stop the sale
- `config_mut` returns a mutable reference to the upstream module

and the following getter functions:

- `collection_id`
- `collection_id_ref`
- `live`
- `config`
- `receiver`
- `admin`
- `nfts`


### Slingshot: Fixed Price Launchpad

The Fixed Price Launchpad config, `LaunchpadConfig`, has the following data model:

| Field             | Type              | Description |
| ----------------- | ----------------- | ----------- |
| `id`              | `UID`             | The UID of the Launchpad configuration object |
| `price`           | `u64`             | The fixed price of each NFT in the collection |

It has the following init and drop functions:
- `create` to create the Launchpad
- `delete` to destroy the Launchpad

the following transfer functions:
- `buy_nft_certificate` when a user wants to buy an NFT, they must first buy the NFT certificate which contains the ID of the NFT they can claim
- `claim_nft` after buying the NFT certificate, the user can then call this endpoint to redeem the allocated NFT

the following modifier functions:
- `new_price` (permissioned endpoint for administrator to call and change the sale price)

and the following getter functions:
- `price`