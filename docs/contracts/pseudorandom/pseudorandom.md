
<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom"></a>

# Module `0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb::pseudorandom`

A module for Pseudo-Randomness


-  [Resource `Counter`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter)
-  [Constants](#@Constants_0)
-  [Function `init`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_init)
-  [Function `increment`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_increment)
-  [Function `rand`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand)
-  [Function `rand_no_counter`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_no_counter)
-  [Function `rand_no_nonce`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_no_nonce)
-  [Function `rand_no_ctx`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_no_ctx)
-  [Function `rand_with_counter`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_counter)
-  [Function `rand_with_ctx`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_ctx)
-  [Function `rand_with_nonce`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_nonce)
-  [Function `nonce_primitives`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_primitives)
-  [Function `nonce_counter`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_counter)
-  [Function `bcs_u8_from_bytes`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_bcs_u8_from_bytes)
-  [Function `bcs_u64_from_bytes`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_bcs_u64_from_bytes)
-  [Function `bcs_u128_from_bytes`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_bcs_u128_from_bytes)
-  [Function `u8_from_bytes`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u8_from_bytes)
-  [Function `u64_from_bytes`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u64_from_bytes)
-  [Function `u128_from_bytes`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u128_from_bytes)
-  [Function `u256_from_bytes`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u256_from_bytes)
-  [Function `select_u64`](#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_select_u64)


<pre><code><b>use</b> <a href="">0x1::hash</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x2::bcs</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
</code></pre>



<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter"></a>

## Resource `Counter`

Resource that wraps an integer counter


<pre><code><b>struct</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a> <b>has</b> key
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
<code>value: u256</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_ELowEntropy"></a>

Require that at least 32 bytes of entropy is provided to generate 32
byte random numbers.


<pre><code><b>const</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_ELowEntropy">ELowEntropy</a>: u64 = 1;
</code></pre>



<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_ETruncatedBytes"></a>

Conversion to integer would truncate bytes


<pre><code><b>const</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_ETruncatedBytes">ETruncatedBytes</a>: u64 = 1;
</code></pre>



<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_init"></a>

## Function `init`

Share a <code><a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a></code> resource with value <code>i</code>


<pre><code><b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_init">init</a>(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_init">init</a>(ctx: &<b>mut</b> TxContext) {
    // Create and share a <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a> resource. This is a privileged operation that
    // can only be done inside the <b>module</b> that declares the `<a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a>` resource
    <a href="_share_object">transfer::share_object</a>(<a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a> { id: <a href="_new">object::new</a>(ctx), value: 0 });
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_increment"></a>

## Function `increment`

Increment the value of the supplied <code><a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a></code> resource


<pre><code><b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_increment">increment</a>(counter: &<b>mut</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">pseudorandom::Counter</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_increment">increment</a>(counter: &<b>mut</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a>): u256 {
    <b>let</b> c_ref = &<b>mut</b> counter.value;
    *c_ref = *c_ref + 1;
    *c_ref
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand"></a>

## Function `rand`

Acquire pseudo-random value using <code><a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a></code>, transaction primitives,
and user-provided nonce


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand">rand</a>(nonce: <a href="">vector</a>&lt;u8&gt;, counter: &<b>mut</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">pseudorandom::Counter</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand">rand</a>(
    nonce: <a href="">vector</a>&lt;u8&gt;,
    counter: &<b>mut</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a>,
    ctx: &<b>mut</b> TxContext,
): <a href="">vector</a>&lt;u8&gt; {
    <a href="_append">vector::append</a>(&<b>mut</b> nonce, <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_counter">nonce_counter</a>(counter));
    <a href="_append">vector::append</a>(&<b>mut</b> nonce, <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_primitives">nonce_primitives</a>(ctx));
    <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_nonce">rand_with_nonce</a>(nonce)
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_no_counter"></a>

## Function `rand_no_counter`

Acquire pseudo-random value using transaction primitives and
user-provided nonce


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_no_counter">rand_no_counter</a>(nonce: <a href="">vector</a>&lt;u8&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_no_counter">rand_no_counter</a>(
    nonce: <a href="">vector</a>&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
): <a href="">vector</a>&lt;u8&gt; {
    <a href="_append">vector::append</a>(&<b>mut</b> nonce, <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_primitives">nonce_primitives</a>(ctx));
    <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_nonce">rand_with_nonce</a>(nonce)
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_no_nonce"></a>

## Function `rand_no_nonce`

Acquire pseudo-random value using <code><a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a></code> and transaction primitives

It is recommended that the user use a method that allows passing a
custom nonce that would allow greater randomization.


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_no_nonce">rand_no_nonce</a>(counter: &<b>mut</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">pseudorandom::Counter</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_no_nonce">rand_no_nonce</a>(
    counter: &<b>mut</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a>,
    ctx: &<b>mut</b> TxContext,
): <a href="">vector</a>&lt;u8&gt; {
    <b>let</b> nonce = <a href="_empty">vector::empty</a>();
    <a href="_append">vector::append</a>(&<b>mut</b> nonce, <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_counter">nonce_counter</a>(counter));
    <a href="_append">vector::append</a>(&<b>mut</b> nonce, <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_primitives">nonce_primitives</a>(ctx));
    <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_nonce">rand_with_nonce</a>(nonce)
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_no_ctx"></a>

## Function `rand_no_ctx`

Acquire pseudo-random value using <code><a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a></code> and user-provided nonce


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_no_ctx">rand_no_ctx</a>(nonce: <a href="">vector</a>&lt;u8&gt;, counter: &<b>mut</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">pseudorandom::Counter</a>): <a href="">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_no_ctx">rand_no_ctx</a>(
    nonce: <a href="">vector</a>&lt;u8&gt;,
    counter: &<b>mut</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a>,
): <a href="">vector</a>&lt;u8&gt; {
    <a href="_append">vector::append</a>(&<b>mut</b> nonce, <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_counter">nonce_counter</a>(counter));
    <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_nonce">rand_with_nonce</a>(nonce)
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_counter"></a>

## Function `rand_with_counter`

Acquire pseudo-random value using <code><a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a></code>

It is recommended that the user use a method that allows passing a
custom nonce that would allow greater randomization, or at least
use more than one source of randomness.


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_counter">rand_with_counter</a>(counter: &<b>mut</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">pseudorandom::Counter</a>): <a href="">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_counter">rand_with_counter</a>(counter: &<b>mut</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a>): <a href="">vector</a>&lt;u8&gt; {
    <b>let</b> nonce = <a href="_empty">vector::empty</a>();
    <a href="_append">vector::append</a>(&<b>mut</b> nonce, <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_counter">nonce_counter</a>(counter));
    <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_nonce">rand_with_nonce</a>(nonce)
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_ctx"></a>

## Function `rand_with_ctx`

Acquire pseudo-random value using transaction primitives

It is recommended that the user use a method that allows passing a
custom nonce that would allow greater randomization, or at least
use more than one source of randomness.


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_ctx">rand_with_ctx</a>(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_ctx">rand_with_ctx</a>(ctx: &<b>mut</b> TxContext): <a href="">vector</a>&lt;u8&gt; {
    <b>let</b> nonce = <a href="_empty">vector::empty</a>();
    <a href="_append">vector::append</a>(&<b>mut</b> nonce, <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_primitives">nonce_primitives</a>(ctx));
    <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_nonce">rand_with_nonce</a>(nonce)
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_nonce"></a>

## Function `rand_with_nonce`

Acquire pseudo-random value using user-provided nonce

It is recommended that the user use at least more than one source of
randomness.


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_nonce">rand_with_nonce</a>(nonce: <a href="">vector</a>&lt;u8&gt;): <a href="">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_rand_with_nonce">rand_with_nonce</a>(nonce: <a href="">vector</a>&lt;u8&gt;): <a href="">vector</a>&lt;u8&gt; {
    <b>assert</b>!(<a href="_length">vector::length</a>(&nonce) &gt;= 32, <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_ELowEntropy">ELowEntropy</a>);
    <a href="_sha3_256">hash::sha3_256</a>(nonce)
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_primitives"></a>

## Function `nonce_primitives`

Generate nonce from transaction primitives


<pre><code><b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_primitives">nonce_primitives</a>(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_primitives">nonce_primitives</a>(ctx: &<b>mut</b> TxContext): <a href="">vector</a>&lt;u8&gt; {
    <b>let</b> uid = <a href="_new">object::new</a>(ctx);
    <b>let</b> object_nonce = <a href="_uid_to_bytes">object::uid_to_bytes</a>(&uid);
    <a href="_delete">object::delete</a>(uid);

    <b>let</b> epoch_nonce = <a href="_to_bytes">bcs::to_bytes</a>(&<a href="_epoch">tx_context::epoch</a>(ctx));
    <b>let</b> sender_nonce = <a href="_to_bytes">bcs::to_bytes</a>(&<a href="_sender">tx_context::sender</a>(ctx));

    <a href="_append">vector::append</a>(&<b>mut</b> object_nonce, epoch_nonce);
    <a href="_append">vector::append</a>(&<b>mut</b> object_nonce, sender_nonce);

    object_nonce
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_counter"></a>

## Function `nonce_counter`

Generate nonce from <code><a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a></code>


<pre><code><b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_counter">nonce_counter</a>(counter: &<b>mut</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">pseudorandom::Counter</a>): <a href="">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_nonce_counter">nonce_counter</a>(counter: &<b>mut</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_Counter">Counter</a>): <a href="">vector</a>&lt;u8&gt; {
    <a href="_to_bytes">bcs::to_bytes</a>(&<a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_increment">increment</a>(counter))
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_bcs_u8_from_bytes"></a>

## Function `bcs_u8_from_bytes`

Deserialize <code>u8</code> from BCS bytes


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_bcs_u8_from_bytes">bcs_u8_from_bytes</a>(bytes: <a href="">vector</a>&lt;u8&gt;): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_bcs_u8_from_bytes">bcs_u8_from_bytes</a>(bytes: <a href="">vector</a>&lt;u8&gt;): u8 {
    bcs::peel_u8(&<b>mut</b> bcs::new(bytes))
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_bcs_u64_from_bytes"></a>

## Function `bcs_u64_from_bytes`

Deserialize <code>u64</code> from BCS bytes


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_bcs_u64_from_bytes">bcs_u64_from_bytes</a>(bytes: <a href="">vector</a>&lt;u8&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_bcs_u64_from_bytes">bcs_u64_from_bytes</a>(bytes: <a href="">vector</a>&lt;u8&gt;): u64 {
    bcs::peel_u64(&<b>mut</b> bcs::new(bytes))
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_bcs_u128_from_bytes"></a>

## Function `bcs_u128_from_bytes`

Deserialize <code>u128</code> from BCS bytes


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_bcs_u128_from_bytes">bcs_u128_from_bytes</a>(bytes: <a href="">vector</a>&lt;u8&gt;): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_bcs_u128_from_bytes">bcs_u128_from_bytes</a>(bytes: <a href="">vector</a>&lt;u8&gt;): u128 {
    bcs::peel_u128(&<b>mut</b> bcs::new(bytes))
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u8_from_bytes"></a>

## Function `u8_from_bytes`

Transpose bytes into <code>u8</code>

Zero byte will be used for empty vector.


<a name="@Panics_1"></a>

###### Panics


Panics if bytes vector is longer than 1 byte due to potential to
truncate data unexpectedly


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u8_from_bytes">u8_from_bytes</a>(bytes: &<a href="">vector</a>&lt;u8&gt;): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u8_from_bytes">u8_from_bytes</a>(bytes: &<a href="">vector</a>&lt;u8&gt;): u8 {
    // Cap length at 1 byte
    <b>let</b> len = <a href="_length">vector::length</a>(bytes);
    <b>assert</b>!(len &lt;= 1, <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_ETruncatedBytes">ETruncatedBytes</a>);

    <b>if</b> (<a href="_length">vector::length</a>(bytes) &lt; 1) {
        0
    } <b>else</b> {
        *<a href="_borrow">vector::borrow</a>(bytes, 0)
    }
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u64_from_bytes"></a>

## Function `u64_from_bytes`

Transpose bytes into <code>u64</code>

Zero bytes will be used for vectors shorter than 8 bytes


<a name="@Panics_2"></a>

###### Panics


Panics if bytes vector is longer than 8 bytes due to potential to
truncate data unexpectedly


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u64_from_bytes">u64_from_bytes</a>(bytes: &<a href="">vector</a>&lt;u8&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u64_from_bytes">u64_from_bytes</a>(bytes: &<a href="">vector</a>&lt;u8&gt;): u64 {
    <b>let</b> m: u64 = 0;

    // Cap length at 8 bytes
    <b>let</b> len = <a href="_length">vector::length</a>(bytes);
    <b>assert</b>!(len &lt;= 8, <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_ETruncatedBytes">ETruncatedBytes</a>);

    <b>let</b> i = 0;
    <b>while</b> (i &lt; len) {
        m = m &lt;&lt; 8;
        <b>let</b> byte = *<a href="_borrow">vector::borrow</a>(bytes, i);
        m = m + (byte <b>as</b> u64);
        i = i + 1;
    };

    m
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u128_from_bytes"></a>

## Function `u128_from_bytes`

Transpose bytes into <code>u64</code>

Zero bytes will be used for vectors shorter than 16 bytes


<a name="@Panics_3"></a>

###### Panics


Panics if bytes vector is longer than 16 bytes due to potential to
truncate data unexpectedly


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u128_from_bytes">u128_from_bytes</a>(bytes: &<a href="">vector</a>&lt;u8&gt;): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u128_from_bytes">u128_from_bytes</a>(bytes: &<a href="">vector</a>&lt;u8&gt;): u128 {
    <b>let</b> m: u128 = 0;

    // Cap length at 16 bytes
    <b>let</b> len = <a href="_length">vector::length</a>(bytes);
    <b>assert</b>!(len &lt;= 16, <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_ETruncatedBytes">ETruncatedBytes</a>);

    <b>let</b> i = 0;
    <b>while</b> (i &lt; len) {
        m = m &lt;&lt; 8;
        <b>let</b> byte = *<a href="_borrow">vector::borrow</a>(bytes, i);
        m = m + (byte <b>as</b> u128);
        i = i + 1;
    };

    m
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u256_from_bytes"></a>

## Function `u256_from_bytes`

Transpose bytes into <code>u256</code>

Zero bytes will be used for vectors shorter than 32 bytes


<a name="@Panics_4"></a>

###### Panics


Panics if bytes vector is longer than 32 bytes due to potential to
truncate data unexpectedly


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u256_from_bytes">u256_from_bytes</a>(bytes: &<a href="">vector</a>&lt;u8&gt;): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u256_from_bytes">u256_from_bytes</a>(bytes: &<a href="">vector</a>&lt;u8&gt;): u256 {
    <b>let</b> m: u256 = 0;

    // Cap length at 32 bytes
    <b>let</b> len = <a href="_length">vector::length</a>(bytes);
    <b>assert</b>!(len &lt;= 32, <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_ETruncatedBytes">ETruncatedBytes</a>);

    <b>let</b> i = 0;
    <b>while</b> (i &lt; len) {
        m = m &lt;&lt; 8;
        <b>let</b> byte = *<a href="_borrow">vector::borrow</a>(bytes, i);
        m = m + (byte <b>as</b> u256);
        i = i + 1;
    };

    m
}
</code></pre>



</details>

<a name="0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_select_u64"></a>

## Function `select_u64`

Selects a random 8 byte number within given bound using 32 byte random
vector.


<a name="@Panics_5"></a>

###### Panics


Panics if random vector is not 32 bytes long.


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_select_u64">select_u64</a>(bound: u64, random: &<a href="">vector</a>&lt;u8&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_select_u64">select_u64</a>(bound: u64, random: &<a href="">vector</a>&lt;u8&gt;): u64 {
    <b>assert</b>!(<a href="_length">vector::length</a>(random) &gt;= 32, <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_ELowEntropy">ELowEntropy</a>);
    <b>let</b> random = <a href="pseudorandom.md#0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb_pseudorandom_u256_from_bytes">u256_from_bytes</a>(random);

    <b>let</b> mod  = random % (bound <b>as</b> u256);
    (mod <b>as</b> u64)
}
</code></pre>



</details>
