
<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request"></a>

# Module `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request`

Withdraw Policy/Request controls how NFTs can be withdrawn from the OB Kiosk
or any other NFT container that implements it.


-  [Struct `Witness`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_Witness)
-  [Struct `WITHDRAW_REQ`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WITHDRAW_REQ)
-  [Struct `WithdrawRequest`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest)
-  [Constants](#@Constants_0)
-  [Function `new`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_new)
-  [Function `init_policy`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_init_policy)
-  [Function `add_receipt`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_add_receipt)
-  [Function `inner_mut`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_inner_mut)
-  [Function `confirm`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_confirm)
-  [Function `tx_sender`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_tx_sender)


<pre><code><b>use</b> <a href="">0x2::package</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request</a>;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_Witness"></a>

## Struct `Witness`



<pre><code><b>struct</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_Witness">Witness</a> <b>has</b> drop
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

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WITHDRAW_REQ"></a>

## Struct `WITHDRAW_REQ`



<pre><code><b>struct</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WITHDRAW_REQ">WITHDRAW_REQ</a> <b>has</b> drop
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

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest"></a>

## Struct `WithdrawRequest`



<pre><code><b>struct</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest">WithdrawRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>sender: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>inner: <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">request::RequestBody</a>&lt;<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft">request::WithNft</a>&lt;T, <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WITHDRAW_REQ">withdraw_request::WITHDRAW_REQ</a>&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_EPolicyMismatch"></a>



<pre><code><b>const</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_EPolicyMismatch">EPolicyMismatch</a>: u64 = 1;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_new"></a>

## Function `new`



<pre><code><b>public</b> <b>fun</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_new">new</a>&lt;T&gt;(sender: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest">withdraw_request::WithdrawRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_new">new</a>&lt;T&gt;(
    sender: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
): <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest">WithdrawRequest</a>&lt;T&gt; {
    <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest">WithdrawRequest</a>&lt;T&gt; {
        sender,
        inner: <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new">request::new</a>(ctx),
    }
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_init_policy"></a>

## Function `init_policy`



<pre><code><b>public</b> <b>fun</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_init_policy">init_policy</a>&lt;T&gt;(publisher: &<a href="_Publisher">package::Publisher</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft">request::WithNft</a>&lt;T, <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WITHDRAW_REQ">withdraw_request::WITHDRAW_REQ</a>&gt;&gt;, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">request::PolicyCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_init_policy">init_policy</a>&lt;T&gt;(publisher: &Publisher, ctx: &<b>mut</b> TxContext): (Policy&lt;WithNft&lt;T, <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WITHDRAW_REQ">WITHDRAW_REQ</a>&gt;&gt;, PolicyCap) {
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new_policy_with_type">request::new_policy_with_type</a>(<a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WITHDRAW_REQ">WITHDRAW_REQ</a> {}, publisher, ctx)
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_add_receipt"></a>

## Function `add_receipt`

Adds a <code>Receipt</code> to the <code>Request</code>, unblocking the request and
confirming that the policy requirements are satisfied.


<pre><code><b>public</b> <b>fun</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_add_receipt">add_receipt</a>&lt;T, Rule&gt;(self: &<b>mut</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest">withdraw_request::WithdrawRequest</a>&lt;T&gt;, rule: &Rule)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_add_receipt">add_receipt</a>&lt;T, Rule&gt;(self: &<b>mut</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest">WithdrawRequest</a>&lt;T&gt;, rule: &Rule) {
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_add_receipt">request::add_receipt</a>(&<b>mut</b> self.inner, rule);
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_inner_mut"></a>

## Function `inner_mut`



<pre><code><b>public</b> <b>fun</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_inner_mut">inner_mut</a>&lt;T&gt;(self: &<b>mut</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest">withdraw_request::WithdrawRequest</a>&lt;T&gt;): &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">request::RequestBody</a>&lt;<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft">request::WithNft</a>&lt;T, <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WITHDRAW_REQ">withdraw_request::WITHDRAW_REQ</a>&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_inner_mut">inner_mut</a>&lt;T&gt;(
    self: &<b>mut</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest">WithdrawRequest</a>&lt;T&gt;
): &<b>mut</b> RequestBody&lt;WithNft&lt;T, <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WITHDRAW_REQ">WITHDRAW_REQ</a>&gt;&gt; { &<b>mut</b> self.inner }
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_confirm"></a>

## Function `confirm`



<pre><code><b>public</b> <b>fun</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_confirm">confirm</a>&lt;T&gt;(self: <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest">withdraw_request::WithdrawRequest</a>&lt;T&gt;, policy: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft">request::WithNft</a>&lt;T, <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WITHDRAW_REQ">withdraw_request::WITHDRAW_REQ</a>&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_confirm">confirm</a>&lt;T&gt;(self: <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest">WithdrawRequest</a>&lt;T&gt;, policy: &Policy&lt;WithNft&lt;T, <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WITHDRAW_REQ">WITHDRAW_REQ</a>&gt;&gt;) {
    <b>let</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest">WithdrawRequest</a> {
        sender: _,
        inner,
    } = self;

    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_confirm">request::confirm</a>(inner, policy);
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_tx_sender"></a>

## Function `tx_sender`



<pre><code><b>public</b> <b>fun</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_tx_sender">tx_sender</a>&lt;T&gt;(self: &<a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest">withdraw_request::WithdrawRequest</a>&lt;T&gt;): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_tx_sender">tx_sender</a>&lt;T&gt;(self: &<a href="withdraw.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_withdraw_request_WithdrawRequest">WithdrawRequest</a>&lt;T&gt;): <b>address</b> { self.sender }
</code></pre>



</details>
