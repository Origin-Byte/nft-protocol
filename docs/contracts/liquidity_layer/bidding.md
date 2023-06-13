
<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding"></a>

# Module `0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788::bidding`

Bidding module that allows users to bid for any given NFT just by its ID.
This gives NFT owners a platform to sell their NFTs to any available bid.


-  [Struct `Witness`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Witness)
-  [Resource `Bid`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid)
-  [Struct `BidCreatedEvent`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_BidCreatedEvent)
-  [Struct `BidClosedEvent`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_BidClosedEvent)
-  [Struct `BidMatchedEvent`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_BidMatchedEvent)
-  [Constants](#@Constants_0)
-  [Function `create_bid`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_create_bid)
-  [Function `create_bid_with_commission`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_create_bid_with_commission)
-  [Function `sell_nft_from_kiosk`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_sell_nft_from_kiosk)
-  [Function `sell_nft`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_sell_nft)
-  [Function `close_bid`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_close_bid)
-  [Function `share`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_share)
-  [Function `new_bid`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_new_bid)
-  [Function `sell_nft_common`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_sell_nft_common)
-  [Function `close_bid_`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_close_bid_)


<pre><code><b>use</b> <a href="">0x1::ascii</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::type_name</a>;
<b>use</b> <a href="">0x2::balance</a>;
<b>use</b> <a href="">0x2::coin</a>;
<b>use</b> <a href="">0x2::event</a>;
<b>use</b> <a href="">0x2::kiosk</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading">0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788::trading</a>;
<b>use</b> <a href="">0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk</a>;
<b>use</b> <a href="">0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request</a>;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Witness"></a>

## Struct `Witness`

=== Structs ===
Witness used to authenticate witness protected endpoints


<pre><code><b>struct</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Witness">Witness</a> <b>has</b> drop
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

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid"></a>

## Resource `Bid`

Holds public information about a bid.

Initially, a bid is open, ie. the offer balance is not zero.
Then, a bid is either closed or matched.
In either case, the offer balance is set to zero.


<pre><code><b>struct</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">Bid</a>&lt;FT&gt; <b>has</b> key
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
<code>nft: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>buyer: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">kiosk</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 Buyer's kiosk into which the NFT must be deposited.
</dd>
<dt>
<code>offer: <a href="_Balance">balance::Balance</a>&lt;FT&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>commission: <a href="_Option">option::Option</a>&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;&gt;</code>
</dt>
<dd>
 Optionally, upon creation, the bid can be created with a commission.
 This means that when the bid is matched, the balance in this field
 is sent to the given beneficiary.

 Useful for wallets or marketplaces which create bids on behalf of
 users and want to secure a commission.
</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_BidCreatedEvent"></a>

## Struct `BidCreatedEvent`

=== Events ===


<pre><code><b>struct</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_BidCreatedEvent">BidCreatedEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>bid: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>nft: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>price: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>commission: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>buyer: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>buyer_kiosk: <a href="_ID">object::ID</a></code>
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

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_BidClosedEvent"></a>

## Struct `BidClosedEvent`

Bid was closed by the user, no sell happened


<pre><code><b>struct</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_BidClosedEvent">BidClosedEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>bid: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>nft: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>buyer: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>price: u64</code>
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

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_BidMatchedEvent"></a>

## Struct `BidMatchedEvent`

NFT was sold


<pre><code><b>struct</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_BidMatchedEvent">BidMatchedEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>bid: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>nft: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>price: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>seller: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>buyer: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>ft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>nft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_EBidAlreadyClosed"></a>

=== Errors ===
When a bid is closed or matched, the balance is set to zero.

It cannot be attempted to be closed or matched again.


<pre><code><b>const</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_EBidAlreadyClosed">EBidAlreadyClosed</a>: u64 = 1;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_EPriceCannotBeZero"></a>

When a bid is created, the price cannot be zero.


<pre><code><b>const</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_EPriceCannotBeZero">EPriceCannotBeZero</a>: u64 = 2;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_ESenderNotOwner"></a>



<pre><code><b>const</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_ESenderNotOwner">ESenderNotOwner</a>: u64 = 3;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_create_bid"></a>

## Function `create_bid`

=== Entry points ===
It performs the following:
- Creates object <code>bid</code>
- Transfers <code>price</code> tokens from <code>wallet</code> to the <code>bid.offer</code>
- Shares the bid

Make sure that the buyers kiosk allows deposits of <code>T</code>.
See <code><a href="_DepositSetting">ob_kiosk::DepositSetting</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_create_bid">create_bid</a>&lt;FT&gt;(buyers_kiosk: <a href="_ID">object::ID</a>, nft: <a href="_ID">object::ID</a>, price: u64, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_create_bid">create_bid</a>&lt;FT&gt;(
    buyers_kiosk: ID,
    nft: ID,
    price: u64,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): ID {
    <b>let</b> bid =
        <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_new_bid">new_bid</a>(buyers_kiosk, nft, price, <a href="_none">option::none</a>(), wallet, ctx);

    <b>let</b> bid_id = <a href="_id">object::id</a>(&bid);
    share_object(bid);
    bid_id
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_create_bid_with_commission"></a>

## Function `create_bid_with_commission`

It performs the following:
- Creates object <code>bid</code>
- Transfers <code>price</code> tokens from <code>wallet</code> to the <code>bid.offer</code>
- Transfers <code>commission_ft</code> tokens from <code>wallet</code> to the <code>bid.commission</code>
- Shares the bid

To be called by a intermediate application, for the purpose
of securing a commission for intermediating the process.

Make sure that the buyers kiosk allows deposits of <code>T</code>.
See <code><a href="_DepositSetting">ob_kiosk::DepositSetting</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_create_bid_with_commission">create_bid_with_commission</a>&lt;FT&gt;(buyers_kiosk: <a href="_ID">object::ID</a>, nft: <a href="_ID">object::ID</a>, price: u64, beneficiary: <b>address</b>, commission_ft: u64, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_create_bid_with_commission">create_bid_with_commission</a>&lt;FT&gt;(
    buyers_kiosk: ID,
    nft: ID,
    price: u64,
    beneficiary: <b>address</b>,
    commission_ft: u64,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): ID {
    <b>let</b> commission = <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_new_bid_commission">trading::new_bid_commission</a>(
        beneficiary,
        <a href="_split">balance::split</a>(<a href="_balance_mut">coin::balance_mut</a>(wallet), commission_ft),
    );
    <b>let</b> bid =
        <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_new_bid">new_bid</a>(buyers_kiosk, nft, price, <a href="_some">option::some</a>(commission), wallet, ctx);
    <b>let</b> bid_id = <a href="_id">object::id</a>(&bid);
    share_object(bid);
    bid_id
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_sell_nft_from_kiosk"></a>

## Function `sell_nft_from_kiosk`

Match a bid.
The NFT must live in the sellers kiosk.

Aborts if the buyers kiosk does not allow deposits of <code>T</code>.
See <code><a href="_DepositSetting">ob_kiosk::DepositSetting</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_sell_nft_from_kiosk">sell_nft_from_kiosk</a>&lt;T: store, key, FT&gt;(bid: &<b>mut</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">bidding::Bid</a>&lt;FT&gt;, sellers_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, buyers_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_sell_nft_from_kiosk">sell_nft_from_kiosk</a>&lt;T: key + store, FT&gt;(
    bid: &<b>mut</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">Bid</a>&lt;FT&gt;,
    sellers_kiosk: &<b>mut</b> Kiosk,
    buyers_kiosk: &<b>mut</b> Kiosk,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
): TransferRequest&lt;T&gt; {
    <b>let</b> transfer_req = <a href="_transfer_signed">ob_kiosk::transfer_signed</a>&lt;T&gt;(
        sellers_kiosk,
        buyers_kiosk,
        nft_id,
        <a href="_value">balance::value</a>(&bid.offer),
        ctx,
    );
    <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_sell_nft_common">sell_nft_common</a>(bid, buyers_kiosk, transfer_req, nft_id, ctx)
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_sell_nft"></a>

## Function `sell_nft`

Use if the NFT does not live in a safe and the seller has access to it
as an owner object.

Aborts if the buyers kiosk does not allow deposits of <code>T</code>.
See <code><a href="_DepositSetting">ob_kiosk::DepositSetting</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_sell_nft">sell_nft</a>&lt;T: store, key, FT&gt;(bid: &<b>mut</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">bidding::Bid</a>&lt;FT&gt;, buyers_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft: T, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_sell_nft">sell_nft</a>&lt;T: key + store, FT&gt;(
    bid: &<b>mut</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">Bid</a>&lt;FT&gt;,
    buyers_kiosk: &<b>mut</b> Kiosk,
    nft: T,
    ctx: &<b>mut</b> TxContext,
): TransferRequest&lt;T&gt; {
    <b>let</b> nft_id = <a href="_id">object::id</a>(&nft);
    <a href="_deposit">ob_kiosk::deposit</a>(buyers_kiosk, nft, ctx);
    <b>let</b> transfer_req = <a href="_new">transfer_request::new</a>&lt;T&gt;(
        nft_id,
        uid_to_address(&bid.id),
        bid.<a href="">kiosk</a>,
        <a href="_value">balance::value</a>(&bid.offer),
        ctx,
    );
    <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_sell_nft_common">sell_nft_common</a>(bid, buyers_kiosk, transfer_req, nft_id, ctx)
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_close_bid"></a>

## Function `close_bid`

If a user wants to cancel their position, they get their coins back.
Both offer and commission (if set) are given back.


<pre><code><b>public</b> <b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_close_bid">close_bid</a>&lt;FT&gt;(bid: &<b>mut</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">bidding::Bid</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_close_bid">close_bid</a>&lt;FT&gt;(bid: &<b>mut</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">Bid</a>&lt;FT&gt;, ctx: &<b>mut</b> TxContext) {
    <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_close_bid_">close_bid_</a>(bid, ctx);
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_share"></a>

## Function `share`

=== Helpers ===


<pre><code><b>public</b> <b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_share">share</a>&lt;FT&gt;(bid: <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">bidding::Bid</a>&lt;FT&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_share">share</a>&lt;FT&gt;(bid: <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">Bid</a>&lt;FT&gt;) {
    share_object(bid);
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_new_bid"></a>

## Function `new_bid`

It performs the following:
- Creates object <code>bid</code>
- Transfers <code>price</code> tokens from <code>wallet</code> to the <code>bid.offer</code>
- Transfers <code>commission_ft</code> tokens from <code>wallet</code> to the <code>bid.commission</code>
if commission is set


<pre><code><b>public</b> <b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_new_bid">new_bid</a>&lt;FT&gt;(buyers_kiosk: <a href="_ID">object::ID</a>, nft: <a href="_ID">object::ID</a>, price: u64, commission: <a href="_Option">option::Option</a>&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;&gt;, wallet: &<b>mut</b> <a href="_Coin">coin::Coin</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">bidding::Bid</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_new_bid">new_bid</a>&lt;FT&gt;(
    buyers_kiosk: ID,
    nft: ID,
    price: u64,
    commission: Option&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;&gt;,
    wallet: &<b>mut</b> Coin&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">Bid</a>&lt;FT&gt; {
    <b>assert</b>!(price != 0, <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_EPriceCannotBeZero">EPriceCannotBeZero</a>);

    <b>let</b> offer = <a href="_split">balance::split</a>(<a href="_balance_mut">coin::balance_mut</a>(wallet), price);
    <b>let</b> buyer = sender(ctx);

    <b>let</b> commission_amount = <b>if</b>(<a href="_is_some">option::is_some</a>(&commission)) {
        <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_bid_commission_amount">trading::bid_commission_amount</a>(<a href="_borrow">option::borrow</a>(&commission))
    } <b>else</b> {
        0
    };

    <b>let</b> bid = <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">Bid</a>&lt;FT&gt; {
        id: <a href="_new">object::new</a>(ctx),
        nft,
        offer,
        buyer,
        <a href="">kiosk</a>: buyers_kiosk,
        commission,
    };
    <b>let</b> bid_id = <a href="_id">object::id</a>(&bid);

    emit(<a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_BidCreatedEvent">BidCreatedEvent</a> {
        bid: bid_id,
        nft: nft,
        price,
        buyer,
        buyer_kiosk: buyers_kiosk,
        ft_type: *<a href="_borrow_string">type_name::borrow_string</a>(&<a href="_get">type_name::get</a>&lt;FT&gt;()),
        commission: commission_amount,
    });

    bid
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_sell_nft_common"></a>

## Function `sell_nft_common`

=== Privates ===


<pre><code><b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_sell_nft_common">sell_nft_common</a>&lt;T: store, key, FT&gt;(bid: &<b>mut</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">bidding::Bid</a>&lt;FT&gt;, buyers_kiosk: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, transfer_req: <a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_sell_nft_common">sell_nft_common</a>&lt;T: key + store, FT&gt;(
    bid: &<b>mut</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">Bid</a>&lt;FT&gt;,
    buyers_kiosk: &<b>mut</b> Kiosk,
    transfer_req: TransferRequest&lt;T&gt;,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
): TransferRequest&lt;T&gt; {
    <a href="_assert_kiosk_id">ob_kiosk::assert_kiosk_id</a>(buyers_kiosk, bid.<a href="">kiosk</a>);
    <b>let</b> seller = sender(ctx);
    <b>let</b> price = <a href="_value">balance::value</a>(&bid.offer);
    <b>assert</b>!(price != 0, <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_EBidAlreadyClosed">EBidAlreadyClosed</a>);

    <a href="_set_paid">transfer_request::set_paid</a>&lt;T, FT&gt;(
        &<b>mut</b> transfer_req, <a href="_withdraw_all">balance::withdraw_all</a>(&<b>mut</b> bid.offer), seller,
    );
    <a href="_set_transfer_request_auth">ob_kiosk::set_transfer_request_auth</a>(&<b>mut</b> transfer_req, &<a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Witness">Witness</a> {});

    <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_transfer_bid_commission">trading::transfer_bid_commission</a>(&<b>mut</b> bid.commission, ctx);

    emit(<a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_BidMatchedEvent">BidMatchedEvent</a> {
        bid: <a href="_id">object::id</a>(bid),
        nft: nft_id,
        price,
        seller,
        buyer: bid.buyer,
        ft_type: *<a href="_borrow_string">type_name::borrow_string</a>(&<a href="_get">type_name::get</a>&lt;FT&gt;()),
        nft_type: *<a href="_borrow_string">type_name::borrow_string</a>(&<a href="_get">type_name::get</a>&lt;T&gt;()),
    });

    transfer_req
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_close_bid_"></a>

## Function `close_bid_`



<pre><code><b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_close_bid_">close_bid_</a>&lt;FT&gt;(bid: &<b>mut</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">bidding::Bid</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_close_bid_">close_bid_</a>&lt;FT&gt;(bid: &<b>mut</b> <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_Bid">Bid</a>&lt;FT&gt;, ctx: &<b>mut</b> TxContext) {
    <b>let</b> sender = sender(ctx);
    <b>assert</b>!(bid.buyer == sender, <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_ESenderNotOwner">ESenderNotOwner</a>);

    <b>let</b> total = <a href="_value">balance::value</a>(&bid.offer);
    <b>assert</b>!(total != 0, <a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_EBidAlreadyClosed">EBidAlreadyClosed</a>);
    <b>let</b> offer = <a href="_take">coin::take</a>(&<b>mut</b> bid.offer, total, ctx);

    <b>if</b> (<a href="_is_some">option::is_some</a>(&bid.commission)) {
        <b>let</b> commission = <a href="_extract">option::extract</a>(&<b>mut</b> bid.commission);
        <b>let</b> (cut, _beneficiary) = <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_destroy_bid_commission">trading::destroy_bid_commission</a>(commission);

        <a href="_join">balance::join</a>(<a href="_balance_mut">coin::balance_mut</a>(&<b>mut</b> offer), cut);
    };

    public_transfer(offer, sender);

    emit(<a href="bidding.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_bidding_BidClosedEvent">BidClosedEvent</a> {
        bid: <a href="_id">object::id</a>(bid),
        nft: bid.nft,
        buyer: sender,
        price: total,
        ft_type: *<a href="_borrow_string">type_name::borrow_string</a>(&<a href="_get">type_name::get</a>&lt;FT&gt;()),
    });
}
</code></pre>



</details>
