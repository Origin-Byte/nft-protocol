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
  - [Permissions](https://explorer.sui.io/object/0x1d01a03fefe5d70c7cea863811f61150544d2265625dfae91408ccbba8a16704)
  - [Allowlist](https://explorer.sui.io/object/0x5a396593d6d7f2e3708be81bb45f85859c5600c77267e1fe54c68871e9ff88a7)
  - [Authlist](https://explorer.sui.io/object/0xb499426ff54e7ec709a6ebcf9300b51b12e8d1133b80462b724f91417f68b279)
  - [Request](https://explorer.sui.io/object/0x7de232c970371d5016c1e90d15f6879867af327dcc84c79f99fce10e44d15b2f)
  - [Kiosk](https://explorer.sui.io/object/0x58877c047ef49d8b2602587b2a26730b3f6a5b5004c4840eb00c24609c3e1c5e)
  - [Liquidity Layer](https://explorer.sui.io/object/0x3fdcd4efe728d281142f74760d62fc64986f8da88a7c6e4bb39d018efd70ca3f)
  - [Launchpad](https://explorer.sui.io/object/0x550e453a75ae4e8c6682003eac1944087f04624e728fa1af0b46cf45933937b9)
  - [NftProtocol](https://explorer.sui.io/object/0xf71ea35aa531a662dfbf8cf7695a5b475bc09f82cd218a801d1aa7c4df3e63e7)
  - [LaunchpadV2](https://explorer.sui.io/object/0x9533382218a78eca52299c14767fc40f94af048e0985cc0695a168bf9c851230)
- [Official Documentation](https://docs.originbyte.io/origin-byte/)
- [Developer Documentation](https://origin-byte.github.io/) (WIP)


In addition, you can find transfer lists curated by OriginByte here:
- [Trading Allowlist](https://explorer.sui.io/object/0xe8daf9d689bc1d9284eebbebe4cda69a36a45db02a475acf9cc0f60557437376)
- [P2P Transfer Authlist](https://explorer.sui.io/object/0x83ef9e893f0385575cb5eae66f62ddd3d3c7bba6883ac3452d00fe6c2d23122c)

# Install

This codebase requires installation of the [Sui CLI](https://docs.sui.io/build/install).

If you are running on Linux you can use [suivm](https://github.com/Origin-Byte/suivm) to handle installation for you.

# Built and Test

1. `$ sui move build` to build the available move modules
2. `$ sui move test` to run the move tests
3. `./bin/publish.sh` to publish the modules on localnet or devnet
