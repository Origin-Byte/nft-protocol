# Off-chain listing

The default way of listing an NFT is to use a client such as a wallet.
The client implements the API of some trading contract.
The API is going to differ contract to contract.

We explore a pattern which shifts complexity from clients to the trading contracts maintainers.
The clients, such as wallets or marketplaces, only need to know an address of a trading contract.
They don't have to implement the interface (`entry fun`) of the trading contract to list an NFT.

# Suggested implementation

A contract is built on top of [`Safe`][rfc-safe] as part of the protocol.
It contains a map between a witness type and `TransferCap`.
An NFT seller's client can call a known `entry fun list()` in this contract.
The trading contract then takes ownership over the `TransferCap` at a later stage in another transaction.
The important point here is that the trading contract maintainer sets up an off-chain service.
The service listens to listing events.
It knows the interface implementation of the trading contract for updating its state.

For example, two different auction contracts both have different NFT listing implementations.
With this pattern, clients don't have to care about that interface.
Listing (and de-listing) is done via the same client call.

# Pseudo code

- The map from witness type to `TransferCap`

```move
struct Listing<TradingContractWitness> {
    transfer_cap: safe::TransferCap,
}
```

- Client's call to list an NFT

```move
public entry fun list<TradingContractWitness: drop>(
    transfer_cap: safe::TransferCap,
    ctx: &mut TxContext,
);
```

- Trading contract's call to take ownership of the `TransferCap`

```move
public fun take<TradingContractWitness: drop>(
    _witness: TradingContractWitness,
    listing: &mut Listing<TradingContractWitness>,
): safe::TransferCap;
```

# Further discussion

1. It might be useful (as suggested [here][rfc-safe-uid]) to also enable
   whitelisting with a `&mut UID` pattern, not only with a witness.

2. Clients that list NFTs this way will naturally see a delay to the actual listing in the trading contract.
   As opposed to if they implemented the interface themselves.

3. How do we enable commissions with this pattern is yet to be explored.

<!-- List of References -->

[rfc-safe]: https://github.com/Origin-Byte/nft-protocol/pull/66
[rfc-safe-uid]: https://github.com/Origin-Byte/nft-protocol/pull/66/files#diff-79dfbca015b147c12926127e357acee6ae5afc9f203a4d5eaec9dda6f4618229R144
