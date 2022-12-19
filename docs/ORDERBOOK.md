# Orderbook

Orderbook implementation where bids are fungible tokens and asks are NFTs.
A bid is a request to buy one NFT from a specific collection.
An ask is one NFT with a min price condition.

`Ask` is an object which is associated with a single NFT.
When `Ask` is created, we transfer the ownership of the NFT to this new object.
To be more precise, we transfer the `safe::TransferCap`.

One can:

- create a new orderbook between a given collection and a BID token (witness
  pattern protected)
- set publicly accessible actions to be witness protected
- open a new BID
- cancel an existing BID they own
- offer an NFT if a collection matches OB collection
- cancel an existing NFT offer
- instantly buy a specific NFT

# Intermediary state

By working with `Safe`, clients must know _up front_ which exact `Safe`
instance to provide into the entry methods for transferring an NFT.
However, OB concept supports frequent trades with `create_ask` and `create_bid`
endpoints.
In frequent trades, the NFT changes fast and therefore the `Safe` instance
cannot reliably be known in advance.
The problem can be summarized as follows:

1. The client has to fetch the OB state to know what's the lowest ask, because
   that determines what `Safe` to include in a tx to create a new bid.
2. The client then has to send the tx. If lowest ask changed, the tx fails.
   The client has to retry.
3. The client is interested in any collection's NFT, yet it observes failures
   due to abstraction leak.

This problem is solved by introducing an intermediary state.
When a trade is executed we create new `TradeIntermediate` shared object.
This object contains `TransferCap` for the NFT and paid balance.
A permission-less endpoint `finish_trade` must be called with the buyer's and
the seller's `Safe` objects as arguments.
The `TradeIntermediate` is a shared object so that both parties can actually
drive the trade to completion.

# Commission

When a bid or an ask is created via a wallet or a marketplace, the client can
use `create_bid_with_commission` or `create_ask_with_commission` endpoints.
These endpoints have two additional arguments: `beneficiary` address
and `commission_ft` amount.

Creating a bid with a commission amount will take this amount from the buyer's
wallet and lock them along with the funds they are bidding with.
Once the bid is matched, then the locked commission funds are instantly
transferred to the beneficiary address.

