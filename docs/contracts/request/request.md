
<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request"></a>

# Module `0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request`

The rolling hot potato pattern was designed by OriginByte in conjunction with
Mysten Labs, and it is here implemented as a generic way of validating that
a set of actions has been taken. Since hot potatoes need to be consumed at the end
of the Programmable Transactions Batch, smart contract developers can force clients
to perform a particular set of actions given a genesis action.

This pattern is at the heart of the NFT Protocol and more specifically at the
heart of the access control around NFTs that live in the OB Kiosk. Nevertheless,
this implementation is generic enough that it can be used in any other contexts,
that do not involve NFTs.

This module consists of three core objects:
- <code><a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;</code> is the object that registers the rules enforced for the policy <code>P</code>,
as well configuration state associated to each rule;
- <code><a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">PolicyCap</a></code> is a capability object that gives managerial access for a given
policy object
- <code><a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a>&lt;P&gt;</code> is the inner body of a hot-potato object that contains the
receipts collected by performing the enforced actions, as well as the metata associated
to them as well as the policy resolution logic. <code><a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a>&lt;P&gt;</code> is meant to be wrapped
by a hot-potato object, but is itself a hot-potato.

Instances of this patter are for example:
- <code>Request&lt;<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft">WithNft</a>&lt;T&gt;, WITHDRAW_REQ&gt;</code> which is responsible for checking that
an NFT withdrawal can be performed.
- <code>Request&lt;<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft">WithNft</a>&lt;T&gt;, BORROW_REQ&gt;</code> which is responsible for checking that
an NFT flash-borrow can be performed.

It's heavily integrated with <code>nft_protocol::ob_kiosk</code>, in particular via
the withdraw and borrow policy. For compatability with the Sui TransferPolicy,
the transfer request uses instead the native <code>sui::transfer_policy::TransferRequest</code>.


