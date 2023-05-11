
<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum"></a>

# Module `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::quorum`

Quorum is a primitive for regulating access management to administrative
objects such <code>MintCap</code>, <code>Publisher</code>, <code>LaunchpadCap</code> among others.

The core problem that Quorum tries to solve is that it's not sufficiently
secure to own Capability objects directly via a keypair. Owning Cap objects
directly equates to centralization risk, exposing projects to
the risk that such keypair gets compromised.

Quorum solves this by providing a flexible yet ergonomic way of regulating
access control over these objects. Baseline Multi-sig only solves the
problem of distributing the risk accross keypairs but it does not provide an
ergonomic on-chain abstraction with ability to manage access control as well
as delegation capatibilities.

The core mechanics of the Quorum are the following:

1. Allowed users can borrow Cap objects from the Quorum but have to return
it in the same batch of programmable transactions. When authorised users
call <code>borrow_cap</code> they will receive the Cap object <code>T</code> and a hot potato object
<code><a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">ReturnReceipt</a>&lt;F, T&gt;</code>. In order for the batch of transactions to suceed this
hot potato object needs to be returned in conjunctions with the Cap <code>T</code>.

2. Quorum exports two users types: Admins and Members. Any <code>Admin</code> user can
add or remove <code>Member</code> users. To add or remove <code>Admin</code> users, at least >50%
of the admins need to vote in favor. (Note: This is the baseline
functionality that the quorum provides but it can be overwritten by
Quorum extensions to fit specific needs of projects)

3. Only Admins can insert Cap objects to Quorums. When inserting Cap objects,
admins can decide if these are accessible to Admin-only or if they are also
accessible to Members.

4. Delegation: To facilitate interactivity between parties, such as Games
or NFT creators and Marketplaces, Quorums can delegate access rights to other
Quorums. This means that sophisticated creators can create a CreatoQuorum and
delegate access rights to a MarketplaceQuorum. This allows for creators to
preserve their sovereignty over the collection's affairs, whilst allowing for
Marketplaces or other Third-Parties to act on their behalf.

5. Simplicity: The above case is an advanced option, however creators can
decide to start simple by calling quorum::singleton(creator_address), which
effectively mimics as if the creator would own the Cap objects directly.

Another option for simplicity, in cases where creators are completely
abstracted away from the on-chain code, these Cap objects can be stored
directly in the marketplace's Quorums. If needed at any time the Marketplace
can return the Caps back to the creator address or quorum.

6. Extendability: Following our principles of OriginByte as a developer
framework, this Quorum can be extended with custom-made implementations.
In a nutshell, extensions can:

- Implement different voting mechanisms with their own majority
and minority rules;
- Implement different access-permission schemes (they can bypass
the Admin-Member model and add their own model)