Creating an ask with a commission amount will take the amount from the seller's
reward for the NFT.
For example, if an NFT is sold for 10 SUI and commission was 2 SUI, then the
NFT seller receives 8 SUI and the beneficiary receives 2 SUI.
Once the ask is matched, then the commission funds are _eventually_ transferred
to the beneficiary address.
See the [documentation](#intermediary-state) for the intermediary state above.
The commission is paid to the beneficiary only after the intermediary state
have been resolved.

To receive a commission on an instant NFT buy (when buying a specific NFT)
the client can use a batched tx to get their commission.
Hence, we don't export a `buy_with_commission` endpoint.

If there are two different marketplaces facilitating a single trade, both can
claim a commission.
Marketplace A would earn a commission from the buyer (on the bid) and
marketplace B would earn a commission from the seller (on the ask.)

# Witness protected actions

The contract which creates the orderbook can restrict specific actions to be
called only with a witness pattern and not via the entry point function.
This means others can build contracts on top of the orderbook with their own
custom logic based on their requirements or they can just use the entry point
functions that cover other use cases.

If a method is protected, clients will need to call a standard endpoint in the
witness-owning smart contract instead of the relevant endpoint in the orderbook.
Another way to think about this from a marketplace or wallet POV:
if I see that an action is protected, I can decide to either call the downstream
implementation in the collection smart contract, or simply disable that specific
action.

An example of this would be an NFT which has an expiry date like a name service
which requires an additional check before an ask can be placed on the orderbook.
Marketplaces can choose to support this additional logic or simply use the
standard orderbook and enable bids but asks would be disabled until they decide
to support the additional checks.

The setting is stored on the orderbook object:

```move
struct WitnessProtectedActions has store {
    buy_nft: bool,
    cancel_ask: bool,
    cancel_bid: bool,
    create_ask: bool,
    create_bid: bool,
}
```

This means that the additional complexity is _(i)_ opt-in by the collection and
_(ii)_ reserved only to the particular action which warrants that complexity.

To reiterate, a marketplace can list NFTs from collections that have all
actions unprotected, ie. no special logic.
Or they can just disable that particular action that is disabled in the UI.

# Endpoints

- `C` is a generic for the NFT collection
- `FT` is a generic for the fungible token

To create a new instance of an orderbook which trades given collection for given
fungible token call the following endpoint:

```move
create<C, FT>()
```

To create a new bid, the client provides the `Safe` into which they wish to
receive an NFT.
They provide the price in the smallest unit of the fungible token.
This amount will be taken from the provided `Coin` wallet.

This endpoint will either store a new bid in the orderbook, or it will match
the bid with an existing ask thereby executing the trade.

In such a case, a new shared object [`TradeIntermediate`](#intermediary-state)
is created.

```move
create_bid<C, FT>(
  book: &mut Orderbook<C, FT>,
  buyer_safe: &mut Safe,
  price: u64,
  wallet: &mut Coin<FT>,
)
```

In addition to the above, the client can ask for a [commission](#commission)
when they create the bid on behalf of the signer.

```move
create_bid_with_commission<C, FT>(
  book,
  buyer_safe,
  price: u64,
  beneficiary: address,
  commission_ft: u64,
  wallet,
)
```

To cancel an existing bid, the client gives the price they sent as an input in
the previous endpoint.
If there are multiple bids the tx sender has created with the same price, then
only one is cancelled.

```move
cancel_bid<C, FT>(
  book,
  bid_price_level: u64,
  wallet,
)
```

To create a new ask, the client provides the `Safe` in which the NFT lives.
They provide the price in the smallest unit of the fungible token they wish
to sell their NFT for.
They must also provide the _exclusive_ `TransferCap` for the NFT.
See the `Safe` documentation for more details on how to obtain this object.

```move
create_ask<C, FT>(
  book,
  requested_tokens: u64,
  transfer_cap: TransferCap,
  safe,
)
```

Additionally, the client can ask for a [commission](#commission).
When the ask is matched, the commission is paid to the beneficiary address.
The commission is taken from the seller's reward for the NFT.
Hence, `requested_tokens` must be greater than `commission_ft`.

```move
create_ask_with_commission<C, FT>(
  book,
  requested_tokens: u64,
  transfer_cap,
  beneficiary: address,
  commission: u64,
  safe,
)
```

To cancel an offer on a specific NFT, the client provides the price they listed
it for.
In theory, it should be enough to provide the NFT ID.
However, in the current version, it's more efficient to search the orderbook
state by price.
This argument can be argued to be a leaky abstraction and might be removed in
future versions.
The `TransferCap` object is transferred back to the tx sender.

```move
cancel_ask<C, FT>(
  book,
  nft_price_level: u64,
  nft_id: ID,
)
```

To buy a specific NFT listed in the orderbook, the client provides the price
for which the NFT is listed.
In this case, it's important to provide both the price and NFT ID to avoid
actions such as offering an NFT for really low price and then quickly changing
the price to a higher one.
The provided `Coin` wallet is used to pay for the NFT.
The NFT is transferred from the seller's `Safe` to the buyer's `Safe`.
The whitelist is used to check if the orderbook is authorized to trade the
collection at all.
See the [whitelist](WHITELIST.md) documentation for more information.
This endpoint does _not_ create a new `TradeIntermediate`, rather performs the
transfer straight away.

```move
buy_nft<C, FT>(
  book,
  nft_id,
  price: u64,
  wallet,
  seller_safe,
  buyer_safe,
  whitelist: &Whitelist,
  ctx: &mut TxContext,
)
```

Settles a trade by transferring the NFT from the seller's `Safe` to the buyer's
`Safe`.
See the [whitelist](WHITELIST.md) documentation for more information.
This endpoint does _not_ create a new `TradeIntermediate`, rather performs the
transfer straight away.

```move
finish_trade<C, FT>(
    trade: &mut TradeIntermediate<C, FT>,
    seller_safe,
    buyer_safe,
    whitelist,
)
```