-  [Struct `WithNft`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft)
-  [Struct `RequestBody`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody)
-  [Resource `Policy`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy)
-  [Resource `PolicyCap`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap)
-  [Struct `RuleStateDfKey`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RuleStateDfKey)
-  [Constants](#@Constants_0)
-  [Function `new`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new)
-  [Function `destroy`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_destroy)
-  [Function `metadata_mut`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_metadata_mut)
-  [Function `metadata`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_metadata)
-  [Function `add_receipt`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_add_receipt)
-  [Function `confirm`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_confirm)
-  [Function `receipts`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_receipts)
-  [Function `new_policy`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new_policy)
-  [Function `new_policy_with_type`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new_policy_with_type)
-  [Function `enforce_rule`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_enforce_rule)
-  [Function `enforce_rule_no_state`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_enforce_rule_no_state)
-  [Function `drop_rule`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_drop_rule)
-  [Function `drop_rule_no_state`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_drop_rule_no_state)
-  [Function `rule_state`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_rule_state)
-  [Function `rule_state_mut`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_rule_state_mut)
-  [Function `rules`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_rules)
-  [Function `policy_cap_for`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_policy_cap_for)
-  [Function `policy_metadata_mut`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_policy_metadata_mut)
-  [Function `policy_metadata`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_policy_metadata)
-  [Function `confirm_`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_confirm_)
-  [Function `assert_publisher`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_publisher)
-  [Function `assert_version`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_version)
-  [Function `migrate`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_migrate)
-  [Function `migrate_as_pub`](#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_migrate_as_pub)


<pre><code><b>use</b> <a href="">0x1::type_name</a>;
<b>use</b> <a href="">0x2::dynamic_field</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::package</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x2::vec_set</a>;
<b>use</b> <a href="init.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_ob_request">0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::ob_request</a>;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft"></a>

## Struct `WithNft`

<code>T</code> is a type this request is concerned with, e.g. NFT type.
<code>P</code> represents the policy type that can confirm this request body.

Used as <code><a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a>&lt;<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft">WithNft</a>&lt;T, P&gt;&gt;</code>


<pre><code><b>struct</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft">WithNft</a>&lt;T, P&gt;
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

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody"></a>

## Struct `RequestBody`

Collects receipts which are later checked in <code>confirm</code> function.

<code>P</code> represents the policy type that can confirm this request body.


<pre><code><b>struct</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a>&lt;P&gt;
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>receipts: <a href="_VecSet">vec_set::VecSet</a>&lt;<a href="_TypeName">type_name::TypeName</a>&gt;</code>
</dt>
<dd>
 Collected Receipts.

 Used to verify that all of the rules were followed and
 <code><a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a></code> can be confirmed.
</dd>
<dt>
<code>metadata: <a href="_UID">object::UID</a></code>
</dt>
<dd>
 Optional metadata can be attached to the request.
 The metadata are dropped at the destruction of the request.
 It doesn't have to be emptied out for this type to be destroyed.
</dd>
</dl>


</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy"></a>

## Resource `Policy`

Defines what receipts does the <code><a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a></code> have to have to be confirmed
and destroyed.

<code>P</code> represents the policy type that can confirm this request body.


<pre><code><b>struct</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt; <b>has</b> store, key
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
<code>rules: <a href="_VecSet">vec_set::VecSet</a>&lt;<a href="_TypeName">type_name::TypeName</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap"></a>

## Resource `PolicyCap`

Should be kept by the creator.
Allows adding and removing policy rules.


<pre><code><b>struct</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">PolicyCap</a> <b>has</b> store, key
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
<code>for: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RuleStateDfKey"></a>

## Struct `RuleStateDfKey`

We use this to store a state for a particular rule.


<pre><code><b>struct</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RuleStateDfKey">RuleStateDfKey</a>&lt;Rule&gt; <b>has</b> <b>copy</b>, drop, store
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


<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_EIllegalRule"></a>

A completed rule is not set in the list of required rules


<pre><code><b>const</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_EIllegalRule">EIllegalRule</a>: u64 = 2;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_EPolicyNotSatisfied"></a>

The number of receipts does not match the list of required rules


<pre><code><b>const</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_EPolicyNotSatisfied">EPolicyNotSatisfied</a>: u64 = 3;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_EInvalidPublisher"></a>

Package publisher mismatch


<pre><code><b>const</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_EInvalidPublisher">EInvalidPublisher</a>: u64 = 1;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_ENotAllowed"></a>

Wrong capability, cannot authorize action


<pre><code><b>const</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_ENotAllowed">ENotAllowed</a>: u64 = 4;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_ENotUpgraded"></a>



<pre><code><b>const</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_ENotUpgraded">ENotUpgraded</a>: u64 = 999;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_EWrongVersion"></a>



<pre><code><b>const</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_EWrongVersion">EWrongVersion</a>: u64 = 1000;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_VERSION"></a>



<pre><code><b>const</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_VERSION">VERSION</a>: u64 = 1;
</code></pre>



<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new"></a>

## Function `new`



<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new">new</a>&lt;P&gt;(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">request::RequestBody</a>&lt;P&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new">new</a>&lt;P&gt;(ctx: &<b>mut</b> TxContext): <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a>&lt;P&gt; {
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a> {
        metadata: <a href="_new">object::new</a>(ctx),
        receipts: <a href="_empty">vec_set::empty</a>(),
    }
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_destroy"></a>

## Function `destroy`

Anyone can destroy the hotpotato.
That's why it's customary to wrap it in a custom hotpotato type and
define under which conditions is it ok to destroy it _without_ rule
checks.
To destroy it _with_ rule checks, use <code>confirm</code> function.


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_destroy">destroy</a>&lt;P&gt;(self: <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">request::RequestBody</a>&lt;P&gt;): <a href="_VecSet">vec_set::VecSet</a>&lt;<a href="_TypeName">type_name::TypeName</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_destroy">destroy</a>&lt;P&gt;(self: <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a>&lt;P&gt;): VecSet&lt;TypeName&gt; {
    <b>let</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a> { metadata, receipts } = self;
    <a href="_delete">object::delete</a>(metadata);
    receipts
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_metadata_mut"></a>

## Function `metadata_mut`

Anyone can attach any metadata (dynamic fields).
The UID is eventually dropped when the <code><a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a></code> is destroyed.

Implementations are responsible for not leaving dangling data inside the
metadata.
If they do, the data will haunt the chain forever.


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_metadata_mut">metadata_mut</a>&lt;P&gt;(self: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">request::RequestBody</a>&lt;P&gt;): &<b>mut</b> <a href="_UID">object::UID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_metadata_mut">metadata_mut</a>&lt;P&gt;(self: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a>&lt;P&gt;): &<b>mut</b> UID { &<b>mut</b> self.metadata }
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_metadata"></a>

## Function `metadata`

Reads what metadata is already there.


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_metadata">metadata</a>&lt;P&gt;(self: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">request::RequestBody</a>&lt;P&gt;): &<a href="_UID">object::UID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_metadata">metadata</a>&lt;P&gt;(self: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a>&lt;P&gt;): &UID { &self.metadata }
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_add_receipt"></a>

## Function `add_receipt`

