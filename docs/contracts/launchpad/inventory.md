
<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory"></a>

# Module `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::inventory`

Module of <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> type, a type-erased wrapper around <code>Warehouse</code>

Additionally, <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> is responsible for providing a safe interface to
change the logical owner of NFTs redeemed from it.


-  [Resource `Inventory`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory)
-  [Struct `WarehouseKey`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_WarehouseKey)
-  [Constants](#@Constants_0)
-  [Function `from_warehouse`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_from_warehouse)
-  [Function `deposit_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_deposit_nft)
-  [Function `redeem_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft)
-  [Function `redeem_nft_and_transfer`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_and_transfer)
-  [Function `redeem_nft_at_index`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_at_index)
-  [Function `redeem_nft_at_index_and_transfer`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_at_index_and_transfer)
-  [Function `redeem_nft_with_id`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_with_id)
-  [Function `redeem_nft_with_id_and_transfer`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_with_id_and_transfer)
-  [Function `redeem_pseudorandom_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_pseudorandom_nft)
-  [Function `redeem_pseudorandom_nft_and_transfer`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_pseudorandom_nft_and_transfer)
-  [Function `redeem_random_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_random_nft)
-  [Function `redeem_random_nft_and_transfer`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_random_nft_and_transfer)
-  [Function `is_empty`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_is_empty)
-  [Function `supply`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_supply)
-  [Function `is_warehouse`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_is_warehouse)
-  [Function `borrow_warehouse`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse)
-  [Function `borrow_warehouse_mut`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse_mut)
-  [Function `assert_warehouse`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_assert_warehouse)


<pre><code><b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x2::dynamic_field</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::warehouse</a>;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory"></a>

## Resource `Inventory`

A type-erased wrapper around <code>Warehouse</code>


<pre><code><b>struct</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt; <b>has</b> store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="_UID">object::UID</a></code>
</dt>
<dd>
 <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> ID
</dd>
</dl>


</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_WarehouseKey"></a>

## Struct `WarehouseKey`



<pre><code><b>struct</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_WarehouseKey">WarehouseKey</a> <b>has</b> <b>copy</b>, drop, store
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


<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_ENotFactory"></a>

<code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> is not a <code>Factory</code>

NOTE: Factory has been deprecated in is reintroduced in Launchpad V2


<pre><code><b>const</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_ENotFactory">ENotFactory</a>: u64 = 2;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_ENotWarehouse"></a>

<code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> is not a <code>Warehouse</code>

Call <code>from_warehouse</code> to create an <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> from <code>Warehouse</code>


<pre><code><b>const</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_ENotWarehouse">ENotWarehouse</a>: u64 = 1;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_from_warehouse"></a>

## Function `from_warehouse`

Create a new <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> from a <code>Warehouse</code>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_from_warehouse">from_warehouse</a>&lt;T: store, key&gt;(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_from_warehouse">from_warehouse</a>&lt;T: key + store&gt;(
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: Warehouse&lt;T&gt;,
    ctx: &<b>mut</b> TxContext,
): <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt; {
    <b>let</b> inventory_id = <a href="_new">object::new</a>(ctx);
    df::add(&<b>mut</b> inventory_id, <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_WarehouseKey">WarehouseKey</a> {}, <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>);

    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a> { id: inventory_id }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_deposit_nft"></a>

## Function `deposit_nft`

Deposits NFT to <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code>

Endpoint is exclusive to friend modules.


<a name="@Panics_1"></a>

###### Panics


Panics if <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> is not a <code>Warehouse</code>.


<pre><code><b>public</b> entry <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_deposit_nft">deposit_nft</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;, nft: T)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_deposit_nft">deposit_nft</a>&lt;T: key + store&gt;(
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;,
    nft: T,
) {
    <b>let</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a> = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse_mut">borrow_warehouse_mut</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_deposit_nft">warehouse::deposit_nft</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, nft);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft"></a>

## Function `redeem_nft`

Redeems NFT from <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> sequentially

Endpoint is exclusive to friend modules.


<a name="@Panics_2"></a>

###### Panics


Panics if no supply is available.


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft">redeem_nft</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft">redeem_nft</a>&lt;T: key + store&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;): T {
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_assert_warehouse">assert_warehouse</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);

    <b>let</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a> = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse_mut">borrow_warehouse_mut</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft">warehouse::redeem_nft</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_and_transfer"></a>

## Function `redeem_nft_and_transfer`

Redeems NFT from <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> sequentially and transfers to owner

See <code>redeem_nft</code> for more details


<a name="@Panics_3"></a>

###### Panics


Panics if no supply is available.


<pre><code><b>public</b> entry <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_and_transfer">redeem_nft_and_transfer</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_and_transfer">redeem_nft_and_transfer</a>&lt;T: key + store&gt;(
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> nft = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft">redeem_nft</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    <a href="_public_transfer">transfer::public_transfer</a>(nft, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_at_index"></a>

## Function `redeem_nft_at_index`

Redeems NFT from specific index in <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code>

Endpoint is exclusive to friend modules.


<a name="@Panics_4"></a>

###### Panics


Panics if underlying type is not a <code>Warehouse</code> and index does not
exist.


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_at_index">redeem_nft_at_index</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;, index: u64): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_at_index">redeem_nft_at_index</a>&lt;T: key + store&gt;(
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;,
    index: u64,
): T {
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_assert_warehouse">assert_warehouse</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);

    <b>let</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a> = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse_mut">borrow_warehouse_mut</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_at_index">warehouse::redeem_nft_at_index</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, index)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_at_index_and_transfer"></a>

## Function `redeem_nft_at_index_and_transfer`

Redeems NFT from specific index in <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> and transfers to sender

See <code>redeem_nft_at_index</code> for more details.


<a name="@Panics_5"></a>

###### Panics


Panics if underlying type is not a <code>Warehouse</code> and index does not
exist.


<pre><code><b>public</b> entry <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_at_index_and_transfer">redeem_nft_at_index_and_transfer</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;, index: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_at_index_and_transfer">redeem_nft_at_index_and_transfer</a>&lt;T: key + store&gt;(
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;,
    index: u64,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> nft = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_at_index">redeem_nft_at_index</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>, index);
    <a href="_public_transfer">transfer::public_transfer</a>(nft, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_with_id"></a>

## Function `redeem_nft_with_id`

Redeems NFT with specific ID from <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code>

Endpoint is exclusive to friend modules.


<a name="@Panics_6"></a>

###### Panics


Panics if underlying type is not a <code>Warehouse</code> and NFT with ID does not
exist.


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_with_id">redeem_nft_with_id</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;, nft_id: <a href="_ID">object::ID</a>): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_with_id">redeem_nft_with_id</a>&lt;T: key + store&gt;(
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;,
    nft_id: ID,
): T {
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_assert_warehouse">assert_warehouse</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);

    <b>let</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a> = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse_mut">borrow_warehouse_mut</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_nft_with_id">warehouse::redeem_nft_with_id</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, nft_id)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_with_id_and_transfer"></a>

## Function `redeem_nft_with_id_and_transfer`

Redeems NFT from specific index in <code>Warehouse</code> and transfers to sender

See <code>redeem_nft_with_id</code> for more details.


<a name="@Panics_7"></a>

###### Panics


Panics if index does not exist in <code>Warehouse</code>.


<pre><code><b>public</b> entry <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_with_id_and_transfer">redeem_nft_with_id_and_transfer</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_with_id_and_transfer">redeem_nft_with_id_and_transfer</a>&lt;T: key + store&gt;(
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> nft = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_with_id">redeem_nft_with_id</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>, nft_id);
    <a href="_public_transfer">transfer::public_transfer</a>(nft, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_pseudorandom_nft"></a>

## Function `redeem_pseudorandom_nft`

Pseudo-randomly redeems NFT from <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code>

Endpoint is susceptible to validator prediction of the resulting index,
use <code>random_redeem_nft</code> instead.

Endpoint is exclusive to friend modules.


<a name="@Panics_8"></a>

###### Panics


Panics if there is no supply left.


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_pseudorandom_nft">redeem_pseudorandom_nft</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_pseudorandom_nft">redeem_pseudorandom_nft</a>&lt;T: key + store&gt;(
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;,
    ctx: &<b>mut</b> TxContext,
): T {
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_assert_warehouse">assert_warehouse</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);

    <b>let</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a> = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse_mut">borrow_warehouse_mut</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_pseudorandom_nft">warehouse::redeem_pseudorandom_nft</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, ctx)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_pseudorandom_nft_and_transfer"></a>

## Function `redeem_pseudorandom_nft_and_transfer`

Pseudo-randomly redeems NFT from <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> and transfers to owner

See <code>redeem_pseudorandom_nft</code> for more details.


<a name="@Panics_9"></a>

###### Panics


Panics if there is no supply left.


<pre><code><b>public</b> entry <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_pseudorandom_nft_and_transfer">redeem_pseudorandom_nft_and_transfer</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_pseudorandom_nft_and_transfer">redeem_pseudorandom_nft_and_transfer</a>&lt;T: key + store&gt;(
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> nft = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_pseudorandom_nft">redeem_pseudorandom_nft</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>, ctx);
    <a href="_public_transfer">transfer::public_transfer</a>(nft, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_random_nft"></a>

## Function `redeem_random_nft`

Randomly redeems NFT from <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code>

Requires a <code>RedeemCommitment</code> created by the user in a separate
transaction to ensure that validators may not bias results favorably.
You can obtain a <code>RedeemCommitment</code> by calling
<code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_init_redeem_commitment">warehouse::init_redeem_commitment</a></code>.

Endpoint is exclusive to friend modules.


<a name="@Panics_10"></a>

###### Panics


Panics if there is no supply left or <code>user_commitment</code> does not match
the hashed commitment in <code>RedeemCommitment</code>.


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_random_nft">redeem_random_nft</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;, commitment: <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">warehouse::RedeemCommitment</a>, user_commitment: <a href="">vector</a>&lt;u8&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_random_nft">redeem_random_nft</a>&lt;T: key + store&gt;(
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;,
    commitment: RedeemCommitment,
    user_commitment: <a href="">vector</a>&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
): T {
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_assert_warehouse">assert_warehouse</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);

    <b>let</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a> = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse_mut">borrow_warehouse_mut</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_redeem_random_nft">warehouse::redeem_random_nft</a>(
        <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, commitment, user_commitment, ctx,
    )
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_random_nft_and_transfer"></a>

## Function `redeem_random_nft_and_transfer`

Randomly redeems NFT from <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> and transfers to owner

See <code>redeem_random_nft</code> for more details.


<a name="@Panics_11"></a>

###### Panics


Panics if there is no supply left or <code>user_commitment</code> does not match
the hashed commitment in <code>RedeemCommitment</code>.


<pre><code><b>public</b> entry <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_random_nft_and_transfer">redeem_random_nft_and_transfer</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;, commitment: <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">warehouse::RedeemCommitment</a>, user_commitment: <a href="">vector</a>&lt;u8&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_random_nft_and_transfer">redeem_random_nft_and_transfer</a>&lt;T: key + store&gt;(
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;,
    commitment: RedeemCommitment,
    user_commitment: <a href="">vector</a>&lt;u8&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> nft = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_random_nft">redeem_random_nft</a>(
        <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>, commitment, user_commitment, ctx,
    );
    <a href="_public_transfer">transfer::public_transfer</a>(nft, <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_is_empty"></a>

## Function `is_empty`

Returns whether <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> has any remaining supply


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_is_empty">is_empty</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_is_empty">is_empty</a>&lt;T: key + store&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;): bool {
    <b>let</b> supply = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_supply">supply</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    <b>if</b> (<a href="_is_some">option::is_some</a>(&supply)) {
        <a href="_destroy_some">option::destroy_some</a>(supply) == 0
    } <b>else</b> {
        <a href="_destroy_none">option::destroy_none</a>(supply);
        // None is only returned for factories <b>with</b> unregulated supplies
        <b>false</b>
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_supply"></a>

## Function `supply`

Returns the available supply in <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code>


<a name="@Panics_12"></a>

###### Panics


Panics if supply was exceeded.


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_supply">supply</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;): <a href="_Option">option::Option</a>&lt;u64&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_supply">supply</a>&lt;T: key + store&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;): Option&lt;u64&gt; {
    <b>assert</b>!(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_is_warehouse">is_warehouse</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>), <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_ENotWarehouse">ENotWarehouse</a>);

    <b>let</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a> = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse">borrow_warehouse</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    <a href="_some">option::some</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_supply">warehouse::supply</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>))
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_is_warehouse"></a>

## Function `is_warehouse`

Returns whether <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> is a <code>Warehouse</code>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_is_warehouse">is_warehouse</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_is_warehouse">is_warehouse</a>&lt;T: key + store&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;): bool {
    df::exists_with_type&lt;<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_WarehouseKey">WarehouseKey</a>, Warehouse&lt;T&gt;&gt;(
        &<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>.id, <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_WarehouseKey">WarehouseKey</a> {}
    )
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse"></a>

## Function `borrow_warehouse`

Borrows <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> as <code>Warehouse</code>


<a name="@Panics_13"></a>

###### Panics


Panics if no <code>Warehouse</code>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse">borrow_warehouse</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;): &<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse">borrow_warehouse</a>&lt;T: key + store&gt;(
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;,
): &Warehouse&lt;T&gt; {
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_assert_warehouse">assert_warehouse</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    df::borrow(&<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>.id, <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_WarehouseKey">WarehouseKey</a> {})
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse_mut"></a>

## Function `borrow_warehouse_mut`

Mutably borrows <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> as <code>Warehouse</code>


<a name="@Panics_14"></a>

###### Panics


Panics if no <code>Warehouse</code>


<pre><code><b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse_mut">borrow_warehouse_mut</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;): &<b>mut</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_borrow_warehouse_mut">borrow_warehouse_mut</a>&lt;T: key + store&gt;(
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;,
): &<b>mut</b> Warehouse&lt;T&gt; {
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_assert_warehouse">assert_warehouse</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    df::borrow_mut(&<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>.id, <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_WarehouseKey">WarehouseKey</a> {})
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_assert_warehouse"></a>

## Function `assert_warehouse`

Asserts that <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> is a <code>Warehouse</code>


<a name="@Panics_15"></a>

###### Panics


Panics if <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a></code> is not a <code>Warehouse</code>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_assert_warehouse">assert_warehouse</a>&lt;T: store, key&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_assert_warehouse">assert_warehouse</a>&lt;T: key + store&gt;(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: &<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">Inventory</a>&lt;T&gt;) {
    <b>assert</b>!(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_is_warehouse">is_warehouse</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>), <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_ENotWarehouse">ENotWarehouse</a>);
}
</code></pre>



</details>
