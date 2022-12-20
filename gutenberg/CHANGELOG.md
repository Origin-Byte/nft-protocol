# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2022-12-20

### Changed

- Adapted Move templating engine to Nft protocol version 0.14.0
- Renamed `NftType.Unique`  to `NftType.Classic` configuration from `config.yaml`

### Added
- `Collection.url` from `config.yaml` as it is no longer being used

### Removed

- `NftType.Collectible` configuration from `config.yaml`
- `NftType.CNft` configuration from `config.yaml`
- `Launchpad` configuration from `config.yaml`
- `Collection.is_mutable` from `config.yaml`
- `Collection.data` from `config.yaml`
