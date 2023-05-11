
<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue"></a>

# Module `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::venue`

Module representing the market <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> type

<code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> allows creator to configure a primary market through which
their collection will be sold. <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> enforces that all purchases made
through it will draw from an inventory determined at construction.

<code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> is an unprotected type that composes the market structure of
<code>Listing</code>.


-  [Resource `Venue`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue)
-  [Constants](#@Constants_0)
-  [Function `new`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_new)
-  [Function `init_venue`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_init_venue)
-  [Function `set_live`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_set_live)
-  [Function `set_whitelisted`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_set_whitelisted)
-  [Function `is_live`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_is_live)
-  [Function `is_whitelisted`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_is_whitelisted)
-  [Function `borrow_market`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market)
-  [Function `borrow_market_mut`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market_mut)
-  [Function `delete`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_delete)
-  [Function `assert_market`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_market)
-  [Function `assert_is_live`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_live)
-  [Function `assert_is_whitelisted`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_whitelisted)
-  [Function `assert_is_not_whitelisted`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_not_whitelisted)


<pre><code><b>use</b> <a href="">0x2::dynamic_field</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue"></a>

## Resource `Venue`

<code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> object

<code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> is a thin wrapper around a generic <code>Market</code> that handles
tracking live status and whitelist assertions. <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> itself is not
generic as to not require knowledge of the underlying market to
perform administrative operations.

<code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> is unprotected and relies on safely obtaining a mutable
reference.


<pre><code><b>struct</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a> <b>has</b> store, key
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
<code>is_live: bool</code>
</dt>
<dd>
 Track whether market is live
</dd>
<dt>
<code>is_whitelisted: bool</code>
</dt>
<dd>
 Track which market is whitelisted
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_EVenueIncorrectMarketType"></a>

<code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> market accessed with incorrect type

Ensure that the type argument provided to <code>Venue::borrow_market</code>
corresponds to the underlying market.


<pre><code><b>const</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_EVenueIncorrectMarketType">EVenueIncorrectMarketType</a>: u64 = 4;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_EVenueNotLive"></a>

<code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> is not live

Call <code>Venue::set_live</code> or <code>Listing::sale_on</code> to make it live.


<pre><code><b>const</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_EVenueNotLive">EVenueNotLive</a>: u64 = 1;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_EVenueNotWhitelisted"></a>

<code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> not whitelisted

Ensure that <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> is whitelisted when calling <code>Venue::new</code> or call
<code>Venue::set_whitelisted</code>.


<pre><code><b>const</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_EVenueNotWhitelisted">EVenueNotWhitelisted</a>: u64 = 3;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_EVenueWhitelisted"></a>

<code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> whitelisted

Ensure that <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> is not whitelisted when calling <code>Venue::new</code> or
call <code>Venue::set_whitelisted</code>.


<pre><code><b>const</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_EVenueWhitelisted">EVenueWhitelisted</a>: u64 = 2;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_new"></a>

## Function `new`

Create a new <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_new">new</a>&lt;Market: store, MarketKey: <b>copy</b>, drop, store&gt;(key: MarketKey, market: Market, is_whitelisted: bool, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_new">new</a>&lt;Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    key: MarketKey,
    market: Market,
    is_whitelisted: bool,
    ctx: &<b>mut</b> TxContext
): <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a> {
    <b>let</b> venue_id = <a href="_new">object::new</a>(ctx);
    df::add(&<b>mut</b> venue_id, key, market);

    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a> {
        id: venue_id,
        is_live: <b>false</b>,
        is_whitelisted,
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_init_venue"></a>

## Function `init_venue`

Initializes a <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> and transfers to transaction sender


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_init_venue">init_venue</a>&lt;Market: store, MarketKey: <b>copy</b>, drop, store&gt;(key: MarketKey, market: Market, is_whitelisted: bool, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_init_venue">init_venue</a>&lt;Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    key: MarketKey,
    market: Market,
    is_whitelisted: bool,
    ctx: &<b>mut</b> TxContext
) {
    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a> = <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_new">new</a>(key, market, is_whitelisted, ctx);
    <a href="_public_transfer">transfer::public_transfer</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_set_live"></a>

## Function `set_live`

Set market's live status


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_set_live">set_live</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<b>mut</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>, is_live: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_set_live">set_live</a>(
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<b>mut</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a>,
    is_live: bool,
) {
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>.is_live = is_live;
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_set_whitelisted"></a>

## Function `set_whitelisted`

Set market's whitelist status


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_set_whitelisted">set_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<b>mut</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>, is_whitelisted: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_set_whitelisted">set_whitelisted</a>(
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<b>mut</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a>,
    is_whitelisted: bool,
) {
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>.is_whitelisted = is_whitelisted;
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_is_live"></a>

## Function `is_live`

Get whether the venue is live


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_is_live">is_live</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_is_live">is_live</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a>): bool {
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>.is_live
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_is_whitelisted"></a>

## Function `is_whitelisted`

Get whether the venue is whitelisted


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_is_whitelisted">is_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_is_whitelisted">is_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a>): bool {
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>.is_whitelisted
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market"></a>

## Function `borrow_market`

Borrow <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> market


<a name="@Panics_1"></a>

###### Panics


Panics if incorrect type was provided for the underlying market.


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market">borrow_market</a>&lt;Market: store, MarketKey: <b>copy</b>, drop, store&gt;(key: MarketKey, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>): &Market
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market">borrow_market</a>&lt;Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    key: MarketKey,
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a>,
): &Market {
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_market">assert_market</a>&lt;Market, MarketKey&gt;(key, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);
    df::borrow(&<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>.id, key)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market_mut"></a>

## Function `borrow_market_mut`

Mutably borrow <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> market


<a name="@Panics_2"></a>

###### Panics


Panics if incorrect type was provided for the underlying market.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market_mut">borrow_market_mut</a>&lt;Market: store, MarketKey: <b>copy</b>, drop, store&gt;(key: MarketKey, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<b>mut</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>): &<b>mut</b> Market
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market_mut">borrow_market_mut</a>&lt;Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    key: MarketKey,
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<b>mut</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a>,
): &<b>mut</b> Market {
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_market">assert_market</a>&lt;Market, MarketKey&gt;(key, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);
    df::borrow_mut(&<b>mut</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>.id, key)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_delete"></a>

## Function `delete`

Deconstruct <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> returning the underlying market


<a name="@Panics_3"></a>

###### Panics


Panics if underlying market does not match the provided type.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_delete">delete</a>&lt;Market: store, MarketKey: <b>copy</b>, drop, store&gt;(key: MarketKey, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>): Market
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_delete">delete</a>&lt;Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    key: MarketKey,
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a>,
): Market {
    <b>let</b> market = df::remove(&<b>mut</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>.id, key);

    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a> { id, is_live: _, is_whitelisted: _ } = <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>;
    <a href="_delete">object::delete</a>(id);

    market
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_market"></a>

## Function `assert_market`

Asserts the type of the underlying market of the <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code>


<a name="@Panics_4"></a>

###### Panics


Panics if incorrect type was provided


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_market">assert_market</a>&lt;Market: store, MarketKey: <b>copy</b>, drop, store&gt;(key: MarketKey, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_market">assert_market</a>&lt;Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    key: MarketKey,
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a>,
): bool {
    df::exists_with_type&lt;MarketKey, Market&gt;(&<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>.id, key)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_live"></a>

## Function `assert_is_live`

Asserts that <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> is live


<a name="@Panics_5"></a>

###### Panics


Panics if <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> is not live


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_live">assert_is_live</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_live">assert_is_live</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a>) {
    <b>assert</b>!(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_is_live">is_live</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>), <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_EVenueNotLive">EVenueNotLive</a>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_whitelisted"></a>

## Function `assert_is_whitelisted`

Asserts that <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> is whitelisted


<a name="@Panics_6"></a>

###### Panics


Panics if <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> is not whitelisted


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_whitelisted">assert_is_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_whitelisted">assert_is_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a>) {
    <b>assert</b>!(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_is_whitelisted">is_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>), <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_EVenueNotWhitelisted">EVenueNotWhitelisted</a>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_not_whitelisted"></a>

## Function `assert_is_not_whitelisted`

Asserts that <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> is not whitelisted


<a name="@Panics_7"></a>

###### Panics


Panics if <code><a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a></code> is whitelisted


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_not_whitelisted">assert_is_not_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_not_whitelisted">assert_is_not_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">Venue</a>) {
    <b>assert</b>!(!<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_is_whitelisted">is_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>), <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_EVenueWhitelisted">EVenueWhitelisted</a>);
}
</code></pre>



</details>
