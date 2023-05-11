
<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace"></a>

# Module `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::marketplace`

Module of a <code><a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a></code> type.

Marketplaces are platforms that facilitate the listing of NFT collections
to the public, by facilitating a primary market UI. NFT Creators can create
Listings to sell their NFTs to the public and can decide to partner with
a Marketplace such that these are sold through the Marketplace UI. In order
for the Marketplace to be remunerated, the <code>Listing</code> must be attached to
a <code><a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a></code>.

Marketplaces and dApps that want to offer a launchpad service should create
a <code><a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a></code> object.

After the creation of the <code><a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a></code> a <code>Listing</code> for the NFT listing needs
to be created by the creator of the NFT Collection. Then, the <code>Listing</code> admin
should request to join the marketplace launchpad, pending acceptance.

Whilst the <code><a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a></code> stipulates a default fee policy, the marketplace
admin can decide to create a custom fee policy for each <code>Listing</code>.

The <code>Listing</code> acts as the object that configures the primary NFT listing
strategy, that is the primary market sale. Primary market sales can take
many shapes, depending on the business level requirements.


-  [Resource `Marketplace`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace)
-  [Constants](#@Constants_0)
-  [Function `new`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_new)
-  [Function `init_marketplace`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_init_marketplace)
-  [Function `receiver`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_receiver)
-  [Function `admin`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_admin)
-  [Function `default_fee`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_default_fee)
-  [Function `assert_marketplace_admin`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_assert_marketplace_admin)
-  [Function `assert_version`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_assert_version)
-  [Function `migrate`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_migrate)


<pre><code><b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::object_box</a>;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace"></a>

## Resource `Marketplace`



<pre><code><b>struct</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a> <b>has</b> store, key
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
<code>version: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>admin: <b>address</b></code>
</dt>
<dd>
 The address of the marketplace administrator
</dd>
<dt>
<code>receiver: <b>address</b></code>
</dt>
<dd>
 Receiver of marketplace fees
</dd>
<dt>
<code>default_fee: <a href="_ObjectBox">object_box::ObjectBox</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_ENotUpgraded"></a>



<pre><code><b>const</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_ENotUpgraded">ENotUpgraded</a>: u64 = 999;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_EWrongVersion"></a>



<pre><code><b>const</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_EWrongVersion">EWrongVersion</a>: u64 = 1000;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_VERSION"></a>



<pre><code><b>const</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_VERSION">VERSION</a>: u64 = 1;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_EInvalidAdmin"></a>

Transaction sender was not admin of marketplace


<pre><code><b>const</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_EInvalidAdmin">EInvalidAdmin</a>: u64 = 1;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_new"></a>

## Function `new`

Initialises a <code><a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a></code> object and returns it


<pre><code><b>public</b> <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_new">new</a>&lt;F: store, key&gt;(admin: <b>address</b>, receiver: <b>address</b>, default_fee: F, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_new">new</a>&lt;F: key + store&gt;(
    admin: <b>address</b>,
    receiver: <b>address</b>,
    default_fee: F,
    ctx: &<b>mut</b> TxContext,
): <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a> {
    <b>let</b> uid = <a href="_new">object::new</a>(ctx);
    <b>let</b> default_fee = obox::new(default_fee, ctx);

    <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a> {
        id: uid,
        version: <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_VERSION">VERSION</a>,
        admin,
        receiver,
        default_fee,
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_init_marketplace"></a>

## Function `init_marketplace`

Initialises a <code><a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a></code> object and shares it


<pre><code><b>public</b> entry <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_init_marketplace">init_marketplace</a>&lt;F: store, key&gt;(admin: <b>address</b>, receiver: <b>address</b>, default_fee: F, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_init_marketplace">init_marketplace</a>&lt;F: key + store&gt;(
    admin: <b>address</b>,
    receiver: <b>address</b>,
    default_fee: F,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a> = <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_new">new</a>(
        admin,
        receiver,
        default_fee,
        ctx,
    );

    <a href="_public_share_object">transfer::public_share_object</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_receiver"></a>

## Function `receiver`

Get the Marketplace's <code>receiver</code> address


<pre><code><b>public</b> <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_receiver">receiver</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_receiver">receiver</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a>): <b>address</b> {
    <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>.receiver
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_admin"></a>

## Function `admin`

Get the Marketplace's <code>admin</code> address


<pre><code><b>public</b> <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_admin">admin</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_admin">admin</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a>): <b>address</b> {
    <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>.admin
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_default_fee"></a>

## Function `default_fee`

Get the Marketplace's <code>default_fee</code>


<pre><code><b>public</b> <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_default_fee">default_fee</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>): &<a href="_ObjectBox">object_box::ObjectBox</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_default_fee">default_fee</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a>): &ObjectBox {
    &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>.default_fee
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_assert_marketplace_admin"></a>

## Function `assert_marketplace_admin`



<pre><code><b>public</b> <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_assert_marketplace_admin">assert_marketplace_admin</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_assert_marketplace_admin">assert_marketplace_admin</a>(
    <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a>,
    ctx: &<b>mut</b> TxContext,
) {
    <b>assert</b>!(
        <a href="_sender">tx_context::sender</a>(ctx) == <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>.admin,
        <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_EInvalidAdmin">EInvalidAdmin</a>,
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_assert_version"></a>

## Function `assert_version`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_assert_version">assert_version</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>)<b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_assert_version">assert_version</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a>) {
    <b>assert</b>!(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>.version == <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_VERSION">VERSION</a>, <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_EWrongVersion">EWrongVersion</a>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_migrate"></a>

## Function `migrate`



<pre><code>entry <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_migrate">migrate</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<b>mut</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>entry <b>fun</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_migrate">migrate</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<b>mut</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">Marketplace</a>, ctx: &<b>mut</b> TxContext) {
    <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_assert_marketplace_admin">assert_marketplace_admin</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>, ctx);

    <b>assert</b>!(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>.version &lt; <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_VERSION">VERSION</a>, <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_ENotUpgraded">ENotUpgraded</a>);
    <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>.version = <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_VERSION">VERSION</a>;
}
</code></pre>



</details>
