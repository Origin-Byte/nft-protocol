
<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request"></a>

# Module `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request`

Borrow Policy/Request controls how NFTs can be flash-borrowed from the OB Kiosk
or any other NFT container that implements it.


-  [Struct `Witness`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_Witness)
-  [Struct `BORROW_REQ`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BORROW_REQ)
-  [Struct `ReturnPromise`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_ReturnPromise)
-  [Struct `BorrowRequest`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest)
-  [Constants](#@Constants_0)
-  [Function `new`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_new)
-  [Function `init_policy`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_init_policy)
-  [Function `add_receipt`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_add_receipt)
-  [Function `inner_mut`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_inner_mut)
-  [Function `confirm`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_confirm)
-  [Function `borrow_nft`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_borrow_nft)
-  [Function `borrow_nft_ref_mut`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_borrow_nft_ref_mut)
-  [Function `borrow_field`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_borrow_field)
-  [Function `return_field`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_return_field)
-  [Function `return_nft`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_return_nft)
-  [Function `tx_sender`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_tx_sender)
-  [Function `is_borrow_field`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_is_borrow_field)
-  [Function `field`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_field)
-  [Function `nft_id`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_nft_id)
-  [Function `assert_is_borrow_nft`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_assert_is_borrow_nft)
-  [Function `assert_is_borrow_field`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_assert_is_borrow_field)


<pre><code><b>use</b> <a href="">0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::witness</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::type_name</a>;
<b>use</b> <a href="">0x2::dynamic_field</a>;
<b>use</b> <a href="">0x2::kiosk</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::package</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request</a>;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_Witness"></a>

## Struct `Witness`



<pre><code><b>struct</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_Witness">Witness</a> <b>has</b> drop
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

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BORROW_REQ"></a>

## Struct `BORROW_REQ`



<pre><code><b>struct</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BORROW_REQ">BORROW_REQ</a> <b>has</b> drop
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

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_ReturnPromise"></a>

## Struct `ReturnPromise`



<pre><code><b>struct</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_ReturnPromise">ReturnPromise</a>&lt;T, Field&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>nft_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest"></a>

## Struct `BorrowRequest`



<pre><code><b>struct</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth: drop, T: store, key&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>nft_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>nft: <a href="_Option">option::Option</a>&lt;T&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>sender: <b>address</b></code>
</dt>
<dd>

</dd>
<dt>
<code>field: <a href="_Option">option::Option</a>&lt;<a href="_TypeName">type_name::TypeName</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>promise: <a href="_Borrow">kiosk::Borrow</a></code>
</dt>
<dd>

</dd>
<dt>
<code>inner: <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">request::RequestBody</a>&lt;<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft">request::WithNft</a>&lt;T, <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BORROW_REQ">borrow_request::BORROW_REQ</a>&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_EPolicyMismatch"></a>



<pre><code><b>const</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_EPolicyMismatch">EPolicyMismatch</a>: u64 = 1;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_new"></a>

## Function `new`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_new">new</a>&lt;Auth: drop, T: store, key&gt;(_witness: Auth, nft: T, sender: <b>address</b>, field: <a href="_Option">option::Option</a>&lt;<a href="_TypeName">type_name::TypeName</a>&gt;, promise: <a href="_Borrow">kiosk::Borrow</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">borrow_request::BorrowRequest</a>&lt;Auth, T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_new">new</a>&lt;Auth: drop, T: key + store&gt;(
    _witness: Auth,
    nft: T,
    sender: <b>address</b>,
    field: Option&lt;TypeName&gt;,
    promise: Borrow,
    ctx: &<b>mut</b> TxContext,
): <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth, T&gt; {
    <b>let</b> nft_id = <a href="_id">object::id</a>(&nft);

    <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth, T&gt; {
        nft_id,
        nft: some(nft),
        sender,
        field,
        promise,
        inner: <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new">request::new</a>(ctx),
    }
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_init_policy"></a>

## Function `init_policy`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_init_policy">init_policy</a>&lt;T: store, key&gt;(publisher: &<a href="_Publisher">package::Publisher</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft">request::WithNft</a>&lt;T, <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BORROW_REQ">borrow_request::BORROW_REQ</a>&gt;&gt;, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">request::PolicyCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_init_policy">init_policy</a>&lt;T: key + store&gt;(publisher: &Publisher, ctx: &<b>mut</b> TxContext): (Policy&lt;WithNft&lt;T, <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BORROW_REQ">BORROW_REQ</a>&gt;&gt;, PolicyCap) {
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new_policy_with_type">request::new_policy_with_type</a>(<a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BORROW_REQ">BORROW_REQ</a> {}, publisher, ctx)
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_add_receipt"></a>

## Function `add_receipt`

Adds a <code>Receipt</code> to the <code>Request</code>, unblocking the request and
confirming that the policy requirements are satisfied.


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_add_receipt">add_receipt</a>&lt;Auth: drop, T: store, key, Rule&gt;(self: &<b>mut</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">borrow_request::BorrowRequest</a>&lt;Auth, T&gt;, rule: &Rule)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_add_receipt">add_receipt</a>&lt;Auth: drop, T: key + store, Rule&gt;(self: &<b>mut</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth, T&gt;, rule: &Rule) {
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_add_receipt">request::add_receipt</a>(&<b>mut</b> self.inner, rule);
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_inner_mut"></a>

