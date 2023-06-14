<a href="https://originbyte.io/">
    <h1><img src="./assets/logo.svg" alt="OriginByte" width="50%"></h1>
</a>

<h3>A new approach to NFTs</h3>

Origin-Byte is an ecosystem of tools, standards, and smart contracts designed to make life easier for Web3 Game Developers and NFT creators.
From simple artwork to complex gaming assets, we want to help you reach the public, and provide on-chain market infrastructure.

The ecosystem is partitioned into three critical components:

- The NFT standard, encompassing the core `Nft`, `Collection`, and `Safe` types,
  controlling the lifecycle and properties of each NFT.
- Primary markets, encompassing `Marketplace`, `Listing`, and numerous markets which
  control the initial minting and sale of NFTs.
- Secondary markets, encompassing principally the `Orderbook` which allows you
  to trade existing NFTs.

## Resources

- Protocol contracts:
  - [PseudoRandom](https://explorer.sui.io/object/0xc9a1f08e77bcc259099137634607d7286899c5f769b5df3171155c42d386201b)
  - [Permissions](https://explorer.sui.io/object/0xc8613b1c0807b0b9cfe229c071fdbdbc06a89cfe41e603c5389941346ad0b3c8)
  - [Allowlist](https://explorer.sui.io/object/0xefa0dce10909a68346038a4de41c2e627165f3d1c1bf9b6f44e390787a6bd13f)
  - [Authlist](https://explorer.sui.io/object/0x2fa28b4730e87700fdfa3f738d044d9d24f5da9e813c832aa1b084b6d66774fc)
  - [Request](https://explorer.sui.io/object/0x1fbc94cb238c555398a828963b469ae8e5d675c42746f6bec85cfa9dbb04b2c4)
  - [Kiosk](https://explorer.sui.io/object/0x1dddbcce1491a365d931a0dc6a64db596dad9c9915c6d0efb13e5c2efd5e95ce)
  - [Liquidity Layer V1](https://explorer.sui.io/object/0x47560bc8b2f68b30733ff2c516c6652b48fe7f0bfd0832acd8cc5306a301736e)
  - [Launchpad V1](https://explorer.sui.io/object/0xc0c5ca1e59bbb0e7330c8f182cbad262717faf7d8d0d7f7da4b3146391ecbbe1)
  - [NftProtocol](https://explorer.sui.io/object/0x77d0f09420a590ee59eeb5e39eb4f953330dbb97789e845b6e43ce64f16f812e)
- [Official Documentation](https://docs.originbyte.io/origin-byte/)
- [Developer Documentation](https://origin-byte.github.io/) (WIP)


In addition, you can find transfer lists curated by OriginByte here:
- [Trading Allowlist](https://explorer.sui.io/object/0xb9353bccfb7ad87b9195c6956b2ac81551350b104d5bfec9cf0ea6f5c467c6d1)
- [P2P Transfer Authlist](https://explorer.sui.io/object/0xedf545c164dacf55acf37431b90f6b5e55acd5925f4683de8753760d2b5e74fa)

# Install

This codebase requires installation of the [Sui CLI](https://docs.sui.io/build/install).

If you are running on Linux you can use [suivm](https://github.com/Origin-Byte/suivm) to handle installation for you.

# Built and Test

1. `$ sui move build` to build the available move modules
2. `$ sui move test` to run the move tests
3. `./bin/publish.sh` to publish the modules on localnet or devnet
