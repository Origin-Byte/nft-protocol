
<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher"></a>

# Module `0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::frozen_publisher`

Frozen Publisher extends the functionality of the SUI display standards. One
problem with the SUI display standards is that it is not possible for a type
<code>T</code> to define its own display if its wrapped by <code>Wrapper&lt;T&gt;</code>.

<code><a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">FrozenPublisher</a></code> can be used by the wrapper module to allow for the publisher
of <code>T</code> to define its own display of <code>Wrapper&lt;T&gt;</code>.


-  [Struct `FROZEN_PUBLISHER`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FROZEN_PUBLISHER)
-  [Resource `FrozenPublisher`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher)
-  [Function `init`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_init)
-  [Function `freeze_from_otw`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_freeze_from_otw)
-  [Function `new`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_new)
-  [Function `public_freeze_object`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_public_freeze_object)
-  [Function `pkg`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_pkg)
-  [Function `mod`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_mod)
-  [Function `borrow_publisher`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_borrow_publisher)
-  [Function `new_display`](#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_new_display)


<pre><code><b>use</b> <a href="witness.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_witness">0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40::witness</a>;
<b>use</b> <a href="">0x1::ascii</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x2::display</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::package</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x859eb18bd5b5e8cc32deb6dfb1c39941008ab3c6e27f0b8ce2364be7102bb7cb::utils</a>;
</code></pre>



<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FROZEN_PUBLISHER"></a>

## Struct `FROZEN_PUBLISHER`



<pre><code><b>struct</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FROZEN_PUBLISHER">FROZEN_PUBLISHER</a> <b>has</b> drop
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

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher"></a>

## Resource `FrozenPublisher`



<pre><code><b>struct</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">FrozenPublisher</a> <b>has</b> key
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
<code>inner: <a href="_Publisher">package::Publisher</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_init"></a>

## Function `init`



<pre><code><b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_init">init</a>(otw: <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FROZEN_PUBLISHER">frozen_publisher::FROZEN_PUBLISHER</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_init">init</a>(otw: <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FROZEN_PUBLISHER">FROZEN_PUBLISHER</a>, ctx: &<b>mut</b> TxContext) {
    <b>let</b> publisher = <a href="_claim">package::claim</a>(otw, ctx);
    <b>let</b> <a href="">display</a> = <a href="_new">display::new</a>&lt;<a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">FrozenPublisher</a>&gt;(&publisher, ctx);

    <a href="_add">display::add</a>(&<b>mut</b> <a href="">display</a>, utf8(b"name"), utf8(b"<a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">FrozenPublisher</a>"));
    <a href="_add">display::add</a>(&<b>mut</b> <a href="">display</a>, utf8(b"url"), <a href="_originbyte_docs_url">utils::originbyte_docs_url</a>());
    <a href="_add">display::add</a>(
        &<b>mut</b> <a href="">display</a>,
        utf8(b"description"),
        utf8(b"Enables access <b>to</b> Publisher via <a href="witness.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_witness_Witness">witness::Witness</a>"),
    );

    <a href="_public_freeze_object">transfer::public_freeze_object</a>(<a href="">display</a>);
    <a href="_burn_publisher">package::burn_publisher</a>(publisher);
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_freeze_from_otw"></a>

## Function `freeze_from_otw`



<pre><code><b>public</b> <b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_freeze_from_otw">freeze_from_otw</a>&lt;OTW: drop&gt;(otw: OTW, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_freeze_from_otw">freeze_from_otw</a>&lt;OTW: drop&gt;(otw: OTW, ctx: &<b>mut</b> TxContext) {
    <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_public_freeze_object">public_freeze_object</a>(<a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_new">new</a>(<a href="_claim">package::claim</a>(otw, ctx), ctx));
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_new"></a>

## Function `new`



<pre><code><b>public</b> <b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_new">new</a>(inner: <a href="_Publisher">package::Publisher</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">frozen_publisher::FrozenPublisher</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_new">new</a>(inner: Publisher, ctx: &<b>mut</b> TxContext): <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">FrozenPublisher</a> {
    <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">FrozenPublisher</a> { id: <a href="_new">object::new</a>(ctx), inner }
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_public_freeze_object"></a>

## Function `public_freeze_object`



<pre><code><b>public</b> <b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_public_freeze_object">public_freeze_object</a>(self: <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">frozen_publisher::FrozenPublisher</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_public_freeze_object">public_freeze_object</a>(self: <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">FrozenPublisher</a>) {
    <a href="_freeze_object">transfer::freeze_object</a>(self);
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_pkg"></a>

## Function `pkg`



<pre><code><b>public</b> <b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_pkg">pkg</a>(self: &<a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">frozen_publisher::FrozenPublisher</a>): &<a href="_String">ascii::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_pkg">pkg</a>(self: &<a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">FrozenPublisher</a>): &<a href="_String">ascii::String</a> {
    <a href="_published_package">package::published_package</a>(&self.inner)
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_mod"></a>

## Function `mod`



<pre><code><b>public</b> <b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_mod">mod</a>(self: &<a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">frozen_publisher::FrozenPublisher</a>): &<a href="_String">ascii::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_mod">mod</a>(self: &<a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">FrozenPublisher</a>): &<a href="_String">ascii::String</a> {
    <a href="_published_module">package::published_module</a>(&self.inner)
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_borrow_publisher"></a>

## Function `borrow_publisher`



<pre><code><b>public</b> <b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_borrow_publisher">borrow_publisher</a>&lt;T&gt;(_witness: <a href="witness.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_witness_Witness">witness::Witness</a>&lt;T&gt;, self: &<a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">frozen_publisher::FrozenPublisher</a>): &<a href="_Publisher">package::Publisher</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_borrow_publisher">borrow_publisher</a>&lt;T&gt;(
    _witness: DelegatedWitness&lt;T&gt;, self: &<a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">FrozenPublisher</a>,
): &Publisher {
    <b>assert</b>!(<a href="_from_module">package::from_module</a>&lt;T&gt;(&self.inner), 0);
    &self.inner
}
</code></pre>



</details>

<a name="0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_new_display"></a>

## Function `new_display`

FrozenPublisher has Publisher from OTW of PARENT.

PARENT: a::b::Foo<c::d::Bar<..>>
INNER: c::d::Bar<..>

Asserts that inner type of Foo equals to the Bar.


<pre><code><b>public</b> <b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_new_display">new_display</a>&lt;PW: drop, Parent: key&gt;(_parent_wit: PW, self: &<a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">frozen_publisher::FrozenPublisher</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Display">display::Display</a>&lt;Parent&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_new_display">new_display</a>&lt;PW: drop, Parent: key&gt;(
    _parent_wit: PW,
    self: &<a href="frozen_publisher.md#0x16c5f17f2d55584a6e6daa442ccf83b4530d10546a8e7dedda9ba324e012fc40_frozen_publisher_FrozenPublisher">FrozenPublisher</a>,
    ctx: &<b>mut</b> TxContext,
): Display&lt;Parent&gt; {
    assert_same_module&lt;PW, Parent&gt;();

    <a href="_new">display::new</a>(&self.inner, ctx)
}
</code></pre>



</details>