-  [Resource `Quorum`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum)
-  [Struct `ReturnReceipt`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt)
-  [Struct `ExtensionToken`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken)
-  [Struct `Signatures`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Signatures)
-  [Struct `AdminField`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AdminField)
-  [Struct `MemberField`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_MemberField)
-  [Struct `AddAdmin`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AddAdmin)
-  [Struct `RemoveAdmin`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_RemoveAdmin)
-  [Struct `AddDelegate`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AddDelegate)
-  [Struct `RemoveDelegate`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_RemoveDelegate)
-  [Struct `CreateQuorumEvent`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_CreateQuorumEvent)
-  [Struct `Foo`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Foo)
-  [Constants](#@Constants_0)
-  [Function `create`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_create)
-  [Function `create_for_extension`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_create_for_extension)
-  [Function `init_quorum`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_init_quorum)
-  [Function `singleton`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_singleton)
-  [Function `vote_add_admin`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_add_admin)
-  [Function `vote_remove_admin`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_remove_admin)
-  [Function `add_admin_with_extension`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_add_admin_with_extension)
-  [Function `remove_admin_with_extension`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_remove_admin_with_extension)
-  [Function `vote_add_delegate`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_add_delegate)
-  [Function `vote_remove_delegate`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_remove_delegate)
-  [Function `add_delegate_with_extension`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_add_delegate_with_extension)
-  [Function `remove_delegate_with_extension`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_remove_delegate_with_extension)
-  [Function `vote`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote)
-  [Function `sign`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_sign)
-  [Function `calc_voting_threshold`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_calc_voting_threshold)
-  [Function `add_member`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_add_member)
-  [Function `remove_member`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_remove_member)
-  [Function `insert_cap`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_insert_cap)
-  [Function `borrow_cap`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_borrow_cap)
-  [Function `return_cap`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_return_cap)
-  [Function `borrow_cap_as_delegate`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_borrow_cap_as_delegate)
-  [Function `return_cap_as_delegate`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_return_cap_as_delegate)
-  [Function `return_cap_`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_return_cap_)
-  [Function `insert_cap_`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_insert_cap_)
-  [Function `burn_receipt`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_burn_receipt)
-  [Function `uid_mut`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_uid_mut)
-  [Function `assert_admin`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_admin)
-  [Function `assert_member`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member)
-  [Function `assert_member_or_admin`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member_or_admin)
-  [Function `assert_extension_token`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_extension_token)
-  [Function `assert_delegate`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_delegate)
-  [Function `assert_version`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version)
-  [Function `migrate_as_creator`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_migrate_as_creator)
-  [Function `migrate_as_pub`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_migrate_as_pub)


<pre><code><b>use</b> <a href="init.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_permissions">0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::permissions</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::type_name</a>;
<b>use</b> <a href="">0x2::dynamic_field</a>;
<b>use</b> <a href="">0x2::event</a>;
<b>use</b> <a href="">0x2::math</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::package</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x2::vec_set</a>;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum"></a>

## Resource `Quorum`



<pre><code><b>struct</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt; <b>has</b> store, key
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
<code>admins: <a href="_VecSet">vec_set::VecSet</a>&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>members: <a href="_VecSet">vec_set::VecSet</a>&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>delegates: <a href="_VecSet">vec_set::VecSet</a>&lt;<a href="_ID">object::ID</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>admin_count: u64</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt"></a>

## Struct `ReturnReceipt`



<pre><code><b>struct</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">ReturnReceipt</a>&lt;F, T: key&gt;
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

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken"></a>

## Struct `ExtensionToken`



<pre><code><b>struct</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">ExtensionToken</a>&lt;F&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>quorum_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Signatures"></a>

## Struct `Signatures`



<pre><code><b>struct</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Signatures">Signatures</a>&lt;F&gt; <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>list: <a href="_VecSet">vec_set::VecSet</a>&lt;<b>address</b>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AdminField"></a>

## Struct `AdminField`



<pre><code><b>struct</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AdminField">AdminField</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="">type_name</a>: <a href="_TypeName">type_name::TypeName</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_MemberField"></a>

## Struct `MemberField`



<pre><code><b>struct</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_MemberField">MemberField</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="">type_name</a>: <a href="_TypeName">type_name::TypeName</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AddAdmin"></a>

## Struct `AddAdmin`



<pre><code><b>struct</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AddAdmin">AddAdmin</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>admin: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_RemoveAdmin"></a>

## Struct `RemoveAdmin`



<pre><code><b>struct</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_RemoveAdmin">RemoveAdmin</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>admin: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AddDelegate"></a>

## Struct `AddDelegate`



<pre><code><b>struct</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AddDelegate">AddDelegate</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>entity: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_RemoveDelegate"></a>

## Struct `RemoveDelegate`



<pre><code><b>struct</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_RemoveDelegate">RemoveDelegate</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>entity: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_CreateQuorumEvent"></a>

## Struct `CreateQuorumEvent`



<pre><code><b>struct</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_CreateQuorumEvent">CreateQuorumEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>quorum_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code><a href="">type_name</a>: <a href="_TypeName">type_name::TypeName</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Foo"></a>

## Struct `Foo`



<pre><code><b>struct</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Foo">Foo</a> <b>has</b> drop
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


<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ADMIN_ADDR_1"></a>



<pre><code><b>const</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ADMIN_ADDR_1">ADMIN_ADDR_1</a>: <b>address</b> = 1;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ADMIN_ADDR_2"></a>



<pre><code><b>const</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ADMIN_ADDR_2">ADMIN_ADDR_2</a>: <b>address</b> = 2;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_EInvalidDelegate"></a>



<pre><code><b>const</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_EInvalidDelegate">EInvalidDelegate</a>: u64 = 6;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_EMinAdminCountIsOne"></a>



<pre><code><b>const</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_EMinAdminCountIsOne">EMinAdminCountIsOne</a>: u64 = 4;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ENotAMember"></a>



<pre><code><b>const</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ENotAMember">ENotAMember</a>: u64 = 2;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ENotAnAdmin"></a>



<pre><code><b>const</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ENotAnAdmin">ENotAnAdmin</a>: u64 = 1;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ENotAnAdminNorMember"></a>



<pre><code><b>const</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ENotAnAdminNorMember">ENotAnAdminNorMember</a>: u64 = 3;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ENotUpgraded"></a>



<pre><code><b>const</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ENotUpgraded">ENotUpgraded</a>: u64 = 999;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_EQuorumExtensionMismatch"></a>



<pre><code><b>const</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_EQuorumExtensionMismatch">EQuorumExtensionMismatch</a>: u64 = 5;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_EWrongVersion"></a>



<pre><code><b>const</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_EWrongVersion">EWrongVersion</a>: u64 = 1000;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_MEMBER_ADDR_1"></a>



<pre><code><b>const</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_MEMBER_ADDR_1">MEMBER_ADDR_1</a>: <b>address</b> = 1337;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_MEMBER_ADDR_2"></a>



<pre><code><b>const</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_MEMBER_ADDR_2">MEMBER_ADDR_2</a>: <b>address</b> = 1338;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_QUORUM"></a>



<pre><code><b>const</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_QUORUM">QUORUM</a>: <b>address</b> = 1234;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_VERSION"></a>



<pre><code><b>const</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_VERSION">VERSION</a>: u64 = 1;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_create"></a>

## Function `create`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_create">create</a>&lt;F&gt;(_witness: &F, admins: <a href="_VecSet">vec_set::VecSet</a>&lt;<b>address</b>&gt;, members: <a href="_VecSet">vec_set::VecSet</a>&lt;<b>address</b>&gt;, delegates: <a href="_VecSet">vec_set::VecSet</a>&lt;<a href="_ID">object::ID</a>&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_create">create</a>&lt;F&gt;(
    _witness: &F,
    admins: VecSet&lt;<b>address</b>&gt;,
    members: VecSet&lt;<b>address</b>&gt;,
    delegates: VecSet&lt;ID&gt;,
    ctx: &<b>mut</b> TxContext,
): <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt; {
    <b>let</b> id = <a href="_new">object::new</a>(ctx);

    <a href="_emit">event::emit</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_CreateQuorumEvent">CreateQuorumEvent</a> {
        quorum_id: <a href="_uid_to_inner">object::uid_to_inner</a>(&id),
        <a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;F&gt;(),
    });

    <b>let</b> admin_count = <a href="_size">vec_set::size</a>(&admins);

    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a> { id, version: <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_VERSION">VERSION</a>, admins, members, delegates, admin_count }
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_create_for_extension"></a>

## Function `create_for_extension`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_create_for_extension">create_for_extension</a>&lt;F&gt;(<a href="witness.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_witness">witness</a>: &F, admins: <a href="_VecSet">vec_set::VecSet</a>&lt;<b>address</b>&gt;, members: <a href="_VecSet">vec_set::VecSet</a>&lt;<b>address</b>&gt;, delegates: <a href="_VecSet">vec_set::VecSet</a>&lt;<a href="_ID">object::ID</a>&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">quorum::ExtensionToken</a>&lt;F&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_create_for_extension">create_for_extension</a>&lt;F&gt;(
    <a href="witness.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_witness">witness</a>: &F,
    admins: VecSet&lt;<b>address</b>&gt;,
    members: VecSet&lt;<b>address</b>&gt;,
    delegates: VecSet&lt;ID&gt;,
    ctx: &<b>mut</b> TxContext,
): (<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">ExtensionToken</a>&lt;F&gt;) {
    <b>let</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a> = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_create">create</a>(<a href="witness.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_witness">witness</a>, admins, members, delegates, ctx);
    <b>let</b> extension_token = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">ExtensionToken</a> { quorum_id: <a href="_id">object::id</a>(&<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>) };

    (<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, extension_token)
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_init_quorum"></a>

## Function `init_quorum`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_init_quorum">init_quorum</a>&lt;F&gt;(<a href="witness.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_witness">witness</a>: &F, admins: <a href="_VecSet">vec_set::VecSet</a>&lt;<b>address</b>&gt;, members: <a href="_VecSet">vec_set::VecSet</a>&lt;<b>address</b>&gt;, delegates: <a href="_VecSet">vec_set::VecSet</a>&lt;<a href="_ID">object::ID</a>&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_init_quorum">init_quorum</a>&lt;F&gt;(
    <a href="witness.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_witness">witness</a>: &F,
    admins: VecSet&lt;<b>address</b>&gt;,
    members: VecSet&lt;<b>address</b>&gt;,
    delegates: VecSet&lt;ID&gt;,
    ctx: &<b>mut</b> TxContext,
): ID {
    <b>let</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a> = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_create">create</a>(<a href="witness.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_witness">witness</a>, admins, members, delegates, ctx);
    <b>let</b> quorum_id = <a href="_id">object::id</a>(&<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);

    <a href="_share_object">transfer::share_object</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);
    quorum_id
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_singleton"></a>

