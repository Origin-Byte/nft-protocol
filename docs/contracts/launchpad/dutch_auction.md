
<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction"></a>

# Module `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::dutch_auction`

Module of a Dutch Auction Sale <code>Market</code> type.

It implements a dutch auction sale configuration, where all NFTs in the sale
warehouse get sold to the winners of the auction. The number of winners

NFT creators can decide if they want to create a simple primary market sale
or if they want to create a tiered market sale by segregating NFTs by
different sale segments (e.g. based on rarity).

To create a market sale the administrator can simply call <code>create_market</code>.
Each sale segment can have a whitelisting process, each with their own
whitelist tokens.


-  [Resource `DutchAuctionMarket`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket)
-  [Struct `Bid`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid)
-  [Struct `MarketKey`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey)
-  [Constants](#@Constants_0)
-  [Function `new`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_new)
-  [Function `init_market`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_init_market)
-  [Function `init_venue`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_init_venue)
-  [Function `create_venue`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_venue)
-  [Function `borrow_market`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_borrow_market)
-  [Function `create_bid`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_bid)
-  [Function `create_bid_whitelisted`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_bid_whitelisted)
-  [Function `cancel_bid`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_cancel_bid)
-  [Function `sale_cancel`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_sale_cancel)
-  [Function `sale_conclude`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_sale_conclude)
-  [Function `reserve_price`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_reserve_price)
-  [Function `bids`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_bids)
-  [Function `bid_owner`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_bid_owner)
-  [Function `bid_amount`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_bid_amount)
-  [Function `create_bid_`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_bid_)
-  [Function `cancel_bid_`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_cancel_bid_)
-  [Function `cancel_auction`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_cancel_auction)
-  [Function `refund_bid`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_refund_bid)
-  [Function `conclude_auction`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_conclude_auction)


<pre><code><b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x2::balance</a>;
<b>use</b> <a href="">0x2::coin</a>;
<b>use</b> <a href="">0x2::kiosk</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::crit_bit</a>;
<b>use</b> <a href="">0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk</a>;
<b>use</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::inventory</a>;
<b>use</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing</a>;
<b>use</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::market_whitelist</a>;
<b>use</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::venue</a>;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket"></a>

## Resource `DutchAuctionMarket`



<pre><code><b>struct</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt; <b>has</b> store, key
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
<code>reserve_price: u64</code>
</dt>
<dd>
 The minimum price at which NFTs can be sold
</dd>
<dt>
<code>bids: <a href="_CritbitTree">crit_bit::CritbitTree</a>&lt;<a href="">vector</a>&lt;<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">dutch_auction::Bid</a>&lt;FT&gt;&gt;&gt;</code>
</dt>
<dd>
 A bid order stores the amount of fungible token, FT, that the
 buyer is willing to purchase.
</dd>
<dt>
<code>inventory_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 <code>Warehouse</code> or <code>Factory</code> that the market will redeem from
</dd>
</dl>


</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid"></a>

## Struct `Bid`

A bid for one NFT


<pre><code><b>struct</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">Bid</a>&lt;FT&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>amount: <a href="_Balance">balance::Balance</a>&lt;FT&gt;</code>
</dt>
<dd>
 Amount is equal to the price that the bidder is ready to pay for
 one NFT.
</dd>
<dt>
<code>owner: <b>address</b></code>
</dt>
<dd>
 The address of the user who created this bid and who will receive
 an NFT in exchange for their tokens.
</dd>
</dl>


</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey"></a>

## Struct `MarketKey`



<pre><code><b>struct</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="@Constants_0"></a>

## Constants


<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_EInvalidOrder"></a>

Order was not found


<pre><code><b>const</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_EInvalidOrder">EInvalidOrder</a>: u64 = 2;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_EInvalidSender"></a>

Transaction sender must be order owner


<pre><code><b>const</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_EInvalidSender">EInvalidSender</a>: u64 = 3;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_EOrderPriceBelowReserve"></a>

Order price was below auction reserve price


<pre><code><b>const</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_EOrderPriceBelowReserve">EOrderPriceBelowReserve</a>: u64 = 1;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_U64_MAX"></a>



<pre><code><b>const</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_U64_MAX">U64_MAX</a>: u64 = 18446744073709551615;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_new"></a>

## Function `new`



<pre><code><b>public</b> <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_new">new</a>&lt;FT&gt;(inventory_id: <a href="_ID">object::ID</a>, reserve_price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">dutch_auction::DutchAuctionMarket</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_new">new</a>&lt;FT&gt;(
    inventory_id: ID,
    reserve_price: u64,
    ctx: &<b>mut</b> TxContext,
): <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt; {
    <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a> {
        id: <a href="_new">object::new</a>(ctx),
        reserve_price,
        bids: <a href="_new">crit_bit::new</a>(ctx),
        inventory_id,
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_init_market"></a>

## Function `init_market`

Creates a <code><a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt;</code> and transfers to transaction sender


<pre><code><b>public</b> entry <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_init_market">init_market</a>&lt;FT&gt;(inventory_id: <a href="_ID">object::ID</a>, reserve_price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_init_market">init_market</a>&lt;FT&gt;(
    inventory_id: ID,
    reserve_price: u64,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> market = <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_new">new</a>&lt;FT&gt;(inventory_id, reserve_price, ctx);
    <a href="_public_transfer">transfer::public_transfer</a>(market, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_init_venue"></a>

## Function `init_venue`

Initializes a <code>Venue</code> with <code><a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt;</code>


<pre><code><b>public</b> entry <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_init_venue">init_venue</a>&lt;T, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>, is_whitelisted: bool, reserve_price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_init_venue">init_venue</a>&lt;T, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    inventory_id: ID,
    is_whitelisted: bool,
    reserve_price: u64,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_venue">create_venue</a>&lt;T, FT&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id, is_whitelisted, reserve_price, ctx
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_venue"></a>

## Function `create_venue`

Creates a <code>Venue</code> with <code><a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt;</code>


<pre><code><b>public</b> <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_venue">create_venue</a>&lt;T, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>, is_whitelisted: bool, reserve_price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_venue">create_venue</a>&lt;T, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    inventory_id: ID,
    is_whitelisted: bool,
    reserve_price: u64,
    ctx: &<b>mut</b> TxContext,
): ID {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_inventory">listing::assert_inventory</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id);

    <b>let</b> market = <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_new">new</a>&lt;FT&gt;(inventory_id, reserve_price, ctx);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_create_venue">listing::create_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a> {}, market, is_whitelisted, ctx)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_borrow_market"></a>

## Function `borrow_market`

Borrows <code><a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt;</code> from <code>Venue</code>


<pre><code><b>public</b> <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_borrow_market">borrow_market</a>&lt;FT&gt;(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>): &<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">dutch_auction::DutchAuctionMarket</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_borrow_market">borrow_market</a>&lt;FT&gt;(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &Venue): &<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt; {
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market">venue::borrow_market</a>(<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a> {}, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_bid"></a>

## Function `create_bid`

Creates a bid in a FIFO manner, previous bids are retained


<pre><code><b>public</b> entry <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_bid">create_bid</a>&lt;FT&gt;(wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, price: u64, quantity: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_bid">create_bid</a>&lt;FT&gt;(
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    price: u64,
    quantity: u64,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_venue_internal_mut">listing::venue_internal_mut</a>&lt;<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt;, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a>&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a> {}, venue_id
    );

    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_live">venue::assert_is_live</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_not_whitelisted">venue::assert_is_not_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);

    <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_bid_">create_bid_</a>(
        <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market_mut">venue::borrow_market_mut</a>(<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a> {}, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>),
        wallet,
        price,
        quantity,
        <a href="_sender">tx_context::sender</a>(ctx)
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_bid_whitelisted"></a>

## Function `create_bid_whitelisted`



<pre><code><b>public</b> entry <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_bid_whitelisted">create_bid_whitelisted</a>&lt;FT&gt;(wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, whitelist_token: <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">market_whitelist::Certificate</a>, price: u64, quantity: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_bid_whitelisted">create_bid_whitelisted</a>&lt;FT&gt;(
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    whitelist_token: Certificate,
    price: u64,
    quantity: u64,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_venue_internal_mut">listing::venue_internal_mut</a>&lt;<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt;, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a>&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a> {}, venue_id
    );

    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_live">venue::assert_is_live</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_whitelisted">venue::assert_is_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);

    <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_assert_certificate">market_whitelist::assert_certificate</a>(&whitelist_token, venue_id);

    <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_bid_">create_bid_</a>(
        <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market_mut">venue::borrow_market_mut</a>(<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a> {}, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>),
        wallet,
        price,
        quantity,
        <a href="_sender">tx_context::sender</a>(ctx)
    );

    <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_burn">market_whitelist::burn</a>(whitelist_token);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_cancel_bid"></a>

