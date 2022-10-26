- Sui v0.12.1

# Install

This codebase requires installation of the [Sui CLI](https://docs.sui.io/build/install).

# Built and Test

1. `$ cargo build` to build the gutenberg
2. `$ cargo run` to run the gutenberg and build the move module
3. `./bin/publish.sh` to publish the modules on localnet or devnet // TODO

# Gutenberg

A templating engine to write Move modules for NFT Collections.

In the spirit of the design philosophy presented in this [RFC](https://github.com/MystenLabs/sui/blob/a49613a52d1556386464be7d138c379773f35499/sui_programmability/examples/nft_standard/README.md), NFTs of a given NFT Collection have their own type exported Move module.

What this means in practice is that creators will have to deploy their own Move module every time they want to create a new NFT collection. We do not expect NFT creators to have to deal with the technical details of writing a Move smart contract, therefore Gutenberg's purpose is to automagically write the Move smart contract on behalf of the NFT creator.

We describe the process to configure the NFT collection and run Gutenberg in the following steps.

### 1. Configure the NFT Collection

To configure the NFT collection, the creator will have to populate the file `gutenberg/config.yaml`, which has the following structure:

```
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
  market_type:
  prices: []
  whitelists: []
```

The top-level fields are defined as follows:

| Field            | Type          | Description |
| ---------------- | ------------- | ---------------- |
| `NftType`        | `String`      | Acts as an Enum for all the NftTypes available in OriginByte ("Unique", "Collectibles" & "CNft") |
| `Collection`     | `Dictionary`  | List of fields defining the collection |
| `Launchpad`      | `Dictionary`  | List of fields defining the launchpad |

Where the fields for the Collection are:

| Field            | Type      | Description |
| ---------------- | --------- | ---------------- |
| name            | `String`   | The name of the collection |
| description     | `String`   | The description of the collection |
| symbol          | `String`   | The symbol/ticker of the collection |
| max_supply      | `Integer`  | The total supply of the collection |
| receiver        | `String`   | Address that receives the sale and royalty proceeds |
| tags            | `List`     | A set of strings that categorize the domain in which the NFT operates |
| royalty_fee_bps | `Integer`  | The royalty fees creators accumulate on the sale of NFTs |
| is_mutable      | `Boolean`  | A configuration field that dictates whether NFTs are mutable |
| data            | `String`   | Field for extra data |

And where the fields for the Launchpad are:

| Field            | Type      | Description |
| ---------------- | --------- | ---------------- |
| market_type      | `String`           | Acts as an Enum for all the market types available in OriginByte (currently only "fixed_price") |
| prices           | `Array<Integer>`   | Array of prices for all sale outlets |
| whitelists       | `Array<Boolean>`   | Array of whitelisting setup for all sale outlets |


Some examples of yaml configurations are provided in `/gutenberg/examples`.

#### Single vs. Multiple Sale Outlets

OriginByte's launchpad configuration allows creators to segregage their NFT sales into tiers, having each tier its own price and whitelisting settings.

An example of a single sale configuration follows:

```
Launchpad:
  market_type: "fixed_price"
  prices: [1000]
  whitelists: [false]
```

Whilst a multi sale configuration is:

```
Launchpad:
  market_type: "fixed_price"
  prices: [1000, 2000, 3000, 4000, 5000]
  whitelists: [false, true, true, true]
```

### 2. Run Gutenberg

Once the yaml configuration file is correctly populated it is time to run Gutenberg via:

`cd gutenberg/`
`cargo run`

By default the Move module will be written in `../sources/examples/<MODULE_NAME>.move`

To define a custom path and file name one can run the following command:
`cargo run ../<CUSTOM_PATH>/<FILENAME>.move`

### 3. Deploy the Contract

To deploy the newly created smart contract in conjunction to the NFT protocol, run the following sh script from the parent folder:

`./bin/publish.sh`

Please note that in the current version, the NFT protocol modules will themselves be deployed along with the newly created NFT module, however in the upcoming version of this tool, the newly created NFT module will tap into a readily deployed contract on-chain.

To publish the module on-chain, one will require to have a .env file with the field `GAS` with an object ID of Gas object. To enquire the CLI as to what GAS object IDs one can use you will need to have the Sui cli installed as well as having and active address and be connected to the DevNet. To check for the a Gas object ID please run `sui client gas`. Please also note that your active address should be funded via the faucet, and therefore it should have SUI coin balance available.