## Function `singleton`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_singleton">singleton</a>&lt;F&gt;(<a href="witness.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_witness">witness</a>: &F, admin: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_singleton">singleton</a>&lt;F&gt;(
    <a href="witness.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_witness">witness</a>: &F,
    admin: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
): <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt; {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_create">create</a>(
        <a href="witness.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_witness">witness</a>,
        <a href="_singleton">vec_set::singleton</a>(admin),
        <a href="_empty">vec_set::empty</a>(),
        <a href="_empty">vec_set::empty</a>(),
        ctx
    )
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_add_admin"></a>

## Function `vote_add_admin`



<pre><code><b>public</b> entry <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_add_admin">vote_add_admin</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, new_admin: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_add_admin">vote_add_admin</a>&lt;F&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    new_admin: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);

    <b>let</b> (vote_count, threshold) = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote">vote</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AddAdmin">AddAdmin</a> { admin: new_admin}, ctx);

    <b>if</b> (vote_count &gt;= threshold) {
        df::remove&lt;<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AddAdmin">AddAdmin</a>, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Signatures">Signatures</a>&lt;F&gt;&gt;(&<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AddAdmin">AddAdmin</a> { admin: new_admin});
        <a href="_insert">vec_set::insert</a>(&<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admins, new_admin);
        <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admin_count = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admin_count + 1;
    };
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_remove_admin"></a>

## Function `vote_remove_admin`



<pre><code><b>public</b> entry <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_remove_admin">vote_remove_admin</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, old_admin: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_remove_admin">vote_remove_admin</a>&lt;F&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    old_admin: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);

    <b>assert</b>!(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admin_count == 1, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_EMinAdminCountIsOne">EMinAdminCountIsOne</a>);

    <b>let</b> (vote_count, threshold) = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote">vote</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_RemoveAdmin">RemoveAdmin</a> { admin: old_admin}, ctx);

    <b>if</b> (vote_count &gt;= threshold) {
        df::remove&lt;<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_RemoveAdmin">RemoveAdmin</a>, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Signatures">Signatures</a>&lt;F&gt;&gt;(&<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_RemoveAdmin">RemoveAdmin</a> { admin: old_admin});
        <a href="_remove">vec_set::remove</a>(&<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admins, &old_admin);

        <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admin_count = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admin_count - 1;
    };
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_add_admin_with_extension"></a>

## Function `add_admin_with_extension`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_add_admin_with_extension">add_admin_with_extension</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, ext_token: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">quorum::ExtensionToken</a>&lt;F&gt;, new_admin: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_add_admin_with_extension">add_admin_with_extension</a>&lt;F&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    ext_token: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">ExtensionToken</a>&lt;F&gt;,
    new_admin: <b>address</b>,
) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_extension_token">assert_extension_token</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, ext_token);

    <a href="_insert">vec_set::insert</a>(&<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admins, new_admin);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admin_count = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admin_count + 1;
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_remove_admin_with_extension"></a>