## Function `cancel_bid`

Cancels a single bid at the given price level in a FIFO manner

Bids can always be canceled no matter whether the auction is live.


<pre><code><b>public</b> entry <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_cancel_bid">cancel_bid</a>&lt;FT&gt;(wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_cancel_bid">cancel_bid</a>&lt;FT&gt;(
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    price: u64,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> market: &<b>mut</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt; = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_market_internal_mut">listing::market_internal_mut</a>(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a> {}, venue_id
    );

    <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_cancel_bid_">cancel_bid_</a>(market, wallet, price, <a href="_sender">tx_context::sender</a>(ctx))
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_sale_cancel"></a>

## Function `sale_cancel`

Cancel the auction and toggle the Slingshot's <code>live</code> to <code><b>false</b></code>.
All bids will be cancelled and refunded.

Permissioned endpoint to be called by <code>admin</code>.


<pre><code><b>public</b> entry <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_sale_cancel">sale_cancel</a>&lt;FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_sale_cancel">sale_cancel</a>&lt;FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    ctx: &<b>mut</b> TxContext,
) {
    // TODO: Consider an entrypoint <b>to</b> be called by the Marketplace instead of
    // the <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a> admin
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">listing::assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);

    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_venue_internal_mut">listing::venue_internal_mut</a>&lt;<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt;, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a>&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a> {}, venue_id
    );

    <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_cancel_auction">cancel_auction</a>&lt;FT&gt;(
        <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market_mut">venue::borrow_market_mut</a>(<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a> {}, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>),
        ctx,
    );

    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_set_live">venue::set_live</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>, <b>false</b>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_sale_conclude"></a>

