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
  - [Pseudorandom](https://explorer.sui.io/object/0x6aff3916ea448ecb49da685e79719781002f5346e775ea6a626257b10bb2793a)
  - [Utils](https://explorer.sui.io/object/0x5885713a908af7f3cf023c2ecf3c95e5af6d2caeeaf1a1c4e97b19358b067a04)
  - [Permissions](https://explorer.sui.io/object/0xc71e941d51e84f5e1c26157fe95b298aa6e56e3335a18bdbc97f1fd6393bafe6)
  - [Request](https://explorer.sui.io/object/0xcf11790d441b8b92f9fdc7e2e30f3864f2751fbda3fbd53010f728bcfd3fda51)
  - [Allowlist](https://explorer.sui.io/object/0x1487caf84ffaccadd3041bdf0e2c11a1f3a547010f1e0ac870f5727dca5b05a8)
  - [Authlist](https://explorer.sui.io/object/0xc367993cb6e76b653302aa099296e1a4404ef58a9f1b382e9b324e703160e80d)
  - [Critbit](https://explorer.sui.io/object/0x295cd8a79d28f2b0c6a1934a2863d40f6081d76a93d292359ac59710e8008806)
  - [Originmate](https://explorer.sui.io/object/0xf23cd3f06f3b223004d1b55bd74af13167ed0115a3467474a64c4a25b3df6e04)
  - [Kiosk](https://explorer.sui.io/object/0x5a50f6d261d103fc86f9797aafa1333918e53fa0896e0de2c72839389b412f50)
  - [NftProtocol](https://explorer.sui.io/object/0x93e37219faa7ef2e4b3d6f57029c3552e7c4fed25bb28f3170413d3a0574dd67)
  - [LiquidityLayerV1](https://explorer.sui.io/object/0xa81e103281edf411209e60ff8cf637f8495a0affac83bb90f93835b15adb9606)
  - [Launchpad](https://explorer.sui.io/object/0x005de2a36494381dd434604eda6cda1b90403e2ee7b2faf44fa06f8a83217952)


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