Adds a <code>Receipt</code> to the <code><a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a></code>, unblocking the request and
confirming that the policy RequestBodys are satisfied.


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_add_receipt">add_receipt</a>&lt;P, Rule&gt;(self: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">request::RequestBody</a>&lt;P&gt;, _rule: &Rule)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_add_receipt">add_receipt</a>&lt;P, Rule&gt;(self: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a>&lt;P&gt;, _rule: &Rule) {
    <a href="_insert">vec_set::insert</a>(&<b>mut</b> self.receipts, <a href="_get">type_name::get</a>&lt;Rule&gt;())
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_confirm"></a>

## Function `confirm`

Asserts all rules have been met.


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_confirm">confirm</a>&lt;P&gt;(self: <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">request::RequestBody</a>&lt;P&gt;, policy: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;P&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_confirm">confirm</a>&lt;P&gt;(self: <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a>&lt;P&gt;, policy: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;) {
    <b>let</b> receipts = <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_destroy">destroy</a>(self);
    <b>let</b> completed = <a href="_into_keys">vec_set::into_keys</a>(receipts);

    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_confirm_">confirm_</a>(completed, &policy.rules);
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_receipts"></a>

## Function `receipts`



<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_receipts">receipts</a>&lt;P&gt;(<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">request::RequestBody</a>&lt;P&gt;): &<a href="_VecSet">vec_set::VecSet</a>&lt;<a href="_TypeName">type_name::TypeName</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_receipts">receipts</a>&lt;P&gt;(<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RequestBody">RequestBody</a>&lt;P&gt;): &VecSet&lt;TypeName&gt; {
    &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request">request</a>.receipts
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new_policy"></a>

## Function `new_policy`

Creates a new policy object for for <code>P</code> and returns it along with a
cap object <code><a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">PolicyCap</a></code> which gives the holder managerial access over the
policy. This function is meant to be called by upstream modules.


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new_policy">new_policy</a>&lt;P: drop&gt;(_witness: P, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;P&gt;, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">request::PolicyCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new_policy">new_policy</a>&lt;P: drop&gt;(
    _witness: P,
    ctx: &<b>mut</b> TxContext,
): (<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">PolicyCap</a>) {
    <b>let</b> policy = <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a> {
        id: <a href="_new">object::new</a>(ctx),
        version: <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_VERSION">VERSION</a>,
        rules: <a href="_empty">vec_set::empty</a>(),
    };
    <b>let</b> cap = <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">PolicyCap</a> {
        id: <a href="_new">object::new</a>(ctx),
        for: <a href="_id">object::id</a>(&policy),
    };

    (policy, cap)
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new_policy_with_type"></a>

## Function `new_policy_with_type`

Useful for generic policies which can be defined per type.

For example, one might want to have a royalty policy which is defined
for a specific NFT type.
In such scheme, the NFT type would be <code>T</code>, and the royalty policy
would be <code>P</code>.
In fact, this is how <code><a href="transfer.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_transfer_request_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;</code> is
implemented.


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new_policy_with_type">new_policy_with_type</a>&lt;T, P: drop&gt;(_witness: P, publisher: &<a href="_Publisher">package::Publisher</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft">request::WithNft</a>&lt;T, P&gt;&gt;, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">request::PolicyCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_new_policy_with_type">new_policy_with_type</a>&lt;T, P: drop&gt;(
    _witness: P,
    publisher: &Publisher,
    ctx: &<b>mut</b> TxContext,
): (<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_WithNft">WithNft</a>&lt;T, P&gt;&gt;, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">PolicyCap</a>) {
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_publisher">assert_publisher</a>&lt;T&gt;(publisher);

    <b>let</b> policy = <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a> {
        id: <a href="_new">object::new</a>(ctx),
        version: <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_VERSION">VERSION</a>,
        rules: <a href="_empty">vec_set::empty</a>(),
    };
    <b>let</b> cap = <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">PolicyCap</a> {
        id: <a href="_new">object::new</a>(ctx),
        for: <a href="_id">object::id</a>(&policy),
    };

    (policy, cap)
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_enforce_rule"></a>

## Function `enforce_rule`

