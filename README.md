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

- Protocol contract:
  - [DevNet](https://explorer.sui.io/object/0x30ac932177f6c7bb1ee142838f0faa8b0ac65f250455567c761c39d84c02082d?network=devnet)
  - [TestNet](https://explorer.sui.io/object/0x83df0d402271a54065cca3f0620b3e62f6324dc2bfd73aa5f4bd74f33c18b40b)
- LaunchpadV2 contract:
  - [DevNet](https://explorer.sui.io/object/0x1a79d9b2ae1066dfac2a0ffb0f5b905e99484a04e4b12673515d752340da42c8?network=devnet)
  - TestNet --> SOON!

- [Official Documentation](https://docs.originbyte.io/origin-byte/)
- [Developer Documentation](https://origin-byte.github.io/)

# Install

This codebase requires installation of the [Sui CLI](https://docs.sui.io/build/install).

If you are running on Linux you can use [suivm](https://github.com/Origin-Byte/suivm) to handle installation for you.

# Built and Test

1. `$ sui move build` to build the available move modules
2. `$ sui move test` to run the move tests
3. `./bin/publish.sh` to publish the modules on localnet or devnet