## Function `remove_admin_with_extension`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_remove_admin_with_extension">remove_admin_with_extension</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, ext_token: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">quorum::ExtensionToken</a>&lt;F&gt;, old_admin: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_remove_admin_with_extension">remove_admin_with_extension</a>&lt;F&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    ext_token: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">ExtensionToken</a>&lt;F&gt;,
    old_admin: <b>address</b>,
) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_extension_token">assert_extension_token</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, ext_token);
    <a href="_remove">vec_set::remove</a>(&<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admins, &old_admin);

    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admin_count = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admin_count - 1;
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_add_delegate"></a>

## Function `vote_add_delegate`



<pre><code><b>public</b> entry <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_add_delegate">vote_add_delegate</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, entity: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_add_delegate">vote_add_delegate</a>&lt;F&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    entity: ID,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);

    <b>let</b> (vote_count, threshold) = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote">vote</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AddDelegate">AddDelegate</a> { entity }, ctx);

    <b>if</b> (vote_count &gt;= threshold) {
        df::remove&lt;<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AddDelegate">AddDelegate</a>, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Signatures">Signatures</a>&lt;F&gt;&gt;(&<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AddDelegate">AddDelegate</a> { entity });
        <a href="_insert">vec_set::insert</a>(&<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.delegates, entity);
    };
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_remove_delegate"></a>

## Function `vote_remove_delegate`



<pre><code><b>public</b> entry <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_remove_delegate">vote_remove_delegate</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, entity: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote_remove_delegate">vote_remove_delegate</a>&lt;F&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    entity: ID,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);

    <b>assert</b>!(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admin_count &gt; 1, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_EMinAdminCountIsOne">EMinAdminCountIsOne</a>);

    <b>let</b> (vote_count, threshold) = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote">vote</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_RemoveDelegate">RemoveDelegate</a> { entity }, ctx);

    <b>if</b> (vote_count &gt;= threshold) {
        df::remove&lt;<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_RemoveDelegate">RemoveDelegate</a>, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Signatures">Signatures</a>&lt;F&gt;&gt;(&<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_RemoveDelegate">RemoveDelegate</a> { entity });
        <a href="_remove">vec_set::remove</a>(&<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.delegates, &entity);
    };
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_add_delegate_with_extension"></a>

## Function `add_delegate_with_extension`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_add_delegate_with_extension">add_delegate_with_extension</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, ext_token: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">quorum::ExtensionToken</a>&lt;F&gt;, entity: <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_add_delegate_with_extension">add_delegate_with_extension</a>&lt;F&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    ext_token: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">ExtensionToken</a>&lt;F&gt;,
    entity: ID,
) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_extension_token">assert_extension_token</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, ext_token);
    <a href="_insert">vec_set::insert</a>(&<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.delegates, entity);
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_remove_delegate_with_extension"></a>

