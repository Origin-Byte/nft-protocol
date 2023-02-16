<p align="center">
    <a href="https://originbyte.io/">
        <img src="/Origin-Byte/nft-protocol/raw/main/assets/logo.svg" alt="OriginByte">
    </a>
    <h3 align="center">OriginByte</h3>
    A new approach to NFTs.
</p>

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

- Devnet contract on the [Sui Explorer](https://explorer.sui.io/object/0xde886c0410106e811bc4a67957fed77e456831d2?network=devnet)
- [Official Documentation](https://docs.originbyte.io/origin-byte/)
- [Developer Documentation](https://origin-byte.github.io/)

# Install

This codebase requires installation of the [Sui CLI](https://docs.sui.io/build/install).

If you are running on Linux you can use [suivm](https://github.com/Origin-Byte/suivm) to handle installation for you.

# Built and Test

1. `$ sui move build` to build the available move modules
2. `$ sui move test` to run the move tests
3. `./bin/publish.sh` to publish the modules on localnet or devnet