## Function `sale_conclude`

Conclude the auction and toggle the Slingshot's <code>live</code> to <code><b>false</b></code>.
NFTs will be allocated to the winning biddeers.

Permissioned endpoint to be called by <code>admin</code>.


<pre><code><b>public</b> entry <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_sale_conclude">sale_conclude</a>&lt;T: store, key, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_sale_conclude">sale_conclude</a>&lt;T: key + store, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    ctx: &<b>mut</b> TxContext,
) {
    // TODO: Consider an entrypoint <b>to</b> be called by the Marketplace instead
    // of the <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a> admin
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">listing::assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);

    // Determine how much <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a> there is <b>to</b> sell
    <b>let</b> market = <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_borrow_market">borrow_market</a>&lt;FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue">listing::borrow_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id));

    <b>let</b> inventory_id = market.inventory_id;
    <b>let</b> supply = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_supply">listing::supply</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id);

    // Auction could be drawing from an <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a> <b>with</b> unregulated supply
    <b>let</b> nfts_to_sell = <b>if</b> (<a href="_is_some">option::is_some</a>(&supply)) {
        <a href="_destroy_some">option::destroy_some</a>(supply)
    } <b>else</b> {
        // NFTs sold will be ultimately limited by the amount of bids
        // therefore it is safe <b>to</b> <b>return</b> maximum number.
        <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_U64_MAX">U64_MAX</a>
    };

    // Determine matching orders
    <b>let</b> market: &<b>mut</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt; = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_market_internal_mut">listing::market_internal_mut</a>(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a> {}, venue_id
    );

    // TODO(https://github.com/Origin-Byte/nft-protocol/issues/63):
    // Investigate whether this logic should be paginated
    <b>let</b> (fill_price, bids_to_fill) =
        <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_conclude_auction">conclude_auction</a>&lt;FT&gt;(market, nfts_to_sell);

    // Transfer NFTs <b>to</b> matching orders
    <b>let</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_internal_mut">listing::inventory_internal_mut</a>&lt;T, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt;, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a>&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_MarketKey">MarketKey</a> {}, venue_id, inventory_id
    );

    <b>let</b> total_funds = <a href="_zero">balance::zero</a>&lt;FT&gt;();
    <b>while</b> (!<a href="_is_empty">vector::is_empty</a>(&bids_to_fill)) {
        <b>let</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">Bid</a> { amount, owner } = <a href="_pop_back">vector::pop_back</a>(&<b>mut</b> bids_to_fill);

        <b>let</b> filled_funds = <a href="_split">balance::split</a>(&<b>mut</b> amount, fill_price);

        <a href="_join">balance::join</a>&lt;FT&gt;(&<b>mut</b> total_funds, filled_funds);

        <b>let</b> nft = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_pseudorandom_nft">inventory::redeem_pseudorandom_nft</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>, ctx);

        // Since we do not know the users Kiosk, create a new one for them
        <b>let</b> (<a href="">kiosk</a>, _) = <a href="_new">ob_kiosk::new</a>(ctx);
        <a href="_deposit">ob_kiosk::deposit</a>(&<b>mut</b> <a href="">kiosk</a>, nft, ctx);
        <a href="_public_share_object">transfer::public_share_object</a>(<a href="">kiosk</a>);

        <b>if</b> (<a href="_value">balance::value</a>(&amount) == 0) {
            <a href="_destroy_zero">balance::destroy_zero</a>(amount);
        } <b>else</b> {
            // Transfer bidding coins back <b>to</b> bid owner
            <a href="_public_transfer">transfer::public_transfer</a>(<a href="_from_balance">coin::from_balance</a>(amount, ctx), owner);
        };
    };

    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_pay">listing::pay</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, total_funds, nfts_to_sell);

    <a href="_destroy_empty">vector::destroy_empty</a>(bids_to_fill);

    // Cancel all remaining orders <b>if</b> there are no NFTs left <b>to</b> sell
    <b>let</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_inventory">listing::borrow_inventory</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id);
    <b>if</b> (<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_is_empty">inventory::is_empty</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>)) {
        <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_sale_cancel">sale_cancel</a>&lt;FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id, ctx);
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_reserve_price"></a>

## Function `reserve_price`

Get the auction's reserve price


<pre><code><b>public</b> <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_reserve_price">reserve_price</a>&lt;FT&gt;(market: &<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">dutch_auction::DutchAuctionMarket</a>&lt;FT&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_reserve_price">reserve_price</a>&lt;FT&gt;(market: &<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt;): u64 {
    market.reserve_price
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_bids"></a>

## Function `bids`

Get the auction's bids


<pre><code><b>public</b> <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_bids">bids</a>&lt;FT&gt;(market: &<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">dutch_auction::DutchAuctionMarket</a>&lt;FT&gt;): &<a href="_CritbitTree">crit_bit::CritbitTree</a>&lt;<a href="">vector</a>&lt;<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">dutch_auction::Bid</a>&lt;FT&gt;&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_bids">bids</a>&lt;FT&gt;(market: &<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt;): &CritbitTree&lt;<a href="">vector</a>&lt;<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">Bid</a>&lt;FT&gt;&gt;&gt; {
    &market.bids
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_bid_owner"></a>

