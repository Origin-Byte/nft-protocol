
<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading"></a>

# Module `0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788::trading`

Reusable trading primitives.


-  [Struct `BidCommission`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission)
-  [Struct `AskCommission`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission)
-  [Function `new_ask_commission`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_new_ask_commission)
-  [Function `new_bid_commission`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_new_bid_commission)
-  [Function `destroy_bid_commission`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_destroy_bid_commission)
-  [Function `transfer_bid_commission`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_transfer_bid_commission)
-  [Function `transfer_ask_commission`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_transfer_ask_commission)
-  [Function `extract_ask_commission`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_extract_ask_commission)
-  [Function `bid_commission_amount`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_bid_commission_amount)
-  [Function `bid_commission_beneficiary`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_bid_commission_beneficiary)
-  [Function `ask_commission_amount`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_ask_commission_amount)
-  [Function `ask_commission_beneficiary`](#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_ask_commission_beneficiary)


<pre><code><b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x2::balance</a>;
<b>use</b> <a href="">0x2::coin</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
</code></pre>



<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission"></a>

## Struct `BidCommission`

Enables collection of wallet/marketplace collection for buying NFTs.
1. user bids via wallet to buy NFT for <code>p</code>, wallet wants fee <code>f</code>
2. when executed, <code>p</code> goes to seller and <code>f</code> goes to wallet


<pre><code><b>struct</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">BidCommission</a>&lt;FT&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>cut: <a href="_Balance">balance::Balance</a>&lt;FT&gt;</code>
</dt>
<dd>
 This is given to the facilitator of the trade.
</dd>
<dt>
<code>beneficiary: <b>address</b></code>
</dt>
<dd>
 A new <code>Coin</code> object is created and sent to this address.
</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission"></a>

## Struct `AskCommission`

Enables collection of wallet/marketplace collection for listing an NFT.
1. user lists NFT via wallet for price <code>p</code>, wallet requests fee <code>f</code>
2. when executed, <code>p - f</code> goes to user and <code>f</code> goes to wallet


<pre><code><b>struct</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">AskCommission</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>cut: u64</code>
</dt>
<dd>
 How many tokens of the transferred amount should go to the party
 which holds the private key of <code>beneficiary</code> address.

 Always less than ask price.
</dd>
<dt>
<code>beneficiary: <b>address</b></code>
</dt>
<dd>
 A new <code>Coin</code> object is created and sent to this address.
</dd>
</dl>


</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_new_ask_commission"></a>

## Function `new_ask_commission`



<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_new_ask_commission">new_ask_commission</a>(beneficiary: <b>address</b>, cut: u64): <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">trading::AskCommission</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_new_ask_commission">new_ask_commission</a>(
    beneficiary: <b>address</b>,
    cut: u64,
): <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">AskCommission</a> {
    <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">AskCommission</a> { beneficiary, cut }
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_new_bid_commission"></a>

## Function `new_bid_commission`



<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_new_bid_commission">new_bid_commission</a>&lt;FT&gt;(beneficiary: <b>address</b>, cut: <a href="_Balance">balance::Balance</a>&lt;FT&gt;): <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_new_bid_commission">new_bid_commission</a>&lt;FT&gt;(
    beneficiary: <b>address</b>,
    cut: Balance&lt;FT&gt;,
): <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">BidCommission</a>&lt;FT&gt; {
    <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">BidCommission</a> { beneficiary, cut }
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_destroy_bid_commission"></a>

## Function `destroy_bid_commission`