## Function `remove_delegate_with_extension`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_remove_delegate_with_extension">remove_delegate_with_extension</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, ext_token: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">quorum::ExtensionToken</a>&lt;F&gt;, entity: <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_remove_delegate_with_extension">remove_delegate_with_extension</a>&lt;F&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    ext_token: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">ExtensionToken</a>&lt;F&gt;,
    entity: ID,
) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_extension_token">assert_extension_token</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, ext_token);
    <a href="_remove">vec_set::remove</a>(&<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.delegates, &entity);
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote"></a>

## Function `vote`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote">vote</a>&lt;F, Field: <b>copy</b>, drop, store&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, field: Field, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_vote">vote</a>&lt;F, Field: <b>copy</b> + drop + store&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    field: Field,
    ctx: &<b>mut</b> TxContext,
): (u64, u64) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_admin">assert_admin</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, ctx);

    <b>let</b> signatures_exist = df::exists_(
        &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, field
    );

    <b>let</b> vote_count: u64;
    <b>let</b> threshold: u64;

    <b>if</b> (signatures_exist) {
        <b>let</b> sigs = df::borrow_mut(
            &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, field
        );

        <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_sign">sign</a>&lt;F&gt;(sigs, ctx);

        vote_count = <a href="_size">vec_set::size</a>(&sigs.list);
        threshold = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_calc_voting_threshold">calc_voting_threshold</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admin_count);

    } <b>else</b> {
        <b>let</b> sig = <a href="_sender">tx_context::sender</a>(ctx);

        <b>let</b> voting_booth = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Signatures">Signatures</a>&lt;F&gt; {
            list: <a href="_singleton">vec_set::singleton</a>(sig),
        };

        df::add(
            &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, field, voting_booth
        );

        vote_count = 1;
        threshold = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_calc_voting_threshold">calc_voting_threshold</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admin_count);
    };

    (vote_count, threshold)
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_sign"></a>

## Function `sign`



<pre><code><b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_sign">sign</a>&lt;F&gt;(sigs: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Signatures">quorum::Signatures</a>&lt;F&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_sign">sign</a>&lt;F&gt;(
    sigs: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Signatures">Signatures</a>&lt;F&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="_insert">vec_set::insert</a>(&<b>mut</b> sigs.list, <a href="_sender">tx_context::sender</a>(ctx))
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_calc_voting_threshold"></a>

## Function `calc_voting_threshold`



