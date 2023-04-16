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
  - [TestNet](https://explorer.sui.io/object/0x7f37d6f86facc20063f3e19b95ac84d973ac2cfd64406c561c26921a57b578b2)
  - [DevNet](https://explorer.sui.io/object/0x99a197a453f06445dae34347055a359ca4694ea90b7ebacfe15a694e21852119)
- LaunchpadV2 contract:
  - [TestNet](https://explorer.sui.io/object/0x1fab4337fffe7a079009c9b77a7132b43246413b7194fabcca9d620c8066a197)
  - [DevNet](https://explorer.sui.io/object/0xdd7d04a361dff2c3943253f2eca94ef683208e07af0a4d2efedac9eb06e63d70)

- [Official Documentation](https://docs.originbyte.io/origin-byte/)
- [Developer Documentation](https://origin-byte.github.io/)

# Install

This codebase requires installation of the [Sui CLI](https://docs.sui.io/build/install).

If you are running on Linux you can use [suivm](https://github.com/Origin-Byte/suivm) to handle installation for you.

# Built and Test

1. `$ sui move build` to build the available move modules
2. `$ sui move test` to run the move tests
3. `./bin/publish.sh` to publish the modules on localnet or devnet
