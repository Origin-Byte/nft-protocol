# Gutenberg

Automagically write Move smart contracts so you don’t have to!

Gutenberg is a templating engine for writing Move modules for OriginByte NFT collections.

In the spirit of the design philosophy presented in this [RFC](https://github.com/MystenLabs/sui/blob/a49613a52d1556386464be7d138c379773f35499/sui_programmability/examples/nft_standard/README.md), NFTs have their own type-exported Move module which can be deployed.

In practice, this means that creators will have to deploy their own Move module every time they want to create a new NFT collection. We don’t think NFT creators should have to deal with the technicalities of writing Move smart contracts, so we created Gutenberg to do it for you.

We describe the process for configuring NFT collections and running Gutenberg in the following steps.

### 1. Configure your NFT Collection

To configure an NFT collection, the creator will have to populate a configuration file.

A number of example configuration files are available in [`gutenberg/examples`](./examples).
A blank template is available in [`gutenberg/config.yaml`](./config.yaml) which has the following structure:

```yaml
NftType:

Collection:
  name:
  description:
  symbol:
  max_supply:
  receiver:
  tags:
    -
  royalty_fee_bps:
  is_mutable:
  data:

Launchpad:
  market_type: "fixed_price"
  prices: []
  whitelists: []
```

The top-level fields are defined as follows:

| Field            | Type          | Description |
| ---------------- | ------------- | ----------- |
| `NftType`        | `String`      | Name of the NFT type (`Unique`, `Collectible`, `CNft`) |
| `Collection`     | `Dictionary`  | List of fields defining the collection |
| `Launchpad`      | `Dictionary`  | List of fields defining the launchpad |

Where the fields for `Collection` are:

| Field           | Type       | Description |
| --------------- | ---------- | ----------- |
| name            | `String`   | The name of the collection |
| description     | `String`   | The description of the collection |
| symbol          | `String`   | The symbol/ticker of the collection |
| max_supply      | `Integer`  | The total supply of the collection |
| receiver        | `String`   | Address that receives the sale and royalty proceeds |
| tags            | `List`     | A set of strings that categorize the domain in which the NFT operates |
| royalty_fee_bps | `Integer`  | The royalty fees creators accumulate on the sale of NFTs |
| is_mutable      | `Boolean`  | A configuration field that dictates whether NFTs are mutable |
| data            | `String`   | Field for extra data |

And where the fields for `Launchpad` are:

| Field        | Type               | Description |
| ------------ | ------------------ | ----------- |
| market_type  | `String`           | Name of the market type (`fixed_price`, `auction`) |
| ..           | `MarketParameters` | Each market type defines different parameters |

Each market type can derfne different `MarketParameters` parameters.

| Field          | Type               | Description |
| -------------- | ------------------ | ----------- |
| `FixedPrice`   |                    |             |
| -------------- | ------------------ | ----------- |
| prices         | `Array<Integer>`   | Array of prices for sale outlets |
| whitelists     | `Array<Boolean>`   | Array defining whether the outlet is whitelisted |
| -------------- | ------------------ | ----------- |
| `Auction`      |                    |             |
| -------------- | ------------------ | ----------- |
| reserve_prices | `Array<Integer>`   | Array of reserve prices for sale outlets |
| whitelists     | `Array<Boolean>`   | Array defining whether the outlet is whitelisted |

Some examples of yaml configurations are provided in `/gutenberg/examples`.

#### Single vs. Multiple Sale Outlets

OriginByte's launchpad configurations allow creators to segregate their NFT sales into tiers, with each tier having its own price and whitelisting settings.

Here is an example of a single sale configuration:

```yaml
Launchpad:
  market_type: "fixed_price"
  prices: [1000]
  whitelists: [false]
```

Whilst a multi sale configuration is:

```yaml
Launchpad:
  market_type: "auction"
  reserve_prices: [1000, 2000, 3000, 4000]
  whitelists: [false, true, true, true]
```

### 2. Run Gutenberg

Once your YAML configuration file is ready, it’s then time to run the Gutenberg executable.

```shell
gutenberg
```

This will use a configuration file, `./config.yaml`, and write the Move contract to `../examples/<MODULE_NAME>.move` by default.

To define a custom configuration and output path one can run the following command:

```shell
gutenberg --config <CONFIGURATION_PATH>/<CONFIG>.yaml <CUSTOM_PATH>/<FILENAME>.move
```

You can obtain a `gutenberg` executable by building it using [cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html) and running the following commands, or using `cargo run` directly:

```shell
cd gutenberg
cargo build --release
```

Alternatively, you can [download a pre-built executable](https://github.com/Origin-Byte/nft-protocol/tags) once these become available.

### 3. Deploy the Contract

To deploy your newly created smart contract follow the deploy instructions found in [docs/deploy](../docs/deploy.md).
