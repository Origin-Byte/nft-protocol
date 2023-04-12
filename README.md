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
  - [DevNet](https://explorer.sui.io/object/0x6cf3baf113ab6f1355a462def0bd3d4f49d5430e921755c1abef567f92e8ca43?network=devnet)
  - [TestNet](https://explorer.sui.io/object/0x86ed6bc882fa476f20db8d21256a20cc7c841b9e1a37c356daa5406f92412f3c)
- LaunchpadV2 contract:
  - [DevNet](https://explorer.sui.io/object/0x0defe126b357fd6af7337398916b1047994772c0f3ebcf2511316a4deb32d8e9?network=devnet)
  - [TestNet](https://explorer.sui.io/object/0xea9a3c40d87483546d0a4b25720e6009a36b4bed0903fcd71d904903d6369754)

- [Official Documentation](https://docs.originbyte.io/origin-byte/)
- [Developer Documentation](https://origin-byte.github.io/)

# Install

This codebase requires installation of the [Sui CLI](https://docs.sui.io/build/install).

If you are running on Linux you can use [suivm](https://github.com/Origin-Byte/suivm) to handle installation for you.

# Built and Test

1. `$ sui move build` to build the available move modules
2. `$ sui move test` to run the move tests
3. `./bin/publish.sh` to publish the modules on localnet or devnet
