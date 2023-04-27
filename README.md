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
  - [Allowlist](https://explorer.sui.io/object/0x458d24cec51b0fe63f9c541b14bee9d4e74a6a912382398d9a464554ea511922)
  - [Authlist](https://explorer.sui.io/object/0xc33d2ebef28f631d8cd059693bc6c3f3df2ffb6db785aab8c7f24cc843e99248)
  - [Witness](https://explorer.sui.io/object/0xe913f2024aeeec54cc2e8951e8ef01e44fbfd639cca992e07acc275118e8ccae)
  - [Request](https://explorer.sui.io/object/0xa37b19d59b762ff0b03a790b48b918cb3b194eec795f0af212e1c199070efabd)
  - [Kiosk](https://explorer.sui.io/object/0xfc53c7688742374df1ef719b2ce177997aae409238baa0c6682832aa74da517e)
  - [Liquidity Layer](https://explorer.sui.io/object/0xda5ce01d0e365f2aac8df7d85d1cdfe271fd75db338daf248132991d74c2f1c8)
  - [Launchpad](https://explorer.sui.io/object/0x1d4ce246312891039588611628057aefd5d229a7f5449788ab18361da9f90631)
  - [NftProtocol](https://explorer.sui.io/object/0x2eead14abcb5a228b62a274ad22510555365f3f8e0af01bd6fb5de689f98f325)
  - [LaunchpadV2](https://explorer.sui.io/object/0x19aefe1458b74f9c9106d535f24b24c57456afddd30fd8858453ec2b5e1fcf7d)
- [Official Documentation](https://docs.originbyte.io/origin-byte/)
- [Developer Documentation](https://origin-byte.github.io/) (WIP)


In addition, you can find transfer lists curated by OriginByte here:
- [Trading Allowlist](https://explorer.sui.io/object/0x4abb6c110090577b4e4d85555a8e925c0b3ab6df0473ce35d71712cc1af3390c)
- [P2P Transfer Authlist](https://explorer.sui.io/object/0x811c730277a87395bd71e2111a3c43a1306c9d47726eaafac58f5d8ae0d78232)

# Install

This codebase requires installation of the [Sui CLI](https://docs.sui.io/build/install).

If you are running on Linux you can use [suivm](https://github.com/Origin-Byte/suivm) to handle installation for you.

# Built and Test

1. `$ sui move build` to build the available move modules
2. `$ sui move test` to run the move tests
3. `./bin/publish.sh` to publish the modules on localnet or devnet
