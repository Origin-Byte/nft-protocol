
<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price"></a>

# Module `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::fixed_price`

Module of <code><a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">FixedPriceMarket</a></code>

It implements a fixed price sale configuration, where all NFTs in the
inventory get sold at a fixed price.

NFT creators can decide to use multiple markets to create a tiered market
sale by segregating NFTs by different sale segments.


-  [Resource `FixedPriceMarket`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket)
-  [Struct `MarketKey`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_MarketKey)
-  [Function `new`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_new)
-  [Function `init_market`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_init_market)
-  [Function `init_venue`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_init_venue)
-  [Function `create_venue`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_create_venue)
-  [Function `borrow_market`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_borrow_market)
-  [Function `buy_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft)
-  [Function `buy_nft_into_kiosk`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft_into_kiosk)
-  [Function `buy_whitelisted_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_whitelisted_nft)
-  [Function `buy_whitelisted_nft_into_kiosk`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_whitelisted_nft_into_kiosk)
-  [Function `buy_nft_`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft_)
-  [Function `set_price`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_set_price)
-  [Function `price`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_price)


<pre><code><b>use</b> <a href="">0x2::balance</a>;
<b>use</b> <a href="">0x2::coin</a>;
<b>use</b> <a href="">0x2::kiosk</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk</a>;
<b>use</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing</a>;
<b>use</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::market_whitelist</a>;
<b>use</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::venue</a>;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket"></a>

## Resource `FixedPriceMarket`

Fixed price market object


<pre><code><b>struct</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">FixedPriceMarket</a>&lt;FT&gt; <b>has</b> store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="_UID">object::UID</a></code>
</dt>
<dd>
 <code><a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">FixedPriceMarket</a></code> ID
</dd>
<dt>
<code>price: u64</code>
</dt>
<dd>
 Fixed price denominated in fungible-token, <code>FT</code>
</dd>
<dt>
<code>inventory_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 <code>Warehouse</code> or <code>Factory</code> that the market will redeem from
</dd>
</dl>


</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_MarketKey"></a>

## Struct `MarketKey`



<pre><code><b>struct</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_MarketKey">MarketKey</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_new"></a>

## Function `new`

Create a new <code><a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">FixedPriceMarket</a>&lt;FT&gt;</code>

Price is denominated in fungible token, <code>FT</code>, such as SUI.

Requires that <code>Inventory</code> with given ID exists on the <code>Listing</code> that
this market will be inserted into.


<pre><code><b>public</b> <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_new">new</a>&lt;FT&gt;(inventory_id: <a href="_ID">object::ID</a>, price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">fixed_price::FixedPriceMarket</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_new">new</a>&lt;FT&gt;(
    inventory_id: ID,
    price: u64,
    ctx: &<b>mut</b> TxContext,
): <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">FixedPriceMarket</a>&lt;FT&gt; {
    <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">FixedPriceMarket</a> {
        id: <a href="_new">object::new</a>(ctx),
        price,
        inventory_id,
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_init_market"></a>

## Function `init_market`

Creates a <code><a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">FixedPriceMarket</a>&lt;FT&gt;</code> and transfers to transaction sender

Price is denominated in fungible token, <code>FT</code>, such as SUI.

Requires that <code>Inventory</code> with given ID exists on the <code>Listing</code> that
this market will be inserted into.

This market can later be consumed by <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_init_venue">listing::init_venue</a></code> or
<code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_init_venue">venue::init_venue</a></code> for later use in a launchpad listing.


