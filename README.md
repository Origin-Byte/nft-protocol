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
  - [Allowlist](https://explorer.sui.io/object/0x7e557c2e1d9a0d79b984a371616255216a2ee550d636663dcfc40bcf644394f2)
  - [Authlist](https://explorer.sui.io/object/0x4ba6606d172d4dd3712aee62399ab5943cdcb021f6af22c9b78619ec96bc96a7)
  - [Witness](https://explorer.sui.io/object/0x9474372fc2c97505d1c3eb57cc50cc5d662d53b14ead827c886e713fa23bf252)
  - [Request](https://explorer.sui.io/object/0x2cad959dbdfa85fc82d329f8f1dc90ed0b4793f7ee3ea048f3dbb3faea368c84)
  - [Kiosk](https://explorer.sui.io/object/0x76b14ea4e29c7bd8e16859ca716f9b3a084b848cf2c823e38bc67432be54f7aa)
  - [Liquidity Layer](https://explorer.sui.io/object/0x9d34b9ac3269a8995c66acd08a62bb5b069b31ba48647664f8b1c53fa059b927)
  - [Launchpad](https://explorer.sui.io/object/0xa0a588a75179d51d60e4b8575a3a89322552166840de14d3d3367efd624dc0fc)
  - [NftProtocol](https://explorer.sui.io/object/0x46315c3ed0e748710ad5e5a0ec162265c2c1140752f7a8e6837aa3ad8c5f2e27)
  - [LaunchpadV2](https://explorer.sui.io/object/0x0124347740a76c3e7aa0e84e4f94d7fb525becf4109c11f16cbdd758bcc8657b)
- [Official Documentation](https://docs.originbyte.io/origin-byte/)
- [Developer Documentation](https://origin-byte.github.io/) (WIP)

# Install

This codebase requires installation of the [Sui CLI](https://docs.sui.io/build/install).

If you are running on Linux you can use [suivm](https://github.com/Origin-Byte/suivm) to handle installation for you.

# Built and Test

1. `$ sui move build` to build the available move modules
2. `$ sui move test` to run the move tests
3. `./bin/publish.sh` to publish the modules on localnet or devnet
