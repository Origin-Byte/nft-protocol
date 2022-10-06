# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
