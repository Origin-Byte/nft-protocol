<a href="https://originbyte.io/">
    <h1><img src="./assets/logo.svg" alt="OriginByte" width="50%"></h1>
</a>

<h3>A new approach to Digital Assets</h3>

Origin-Byte is an ecosystem of tools, standards, and smart contracts designed to make life easier for Digital Asset Creaters, from Web3 Game Developers, NFT creators, creators of Tokenized Media or non-standard OTC assets.

From simple artwork to complex gaming assets, we want to help you reach the public, and provide on-chain market infrastructure.

The ecosystem is partitioned into three critical components:

- The NFT standard, encompassing the core `Nft`, `Collection`, and `Safe` types,
  controlling the lifecycle and properties of each NFT.
- Primary markets, encompassing `Marketplace`, `Listing`, and numerous markets which
  control the initial minting and sale of NFTs.
- Secondary markets, encompassing principally the `Orderbook` which allows you
  to trade existing NFTs.

## Contracts

- Protocol contracts:
  - [Pseudorandom](https://explorer.sui.io/object/0x96151d14878707d390b370b70843704cc4606209883d3ea3a4e5cf8ac2872be2)
  - [Utils](https://explorer.sui.io/object/0xd5eaac4e1952473940b120a31bbca4c155fe78b2f0dabd63805e491a3384ecde)
  - [Permissions](https://explorer.sui.io/object/0xe571741e4b123a32e4afda5268735a87f7ae5bc1a945d53c2c160d161651c7fc)
  - [Request](https://explorer.sui.io/object/0xd4e94a458e5d192ffbac8364339e926450391bb8bd248973087f8cc264da3258)
  - [Allowlist](https://explorer.sui.io/object/0x165462c17573288e823bbaabc782723f673c528a0dead0f320fe9d99e3ac66aa)
  - [Authlist](https://explorer.sui.io/object/0xfec47309a83e59589f3540c8936b6208d7fa62163b8c3e939937ca0880371c53)
  - [Critbit](https://explorer.sui.io/object/0x1e9ce91148edbd6e474252cdc1c3af2a27fc4c238be617ed56b55275e0e92ef5)
  - [Originmate](https://explorer.sui.io/object/0x40fccbe644cb7e496309af17fc76574e5ac436ae8533a6f830d596264fbc5bb2)
  - [Kiosk](https://explorer.sui.io/object/0x710fe6944f741058ce916cd16e87953a656b5d339591c1627e73e41f01509d99)
  - [NftProtocol](https://explorer.sui.io/object/0xbdd1811dd6e8feb2c7311d193bbf92cb45d3d6a8fb2b6ec60dc19adf20c18796)
  - [LiquidityLayerV1](https://explorer.sui.io/object/0x509f287d326291d1066e20e2eb8adbbe1c8283e895d58c23afe7c9228645def2)
  - [Launchpad](https://explorer.sui.io/object/0x7b36997c1606ce7421d433eeafd52ace7921dad632ee6a2ef944e5b3f5479b3c)


## Resources

- [Official Documentation](https://docs.originbyte.io/origin-byte/)
- [Developer Documentation](https://origin-byte.github.io/) (WIP)


In addition, you can find transfer lists curated by OriginByte here:
- [Trading Allowlist](https://explorer.sui.io/object/0xb9353bccfb7ad87b9195c6956b2ac81551350b104d5bfec9cf0ea6f5c467c6d1)
- [P2P Transfer Authlist](https://explorer.sui.io/object/0xedf545c164dacf55acf37431b90f6b5e55acd5925f4683de8753760d2b5e74fa)

# Install

This codebase requires installation of the [Sui CLI](https://docs.sui.io/build/install).

If you are running on Linux you can use [suivm](https://github.com/Origin-Byte/suivm) to handle installation for you.

# Built and Test

1. `./bin/build.sh` to build the available move modules
2. `./bin/test.sh` to run the move tests
