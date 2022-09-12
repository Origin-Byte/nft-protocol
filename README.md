- Sui v0.8.0

# Install

This codebase requires the installation of Sui cli as well as the sui source code downloaded in the parent folder of the repository

- Install the [Sui cli](https://docs.sui.io/build/install)
- `git clone https://github.com/MystenLabs/sui.git --branch devnet` to download the current sui develop soure code

# Built and Test

1. `$ sui move build` to build the available move modules
2. `$ sui move test` to run the move tests
3. `./bin/publish.sh` to publish the modules on localnet or devnet

# Origin Byte

A new approach to NFTs.

Origin Byte is an ecosystem of tools, standards and smart contracts designed to allow anybody to create NFTs, from simple artwork to gaming assets with arbitrarily complex behaviour, to sell them to the public, and to provide an on-chain secondary market infrastructure.

In this repository we currently offer the first version of Origin Byte nft and collection framework. The framework is composed by four modules, of which two are generic:

Generic modules:
- `nft.move`
- `collection.move`

Domain specific modules:
- `std_nft.move`
- `std_collection.move`

## Minting an NFT Collection

TODO: Add some explanation how collection object relate to Nft objects.

Before walking through the minting flow of a collection we first describe anatomically the `Collection` and `Metadata` objects, instanciated by the `collection` and `std_collection` modules.

### Collection Object

The collection object has the following data model:

| Field            | Type          | Description |
| ---------------- | ------------- | ----------- |
| `id`             | `UID`         | The UID of the collection object |
| `name`           | `String`      | The name of the collection |
| `symbol`         | `String`      | The symbol/ticker of the collection |
| `current_supply` | `u64`         | The current number of instantiated nft objects for this collection |
| `total_supply`   | `u64`         | The maximum number of nft objects instantiated at any given time for this colleciton |
| `initial_price`  | `u64`         | Initial mint price in Sui |
| `receiver`       | `address`     | Address that receives the mint price in Sui |
| `tags`           | `Tags`        | A set of strings that categorise the domain in which the Nft operates |
| `is_mutable`     | `bool`        | A configuration field that dictates if Nfts are mutable * |
| `metadata`       | `Meta`        | A generic type representing the metadata object embeded in the nft collection |

Where `Tags` is a struct with the field `enumarations` as a `VecMap<u64, String>` being the set of strings representing the domains of the Nft (e.g. Art, Profile Picture, Gaming Asset, Tickets, Loyalty Points, etc.)

The collection object has the following functions that mutate state:

- `create` which mints a collection object and returns it
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
- `metadata_mut`
- `initial_price`
- `receiver`
- `is_mutable`


### Standard Collection Metadata Object

The standard collection metadata object has the following data model:

| Field             | Type              | Description |
| ----------------- | ----------------- | ----------- |
| `id`              | `UID`             | The UID of the standard collection metadata object |
| `royalty_fee_bps` | `u64`             | The royalty fees creators accumulate on the sale of Nfts * |
| `creators`        | `vector<Creator>` | A vector containing the information of the creators |
| `data`            | `String`          | An open String field to add any arbitrary data |

* `royalty_fee_bps` and `is_mutable` are currently not being utilized.

Where `Creators` is a struct with the field `id` representing the address of the creator, `verified` which is a bool value that represents if the creator address has been sverified via signed transaction (this functionality is still not implemented), and `share_of_royalty` as the percentage share that the creator has over `royalty_fee_bps`.

The collection metadata object has the following functions that mutate state:

- `mint_and_transfer` mints a collection object, it's corresponding metadata object and transfers it to a recipient
- `mint_and_share` mints a collection object, it's corresponding metadata object and makes it a shared object
- `add_creator` pushes a `Creator` to `creators` field
- `remove_creator` pops a `Creator` form `creators` field
- `change_royalty` changes the field `royalty_fee_bps`
- `burn` which burns the collection object and subsequently the metadata object (TODO: to be implemented)

and the following getter functions:
- `royalty`
- `creators`
- `data`


### Nft Object

The generic nft object has the following data model:

| Field             | Type              | Description |
| ----------------- | ----------------- | ----------- |
| `id`              | `UID`             | The UID of the generic nft object |
| `collection_id`   | `ID`              | A pointer to the collection object |
| `metadata`        | `u64`             |  A generic type representing the metadata object embeded in the nft |

The generic nft object has the following init and drop functions:
- `create_owned`
- `destroy_owned`

### Nft Standard Metadata Object

The standard nft metadata object has the following data model:

| Field             | Type              | Description |
| ----------------- | ----------------- | ----------- |
| `id`              | `UID`             | The UID of the nft metadata object |
| `name`            | `String`          | Name of the Nft object |
| `index`           | `u64`             | The index of the Nft in relation to the whole collection |
| `uri`             | `Url`             | The Url of the Nft |
| `attributes`      | `Attributes`      | Attributes of a given Nft |


Where `Attributes` is a struct with the field `keys`, the attribute keys represented as string vector, in other words the set of traits (e.g. Hat, Color of T-shirt, Fur type, etc.) and Nft has, and `values` of such traits (e.g. Straw Hat, White T-shit, Blue Fur, etc.).

The standard nft metadata object has the following init and drop functions:
- `mint_and_transfer` which mint and Nft and transfer it to a recipient. Currently, the only way to mint the Nft is if the call is made by Collection owner, or by anyone if the collection is a shared object. This last option allows for anyone to mint their desired metadata which is suboptimal. For the timebeing we are allowing for this so that marketplaces can let users mint devnet nft mints from dummy collection but we will deprecate this as soon as we deploy the launchpad module, which will allow collection owners to mint and transfer the nft to a launchpad object which will configure the primary market sale strategy.
- `burn` which burns the Nft

and the following getter functions:

- `name`
- `index`
- `uri`
- `attributes`
