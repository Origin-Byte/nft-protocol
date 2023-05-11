
<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction"></a>

# Module `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::english_auction`

Module implements the <code><a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a></code> primitive intended to be embedded
within primary and secondary markets


-  [Struct `Bid`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid)
-  [Struct `EnglishAuction`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction)
-  [Struct `MarketKey`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey)
-  [Constants](#@Constants_0)
-  [Function `new`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_new)
-  [Function `bid_from_balance`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_bid_from_balance)
-  [Function `bid_from_coin`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_bid_from_coin)
-  [Function `from_warehouse`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_from_warehouse)
-  [Function `from_inventory`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_from_inventory)
-  [Function `init_auction`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_init_auction)
-  [Function `create_auction`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_auction)
-  [Function `borrow_market`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_borrow_market)
-  [Function `create_bid`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid)
-  [Function `create_bid_whitelisted`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid_whitelisted)
-  [Function `create_bid_`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid_)
-  [Function `conclude_auction`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_conclude_auction)
-  [Function `claim_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_claim_nft)
-  [Function `claim_nft_into_kiosk`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_claim_nft_into_kiosk)
-  [Function `claim_nft_`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_claim_nft_)
-  [Function `delete`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_delete)
-  [Function `delete_bid`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_delete_bid)
-  [Function `current_bid`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_current_bid)
-  [Function `current_bidder`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_current_bidder)
-  [Function `is_concluded`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_is_concluded)
-  [Function `assert_concluded`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_assert_concluded)
-  [Function `assert_not_concluded`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_assert_not_concluded)


<pre><code><b>use</b> <a href="">0x2::balance</a>;
<b>use</b> <a href="">0x2::coin</a>;
<b>use</b> <a href="">0x2::kiosk</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk</a>;
<b>use</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::inventory</a>;
<b>use</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing</a>;
<b>use</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::market_whitelist</a>;
<b>use</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::venue</a>;
<b>use</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::warehouse</a>;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid"></a>

## Struct `Bid`

Auction bid


<pre><code><b>struct</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a>&lt;FT&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>bidder: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>offer: <a href="_Balance">balance::Balance</a>&lt;FT&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction"></a>

## Struct `EnglishAuction`

English auction object

Handles the logic for running an english auction


<pre><code><b>struct</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>nft: T</code>
</dt>
<dd>
 Owned NFT subject of the auction
</dd>
<dt>
<code>bid: <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">english_auction::Bid</a>&lt;FT&gt;</code>
</dt>
<dd>
 Best bid for <code>nft</code>

 Must always exist such that auction may be concluded at any time
</dd>
<dt>
<code>concluded: bool</code>
</dt>
<dd>
 Whether auction has concluded
</dd>
</dl>


</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey"></a>

## Struct `MarketKey`



<pre><code><b>struct</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey">MarketKey</a> <b>has</b> <b>copy</b>, drop, store
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


<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EAuctionConcluded"></a>

Auction was already concluded


<pre><code><b>const</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EAuctionConcluded">EAuctionConcluded</a>: u64 = 2;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EAuctionNotConcluded"></a>

Auction was not concluded


<pre><code><b>const</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EAuctionNotConcluded">EAuctionNotConcluded</a>: u64 = 3;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EBidTooLow"></a>

Bid was lower than existing bid

Call <code><a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid">english_auction::create_bid</a></code> with a higher bid.


<pre><code><b>const</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EBidTooLow">EBidTooLow</a>: u64 = 1;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_ECannotClaim"></a>

Tried to claim NFT by transaction sender that was not auction winner


<pre><code><b>const</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_ECannotClaim">ECannotClaim</a>: u64 = 4;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_new"></a>

## Function `new`

Create <code><a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a></code> from NFT <code>T</code> with bids denominated in fungible
token <code>FT</code>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_new">new</a>&lt;T, FT&gt;(nft: T, bid: <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">english_auction::Bid</a>&lt;FT&gt;): <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">english_auction::EnglishAuction</a>&lt;T, FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_new">new</a>&lt;T, FT&gt;(
    nft: T,
    bid: <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a>&lt;FT&gt;,
): <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt; {
    <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a> { nft, bid, concluded: <b>false</b> }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_bid_from_balance"></a>

## Function `bid_from_balance`

Create a new auction <code><a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a></code> for fungible token <code>FT</code>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_bid_from_balance">bid_from_balance</a>&lt;FT&gt;(offer: <a href="_Balance">balance::Balance</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">english_auction::Bid</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_bid_from_balance">bid_from_balance</a>&lt;FT&gt;(
    offer: Balance&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a>&lt;FT&gt; {
    <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a> {
        bidder: <a href="_sender">tx_context::sender</a>(ctx),
        offer,
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_bid_from_coin"></a>

## Function `bid_from_coin`

Create a new auction <code><a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a></code> for fungible token <code>FT</code>


<a name="@Panics_1"></a>

###### Panics


Panics if there are insufficient funds in <code>Coin&lt;FT&gt;</code>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_bid_from_coin">bid_from_coin</a>&lt;FT&gt;(wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, bid: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">english_auction::Bid</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_bid_from_coin">bid_from_coin</a>&lt;FT&gt;(
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    bid: u64,
    ctx: &<b>mut</b> TxContext,
): <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a>&lt;FT&gt; {
    <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_bid_from_balance">bid_from_balance</a>(
        <a href="_split">balance::split</a>(<a href="_balance_mut">coin::balance_mut</a>(wallet), bid),
        ctx,
    )
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_from_warehouse"></a>

## Function `from_warehouse`

Helper method to create <code><a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a></code> from <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a></code>

Requires an immediate placement of a <code><a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a></code> as the NFT will be withdrawn
from the <code>Warehouse</code>.


<a name="@Panics_2"></a>

###### Panics


Panics if NFT with ID does not exist.


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_from_warehouse">from_warehouse</a>&lt;T: store, key, FT&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, nft_id: <a href="_ID">object::ID</a>, bid: <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">english_auction::Bid</a>&lt;FT&gt;): <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">english_auction::EnglishAuction</a>&lt;T, FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_from_warehouse">from_warehouse</a>&lt;T: key + store, FT&gt;(
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> Warehouse&lt;T&gt;,
    nft_id: ID,
    bid: <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a>&lt;FT&gt;,
): <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt; {
    <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_new">new</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_with_id">warehouse::redeem_nft_with_id</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, nft_id), bid)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_from_inventory"></a>

## Function `from_inventory`

Helper method to create <code><a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a></code> from <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a></code>

Requires an immediate placement of a <code><a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a></code> as the NFT will be withdrawn
from the <code>Inventory</code>.


<a name="@Panics_3"></a>

###### Panics


Panics if underlying <code>Inventory</code> type is not a <code>Warehouse</code> or NFT with
ID does not exist.


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_from_inventory">from_inventory</a>&lt;T: store, key, FT&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;, nft_id: <a href="_ID">object::ID</a>, bid: <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">english_auction::Bid</a>&lt;FT&gt;): <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">english_auction::EnglishAuction</a>&lt;T, FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_from_inventory">from_inventory</a>&lt;T: key + store, FT&gt;(
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> Inventory&lt;T&gt;,
    nft_id: ID,
    bid: <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a>&lt;FT&gt;,
): <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt; {
    <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_new">new</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_with_id">inventory::redeem_nft_with_id</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>, nft_id), bid)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_init_auction"></a>

## Function `init_auction`

Initializes a <code>Venue</code> with <code><a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;FT&gt;</code>


<pre><code><b>public</b> entry <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_init_auction">init_auction</a>&lt;T: store, key, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, inventory_id: <a href="_ID">object::ID</a>, is_whitelisted: bool, nft_id: <a href="_ID">object::ID</a>, bid: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_init_auction">init_auction</a>&lt;T: key + store, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    inventory_id: ID,
    is_whitelisted: bool,
    nft_id: ID,
    bid: u64,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_auction">create_auction</a>&lt;T, FT&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, wallet, is_whitelisted, inventory_id, nft_id, bid, ctx
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_auction"></a>

## Function `create_auction`

Creates a <code>Venue</code> with <code><a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;FT&gt;</code>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_auction">create_auction</a>&lt;T: store, key, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, is_whitelisted: bool, inventory_id: <a href="_ID">object::ID</a>, nft_id: <a href="_ID">object::ID</a>, bid: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_auction">create_auction</a>&lt;T: key + store, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    is_whitelisted: bool,
    inventory_id: ID,
    nft_id: ID,
    bid: u64,
    ctx: &<b>mut</b> TxContext,
): ID {
    <b>let</b> bid = <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_bid_from_coin">bid_from_coin</a>(wallet, bid, ctx);
    <b>let</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a> =
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_admin_mut">listing::inventory_admin_mut</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id, ctx);

    <b>let</b> auction = <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_from_inventory">from_inventory</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>, nft_id, bid);

    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_create_venue">listing::create_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey">MarketKey</a> {}, auction, is_whitelisted, ctx)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_borrow_market"></a>

## Function `borrow_market`

Borrows <code>DutchAuctionMarket&lt;FT&gt;</code> from <code>Venue</code>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_borrow_market">borrow_market</a>&lt;T: store, key, FT&gt;(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>): &<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">english_auction::EnglishAuction</a>&lt;T, FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_borrow_market">borrow_market</a>&lt;T: key + store, FT&gt;(
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &Venue,
): &<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt; {
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market">venue::borrow_market</a>(<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey">MarketKey</a> {}, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid"></a>

## Function `create_bid`

Creates a bid on the NFT


<pre><code><b>public</b> entry <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid">create_bid</a>&lt;T: store, key, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, venue_id: <a href="_ID">object::ID</a>, bid: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid">create_bid</a>&lt;T: key + store, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    venue_id: ID,
    bid: u64,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_venue_internal_mut">listing::venue_internal_mut</a>&lt;<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt;, <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey">MarketKey</a>&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey">MarketKey</a> {}, venue_id
    );

    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_live">venue::assert_is_live</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_not_whitelisted">venue::assert_is_not_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);

    <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid_">create_bid_</a>&lt;T, FT&gt;(
        <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market_mut">venue::borrow_market_mut</a>(<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey">MarketKey</a> {}, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>),
        <a href="_split">balance::split</a>(<a href="_balance_mut">coin::balance_mut</a>(wallet), bid),
        ctx,
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid_whitelisted"></a>

## Function `create_bid_whitelisted`

Creates a bid on NFT for whitelisted auction


<pre><code><b>public</b> entry <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid_whitelisted">create_bid_whitelisted</a>&lt;T: store, key, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, venue_id: <a href="_ID">object::ID</a>, whitelist_token: <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">market_whitelist::Certificate</a>, bid: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid_whitelisted">create_bid_whitelisted</a>&lt;T: key + store, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    venue_id: ID,
    whitelist_token: Certificate,
    bid: u64,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_venue_internal_mut">listing::venue_internal_mut</a>&lt;<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt;, <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey">MarketKey</a>&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey">MarketKey</a> {}, venue_id
    );

    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_live">venue::assert_is_live</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_whitelisted">venue::assert_is_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);

    <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_assert_certificate">market_whitelist::assert_certificate</a>(&whitelist_token, venue_id);

    <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid_">create_bid_</a>&lt;T, FT&gt;(
        <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market_mut">venue::borrow_market_mut</a>(<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey">MarketKey</a> {}, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>),
        <a href="_split">balance::split</a>(<a href="_balance_mut">coin::balance_mut</a>(wallet), bid),
        ctx,
    );

    <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_burn">market_whitelist::burn</a>(whitelist_token);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid_"></a>

## Function `create_bid_`



<pre><code><b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid_">create_bid_</a>&lt;T: store, key, FT&gt;(auction: &<b>mut</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">english_auction::EnglishAuction</a>&lt;T, FT&gt;, bid: <a href="_Balance">balance::Balance</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_create_bid_">create_bid_</a>&lt;T: key + store, FT&gt;(
    auction: &<b>mut</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt;,
    bid: Balance&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>assert</b>!(
        <a href="_value">balance::value</a>(&bid) &gt; <a href="_value">balance::value</a>(&auction.bid.offer),
        <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EBidTooLow">EBidTooLow</a>,
    );

    <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_assert_not_concluded">assert_not_concluded</a>(auction);

    // Transfer <a href="">balance</a> of <b>old</b> bid back <b>to</b> original bidder
    <b>let</b> old_bid = <a href="_withdraw_all">balance::withdraw_all</a>(&<b>mut</b> auction.bid.offer);
    <a href="_public_transfer">transfer::public_transfer</a>(
        <a href="_from_balance">coin::from_balance</a>(old_bid, ctx), auction.bid.bidder,
    );

    // Update `<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a>`
    auction.bid.bidder = <a href="_sender">tx_context::sender</a>(ctx);
    <a href="_join">balance::join</a>(&<b>mut</b> auction.bid.offer, bid);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_conclude_auction"></a>

## Function `conclude_auction`

Conclude english auction

This does not actually resolve


<pre><code><b>public</b> entry <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_conclude_auction">conclude_auction</a>&lt;T: store, key, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_conclude_auction">conclude_auction</a>&lt;T: key + store, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">listing::assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);

    <b>let</b> auction: &<b>mut</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt; = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_market_internal_mut">listing::market_internal_mut</a>(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey">MarketKey</a> {}, venue_id,
    );

    <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_assert_not_concluded">assert_not_concluded</a>(auction);
    auction.concluded = <b>true</b>;
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_claim_nft"></a>

## Function `claim_nft`

Claim NFT after auction has concluded and transfer to transaction
sender


<a name="@Panics_4"></a>

###### Panics


Panics if <code>Venue</code> does not exist or has not yet concluded.


<pre><code><b>public</b> entry <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_claim_nft">claim_nft</a>&lt;T: store, key, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_claim_nft">claim_nft</a>&lt;T: key + store, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> (<a href="">kiosk</a>, _) = <a href="_new">ob_kiosk::new</a>(ctx);
    <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_claim_nft_into_kiosk">claim_nft_into_kiosk</a>&lt;T, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id, &<b>mut</b> <a href="">kiosk</a>, ctx);
    <a href="_public_share_object">transfer::public_share_object</a>(<a href="">kiosk</a>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_claim_nft_into_kiosk"></a>

## Function `claim_nft_into_kiosk`

Claim NFT into kiosk after auction has concluded


<a name="@Panics_5"></a>

###### Panics


Panics if <code>Venue</code> does not exist or has not yet concluded.


<pre><code><b>public</b> entry <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_claim_nft_into_kiosk">claim_nft_into_kiosk</a>&lt;T: store, key, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, buyer_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_claim_nft_into_kiosk">claim_nft_into_kiosk</a>&lt;T: key + store, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    buyer_kiosk: &<b>mut</b> Kiosk,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> nft = <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_claim_nft_">claim_nft_</a>&lt;T, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id, ctx);
    <a href="_deposit">ob_kiosk::deposit</a>(buyer_kiosk, nft, ctx);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_claim_nft_"></a>

## Function `claim_nft_`

Claim NFT after auction has concluded


<a name="@Panics_6"></a>

###### Panics


Panics if <code>Venue</code> does not exist or has not yet concluded.


<pre><code><b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_claim_nft_">claim_nft_</a>&lt;T: store, key, FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_claim_nft_">claim_nft_</a>&lt;T: key + store, FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    venue_id: ID,
    ctx: &<b>mut</b> TxContext,
): T {
    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_remove_venue">listing::remove_venue</a>&lt;<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt;, <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey">MarketKey</a>&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey">MarketKey</a> {}, venue_id
    );

    <b>let</b> auction: <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt; = <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_delete">venue::delete</a>(<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_MarketKey">MarketKey</a> {}, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);
    <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_assert_concluded">assert_concluded</a>(&auction);

    <b>let</b> (nft, bid) = <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_delete">delete</a>(auction);

    <b>let</b> buyer = bid.bidder;
    <b>assert</b>!(buyer == <a href="_sender">tx_context::sender</a>(ctx), <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_ECannotClaim">ECannotClaim</a>);

    <b>let</b> bid = <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_delete_bid">delete_bid</a>(bid);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_pay_and_emit_sold_event">listing::pay_and_emit_sold_event</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, &nft, bid, buyer);
    nft
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_delete"></a>

## Function `delete`

Deconstruct the <code><a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a></code> struct


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_delete">delete</a>&lt;T: store, key, FT&gt;(auction: <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">english_auction::EnglishAuction</a>&lt;T, FT&gt;): (T, <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">english_auction::Bid</a>&lt;FT&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_delete">delete</a>&lt;T: key + store, FT&gt;(
    auction: <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt;,
): (T, <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a>&lt;FT&gt;) {
    <b>let</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a> { nft, bid, concluded: _ } = auction;
    (nft, bid)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_delete_bid"></a>

## Function `delete_bid`

Deconstruct the <code><a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a></code> struct


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_delete_bid">delete_bid</a>&lt;FT&gt;(bid: <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">english_auction::Bid</a>&lt;FT&gt;): <a href="_Balance">balance::Balance</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_delete_bid">delete_bid</a>&lt;FT&gt;(bid: <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a>&lt;FT&gt;): Balance&lt;FT&gt; {
    <b>let</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_Bid">Bid</a> { bidder: _, offer } = bid;
    offer
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_current_bid"></a>

## Function `current_bid`

Return current auction bid


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_current_bid">current_bid</a>&lt;T, FT&gt;(auction: &<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">english_auction::EnglishAuction</a>&lt;T, FT&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_current_bid">current_bid</a>&lt;T, FT&gt;(auction: &<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt;): u64 {
    <a href="_value">balance::value</a>(&auction.bid.offer)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_current_bidder"></a>

## Function `current_bidder`

Return current auction bidder


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_current_bidder">current_bidder</a>&lt;T, FT&gt;(auction: &<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">english_auction::EnglishAuction</a>&lt;T, FT&gt;): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_current_bidder">current_bidder</a>&lt;T, FT&gt;(
    auction: &<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt;,
): <b>address</b> {
    auction.bid.bidder
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_is_concluded"></a>

## Function `is_concluded`

Return whether auction is concluded


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_is_concluded">is_concluded</a>&lt;T, FT&gt;(auction: &<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">english_auction::EnglishAuction</a>&lt;T, FT&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_is_concluded">is_concluded</a>&lt;T, FT&gt;(
    auction: &<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt;,
): bool {
    auction.concluded
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_assert_concluded"></a>

## Function `assert_concluded`

Assert that auction is not concluded


<a name="@Panics_7"></a>

###### Panics


Panics if auction was not concluded


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_assert_concluded">assert_concluded</a>&lt;T: store, key, FT&gt;(auction: &<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">english_auction::EnglishAuction</a>&lt;T, FT&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_assert_concluded">assert_concluded</a>&lt;T: key + store, FT&gt;(
    auction: &<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt;,
) {
    <b>assert</b>!(auction.concluded, <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EAuctionNotConcluded">EAuctionNotConcluded</a>)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_assert_not_concluded"></a>

## Function `assert_not_concluded`

Assert that auction is not concluded


<a name="@Panics_8"></a>

###### Panics


Panics if auction was concluded


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_assert_not_concluded">assert_not_concluded</a>&lt;T: store, key, FT&gt;(auction: &<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">english_auction::EnglishAuction</a>&lt;T, FT&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_assert_not_concluded">assert_not_concluded</a>&lt;T: key + store, FT&gt;(
    auction: &<a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EnglishAuction">EnglishAuction</a>&lt;T, FT&gt;,
) {
    <b>assert</b>!(!auction.concluded, <a href="english_auction.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_english_auction_EAuctionConcluded">EAuctionConcluded</a>)
}
</code></pre>



</details>
