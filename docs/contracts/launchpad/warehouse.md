
<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse"></a>

# Module `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::warehouse`

Module representing the NFT bookkeeping <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> type

<code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> is an unprotected object used to store pre-minted NFTs for
later withdrawal in a <code>Venue</code>. Additionally, it provides two randomized
withdrawal mechanisms, a pseudo-random withdrawal, or a hidden commitment
scheme.

<code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> is an unprotected type that can be constructed independently
before it is merged to a <code>Venue</code>, allowing <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> to be constructed
while avoiding shared consensus transactions on <code>Listing</code>.


-  [Resource `RedeemCommitment`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment)
-  [Resource `Warehouse`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse)
-  [Constants](#@Constants_0)
-  [Function `new`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_new)
-  [Function `init_warehouse`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_init_warehouse)
-  [Function `deposit_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_deposit_nft)
-  [Function `redeem_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft)
-  [Function `redeem_nft_and_transfer`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_and_transfer)
-  [Function `redeem_nft_at_index`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_at_index)
-  [Function `redeem_nft_at_index_and_transfer`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_at_index_and_transfer)
-  [Function `redeem_nft_with_id`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_with_id)
-  [Function `redeem_nft_with_id_and_transfer`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_with_id_and_transfer)
-  [Function `redeem_pseudorandom_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_pseudorandom_nft)
-  [Function `redeem_pseudorandom_nft_and_transfer`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_pseudorandom_nft_and_transfer)
-  [Function `new_redeem_commitment`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_new_redeem_commitment)
-  [Function `init_redeem_commitment`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_init_redeem_commitment)
-  [Function `redeem_random_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_random_nft)
-  [Function `redeem_random_nft_and_transfer`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_random_nft_and_transfer)
-  [Function `destroy`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_destroy)
-  [Function `destroy_commitment`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_destroy_commitment)
-  [Function `is_empty`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_is_empty)
-  [Function `nfts`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_nfts)
-  [Function `supply`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_supply)
-  [Function `idx_with_id`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_idx_with_id)
-  [Function `assert_is_empty`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_assert_is_empty)
-  [Function `select`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_select)


<pre><code><b>use</b> <a href="">0x1::hash</a>;
<b>use</b> <a href="">0x1::vector</a>;
<b>use</b> <a href="">0x2::bcs</a>;
<b>use</b> <a href="">0x2::dynamic_object_field</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::dynamic_vector</a>;
<b>use</b> <a href="">0x9e5962d5183664be8a7762fbe94eee6e3457c0cc701750c94c17f7f8ac5a32fb::pseudorandom</a>;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment"></a>

## Resource `RedeemCommitment`

Used for the client to commit a pseudo-random


<pre><code><b>struct</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="_UID">object::UID</a></code>
</dt>
<dd>
 <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a></code> ID
</dd>
<dt>
<code>hashed_sender_commitment: <a href="">vector</a>&lt;u8&gt;</code>
</dt>
<dd>
 Hashed sender commitment

 Sender will have to provide the pre-hashed value to be able to use
 this <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a></code>. This value can be pseudo-random as long
 as it is not predictable by the validator.
</dd>
<dt>
<code>contract_commitment: <a href="">vector</a>&lt;u8&gt;</code>
</dt>
<dd>
 Open commitment made by validator
</dd>
</dl>


</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse"></a>

## Resource `Warehouse`

<code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> object which stores NFTs of type <code>T</code>

The reason that the type is limited is to easily support random
withdrawals. If multiple types are allowed then user will not be able
to predict the type of the object they withdraw.


<pre><code><b>struct</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T: store, key&gt; <b>has</b> store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="_UID">object::UID</a></code>
</dt>
<dd>
 <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> ID
</dd>
<dt>
<code>nfts: <a href="_DynVec">dynamic_vector::DynVec</a>&lt;<a href="_ID">object::ID</a>&gt;</code>
</dt>
<dd>
 Initial vector of NFT IDs stored within <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>

 If this vector is overflowed, additional NFT IDs will be stored
 within dynamic fields. Avoids overhead of dynamic fields for most
 use-cases.
</dd>
<dt>
<code>total_deposited: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EIndexOutOfBounds"></a>

<code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> does not have NFT at specified index

Call <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_at_index">warehouse::redeem_nft_at_index</a></code> with an index that exists.


<pre><code><b>const</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EIndexOutOfBounds">EIndexOutOfBounds</a>: u64 = 3;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_ENotEmpty"></a>

<code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> still has NFTs left to withdraw

Call <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft">warehouse::redeem_nft</a></code> or a <code>Listing</code> market to withdraw remaining
NFTs.


<pre><code><b>const</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_ENotEmpty">ENotEmpty</a>: u64 = 2;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EEmpty"></a>

<code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> does not have NFTs left to withdraw

Call <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_deposit_nft">warehouse::deposit_nft</a></code> or <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_nft">listing::add_nft</a></code> to add NFTs.


<pre><code><b>const</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EEmpty">EEmpty</a>: u64 = 1;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EInvalidCommitment"></a>

Commitment in <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a></code> did not match original value committed

Call <code>warehouse::random_redeem_nft</code> with the correct commitment.


<pre><code><b>const</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EInvalidCommitment">EInvalidCommitment</a>: u64 = 6;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EInvalidCommitmentLength"></a>

Attempted to construct a <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a></code> with a hash length
different than 32 bytes


<pre><code><b>const</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EInvalidCommitmentLength">EInvalidCommitmentLength</a>: u64 = 5;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EInvalidNftId"></a>

<code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> did not contain NFT object with given ID

Call <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_with_id">warehouse::redeem_nft_with_id</a></code> with an ID that exists.


<pre><code><b>const</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EInvalidNftId">EInvalidNftId</a>: u64 = 4;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_LIMIT"></a>

Limit of NFTs held within each ID chunk
The real limitation is at <code>7998</code> but we give a slight buffer


<pre><code><b>const</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_LIMIT">LIMIT</a>: u64 = 7500;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_new"></a>

## Function `new`

Create a new <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_new">new</a>&lt;T: store, key&gt;(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_new">new</a>&lt;T: key + store&gt;(ctx: &<b>mut</b> TxContext): <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt; {
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a> {
        id: <a href="_new">object::new</a>(ctx),
        nfts: dyn_vector::empty(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_LIMIT">LIMIT</a>, ctx),
        total_deposited: 0,
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_init_warehouse"></a>

## Function `init_warehouse`

Creates a <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> and transfers to transaction sender


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_init_warehouse">init_warehouse</a>&lt;T: store, key&gt;(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_init_warehouse">init_warehouse</a>&lt;T: key + store&gt;(ctx: &<b>mut</b> TxContext) {
    <a href="_public_transfer">transfer::public_transfer</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_new">new</a>&lt;T&gt;(ctx), <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_deposit_nft"></a>

## Function `deposit_nft`

Deposits NFT to <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>

Endpoint is unprotected and relies on safely obtaining a mutable
reference to <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>.


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_deposit_nft">deposit_nft</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, nft: T)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_deposit_nft">deposit_nft</a>&lt;T: key + store&gt;(
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;,
    nft: T,
) {
    <b>let</b> nft_id = <a href="_id">object::id</a>(&nft);

    dyn_vector::push_back(&<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.nfts, nft_id);
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.total_deposited = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.total_deposited + 1;

    dof::add(&<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.id, nft_id, nft);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft"></a>

## Function `redeem_nft`

Redeems NFT from <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> sequentially


<a name="@Panics_1"></a>

###### Panics


Panics if <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> is empty.


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft">redeem_nft</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft">redeem_nft</a>&lt;T: key + store&gt;(
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;,
): T {
    <b>assert</b>!(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.total_deposited &gt; 0, <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EEmpty">EEmpty</a>);

    <b>let</b> nft_id = dyn_vector::pop_back(&<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.nfts);
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.total_deposited = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.total_deposited - 1;

    dof::remove(&<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.id, nft_id)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_and_transfer"></a>

## Function `redeem_nft_and_transfer`

Redeems NFT from <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> sequentially and transfers to sender

See <code>redeem_nft</code> for more details.


<a name="@Usage_2"></a>

###### Usage


Entry mint functions like <code>suimarines::mint_nft</code> take an <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>
object to deposit into. Calling <code>redeem_nft_and_transfer</code> allows one to
withdraw an NFT and own it directly.


<a name="@Panics_3"></a>

###### Panics


Panics if <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> is empty.


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_and_transfer">redeem_nft_and_transfer</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_and_transfer">redeem_nft_and_transfer</a>&lt;T: key + store&gt;(
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> nft = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft">redeem_nft</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>);
    <a href="_public_transfer">transfer::public_transfer</a>(nft, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_at_index"></a>

## Function `redeem_nft_at_index`

Redeems NFT from specific index in <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>

Does not retain original order of NFTs in the bookkeeping vector.


<a name="@Panics_4"></a>

###### Panics


Panics if index does not exist in <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_at_index">redeem_nft_at_index</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, index: u64): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_at_index">redeem_nft_at_index</a>&lt;T: key + store&gt;(
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;,
    index: u64,
): T {
    <b>assert</b>!(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.total_deposited &gt; 0, <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EEmpty">EEmpty</a>);
    <b>assert</b>!(index &lt; <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.total_deposited, <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EIndexOutOfBounds">EIndexOutOfBounds</a>);

    <b>let</b> nft_id = dyn_vector::pop_at_index(&<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.nfts, index);

    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.total_deposited = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.total_deposited - 1;

    dof::remove(&<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.id, nft_id)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_at_index_and_transfer"></a>

## Function `redeem_nft_at_index_and_transfer`

Redeems NFT from specific index in <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> and transfers to sender

See <code>redeem_nft_at_index</code> for more details.


<a name="@Panics_5"></a>

###### Panics


Panics if index does not exist in <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>.


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_at_index_and_transfer">redeem_nft_at_index_and_transfer</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, index: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_at_index_and_transfer">redeem_nft_at_index_and_transfer</a>&lt;T: key + store&gt;(
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;,
    index: u64,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> nft = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_at_index">redeem_nft_at_index</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, index);
    <a href="_public_transfer">transfer::public_transfer</a>(nft, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_with_id"></a>

## Function `redeem_nft_with_id`

Redeems NFT with specific ID from <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>

Does not retain original order of NFTs in the bookkeeping vector.


<a name="@Panics_6"></a>

###### Panics


Panics if NFT with ID does not exist in <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_with_id">redeem_nft_with_id</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, nft_id: <a href="_ID">object::ID</a>): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_with_id">redeem_nft_with_id</a>&lt;T: key + store&gt;(
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;,
    nft_id: ID,
): T {
    <b>let</b> idx = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_idx_with_id">idx_with_id</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, &nft_id);
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_at_index">redeem_nft_at_index</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, idx)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_with_id_and_transfer"></a>

## Function `redeem_nft_with_id_and_transfer`

Redeems NFT from specific index in <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> and transfers to sender

See <code>redeem_nft_with_id</code> for more details.


<a name="@Panics_7"></a>

###### Panics


Panics if index does not exist in <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>.


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_with_id_and_transfer">redeem_nft_with_id_and_transfer</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_with_id_and_transfer">redeem_nft_with_id_and_transfer</a>&lt;T: key + store&gt;(
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> nft = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_with_id">redeem_nft_with_id</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, nft_id);
    <a href="_public_transfer">transfer::public_transfer</a>(nft, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_pseudorandom_nft"></a>

## Function `redeem_pseudorandom_nft`

Pseudo-randomly redeems NFT from <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>

Endpoint is susceptible to validator prediction of the resulting index,
use <code>random_redeem_nft</code> instead.


<a name="@Panics_8"></a>

###### Panics


Panics if <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> is empty


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_pseudorandom_nft">redeem_pseudorandom_nft</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_pseudorandom_nft">redeem_pseudorandom_nft</a>&lt;T: key + store&gt;(
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;,
    ctx: &<b>mut</b> TxContext,
): T {
    <b>let</b> supply = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_supply">supply</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>);
    <b>assert</b>!(supply != 0, <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EEmpty">EEmpty</a>);

    // Use supply of `<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>` <b>as</b> an additional nonce factor
    <b>let</b> nonce = <a href="_empty">vector::empty</a>();
    <a href="_append">vector::append</a>(&<b>mut</b> nonce, sui::bcs::to_bytes(&supply));

    <b>let</b> contract_commitment = <a href="_rand_no_counter">pseudorandom::rand_no_counter</a>(nonce, ctx);

    <b>let</b> index = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_select">select</a>(supply, &contract_commitment);
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_at_index">redeem_nft_at_index</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, index)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_pseudorandom_nft_and_transfer"></a>

## Function `redeem_pseudorandom_nft_and_transfer`

Pseudo-randomly redeems specific NFT from <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> and transfers to
sender

See <code>redeem_pseudorandom_nft</code> for more details.


<a name="@Usage_9"></a>

###### Usage


Entry mint functions like <code>suimarines::mint_nft</code> take an <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>
object to deposit into. Calling <code>redeem_nft_and_transfer</code> allows one to
withdraw an NFT and own it directly.


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_pseudorandom_nft_and_transfer">redeem_pseudorandom_nft_and_transfer</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_pseudorandom_nft_and_transfer">redeem_pseudorandom_nft_and_transfer</a>&lt;T: key + store&gt;(
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> nft = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_pseudorandom_nft">redeem_pseudorandom_nft</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, ctx);
    <a href="_public_transfer">transfer::public_transfer</a>(nft, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_new_redeem_commitment"></a>

## Function `new_redeem_commitment`

Create a new <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a></code>

Contract commitment must be unfeasible to predict by the transaction
sender. The underlying value of the commitment can be pseudo-random as
long as it is not predictable by the validator.


<a name="@Panics_10"></a>

###### Panics


Panics if commitment is not 32 bytes.


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_new_redeem_commitment">new_redeem_commitment</a>(hashed_sender_commitment: <a href="">vector</a>&lt;u8&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">warehouse::RedeemCommitment</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_new_redeem_commitment">new_redeem_commitment</a>(
    hashed_sender_commitment: <a href="">vector</a>&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
): <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a> {
    <b>assert</b>!(
        <a href="_length">vector::length</a>(&hashed_sender_commitment) != 32,
        <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EInvalidCommitmentLength">EInvalidCommitmentLength</a>,
    );

    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a> {
        id: <a href="_new">object::new</a>(ctx),
        hashed_sender_commitment,
        contract_commitment: <a href="_rand_with_ctx">pseudorandom::rand_with_ctx</a>(ctx),
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_init_redeem_commitment"></a>

## Function `init_redeem_commitment`

Creates a new <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a></code> and transfers it to the transaction
caller.

Contract commitment must be unfeasible to predict by the transaction
caller. The underlying value of the commitment can be pseudo-random as
long as it is not predictable by the validator.


<a name="@Panics_11"></a>

###### Panics


Panics if commitment is not 32 bytes.


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_init_redeem_commitment">init_redeem_commitment</a>(hashed_sender_commitment: <a href="">vector</a>&lt;u8&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_init_redeem_commitment">init_redeem_commitment</a>(
    hashed_sender_commitment: <a href="">vector</a>&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> commitment = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_new_redeem_commitment">new_redeem_commitment</a>(hashed_sender_commitment,  ctx);
    <a href="_transfer">transfer::transfer</a>(commitment, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_random_nft"></a>

## Function `redeem_random_nft`

Randomly redeems NFT from <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>

Requires a <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a></code> created by the user in a separate
transaction to ensure that validators may not bias results favorably.
You can obtain a <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a></code> by calling
<code>init_redeem_commitment</code>.


<a name="@Panics_12"></a>

###### Panics


Panics if <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> is empty or <code>user_commitment</code> does not match the
hashed commitment in <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_random_nft">redeem_random_nft</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, commitment: <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">warehouse::RedeemCommitment</a>, user_commitment: <a href="">vector</a>&lt;u8&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_random_nft">redeem_random_nft</a>&lt;T: key + store&gt;(
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;,
    commitment: <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a>,
    user_commitment: <a href="">vector</a>&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
): T {
    <b>let</b> supply = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_supply">supply</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>);
    <b>assert</b>!(supply != 0, <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EEmpty">EEmpty</a>);

    // Verify user commitment
    <b>let</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a> {
        id,
        hashed_sender_commitment,
        contract_commitment
    } = commitment;

    <a href="_delete">object::delete</a>(id);

    <b>let</b> user_commitment = std::hash::sha3_256(user_commitment);
    <b>assert</b>!(
        user_commitment == hashed_sender_commitment,
        <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EInvalidCommitment">EInvalidCommitment</a>,
    );

    // Construct randomized index
    <a href="_append">vector::append</a>(&<b>mut</b> user_commitment, contract_commitment);
    // Use supply of `<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>` <b>as</b> a additional nonce factor
    <a href="_append">vector::append</a>(&<b>mut</b> user_commitment, sui::bcs::to_bytes(&supply));

    <b>let</b> contract_commitment = <a href="_rand_no_counter">pseudorandom::rand_no_counter</a>(user_commitment, ctx);

    <b>let</b> index = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_select">select</a>(supply, &contract_commitment);
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_at_index">redeem_nft_at_index</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, index)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_random_nft_and_transfer"></a>

## Function `redeem_random_nft_and_transfer`

Randomly redeems NFT from <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> and transfers to sender

See <code>redeem_random_nft</code> for more details.


<a name="@Panics_13"></a>

###### Panics


Panics if <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> is empty or <code>user_commitment</code> does not match the
hashed commitment in <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a></code>.


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_random_nft_and_transfer">redeem_random_nft_and_transfer</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, commitment: <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">warehouse::RedeemCommitment</a>, user_commitment: <a href="">vector</a>&lt;u8&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_random_nft_and_transfer">redeem_random_nft_and_transfer</a>&lt;T: key + store&gt;(
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;,
    commitment: <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a>,
    user_commitment: <a href="">vector</a>&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> nft = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_random_nft">redeem_random_nft</a>(
        <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, commitment, user_commitment, ctx,
    );
    <a href="_public_transfer">transfer::public_transfer</a>(nft, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_destroy"></a>

## Function `destroy`

Destroys <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>


<a name="@Panics_14"></a>

###### Panics


Panics if <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> is not empty


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_destroy">destroy</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_destroy">destroy</a>&lt;T: key + store&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;) {
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_assert_is_empty">assert_is_empty</a>(&<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>);

    <b>let</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a> { id, total_deposited: _, nfts } = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>;
    <a href="_delete">object::delete</a>(id);
    dyn_vector::delete(nfts);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_destroy_commitment"></a>

## Function `destroy_commitment`

Destroyes <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a></code>


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_destroy_commitment">destroy_commitment</a>(commitment: <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">warehouse::RedeemCommitment</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_destroy_commitment">destroy_commitment</a>(commitment: <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a>) {
    <b>let</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">RedeemCommitment</a> {
        id,
        hashed_sender_commitment: _,
        contract_commitment: _,
    } = commitment;

    <a href="_delete">object::delete</a>(id);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_is_empty"></a>

## Function `is_empty`

Return whether there are any <code>Nft</code> in the <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_is_empty">is_empty</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_is_empty">is_empty</a>&lt;T: key + store&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;): bool {
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.total_deposited == 0
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_nfts"></a>

## Function `nfts`

Returns list of all NFTs stored in <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_nfts">nfts</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;): &<a href="_DynVec">dynamic_vector::DynVec</a>&lt;<a href="_ID">object::ID</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_nfts">nfts</a>&lt;T: key + store&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;): &DynVec&lt;ID&gt; {
    &<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.nfts
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_supply"></a>

## Function `supply`

Return the net amount of <code>Nft</code>s deposited in the <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_supply">supply</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_supply">supply</a>&lt;T: key + store&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;): u64 {
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.total_deposited
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_idx_with_id"></a>

## Function `idx_with_id`

Get index of NFT given ID


<a name="@Panics_15"></a>

###### Panics


Panics if NFT was not registered in <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_idx_with_id">idx_with_id</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, nft_id: &<a href="_ID">object::ID</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_idx_with_id">idx_with_id</a>&lt;T: key + store&gt;(
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;,
    nft_id: &ID,
): u64 {
    <b>let</b> supply = <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.total_deposited;
    <b>assert</b>!(supply &gt; 0, <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EEmpty">EEmpty</a>);

    <b>let</b> idx = 0;
    <b>while</b> (idx &lt; supply) {
        <b>let</b> _idx = 0;
        <b>let</b> (chunk_idx, _) = dyn_vector::chunk_index(&<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.nfts, idx);
        <b>let</b> chunk = dyn_vector::borrow_chunk(&<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>.nfts, chunk_idx);
        <b>let</b> length = <a href="_length">vector::length</a>(chunk);
        <b>while</b> (_idx &lt; length) {
            <b>let</b> t_nft_id = <a href="_borrow">vector::borrow</a>(chunk, _idx);

            <b>if</b> (t_nft_id == nft_id) {
                <b>return</b> idx
            };

            idx = idx + 1;
            _idx = _idx + 1;
        };
    };

    <b>abort</b>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_EInvalidNftId">EInvalidNftId</a>)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_assert_is_empty"></a>

## Function `assert_is_empty`

Asserts that <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> is empty


<a name="@Panics_16"></a>

###### Panics


Panics if <code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a></code> has elements.


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_assert_is_empty">assert_is_empty</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_assert_is_empty">assert_is_empty</a>&lt;T: key + store&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: &<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">Warehouse</a>&lt;T&gt;) {
    <b>assert</b>!(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_is_empty">is_empty</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>), <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_ENotEmpty">ENotEmpty</a>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_select"></a>

## Function `select`

Outputs modulo of a random <code>u256</code> number and a bound

Due to <code>random &gt;&gt; bound</code> we <code>select</code> does not exhibit significant
modulo bias.


<pre><code><b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_select">select</a>(bound: u64, random: &<a href="">vector</a>&lt;u8&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_select">select</a>(bound: u64, random: &<a href="">vector</a>&lt;u8&gt;): u64 {
    <b>let</b> random = <a href="_u256_from_bytes">pseudorandom::u256_from_bytes</a>(random);
    <b>let</b> mod  = random % (bound <b>as</b> u256);
    (mod <b>as</b> u64)
}
</code></pre>



</details>