<pre><code><b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_calc_voting_threshold">calc_voting_threshold</a>(admin_count: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_calc_voting_threshold">calc_voting_threshold</a>(
    admin_count: u64,
): u64 {
    <b>let</b> threshold: u64;

    <b>if</b> (admin_count == 1) {
        threshold = 1;
    } <b>else</b> {
        threshold = <a href="_divide_and_round_up">math::divide_and_round_up</a>(admin_count, 2);

        <b>if</b> (admin_count % 2 == 0) {
            threshold = threshold + 1;
        }
    };

    threshold
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_add_member"></a>

## Function `add_member`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_add_member">add_member</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, member: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_add_member">add_member</a>&lt;F&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    member: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_admin">assert_admin</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, ctx);

    <a href="_insert">vec_set::insert</a>(&<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.members, member);
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_remove_member"></a>

## Function `remove_member`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_remove_member">remove_member</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, member: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_remove_member">remove_member</a>&lt;F&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    member: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_admin">assert_admin</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, ctx);

    <a href="_remove">vec_set::remove</a>(&<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.members, &member);
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_insert_cap"></a>

## Function `insert_cap`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_insert_cap">insert_cap</a>&lt;F, T: store, key&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, cap_object: T, admin_only: bool, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_insert_cap">insert_cap</a>&lt;F, T: key + store&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    cap_object: T,
    admin_only: bool,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_admin">assert_admin</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, ctx);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_insert_cap_">insert_cap_</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, cap_object, admin_only);
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_borrow_cap"></a>

## Function `borrow_cap`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_borrow_cap">borrow_cap</a>&lt;F, T: store, key&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (T, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">quorum::ReturnReceipt</a>&lt;F, T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_borrow_cap">borrow_cap</a>&lt;F, T: key + store&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    ctx: &<b>mut</b> TxContext,
): (T, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">ReturnReceipt</a>&lt;F, T&gt;) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member_or_admin">assert_member_or_admin</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, ctx);
    <b>let</b> is_admin_field = df::exists_(
        &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AdminField">AdminField</a> {<a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;T&gt;()}
    );

    <b>let</b> cap: T;

    <b>if</b> (is_admin_field) {
        <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_admin">assert_admin</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, ctx);

        <b>let</b> field = df::borrow_mut(
            &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AdminField">AdminField</a> {<a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;T&gt;()}
        );

        cap = <a href="_extract">option::extract</a>(field);

    } <b>else</b> {
        <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member">assert_member</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, ctx);

        // Fails <b>if</b> Member field does not exist either
        <b>let</b> field = df::borrow_mut(
            &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_MemberField">MemberField</a> {<a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;T&gt;()}
        );

        cap = <a href="_extract">option::extract</a>(field);
    };

    (cap, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">ReturnReceipt</a> {})
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_return_cap"></a>

## Function `return_cap`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_return_cap">return_cap</a>&lt;F, T: store, key&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, cap_object: T, receipt: <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">quorum::ReturnReceipt</a>&lt;F, T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_return_cap">return_cap</a>&lt;F, T: key + store&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    cap_object: T,
    receipt: <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">ReturnReceipt</a>&lt;F, T&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_return_cap_">return_cap_</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, cap_object, ctx);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_burn_receipt">burn_receipt</a>(receipt);
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_borrow_cap_as_delegate"></a>

