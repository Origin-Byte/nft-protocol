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
  - [PseudoRandom](https://explorer.sui.io/object/0x9a586ae29d94788c0fc1db567b83f277c9f20af4e825374e127a331f2ae8231c)
  - [Permissions](https://explorer.sui.io/object/0x59839eebd432e473ffca5a08675d26c49526ed39b584c39e762afa8c127f25a2)
  - [Allowlist](https://explorer.sui.io/object/0x58c01ad7908a1c5ffbd70d89ac33e83cb554b828d69a7772246ae386bd62b5a7)
  - [Authlist](https://explorer.sui.io/object/0x4e95600adb05c72bd2caefac7cfda17ca9ccd78846a15663b06662258761b81a)
  - [Request](https://explorer.sui.io/object/0xadf32ebafc587cc86e1e56e59f7b17c7e8cbeb3315193be63c6f73157d4e88b9)
  - [Kiosk](https://explorer.sui.io/object/0x2678c98fe23173eebea384509464eb81b1f3035a57419cb46d025000c337451a)
  - [Liquidity Layer V1](https://explorer.sui.io/object/0x8534e4cdfd28709c94330a9783c3d5fe6f5daba0bffb69102ce303c5b38aed5a)
  - [Launchpad V1](https://explorer.sui.io/object/0x546b50e2570a478ecdfc6e836077fc1f69306393738b0be2df459e658ed20915)
  - [NftProtocol](https://explorer.sui.io/object/0x6f42ec2355fcda5ebeee2399d901ae9f71cb214e640a45a0007f1f1cdf9f7b5e)
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