Registers rule in the Policy object and adds
config state to the object


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_enforce_rule">enforce_rule</a>&lt;P, Rule, State: store&gt;(self: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;P&gt;, cap: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">request::PolicyCap</a>, state: State)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_enforce_rule">enforce_rule</a>&lt;P, Rule, State: store&gt;(
    self: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;, cap: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">PolicyCap</a>, state: State,
) {
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_version">assert_version</a>(self);

    <b>assert</b>!(<a href="_id">object::id</a>(self) == cap.for, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_ENotAllowed">ENotAllowed</a>);
    df::add(&<b>mut</b> self.id, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RuleStateDfKey">RuleStateDfKey</a>&lt;Rule&gt; {}, state);
    <a href="_insert">vec_set::insert</a>(&<b>mut</b> self.rules, <a href="_get">type_name::get</a>&lt;Rule&gt;());
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_enforce_rule_no_state"></a>

## Function `enforce_rule_no_state`

Registers rule in the Policy object without adding extra
config state to the object


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_enforce_rule_no_state">enforce_rule_no_state</a>&lt;P, Rule&gt;(self: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;P&gt;, cap: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">request::PolicyCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_enforce_rule_no_state">enforce_rule_no_state</a>&lt;P, Rule&gt;(
    self: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;, cap: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">PolicyCap</a>,
) {
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_version">assert_version</a>(self);
    <b>assert</b>!(<a href="_id">object::id</a>(self) == cap.for, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_ENotAllowed">ENotAllowed</a>);
    df::add(&<b>mut</b> self.id, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RuleStateDfKey">RuleStateDfKey</a>&lt;Rule&gt; {}, <b>true</b>);
    <a href="_insert">vec_set::insert</a>(&<b>mut</b> self.rules, <a href="_get">type_name::get</a>&lt;Rule&gt;());
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_drop_rule"></a>

## Function `drop_rule`



<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_drop_rule">drop_rule</a>&lt;P, Rule, State: store&gt;(self: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;P&gt;, cap: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">request::PolicyCap</a>): State
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_drop_rule">drop_rule</a>&lt;P, Rule, State: store&gt;(
    self: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;, cap: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">PolicyCap</a>,
): State {
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_version">assert_version</a>(self);
    <b>assert</b>!(<a href="_id">object::id</a>(self) == cap.for, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_ENotAllowed">ENotAllowed</a>);
    <a href="_remove">vec_set::remove</a>(&<b>mut</b> self.rules, &<a href="_get">type_name::get</a>&lt;Rule&gt;());
    df::remove(&<b>mut</b> self.id, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RuleStateDfKey">RuleStateDfKey</a>&lt;Rule&gt; {})
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_drop_rule_no_state"></a>

## Function `drop_rule_no_state`



<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_drop_rule_no_state">drop_rule_no_state</a>&lt;P, Rule&gt;(self: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;P&gt;, cap: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">request::PolicyCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_drop_rule_no_state">drop_rule_no_state</a>&lt;P, Rule&gt;(
    self: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;, cap: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">PolicyCap</a>,
) {
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_version">assert_version</a>(self);
    <b>assert</b>!(<a href="_id">object::id</a>(self) == cap.for, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_ENotAllowed">ENotAllowed</a>);
    <a href="_remove">vec_set::remove</a>(&<b>mut</b> self.rules, &<a href="_get">type_name::get</a>&lt;Rule&gt;());
    <b>assert</b>!(df::remove(&<b>mut</b> self.id, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RuleStateDfKey">RuleStateDfKey</a>&lt;Rule&gt; {}), 0);
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_rule_state"></a>

## Function `rule_state`



<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_rule_state">rule_state</a>&lt;P, Rule: drop, State: drop, store&gt;(self: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;P&gt;, _: Rule): &State
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_rule_state">rule_state</a>&lt;P, Rule: drop, State: store + drop&gt;(
    self: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;, _: Rule,
): &State {
    df::borrow(&self.id, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RuleStateDfKey">RuleStateDfKey</a>&lt;Rule&gt; {})
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_rule_state_mut"></a>

## Function `rule_state_mut`



<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_rule_state_mut">rule_state_mut</a>&lt;P, Rule: drop, State: drop, store&gt;(self: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;P&gt;, _: Rule): &<b>mut</b> State
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_rule_state_mut">rule_state_mut</a>&lt;P, Rule: drop, State: store + drop&gt;(
    self: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;, _: Rule,
): &<b>mut</b> State {
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_version">assert_version</a>(self);
    df::borrow_mut(&<b>mut</b> self.id, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_RuleStateDfKey">RuleStateDfKey</a>&lt;Rule&gt; {})
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_rules"></a>

## Function `rules`



<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_rules">rules</a>&lt;P&gt;(policy: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;P&gt;): &<a href="_VecSet">vec_set::VecSet</a>&lt;<a href="_TypeName">type_name::TypeName</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_rules">rules</a>&lt;P&gt;(policy: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;): &VecSet&lt;TypeName&gt; {
    &policy.rules
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_policy_cap_for"></a>

## Function `policy_cap_for`



<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_policy_cap_for">policy_cap_for</a>(policy: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">request::PolicyCap</a>): &<a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_policy_cap_for">policy_cap_for</a>(policy: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">PolicyCap</a>): &ID {
    &policy.for
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_policy_metadata_mut"></a>

## Function `policy_metadata_mut`



<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_policy_metadata_mut">policy_metadata_mut</a>&lt;P&gt;(policy: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;P&gt;): &<b>mut</b> <a href="_UID">object::UID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_policy_metadata_mut">policy_metadata_mut</a>&lt;P&gt;(policy: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;): &<b>mut</b> UID {
    <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_version">assert_version</a>(policy);

    &<b>mut</b> policy.id
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_policy_metadata"></a>

## Function `policy_metadata`



<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_policy_metadata">policy_metadata</a>&lt;P&gt;(policy: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;P&gt;): &<a href="_UID">object::UID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_policy_metadata">policy_metadata</a>&lt;P&gt;(policy: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;): &UID {
    &policy.id
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_confirm_"></a>

## Function `confirm_`



<pre><code><b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_confirm_">confirm_</a>(completed: <a href="">vector</a>&lt;<a href="_TypeName">type_name::TypeName</a>&gt;, rules: &<a href="_VecSet">vec_set::VecSet</a>&lt;<a href="_TypeName">type_name::TypeName</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_confirm_">confirm_</a>(completed: <a href="">vector</a>&lt;TypeName&gt;, rules: &VecSet&lt;TypeName&gt;) {
    <b>let</b> total = <a href="_length">vector::length</a>(&completed);
    <b>assert</b>!(total == <a href="_size">vec_set::size</a>(rules), <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_EPolicyNotSatisfied">EPolicyNotSatisfied</a>);

    <b>while</b> (total &gt; 0) {
        <b>let</b> rule_type = <a href="_pop_back">vector::pop_back</a>(&<b>mut</b> completed);
        <b>assert</b>!(<a href="_contains">vec_set::contains</a>(rules, &rule_type), <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_EIllegalRule">EIllegalRule</a>);
        total = total - 1;
    };
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_publisher"></a>

## Function `assert_publisher`

Asserts that <code>Publisher</code> is of type <code>T</code>


<a name="@Panics_1"></a>

###### Panics


Panics if <code>Publisher</code> is mismatched


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_publisher">assert_publisher</a>&lt;T&gt;(pub: &<a href="_Publisher">package::Publisher</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_publisher">assert_publisher</a>&lt;T&gt;(pub: &Publisher) {
    <b>assert</b>!(<a href="_from_package">package::from_package</a>&lt;T&gt;(pub), <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_EInvalidPublisher">EInvalidPublisher</a>);
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_version"></a>

## Function `assert_version`



<pre><code><b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_version">assert_version</a>&lt;P&gt;(policy: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;P&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_assert_version">assert_version</a>&lt;P&gt;(policy: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;) {
    <b>assert</b>!(policy.version == <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_VERSION">VERSION</a>, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_EWrongVersion">EWrongVersion</a>);
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_migrate"></a>

## Function `migrate`



<pre><code>entry <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_migrate">migrate</a>&lt;P&gt;(policy: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;P&gt;, cap: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">request::PolicyCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>entry <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_migrate">migrate</a>&lt;P&gt;(policy: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;, cap: &<a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_PolicyCap">PolicyCap</a>) {
    <b>assert</b>!(<a href="_id">object::id</a>(policy) == cap.for, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_ENotAllowed">ENotAllowed</a>);
    <b>assert</b>!(policy.version &lt; <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_VERSION">VERSION</a>, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_ENotUpgraded">ENotUpgraded</a>);
    policy.version = <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_VERSION">VERSION</a>;
}
</code></pre>



</details>

<a name="0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_migrate_as_pub"></a>

## Function `migrate_as_pub`



<pre><code>entry <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_migrate_as_pub">migrate_as_pub</a>&lt;P&gt;(policy: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">request::Policy</a>&lt;P&gt;, pub: &<a href="_Publisher">package::Publisher</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>entry <b>fun</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_migrate_as_pub">migrate_as_pub</a>&lt;P&gt;(policy: &<b>mut</b> <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_Policy">Policy</a>&lt;P&gt;, pub: &Publisher) {
    <b>assert</b>!(<a href="_from_package">package::from_package</a>&lt;OB_REQUEST&gt;(pub), 0);
    <b>assert</b>!(policy.version &lt; <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_VERSION">VERSION</a>, <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_ENotUpgraded">ENotUpgraded</a>);
    policy.version = <a href="request.md#0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43_request_VERSION">VERSION</a>;
}
</code></pre>



</details>
