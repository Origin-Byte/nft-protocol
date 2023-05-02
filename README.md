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
  - [Permissions](https://explorer.sui.io/object/0x0c0dfe1d585dd2a208d16a23ea769b70ad5c682f161bde613c56eabcbca8b138)
  - [Allowlist](https://explorer.sui.io/object/0x505c310fb3adfac0601b77408c1317abe078828670410feb2b77e1d19a03083f)
  - [Authlist](https://explorer.sui.io/object/0x9cc4dda2ad1477b2d4a23d646e87d906a2f48270a45330f3edf0f2da382aadf5)
  - [Request](https://explorer.sui.io/object/0x5f60d9a2b56de29cd953907b1e3825b078c99c3bf44fdbcfa24248ceae019944)
  - [Kiosk](https://explorer.sui.io/object/0x0bdb0c4adbabbdc04b5843548f283c5381dc557019c53aa750a7138997d41e98)
  - [Liquidity Layer](https://explorer.sui.io/object/0xedb26437833b9a8c06463a39f2af6508f44687b59f0014ecbd3b7da3c867a0f0)
  - [Launchpad](https://explorer.sui.io/object/0xbcd22c469cdf81b19f167227a373c3dff30a986384ff568667fe0cfe1eb2419f)
  - [NftProtocol](https://explorer.sui.io/object/0xc1c6dff093fbcff4c0f1d252e226ffcc5271c7d6f1523c60514068a76dab86d3)
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
