# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Changed:
- Moved the supply mint policy responsibility off the `Collection` object to a separate
  object `MintAuthority`
- `Slingshot` has now witness pattern `Slingshot<phantom T, M>` where 
  `T` represents the exported NFT type and `M` the market type
- `std_collection::mint_and_transfer` function now expected `u64` for field `max_supply` instead
  of `Option<u64>` to facilitate function call on the client side

Added:

- `supply_policy` module with object `SupplyPolicy` to regulate NFT Collection supply
- Error handling via `err` module

Removed:
- `cap` module with objects `Limited` and `Unlimited` that regulate the supply
  of NFT collections
- Removed field `cap` from `Collection` object, removing the supply mint policy
  responsibility off the `Collection` object
- Removed field `index` from `unique_nft::Unique`, `collectibles::Collectible` and
  `c_nft::Data`


## [0.4.0] - 2022-10-11

### Changed
- Reimplemented `nft` module with `nft::Nft` object and removed `NftOwned`
- Reimplemented `collection` module with `collection::Collection` object
- Collection data fields now belong to `collection::Collection`
- `std_collection::StdMeta` now only has json field
- Reimplemented `slingshot` module with `slingshot::Slingshot` object
- NFT IDs for primary release are now stored in `sale::Sale` objects, accessible
  to the slingshot launchpad via the field `sales`
- Launchpads can now have `create_single_market` and `create_multi_market` sales
  configuration. The modules that implement the market type decide if the slinshot they initiate is single or multi market. In this current version, `fixed_price` is the only market immplementation.
- NFT Collections can now only be created via witness type

### Added
- `unique_nft` module and `unique_nft:Unique` object serving as domain-specific 
  embedded NFT implementation
- `collectibles` module and `collectibles:Collectible` object serving as domain-specific 
  loose NFT implementation
- `c_nft` module and `c_nft:Composable` object serving as domain-specific 
  loose NFT implementation
- `sale` module to be able to perform multiple sales per slingshot launchpad
- `whitelist` module to be able to perform whitelisted sales
- `cap` module with objects `Limited` and `Unlimited` that regulate the supply
  of NFT collections
- `supply` module with object `Supply` that controls and manages the supply of a given
  object

### Removed
- `std_nft` module and `std_nft::StdNft` object

## [0.3.0] - 2022-09-20

### Changed
- Renamed move package from `nftProtocol` to `NftProtocol`.
- Renamed field `uri` to `url` for `std_nft::NftMeta`
- Changed parameter `collection` from `ID` to `&Collection<T, Meta>`
  in `fixed_price::create`

## [0.3.0] - 2022-09-20

### Changed
- Renamed field `uri` to `url` for `std_nft::NftMeta`
- Changed parameter `collection` from `ID` to `&Collection<T, Meta>`
  in `fixed_price::create`

## [0.2.0] - 2022-09-20

### Added
- The following objects with `key`, `store` abilities:
  - `slingshot::Slingshot` as generic launchpad
  - `fixed_price::LaunchpadConfig` as fixed price launchpad configuration
  - `fixed_price::NftCertificate` as certificate to redeem NFT
- The following structs to be used as witnesses:
  - `fixed_price::FixedPriceSale`
- Method `std_nft::mint_to_launchpad` to mint an NFT an transfer it to a 
  launchpad


### Changed
- Bumped Sui version to `devnet-0.9.0`


## [0.1.0] - 2022-09-14

### Added

- The following structs with `key`, `store` abilities:
  - `collection::Collection` as generic Collection
  - `std_collection::CollectionMeta` as collection metadata
  - `nft::NftOwned` as generic NFT
  - `std_nft::NftMeta` as NFT metadata
- The following structs to be used as witnesses:
  - `std_nft::StdNft`
  - `std_collection::StdCollection` 
- The object type `tags::Tags` with `copy`, `drop`, `store`