## Function `inner_mut`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_inner_mut">inner_mut</a>&lt;Auth: drop, T: store, key&gt;(self: &<b>mut</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">borrow_request::BorrowRequest</a>&lt;Auth, T&gt;): &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">request::RequestBody</a>&lt;<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft">request::WithNft</a>&lt;T, <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BORROW_REQ">borrow_request::BORROW_REQ</a>&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_inner_mut">inner_mut</a>&lt;Auth: drop, T: key + store&gt;(
    self: &<b>mut</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth, T&gt;
): &<b>mut</b> RequestBody&lt;WithNft&lt;T, <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BORROW_REQ">BORROW_REQ</a>&gt;&gt; { &<b>mut</b> self.inner }
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_confirm"></a>

## Function `confirm`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_confirm">confirm</a>&lt;Auth: drop, T: store, key&gt;(_witness: Auth, self: <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">borrow_request::BorrowRequest</a>&lt;Auth, T&gt;, policy: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft">request::WithNft</a>&lt;T, <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BORROW_REQ">borrow_request::BORROW_REQ</a>&gt;&gt;): (T, <a href="_Borrow">kiosk::Borrow</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_confirm">confirm</a>&lt;Auth: drop, T: key + store&gt;(
    _witness: Auth, self: <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth, T&gt;, policy: &Policy&lt;WithNft&lt;T, <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BORROW_REQ">BORROW_REQ</a>&gt;&gt;
): (T, Borrow) {
    <b>assert</b>!(<a href="_is_some">option::is_some</a>(&self.nft), 0);

    <b>let</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a> {
        nft_id: _,
        nft,
        sender: _,
        field: _,
        promise,
        inner,
    } = self;


    // TODO: Right now there are no guarantees that the Field was not removed,
    // it relies on faithful implementation on behalf of the creator, this is not
    // ideal we would ideally have a bulletproof here.

    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_confirm">request::confirm</a>(inner, policy);
    (<a href="_destroy_some">option::destroy_some</a>(nft), promise)
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_borrow_nft"></a>

## Function `borrow_nft`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_borrow_nft">borrow_nft</a>&lt;Auth: drop, T: store, key&gt;(_witness: <a href="_Witness">witness::Witness</a>&lt;T&gt;, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>: &<b>mut</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">borrow_request::BorrowRequest</a>&lt;Auth, T&gt;): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_borrow_nft">borrow_nft</a>&lt;Auth: drop, T: key + store&gt;(
    // Creator <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_Witness">Witness</a>: Only the creator's contract should have
    // the ability <b>to</b> operate on the inner <a href="">object</a> extract a field
    _witness: DelegatedWitness&lt;T&gt;,
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>: &<b>mut</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth, T&gt;,
): T {
    <b>assert</b>!(<a href="_is_none">option::is_none</a>(&<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>.field), 0);
    <a href="_extract">option::extract</a>(&<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>.nft)
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_borrow_nft_ref_mut"></a>

## Function `borrow_nft_ref_mut`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_borrow_nft_ref_mut">borrow_nft_ref_mut</a>&lt;Auth: drop, T: store, key&gt;(_witness: <a href="_Witness">witness::Witness</a>&lt;T&gt;, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>: &<b>mut</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">borrow_request::BorrowRequest</a>&lt;Auth, T&gt;): &<b>mut</b> T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_borrow_nft_ref_mut">borrow_nft_ref_mut</a>&lt;Auth: drop, T: key + store&gt;(
    // Creator <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_Witness">Witness</a>: Only the creator's contract should have
    // the ability <b>to</b> operate on the inner <a href="">object</a> extract a field
    _witness: DelegatedWitness&lt;T&gt;,
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>: &<b>mut</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth, T&gt;,
): &<b>mut</b> T {
    <a href="_borrow_mut">option::borrow_mut</a>(&<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>.nft)
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_borrow_field"></a>

## Function `borrow_field`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_borrow_field">borrow_field</a>&lt;T: store, key, Field: store&gt;(_witness: <a href="_Witness">witness::Witness</a>&lt;T&gt;, nft_uid: &<b>mut</b> <a href="_UID">object::UID</a>): (Field, <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_ReturnPromise">borrow_request::ReturnPromise</a>&lt;T, Field&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_borrow_field">borrow_field</a>&lt;T: key + store, Field: store&gt;(
    _witness: DelegatedWitness&lt;T&gt;,
    nft_uid: &<b>mut</b> UID,
): (Field, <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_ReturnPromise">ReturnPromise</a>&lt;T, Field&gt;) {
    <b>let</b> nft_id = <a href="_uid_to_inner">object::uid_to_inner</a>(nft_uid);

    <b>let</b> field: Field = df::remove(nft_uid, <a href="_get">type_name::get</a>&lt;Field&gt;());

    (field, <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_ReturnPromise">ReturnPromise</a> { nft_id })
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_return_field"></a>

## Function `return_field`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_return_field">return_field</a>&lt;T: store, key, Field: store&gt;(_witness: <a href="_Witness">witness::Witness</a>&lt;T&gt;, nft_uid: &<b>mut</b> <a href="_UID">object::UID</a>, promise: <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_ReturnPromise">borrow_request::ReturnPromise</a>&lt;T, Field&gt;, field: Field)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_return_field">return_field</a>&lt;T: key + store, Field: store&gt;(
    _witness: DelegatedWitness&lt;T&gt;,
    nft_uid: &<b>mut</b> UID,
    promise: <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_ReturnPromise">ReturnPromise</a>&lt;T, Field&gt;,
    field: Field,
) {
    // No need <b>to</b> call the following assertion, we will confirm that the field
    // is present before resolving the <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>
    // <b>assert</b>!(<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>.is_returned == <b>false</b>, 0);
    <b>assert</b>!(<a href="_uid_to_inner">object::uid_to_inner</a>(nft_uid) == promise.nft_id, 0);
    df::add(nft_uid, <a href="_get">type_name::get</a>&lt;Field&gt;(), field);

    <b>let</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_ReturnPromise">ReturnPromise</a> { nft_id: _ } = promise;

}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_return_nft"></a>

## Function `return_nft`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_return_nft">return_nft</a>&lt;Auth: drop, T: store, key&gt;(_witness: <a href="_Witness">witness::Witness</a>&lt;T&gt;, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>: &<b>mut</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">borrow_request::BorrowRequest</a>&lt;Auth, T&gt;, nft: T)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_return_nft">return_nft</a>&lt;Auth: drop, T: key + store&gt;(
    _witness: DelegatedWitness&lt;T&gt;,
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>: &<b>mut</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth, T&gt;,
    nft: T,
) {
    <b>assert</b>!(<a href="_id">object::id</a>(&nft) == <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>.nft_id, 0);
    <a href="_fill">option::fill</a>(&<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>.nft, nft);
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_tx_sender"></a>

## Function `tx_sender`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_tx_sender">tx_sender</a>&lt;Auth: drop, T: store, key&gt;(self: &<a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">borrow_request::BorrowRequest</a>&lt;Auth, T&gt;): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_tx_sender">tx_sender</a>&lt;Auth: drop, T: key + store&gt;(self: &<a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth, T&gt;): <b>address</b> { self.sender }
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_is_borrow_field"></a>

## Function `is_borrow_field`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_is_borrow_field">is_borrow_field</a>&lt;Auth: drop, T: store, key&gt;(self: &<a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">borrow_request::BorrowRequest</a>&lt;Auth, T&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_is_borrow_field">is_borrow_field</a>&lt;Auth: drop, T: key + store&gt;(self: &<a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth, T&gt;): bool {
    <a href="_is_some">option::is_some</a>(&self.field)
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_field"></a>

## Function `field`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_field">field</a>&lt;Auth: drop, T: store, key&gt;(self: &<a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">borrow_request::BorrowRequest</a>&lt;Auth, T&gt;): <a href="_TypeName">type_name::TypeName</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_field">field</a>&lt;Auth: drop, T: key + store&gt;(self: &<a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth, T&gt;): TypeName {
    *<a href="_borrow">option::borrow</a>(&self.field)
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_nft_id"></a>

## Function `nft_id`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_nft_id">nft_id</a>&lt;Auth: drop, T: store, key&gt;(self: &<a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">borrow_request::BorrowRequest</a>&lt;Auth, T&gt;): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_nft_id">nft_id</a>&lt;Auth: drop, T: key + store&gt;(self: &<a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth, T&gt;): ID {
    <a href="_id">object::id</a>(<a href="_borrow">option::borrow</a>(&self.nft))
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_assert_is_borrow_nft"></a>

## Function `assert_is_borrow_nft`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_assert_is_borrow_nft">assert_is_borrow_nft</a>&lt;Auth: drop, T: store, key&gt;(<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>: &<a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">borrow_request::BorrowRequest</a>&lt;Auth, T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_assert_is_borrow_nft">assert_is_borrow_nft</a>&lt;Auth: drop, T: key + store&gt;(<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>: &<a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth, T&gt;) {
    <b>assert</b>!(<a href="_is_none">option::is_none</a>(&<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>.field), 0);
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_assert_is_borrow_field"></a>

## Function `assert_is_borrow_field`



<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_assert_is_borrow_field">assert_is_borrow_field</a>&lt;Auth: drop, T: store, key&gt;(<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>: &<a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">borrow_request::BorrowRequest</a>&lt;Auth, T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_assert_is_borrow_field">assert_is_borrow_field</a>&lt;Auth: drop, T: key + store&gt;(<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>: &<a href="borrow.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_borrow_request_BorrowRequest">BorrowRequest</a>&lt;Auth, T&gt;) {
    <b>assert</b>!(<a href="_is_some">option::is_some</a>(&<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>.field), 0);
}
</code></pre>



</details>
