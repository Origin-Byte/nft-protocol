
<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist"></a>

# Module `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::market_whitelist`

Module responsible for the creation and destruction of Whitelist certificates.


-  [Resource `Certificate`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate)
-  [Constants](#@Constants_0)
-  [Function `new`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_new)
-  [Function `issue`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_issue)
-  [Function `burn`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_burn)
-  [Function `assert_whitelist`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_assert_whitelist)
-  [Function `assert_certificate`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_assert_certificate)


<pre><code><b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing</a>;
<b>use</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::venue</a>;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate"></a>

## Resource `Certificate`

Grants owner the privilege to participate in an NFT sale in a
whitelisted <code>Listing</code>

Creators can create tiered sales based on the NFT rarity and then
whitelist only the rare NFT sale. Alternatively, they can provide a
lower priced market on an <code>Inventory</code> that they can then emit whitelist
tokens and send them to users who have completed a set of defined
actions.


<pre><code><b>struct</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a> <b>has</b> store, key
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
<code>listing_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 <code>Listing</code> from which this certificate can withdraw an <code>Nft</code>
</dd>
<dt>
<code>venue_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>
 <code>Venue</code> from which this certificate can withdraw an <code>Nft</code>
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_EINCORRECT_CERTIFICATE"></a>

<code><a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a></code> issued for incorrect <code>Venue</code> ID


<pre><code><b>const</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_EINCORRECT_CERTIFICATE">EINCORRECT_CERTIFICATE</a>: u64 = 1;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_new"></a>

## Function `new`

Create a new <code><a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a></code>

Can be used by owner to participate in the provided market.


<a name="@Panics_1"></a>

###### Panics


Panics if transaction sender is not <code>Listing</code> admin


<pre><code><b>public</b> <b>fun</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_new">new</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">market_whitelist::Certificate</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_new">new</a>(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &Listing,
    venue_id: ID,
    ctx: &<b>mut</b> TxContext,
): <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a> {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">listing::assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_venue">listing::assert_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id);

    <b>let</b> certificate = <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a> {
        id: <a href="_new">object::new</a>(ctx),
        listing_id: <a href="_id">object::id</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>),
        venue_id,
    };

    certificate
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_issue"></a>

## Function `issue`

Issue a new <code><a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a></code> to an address

Can be used by owner to participate in the provided market.


<a name="@Panics_2"></a>

###### Panics


Panics if transaction sender is not <code>Listing</code> admin


<pre><code><b>public</b> entry <b>fun</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_issue">issue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, recipient: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_issue">issue</a>(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &Listing,
    venue_id: ID,
    recipient: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> certificate = <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_new">new</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id, ctx);
    <a href="_public_transfer">transfer::public_transfer</a>(certificate, recipient);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_burn"></a>

## Function `burn`

Burns a <code><a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a></code>


<pre><code><b>public</b> entry <b>fun</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_burn">burn</a>(certificate: <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">market_whitelist::Certificate</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_burn">burn</a>(
    certificate: <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a>,
) {
    <b>let</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a> {
        id,
        listing_id: _,
        venue_id: _,
    } = certificate;

    <a href="_delete">object::delete</a>(id);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_assert_whitelist"></a>

## Function `assert_whitelist`

Assert <code><a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a></code> parameters based on <code>Venue</code>


<a name="@Panics_3"></a>

###### Panics


Panics if <code>Venue</code> is not whitelisted or <code><a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a></code> parameters
don't match.


<pre><code><b>public</b> <b>fun</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_assert_whitelist">assert_whitelist</a>(certificate: &<a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">market_whitelist::Certificate</a>, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_assert_whitelist">assert_whitelist</a>(certificate: &<a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a>, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: &Venue) {
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_is_whitelisted">venue::assert_is_whitelisted</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);
    <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_assert_certificate">assert_certificate</a>(certificate, <a href="_id">object::id</a>(<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>));
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_assert_certificate"></a>

## Function `assert_certificate`

Assert <code><a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a></code> parameters


<a name="@Panics_4"></a>

###### Panics


Panics if <code><a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a></code> parameters don't match


<pre><code><b>public</b> <b>fun</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_assert_certificate">assert_certificate</a>(certificate: &<a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">market_whitelist::Certificate</a>, venue_id: <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_assert_certificate">assert_certificate</a>(certificate: &<a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_Certificate">Certificate</a>, venue_id: ID) {
    <b>assert</b>!(certificate.venue_id == venue_id, <a href="market_whitelist.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_market_whitelist_EINCORRECT_CERTIFICATE">EINCORRECT_CERTIFICATE</a>);
}
</code></pre>



</details>
