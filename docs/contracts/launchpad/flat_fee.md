
<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee"></a>

# Module `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::flat_fee`

A module responsible for the calculation and distribution
of Launchpad proceeds and fees.


-  [Resource `FlatFee`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_FlatFee)
-  [Constants](#@Constants_0)
-  [Function `new`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_new)
-  [Function `init_fee`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_init_fee)
-  [Function `collect_proceeds_and_fees`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_collect_proceeds_and_fees)
-  [Function `calc_fee`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_calc_fee)


<pre><code><b>use</b> <a href="">0x2::balance</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::math</a>;
<b>use</b> <a href="">0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils</a>;
<b>use</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing</a>;
<b>use</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::marketplace</a>;
<b>use</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::proceeds</a>;
<b>use</b> <a href="">0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::object_box</a>;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_FlatFee"></a>

## Resource `FlatFee`



<pre><code><b>struct</b> <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_FlatFee">FlatFee</a> <b>has</b> store, key
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
<code>rate_bps: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_EInvalidFeePolicy"></a>

<code>Listing</code> did not have <code><a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_FlatFee">FlatFee</a></code> policy


<pre><code><b>const</b> <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_EInvalidFeePolicy">EInvalidFeePolicy</a>: u64 = 1;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_new"></a>

## Function `new`



<pre><code><b>public</b> <b>fun</b> <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_new">new</a>(rate_bps: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_FlatFee">flat_fee::FlatFee</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_new">new</a>(rate_bps: u64, ctx: &<b>mut</b> TxContext): <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_FlatFee">FlatFee</a> {
    <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_FlatFee">FlatFee</a> {
        id: <a href="_new">object::new</a>(ctx),
        rate_bps,
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_init_fee"></a>

## Function `init_fee`



<pre><code><b>public</b> entry <b>fun</b> <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_init_fee">init_fee</a>(rate: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_init_fee">init_fee</a>(
    rate: u64,
    ctx: &<b>mut</b> TxContext,
) {
    public_transfer(<a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_new">new</a>(rate, ctx), <a href="_sender">tx_context::sender</a>(ctx));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_collect_proceeds_and_fees"></a>

## Function `collect_proceeds_and_fees`

Collect proceeds and fees

Requires that caller is listing admin in order to protect against
rugpulls.


<a name="@Panics_1"></a>

###### Panics


Panics if <code>Listing</code> was not attached to the <code>Marketplace</code> or
<code>Marketplace</code> did not define a flat fee.


<pre><code><b>public</b> entry <b>fun</b> <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_collect_proceeds_and_fees">collect_proceeds_and_fees</a>&lt;FT&gt;(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_collect_proceeds_and_fees">collect_proceeds_and_fees</a>&lt;FT&gt;(
    <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &Marketplace,
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> Listing,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_marketplace_match">listing::assert_listing_marketplace_match</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_correct_admin">listing::assert_correct_admin</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);

    <b>let</b> (proceeds_value, listing_receiver) = {
        <b>let</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_proceeds">listing::borrow_proceeds</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
        <b>let</b> listing_receiver = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_receiver">listing::receiver</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
        <b>let</b> proceeds_value = <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_balance">proceeds::balance</a>&lt;FT&gt;(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>);
        (proceeds_value, listing_receiver)
    };

    <b>let</b> fee_policy = <b>if</b> (<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_custom_fee">listing::contains_custom_fee</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>)) {
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_custom_fee">listing::custom_fee</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>)
    } <b>else</b> {
        mkt::default_fee(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>)
    };

    <b>assert</b>!(
        <a href="_has_object">object_box::has_object</a>&lt;<a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_FlatFee">FlatFee</a>&gt;(fee_policy),
        <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_EInvalidFeePolicy">EInvalidFeePolicy</a>,
    );

    <b>let</b> policy = <a href="_borrow">object_box::borrow</a>&lt;<a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_FlatFee">FlatFee</a>&gt;(fee_policy);

    <b>let</b> fee = <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_calc_fee">calc_fee</a>(<a href="_value">balance::value</a>(proceeds_value), policy.rate_bps);

    <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_collect_with_fees">proceeds::collect_with_fees</a>&lt;FT&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_proceeds_mut">listing::borrow_proceeds_mut</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>),
        fee,
        mkt::receiver(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>),
        listing_receiver,
        ctx,
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_calc_fee"></a>

## Function `calc_fee`



<pre><code><b>fun</b> <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_calc_fee">calc_fee</a>(proceeds_value: u64, rate_bps: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="flat_fee.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_flat_fee_calc_fee">calc_fee</a>(proceeds_value: u64, rate_bps: u64): u64 {
    <b>let</b> (_, div) = <a href="_div_round">math::div_round</a>(rate_bps, (<a href="_bps">utils::bps</a>() <b>as</b> u64));
    <b>let</b> (_, result) = <a href="_mul_round">math::mul_round</a>(div, proceeds_value);
    result
}
</code></pre>



</details>