<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_destroy_bid_commission">destroy_bid_commission</a>&lt;FT&gt;(commission: <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;): (<a href="_Balance">balance::Balance</a>&lt;FT&gt;, <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_destroy_bid_commission">destroy_bid_commission</a>&lt;FT&gt;(
    commission: <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">BidCommission</a>&lt;FT&gt;,
): (Balance&lt;FT&gt;, <b>address</b>) {
    <b>let</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">BidCommission</a> { cut, beneficiary } = commission;
    (cut, beneficiary)
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_transfer_bid_commission"></a>

## Function `transfer_bid_commission`



<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_transfer_bid_commission">transfer_bid_commission</a>&lt;FT&gt;(commission: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_transfer_bid_commission">transfer_bid_commission</a>&lt;FT&gt;(
    commission: &<b>mut</b> Option&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">BidCommission</a>&lt;FT&gt;&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>if</b> (<a href="_is_some">option::is_some</a>(commission)) {
        <b>let</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">BidCommission</a> { beneficiary, cut } =
            <a href="_extract">option::extract</a>(commission);

        public_transfer(<a href="_from_balance">coin::from_balance</a>(cut, ctx), beneficiary);
    };
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_transfer_ask_commission"></a>

## Function `transfer_ask_commission`



<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_transfer_ask_commission">transfer_ask_commission</a>&lt;FT&gt;(commission: &<b>mut</b> <a href="_Option">option::Option</a>&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">trading::AskCommission</a>&gt;, source: &<b>mut</b> <a href="_Balance">balance::Balance</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_transfer_ask_commission">transfer_ask_commission</a>&lt;FT&gt;(
    commission: &<b>mut</b> Option&lt;<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">AskCommission</a>&gt;,
    source: &<b>mut</b> Balance&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>if</b> (<a href="_is_some">option::is_some</a>(commission)) {
        <b>let</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">AskCommission</a> { beneficiary, cut } =
            <a href="_extract">option::extract</a>(commission);

        public_transfer(<a href="_take">coin::take</a>(source, cut, ctx), beneficiary);
    };
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_extract_ask_commission"></a>

## Function `extract_ask_commission`



<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_extract_ask_commission">extract_ask_commission</a>&lt;FT&gt;(commission: <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">trading::AskCommission</a>, source: &<b>mut</b> <a href="_Balance">balance::Balance</a>&lt;FT&gt;): (<a href="_Balance">balance::Balance</a>&lt;FT&gt;, <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_extract_ask_commission">extract_ask_commission</a>&lt;FT&gt;(
    commission: <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">AskCommission</a>,
    source: &<b>mut</b> Balance&lt;FT&gt;,
): (Balance&lt;FT&gt;, <b>address</b>) {
    <b>let</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">AskCommission</a> { beneficiary, cut } = commission;

    (<a href="_split">balance::split</a>(source, cut), beneficiary)
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_bid_commission_amount"></a>

## Function `bid_commission_amount`



<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_bid_commission_amount">bid_commission_amount</a>&lt;FT&gt;(bid: &<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_bid_commission_amount">bid_commission_amount</a>&lt;FT&gt;(bid: &<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">BidCommission</a>&lt;FT&gt;): u64 {
    <a href="_value">balance::value</a>(&bid.cut)
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_bid_commission_beneficiary"></a>

## Function `bid_commission_beneficiary`



<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_bid_commission_beneficiary">bid_commission_beneficiary</a>&lt;FT&gt;(bid: &<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">trading::BidCommission</a>&lt;FT&gt;): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_bid_commission_beneficiary">bid_commission_beneficiary</a>&lt;FT&gt;(bid: &<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_BidCommission">BidCommission</a>&lt;FT&gt;): <b>address</b> {
    bid.beneficiary
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_ask_commission_amount"></a>

## Function `ask_commission_amount`



<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_ask_commission_amount">ask_commission_amount</a>(ask: &<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">trading::AskCommission</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_ask_commission_amount">ask_commission_amount</a>(ask: &<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">AskCommission</a>): u64 {
    ask.cut
}
</code></pre>



</details>

<a name="0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_ask_commission_beneficiary"></a>

## Function `ask_commission_beneficiary`



<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_ask_commission_beneficiary">ask_commission_beneficiary</a>(ask: &<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">trading::AskCommission</a>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_ask_commission_beneficiary">ask_commission_beneficiary</a>(ask: &<a href="trading.md#0x381bc6b9fd89d748226db81e98e6c22c6246c37d4a13acefc862e4a70c73a788_trading_AskCommission">AskCommission</a>): <b>address</b> {
    ask.beneficiary
}
</code></pre>



</details>
