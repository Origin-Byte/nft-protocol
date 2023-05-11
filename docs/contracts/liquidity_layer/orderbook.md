
<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook"></a>

# Module `0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788::orderbook`

Orderbook where bids are fungible tokens and asks are NFTs.
A bid is a request to buy one NFT from a specific collection.
An ask is one NFT with a min price condition.

One can
- create a new orderbook between a given collection and a bid token;
- set publicly accessible actions to be witness protected;
- open a new bid;
- cancel an existing bid they own;
- offer an NFT if collection matches OB collection;
- cancel an existing NFT offer;
- instantly buy a specific NFT;
- open bids and asks with a commission on behalf of a user;
- edit positions;
- trade both native and 3rd party collections.


<a name="@Other_resources_0"></a>

## Other resources

- https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook
- https://origin-byte.github.io/orderbook.html


-  [Other resources](#@Other_resources_0)
-  [Struct `Witness`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Witness)
-  [Struct `TradeIntermediateDfKey`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediateDfKey)
-  [Resource `Orderbook`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook)
-  [Struct `WitnessProtectedActions`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_WitnessProtectedActions)
    -  [Important](#@Important_1)
-  [Struct `Bid`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Bid)
-  [Struct `Ask`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask)
-  [Resource `TradeIntermediate`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate)
-  [Struct `TradeInfo`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo)
-  [Struct `OrderbookCreatedEvent`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_OrderbookCreatedEvent)
-  [Struct `AskCreatedEvent`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_AskCreatedEvent)
-  [Struct `AskClosedEvent`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_AskClosedEvent)
-  [Struct `BidCreatedEvent`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_BidCreatedEvent)
-  [Struct `BidClosedEvent`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_BidClosedEvent)
-  [Struct `TradeFilledEvent`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeFilledEvent)
-  [Constants](#@Constants_2)
-  [Function `new`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new)
-  [Function `new_unprotected`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_unprotected)
-  [Function `create`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create)
-  [Function `create_unprotected`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_unprotected)
-  [Function `init_orderbook`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_init_orderbook)
-  [Function `init_unprotected_orderbook`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_init_unprotected_orderbook)
-  [Function `new_external`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_external)
-  [Function `create_external`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_external)
-  [Function `init_external`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_init_external)
-  [Function `new_`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_)
-  [Function `create_bid`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid)
-  [Function `create_bid_protected`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_protected)
-  [Function `create_bid_with_commission`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_with_commission)
-  [Function `create_bid_with_commission_protected`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_with_commission_protected)
-  [Function `market_buy`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_market_buy)
-  [Function `cancel_bid`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid)
-  [Function `cancel_ask`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_ask)
-  [Function `create_ask`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask)
-  [Function `create_ask_protected`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_protected)
-  [Function `create_ask_with_commission`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_with_commission)
-  [Function `create_ask_with_commission_protected`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_with_commission_protected)
-  [Function `market_sell`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_market_sell)
-  [Function `edit_ask`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_edit_ask)
-  [Function `edit_bid`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_edit_bid)
-  [Function `buy_nft`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_buy_nft)
-  [Function `buy_nft_protected`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_buy_nft_protected)
-  [Function `finish_trade`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_finish_trade)
-  [Function `finish_trade_if_kiosks_match`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_finish_trade_if_kiosks_match)
-  [Function `change_tick_size`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_change_tick_size)
-  [Function `change_tick_size_with_witness`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_change_tick_size_with_witness)
-  [Function `set_protection`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_set_protection)
-  [Function `set_protection_with_witness`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_set_protection_with_witness)
-  [Function `disable_trading`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_disable_trading)
-  [Function `enable_trading`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_enable_trading)
-  [Function `borrow_bids`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_borrow_bids)
-  [Function `bid_offer`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_bid_offer)
-  [Function `bid_owner`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_bid_owner)
-  [Function `borrow_asks`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_borrow_asks)
-  [Function `ask_price`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ask_price)
-  [Function `ask_owner`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ask_owner)
-  [Function `is_create_ask_protected`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_is_create_ask_protected)
-  [Function `is_create_bid_protected`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_is_create_bid_protected)
-  [Function `is_buy_nft_protected`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_is_buy_nft_protected)
-  [Function `trade_id`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_trade_id)
-  [Function `trade_price`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_trade_price)
-  [Function `trade`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_trade)
-  [Function `create_bid_`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_)
-  [Function `match_buy_with_ask_`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_match_buy_with_ask_)
-  [Function `match_sell_with_bid_`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_match_sell_with_bid_)
-  [Function `cancel_bid_except_commission`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid_except_commission)
-  [Function `cancel_bid_`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid_)
-  [Function `edit_bid_`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_edit_bid_)
-  [Function `create_ask_`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_)
-  [Function `cancel_ask_`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_ask_)
-  [Function `buy_nft_`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_buy_nft_)
-  [Function `finish_trade_`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_finish_trade_)
-  [Function `remove_ask`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_remove_ask)
-  [Function `assert_tick_level`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_tick_level)
-  [Function `check_tick_level`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_check_tick_level)
-  [Function `assert_version`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_version)
-  [Function `migrate_as_creator`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_migrate_as_creator)
-  [Function `migrate_as_pub`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_migrate_as_pub)


<pre><code><b>use</b> <a href="">0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::witness</a>;
<b>use</b> <a href="">0x1::ascii</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::type_name</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x2::balance</a>;
<b>use</b> <a href="">0x2::coin</a>;
<b>use</b> <a href="">0x2::dynamic_field</a>;
<b>use</b> <a href="">0x2::event</a>;
<b>use</b> <a href="">0x2::kiosk</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::package</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::transfer_policy</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="init.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_liquidity_layer">0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788::liquidity_layer</a>;
<b>use</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading">0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788::trading</a>;
<b>use</b> <a href="">0x5fb957b59e6b093c17eb3f0ca0a3e8762530244f39f738bd356dbdd43ed9230e::critbit_u64</a>;
<b>use</b> <a href="">0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk</a>;
<b>use</b> <a href="">0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request</a>;
<b>use</b> <a href="">0xffe9703dc31c17b294c37b2ffae7815b197d3e823bbb9f9b9f285f60afb524f2::fee_balance</a>;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Witness"></a>

## Struct `Witness`

Add this witness type to allowlists via
<code>transfer_allowlist::insert_authority</code> to allow orderbook trades with
that allowlist.


<pre><code><b>struct</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Witness">Witness</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>dummy_field: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediateDfKey"></a>

## Struct `TradeIntermediateDfKey`



<pre><code><b>struct</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediateDfKey">TradeIntermediateDfKey</a>&lt;T, FT&gt; <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>trade_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook"></a>

## Resource `Orderbook`

A critbit order book implementation. Contains two ordered trees:
1. bids ASC
2. asks DESC


<pre><code><b>struct</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T: store, key, FT&gt; <b>has</b> store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="_UID">object::UID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>version: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>tick_size: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>protected_actions: <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_WitnessProtectedActions">orderbook::WitnessProtectedActions</a></code>
</dt>
<dd>
 Actions which have a flag set to true can only be called via a
 witness protected implementation.
</dd>
<dt>
<code>asks: <a href="_CritbitTree">critbit_u64::CritbitTree</a>&lt;<a href="">vector</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">orderbook::Ask</a>&gt;&gt;</code>
</dt>
<dd>
 An ask order stores an NFT to be traded. The price associated with
 such an order is saying:

 > for this NFT, I want to receive at least this amount of FT.
</dd>
<dt>
<code>bids: <a href="_CritbitTree">critbit_u64::CritbitTree</a>&lt;<a href="">vector</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Bid">orderbook::Bid</a>&lt;FT&gt;&gt;&gt;</code>
</dt>
<dd>
 A bid order stores amount of tokens of type "B"(id) to trade. A bid
 order is saying:

 > for any NFT in this collection, I will spare this many tokens
</dd>
<dt>
<code>transfer_signer: <a href="_UID">object::UID</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_WitnessProtectedActions"></a>

## Struct `WitnessProtectedActions`

The contract which creates the orderbook can restrict specific actions
to be only callable with a witness pattern and not via the entry point
function.

This means contracts can build on top of this orderbook their custom
logic if they desire so, or they can just use the entry point functions
which might be good enough for most use cases.


<a name="@Important_1"></a>

### Important

If a method is protected, then clients call instead of the relevant
endpoint in the orderbook a standardized endpoint in the witness-owning
smart contract.

Another way to think about this from marketplace or wallet POV:
If I see that an action is protected, I can decide to either call
the downstream implementation in the collection smart contract, or just
not enable to perform that specific action at all.

We don't restrict canceling positions to protect the users.


<pre><code><b>struct</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_WitnessProtectedActions">WitnessProtectedActions</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>buy_nft: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>create_ask: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>create_bid: bool</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Bid"></a>

## Struct `Bid`

An offer for a single NFT in a collection.


<pre><code><b>struct</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Bid">Bid</a>&lt;FT&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>offer: <a href="_Balance">balance::Balance</a>&lt;FT&gt;</code>
</dt>
<dd>
 How many token are being offered by the order issuer for one NFT.
</dd>
<dt>
<code>owner: <b>address</b></code>
</dt>
<dd>
 The address of the user who created this bid and who will receive an
 NFT in exchange for their tokens.
</dd>
<dt>
<code><a href="">kiosk</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 Points to <code>Kiosk</code> shared object into which to deposit NFT.
</dd>
<dt>
<code>commission: <a href="_Option">option::Option</a>&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;&gt;</code>
</dt>
<dd>
 If the NFT is offered via a marketplace or a wallet, the
 facilitator can optionally set how many tokens they want to claim
 on top of the offer.
</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask"></a>

## Struct `Ask`

Object which is associated with a single NFT.

When [<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">Ask</a></code>] is created, we transfer the ownership of the NFT to this
new object.
When an ask is matched with a bid, we transfer the ownership of the
[<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">Ask</a></code>] object to the bid owner (buyer).
The buyer can then claim the NFT via [<code>claim_nft</code>] endpoint.


<pre><code><b>struct</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">Ask</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>price: u64</code>
</dt>
<dd>
 How many tokens does the seller want for their NFT in exchange.
</dd>
<dt>
<code>nft_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 ID of the respective NFT object
</dd>
<dt>
<code>kiosk_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 ID of the respective kiosk
</dd>
<dt>
<code>owner: <b>address</b></code>
</dt>
<dd>
 Who owns the NFT.
</dd>
<dt>
<code>commission: <a href="_Option">option::Option</a>&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">trading::AskCommission</a>&gt;</code>
</dt>
<dd>
 If the NFT is offered via a marketplace or a wallet, the
 facilitator can optionally set how many tokens they want to claim
 from the price of the NFT for themselves as a commission.
</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate"></a>

## Resource `TradeIntermediate`

<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a></code> is made a shared object and can be called in a
permissionless transaction <code>finish_trade</code>.


<pre><code><b>struct</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a>&lt;T, FT&gt; <b>has</b> store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="_UID">object::UID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>nft_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>seller: <b>address</b></code>
</dt>
<dd>
 Who receives the funds
</dd>
<dt>
<code>seller_kiosk: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 Where can we find the NFT
</dd>
<dt>
<code>buyer: <b>address</b></code>
</dt>
<dd>
 Who pays
</dd>
<dt>
<code>buyer_kiosk: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 Where to deposit the NFT
</dd>
<dt>
<code>paid: <a href="_Balance">balance::Balance</a>&lt;FT&gt;</code>
</dt>
<dd>
 From buyer to seller
</dd>
<dt>
<code>commission: <a href="_Option">option::Option</a>&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">trading::AskCommission</a>&gt;</code>
</dt>
<dd>
 From the <code>paid</code> amount we deduct commission
</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo"></a>

## Struct `TradeInfo`

Helper struct to be used on the client side. Helps the client side
to identity the trade_id which is needed to call <code>finish_trade</code>


<pre><code><b>struct</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>trade_price: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>trade_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_OrderbookCreatedEvent"></a>

## Struct `OrderbookCreatedEvent`



<pre><code><b>struct</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_OrderbookCreatedEvent">OrderbookCreatedEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>nft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>ft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_AskCreatedEvent"></a>

## Struct `AskCreatedEvent`



<pre><code><b>struct</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_AskCreatedEvent">AskCreatedEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>nft: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>owner: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>price: u64</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">kiosk</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>nft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>ft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_AskClosedEvent"></a>

## Struct `AskClosedEvent`

When de-listed, not when sold!


<pre><code><b>struct</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_AskClosedEvent">AskClosedEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>nft: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>owner: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>price: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>nft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>ft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_BidCreatedEvent"></a>

## Struct `BidCreatedEvent`



<pre><code><b>struct</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_BidCreatedEvent">BidCreatedEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>owner: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>price: u64</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">kiosk</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>nft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>ft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_BidClosedEvent"></a>

## Struct `BidClosedEvent`

When de-listed, not when bought!


<pre><code><b>struct</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_BidClosedEvent">BidClosedEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>owner: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">kiosk</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>price: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>nft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>ft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeFilledEvent"></a>

## Struct `TradeFilledEvent`

Either an ask is created and immediately matched with a bid, or a bid
is created and immediately matched with an ask.
In both cases [<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeFilledEvent">TradeFilledEvent</a></code>] is emitted.
In such case, the property <code>trade_intermediate</code> is <code>Some</code>.

If the NFT was bought directly (<code>buy_nft</code>), then
the property <code>trade_intermediate</code> is <code>None</code>.


<pre><code><b>struct</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeFilledEvent">TradeFilledEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>buyer_kiosk: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>buyer: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>nft: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>price: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>seller_kiosk: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>seller: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>trade_intermediate: <a href="_Option">option::Option</a>&lt;<a href="_ID">object::ID</a>&gt;</code>
</dt>
<dd>
 Is <code>None</code> if the NFT was bought directly (<code>buy_nft</code>)

 Is <code>Some</code> if the NFT was bought via <code>create_bid</code> or <code>create_ask</code>.
</dd>
<dt>
<code>nft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>ft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_2"></a>

## Constants


<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ENotUpgraded"></a>



<pre><code><b>const</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ENotUpgraded">ENotUpgraded</a>: u64 = 999;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EWrongVersion"></a>



<pre><code><b>const</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EWrongVersion">EWrongVersion</a>: u64 = 1000;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_VERSION"></a>



<pre><code><b>const</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_VERSION">VERSION</a>: u64 = 1;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_DEFAULT_TICK_SIZE"></a>



<pre><code><b>const</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_DEFAULT_TICK_SIZE">DEFAULT_TICK_SIZE</a>: u64 = 1000000;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EActionNotPublic"></a>

A protected action was called without a witness.
This action can only be called from an implementation in the collection
smart contract.


<pre><code><b>const</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EActionNotPublic">EActionNotPublic</a>: u64 = 1;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ECannotTradeWithSelf"></a>

The NFT lives in a kiosk which also wanted to buy it


<pre><code><b>const</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ECannotTradeWithSelf">ECannotTradeWithSelf</a>: u64 = 3;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ECommissionTooHigh"></a>

Cannot make sell commission higher than listed price


<pre><code><b>const</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ECommissionTooHigh">ECommissionTooHigh</a>: u64 = 2;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EKioskIdMismatch"></a>

Expected different kiosk


<pre><code><b>const</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EKioskIdMismatch">EKioskIdMismatch</a>: u64 = 5;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EMarketOrderNotFilled"></a>

Market orders fail with this error if they cannot be filled


<pre><code><b>const</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EMarketOrderNotFilled">EMarketOrderNotFilled</a>: u64 = 6;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ENotExternalPolicy"></a>

Trying to access an endpoint for creating an orderbook for collections
that are external to the OriginByte ecosystem, without itself being external


<pre><code><b>const</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ENotExternalPolicy">ENotExternalPolicy</a>: u64 = 8;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ENotOriginBytePolicy"></a>

Trying to create an orderbook via a witness protected endpoint
without TransferPolicy being registered with OriginByte


<pre><code><b>const</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ENotOriginBytePolicy">ENotOriginBytePolicy</a>: u64 = 7;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EOrderDoesNotExist"></a>

No order matches the given price level or ownership level


<pre><code><b>const</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EOrderDoesNotExist">EOrderDoesNotExist</a>: u64 = 6;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EOrderOwnerMustBeSender"></a>

User doesn't own this order


<pre><code><b>const</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EOrderOwnerMustBeSender">EOrderOwnerMustBeSender</a>: u64 = 4;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new"></a>

## Function `new`

Create a new <code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;</code>

To implement specific logic in your smart contract, you can toggle the
protection on specific actions. That will make them only accessible via
witness protected methods.


<a name="@Panics_3"></a>

###### Panics


Panics if <code>TransferPolicy&lt;T&gt;</code> is not an OriginByte policy.


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new">new</a>&lt;T: store, key, FT&gt;(_witness: <a href="_Witness">witness::Witness</a>&lt;T&gt;, <a href="">transfer_policy</a>: &<a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;, buy_nft: bool, create_ask: bool, create_bid: bool, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new">new</a>&lt;T: key + store, FT&gt;(
    _witness: DelegatedWitness&lt;T&gt;,
    <a href="">transfer_policy</a>: &TransferPolicy&lt;T&gt;,
    buy_nft: bool,
    create_ask: bool,
    create_bid: bool,
    ctx: &<b>mut</b> TxContext,
): <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt; {
    <b>assert</b>!(
        <a href="_is_originbyte">transfer_request::is_originbyte</a>(<a href="">transfer_policy</a>),
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ENotOriginBytePolicy">ENotOriginBytePolicy</a>,
    );

    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_">new_</a>(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_WitnessProtectedActions">WitnessProtectedActions</a> { buy_nft, create_ask, create_bid }, ctx)
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_unprotected"></a>

## Function `new_unprotected`

Create an unprotected new <code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;</code>

To implement specific logic in your smart contract, you can toggle the
protection on specific actions. That will make them only accessible via
witness protected methods.


<a name="@Panics_4"></a>

###### Panics


Panics if <code>TransferPolicy&lt;T&gt;</code> is not an OriginByte policy.


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_unprotected">new_unprotected</a>&lt;T: store, key, FT&gt;(<a href="">witness</a>: <a href="_Witness">witness::Witness</a>&lt;T&gt;, <a href="">transfer_policy</a>: &<a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_unprotected">new_unprotected</a>&lt;T: key + store, FT&gt;(
    <a href="">witness</a>: DelegatedWitness&lt;T&gt;,
    <a href="">transfer_policy</a>: &TransferPolicy&lt;T&gt;,
    ctx: &<b>mut</b> TxContext
): <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt; {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new">new</a>&lt;T, FT&gt;(<a href="">witness</a>, <a href="">transfer_policy</a>, <b>false</b>, <b>false</b>, <b>false</b>, ctx)
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create"></a>

## Function `create`

Create a new <code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;</code> and immediately share it, returning
it's ID


<a name="@Panics_5"></a>

###### Panics


Panics if <code>TransferPolicy&lt;T&gt;</code> is not an OriginByte policy.


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create">create</a>&lt;T: store, key, FT&gt;(<a href="">witness</a>: <a href="_Witness">witness::Witness</a>&lt;T&gt;, <a href="">transfer_policy</a>: &<a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;, buy_nft: bool, create_ask: bool, create_bid: bool, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create">create</a>&lt;T: key + store, FT&gt;(
    <a href="">witness</a>: DelegatedWitness&lt;T&gt;,
    <a href="">transfer_policy</a>: &TransferPolicy&lt;T&gt;,
    buy_nft: bool,
    create_ask: bool,
    create_bid: bool,
    ctx: &<b>mut</b> TxContext,
): ID {
    <b>let</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a> = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new">new</a>&lt;T, FT&gt;(
        <a href="">witness</a>, <a href="">transfer_policy</a>, buy_nft, create_ask, create_bid, ctx,
    );
    <b>let</b> orderbook_id = <a href="_id">object::id</a>(&<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>);
    <a href="_share_object">transfer::share_object</a>(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>);
    orderbook_id
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_unprotected"></a>

## Function `create_unprotected`

Create a new unprotected <code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;</code> and immediately share it
returning it's ID


<a name="@Panics_6"></a>

###### Panics


Panics if <code>TransferPolicy&lt;T&gt;</code> is not an OriginByte policy.


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_unprotected">create_unprotected</a>&lt;T: store, key, FT&gt;(<a href="">witness</a>: <a href="_Witness">witness::Witness</a>&lt;T&gt;, <a href="">transfer_policy</a>: &<a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_unprotected">create_unprotected</a>&lt;T: key + store, FT&gt;(
    <a href="">witness</a>: DelegatedWitness&lt;T&gt;,
    <a href="">transfer_policy</a>: &TransferPolicy&lt;T&gt;,
    ctx: &<b>mut</b> TxContext
): ID {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create">create</a>&lt;T, FT&gt;(<a href="">witness</a>, <a href="">transfer_policy</a>, <b>false</b>, <b>false</b>, <b>false</b>, ctx)
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_init_orderbook"></a>

## Function `init_orderbook`

Create a new <code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;</code> and immediately share it


<a name="@Panics_7"></a>

###### Panics


Panics if <code>TransferPolicy&lt;T&gt;</code> is not an OriginByte policy.


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_init_orderbook">init_orderbook</a>&lt;T: store, key, FT&gt;(publisher: &<a href="_Publisher">package::Publisher</a>, <a href="">transfer_policy</a>: &<a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;, buy_nft: bool, create_ask: bool, create_bid: bool, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_init_orderbook">init_orderbook</a>&lt;T: key + store, FT&gt;(
    publisher: &Publisher,
    <a href="">transfer_policy</a>: &TransferPolicy&lt;T&gt;,
    buy_nft: bool,
    create_ask: bool,
    create_bid: bool,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create">create</a>&lt;T, FT&gt;(
        <a href="_from_publisher">witness::from_publisher</a>(publisher),
        <a href="">transfer_policy</a>,
        buy_nft,
        create_ask,
        create_bid,
        ctx,
    );
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_init_unprotected_orderbook"></a>

## Function `init_unprotected_orderbook`

Create a new unprotected <code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;</code> and immediately share it


<a name="@Panics_8"></a>

###### Panics


Panics if <code>TransferPolicy&lt;T&gt;</code> is not an OriginByte policy.


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_init_unprotected_orderbook">init_unprotected_orderbook</a>&lt;T: store, key, FT&gt;(publisher: &<a href="_Publisher">package::Publisher</a>, <a href="">transfer_policy</a>: &<a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_init_unprotected_orderbook">init_unprotected_orderbook</a>&lt;T: key + store, FT&gt;(
    publisher: &Publisher,
    <a href="">transfer_policy</a>: &TransferPolicy&lt;T&gt;,
    ctx: &<b>mut</b> TxContext
) {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_unprotected">create_unprotected</a>&lt;T, FT&gt;(
        <a href="_from_publisher">witness::from_publisher</a>(publisher), <a href="">transfer_policy</a>, ctx,
    );
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_external"></a>

## Function `new_external`

Create a new <code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;</code> for external <code>TransferPolicy</code>

To implement specific logic in your smart contract, you can toggle the
protection on specific actions. That will make them only accessible via
witness protected methods.


<a name="@Panics_9"></a>

###### Panics


Panics if <code>TransferPolicy&lt;T&gt;</code> is an OriginByte policy.


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_external">new_external</a>&lt;T: store, key, FT&gt;(<a href="">transfer_policy</a>: &<a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_external">new_external</a>&lt;T: key + store, FT&gt;(
    <a href="">transfer_policy</a>: &TransferPolicy&lt;T&gt;,
    ctx: &<b>mut</b> TxContext
): <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt; {
    <b>assert</b>!(
        !<a href="_is_originbyte">transfer_request::is_originbyte</a>(<a href="">transfer_policy</a>),
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ENotExternalPolicy">ENotExternalPolicy</a>,
    );

    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_">new_</a>&lt;T, FT&gt;(
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_WitnessProtectedActions">WitnessProtectedActions</a> {
            buy_nft: <b>false</b>,
            create_ask: <b>false</b>,
            create_bid: <b>false</b>,
        },
        ctx,
    )
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_external"></a>

## Function `create_external`

Create a new <code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;</code> for external <code>TransferPolicy</code> and
immediately share it returning its ID

To implement specific logic in your smart contract, you can toggle the
protection on specific actions. That will make them only accessible via
witness protected methods.


<a name="@Panics_10"></a>

###### Panics


Panics if <code>TransferPolicy&lt;T&gt;</code> is an OriginByte policy.


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_external">create_external</a>&lt;T: store, key, FT&gt;(<a href="">transfer_policy</a>: &<a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_external">create_external</a>&lt;T: key + store, FT&gt;(
    <a href="">transfer_policy</a>: &TransferPolicy&lt;T&gt;,
    ctx: &<b>mut</b> TxContext
): ID {
    <b>let</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a> = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_external">new_external</a>&lt;T, FT&gt;(<a href="">transfer_policy</a>, ctx);
    <b>let</b> orderbook_id = <a href="_id">object::id</a>(&<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>);
    <a href="_share_object">transfer::share_object</a>(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>);
    orderbook_id
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_init_external"></a>

## Function `init_external`

Create a new <code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;</code> for external <code>TransferPolicy</code> and
immediately share it

To implement specific logic in your smart contract, you can toggle the
protection on specific actions. That will make them only accessible via
witness protected methods.


<a name="@Panics_11"></a>

###### Panics


Panics if <code>TransferPolicy&lt;T&gt;</code> is an OriginByte policy.


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_init_external">init_external</a>&lt;T: store, key, FT&gt;(<a href="">transfer_policy</a>: &<a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_init_external">init_external</a>&lt;T: key + store, FT&gt;(
    <a href="">transfer_policy</a>: &TransferPolicy&lt;T&gt;,
    ctx: &<b>mut</b> TxContext
) {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_external">create_external</a>&lt;T, FT&gt;(<a href="">transfer_policy</a>, ctx);
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_"></a>

## Function `new_`

Create a new <code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;</code>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_">new_</a>&lt;T: store, key, FT&gt;(protected_actions: <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_WitnessProtectedActions">orderbook::WitnessProtectedActions</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_new_">new_</a>&lt;T: key + store, FT&gt;(
    protected_actions: <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_WitnessProtectedActions">WitnessProtectedActions</a>,
    ctx: &<b>mut</b> TxContext,
): <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt; {
    <b>let</b> id = <a href="_new">object::new</a>(ctx);

    <a href="_emit">event::emit</a>(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_OrderbookCreatedEvent">OrderbookCreatedEvent</a> {
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: <a href="_uid_to_inner">object::uid_to_inner</a>(&id),
        nft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;T&gt;()),
        ft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;FT&gt;()),
    });

    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt; {
        id,
        version: <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_VERSION">VERSION</a>,
        tick_size: <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_DEFAULT_TICK_SIZE">DEFAULT_TICK_SIZE</a>,
        protected_actions,
        asks: critbit::new(ctx),
        bids: critbit::new(ctx),
        transfer_signer: <a href="_new">object::new</a>(ctx)
    }
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid"></a>

## Function `create_bid`

How many (<code>price</code>) fungible tokens should be taken from sender's wallet
and put into the orderbook with the intention of exchanging them for
1 NFT.

If the <code>price</code> is higher than the lowest ask requested price, then we
execute a trade straight away.
In such a case, a new shared object [<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a></code>] is created.
Otherwise we add the bid to the orderbook's state.

The client provides the Kiosk into which they wish to receive an NFT.

* buyer kiosk must be in Originbyte ecosystem
* sender must be owner of buyer kiosk
* the buyer kiosk must allow deposits of <code>T</code>

Returns <code>Some</code> with amount if matched.
The amount is always equal or less than price.


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid">create_bid</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, price: u64, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Option">option::Option</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">orderbook::TradeInfo</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid">create_bid</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    buyer_kiosk: &<b>mut</b> Kiosk,
    price: u64,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): Option&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a>&gt; {
    <b>assert</b>!(!book.protected_actions.create_bid, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EActionNotPublic">EActionNotPublic</a>);
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_">create_bid_</a>&lt;T, FT&gt;(book, buyer_kiosk, price, <a href="_none">option::none</a>(), wallet, ctx)
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_protected"></a>

## Function `create_bid_protected`

Same as [<code>create_bid</code>] but protected by
[collection witness](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#witness-protected-actions).


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_protected">create_bid_protected</a>&lt;T: store, key, FT&gt;(_witness: <a href="_Witness">witness::Witness</a>&lt;T&gt;, book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, price: u64, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Option">option::Option</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">orderbook::TradeInfo</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_protected">create_bid_protected</a>&lt;T: key + store, FT&gt;(
    _witness: DelegatedWitness&lt;T&gt;,
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    buyer_kiosk: &<b>mut</b> Kiosk,
    price: u64,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): Option&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a>&gt; {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_">create_bid_</a>&lt;T, FT&gt;(book, buyer_kiosk, price, <a href="_none">option::none</a>(), wallet, ctx)
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_with_commission"></a>

## Function `create_bid_with_commission`

Same as [<code>create_bid</code>] but with a
[commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_with_commission">create_bid_with_commission</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, price: u64, beneficiary: <b>address</b>, commission_ft: u64, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Option">option::Option</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">orderbook::TradeInfo</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_with_commission">create_bid_with_commission</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    buyer_kiosk: &<b>mut</b> Kiosk,
    price: u64,
    beneficiary: <b>address</b>,
    commission_ft: u64,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): Option&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a>&gt; {
    <b>assert</b>!(!book.protected_actions.create_bid, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EActionNotPublic">EActionNotPublic</a>);
    <b>let</b> commission = <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_new_bid_commission">trading::new_bid_commission</a>(
        beneficiary,
        <a href="_split">balance::split</a>(<a href="_balance_mut">coin::balance_mut</a>(wallet), commission_ft),
    );
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_">create_bid_</a>&lt;T, FT&gt;(
        book, buyer_kiosk, price, <a href="_some">option::some</a>(commission), wallet, ctx,
    )
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_with_commission_protected"></a>

## Function `create_bid_with_commission_protected`

Same as [<code>create_bid_protected</code>] but with a
[commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_with_commission_protected">create_bid_with_commission_protected</a>&lt;T: store, key, FT&gt;(_witness: <a href="_Witness">witness::Witness</a>&lt;T&gt;, book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, price: u64, beneficiary: <b>address</b>, commission_ft: u64, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Option">option::Option</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">orderbook::TradeInfo</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_with_commission_protected">create_bid_with_commission_protected</a>&lt;T: key + store, FT&gt;(
    _witness: DelegatedWitness&lt;T&gt;,
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    buyer_kiosk: &<b>mut</b> Kiosk,
    price: u64,
    beneficiary: <b>address</b>,
    commission_ft: u64,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): Option&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a>&gt; {
    <b>let</b> commission = <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_new_bid_commission">trading::new_bid_commission</a>(
        beneficiary,
        <a href="_split">balance::split</a>(<a href="_balance_mut">coin::balance_mut</a>(wallet), commission_ft),
    );
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_">create_bid_</a>&lt;T, FT&gt;(
        book, buyer_kiosk, price, <a href="_some">option::some</a>(commission), wallet, ctx,
    )
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_market_buy"></a>

## Function `market_buy`

How many (<code>price</code>) fungible tokens should be taken from sender's wallet
and put into the orderbook with the intention of exchanging them for
1 NFT.

If the <code>price</code> is higher than the lowest ask requested price, then we
execute a trade straight away.
In such a case, a new shared object [<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a></code>] is created.
If market order is not filled, then the tx fails.

The client provides the Kiosk into which they wish to receive an NFT.

* buyer kiosk must be in Originbyte ecosystem
* sender must be owner of buyer kiosk
* the buyer kiosk must allow deposits of <code>T</code>

Returns the paid amount.


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_market_buy">market_buy</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, max_price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">orderbook::TradeInfo</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_market_buy">market_buy</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    buyer_kiosk: &<b>mut</b> Kiosk,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    max_price: u64,
    ctx: &<b>mut</b> TxContext,
): <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a> {
    <b>let</b> is_matched_with_price = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid">create_bid</a>(
        book, buyer_kiosk, max_price, wallet, ctx,
    );
    <b>assert</b>!(
        <a href="_is_some">option::is_some</a>(&is_matched_with_price),
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EMarketOrderNotFilled">EMarketOrderNotFilled</a>,
    );
    <a href="_destroy_some">option::destroy_some</a>(is_matched_with_price)
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid"></a>

## Function `cancel_bid`

Cancel a bid owned by the sender at given price. If there are two bids
with the same price, the one created later is cancelled.


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid">cancel_bid</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, bid_price_level: u64, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid">cancel_bid</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    bid_price_level: u64,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid_">cancel_bid_</a>(book, bid_price_level, wallet, ctx)
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_ask"></a>

## Function `cancel_ask`

To cancel an offer on a specific NFT, the client provides the price they
listed it for.


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_ask">cancel_ask</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, seller_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_price_level: u64, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_ask">cancel_ask</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    seller_kiosk: &<b>mut</b> Kiosk,
    nft_price_level: u64,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_ask_">cancel_ask_</a>(book, seller_kiosk, nft_price_level, nft_id, ctx);
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask"></a>

## Function `create_ask`

Offer given NFT to be traded for given (<code>requested_tokens</code>) tokens.
If there exists a bid with higher offer than <code>requested_tokens</code>, then
trade is immediately executed.
In such a case, a new shared object [<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a></code>] is created.
Otherwise we exclusively lock the NFT in the seller's kiosk for the
orderbook to collect later.

* the sender must be owner of kiosk
* the kiosk must be in Originbyte universe
* the NFT mustn't be listed anywhere else yet

Returns <code>Some</code> with the amount if matched.
Amount is always equal or more than <code>requested_tokens</code>.


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask">create_ask</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, seller_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, requested_tokens: u64, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Option">option::Option</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">orderbook::TradeInfo</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask">create_ask</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    seller_kiosk: &<b>mut</b> Kiosk,
    requested_tokens: u64,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
): Option&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a>&gt; {
    <b>assert</b>!(!book.protected_actions.create_ask, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EActionNotPublic">EActionNotPublic</a>);
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_">create_ask_</a>&lt;T, FT&gt;(
        book, seller_kiosk, requested_tokens, <a href="_none">option::none</a>(), nft_id, ctx
    )
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_protected"></a>

## Function `create_ask_protected`

Same as [<code>create_ask</code>] but protected by
[collection witness](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#witness-protected-actions).


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_protected">create_ask_protected</a>&lt;T: store, key, FT&gt;(_witness: <a href="_Witness">witness::Witness</a>&lt;T&gt;, book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, seller_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, requested_tokens: u64, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Option">option::Option</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">orderbook::TradeInfo</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_protected">create_ask_protected</a>&lt;T: key + store, FT&gt;(
    _witness: DelegatedWitness&lt;T&gt;,
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    seller_kiosk: &<b>mut</b> Kiosk,
    requested_tokens: u64,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
): Option&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a>&gt; {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_">create_ask_</a>&lt;T, FT&gt;(
        book, seller_kiosk, requested_tokens, <a href="_none">option::none</a>(), nft_id, ctx
    )
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_with_commission"></a>

## Function `create_ask_with_commission`

Same as [<code>create_ask</code>] but with a
[commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_with_commission">create_ask_with_commission</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, seller_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, requested_tokens: u64, nft_id: <a href="_ID">object::ID</a>, beneficiary: <b>address</b>, commission_ft: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Option">option::Option</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">orderbook::TradeInfo</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_with_commission">create_ask_with_commission</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    seller_kiosk: &<b>mut</b> Kiosk,
    requested_tokens: u64,
    nft_id: ID,
    beneficiary: <b>address</b>,
    commission_ft: u64,
    ctx: &<b>mut</b> TxContext,
): Option&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a>&gt; {
    <b>assert</b>!(!book.protected_actions.create_ask, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EActionNotPublic">EActionNotPublic</a>);
    <b>assert</b>!(commission_ft &lt; requested_tokens, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ECommissionTooHigh">ECommissionTooHigh</a>);

    <b>let</b> commission = <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_new_ask_commission">trading::new_ask_commission</a>(
        beneficiary, commission_ft,
    );
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_">create_ask_</a>&lt;T, FT&gt;(
        book,
        seller_kiosk,
        requested_tokens,
        <a href="_some">option::some</a>(commission),
        nft_id,
        ctx,
    )
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_with_commission_protected"></a>

## Function `create_ask_with_commission_protected`

Same as [<code>create_ask_protected</code>] but with a
[commission](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#commission).


<a name="@Panics_12"></a>

###### Panics

The <code>commission</code> arg must be less than <code>requested_tokens</code>.


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_with_commission_protected">create_ask_with_commission_protected</a>&lt;T: store, key, FT&gt;(_witness: <a href="_Witness">witness::Witness</a>&lt;T&gt;, book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, seller_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, requested_tokens: u64, nft_id: <a href="_ID">object::ID</a>, beneficiary: <b>address</b>, commission_ft: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Option">option::Option</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">orderbook::TradeInfo</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_with_commission_protected">create_ask_with_commission_protected</a>&lt;T: key + store, FT&gt;(
    _witness: DelegatedWitness&lt;T&gt;,
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    seller_kiosk: &<b>mut</b> Kiosk,
    requested_tokens: u64,
    nft_id: ID,
    beneficiary: <b>address</b>,
    commission_ft: u64,
    ctx: &<b>mut</b> TxContext,
): Option&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a>&gt; {
    <b>assert</b>!(commission_ft &lt; requested_tokens, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ECommissionTooHigh">ECommissionTooHigh</a>);

    <b>let</b> commission = <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_new_ask_commission">trading::new_ask_commission</a>(
        beneficiary,
        commission_ft,
    );
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_">create_ask_</a>&lt;T, FT&gt;(
        book,
        seller_kiosk,
        requested_tokens,
        <a href="_some">option::some</a>(commission),
        nft_id,
        ctx,
    )
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_market_sell"></a>

## Function `market_sell`

Offer given NFT to be traded for given (<code>requested_tokens</code>) tokens.
If there exists a bid with higher offer than <code>requested_tokens</code>, then
trade is immediately executed.
In such a case, a new shared object [<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a></code>] is created.
Otherwise we fail the transaction.

* the sender must be owner of kiosk
* the kiosk must be in Originbyte universe
* the NFT mustn't be listed anywhere else yet

Returns the paid amount for the NFT.


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_market_sell">market_sell</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, seller_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, min_price: u64, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">orderbook::TradeInfo</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_market_sell">market_sell</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    seller_kiosk: &<b>mut</b> Kiosk,
    min_price: u64,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
): <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a> {
    <b>let</b> is_matched_with_price = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask">create_ask</a>(
        book,
        seller_kiosk,
        min_price,
        nft_id,
        ctx,
    );
    <b>assert</b>!(
        <a href="_is_some">option::is_some</a>(&is_matched_with_price),
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EMarketOrderNotFilled">EMarketOrderNotFilled</a>,
    );
    <a href="_destroy_some">option::destroy_some</a>(is_matched_with_price)
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_edit_ask"></a>

## Function `edit_ask`

Removes the old ask and creates a new one with the same NFT.
Two events are emitted at least:
Firstly, we always emit <code>AskRemovedEvent</code> for the old ask.
Then either <code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_AskCreatedEvent">AskCreatedEvent</a></code> or <code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeFilledEvent">TradeFilledEvent</a></code>.
Depends on whether the ask is filled immediately or not.


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_edit_ask">edit_ask</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, seller_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, old_price: u64, nft_id: <a href="_ID">object::ID</a>, new_price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_edit_ask">edit_ask</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    seller_kiosk: &<b>mut</b> Kiosk,
    old_price: u64,
    nft_id: ID,
    new_price: u64,
    ctx: &<b>mut</b> TxContext,
) {
    <b>assert</b>!(!book.protected_actions.create_ask, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EActionNotPublic">EActionNotPublic</a>);

    <b>let</b> commission = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_ask_">cancel_ask_</a>(
        book, seller_kiosk, old_price, nft_id, ctx,
    );
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_">create_ask_</a>(book, seller_kiosk, new_price, commission, nft_id, ctx);
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_edit_bid"></a>

## Function `edit_bid`

Cancels the old bid and creates a new one with new price.


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_edit_bid">edit_bid</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, old_price: u64, new_price: u64, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_edit_bid">edit_bid</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    buyer_kiosk: &<b>mut</b> Kiosk,
    old_price: u64,
    new_price: u64,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>assert</b>!(!book.protected_actions.create_bid, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EActionNotPublic">EActionNotPublic</a>);
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_edit_bid_">edit_bid_</a>(book, buyer_kiosk, old_price, new_price, wallet, ctx);
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_buy_nft"></a>

## Function `buy_nft`

To buy a specific NFT listed in the orderbook, the client provides the
price for which the NFT is listed.

The NFT is transferred from the seller's Kiosk to the buyer's Kiosk.

In this case, it's important to provide both the price and NFT ID to
avoid actions such as offering an NFT for a really low price and then
quickly changing the price to a higher one.

The provided [<code>Coin</code>] wallet is used to pay for the NFT.

This endpoint does not create a new [<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a></code>], rather
performs he transfer straight away.

See the documentation for <code>nft_protocol::transfer_request</code> to understand
how to deal with the returned [<code>TransferRequest</code>] type.

* both kiosks must be in the OB universe


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_buy_nft">buy_nft</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, seller_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, price: u64, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_buy_nft">buy_nft</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    seller_kiosk: &<b>mut</b> Kiosk,
    buyer_kiosk: &<b>mut</b> Kiosk,
    nft_id: ID,
    price: u64,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): TransferRequest&lt;T&gt; {
    <b>assert</b>!(!book.protected_actions.buy_nft, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EActionNotPublic">EActionNotPublic</a>);
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_buy_nft_">buy_nft_</a>&lt;T, FT&gt;(
        book, seller_kiosk, buyer_kiosk, nft_id, price, wallet, ctx
    )
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_buy_nft_protected"></a>

## Function `buy_nft_protected`

Same as [<code>buy_nft</code>] but protected by
[collection witness](https://docs.originbyte.io/origin-byte/about-our-programs/liquidity-layer/orderbook#witness-protected-actions).


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_buy_nft_protected">buy_nft_protected</a>&lt;T: store, key, FT&gt;(_witness: <a href="_Witness">witness::Witness</a>&lt;T&gt;, book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, seller_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, price: u64, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_buy_nft_protected">buy_nft_protected</a>&lt;T: key + store, FT&gt;(
    _witness: DelegatedWitness&lt;T&gt;,
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    seller_kiosk: &<b>mut</b> Kiosk,
    buyer_kiosk: &<b>mut</b> Kiosk,
    nft_id: ID,
    price: u64,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): TransferRequest&lt;T&gt; {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_buy_nft_">buy_nft_</a>&lt;T, FT&gt;(
        book, seller_kiosk, buyer_kiosk, nft_id, price, wallet, ctx
    )
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_finish_trade"></a>

## Function `finish_trade`

When a bid is created and there's an ask with a lower price, then the
trade cannot be resolved immediately.
That's because we don't know the <code>Kiosk</code> ID up front in OB.
Conversely, when an ask is created, we don't know the <code>Kiosk</code> ID of the
buyer as the best bid can change at any time.

Therefore, orderbook creates [<code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a></code>] which then has to be
permissionlessly resolved via this endpoint.

See the documentation for <code>nft_protocol::transfer_request</code> to understand
how to deal with the returned [<code>TransferRequest</code>] type.

* the buyer's kiosk must allow permissionless deposits of <code>T</code> unless
buyer is the signer


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_finish_trade">finish_trade</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, trade_id: <a href="_ID">object::ID</a>, seller_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_finish_trade">finish_trade</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    trade_id: ID,
    seller_kiosk: &<b>mut</b> Kiosk,
    buyer_kiosk: &<b>mut</b> Kiosk,
    ctx: &<b>mut</b> TxContext,
): TransferRequest&lt;T&gt; {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_finish_trade_">finish_trade_</a>&lt;T, FT&gt;(book, trade_id, seller_kiosk, buyer_kiosk, ctx)
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_finish_trade_if_kiosks_match"></a>

## Function `finish_trade_if_kiosks_match`



<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_finish_trade_if_kiosks_match">finish_trade_if_kiosks_match</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, trade_id: <a href="_ID">object::ID</a>, seller_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Option">option::Option</a>&lt;<a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_finish_trade_if_kiosks_match">finish_trade_if_kiosks_match</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    trade_id: ID,
    seller_kiosk: &<b>mut</b> Kiosk,
    buyer_kiosk: &<b>mut</b> Kiosk,
    ctx: &<b>mut</b> TxContext,
): Option&lt;TransferRequest&lt;T&gt;&gt; {
    <b>let</b> t = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_trade">trade</a>(book, trade_id);
    <b>let</b> kiosks_match = &t.seller_kiosk == &<a href="_id">object::id</a>(seller_kiosk)
        && &t.buyer_kiosk == &<a href="_id">object::id</a>(buyer_kiosk);

    <b>if</b> (kiosks_match) {
        <a href="_some">option::some</a>(
            <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_finish_trade">finish_trade</a>(book, trade_id, seller_kiosk, buyer_kiosk, ctx),
        )
    } <b>else</b> {
        <a href="_none">option::none</a>()
    }
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_change_tick_size"></a>

## Function `change_tick_size`

Change tick size of orderbook


<a name="@Panics_13"></a>

###### Panics


Panics if provided <code>Publisher</code> did not publish type <code>T</code>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_change_tick_size">change_tick_size</a>&lt;T: store, key, FT&gt;(publisher: &<a href="_Publisher">package::Publisher</a>, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, tick_size: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_change_tick_size">change_tick_size</a>&lt;T: key + store, FT&gt;(
    publisher: &Publisher,
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    tick_size: u64,
) {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_change_tick_size_with_witness">change_tick_size_with_witness</a>(
        <a href="_from_publisher">witness::from_publisher</a>(publisher), <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>, tick_size,
    )
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_change_tick_size_with_witness"></a>

## Function `change_tick_size_with_witness`

Change tick size of orderbook


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_change_tick_size_with_witness">change_tick_size_with_witness</a>&lt;T: store, key, FT&gt;(_witness: <a href="_Witness">witness::Witness</a>&lt;T&gt;, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, tick_size: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_change_tick_size_with_witness">change_tick_size_with_witness</a>&lt;T: key + store, FT&gt;(
    _witness: DelegatedWitness&lt;T&gt;,
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    tick_size: u64,
) {
    <b>assert</b>!(tick_size &lt; <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>.tick_size, 0);
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>.tick_size = tick_size;
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_set_protection"></a>

## Function `set_protection`

Change protection level of an existing orderbook


<a name="@Panics_14"></a>

###### Panics


Panics if provided <code>Publisher</code> did not publish type <code>T</code>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_set_protection">set_protection</a>&lt;T: store, key, FT&gt;(publisher: &<a href="_Publisher">package::Publisher</a>, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, buy_nft: bool, create_ask: bool, create_bid: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_set_protection">set_protection</a>&lt;T: key + store, FT&gt;(
    publisher: &Publisher,
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    buy_nft: bool,
    create_ask: bool,
    create_bid: bool,
) {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_set_protection_with_witness">set_protection_with_witness</a>&lt;T, FT&gt;(
        <a href="_from_publisher">witness::from_publisher</a>(publisher),
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>,
        buy_nft,
        create_ask,
        create_bid,
    )
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_set_protection_with_witness"></a>

## Function `set_protection_with_witness`

Change protection level of an existing orderbook


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_set_protection_with_witness">set_protection_with_witness</a>&lt;T: store, key, FT&gt;(_witness: <a href="_Witness">witness::Witness</a>&lt;T&gt;, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, buy_nft: bool, create_ask: bool, create_bid: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_set_protection_with_witness">set_protection_with_witness</a>&lt;T: key + store, FT&gt;(
    _witness: DelegatedWitness&lt;T&gt;,
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    buy_nft: bool,
    create_ask: bool,
    create_bid: bool,
) {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>.protected_actions = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_WitnessProtectedActions">WitnessProtectedActions</a> {
        buy_nft, create_ask, create_bid,
    };
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_disable_trading"></a>

## Function `disable_trading`

Helper method to protect all endpoints thus disabling trading


<a name="@Panics_15"></a>

###### Panics


Panics if provided <code>Publisher</code> did not publish type <code>T</code>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_disable_trading">disable_trading</a>&lt;T: store, key, FT&gt;(publisher: &<a href="_Publisher">package::Publisher</a>, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_disable_trading">disable_trading</a>&lt;T: key + store, FT&gt;(
    publisher: &Publisher,
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
) {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_set_protection_with_witness">set_protection_with_witness</a>&lt;T, FT&gt;(
        <a href="_from_publisher">witness::from_publisher</a>(publisher), <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>, <b>true</b>, <b>true</b>, <b>true</b>,
    )
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_enable_trading"></a>

## Function `enable_trading`

Helper method to unprotect all endpoints thus enabling trading


<a name="@Panics_16"></a>

###### Panics


Panics if provided <code>Publisher</code> did not publish type <code>T</code>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_enable_trading">enable_trading</a>&lt;T: store, key, FT&gt;(publisher: &<a href="_Publisher">package::Publisher</a>, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_enable_trading">enable_trading</a>&lt;T: key + store, FT&gt;(
    publisher: &Publisher,
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
) {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_set_protection_with_witness">set_protection_with_witness</a>&lt;T, FT&gt;(
        <a href="_from_publisher">witness::from_publisher</a>(publisher), <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>, <b>false</b>, <b>false</b>, <b>false</b>,
    )
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_borrow_bids"></a>

## Function `borrow_bids`



<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_borrow_bids">borrow_bids</a>&lt;T: store, key, FT&gt;(book: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;): &<a href="_CritbitTree">critbit_u64::CritbitTree</a>&lt;<a href="">vector</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Bid">orderbook::Bid</a>&lt;FT&gt;&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_borrow_bids">borrow_bids</a>&lt;T: key + store, FT&gt;(
    book: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
): &CritbitTree&lt;<a href="">vector</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Bid">Bid</a>&lt;FT&gt;&gt;&gt; {
    &book.bids
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_bid_offer"></a>

## Function `bid_offer`



<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_bid_offer">bid_offer</a>&lt;FT&gt;(bid: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Bid">orderbook::Bid</a>&lt;FT&gt;): &<a href="_Balance">balance::Balance</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_bid_offer">bid_offer</a>&lt;FT&gt;(bid: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Bid">Bid</a>&lt;FT&gt;): &Balance&lt;FT&gt; {
    &bid.offer
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_bid_owner"></a>

## Function `bid_owner`



<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_bid_owner">bid_owner</a>&lt;FT&gt;(bid: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Bid">orderbook::Bid</a>&lt;FT&gt;): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_bid_owner">bid_owner</a>&lt;FT&gt;(bid: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Bid">Bid</a>&lt;FT&gt;): <b>address</b> {
    bid.owner
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_borrow_asks"></a>

## Function `borrow_asks`



<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_borrow_asks">borrow_asks</a>&lt;T: store, key, FT&gt;(book: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;): &<a href="_CritbitTree">critbit_u64::CritbitTree</a>&lt;<a href="">vector</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">orderbook::Ask</a>&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_borrow_asks">borrow_asks</a>&lt;T: key + store, FT&gt;(
    book: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
): &CritbitTree&lt;<a href="">vector</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">Ask</a>&gt;&gt; {
    &book.asks
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ask_price"></a>

## Function `ask_price`



<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ask_price">ask_price</a>(ask: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">orderbook::Ask</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ask_price">ask_price</a>(ask: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">Ask</a>): u64 {
    ask.price
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ask_owner"></a>

## Function `ask_owner`



<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ask_owner">ask_owner</a>(ask: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">orderbook::Ask</a>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ask_owner">ask_owner</a>(ask: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">Ask</a>): <b>address</b> {
    ask.owner
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_is_create_ask_protected"></a>

## Function `is_create_ask_protected`



<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_is_create_ask_protected">is_create_ask_protected</a>&lt;T: store, key, FT&gt;(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_is_create_ask_protected">is_create_ask_protected</a>&lt;T: key + store, FT&gt;(
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
): bool {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>.protected_actions.create_ask
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_is_create_bid_protected"></a>

## Function `is_create_bid_protected`



<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_is_create_bid_protected">is_create_bid_protected</a>&lt;T: store, key, FT&gt;(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_is_create_bid_protected">is_create_bid_protected</a>&lt;T: key + store, FT&gt;(
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
): bool {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>.protected_actions.create_bid
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_is_buy_nft_protected"></a>

## Function `is_buy_nft_protected`



<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_is_buy_nft_protected">is_buy_nft_protected</a>&lt;T: store, key, FT&gt;(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_is_buy_nft_protected">is_buy_nft_protected</a>&lt;T: key + store, FT&gt;(
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
): bool {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>.protected_actions.buy_nft
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_trade_id"></a>

## Function `trade_id`



<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_trade_id">trade_id</a>(trade: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">orderbook::TradeInfo</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_trade_id">trade_id</a>(trade: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a>): ID {
    trade.trade_id
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_trade_price"></a>

## Function `trade_price`



<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_trade_price">trade_price</a>(trade: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">orderbook::TradeInfo</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_trade_price">trade_price</a>(trade: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a>): u64 {
    trade.trade_price
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_trade"></a>

## Function `trade`



<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_trade">trade</a>&lt;T: store, key, FT&gt;(book: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, trade_id: <a href="_ID">object::ID</a>): &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">orderbook::TradeIntermediate</a>&lt;T, FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_trade">trade</a>&lt;T: key + store, FT&gt;(
    book: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    trade_id: ID,
): &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a>&lt;T, FT&gt; {
    df::borrow(&book.id, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediateDfKey">TradeIntermediateDfKey</a>&lt;T, FT&gt; { trade_id })
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_"></a>

## Function `create_bid_`

* buyer kiosk must be in Originbyte ecosystem
* sender must be owner of buyer kiosk
* kiosk must allow permissionless deposits of <code>T</code>

Either <code><a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a></code> is shared, or bid is added to the state.

Returns <code>Some</code> with amount if matched.
The amount is always equal or less than price.


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_">create_bid_</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, price: u64, bid_commission: <a href="_Option">option::Option</a>&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;&gt;, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Option">option::Option</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">orderbook::TradeInfo</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_">create_bid_</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    buyer_kiosk: &<b>mut</b> Kiosk,
    price: u64,
    bid_commission: Option&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;&gt;,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): Option&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a>&gt; {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_version">assert_version</a>(book);
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_tick_level">assert_tick_level</a>(price, book.tick_size);

    <a href="_assert_is_ob_kiosk">ob_kiosk::assert_is_ob_kiosk</a>(buyer_kiosk);
    <a href="_assert_permission">ob_kiosk::assert_permission</a>(buyer_kiosk, ctx);
    <a href="_assert_can_deposit_permissionlessly">ob_kiosk::assert_can_deposit_permissionlessly</a>&lt;T&gt;(buyer_kiosk);

    <b>let</b> buyer = <a href="_sender">tx_context::sender</a>(ctx);
    <b>let</b> buyer_kiosk_id = <a href="_id">object::id</a>(buyer_kiosk);

    <b>let</b> asks = &<b>mut</b> book.asks;

    // <b>if</b> map empty, then lowest ask price is 0
    <b>let</b> (can_be_filled, lowest_ask_price) = <b>if</b> (critbit::is_empty(asks)) {
        (<b>false</b>, 0)
    } <b>else</b> {
        <b>let</b> (lowest_ask_price, _) = critbit::min_leaf(asks);

        (lowest_ask_price &lt;= price, lowest_ask_price)
    };

    <b>if</b> (can_be_filled) {
        <b>let</b> trade_id = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_match_buy_with_ask_">match_buy_with_ask_</a>(
            book,
            lowest_ask_price,
            buyer_kiosk_id,
            bid_commission,
            wallet,
            ctx,
        );

        <a href="_some">option::some</a>(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a> {
            trade_price: lowest_ask_price,
            trade_id,
        })
    } <b>else</b> {
        <a href="_emit">event::emit</a>(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_BidCreatedEvent">BidCreatedEvent</a> {
            <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: <a href="_id">object::id</a>(book),
            owner: buyer,
            price,
            <a href="">kiosk</a>: buyer_kiosk_id,
            nft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;T&gt;()),
            ft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;FT&gt;()),
        });

        // take the amount that the sender wants <b>to</b> create a bid <b>with</b> from their
        // wallet
        <b>let</b> bid_offer = <a href="_split">balance::split</a>(<a href="_balance_mut">coin::balance_mut</a>(wallet), price);

        <b>let</b> order = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Bid">Bid</a> {
            offer: bid_offer,
            owner: buyer,
            <a href="">kiosk</a>: buyer_kiosk_id,
            commission: bid_commission,
        };

        <b>let</b> (has_key, price_level_idx) =
            critbit::find_leaf(&book.bids, price);

        <b>if</b> (has_key) {
            <a href="_push_back">vector::push_back</a>(
                critbit::borrow_mut_leaf_by_index(
                    &<b>mut</b> book.bids, price_level_idx,
                ),
                order
            );
        } <b>else</b> {
            critbit::insert_leaf(
                &<b>mut</b> book.bids, price, <a href="_singleton">vector::singleton</a>(order),
            );
        };

        <a href="_none">option::none</a>()
    }
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_match_buy_with_ask_"></a>

## Function `match_buy_with_ask_`



<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_match_buy_with_ask_">match_buy_with_ask_</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, lowest_ask_price: u64, buyer_kiosk_id: <a href="_ID">object::ID</a>, bid_commission: <a href="_Option">option::Option</a>&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;&gt;, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_match_buy_with_ask_">match_buy_with_ask_</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    lowest_ask_price: u64,
    buyer_kiosk_id: ID,
    bid_commission: Option&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;&gt;,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): ID {
    <b>let</b> asks = &<b>mut</b> book.asks;
    <b>let</b> buyer = <a href="_sender">tx_context::sender</a>(ctx);
    <b>let</b> price_level =
        critbit::borrow_mut_leaf_by_key(asks, lowest_ask_price);

    // remove zeroth for FIFO, must exist due <b>to</b> `can_be_filled`
    <b>let</b> ask = <a href="_remove">vector::remove</a>(price_level, 0);

    <b>if</b> (<a href="_length">vector::length</a>(price_level) == 0) {
        // <b>to</b> simplify impl, always delete empty price level
        <b>let</b> price_level =
            critbit::remove_leaf_by_key(asks, lowest_ask_price);
        <a href="_destroy_empty">vector::destroy_empty</a>(price_level);
    };

    <b>let</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">Ask</a> {
        price: _,
        owner: seller,
        nft_id,
        kiosk_id,
        commission: ask_commission,
    } = ask;

    <b>assert</b>!(kiosk_id != buyer_kiosk_id, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ECannotTradeWithSelf">ECannotTradeWithSelf</a>);

    // see also `finish_trade` entry point
    <b>let</b> trade_intermediate = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a>&lt;T, FT&gt; {
        buyer_kiosk: buyer_kiosk_id,
        buyer,
        nft_id,
        seller,
        seller_kiosk: kiosk_id,
        commission: ask_commission,
        id: <a href="_new">object::new</a>(ctx),
        paid: <a href="_split">balance::split</a>(<a href="_balance_mut">coin::balance_mut</a>(wallet), lowest_ask_price),
    };
    <b>let</b> trade_intermediate_id = <a href="_id">object::id</a>(&trade_intermediate);

    // Add <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a> <b>as</b> a dynamic field <b>to</b> the <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>
    df::add(
        &<b>mut</b> book.id,
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediateDfKey">TradeIntermediateDfKey</a>&lt;T, FT&gt; { trade_id: trade_intermediate_id },
        trade_intermediate
    );

    <a href="_emit">event::emit</a>(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeFilledEvent">TradeFilledEvent</a> {
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: <a href="_id">object::id</a>(book),
        buyer_kiosk: buyer_kiosk_id,
        buyer,
        nft: nft_id,
        price: lowest_ask_price,
        seller_kiosk: kiosk_id,
        seller,
        trade_intermediate: <a href="_some">option::some</a>(trade_intermediate_id),
        nft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;T&gt;()),
        ft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;FT&gt;()),
    });

    <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_transfer_bid_commission">trading::transfer_bid_commission</a>(&<b>mut</b> bid_commission, ctx);
    <a href="_destroy_none">option::destroy_none</a>(bid_commission);

    trade_intermediate_id
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_match_sell_with_bid_"></a>

## Function `match_sell_with_bid_`



<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_match_sell_with_bid_">match_sell_with_bid_</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, highest_bid_price: u64, seller_kiosk_id: <a href="_ID">object::ID</a>, ask_commission: <a href="_Option">option::Option</a>&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">trading::AskCommission</a>&gt;, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_match_sell_with_bid_">match_sell_with_bid_</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    highest_bid_price: u64,
    seller_kiosk_id: ID,
    ask_commission: Option&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">trading::AskCommission</a>&gt;,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
): ID {
    <b>let</b> bids = &<b>mut</b> book.bids;
    <b>let</b> seller = <a href="_sender">tx_context::sender</a>(ctx);
    <b>let</b> price_level = critbit::borrow_mut_leaf_by_key(bids, highest_bid_price);

    // remove zeroth for FIFO, must exist due <b>to</b> `can_be_filled`
    <b>let</b> bid = <a href="_remove">vector::remove</a>(price_level, 0);

    <b>if</b> (<a href="_length">vector::length</a>(price_level) == 0) {
        // <b>to</b> simplify impl, always delete empty price level
        <b>let</b> price_level =
            critbit::remove_leaf_by_key(bids, highest_bid_price);
        <a href="_destroy_empty">vector::destroy_empty</a>(price_level);
    };

    <b>let</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Bid">Bid</a> {
        owner: buyer,
        offer: bid_offer,
        <a href="">kiosk</a>: buyer_kiosk_id,
        commission: bid_commission,
    } = bid;
    <b>assert</b>!(buyer_kiosk_id != seller_kiosk_id, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_ECannotTradeWithSelf">ECannotTradeWithSelf</a>);
    <b>let</b> paid = <a href="_value">balance::value</a>(&bid_offer);

    // see also `finish_trade` entry point
    <b>let</b> trade_intermediate = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a>&lt;T, FT&gt; {
        id: <a href="_new">object::new</a>(ctx),
        commission: ask_commission,
        seller,
        buyer,
        buyer_kiosk: buyer_kiosk_id,
        seller_kiosk: seller_kiosk_id,
        nft_id: nft_id,
        paid: bid_offer,
    };
    <b>let</b> trade_intermediate_id = <a href="_id">object::id</a>(&trade_intermediate);

    // Add <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a> <b>as</b> a dynamic field <b>to</b> the <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>
    df::add(
        &<b>mut</b> book.id,
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediateDfKey">TradeIntermediateDfKey</a>&lt;T, FT&gt; { trade_id: trade_intermediate_id },
        trade_intermediate
    );

    <a href="_emit">event::emit</a>(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeFilledEvent">TradeFilledEvent</a> {
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: <a href="_id">object::id</a>(book),
        buyer_kiosk: buyer_kiosk_id,
        buyer,
        nft: nft_id,
        price: paid,
        seller_kiosk: seller_kiosk_id,
        seller,
        trade_intermediate: <a href="_some">option::some</a>(trade_intermediate_id),
        nft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;T&gt;()),
        ft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;FT&gt;()),
    });

    <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_transfer_bid_commission">trading::transfer_bid_commission</a>(&<b>mut</b> bid_commission, ctx);
    <a href="_destroy_none">option::destroy_none</a>(bid_commission);

    trade_intermediate_id
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid_except_commission"></a>

## Function `cancel_bid_except_commission`

Removes bid from the state and returns the commission which contains
tokens that the buyer was meant to pay as a commission on a successful
trade.


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid_except_commission">cancel_bid_except_commission</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, bid_price_level: u64, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Option">option::Option</a>&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid_except_commission">cancel_bid_except_commission</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    bid_price_level: u64,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): Option&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;&gt; {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_version">assert_version</a>(book);

    <b>let</b> sender = <a href="_sender">tx_context::sender</a>(ctx);
    <b>let</b> bids = &<b>mut</b> book.bids;

    <b>let</b> (has_key, price_level_idx) =
        critbit::find_leaf(bids, bid_price_level);

    <b>assert</b>!(has_key, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EOrderDoesNotExist">EOrderDoesNotExist</a>);

    <b>let</b> price_level =
        critbit::borrow_mut_leaf_by_index(bids, price_level_idx);

    <b>let</b> index = 0;
    <b>let</b> bids_count = <a href="_length">vector::length</a>(price_level);
    <b>while</b> (bids_count &gt; index) {
        <b>let</b> bid = <a href="_borrow">vector::borrow</a>(price_level, index);
        <b>if</b> (bid.owner == sender) {
            <b>break</b>
        };

        index = index + 1;
    };
    // we iterated over all bids and didn't find one <b>where</b> owner is sender
    <b>assert</b>!(index &lt; bids_count, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EOrderOwnerMustBeSender">EOrderOwnerMustBeSender</a>);

    <b>let</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Bid">Bid</a> { offer, owner: _owner, commission, <a href="">kiosk</a> } =
        <a href="_remove">vector::remove</a>(price_level, index);
    <a href="_join">balance::join</a>(<a href="_balance_mut">coin::balance_mut</a>(wallet), offer);

    <b>if</b> (<a href="_length">vector::length</a>(price_level) == 0) {
        // <b>to</b> simplify impl, always delete empty price level
        <b>let</b> price_level = critbit::remove_leaf_by_index(bids, price_level_idx);
        <a href="_destroy_empty">vector::destroy_empty</a>(price_level);
    };

    <a href="_emit">event::emit</a>(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_BidClosedEvent">BidClosedEvent</a> {
        owner: sender,
        <a href="">kiosk</a>,
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: <a href="_id">object::id</a>(book),
        price: bid_price_level,
        nft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;T&gt;()),
        ft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;FT&gt;()),
    });

    commission
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid_"></a>

## Function `cancel_bid_`



<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid_">cancel_bid_</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, bid_price_level: u64, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid_">cancel_bid_</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    bid_price_level: u64,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_version">assert_version</a>(book);

    <b>let</b> commission =
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid_except_commission">cancel_bid_except_commission</a>(book, bid_price_level, wallet, ctx);

    <b>if</b> (<a href="_is_some">option::is_some</a>(&commission)) {
        <b>let</b> (cut, _beneficiary) =
            <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_destroy_bid_commission">trading::destroy_bid_commission</a>(<a href="_extract">option::extract</a>(&<b>mut</b> commission));
        <a href="_join">balance::join</a>(
            <a href="_balance_mut">coin::balance_mut</a>(wallet),
            cut,
        );
    };
    <a href="_destroy_none">option::destroy_none</a>(commission);
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_edit_bid_"></a>

## Function `edit_bid_`



<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_edit_bid_">edit_bid_</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, old_price: u64, new_price: u64, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_edit_bid_">edit_bid_</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    buyer_kiosk: &<b>mut</b> Kiosk,
    old_price: u64,
    new_price: u64,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> commission =
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_bid_except_commission">cancel_bid_except_commission</a>(book, old_price, wallet, ctx);

    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_bid_">create_bid_</a>(book, buyer_kiosk, new_price, commission, wallet, ctx);
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_"></a>

## Function `create_ask_`

* the sender must be owner of kiosk
* the kiosk must be in Originbyte universe
* NFT is exclusively listed in the kiosk

Returns <code>Some</code> with the amount if matched.
Amount is always equal or more than <code>requested_tokens</code>.


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_">create_ask_</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, seller_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, price: u64, ask_commission: <a href="_Option">option::Option</a>&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">trading::AskCommission</a>&gt;, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Option">option::Option</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">orderbook::TradeInfo</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_create_ask_">create_ask_</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    seller_kiosk: &<b>mut</b> Kiosk,
    price: u64,
    ask_commission: Option&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">trading::AskCommission</a>&gt;,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
): Option&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a>&gt; {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_version">assert_version</a>(book);
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_tick_level">assert_tick_level</a>(price, book.tick_size);

    // we cannot <a href="">transfer</a> the NFT straight away because we don't know
    // the buyers <a href="">kiosk</a> at the point of sending the tx

    // will fail <b>if</b> not OB <a href="">kiosk</a>
    <a href="_auth_exclusive_transfer">ob_kiosk::auth_exclusive_transfer</a>(seller_kiosk, nft_id, &book.transfer_signer, ctx);

    // prevent listing of NFTs which don't belong <b>to</b> the collection
    <a href="_assert_nft_type">ob_kiosk::assert_nft_type</a>&lt;T&gt;(seller_kiosk, nft_id);

    <b>let</b> seller = <a href="_sender">tx_context::sender</a>(ctx);
    <b>let</b> seller_kiosk_id = <a href="_id">object::id</a>(seller_kiosk);

    <b>let</b> bids = &<b>mut</b> book.bids;

    // <b>if</b> map empty, then highest bid ask price is 0
    <b>let</b> (can_be_filled, highest_bid_price) = <b>if</b> (critbit::is_empty(bids)) {
        (<b>false</b>, 0)
    } <b>else</b> {
        <b>let</b> (highest_bid_price, _) = critbit::max_leaf(bids);

        (highest_bid_price &gt;= price, highest_bid_price)
    };

    <b>if</b> (can_be_filled) {
        <b>let</b> trade_id = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_match_sell_with_bid_">match_sell_with_bid_</a>(
            book,
            highest_bid_price,
            seller_kiosk_id,
            ask_commission,
            nft_id,
            ctx,
        );

        <a href="_some">option::some</a>(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeInfo">TradeInfo</a> {
            trade_price: highest_bid_price,
            trade_id,
        })
    } <b>else</b> {
        <a href="_emit">event::emit</a>(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_AskCreatedEvent">AskCreatedEvent</a> {
            nft: nft_id,
            <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: <a href="_id">object::id</a>(book),
            owner: seller,
            price,
            <a href="">kiosk</a>: seller_kiosk_id,
            nft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;T&gt;()),
            ft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;FT&gt;()),
        });

        <b>let</b> ask = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">Ask</a> {
            price,
            nft_id,
            kiosk_id: seller_kiosk_id,
            owner: seller,
            commission: ask_commission,
        };
        // store the <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">Ask</a> <a href="">object</a>
        <b>let</b> (has_key, price_level_idx) =
            critbit::find_leaf(&book.asks, price);

        <b>if</b> (has_key) {
            <a href="_push_back">vector::push_back</a>(
                critbit::borrow_mut_leaf_by_index(
                    &<b>mut</b> book.asks, price_level_idx,
                ),
                ask,
            );
        } <b>else</b> {
            critbit::insert_leaf(&<b>mut</b> book.asks, price, <a href="_singleton">vector::singleton</a>(ask));
        };

        <a href="_none">option::none</a>()
    }
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_ask_"></a>