## Function `borrow_cap_as_delegate`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_borrow_cap_as_delegate">borrow_cap_as_delegate</a>&lt;F1, F2, T: store, key&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F1&gt;, delegate: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F2&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (T, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">quorum::ReturnReceipt</a>&lt;F1, T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_borrow_cap_as_delegate">borrow_cap_as_delegate</a>&lt;F1, F2, T: key + store&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F1&gt;,
    delegate: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F2&gt;,
    ctx: &<b>mut</b> TxContext,
): (T, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">ReturnReceipt</a>&lt;F1, T&gt;) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_delegate">assert_delegate</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, &delegate.id);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member_or_admin">assert_member_or_admin</a>(delegate, ctx);

    <b>let</b> is_admin_field = df::exists_(
        &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AdminField">AdminField</a> {<a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;T&gt;()}
    );

    <b>let</b> cap: T;

    <b>if</b> (is_admin_field) {
        <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_admin">assert_admin</a>(delegate, ctx);

        <b>let</b> field = df::borrow_mut(
            &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AdminField">AdminField</a> {<a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;T&gt;()}
        );

        cap = <a href="_extract">option::extract</a>(field);

    } <b>else</b> {
        <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member">assert_member</a>(delegate, ctx);

        // Fails <b>if</b> Member field does not exist either
        <b>let</b> field = df::borrow_mut(
            &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_MemberField">MemberField</a> {<a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;T&gt;()}
        );

        cap = <a href="_extract">option::extract</a>(field);
    };

    (cap, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">ReturnReceipt</a> {})
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_return_cap_as_delegate"></a>

## Function `return_cap_as_delegate`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_return_cap_as_delegate">return_cap_as_delegate</a>&lt;F1, F2, T: store, key&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F1&gt;, delegate: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F2&gt;, cap_object: T, receipt: <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">quorum::ReturnReceipt</a>&lt;F1, T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_return_cap_as_delegate">return_cap_as_delegate</a>&lt;F1, F2, T: key + store&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F1&gt;,
    delegate: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F2&gt;,
    cap_object: T,
    receipt: <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">ReturnReceipt</a>&lt;F1, T&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_delegate">assert_delegate</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, &delegate.id);
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member_or_admin">assert_member_or_admin</a>(delegate, ctx);

    <b>let</b> is_admin_field = df::exists_(
        &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AdminField">AdminField</a> {<a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;T&gt;()}
    );

    <b>if</b> (is_admin_field) {
        <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_admin">assert_admin</a>(delegate, ctx);

        <b>let</b> field = df::borrow_mut(
            &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AdminField">AdminField</a> {<a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;T&gt;()}
        );

        <a href="_fill">option::fill</a>(field, cap_object);
    } <b>else</b> {
        <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member">assert_member</a>(delegate, ctx);

        // Fails <b>if</b> Member field does not exist either
        <b>let</b> field = df::borrow_mut(
            &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_MemberField">MemberField</a> {<a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;T&gt;()}
        );

        <a href="_fill">option::fill</a>(field, cap_object);
    };

    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_burn_receipt">burn_receipt</a>(receipt);
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_return_cap_"></a>

## Function `return_cap_`



<pre><code><b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_return_cap_">return_cap_</a>&lt;F, T: store, key&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, cap_object: T, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_return_cap_">return_cap_</a>&lt;F, T: key + store&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    cap_object: T,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> is_admin_field = df::exists_(
        &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AdminField">AdminField</a> {<a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;T&gt;()}
    );

    <b>if</b> (is_admin_field) {
        <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_admin">assert_admin</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, ctx);

        <b>let</b> field = df::borrow_mut(
            &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AdminField">AdminField</a> {<a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;T&gt;()}
        );

        <a href="_fill">option::fill</a>(field, cap_object);
    } <b>else</b> {
        <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member">assert_member</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, ctx);

        // Fails <b>if</b> Member field does not exist either
        <b>let</b> field = df::borrow_mut(
            &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_MemberField">MemberField</a> {<a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;T&gt;()}
        );

        <a href="_fill">option::fill</a>(field, cap_object);
    }
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_insert_cap_"></a>

## Function `insert_cap_`



