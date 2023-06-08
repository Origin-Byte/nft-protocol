
<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds"></a>

# Module `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::proceeds`

Module performing custody of the funds acquired from the sale proceeds of
an NFT <code>Listing</code>. In addition, <code><a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">Proceeds</a></code> also performs the bookeeping
of the sales, in quantities and <FT>-amount.

The process of retrieving the funds from the  <code><a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">Proceeds</a></code> object embedded in
a <code>Listing</code> guarantees that fees are transferred to the <code><a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>.receiver</code>
and therefore the <code>Listing.receiver</code> receives the proceeds net of fees.


-  [Resource `Proceeds`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds)
-  [Struct `QtSold`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_QtSold)
-  [Function `empty`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_empty)
-  [Function `add`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_add)
-  [Function `collect_with_fees`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_collect_with_fees)
-  [Function `collect_without_fees`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_collect_without_fees)
-  [Function `collected`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_collected)
-  [Function `total`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_total)
-  [Function `balance`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_balance)
-  [Function `balance_mut`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_balance_mut)


<pre><code><b>use</b> <a href="">0x1::type_name</a>;
<b>use</b> <a href="">0x2::balance</a>;
<b>use</b> <a href="">0x2::coin</a>;
<b>use</b> <a href="">0x2::dynamic_field</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds"></a>

## Resource `Proceeds`



<pre><code><b>struct</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">Proceeds</a> <b>has</b> store, key
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
<code>qt_sold: <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_QtSold">proceeds::QtSold</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_QtSold"></a>

## Struct `QtSold`



<pre><code><b>struct</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_QtSold">QtSold</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>collected: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>total: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_empty"></a>

## Function `empty`



<pre><code><b>public</b> <b>fun</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_empty">empty</a>(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">proceeds::Proceeds</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_empty">empty</a>(
    ctx: &<b>mut</b> TxContext,
): <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">Proceeds</a> {
    <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">Proceeds</a> {
        id: <a href="_new">object::new</a>(ctx),
        qt_sold: <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_QtSold">QtSold</a> {collected: 0, total: 0},
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_add"></a>

## Function `add`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_add">add</a>&lt;FT&gt;(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: &<b>mut</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">proceeds::Proceeds</a>, new_proceeds: <a href="_Balance">balance::Balance</a>&lt;FT&gt;, qty_sold: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_add">add</a>&lt;FT&gt;(
    <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: &<b>mut</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">Proceeds</a>,
    new_proceeds: Balance&lt;FT&gt;,
    qty_sold: u64,
) {
    <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>.qt_sold.total = <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>.qt_sold.total + qty_sold;

    <b>let</b> marker = <a href="_get">type_name::get</a>&lt;FT&gt;();
    <b>let</b> missing_df = !df::exists_with_type&lt;TypeName, Balance&lt;FT&gt;&gt;(
        &<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>.id, marker
    );

    <b>if</b> (missing_df) {
        df::add&lt;TypeName, Balance&lt;FT&gt;&gt;(
            &<b>mut</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>.id,
            marker,
            new_proceeds,
        )
    } <b>else</b> {
        <b>let</b> <a href="">balance</a> = <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_balance_mut">balance_mut</a>&lt;FT&gt;(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>);

        <a href="_join">balance::join</a>(
            <a href="">balance</a>,
            new_proceeds
        );
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_collect_with_fees"></a>

## Function `collect_with_fees`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_collect_with_fees">collect_with_fees</a>&lt;FT&gt;(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: &<b>mut</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">proceeds::Proceeds</a>, fees: u64, marketplace_receiver: <b>address</b>, listing_receiver: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_collect_with_fees">collect_with_fees</a>&lt;FT&gt;(
    <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: &<b>mut</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">Proceeds</a>,
    fees: u64,
    marketplace_receiver: <b>address</b>,
    listing_receiver: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <a href="">balance</a> = <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_balance_mut">balance_mut</a>&lt;FT&gt;(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>);
    <b>let</b> fee_balance = <a href="_split">balance::split</a>&lt;FT&gt;(
        <a href="">balance</a>,
        fees,
    );

    <b>let</b> fee = <a href="_from_balance">coin::from_balance</a>(fee_balance, ctx);

    <a href="_public_transfer">transfer::public_transfer</a>(
        fee,
        marketplace_receiver,
    );

    <b>let</b> balance_value = <a href="_value">balance::value</a>(<a href="">balance</a>);

    // Take the whole <a href="">balance</a>
    <b>let</b> proceeds_balance = <a href="_split">balance::split</a>&lt;FT&gt;(
        <a href="">balance</a>,
        balance_value,
    );

    <b>let</b> proceeds_coin = <a href="_from_balance">coin::from_balance</a>(proceeds_balance, ctx);

    <a href="_public_transfer">transfer::public_transfer</a>(
        proceeds_coin,
        listing_receiver,
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_collect_without_fees"></a>

## Function `collect_without_fees`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_collect_without_fees">collect_without_fees</a>&lt;FT&gt;(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: &<b>mut</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">proceeds::Proceeds</a>, listing_receiver: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_collect_without_fees">collect_without_fees</a>&lt;FT&gt;(
    <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: &<b>mut</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">Proceeds</a>,
    listing_receiver: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <a href="">balance</a> = <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_balance_mut">balance_mut</a>&lt;FT&gt;(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>);
    <b>let</b> balance_value = <a href="_value">balance::value</a>(<a href="">balance</a>);

    // Take the whole <a href="">balance</a>
    <b>let</b> proceeds_balance = <a href="_split">balance::split</a>&lt;FT&gt;(
        <a href="">balance</a>,
        balance_value,
    );

    <b>let</b> proceeds_coin = <a href="_from_balance">coin::from_balance</a>(proceeds_balance, ctx);

    <a href="_public_transfer">transfer::public_transfer</a>(
        proceeds_coin,
        listing_receiver,
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_collected"></a>

## Function `collected`



<pre><code><b>public</b> <b>fun</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_collected">collected</a>(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: &<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">proceeds::Proceeds</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_collected">collected</a>(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: &<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">Proceeds</a>): u64 {
    <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>.qt_sold.collected
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_total"></a>

## Function `total`



<pre><code><b>public</b> <b>fun</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_total">total</a>(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: &<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">proceeds::Proceeds</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_total">total</a>(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: &<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">Proceeds</a>): u64 {
    <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>.qt_sold.total
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_balance"></a>

## Function `balance`



<pre><code><b>public</b> <b>fun</b> <a href="">balance</a>&lt;FT&gt;(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: &<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">proceeds::Proceeds</a>): &<a href="_Balance">balance::Balance</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="">balance</a>&lt;FT&gt;(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: &<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">Proceeds</a>): &Balance&lt;FT&gt; {
    df::borrow(
        &<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>.id,
        <a href="_get">type_name::get</a>&lt;FT&gt;(),
    )
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_balance_mut"></a>

## Function `balance_mut`



<pre><code><b>fun</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_balance_mut">balance_mut</a>&lt;FT&gt;(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: &<b>mut</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">proceeds::Proceeds</a>): &<b>mut</b> <a href="_Balance">balance::Balance</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_balance_mut">balance_mut</a>&lt;FT&gt;(
    <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: &<b>mut</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">Proceeds</a>,
): &<b>mut</b> Balance&lt;FT&gt; {
    df::borrow_mut(
        &<b>mut</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>.id,
        <a href="_get">type_name::get</a>&lt;FT&gt;(),
    )
}
</code></pre>



</details>