## Function `bid_owner`



<pre><code><b>public</b> <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_bid_owner">bid_owner</a>&lt;FT&gt;(bid: &<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">dutch_auction::Bid</a>&lt;FT&gt;): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_bid_owner">bid_owner</a>&lt;FT&gt;(bid: &<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">Bid</a>&lt;FT&gt;): <b>address</b> {
    bid.owner
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_bid_amount"></a>

## Function `bid_amount`



<pre><code><b>public</b> <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_bid_amount">bid_amount</a>&lt;FT&gt;(bid: &<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">dutch_auction::Bid</a>&lt;FT&gt;): &<a href="_Balance">balance::Balance</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_bid_amount">bid_amount</a>&lt;FT&gt;(bid: &<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">Bid</a>&lt;FT&gt;): &Balance&lt;FT&gt; {
    &bid.amount
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_bid_"></a>

## Function `create_bid_`



<pre><code><b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_bid_">create_bid_</a>&lt;FT&gt;(auction: &<b>mut</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">dutch_auction::DutchAuctionMarket</a>&lt;FT&gt;, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, price: u64, quantity: u64, owner: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_create_bid_">create_bid_</a>&lt;FT&gt;(
    auction: &<b>mut</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt;,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    price: u64,
    quantity: u64,
    owner: <b>address</b>,
) {
    <b>assert</b>!(
        price &gt;= auction.reserve_price,
        <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_EOrderPriceBelowReserve">EOrderPriceBelowReserve</a>
    );

    // Create price level <b>if</b> it does not exist
    <b>let</b> (has_key, _) = <a href="_find_leaf">crit_bit::find_leaf</a>(&auction.bids, price);

    <b>if</b> (!has_key) {
        <a href="_insert_leaf">crit_bit::insert_leaf</a>(
            &<b>mut</b> auction.bids,
            price,
            <a href="_empty">vector::empty</a>()
        );
    };

    <b>let</b> price_level =
        <a href="_borrow_mut_leaf_by_key">crit_bit::borrow_mut_leaf_by_key</a>(&<b>mut</b> auction.bids, price);

    // Make `quantity` number of bids
    <b>let</b> index = 0;
    <b>while</b> (quantity &gt; index) {
        <b>let</b> amount = <a href="_split">balance::split</a>(<a href="_balance_mut">coin::balance_mut</a>(wallet), price);
        <a href="_push_back">vector::push_back</a>(price_level, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">Bid</a> { amount, owner });
        index = index + 1;
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_cancel_bid_"></a>

## Function `cancel_bid_`

Cancels a single order in a FIFO manner


<pre><code><b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_cancel_bid_">cancel_bid_</a>&lt;FT&gt;(auction: &<b>mut</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">dutch_auction::DutchAuctionMarket</a>&lt;FT&gt;, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, price: u64, sender: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_cancel_bid_">cancel_bid_</a>&lt;FT&gt;(
    auction: &<b>mut</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt;,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    price: u64,
    sender: <b>address</b>,
) {
    <b>let</b> bids = &<b>mut</b> auction.bids;

    <b>let</b> (has_leaf, _) = <a href="_find_leaf">crit_bit::find_leaf</a>(bids, price);

    <b>assert</b>!(has_leaf, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_EInvalidOrder">EInvalidOrder</a>);

    <b>let</b> price_level = <a href="_borrow_mut_leaf_by_key">crit_bit::borrow_mut_leaf_by_key</a>(bids, price);

    <b>let</b> bid_index = 0;
    <b>let</b> bid_count = <a href="_length">vector::length</a>(price_level);
    <b>while</b> (bid_count &gt; bid_index) {
        <b>let</b> bid = <a href="_borrow">vector::borrow</a>(price_level, bid_index);
        <b>if</b> (bid.owner == sender) {
            <b>break</b>
        };

        bid_index = bid_index + 1;
    };

    <b>assert</b>!(bid_index &lt; bid_count, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_EInvalidSender">EInvalidSender</a>);

    <b>let</b> bid = <a href="_remove">vector::remove</a>(price_level, bid_index);
    <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_refund_bid">refund_bid</a>(bid, wallet, &sender);

    <b>if</b> (<a href="_is_empty">vector::is_empty</a>(price_level)) {
        <b>let</b> price_level = <a href="_remove_leaf_by_key">crit_bit::remove_leaf_by_key</a>(bids, price);
        <a href="_destroy_empty">vector::destroy_empty</a>(price_level);
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_cancel_auction"></a>

## Function `cancel_auction`



<pre><code><b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_cancel_auction">cancel_auction</a>&lt;FT&gt;(book: &<b>mut</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">dutch_auction::DutchAuctionMarket</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_cancel_auction">cancel_auction</a>&lt;FT&gt;(
    book: &<b>mut</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> bids = &<b>mut</b> book.bids;

    <b>while</b> (!<a href="_is_empty">crit_bit::is_empty</a>(bids)) {
        <b>let</b> (min_key, _) = <a href="_max_leaf">crit_bit::max_leaf</a>(bids);
        <b>let</b> price_level = <a href="_remove_leaf_by_key">crit_bit::remove_leaf_by_key</a>(bids, min_key);
        <b>while</b> (!<a href="_is_empty">vector::is_empty</a>(&price_level)) {
            <b>let</b> bid = <a href="_pop_back">vector::pop_back</a>(&<b>mut</b> price_level);

            // Since we do not have access <b>to</b> the original wallet
            // we must create a wallet wherein the bidder can be refunded.
            <b>let</b> wallet = <a href="_zero">coin::zero</a>(ctx);
            <b>let</b> owner = bid.owner;
            <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_refund_bid">refund_bid</a>(bid, &<b>mut</b> wallet, &owner);

            <a href="_public_transfer">transfer::public_transfer</a>(wallet, owner);
        };

        <a href="_destroy_empty">vector::destroy_empty</a>(price_level);
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_refund_bid"></a>

## Function `refund_bid`



<pre><code><b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_refund_bid">refund_bid</a>&lt;FT&gt;(bid: <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">dutch_auction::Bid</a>&lt;FT&gt;, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, sender: &<b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_refund_bid">refund_bid</a>&lt;FT&gt;(
    bid: <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">Bid</a>&lt;FT&gt;,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    sender: &<b>address</b>,
) {
    <b>let</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">Bid</a> { amount, owner } = bid;
    <b>assert</b>!(sender == &owner, <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_EInvalidSender">EInvalidSender</a>);

    <a href="_join">balance::join</a>(<a href="_balance_mut">coin::balance_mut</a>(wallet), amount);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_conclude_auction"></a>

## Function `conclude_auction`

Returns the fill_price and bids that must be filled


<pre><code><b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_conclude_auction">conclude_auction</a>&lt;FT&gt;(auction: &<b>mut</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">dutch_auction::DutchAuctionMarket</a>&lt;FT&gt;, nfts_to_sell: u64): (u64, <a href="">vector</a>&lt;<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">dutch_auction::Bid</a>&lt;FT&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_conclude_auction">conclude_auction</a>&lt;FT&gt;(
    auction: &<b>mut</b> <a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_DutchAuctionMarket">DutchAuctionMarket</a>&lt;FT&gt;,
    // Use <b>to</b> specify how many NFTs will be transfered <b>to</b> the winning bids
    // during the `conclude_auction`. This functionality is used <b>to</b> avoid
    // hitting computational costs during large auction sales.
    //
    // To conclude the entire auction, the total number of NFTs in the sale
    // should be passed.
    nfts_to_sell: u64,
): (u64, <a href="">vector</a>&lt;<a href="dutch_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_dutch_auction_Bid">Bid</a>&lt;FT&gt;&gt;) {
    <b>let</b> bids = &<b>mut</b> auction.bids;

    <b>let</b> fill_price = 0;
    <b>let</b> bids_to_fill = <a href="_empty">vector::empty</a>();
    <b>while</b> (nfts_to_sell &gt; 0 && !<a href="_is_empty">crit_bit::is_empty</a>(bids)) {
        // Get key of maximum price level representing the price level from
        // which the next winning bid is extracted.
        <b>let</b> (max_key, _) = <a href="_max_leaf">crit_bit::max_leaf</a>(bids);
        <b>let</b> price_level = <a href="_borrow_mut_leaf_by_key">crit_bit::borrow_mut_leaf_by_key</a>(bids, max_key);

        <b>if</b> (<a href="_is_empty">vector::is_empty</a>(price_level)) {
            <b>let</b> price_level = <a href="_remove_leaf_by_key">crit_bit::remove_leaf_by_key</a>(bids, max_key);
            <a href="_destroy_empty">vector::destroy_empty</a>(price_level);
            <b>continue</b>
        };

        // There <b>exists</b> a bid we can match <b>to</b> an NFT
        // Match in FIFO order
        <b>let</b> bid = <a href="_remove">vector::remove</a>(price_level, 0);

        fill_price = max_key;
        nfts_to_sell = nfts_to_sell - 1;
        <a href="_push_back">vector::push_back</a>(&<b>mut</b> bids_to_fill, bid);
    };

    (fill_price, bids_to_fill)
}
</code></pre>



</details>
