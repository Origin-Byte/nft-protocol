
<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request"></a>

# Module `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request`

The rolling hot potato pattern was designed by us in conjunction with
Mysten team.

For compatability with the Sui TransferPolicy module, the OriginByte
transfer request use the <code>sui::transfer_policy::TransferRequest</code> instead of
the native OriginByte request module.

To lower the barrier to entry, we mimic the API defined in the Sui Framework
where relevant.
See the <code>sui::transfer_policy</code> module in the https://github.com/MystenLabs/sui
We interoperate with the sui ecosystem by allowing our <code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a></code> to
be converted into the sui version.
This is only possible for the cases where the payment is done in SUI token.

Our transfer request offers generics over fungible token.
We are no longer limited to SUI token.
Royalty policies can decide whether they charge a fee in other tokens.

Our transfer request associates paid balance with the request.
This enables us to do permissionless transfers of NFTs.
That's because we store the beneficiary address (e.g. NFT seller) with the
paid balance.
Then when confirming a transfer, we transfer this balance to the seller.
With special capability, the policies which act as a middleware can access
the balance and charge royalty from it.
Therefore, a 3rd party to a trade can send a tx to finish it.
This is helpful for reducing # of txs users have to send for trading
logic which requires multiple steps.
With our protocol, automation can be set up by marketplaces.


<a name="@_0"></a>

#####

To be able to authorize transfers, create a policy with
<code>nft_protocol::transfer_request::init_policy</code>.
This creates a new transfer request policy to which rules can be attached.
Some common rules:
* <code>nft_protocol::allowlist::enforce</code>
* <code>nft_protocol::royalty_strategy_bps::enforce</code>


