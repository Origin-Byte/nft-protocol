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
  - [PseudoRandom](https://explorer.sui.io/object/0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb)
  - [Permissions](https://explorer.sui.io/object/0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40)
  - [Allowlist](https://explorer.sui.io/object/0x70e34fcd390b767edbddaf7573450528698188c84c5395af8c4b12e3e37622fa)
  - [Authlist](https://explorer.sui.io/object/0x228b48911fdc05f8d80ac4334cd734d38dd7db74a0f4e423cb91f736f429ebe4)
  - [Request](https://explorer.sui.io/object/0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43)
  - [Kiosk](https://explorer.sui.io/object/0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b)
  - [Liquidity Layer](https://explorer.sui.io/object/0xae5e376b646e4d095b99e2eeaa222e40d5a6c26250419f00c4fc613a9cfb2e18)
  - [Launchpad](https://explorer.sui.io/object/0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b)
  - [NftProtocol](https://explorer.sui.io/object/0xbc3df36be17f27ac98e3c839b2589db8475fa07b20657b08e8891e3aaf5ee5f9)
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
