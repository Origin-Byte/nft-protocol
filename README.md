- Sui v0.15.0

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

The naturally NFT release strategy for embedded NFTs is for the NFT creators to pre-mint them on-chain and transfer them to a Launchpad object, which in turns is responsible to configure the NFT Release / Primary Market Sales strategy.

To mint an embedded NFT, modules will call the function `nft::mint_nft_embedded` which will create the `Data` object as well as the `Nft`.

### Loose NFTs

In contrast, since loose NFTs do not wrap the data object within itself, they can represent 1-to-many relationships between the data object and the NFT objects. Basically, one can mint any amount of NFTs pointing to a single data object. This is ideal to represent digital collectibles, such as digital football or baseball cards, as well as gaming items that more than one user should have access to.

Whilst Embedded NFTs have a simpler design and thus are more suitable for simple use cases, Loose NFTs are more suitable for digital collectibles and on-chain gaming items. Since they separate the data from the NFT, they can substantially reduce the amount of data redundancy you would otherwise have if you would use Embedded NFTs. A practical example is, if any creator wants to mint million of gaming NFTs it is dramatically cheaper to use the Loose NFT implementation.

In loose NFTs, the `Data` object is first minted and only then the NFTs associated to that object are minted.

To mint a loose NFT, modules will first create the data object on-chain and then allows the NFTs to be minted on the fly when needed, via the function call `nft::mint_nft_loose`.

### Type Exporting

