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
  - [Permissions](https://explorer.sui.io/object/0xa0b1d5153718e2c1a47c33fbb0652c044b3bb7bbd3284e7a8ae208f33c6aa465)
  - [Allowlist](https://explorer.sui.io/object/0xc840bacf75a57dfc1b1d293d13c4b42d269ff6653f2f5023343ebdc967bcff1d)
  - [Authlist](https://explorer.sui.io/object/0x730dfb43e4e44b1fc04d2bac5066886c516e47bc1b709445d6b0ba804278cb65)
  - [Request](https://explorer.sui.io/object/0x33324b87a09f5b2928d8d62a00eb66f93baa8d7545330c8c8ca15da2c80cbc82)
  - [Kiosk](https://explorer.sui.io/object/0xb880efb88af9174c16cf561a07db6aebbca74ace27916761c374f711abb42a76)
  - [Liquidity Layer](https://explorer.sui.io/object/0xd34b56feab8ec4e31e32b30564e1d6b11eb32f2985c3fbb85b5be715df006536)
  - [Launchpad](https://explorer.sui.io/object/0xc935171cae32cb2f503762174cbaf2ebd3d32bd662289487ef0b9a25ed7df896)
  - [NftProtocol](https://explorer.sui.io/object/0xd624568412019443dbea9c4e97a6c474cececa7e9daef307457cb34dd04eee0d)
  - [LaunchpadV2](https://explorer.sui.io/object/0xdbc3dea6f5ed15b078c9a5cd72b337e554336a9604c4066ea9caaccf46e81866)
- [Official Documentation](https://docs.originbyte.io/origin-byte/)
- [Developer Documentation](https://origin-byte.github.io/) (WIP)


In addition, you can find transfer lists curated by OriginByte here:
- [Trading Allowlist](https://explorer.sui.io/object/0xa6353cc3ef51570eaaf3b62fef103041a9d7a85e22c59869f01da51407e45f9d)
- [P2P Transfer Authlist](https://explorer.sui.io/object/0xfe6c2384960147ec1887ebe838f5e476a540ea4b535eb31933045d5692e74a9a)

# Install

This codebase requires installation of the [Sui CLI](https://docs.sui.io/build/install).

If you are running on Linux you can use [suivm](https://github.com/Origin-Byte/suivm) to handle installation for you.

# Built and Test

1. `$ sui move build` to build the available move modules
2. `$ sui move test` to run the move tests
3. `./bin/publish.sh` to publish the modules on localnet or devnet