## Function `cancel_ask_`

* cancels the exclusive listing


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_ask_">cancel_ask_</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, <a href="">kiosk</a>: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_price_level: u64, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Option">option::Option</a>&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">trading::AskCommission</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_cancel_ask_">cancel_ask_</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    <a href="">kiosk</a>: &<b>mut</b> Kiosk,
    nft_price_level: u64,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
): Option&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">trading::AskCommission</a>&gt; {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_version">assert_version</a>(book);
    <b>let</b> sender = <a href="_sender">tx_context::sender</a>(ctx);

    <b>let</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">Ask</a> {
        owner,
        price: _,
        nft_id,
        kiosk_id: _,
        commission,
    } = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_remove_ask">remove_ask</a>(&<b>mut</b> book.asks, nft_price_level, nft_id);

    <a href="_emit">event::emit</a>(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_AskClosedEvent">AskClosedEvent</a> {
        price: nft_price_level,
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: <a href="_id">object::id</a>(book),
        nft: nft_id,
        owner: sender,
        nft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;T&gt;()),
        ft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;FT&gt;()),
    });

    <b>assert</b>!(owner == sender, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EOrderOwnerMustBeSender">EOrderOwnerMustBeSender</a>);
    <a href="_remove_auth_transfer">ob_kiosk::remove_auth_transfer</a>(<a href="">kiosk</a>, nft_id, &book.transfer_signer);

    commission
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_buy_nft_"></a>

## Function `buy_nft_`



<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_buy_nft_">buy_nft_</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, seller_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, price: u64, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_buy_nft_">buy_nft_</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    seller_kiosk: &<b>mut</b> Kiosk,
    buyer_kiosk: &<b>mut</b> Kiosk,
    nft_id: ID,
    price: u64,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): TransferRequest&lt;T&gt; {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_version">assert_version</a>(book);
    <b>let</b> buyer = <a href="_sender">tx_context::sender</a>(ctx);

    <b>let</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">Ask</a> {
        owner: seller,
        price: _,
        nft_id: _,
        kiosk_id: _,
        commission: maybe_commission,
    } = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_remove_ask">remove_ask</a>(&<b>mut</b> book.asks, price, nft_id);

    <a href="_emit">event::emit</a>(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeFilledEvent">TradeFilledEvent</a> {
        <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook">orderbook</a>: <a href="_id">object::id</a>(book),
        buyer_kiosk: <a href="_id">object::id</a>(buyer_kiosk),
        buyer,
        nft: nft_id,
        price,
        seller_kiosk: <a href="_id">object::id</a>(seller_kiosk),
        seller,
        trade_intermediate: <a href="_none">option::none</a>(),
        nft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;T&gt;()),
        ft_type: <a href="_into_string">type_name::into_string</a>(<a href="_get">type_name::get</a>&lt;FT&gt;()),
    });

    <b>let</b> bid_offer = <a href="_split">balance::split</a>(<a href="_balance_mut">coin::balance_mut</a>(wallet), price);

    <b>let</b> transfer_req = <a href="_transfer_delegated">ob_kiosk::transfer_delegated</a>&lt;T&gt;(
        seller_kiosk,
        buyer_kiosk,
        nft_id,
        &book.transfer_signer,
        price,
        ctx,
    );

    <b>if</b> (<a href="_is_some">option::is_some</a>(&maybe_commission)) {
        <b>let</b> commission = <a href="_extract">option::extract</a>(&<b>mut</b> maybe_commission);

        <b>let</b> (<a href="">fee_balance</a>, fee_beneficiary) = <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_extract_ask_commission">trading::extract_ask_commission</a>(
            commission, &<b>mut</b> bid_offer,
        );

        <a href="_set_paid_fee">fee_balance::set_paid_fee</a>(
            &<b>mut</b> transfer_req, <a href="">fee_balance</a>, fee_beneficiary
        );
    };

    <a href="_set_paid">transfer_request::set_paid</a>&lt;T, FT&gt;(&<b>mut</b> transfer_req, bid_offer, seller);

    <a href="_destroy_none">option::destroy_none</a>(maybe_commission);
    <a href="_set_transfer_request_auth">ob_kiosk::set_transfer_request_auth</a>(&<b>mut</b> transfer_req, &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Witness">Witness</a> {});

    transfer_req
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_finish_trade_"></a>

## Function `finish_trade_`



<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_finish_trade_">finish_trade_</a>&lt;T: store, key, FT&gt;(book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, trade_id: <a href="_ID">object::ID</a>, seller_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_finish_trade_">finish_trade_</a>&lt;T: key + store, FT&gt;(
    book: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    trade_id: ID,
    seller_kiosk: &<b>mut</b> Kiosk,
    buyer_kiosk: &<b>mut</b> Kiosk,
    ctx: &<b>mut</b> TxContext,
): TransferRequest&lt;T&gt; {
    <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_version">assert_version</a>(book);

    <b>let</b> trade = df::remove(
        &<b>mut</b> book.id, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediateDfKey">TradeIntermediateDfKey</a>&lt;T, FT&gt; { trade_id }
    );

    <b>let</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_TradeIntermediate">TradeIntermediate</a>&lt;T, FT&gt; {
        id,
        nft_id,
        seller_kiosk: _,
        paid,
        seller,
        buyer: _,
        buyer_kiosk: expected_buyer_kiosk_id,
        commission: maybe_commission,
    } = trade;

    <a href="_delete">object::delete</a>(id);

    <b>let</b> price = <a href="_value">balance::value</a>(&paid);

    <b>assert</b>!(
        expected_buyer_kiosk_id == <a href="_id">object::id</a>(buyer_kiosk), <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EKioskIdMismatch">EKioskIdMismatch</a>,
    );

    <b>let</b> transfer_req = <b>if</b> (<a href="_is_locked">kiosk::is_locked</a>(seller_kiosk, nft_id)) {
        <a href="_transfer_locked_nft">ob_kiosk::transfer_locked_nft</a>&lt;T&gt;(
            seller_kiosk,
            buyer_kiosk,
            nft_id,
            &book.transfer_signer,
            ctx,
        )
    } <b>else</b> {
        <a href="_transfer_delegated">ob_kiosk::transfer_delegated</a>&lt;T&gt;(
            seller_kiosk,
            buyer_kiosk,
            nft_id,
            &book.transfer_signer,
            price,
            ctx,
        )
    };

    <b>if</b> (<a href="_is_some">option::is_some</a>(&maybe_commission)) {
        <b>let</b> commission = <a href="_extract">option::extract</a>(&<b>mut</b> maybe_commission);

        <b>let</b> (<a href="">fee_balance</a>, fee_beneficiary) = <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_extract_ask_commission">trading::extract_ask_commission</a>(
            commission, &<b>mut</b> paid,
        );

        <a href="_set_paid_fee">fee_balance::set_paid_fee</a>(
            &<b>mut</b> transfer_req, <a href="">fee_balance</a>, fee_beneficiary
        );
    };

    <a href="_set_paid">transfer_request::set_paid</a>&lt;T, FT&gt;(&<b>mut</b> transfer_req, paid, seller);

    <a href="_destroy_none">option::destroy_none</a>(maybe_commission);

    <a href="_set_transfer_request_auth">ob_kiosk::set_transfer_request_auth</a>(&<b>mut</b> transfer_req, &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Witness">Witness</a> {});

    transfer_req
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_remove_ask"></a>

## Function `remove_ask`

Finds an ask of a given NFT advertized for the given price. Removes it
from the asks vector preserving order and returns it.


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_remove_ask">remove_ask</a>(asks: &<b>mut</b> <a href="_CritbitTree">critbit_u64::CritbitTree</a>&lt;<a href="">vector</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">orderbook::Ask</a>&gt;&gt;, price: u64, nft_id: <a href="_ID">object::ID</a>): <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">orderbook::Ask</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_remove_ask">remove_ask</a>(asks: &<b>mut</b> CritbitTree&lt;<a href="">vector</a>&lt;<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">Ask</a>&gt;&gt;, price: u64, nft_id: ID): <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Ask">Ask</a> {
    <b>let</b> (has_key, price_level_idx) = critbit::find_leaf(asks, price);
    <b>assert</b>!(has_key, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EOrderDoesNotExist">EOrderDoesNotExist</a>);

    <b>let</b> price_level = critbit::borrow_mut_leaf_by_index(asks, price_level_idx);

    <b>let</b> index = 0;
    <b>let</b> asks_count = <a href="_length">vector::length</a>(price_level);
    <b>while</b> (asks_count &gt; index) {
        <b>let</b> ask = <a href="_borrow">vector::borrow</a>(price_level, index);
        // on the same price level, we search for the specified NFT
        <b>if</b> (nft_id == ask.nft_id) {
            <b>break</b>
        };

        index = index + 1;
    };

    <b>assert</b>!(index &lt; asks_count, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EOrderDoesNotExist">EOrderDoesNotExist</a>);

    <b>let</b> ask = <a href="_remove">vector::remove</a>(price_level, index);

    <b>if</b> (<a href="_length">vector::length</a>(price_level) == 0) {
        // <b>to</b> simplify impl, always delete empty price level
        <b>let</b> price_level = critbit::remove_leaf_by_index(asks, price_level_idx);
        <a href="_destroy_empty">vector::destroy_empty</a>(price_level);
    };

    ask
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_tick_level"></a>

## Function `assert_tick_level`



<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_tick_level">assert_tick_level</a>(price: u64, tick_size: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_tick_level">assert_tick_level</a>(price: u64, tick_size: u64) {
    <b>assert</b>!(<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_check_tick_level">check_tick_level</a>(price, tick_size), 0);
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_check_tick_level"></a>

## Function `check_tick_level`



<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_check_tick_level">check_tick_level</a>(price: u64, tick_size: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_check_tick_level">check_tick_level</a>(price: u64, tick_size: u64): bool {
    price &gt;= tick_size
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_version"></a>

## Function `assert_version`



<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_version">assert_version</a>&lt;T: store, key, FT&gt;(self: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_assert_version">assert_version</a>&lt;T: key + store, FT&gt;(self: &<a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;) {
    <b>assert</b>!(self.version == <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_VERSION">VERSION</a>, <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_EWrongVersion">EWrongVersion</a>);
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_migrate_as_creator"></a>

## Function `migrate_as_creator`



<pre><code>entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_migrate_as_creator">migrate_as_creator</a>&lt;T: store, key, FT&gt;(self: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, pub: &<a href="_Publisher">package::Publisher</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_migrate_as_creator">migrate_as_creator</a>&lt;T: key + store, FT&gt;(
    self: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    pub: &Publisher,
) {
    <b>assert</b>!(<a href="_from_package">package::from_package</a>&lt;T&gt;(pub), 0);
    self.version = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_VERSION">VERSION</a>;
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_migrate_as_pub"></a>

## Function `migrate_as_pub`



<pre><code>entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_migrate_as_pub">migrate_as_pub</a>&lt;T: store, key, FT&gt;(self: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">orderbook::Orderbook</a>&lt;T, FT&gt;, pub: &<a href="_Publisher">package::Publisher</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>entry <b>fun</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_migrate_as_pub">migrate_as_pub</a>&lt;T: key + store, FT&gt;(
    self: &<b>mut</b> <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_Orderbook">Orderbook</a>&lt;T, FT&gt;,
    pub: &Publisher,
) {
    <b>assert</b>!(<a href="_from_package">package::from_package</a>&lt;LIQUIDITY_LAYER&gt;(pub), 0);
    self.version = <a href="orderbook.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_orderbook_VERSION">VERSION</a>;
}
</code></pre>



</details>