In the spirit of the design philosophy presented in this [RFC](https://github.com/MystenLabs/sui/blob/a49613a52d1556386464be7d138c379773f35499/sui_programmability/examples/nft_standard/README.md), NFTs of a given NFT Collection have their own type `T` which is expressed as:

- `Nft<T, D>`
- `Collection<T, M>`

Where the following generics represent:

- `T` NFT type export that types the `Nft` and `Collection` object
- `D` a generic for the NFT `Data` object type
- `M` a generic for the Collection `Metadta` object type

### A 3-layered approach

Since the NFTs are type exported, each NFT collection will have to deploy its type-specific contract that interfaces with OriginByte modules.

Consider two sample NFT collections: Suimarines and Suiway Surfers. To launch these collections on Sui, the creators will deploy the contracts `suimarines` and `suiway_surfers` (this deployment is facilitated via our [Gutenberg](https://github.com/Origin-Byte/nft-protocol/tree/main/gutenberg) program). Creators will be able to choose which NFT implementation they want their collection to have (i.e. Unique NFTs, Collectibles, Composable NFTs, Tickets, Loyalty Points, etc.):

<img src="assets/3_layer.png" width="632" height="395" />

The core vision is that any developer can build a custom implementation on top of the base NFT contract. Currently we have implemented the following domain-specific modules:

- `nft_protocol::unique_nft`
- `nft_protocol::collectible`
- `nft_protocol::c_nft`

These domain-specific modules in turn communicate with the base module `nft_protocol::nft` to mint the NFTs and to perform basic actions such as morphing the NFT from loose to embedded and vice-versa.

To summarise, the core NFT module is responsible for wrapping all NFTs with a unified type `Nft<T>` whilst still providing enough flexibility by allowing NFTs to be Embedded or Loose. The modules that build on top of it, such as the Unique, Collectible and CNft, are responsible for building NFTs with specific behaviour and metadata fields. Finally, the contracts to be deployed by the creators (e.g. Suimarines) allows all NFTs of that collection to have the same type `T` and therefore in conjunction with our core module create a unified type `Nft<T>` (e.g. `Nft<SUIMARINES>`).

### Relationship to Collection object

Conceptually, we can think of NFTs being organized into collections. It is in essence a 1-to-many relational data model, that could, in a traditional database setup, be represented by two relational database tables, `collection` and `nfts`, where `collection_id` would serve as a primary key for the `collection` table and a foreign key to the `nfts` table.

In Move, the way we represent this relational model is to guarantee that the NFT objects themselves have an `ID` pointer to the collection `UID`.

To mint an NFT, projects must first create the NFT collection object, where metadata and configurations about the project will be stored. The NFT collection objects are meant to be owned by the project owners, who maintain control over the collection and its NFTs while the collection is mutable (TODO: We should separate the concept of Freezing the Collection and inherent mutability of its NFTS).

At any point in time, the collection owner can decide to make the collection immutable, which involves freezing the collection object and its associated NFTs. However, not all fields of the Collection are frozen:

- The field current_supply will still mutate every time an NFT is minted or burned
- Collection owners will still be able to push and pop tags onto the field tags

When minting an NFT, you need to pass on a mutable reference to the Collection object. This means that only the collection owner can perform the initial mint, unless it is a shared-object in which case anyone can.

## Data Model

### Collection

The collection object, `Collection<phantom T, M: store>`, has the following data model:

| Field             | Type              | Description                                                                    |
| ----------------- | ----------------- | ------------------------------------------------------------------------------ |
| `id`              | `UID`             | The UID of the collection object                                               |
| `name`            | `String`          | The name of the collection                                                     |
| `description`     | `String`          | The description of the collection                                              |
| `symbol`          | `String`          | The symbol/ticker of the collection                                            |
| `receiver`        | `address`         | Address that receives the royalty proceeds                                     |
| `tags`            | `Tags`            | A set of strings that categorize the domain in which the NFT operates          |
| `is_mutable`      | `bool`            | A configuration field that dictates whether NFTs are mutable                   |
| `royalty_fee_bps` | `u64`             | The royalty fees creators accumulate on the sale of NFTs \*                    |
| `creators`        | `vector<Creator>` | A vector containing the information of the creators                            |
| `metadata`        | `M`               | A generic type representing the metadata object embedded in the NFT collection |

- `royalty_fee_bps` is currently not being utilized but will be used in the standard launchpad module.

Where `Tags` is a struct with the field `enumerations` as a `VecMap<u64, String>` being the set of strings representing the domains of the NFT (e.g. Art, Gaming Asset, Tickets, Loyalty Points, etc.)

Where `Creators` is a struct with the following fields:

- `id` representing the address of the creator
- `verified` which is a bool value that represents if the creator address has been verified via signed transaction (this functionality is still not implemented)
- `share_of_royalty` as the percentage share that the creator has over `royalty_fee_bps`.

The function associated to the intial creation of the Collection is meant to be called by the standard collection `std_collection` contract:

- `mint` which mints a collection object, with or without regulated supply, mints a `MintAuthority` object and transfers it to the `recipient`, and returns the collection object. The `MintAuthority` object is meant to be owned by the creators and gives them the power to either minting the NFTs (embeeded) or mint the associated data objects (loose).

The contract also exposes the following entry function to be called by the client code:

- `burn_regulated` to delete a collection provided that the current supply is zero
- `freeze_collection` (irreversible)
- `rename`
- `change_description`
- `change_symbol`
- `change_receiver`
- `push_tag`
- `pop_tag`
- `change_royalty` changes the field `royalty_fee_bps`
- `add_creator` pushes a `Creator` to the `creators` field
- `remove_creator` pops a `Creator` from the `creators` field
- `ceil_supply`: Regulated collections can have a cap on the maximum supply. This function call adds a value to the maximum supply.
- `increase_max_supply`
- `decrease_max_supply`

#### Mint Authority

As mentioned previously, the collection module also defines an object called `MintAuthority` This object gives power to the owner to mint objects for that collection. It has the following fields:

- `id`
- `collection_id`
- `supply_policy`
  - `regulated` (i.e true or false)
  - `supply`
    - `frozen` (i.e. true or false)
    - `max`
    - `current`

The supply policy of a collection, defined by its corresponding Mint Authority object, can either be regulated or unregulated. A regulated supply means that every time an object is minted, a counter will be incremented and the `supply.current` will be increased. This essentially means that regulated supplies keep track of their supply on-chain, and therefore during the minting process nodes will have to operate a lock on the `MintAuthority` object during parallel mint transactions. Unregulated supplies on the other hand do not keep on-chain track of their current supply and therefore nodes will not require to operate a lock on the `MintAuthority` object and hence mint transactions can be fully independent from each other.

### Standard Collection Metadata

The standard collection metadata object, `StdMeta`, has the following data model:

| Field  | Type     | Description                                        |
| ------ | -------- | -------------------------------------------------- |
| `id`   | `UID`    | The UID of the standard collection metadata object |
| `json` | `String` | An open string field to add any arbitrary data     |

The functions associated to the intial creation of the Collection on-chain is meant to be called by the contract deployed by the creators:

- `mint` mints a collection object, it's corresponding metadata object, and makes it a shared object

The following entry functions can be called directly by the client code:

- `burn_regulated` which burns a regulated collection object and subsequently the metadata object if the NFT supply is zero. It can only be called by the `MintAuthority` owner

### NFT (Base type)

Generic NFT object, `Nft<phantom T, D: store>`, has the following data model:

| Field     | Type        | Description                                                               |
| --------- | ----------- | ------------------------------------------------------------------------- |
| `id`      | `UID`       | The UID of the generic NFT object                                         |
| `data_id` | `ID`        | A pointer to the collection object                                        |
| `data`    | `Option<D>` | An optional generic type representing the data object embedded in the NFT |

All functions associated to this module are meant to be called by the upstream modules (i.e. Unique NFT, Collectible, cNFT modules). It has the following functions:

- `mint_nft_loose` to mint a loose NFT
- `mint_nft_embedded` to mint an embedded NFT
- `join_nft_data` to turn a loose NFT to embedded NFT
- `split_nft_data` to turn an embedded NFT to loose
- `burn_loose_nft` to burn a loose NFT
- `burn_embedded_nft` to burn an embedded NFT

Note that this module has no entry functions and therefore it cannot be called directly by the client code.

### Unique NFT

The Unique NFT type is the our plain-vanilla type. It's the right type for a collection of unique Art NFTs and it's our simplest NFT implemenation.

Unique NFT data object, `Unique`, has the following data model:

| Field           | Type         | Description                        |
| --------------- | ------------ | ---------------------------------- |
| `id`            | `UID`        | The UID of the NFT metadata object |
| `name`          | `String`     | Name of the NFT object             |
| `description`   | `String`     | Description of the NFT object      |
| `collection_id` | `ID`         | ID pointer to Collection object    |
| `url`           | `Url`        | The URL of the NFT                 |
| `attributes`    | `Attributes` | Attributes of a given NFT          |

Where `Attributes` is a struct with the field `keys`, the attribute keys represented as string vector, in other words the set of traits (e.g. Hat, Color of T-shirt, Fur type, etc.) and NFT has, and `values` of such traits (e.g. Straw Hat, White T-shirt, Blue Fur, etc.).

All functions associated to the intial creation of the NFTs on-chain are meant to be called by the contract deployed by the creators. The Unique NFT module has the following functions to be called:

- `mint_unregulated_nft ` to mint an NFT from a collection with unregulation supply and transfer it to the launchpad object
- `mint_regulated_nft` to mint an NFT from a collection with regulated supply and transfer it to the launchpad object
- `direct_mint_unregulated_nft` to mint an NFT from a collection with unregulated supply and transfer it directly to a user address
- `direct_mint_regulated_nft` to mint an NFT from a collection with regulated supply and transfer it directly to a user address

The following entry functions can be called directly via the Unique NFT module:

- `burn_nft` to burn an NFT

### Collectible NFT

The Collectible NFT type is perfect for representing digital collectibles that aren’t typically unique.

It can be used to create collectibles like baseball or football cards, where each card has its own supply (i.e. The better the player the rarer the card). This is enabled by utilizing a Loose NFT implementation, which separates the data object from the NFTs themselves.

Example:
For a collection of 100 different baseball cards, the NFT creator will create 100 data objects, with each representing a different card. Each card will have its own supply and once the data objects are minted by the NFT creators, users can come in and mint the NFTs.

Collectible NFT data object, `Collectible`, has the following data model:

| Field           | Type         | Description                                |
| --------------- | ------------ | ------------------------------------------ |
| `id`            | `UID`        | The UID of the NFT metadata object         |
| `name`          | `String`     | Name of the NFT object                     |
| `description`   | `String`     | Description of the NFT object              |
| `collection_id` | `ID`         | ID pointer to Collection object            |
| `url`           | `Url`        | The URL of the NFT                         |
| `attributes`    | `Attributes` | Attributes of a given NFT                  |
| `supply`        | `Supply`     | Object determining Supply limit of the NFT |

Where `Attributes` is a struct with the field `keys`, the attribute keys represented as string vector, in other words the set of traits (e.g. Hat, Color of T-shirt, Fur type, etc.) and NFT has, and `values` of such traits (e.g. Straw Hat, White T-shirt, Blue Fur, etc.).

All functions associated to the initial creation of the NFT Data objects on-chain are meant to be called by the contract deployed by the creators. The Collectible module has the following functions to be called:

- `mint_unregulated_nft_data` to create the data object associated to an NFT from a collection with unregulated supply
- `mint_regulated_nft_data` to create the data object associated to an NFT from a collection with regulated supply

The minting of the NFTs themselves occurs in the launchpad phase, via the function call `nft::mint_loose_nft`.

The module has the following entry functions that can be called directly:

- `burn_regulated_collection_nft_data` to destroy a given NFT data object if the supply is zero
- `burn_nft` to burn an NFT

### Composable cNFTs

The Composable NFT type (cNFT) will take NFTs to a whole new level by allowing them to be merged to create Combo NFTs.

At its core our cNFT implementation is similar to our Collectibles implementation in that each different NFT (data object) can have its own supply. The key difference is that in this implementation, the creators can define composability rules by calling `compose_data_objects`.

By calling this function creators are essentially defining which, and how many times NFTs can be merged together.
These characteristics make cNFTs perfect for collections with Tradable Traits.

Example:
Think of a game like Runescape where you can merge copper and tin to make bronze, or wood and stone to make an axe.

Alternatively, in a conventional NFT collection, cNFTs could be used by creators to allow the merging of two NFTs (or traits) to create a new one. As individual metadata fields can be NFTs themselves, you could allow the combination of two rare skin types to create an entirely new one!

Composable NFT (cNFT) data object, `Composable<C: store + copy>`, has the following data model:

| Field           | Type            | Description                                                                                                                                                                                                                                                                                                                                                                         |
| --------------- | --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`            | `UID`           | The UID of the NFT metadata object                                                                                                                                                                                                                                                                                                                                                  |
| `data`          | `Option<Data>`  | Composable `Data` objects can have some `Data` struct attached to it. Currently, only the objects at the leaf nodes of the composability tree have `Data` whilst the others have `option::none()                                                                                                                                                                                    |
| `collection_id` | `ID`            | The ID of the NFT Collection                                                                                                                                                                                                                                                                                                                                                        |
| `supply`        | `Supply`        | Each composable has its own supply. This allows for configuration scarcity. If two objects, both with a supply of 10, merge to produce a composably of both, this composable object can have its own supply. This means that even if both leaf node objects have supply of 10, if the supply of the root node composable object is 5 then the NFTs can only be merge up to 5 times. |
| `componenets`   | `VecMap<ID, C>` | A VecMap storing a list of `C` structs which represent cloned versions of the constituent objects. These structs do not have key ability and can be copied for the sake of clonability. It is structured as VecMap such that we can have the original object `ID`s as the key for each `C`                                                                                          |

The `Data` objects have the following fields:

- `name`
- `description`
- `url`
- `attributes`

All functions associated to the initial creation of the constituent NFT Data objects on-chain are meant to be called by the contract deployed by the creators. The cNFT module has the following functions to be called:

- `mint_unregulated_nft_data` to create the data object associated to an NFT from a collection with unregulated supply
- `mint_regulated_nft_data` to create the data object associated to an NFT from a collection with regulated supply

The minting of the constituent NFTs themselves occurs in the launchpad phase, via the function call `nft::mint_loose_nft`. The minting of the Combo NFTs occurs at a later phase when NFT owners decide to merge the NFTs they own.

And has the following entry functions to be called directly by the client code:

- `compose_data_objects` is a permissioned method to be called by the NFT creators, creating combo data objects. Combo objects serve as a mechanism to describe which NFTs can be merged. Merging two NFTs is only allowed if there is an associated combo object for such merger.
- `mint_c_nft` is responsible for merging NFTs and transfering the Combo NFT to the owner.
- `split_c_nft` performs the opposite action of `mint_c_nft`. It burns the Combo NFT and returns the constituent NFTs back to the owner.
- `burn_nft` burns an NFT

### Slingshot Launchpad

In order for NFT creators to better control the flow of creating and releasing NFTs to the public we have created a launchpad module called Slingshot. Slingshot allows you to define what market primitive you want to utilise (i.e. Fixed Price sales, Auctions, etc.) and to break down your sales strategy into tiers, which with their own whitelisting configuration.

The Slingshot object, `Slingshot<phantom T, M>`, has the following data model:

| Field           | Type                 | Description                                                                     |
| --------------- | -------------------- | ------------------------------------------------------------------------------- |
| `id`            | `UID`                | The UID of the Slingshot object                                                 |
| `collection_id` | `ID`                 | The ID of the NFT Collection object                                             |
| `live`          | `bool`               | Boolean indicating if the sale is live                                          |
| `admin`         | `address`            | The address of the administrator                                                |
| `receiver`      | `address`            | The address of the receiver of funds                                            |
| `sales`         | `vector<Sale<T, M>>` | Vector of all Sale outleds that, each outles holding IDs owned by the slingshot |
| `is_embedded`   | `bool`               | Field determining if NFTs are embedded or loose                                 |

All functions associated to creation and deletion of the Launchpad are meant to be called by the upstream modules (i.e. currently only the Fixed Price module):

- `create` to create the Slingshot launchpad (called by the market module)
- `delete` to destroy the Slingshot launchpad (called by the market module)

Whereas entry functions associated to redeeming the NFTs can be called directly by the client code:

- `claim_nft_embedded` to redeem an embedded NFT
- `claim_nft_loose` to redeem a loose NFT

Note: One can only claim an NFT after having bought the NFT certificate from the sale. This action occurs directly in the market module.

### Launchpad Markets

Market modules export the `create_market` endpoint which can be used to create a launchpad with optional tiered sales.

The standard provides multiple types of markets that can be used, including fixed price and dutch auction markets. NFTs to be sold can be seggregated by sales outlets, each with different prices and different options for whitelisting rules.

Market modules have entry functions that are meant to be called directly by client code.

Launchpad administrators can call the following functions:

- `sale_on` permissioned entry function making the NFT sale live
- `sale_off` permissioned entry function pausing the NFT sale

#### Fixed Price Market

The fixed price market object, `FixedPriceMarket`, has the following data model:

| Field   | Type  | Description                        |
| ------- | ----- | ---------------------------------- |
| `id`    | `UID` | The UID of the Slingshot object    |
| `price` | `u64` | The price of a NFT for sale in SUI |

Clients can directly call the following entry functions to interact with the market:

- `buy_nft_certificate` to buy an NFT certificate from a permissionless Sales outlet
- `buy_whitelisted_nft_certificate` to buy an NFT certificate from a whitelisted Sales outlet

Additionaly, the administrator of the Launchpad can call the following function:

- `new_price` permissioned entry function to change the price of the sale

#### Auction Market

Auction market implements a Dutch auction to determine the price and allocate NFTs to bidders. In such an auction, the lowest price needed to sell all the NFTs will be the price which will be charged to bidders. However, auction owners can set a reserve price, disallowing bids on prices lower than the reserve.

The auction market object, `AuctionMarket`, has the following data model:

| Field           | Type                     | Description                                  |
| ----------------| ------------------------ | -------------------------------------------- |
| `id`            | `UID`                    | The UID of the Slingshot object              |
| `reserve_price` | `u64`                    | The price of a NFT for sale in SUI           |
| `bids`          | `movemate::crit_bit::CB` | Collection of all bids placed in the auction |

Clients can directly call the following entry functions to interact with the market:

- `create_bid` place a bid for a number of NFTs at a chosen price
- `create_bid_whitelisted` place a bid for a number of whitelisted NFTs at a chosen price
- `cancel_bid` cancel a single bid at the given price level in a FIFO manner

In addition, the administrator of the Launchpad can call the following function:

- `sale_cancel` permissioned entry function to cancel the NFT auction. `sale_cancel` refunds all open bids in contrast to `sale_off` which only pauses bidding.
- `sale_conclude` permissioned entry function to conclude the NFT auction, determine the price, and match NFTs with winning bids. Remaining bids are canceled.

## Guides for NFT Creators, Wallets and Marketplaces

Note: This section needs to be developed.

### Deploy a simple NFT collection

To deploy your own NFT collection follow our guide on how to use [Gutenberg](https://github.com/Origin-Byte/nft-protocol/blob/main/gutenberg/README.md) to automagically generate your collection specific Move module.
