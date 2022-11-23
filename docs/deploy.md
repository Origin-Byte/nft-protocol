# Deploying OriginByte contracts

To deploy your newly created smart contract in conjunction with the NFT protocol, run the following sh script from the parent folder:

`./bin/publish.sh`

Please note that in the current version, the NFT protocol modules will themselves be deployed along with the newly created NFT module. However, in the upcoming version of this tool, newly created NFT modules will tap into a readily deployed contract on-chain.

To publish the module on-chain, you’ll be required to have a .env file with the field `GAS` and an object ID of the Gas object. To enquire the CLI on what GAS object IDs can be used, you’ll need to be connected to the DevNet, have an active address, and also have the Sui CLI installed. To check for the Gas object ID, run `sui client gas`. Please also note that your active address should be funded via the faucet, and therefore it should have a SUI coin balance available.