<pre><code><b>public</b> entry <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_init_market">init_market</a>&lt;FT&gt;(inventory_id: <a href="_ID">object::ID</a>, price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_init_market">init_market</a>&lt;FT&gt;(
    inventory_id: ID,
    price: u64,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> market = <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_new">new</a>&lt;FT&gt;(inventory_id, price, ctx);
    <a href="_public_transfer">transfer::public_transfer</a>(market, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_init_venue"></a>

## Function `init_venue`

Initializes a <code>Venue</code> with <code><a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">FixedPriceMarket</a>&lt;FT&gt;</code>

Price is denominated in fungible token, <code>FT</code>, such as SUI.

Requires that <code>Inventory</code> with given ID exists on the <code>Listing</code> that
this market will be inserted into.

Resultant <code>Venue</code> can later be consumed by <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_venue">listing::add_venue</a></code> for
later use in a launchpad listing.


<a name="@Panics_0"></a>

###### Panics


Panics if <code>Inventory</code> with given ID does not exist on <code>Listing</code> or
if transaction sender is not the <code>Listing</code> admin.


<pre><code><b>public</b> entry <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_init_venue">init_venue</a>&lt;C, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>, is_whitelisted: bool, price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_init_venue">init_venue</a>&lt;C, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    inventory_id: ID,
    is_whitelisted: bool,
    price: u64,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_create_venue">create_venue</a>&lt;C, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id, is_whitelisted, price, ctx);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_create_venue"></a>

## Function `create_venue`

Creates a <code>Venue</code> with <code><a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">FixedPriceMarket</a>&lt;FT&gt;</code>

Price is denominated in fungible token, <code>FT</code>, such as SUI.

Requires that <code>Inventory</code> with given ID exists on the <code>Listing</code> that
this market will be inserted into.

Resultant <code>Venue</code> can later be consumed by <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_venue">listing::add_venue</a></code> for
later use in a launchpad listing.


<a name="@Panics_1"></a>

###### Panics


Panics if <code>Inventory</code> with given ID does not exist on <code>Listing</code> or
if transaction sender is not the <code>Listing</code> admin.


<pre><code><b>public</b> <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_create_venue">create_venue</a>&lt;C, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>, is_whitelisted: bool, price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_create_venue">create_venue</a>&lt;C, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    inventory_id: ID,
    is_whitelisted: bool,
    price: u64,
    ctx: &<b>mut</b> TxContext,
): ID {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_inventory">listing::assert_inventory</a>&lt;C&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id);

    <b>let</b> market = <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_new">new</a>&lt;FT&gt;(inventory_id, price, ctx);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_create_venue">listing::create_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_MarketKey">MarketKey</a> {}, market, is_whitelisted, ctx)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_borrow_market"></a>

## Function `borrow_market`

Borrows <code><a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">FixedPriceMarket</a>&lt;FT&gt;</code> from <code>Venue</code>


<pre><code><b>public</b> <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_borrow_market">borrow_market</a>&lt;FT&gt;(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>): &<a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">fixed_price::FixedPriceMarket</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_borrow_market">borrow_market</a>&lt;FT&gt;(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &Venue): &<a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">FixedPriceMarket</a>&lt;FT&gt; {
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market">venue::borrow_market</a>(<a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_MarketKey">MarketKey</a> {}, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft"></a>

## Function `buy_nft`

Buy NFT for non-whitelisted sale into new Kiosk


<a name="@Panics_2"></a>

###### Panics


Panics if <code>Venue</code> does not exist, is not live, or is whitelisted or
wallet does not have the necessary funds.


<pre><code><b>public</b> entry <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft">buy_nft</a>&lt;T: store, key, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft">buy_nft</a>&lt;T: key + store, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue">listing::borrow_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_live">venue::assert_is_live</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_not_whitelisted">venue::assert_is_not_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);

    <b>let</b> nft =
        <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft_">buy_nft_</a>&lt;T, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id, <a href="_balance_mut">coin::balance_mut</a>(wallet), ctx);
    <a href="_public_transfer">transfer::public_transfer</a>(nft, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft_into_kiosk"></a>

## Function `buy_nft_into_kiosk`

Buy NFT for non-whitelisted sale


<a name="@Panics_3"></a>

###### Panics


Panics if <code>Venue</code> does not exist, is not live, or is whitelisted or
wallet does not have the necessary funds.


<pre><code><b>public</b> entry <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft_into_kiosk">buy_nft_into_kiosk</a>&lt;T: store, key, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft_into_kiosk">buy_nft_into_kiosk</a>&lt;T: key + store, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    buyer_kiosk: &<b>mut</b> Kiosk,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue">listing::borrow_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_live">venue::assert_is_live</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_not_whitelisted">venue::assert_is_not_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);

    <b>let</b> nft =
        <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft_">buy_nft_</a>&lt;T, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id, <a href="_balance_mut">coin::balance_mut</a>(wallet), ctx);
    <a href="_deposit">ob_kiosk::deposit</a>(buyer_kiosk, nft, ctx);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_whitelisted_nft"></a>

## Function `buy_whitelisted_nft`

Buy NFT for whitelisted sale into new Kiosk


<a name="@Panics_4"></a>

###### Panics


- If <code>Venue</code> does not exist, is not live, or is not whitelisted
- If whitelist <code>Certificate</code> was not issued for given market


<pre><code><b>public</b> entry <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_whitelisted_nft">buy_whitelisted_nft</a>&lt;T: store, key, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, whitelist_token: <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">market_whitelist::Certificate</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_whitelisted_nft">buy_whitelisted_nft</a>&lt;T: key + store, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    whitelist_token: Certificate,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> (<a href="">kiosk</a>, _) = <a href="_new">ob_kiosk::new</a>(ctx);
    <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_whitelisted_nft_into_kiosk">buy_whitelisted_nft_into_kiosk</a>&lt;T, FT&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id, wallet, &<b>mut</b> <a href="">kiosk</a>, whitelist_token, ctx,
    );
    <a href="_public_share_object">transfer::public_share_object</a>(<a href="">kiosk</a>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_whitelisted_nft_into_kiosk"></a>

## Function `buy_whitelisted_nft_into_kiosk`

Buy NFT for whitelisted sale
Deposits the NFT to a kiosk


<a name="@Panics_5"></a>

###### Panics


- If <code>Venue</code> does not exist, is not live, or is not whitelisted
- If whitelist <code>Certificate</code> was not issued for given market


<pre><code><b>public</b> entry <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_whitelisted_nft_into_kiosk">buy_whitelisted_nft_into_kiosk</a>&lt;T: store, key, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, safe: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, whitelist_token: <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">market_whitelist::Certificate</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_whitelisted_nft_into_kiosk">buy_whitelisted_nft_into_kiosk</a>&lt;T: key + store, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    safe: &<b>mut</b> Kiosk,
    whitelist_token: Certificate,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue">listing::borrow_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_live">venue::assert_is_live</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);
    <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_assert_whitelist">market_whitelist::assert_whitelist</a>(&whitelist_token, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);
    <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_burn">market_whitelist::burn</a>(whitelist_token);

    <b>let</b> nft =
        <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft_">buy_nft_</a>&lt;T, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id, <a href="_balance_mut">coin::balance_mut</a>(wallet), ctx);
    <a href="_deposit">ob_kiosk::deposit</a>(safe, nft, ctx);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft_"></a>

## Function `buy_nft_`

Internal method to buy NFT


<a name="@Panics_6"></a>

###### Panics


Panics if <code>Venue</code> or associated <code>Inventory</code> does not exist or wallet
does not have required funds.


<pre><code><b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft_">buy_nft_</a>&lt;T: store, key, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, <a href="">balance</a>: &<b>mut</b> <a href="_Balance">balance::Balance</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_buy_nft_">buy_nft_</a>&lt;T: key + store, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    <a href="">balance</a>: &<b>mut</b> Balance&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): T {
    <b>let</b> market = <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_borrow_market">borrow_market</a>&lt;FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue">listing::borrow_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id));

    <b>let</b> price = market.price;
    <b>let</b> inventory_id = market.inventory_id;

    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_buy_pseudorandom_nft">listing::buy_pseudorandom_nft</a>&lt;T, FT, <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">FixedPriceMarket</a>&lt;FT&gt;, <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_MarketKey">MarketKey</a>&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>,
        <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_MarketKey">MarketKey</a> {},
        inventory_id,
        venue_id,
        <a href="_sender">tx_context::sender</a>(ctx),
        <a href="_split">balance::split</a>(<a href="">balance</a>, price),
        ctx,
    )
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_set_price"></a>

## Function `set_price`

Change market price


<a name="@Panics_7"></a>

###### Panics


Panics if transaction sender is not <code>Listing</code> admin.


<pre><code><b>public</b> entry <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_set_price">set_price</a>&lt;FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, new_price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_set_price">set_price</a>&lt;FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    new_price: u64,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">listing::assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);

    <b>let</b> market: &<b>mut</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">FixedPriceMarket</a>&lt;FT&gt; = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_market_internal_mut">listing::market_internal_mut</a>(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_MarketKey">MarketKey</a> {}, venue_id
    );

    market.price = new_price;
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_price"></a>

## Function `price`

Return market price


<pre><code><b>public</b> <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_price">price</a>&lt;FT&gt;(market: &<a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">fixed_price::FixedPriceMarket</a>&lt;FT&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_price">price</a>&lt;FT&gt;(market: &<a href="fixed_price.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_fixed_price_FixedPriceMarket">FixedPriceMarket</a>&lt;FT&gt;): u64 {
    market.price
}
</code></pre>



</details>