<pre><code><b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_insert_cap_">insert_cap_</a>&lt;F, T: store, key&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, cap_object: T, admin_only: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_insert_cap_">insert_cap_</a>&lt;F, T: key + store&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    cap_object: T,
    admin_only: bool,
) {
    <b>if</b> (admin_only) {
        df::add(
            &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id,
            <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_AdminField">AdminField</a> {<a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;T&gt;()},
            <a href="_some">option::some</a>(cap_object),
        );
    } <b>else</b> {
        df::add(
            &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id,
            <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_MemberField">MemberField</a> {<a href="">type_name</a>: <a href="_get">type_name::get</a>&lt;T&gt;()},
            <a href="_some">option::some</a>(cap_object),
        );
    }
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_burn_receipt"></a>

## Function `burn_receipt`



<pre><code><b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_burn_receipt">burn_receipt</a>&lt;F, T: store, key&gt;(receipt: <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">quorum::ReturnReceipt</a>&lt;F, T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_burn_receipt">burn_receipt</a>&lt;F, T: key + store&gt;(
    receipt: <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">ReturnReceipt</a>&lt;F, T&gt;
) {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ReturnReceipt">ReturnReceipt</a> {} = receipt;
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_uid_mut"></a>

## Function `uid_mut`



<pre><code><b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_uid_mut">uid_mut</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, ext_token: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">quorum::ExtensionToken</a>&lt;F&gt;): &<b>mut</b> <a href="_UID">object::UID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_uid_mut">uid_mut</a>&lt;F&gt;(
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;,
    ext_token: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">ExtensionToken</a>&lt;F&gt;,
): &<b>mut</b> UID {
    <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_extension_token">assert_extension_token</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>, ext_token);

    &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.id
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_admin"></a>

## Function `assert_admin`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_admin">assert_admin</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, ctx: &<a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_admin">assert_admin</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;, ctx: &TxContext) {
    <b>assert</b>!(<a href="_contains">vec_set::contains</a>(&<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admins, &<a href="_sender">tx_context::sender</a>(ctx)), <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ENotAnAdmin">ENotAnAdmin</a>);
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member"></a>

## Function `assert_member`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member">assert_member</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, ctx: &<a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member">assert_member</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;, ctx: &TxContext) {
    <b>assert</b>!(<a href="_contains">vec_set::contains</a>(&<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.members, &<a href="_sender">tx_context::sender</a>(ctx)), <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ENotAMember">ENotAMember</a>);
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member_or_admin"></a>

## Function `assert_member_or_admin`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member_or_admin">assert_member_or_admin</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, ctx: &<a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_member_or_admin">assert_member_or_admin</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;, ctx: &TxContext) {
    <b>assert</b>!(
        <a href="_contains">vec_set::contains</a>(&<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.admins, &<a href="_sender">tx_context::sender</a>(ctx))
            || <a href="_contains">vec_set::contains</a>(&<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.members, &<a href="_sender">tx_context::sender</a>(ctx)),
        <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ENotAnAdminNorMember">ENotAnAdminNorMember</a>);
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_extension_token"></a>

## Function `assert_extension_token`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_extension_token">assert_extension_token</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, ext_token: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">quorum::ExtensionToken</a>&lt;F&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_extension_token">assert_extension_token</a>&lt;F&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;, ext_token: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_ExtensionToken">ExtensionToken</a>&lt;F&gt;) {
    <b>assert</b>!(<a href="_id">object::id</a>(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>) == ext_token.quorum_id, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_EQuorumExtensionMismatch">EQuorumExtensionMismatch</a>);
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_delegate"></a>

## Function `assert_delegate`



<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_delegate">assert_delegate</a>&lt;F1&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F1&gt;, delegate_uid: &<a href="_UID">object::UID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_delegate">assert_delegate</a>&lt;F1&gt;(<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F1&gt;, delegate_uid: &UID) {
    <b>assert</b>!(
        <a href="_contains">vec_set::contains</a>(&<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum">quorum</a>.delegates, <a href="_uid_as_inner">object::uid_as_inner</a>(delegate_uid)),
        <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_EInvalidDelegate">EInvalidDelegate</a>
    );
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version"></a>

## Function `assert_version`



<pre><code><b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>&lt;F&gt;(self: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_assert_version">assert_version</a>&lt;F&gt;(self: &<a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;) {
    <b>assert</b>!(self.version == <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_VERSION">VERSION</a>, <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_EWrongVersion">EWrongVersion</a>);
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_migrate_as_creator"></a>

## Function `migrate_as_creator`



<pre><code>entry <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_migrate_as_creator">migrate_as_creator</a>&lt;F&gt;(self: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, pub: &<a href="_Publisher">package::Publisher</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>entry <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_migrate_as_creator">migrate_as_creator</a>&lt;F&gt;(
    self: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;, pub: &Publisher,
) {
    <b>assert</b>!(<a href="_from_package">package::from_package</a>&lt;F&gt;(pub), 0);
    self.version = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_VERSION">VERSION</a>;
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_migrate_as_pub"></a>

## Function `migrate_as_pub`



<pre><code>entry <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_migrate_as_pub">migrate_as_pub</a>&lt;F&gt;(self: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">quorum::Quorum</a>&lt;F&gt;, pub: &<a href="_Publisher">package::Publisher</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>entry <b>fun</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_migrate_as_pub">migrate_as_pub</a>&lt;F&gt;(
    self: &<b>mut</b> <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_Quorum">Quorum</a>&lt;F&gt;, pub: &Publisher
) {
    <b>assert</b>!(<a href="_from_package">package::from_package</a>&lt;PERMISSIONS&gt;(pub), 0);
    self.version = <a href="quorum.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_quorum_VERSION">VERSION</a>;
}
</code></pre>



</details>