-  [Struct `Witness`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_Witness)
-  [Struct `TransferRequest`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest)
-  [Struct `BalanceAccessCap`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceAccessCap)
-  [Struct `BalanceDfKey`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceDfKey)
-  [Struct `OBCustomRulesDfKey`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_OBCustomRulesDfKey)
-  [Constants](#@Constants_1)
-  [Function `new`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_new)
-  [Function `set_paid`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_set_paid)
-  [Function `set_nothing_paid`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_set_nothing_paid)
-  [Function `inner_mut`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_inner_mut)
-  [Function `inner`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_inner)
-  [Function `add_receipt`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_add_receipt)
-  [Function `metadata_mut`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_metadata_mut)
-  [Function `metadata`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_metadata)
-  [Function `from_sui`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_from_sui)
-  [Function `into_sui`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_into_sui)
-  [Function `init_policy`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_init_policy)
-  [Function `add_originbyte_rule`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_add_originbyte_rule)
-  [Function `remove_originbyte_rule`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_remove_originbyte_rule)
-  [Function `grant_balance_access_cap`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_grant_balance_access_cap)
-  [Function `confirm`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_confirm)
-  [Function `distribute_balance_to_beneficiary`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_distribute_balance_to_beneficiary)
-  [Function `paid_in_ft_mut`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_ft_mut)
-  [Function `paid_in_sui_mut`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_sui_mut)
-  [Function `paid_in_ft`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_ft)
-  [Function `paid_in_sui`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_sui)
-  [Function `is_originbyte`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_is_originbyte)
-  [Function `originator`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_originator)
-  [Function `nft`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_nft)
-  [Function `balance_mut_`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_balance_mut_)
-  [Function `balance_`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_balance_)


<pre><code><b>use</b> <a href="">0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::witness</a>;
<b>use</b> <a href="">0x2::balance</a>;
<b>use</b> <a href="">0x2::coin</a>;
<b>use</b> <a href="">0x2::dynamic_field</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::package</a>;
<b>use</b> <a href="">0x2::sui</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::transfer_policy</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_Witness"></a>

## Struct `Witness`



<pre><code><b>struct</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_Witness">Witness</a> <b>has</b> drop
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

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest"></a>

## Struct `TransferRequest`

A "Hot Potato" forcing the buyer to get a transfer permission
from the item type (<code>T</code>) owner on purchase attempt.

We create some helper methods for SUI token, but also support any
fungible token.

See the module docs for a comparison between this and <code>SuiTransferRequest</code>.


<pre><code><b>struct</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>nft: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>originator: <b>address</b></code>
</dt>
<dd>
 For entities which authorize with <code>ID</code>, we convert the <code>ID</code> to
 address.
</dd>
<dt>
<code>beneficiary: <b>address</b></code>
</dt>
<dd>
 Who's to receive the payment which we wrap as dyn field in metadata.
</dd>
<dt>
<code>inner: <a href="_TransferRequest">transfer_policy::TransferRequest</a>&lt;T&gt;</code>
</dt>
<dd>
 Helper for checking that transfer rules have been followed.
 This inner type is what interoperates with the policy.
 The type <code>Policy&lt;WithNft&lt;T, OB_TRANSFER_REQUEST&gt;&gt;</code>
 matches with this type of request.
</dd>
<dt>
<code>metadata: <a href="_UID">object::UID</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceAccessCap"></a>

## Struct `BalanceAccessCap`

TLDR:
* + easier interface
* + pay royalties from what's been paid
* + permissionless trade resolution
* - less client control

Policies which own this capability get mutable access the balance of
<code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;</code>.

This is useful for policies which charge a fee from the payment.
E.g., the fee can be deducted from the balance and the rest transferred
to the beneficiary (NFT seller).
That's handy for orderbook trading - improves UX.
Otherwise, either the seller or the buyer would have to run
the trade resolution as another tx.

Note that thorough review of the policy code is required because it
gets access to all the funds used for trading.

We don't consider a malicious policy by the creator to be a security
risk because it is equivalent to charging a 100% royalty.
This isn't prevented in the standard Sui implementation either.
The best prevention is a client side condition which fails the trade
if royalty is too high.

Typically, this is optional because there's another way of paying
royalties in which the strategy doesn't have to touch the
balance.
It's useful to avoid this for careful clients which prefer to have
precise control over how much royalty is paid and fail if it's over a
certain amount.
Therefore, creators can avoid this field.


<pre><code><b>struct</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceAccessCap">BalanceAccessCap</a>&lt;T&gt; <b>has</b> drop, store
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

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceDfKey"></a>

## Struct `BalanceDfKey`

Stores balance on <code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a></code> as dynamic field in the metadata.


<pre><code><b>struct</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceDfKey">BalanceDfKey</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_OBCustomRulesDfKey"></a>

## Struct `OBCustomRulesDfKey`



<pre><code><b>struct</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_OBCustomRulesDfKey">OBCustomRulesDfKey</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="@Constants_1"></a>

## Constants


<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_EIllegalRule"></a>

A completed rule is not set in the <code>TransferPolicy</code>.


<pre><code><b>const</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_EIllegalRule">EIllegalRule</a>: u64 = 1;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_EPolicyNotSatisfied"></a>

The number of receipts does not match the <code>TransferPolicy</code> requirement.


<pre><code><b>const</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_EPolicyNotSatisfied">EPolicyNotSatisfied</a>: u64 = 3;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_ECannotConvertCustomPolicy"></a>

A custom policy action cannot be converted to from <code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a></code> to <code>SuiTransferRequest</code>


<pre><code><b>const</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_ECannotConvertCustomPolicy">ECannotConvertCustomPolicy</a>: u64 = 3;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_ENoRulesToRemove"></a>

Trying to remove rules that do not exist


<pre><code><b>const</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_ENoRulesToRemove">ENoRulesToRemove</a>: u64 = 3;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_EOnlyTransferRequestOfSuiToken"></a>

Conversion of our transfer request to the one exposed by the sui library
is only permitted for SUI token.


<pre><code><b>const</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_EOnlyTransferRequestOfSuiToken">EOnlyTransferRequestOfSuiToken</a>: u64 = 2;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_new"></a>

## Function `new`

Construct a new <code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a></code> hot potato which requires an
approving action from the creator to be destroyed / resolved.

<code>set_paid</code> MUST be called to set the paid amount.
Without calling <code>set_paid</code>, the tx will always abort.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_new">new</a>&lt;T&gt;(nft: <a href="_ID">object::ID</a>, originator: <b>address</b>, kiosk_id: <a href="_ID">object::ID</a>, price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_new">new</a>&lt;T&gt;(
    nft: ID, originator: <b>address</b>, kiosk_id: ID, price: u64, ctx: &<b>mut</b> TxContext,
): <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt; {
    <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a> {
        nft,
        originator,
        // is overwritten in `set_paid` <b>if</b> any <a href="">balance</a> is associated <b>with</b>
        beneficiary: @0x0,
        inner: <a href="_new_request">transfer_policy::new_request</a>(nft, price, kiosk_id),
        metadata: <a href="_new">object::new</a>(ctx),
    }
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_set_paid"></a>

## Function `set_paid`

Aborts unless called exactly once.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_set_paid">set_paid</a>&lt;T, FT&gt;(self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;, paid: <a href="_Balance">balance::Balance</a>&lt;FT&gt;, beneficiary: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_set_paid">set_paid</a>&lt;T, FT&gt;(
    self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;, paid: Balance&lt;FT&gt;, beneficiary: <b>address</b>,
) {
    self.beneficiary = beneficiary;
    df::add(<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_metadata_mut">metadata_mut</a>(self), <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceDfKey">BalanceDfKey</a> {}, paid);
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_set_nothing_paid"></a>

## Function `set_nothing_paid`

Sets empty SUI token balance.

Useful for apps which are not payment based.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_set_nothing_paid">set_nothing_paid</a>&lt;T&gt;(self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_set_nothing_paid">set_nothing_paid</a>&lt;T&gt;(self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;) {
    df::add(<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_metadata_mut">metadata_mut</a>(self), <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceDfKey">BalanceDfKey</a> {}, <a href="_zero">balance::zero</a>&lt;SUI&gt;());
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_inner_mut"></a>

## Function `inner_mut`

Gets mutable access to the inner type which is concerned with the
receipt resolution.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_inner_mut">inner_mut</a>&lt;T&gt;(self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;): &<b>mut</b> <a href="_TransferRequest">transfer_policy::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_inner_mut">inner_mut</a>&lt;T&gt;(
    self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;,
): &<b>mut</b> SuiTransferRequest&lt;T&gt; { &<b>mut</b> self.inner }
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_inner"></a>

## Function `inner`

Gets access to the inner type which is concerned with the
receipt resolution.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_inner">inner</a>&lt;T&gt;(self: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;): &<a href="_TransferRequest">transfer_policy::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_inner">inner</a>&lt;T&gt;(
    self: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;,
): &SuiTransferRequest&lt;T&gt; { &self.inner }
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_add_receipt"></a>

## Function `add_receipt`

Adds a <code>Receipt</code> to the <code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a></code>, unblocking the request and
confirming that the policy requirements are satisfied.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_add_receipt">add_receipt</a>&lt;T, Rule: drop&gt;(self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;, rule: Rule)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_add_receipt">add_receipt</a>&lt;T, Rule: drop&gt;(self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;, rule: Rule) {
    <a href="_add_receipt">transfer_policy::add_receipt</a>(rule, &<b>mut</b> self.inner);
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_metadata_mut"></a>

## Function `metadata_mut`

Anyone can attach any metadata (dynamic fields).
The UID is eventually dropped when the <code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a></code> is destroyed.

There are some standard metadata are
* <code>ob_kiosk::set_transfer_request_auth</code>
* <code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_set_paid">transfer_request::set_paid</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_metadata_mut">metadata_mut</a>&lt;T&gt;(self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;): &<b>mut</b> <a href="_UID">object::UID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_metadata_mut">metadata_mut</a>&lt;T&gt;(self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;): &<b>mut</b> UID { &<b>mut</b> self.metadata }
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_metadata"></a>

## Function `metadata`



<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_metadata">metadata</a>&lt;T&gt;(self: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;): &<a href="_UID">object::UID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_metadata">metadata</a>&lt;T&gt;(self: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;): &UID { &self.metadata }
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_from_sui"></a>

## Function `from_sui`



<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_from_sui">from_sui</a>&lt;T&gt;(inner: <a href="_TransferRequest">transfer_policy::TransferRequest</a>&lt;T&gt;, nft: <a href="_ID">object::ID</a>, originator: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_from_sui">from_sui</a>&lt;T&gt;(
    inner: SuiTransferRequest&lt;T&gt;, nft: ID, originator: <b>address</b>, ctx: &<b>mut</b> TxContext,
): <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt; {
    <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a> {
        nft,
        originator,
        // is overwritten in `set_paid` <b>if</b> any <a href="">balance</a> is associated <b>with</b>
        beneficiary: @0x0,
        inner,
        metadata: <a href="_new">object::new</a>(ctx),
    }
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_into_sui"></a>

## Function `into_sui`

The transfer request can be converted to the sui lib version if the
payment was done in SUI and there's no other currency used.

Note that after this, the royalty enforcement is modelled after the
sui ecosystem settings.
This means that the rules for closing the <code>SuiTransferRequest</code> must
be met according to <code>sui::transfer_policy::confirm_request</code>.

The creator has to opt into that (Sui) ecosystem.
All the receipts are reset and must be collected anew.
Therefore, it really makes sense to call this function immediately
after one got the <code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_into_sui">into_sui</a>&lt;T&gt;(self: <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;, policy: &<a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_TransferRequest">transfer_policy::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_into_sui">into_sui</a>&lt;T&gt;(
    self: <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;, policy: &TransferPolicy&lt;T&gt;, ctx: &<b>mut</b> TxContext,
): SuiTransferRequest&lt;T&gt; {
    // Assert no custom rules
    <b>assert</b>!(
        !df::exists_(<a href="_uid">transfer_policy::uid</a>(policy), <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_OBCustomRulesDfKey">OBCustomRulesDfKey</a> {}),
        <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_ECannotConvertCustomPolicy">ECannotConvertCustomPolicy</a>
    );
    // the <a href="">sui</a> <a href="">transfer</a> policy doesn't support our <a href="">balance</a> association
    // and therefore just send the <a href="">coin</a> <b>to</b> the beneficiary directly
    <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_distribute_balance_to_beneficiary">distribute_balance_to_beneficiary</a>&lt;T, SUI&gt;(&<b>mut</b> self, ctx);

    <b>let</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a> {
        nft: _,
        originator: _,
        inner,
        beneficiary: _,
        metadata,
    } = self;
    <a href="_delete">object::delete</a>(metadata);

    inner
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_init_policy"></a>

## Function `init_policy`

Creates a new transfer policy for type <code>T</code>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_init_policy">init_policy</a>&lt;T&gt;(publisher: &<a href="_Publisher">package::Publisher</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (<a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;, <a href="_TransferPolicyCap">transfer_policy::TransferPolicyCap</a>&lt;T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_init_policy">init_policy</a>&lt;T&gt;(
    publisher: &Publisher, ctx: &<b>mut</b> TxContext,
): (TransferPolicy&lt;T&gt;, TransferPolicyCap&lt;T&gt;) {
    // Asserts Publisher in `new`
    <b>let</b> (policy, cap) = <a href="_new">transfer_policy::new</a>(publisher, ctx);

    // Register policy in the OriginByte ecosystem
    <b>let</b> ext = <a href="_uid_mut_as_owner">transfer_policy::uid_mut_as_owner</a>(&<b>mut</b> policy, &cap);
    df::add(ext, <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_OBCustomRulesDfKey">OBCustomRulesDfKey</a> {}, 0_u8);

    (policy, cap)
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_add_originbyte_rule"></a>

## Function `add_originbyte_rule`

We extend the functionality of <code>TransferPolicy</code> by inserting our
Originbyte <code>VecSet&lt;TypeName&gt;</code> into it.
These rules work with our custom <code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_add_originbyte_rule">add_originbyte_rule</a>&lt;T, Rule: drop, Config: drop, store&gt;(rule: Rule, self: &<b>mut</b> <a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;, cap: &<a href="_TransferPolicyCap">transfer_policy::TransferPolicyCap</a>&lt;T&gt;, cfg: Config)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_add_originbyte_rule">add_originbyte_rule</a>&lt;T, Rule: drop, Config: store + drop&gt;(
    rule: Rule, self: &<b>mut</b> TransferPolicy&lt;T&gt;, cap: &TransferPolicyCap&lt;T&gt;, cfg: Config
) {
    <b>let</b> ext = <a href="_uid_mut_as_owner">transfer_policy::uid_mut_as_owner</a>(self, cap);

    // We bump a counter each time we add and remove an OriginByte Rule
    <b>if</b> (!df::exists_(ext, <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_OBCustomRulesDfKey">OBCustomRulesDfKey</a> {})) {
        df::add(ext, <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_OBCustomRulesDfKey">OBCustomRulesDfKey</a> {}, 1_u8);
    } <b>else</b> {
        <b>let</b> ob_rules = df::borrow_mut&lt;<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_OBCustomRulesDfKey">OBCustomRulesDfKey</a>, u8&gt;(ext, <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_OBCustomRulesDfKey">OBCustomRulesDfKey</a> {});
        *ob_rules = *ob_rules + 1;
    };

    <a href="_add_rule">transfer_policy::add_rule</a>(rule, self, cap, cfg);
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_remove_originbyte_rule"></a>

## Function `remove_originbyte_rule`

Allows us to modify the rules.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_remove_originbyte_rule">remove_originbyte_rule</a>&lt;T, Rule: drop, Config: drop, store&gt;(self: &<b>mut</b> <a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;, cap: &<a href="_TransferPolicyCap">transfer_policy::TransferPolicyCap</a>&lt;T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_remove_originbyte_rule">remove_originbyte_rule</a>&lt;T, Rule: drop, Config: store + drop&gt;(
    self: &<b>mut</b> TransferPolicy&lt;T&gt;, cap: &TransferPolicyCap&lt;T&gt;,
) {
    <b>let</b> ext = <a href="_uid_mut_as_owner">transfer_policy::uid_mut_as_owner</a>(self, cap);
    <b>let</b> ob_rules = df::borrow_mut&lt;<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_OBCustomRulesDfKey">OBCustomRulesDfKey</a>, u8&gt;(ext, <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_OBCustomRulesDfKey">OBCustomRulesDfKey</a> {});

    <b>assert</b>!(*ob_rules &gt;= 1 , <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_ENoRulesToRemove">ENoRulesToRemove</a>);

    *ob_rules = *ob_rules - 1;
    <a href="_remove_rule">transfer_policy::remove_rule</a>&lt;T, Rule, Config&gt;(self, cap);
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_grant_balance_access_cap"></a>

## Function `grant_balance_access_cap`

Creates a new capability which enables the holder to get <code>&<b>mut</b></code> access
to a balance paid for an NFT.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_grant_balance_access_cap">grant_balance_access_cap</a>&lt;T&gt;(_witness: <a href="_Witness">witness::Witness</a>&lt;T&gt;): <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceAccessCap">transfer_request::BalanceAccessCap</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_grant_balance_access_cap">grant_balance_access_cap</a>&lt;T&gt;(
    _witness: DelegatedWitness&lt;T&gt;,
): <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceAccessCap">BalanceAccessCap</a>&lt;T&gt; { <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceAccessCap">BalanceAccessCap</a> {} }
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_confirm"></a>

## Function `confirm`

Allow a <code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a></code> for the type <code>T</code>.
The call is protected by the type constraint, as only the publisher of
the <code>T</code> can get <code>TransferPolicy&lt;T&gt;</code>.

Note: unless there's a policy for <code>T</code> to allow transfers,
Kiosk trades will not be possible.
If there is no transfer policy in the OB ecosystem, try using
<code>into_sui</code> to convert the <code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a></code> to the SUI ecosystem.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_confirm">confirm</a>&lt;T, FT&gt;(self: <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;, policy: &<a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_confirm">confirm</a>&lt;T, FT&gt;(
    self: <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;,
    policy: &TransferPolicy&lt;T&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_distribute_balance_to_beneficiary">distribute_balance_to_beneficiary</a>&lt;T, FT&gt;(&<b>mut</b> self, ctx);
    <b>let</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a> {
        nft: _,
        originator: _,
        beneficiary: _,
        inner,
        metadata,
    } = self;
    <a href="_delete">object::delete</a>(metadata);

    <a href="_confirm_request">transfer_policy::confirm_request</a>(policy, inner);
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_distribute_balance_to_beneficiary"></a>

## Function `distribute_balance_to_beneficiary`

Takes out the funds from the transfer request and sends them to the
originator.
This is useful if permissionless trade resolution is not necessary
and the royalties can be deducted from a specific <code>Balance</code> rather than
using <code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceAccessCap">BalanceAccessCap</a></code>.

Is idempotent.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_distribute_balance_to_beneficiary">distribute_balance_to_beneficiary</a>&lt;T, FT&gt;(self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_distribute_balance_to_beneficiary">distribute_balance_to_beneficiary</a>&lt;T, FT&gt;(
    self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;, ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> metadata = <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_metadata_mut">metadata_mut</a>(self);
    <b>if</b> (!df::exists_(metadata, <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceDfKey">BalanceDfKey</a> {})) {
        <b>return</b>
    };

    <b>let</b> <a href="">balance</a>: Balance&lt;FT&gt; = df::remove(metadata, <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceDfKey">BalanceDfKey</a> {});
    <b>if</b> (<a href="_value">balance::value</a>(&<a href="">balance</a>) &gt; 0) {
        public_transfer(<a href="_from_balance">coin::from_balance</a>(<a href="">balance</a>, ctx), self.beneficiary);
    } <b>else</b> {
        <a href="_destroy_zero">balance::destroy_zero</a>(<a href="">balance</a>);
    };
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_ft_mut"></a>

## Function `paid_in_ft_mut`



<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_ft_mut">paid_in_ft_mut</a>&lt;T, FT&gt;(self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;, _cap: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceAccessCap">transfer_request::BalanceAccessCap</a>&lt;T&gt;): (&<b>mut</b> <a href="_Balance">balance::Balance</a>&lt;FT&gt;, <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_ft_mut">paid_in_ft_mut</a>&lt;T, FT&gt;(
    self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;, _cap: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceAccessCap">BalanceAccessCap</a>&lt;T&gt;,
): (&<b>mut</b> Balance&lt;FT&gt;, <b>address</b>) {
    <b>let</b> beneficiary = self.beneficiary;
    (<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_balance_mut_">balance_mut_</a>(self), beneficiary)
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_sui_mut"></a>

## Function `paid_in_sui_mut`



<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_sui_mut">paid_in_sui_mut</a>&lt;T&gt;(self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;, _cap: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceAccessCap">transfer_request::BalanceAccessCap</a>&lt;T&gt;): (&<b>mut</b> <a href="_Balance">balance::Balance</a>&lt;<a href="_SUI">sui::SUI</a>&gt;, <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_sui_mut">paid_in_sui_mut</a>&lt;T&gt;(
    self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;, _cap: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceAccessCap">BalanceAccessCap</a>&lt;T&gt;,
): (&<b>mut</b> Balance&lt;SUI&gt;, <b>address</b>) {
    <b>let</b> beneficiary = self.beneficiary;
    (<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_balance_mut_">balance_mut_</a>(self), beneficiary)
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_ft"></a>

## Function `paid_in_ft`

Returns the amount and beneficiary.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_ft">paid_in_ft</a>&lt;T, FT&gt;(self: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;): (u64, <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_ft">paid_in_ft</a>&lt;T, FT&gt;(self: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;): (u64, <b>address</b>) {
    <b>let</b> beneficiary = self.beneficiary;
    (<a href="_value">balance::value</a>&lt;FT&gt;(<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_balance_">balance_</a>(self)), beneficiary)
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_sui"></a>

## Function `paid_in_sui`

Panics if the <code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a></code> is not for SUI token.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_sui">paid_in_sui</a>&lt;T&gt;(self: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;): (u64, <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_sui">paid_in_sui</a>&lt;T&gt;(self: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;): (u64, <b>address</b>) {
    <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_paid_in_ft">paid_in_ft</a>&lt;T, SUI&gt;(self)
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_is_originbyte"></a>

## Function `is_originbyte`



<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_is_originbyte">is_originbyte</a>&lt;T&gt;(self: &<a href="_TransferPolicy">transfer_policy::TransferPolicy</a>&lt;T&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_is_originbyte">is_originbyte</a>&lt;T&gt;(self: &TransferPolicy&lt;T&gt;): bool {
    <b>let</b> ext = <a href="_uid">transfer_policy::uid</a>(self);

    df::exists_(ext, <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_OBCustomRulesDfKey">OBCustomRulesDfKey</a> {})
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_originator"></a>

## Function `originator`

Which entity started the trade.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_originator">originator</a>&lt;T&gt;(self: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_originator">originator</a>&lt;T&gt;(self: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;): <b>address</b> { self.originator }
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_nft"></a>

## Function `nft`

What's the NFT that's being transferred.


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_nft">nft</a>&lt;T&gt;(self: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_nft">nft</a>&lt;T&gt;(self: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;): ID { self.nft }
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_balance_mut_"></a>

## Function `balance_mut_`



<pre><code><b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_balance_mut_">balance_mut_</a>&lt;T, FT&gt;(self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;): &<b>mut</b> <a href="_Balance">balance::Balance</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_balance_mut_">balance_mut_</a>&lt;T, FT&gt;(self: &<b>mut</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;): &<b>mut</b> Balance&lt;FT&gt; {
    df::borrow_mut(&<b>mut</b> self.metadata, <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceDfKey">BalanceDfKey</a> {})
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_balance_"></a>

## Function `balance_`



<pre><code><b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_balance_">balance_</a>&lt;T, FT&gt;(self: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;): &<a href="_Balance">balance::Balance</a>&lt;FT&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_balance_">balance_</a>&lt;T, FT&gt;(self: &<a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">TransferRequest</a>&lt;T&gt;): &Balance&lt;FT&gt; {
    df::borrow(&self.metadata, <a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_BalanceDfKey">BalanceDfKey</a> {})
}
</code></pre>



</details>
