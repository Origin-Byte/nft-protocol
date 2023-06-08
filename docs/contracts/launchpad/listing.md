
<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing"></a>

# Module `0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::listing`

Module for an NFT <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>

A <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> allows creators to sell their NFTs to the primary market using
bespoke market primitives, such as <code>FixedPriceMarket</code> and
<code>DutchAuctionMarket</code>.
<code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> can be standalone or be attached to <code>Marketplace</code>.

Associated <code>Marketplace</code> objects may stipulate a fee policy, the
marketplace admin can decide to create a custom fee policy for each
<code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>.

<code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> may define multiple <code>Inventory</code> objects which themselves can
define multiple markets.
In consequence, each <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> may tier it's sales into different NFT
rarities, but may also want to sell one NFT inventory through different
sales channels.
For example, a creator might want to auction a rare tier of their
collection or provide an instant-buy option for users not wanting to
participate in the auction.
Alternatively, an inventory listing may want to sell NFTs for multiple
fungible tokens.

In essence, <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> is a shared object that provides a safe API to the
underlying inventories which are unprotected.


-  [Resource `Listing`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing)
-  [Resource `RequestToJoin`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_RequestToJoin)
-  [Struct `RequestToJoinDfKey`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_RequestToJoinDfKey)
-  [Struct `CreateListingEvent`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_CreateListingEvent)
-  [Struct `DeleteListingEvent`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_DeleteListingEvent)
-  [Struct `NftSoldEvent`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_NftSoldEvent)
-  [Constants](#@Constants_0)
-  [Function `new`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_new)
-  [Function `init_listing`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_init_listing)
-  [Function `init_venue`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_init_venue)
-  [Function `create_venue`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_create_venue)
-  [Function `init_warehouse`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_init_warehouse)
-  [Function `create_warehouse`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_create_warehouse)
-  [Function `pay`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_pay)
-  [Function `emit_sold_event`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_emit_sold_event)
-  [Function `pay_and_emit_sold_event`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_pay_and_emit_sold_event)
-  [Function `buy_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_buy_nft)
-  [Function `buy_pseudorandom_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_buy_pseudorandom_nft)
-  [Function `buy_random_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_buy_random_nft)
-  [Function `request_to_join_marketplace`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_request_to_join_marketplace)
-  [Function `accept_listing_request`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_accept_listing_request)
-  [Function `add_fee`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_fee)
-  [Function `add_venue`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_venue)
-  [Function `add_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_nft)
-  [Function `add_inventory`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_inventory)
-  [Function `add_warehouse`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_warehouse)
-  [Function `insert_warehouse`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_insert_warehouse)
-  [Function `sale_on`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_on)
-  [Function `sale_off`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_off)
-  [Function `sale_on_delegated`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_on_delegated)
-  [Function `sale_off_delegated`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_off_delegated)
-  [Function `collect_proceeds`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_collect_proceeds)
-  [Function `receiver`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_receiver)
-  [Function `admin`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin)
-  [Function `contains_custom_fee`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_custom_fee)
-  [Function `custom_fee`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_custom_fee)
-  [Function `borrow_proceeds`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_proceeds)
-  [Function `borrow_proceeds_mut`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_proceeds_mut)
-  [Function `contains_venue`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_venue)
-  [Function `borrow_venue`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue)
-  [Function `borrow_venue_mut`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue_mut)
-  [Function `venue_internal_mut`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_venue_internal_mut)
-  [Function `market_internal_mut`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_market_internal_mut)
-  [Function `remove_venue`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_remove_venue)
-  [Function `contains_inventory`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_inventory)
-  [Function `borrow_inventory`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_inventory)
-  [Function `borrow_inventory_mut`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_inventory_mut)
-  [Function `inventory_internal_mut`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_internal_mut)
-  [Function `supply`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_supply)
-  [Function `inventory_admin_mut`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_admin_mut)
-  [Function `admin_redeem_nft`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft)
-  [Function `admin_redeem_nft_and_transfer`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_and_transfer)
-  [Function `admin_redeem_nft_to_kiosk`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_to_kiosk)
-  [Function `admin_redeem_nft_to_new_kiosk`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_to_new_kiosk)
-  [Function `admin_redeem_nft_with_id`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id)
-  [Function `admin_redeem_nft_with_id_and_transfer`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id_and_transfer)
-  [Function `admin_redeem_nft_with_id_to_kiosk`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id_to_kiosk)
-  [Function `admin_redeem_nft_with_id_to_new_kiosk`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id_to_new_kiosk)
-  [Function `assert_listing_marketplace_match`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_marketplace_match)
-  [Function `assert_listing_admin`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin)
-  [Function `assert_correct_admin`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_correct_admin)
-  [Function `assert_default_fee`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_default_fee)
-  [Function `assert_venue`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_venue)
-  [Function `assert_inventory`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_inventory)
-  [Function `assert_version`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version)
-  [Function `migrate`](#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_migrate)


<pre><code><b>use</b> <a href="">0x1::ascii</a>;
<b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::type_name</a>;
<b>use</b> <a href="">0x2::balance</a>;
<b>use</b> <a href="">0x2::dynamic_object_field</a>;
<b>use</b> <a href="">0x2::event</a>;
<b>use</b> <a href="">0x2::kiosk</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::object_bag</a>;
<b>use</b> <a href="">0x2::object_table</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk</a>;
<b>use</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::inventory</a>;
<b>use</b> <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::marketplace</a>;
<b>use</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::proceeds</a>;
<b>use</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::venue</a>;
<b>use</b> <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b::warehouse</a>;
<b>use</b> <a href="">0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::object_box</a>;
<b>use</b> <a href="">0xed6c6fe0732be937f4379bc0b471f0f6bfbe0e8741968009e0f01e6de3d59f32::typed_id</a>;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing"></a>

## Resource `Listing`



<pre><code><b>struct</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a> <b>has</b> store, key
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
<code>marketplace_id: <a href="_Option">option::Option</a>&lt;<a href="_TypedID">typed_id::TypedID</a>&lt;<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>&gt;&gt;</code>
</dt>
<dd>
 The ID of the marketplace if any
</dd>
<dt>
<code>admin: <b>address</b></code>
</dt>
<dd>
 The address of the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> administrator
</dd>
<dt>
<code>receiver: <b>address</b></code>
</dt>
<dd>
 The address of the receiver of funds
</dd>
<dt>
<code><a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">proceeds::Proceeds</a></code>
</dt>
<dd>
 Proceeds object holds the balance of fungible tokens acquired from
 the sale of the listing
</dd>
<dt>
<code>venues: <a href="_ObjectTable">object_table::ObjectTable</a>&lt;<a href="_ID">object::ID</a>, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>&gt;</code>
</dt>
<dd>
 Main object that holds all venues part of the listing
</dd>
<dt>
<code>inventories: <a href="_ObjectBag">object_bag::ObjectBag</a></code>
</dt>
<dd>
 Main object that holds all inventories part of the listing
</dd>
<dt>
<code>custom_fee: <a href="_ObjectBox">object_box::ObjectBox</a></code>
</dt>
<dd>
 Field with Object Box holding a Custom Fee implementation if any.
 In case this box is empty the calculation will applied on the
 default fee object in the associated Marketplace
</dd>
</dl>


</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_RequestToJoin"></a>

## Resource `RequestToJoin`

An ephemeral object representing the intention of a <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> admin
to join a given Marketplace.


<pre><code><b>struct</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_RequestToJoin">RequestToJoin</a> <b>has</b> store, key
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
<code>marketplace_id: <a href="_TypedID">typed_id::TypedID</a>&lt;<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_RequestToJoinDfKey"></a>

## Struct `RequestToJoinDfKey`



<pre><code><b>struct</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_RequestToJoinDfKey">RequestToJoinDfKey</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_CreateListingEvent"></a>

## Struct `CreateListingEvent`

Event signalling that a <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> was created


<pre><code><b>struct</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_CreateListingEvent">CreateListingEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>listing_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_DeleteListingEvent"></a>

## Struct `DeleteListingEvent`

Event signalling that a <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> was deleted


<pre><code><b>struct</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_DeleteListingEvent">DeleteListingEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>listing_id: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_NftSoldEvent"></a>

## Struct `NftSoldEvent`

Event signalling that <code>Nft</code> was sold by <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>


<pre><code><b>struct</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_NftSoldEvent">NftSoldEvent</a> <b>has</b> <b>copy</b>, drop
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
<code>price: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>ft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>nft_type: <a href="_String">ascii::String</a></code>
</dt>
<dd>

</dd>
<dt>
<code>buyer: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_ENotUpgraded"></a>



<pre><code><b>const</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_ENotUpgraded">ENotUpgraded</a>: u64 = 999;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EWrongVersion"></a>



<pre><code><b>const</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EWrongVersion">EWrongVersion</a>: u64 = 1000;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_VERSION"></a>



<pre><code><b>const</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_VERSION">VERSION</a>: u64 = 1;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EActionExclusiveToStandaloneListing"></a>



<pre><code><b>const</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EActionExclusiveToStandaloneListing">EActionExclusiveToStandaloneListing</a>: u64 = 8;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EHasCustomFeePolicy"></a>



<pre><code><b>const</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EHasCustomFeePolicy">EHasCustomFeePolicy</a>: u64 = 9;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EListingAlreadyAttached"></a>



<pre><code><b>const</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EListingAlreadyAttached">EListingAlreadyAttached</a>: u64 = 6;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EListingHasNotApplied"></a>



<pre><code><b>const</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EListingHasNotApplied">EListingHasNotApplied</a>: u64 = 7;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EMarketplaceListingMismatch"></a>



<pre><code><b>const</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EMarketplaceListingMismatch">EMarketplaceListingMismatch</a>: u64 = 5;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EUndefinedInventory"></a>

<code>Warehouse</code> was not defined on <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>

Initialize <code>Warehouse</code> using <code>Listing::init_warehouse</code> or insert one
using <code>Listing::add_warehouse</code>.


<pre><code><b>const</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EUndefinedInventory">EUndefinedInventory</a>: u64 = 2;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EUndefinedVenue"></a>

<code>Venue</code> was not defined on <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>

Call <code>Listing::init_venue</code> to initialize a <code>Venue</code>


<pre><code><b>const</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EUndefinedVenue">EUndefinedVenue</a>: u64 = 1;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EWrongAdmin"></a>

Transaction sender was not <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> admin when calling protected
endpoint


<pre><code><b>const</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EWrongAdmin">EWrongAdmin</a>: u64 = 3;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EWrongListingOrMarketplaceAdmin"></a>



<pre><code><b>const</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EWrongListingOrMarketplaceAdmin">EWrongListingOrMarketplaceAdmin</a>: u64 = 4;
</code></pre>



<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_new"></a>

## Function `new`

Initialises a <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> object and returns it.


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_new">new</a>(listing_admin: <b>address</b>, receiver: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_new">new</a>(
    listing_admin: <b>address</b>,
    receiver: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
): <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a> {
    <b>let</b> id = <a href="_new">object::new</a>(ctx);

    <a href="_emit">event::emit</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_CreateListingEvent">CreateListingEvent</a> {
        listing_id: <a href="_uid_to_inner">object::uid_to_inner</a>(&id),
    });

    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a> {
        id,
        version: <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_VERSION">VERSION</a>,
        marketplace_id: <a href="_none">option::none</a>(),
        admin: listing_admin,
        receiver,
        <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>: <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_empty">proceeds::empty</a>(ctx),
        venues: <a href="_new">object_table::new</a>(ctx),
        inventories: <a href="_new">object_bag::new</a>(ctx),
        custom_fee: obox::empty(ctx),
    }
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_init_listing"></a>

## Function `init_listing`

Initialises a standalone <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> object.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_init_listing">init_listing</a>(listing_admin: <b>address</b>, receiver: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_init_listing">init_listing</a>(
    listing_admin: <b>address</b>,
    receiver: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_new">new</a>(
        listing_admin,
        receiver,
        ctx,
    );

    <a href="_public_share_object">transfer::public_share_object</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_init_venue"></a>

## Function `init_venue`

Initializes a <code>Venue</code> on <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>


<a name="@Panics_1"></a>

###### Panics


Panics if transaction sender is not listing admin.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_init_venue">init_venue</a>&lt;Market: store, MarketKey: <b>copy</b>, drop, store&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, key: MarketKey, market: Market, is_whitelisted: bool, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_init_venue">init_venue</a>&lt;Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    key: MarketKey,
    market: Market,
    is_whitelisted: bool,
    ctx: &<b>mut</b> TxContext,
) {
    // Version asserted in `create_venue`
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_create_venue">create_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, key, market, is_whitelisted, ctx);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_create_venue"></a>

## Function `create_venue`

Creates a <code>Venue</code> on <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> and returns it's ID


<a name="@Panics_2"></a>

###### Panics


Panics if transaction sender is not listing admin.


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_create_venue">create_venue</a>&lt;Market: store, MarketKey: <b>copy</b>, drop, store&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, key: MarketKey, market: Market, is_whitelisted: bool, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_create_venue">create_venue</a>&lt;Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    key: MarketKey,
    market: Market,
    is_whitelisted: bool,
    ctx: &<b>mut</b> TxContext,
): ID {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);

    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a> = <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_new">venue::new</a>(key, market, is_whitelisted, ctx);
    <b>let</b> venue_id = <a href="_id">object::id</a>(&<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_venue">add_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>, ctx);
    venue_id
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_init_warehouse"></a>

## Function `init_warehouse`

Initializes an empty <code>Warehouse</code> on <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>

Requires that transaction sender is collection creator registered in
<code>CreatorsDomain</code>.


<a name="@Panics_3"></a>

###### Panics


Panics if transaction sender is not listing admin or creator.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_init_warehouse">init_warehouse</a>&lt;T: store, key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_init_warehouse">init_warehouse</a>&lt;T: key + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_create_warehouse">create_warehouse</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_create_warehouse"></a>

## Function `create_warehouse`

Creates an empty <code>Warehouse</code> on <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> and returns it's ID

Function transparently wraps <code>Warehouse</code> in <code>Inventory</code>, therefore, the
returned ID is that of the <code>Inventory</code> not the <code>Warehouse</code>.


<a name="@Panics_4"></a>

###### Panics


Panics if transaction sender is not listing admin.


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_create_warehouse">create_warehouse</a>&lt;T: store, key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_create_warehouse">create_warehouse</a>&lt;T: key + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    ctx: &<b>mut</b> TxContext,
): ID {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);

    <b>let</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a> = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_from_warehouse">inventory::from_warehouse</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_new">warehouse::new</a>&lt;T&gt;(ctx), ctx);
    <b>let</b> inventory_id = <a href="_id">object::id</a>(&<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_inventory">add_inventory</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>, ctx);
    inventory_id
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_pay"></a>

## Function `pay`

Pay for <code>Nft</code> sale and direct funds to <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> proceeds


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_pay">pay</a>&lt;FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, <a href="">balance</a>: <a href="_Balance">balance::Balance</a>&lt;FT&gt;, quantity: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_pay">pay</a>&lt;FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    <a href="">balance</a>: Balance&lt;FT&gt;,
    quantity: u64,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);

    <b>let</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_proceeds_mut">borrow_proceeds_mut</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_add">proceeds::add</a>(<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>, <a href="">balance</a>, quantity);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_emit_sold_event"></a>

## Function `emit_sold_event`

Emits <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_NftSoldEvent">NftSoldEvent</a></code> for provided <code>Nft</code>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_emit_sold_event">emit_sold_event</a>&lt;FT, T: key&gt;(nft: &T, price: u64, buyer: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_emit_sold_event">emit_sold_event</a>&lt;FT, T: key&gt;(
    nft: &T,
    price: u64,
    buyer: <b>address</b>,
) {
    <a href="_emit">event::emit</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_NftSoldEvent">NftSoldEvent</a> {
        nft: <a href="_id">object::id</a>(nft),
        price,
        ft_type: *<a href="_borrow_string">type_name::borrow_string</a>(&<a href="_get">type_name::get</a>&lt;FT&gt;()),
        nft_type: *<a href="_borrow_string">type_name::borrow_string</a>(&<a href="_get">type_name::get</a>&lt;T&gt;()),
        buyer,
    });
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_pay_and_emit_sold_event"></a>

## Function `pay_and_emit_sold_event`

Pay for <code>Nft</code> sale, direct fund to <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> proceeds, and emit sale
events.

Will charge <code>price</code> from the provided <code>Balance</code> object.


<a name="@Panics_5"></a>

###### Panics


Panics if balance is not enough to fund price


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_pay_and_emit_sold_event">pay_and_emit_sold_event</a>&lt;FT, T: key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, nft: &T, funds: <a href="_Balance">balance::Balance</a>&lt;FT&gt;, buyer: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_pay_and_emit_sold_event">pay_and_emit_sold_event</a>&lt;FT, T: key&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    nft: &T,
    funds: Balance&lt;FT&gt;,
    buyer: <b>address</b>,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);

    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_emit_sold_event">emit_sold_event</a>&lt;FT, T&gt;(nft, <a href="_value">balance::value</a>(&funds), buyer);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_pay">pay</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, funds, 1);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_buy_nft"></a>

## Function `buy_nft`

Buys an NFT from an <code>Inventory</code>

Only venues registered on the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> have authorization to withdraw
from an <code>Inventory</code>, therefore this operation must be authorized using
a witness that corresponds to the market contract.

Endpoint will redeem NFTs sequentially, if you need random withdrawal
use <code>buy_pseudorandom_nft</code> or <code>buy_random_nft</code>.


<a name="@Panics_6"></a>

###### Panics


- <code>Market</code> type does not correspond to <code>venue_id</code> on the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>
- No supply is available from underlying <code>Inventory</code>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_buy_nft">buy_nft</a>&lt;T: store, key, FT, Market: store, MarketKey: <b>copy</b>, drop, store&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, key: MarketKey, inventory_id: <a href="_ID">object::ID</a>, venue_id: <a href="_ID">object::ID</a>, buyer: <b>address</b>, funds: <a href="_Balance">balance::Balance</a>&lt;FT&gt;): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_buy_nft">buy_nft</a>&lt;T: key + store, FT, Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    key: MarketKey,
    inventory_id: ID,
    venue_id: ID,
    buyer: <b>address</b>,
    funds: Balance&lt;FT&gt;,
): T {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);

    <b>let</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_internal_mut">inventory_internal_mut</a>&lt;T, Market, MarketKey&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, key, venue_id, inventory_id,
    );
    <b>let</b> nft = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft">inventory::redeem_nft</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_pay_and_emit_sold_event">pay_and_emit_sold_event</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, &nft, funds, buyer);
    nft
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_buy_pseudorandom_nft"></a>

## Function `buy_pseudorandom_nft`

Buys a pseudo-random NFT from an <code>Inventory</code>

Only venues registered on the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> have authorization to withdraw
from an <code>Inventory</code>, therefore this operation must be authorized using
a witness that corresponds to the market contract.

Endpoint is susceptible to validator prediction of the resulting index,
use <code>buy_random_nft</code> instead.


<a name="@Panics_7"></a>

###### Panics


- <code>Market</code> type does not correspond to <code>venue_id</code> on the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>
- Underlying <code>Inventory</code> is not a <code>Warehouse</code> and there is no supply


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_buy_pseudorandom_nft">buy_pseudorandom_nft</a>&lt;T: store, key, FT, Market: store, MarketKey: <b>copy</b>, drop, store&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, key: MarketKey, inventory_id: <a href="_ID">object::ID</a>, venue_id: <a href="_ID">object::ID</a>, buyer: <b>address</b>, funds: <a href="_Balance">balance::Balance</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_buy_pseudorandom_nft">buy_pseudorandom_nft</a>&lt;T: key + store, FT, Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    key: MarketKey,
    inventory_id: ID,
    venue_id: ID,
    buyer: <b>address</b>,
    funds: Balance&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): T {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);

    <b>let</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_internal_mut">inventory_internal_mut</a>&lt;T, Market, MarketKey&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, key, venue_id, inventory_id,
    );
    <b>let</b> nft = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_pseudorandom_nft">inventory::redeem_pseudorandom_nft</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>, ctx);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_pay_and_emit_sold_event">pay_and_emit_sold_event</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, &nft, funds, buyer);
    nft
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_buy_random_nft"></a>

## Function `buy_random_nft`

Buys a random NFT from <code>Inventory</code>

Requires a <code>RedeemCommitment</code> created by the user in a separate
transaction to ensure that validators may not bias results favorably.
You can obtain a <code>RedeemCommitment</code> by calling
<code><a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_init_redeem_commitment">warehouse::init_redeem_commitment</a></code>.

Only venues registered on the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> have authorization to withdraw
from an <code>Inventory</code>, therefore this operation must be authorized using
a witness that corresponds to the market contract.


<a name="@Panics_8"></a>

###### Panics


- <code>Market</code> type does not correspond to <code>venue_id</code> on the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>
- Underlying <code>Inventory</code> is not a <code>Warehouse</code> and there is no supply
- <code>user_commitment</code> does not match the hashed commitment in
<code>RedeemCommitment</code>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_buy_random_nft">buy_random_nft</a>&lt;T: store, key, FT, Market: store, MarketKey: <b>copy</b>, drop, store&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, key: MarketKey, commitment: <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_RedeemCommitment">warehouse::RedeemCommitment</a>, user_commitment: <a href="">vector</a>&lt;u8&gt;, inventory_id: <a href="_ID">object::ID</a>, venue_id: <a href="_ID">object::ID</a>, buyer: <b>address</b>, funds: <a href="_Balance">balance::Balance</a>&lt;FT&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_buy_random_nft">buy_random_nft</a>&lt;T: key + store, FT, Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    key: MarketKey,
    commitment: RedeemCommitment,
    user_commitment: <a href="">vector</a>&lt;u8&gt;,
    inventory_id: ID,
    venue_id: ID,
    buyer: <b>address</b>,
    funds: Balance&lt;FT&gt;,
    ctx: &<b>mut</b> TxContext,
): T {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);

    <b>let</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_internal_mut">inventory_internal_mut</a>&lt;T, Market, MarketKey&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, key, venue_id, inventory_id,
    );
    <b>let</b> nft = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_random_nft">inventory::redeem_random_nft</a>(
        <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>, commitment, user_commitment, ctx,
    );
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_pay_and_emit_sold_event">pay_and_emit_sold_event</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, &nft, funds, buyer);
    nft
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_request_to_join_marketplace"></a>

## Function `request_to_join_marketplace`

To be called by the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> administrator, to declare the intention
of joining a Marketplace. This is the first step to join a marketplace.
Joining a <code>Marketplace</code> is a two step process in which both the
<code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> admin and the <code>Marketplace</code> admin need to declare their
intention to partner up.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_request_to_join_marketplace">request_to_join_marketplace</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_request_to_join_marketplace">request_to_join_marketplace</a>(
    <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &Marketplace,
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    ctx: &<b>mut</b> TxContext,
) {
    mkt::assert_version(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);

    <b>assert</b>!(
        <a href="_is_none">option::is_none</a>(&<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.marketplace_id),
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EListingAlreadyAttached">EListingAlreadyAttached</a>,
    );

    <b>let</b> marketplace_id = <a href="_new">typed_id::new</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>);

    <b>let</b> <a href="">request</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_RequestToJoin">RequestToJoin</a> {
        id: <a href="_new">object::new</a>(ctx),
        marketplace_id,
    };

    dof::add(
        &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.id, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_RequestToJoinDfKey">RequestToJoinDfKey</a> {}, <a href="">request</a>
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_accept_listing_request"></a>

## Function `accept_listing_request`

To be called by the <code>Marketplace</code> administrator, to accept the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>
request to join. This is the second step to join a marketplace.
Joining a <code>Marketplace</code> is a two step process in which both the
<code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> admin and the <code>Marketplace</code> admin need to declare their
intention to partner up.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_accept_listing_request">accept_listing_request</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_accept_listing_request">accept_listing_request</a>(
    <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &Marketplace,
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    ctx: &<b>mut</b> TxContext,
) {
    mkt::assert_version(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    mkt::assert_marketplace_admin(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>, ctx);

    <b>assert</b>!(
        <a href="_is_none">option::is_none</a>(&<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.marketplace_id),
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EListingAlreadyAttached">EListingAlreadyAttached</a>,
    );

    <b>let</b> marketplace_id = <a href="_new">typed_id::new</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>);

    <b>let</b> <a href="">request</a> = dof::remove&lt;<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_RequestToJoinDfKey">RequestToJoinDfKey</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_RequestToJoin">RequestToJoin</a>&gt;(
        &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.id, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_RequestToJoinDfKey">RequestToJoinDfKey</a> {}
    );

    <b>assert</b>!(
        marketplace_id == <a href="">request</a>.marketplace_id,
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EListingHasNotApplied">EListingHasNotApplied</a>,
    );

    <b>let</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_RequestToJoin">RequestToJoin</a> {
        id, marketplace_id: _,
    } = <a href="">request</a>;
    <a href="_delete">object::delete</a>(id);

    <a href="_fill">option::fill</a>(&<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.marketplace_id, marketplace_id);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_fee"></a>

## Function `add_fee`

Adds a fee object to the Listing's <code>custom_fee</code>

This function should be called by the marketplace.
If there the listing is not attached to a marketplace
then if does not make sense to pay fees.

Can only be called by the <code>Marketplace</code> admin


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_fee">add_fee</a>&lt;FeeType: store, key&gt;(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, fee: FeeType, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_fee">add_fee</a>&lt;FeeType: key + store&gt;(
    <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &Marketplace,
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    fee: FeeType,
    ctx: &<b>mut</b> TxContext,
) {
    mkt::assert_version(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);

    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_marketplace_match">assert_listing_marketplace_match</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    mkt::assert_marketplace_admin(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>, ctx);

    obox::add&lt;FeeType&gt;(&<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.custom_fee, fee);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_venue"></a>

## Function `add_venue`

Adds a <code>Venue</code> to the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>


<a name="@Panics_9"></a>

###### Panics


Panics if inventory that <code>Venue</code> is assigned to does not exist or if
transaction sender is not the listing admin.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_venue">add_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_venue">add_venue</a>(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>: Venue,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);

    <a href="_add">object_table::add</a>(
        &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.venues,
        <a href="_id">object::id</a>(&<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>),
        <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>,
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_nft"></a>

## Function `add_nft`

Adds an <code>Nft</code> to a <code>Warehouse</code> on the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>

To avoid shared consensus during mass minting, <code>Warehouse</code> can be
constructed as a private object and later inserted into the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>.


<a name="@Panics_10"></a>

###### Panics


- <code>Inventory</code> with the given ID does not exist
- <code>Inventory</code> with the given ID is not a <code>Warehouse</code>
- Transaction sender is not the listing admin


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_nft">add_nft</a>&lt;T: store, key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>, nft: T, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_nft">add_nft</a>&lt;T: key + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    inventory_id: ID,
    nft: T,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);

    <b>let</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_inventory_mut">borrow_inventory_mut</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id);
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_deposit_nft">inventory::deposit_nft</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>, nft);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_inventory"></a>

## Function `add_inventory`

Adds <code>Inventory</code> to <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>

<code>Inventory</code> is a type-erased wrapper around <code>Warehouse</code>.

To create a new inventory call <code><a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_from_warehouse">inventory::from_warehouse</a></code> or
<code>inventory::from_factory</code>.


<a name="@Panics_11"></a>

###### Panics


Panics if transaction sender is not the listing admin


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_inventory">add_inventory</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_inventory">add_inventory</a>&lt;T&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>: Inventory&lt;T&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);

    <b>let</b> inventory_id = <a href="_id">object::id</a>(&<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    <a href="_add">object_bag::add</a>(&<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.inventories, inventory_id, <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_warehouse"></a>

## Function `add_warehouse`

Adds <code>Warehouse</code> to <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>

Function transparently wraps <code>Warehouse</code> in <code>Inventory</code>, therefore, the
returned ID is that of the <code>Inventory</code> not the <code>Warehouse</code>.


<a name="@Panics_12"></a>

###### Panics


Panics if transaction sender is not listing admin or creator registered
in <code>CreatorsDomain</code>.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_warehouse">add_warehouse</a>&lt;T: store, key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_warehouse">add_warehouse</a>&lt;T: key + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: Warehouse&lt;T&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    // We are asserting that the caller is the <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a> admin in
    // the call `add_inventory`

    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_insert_warehouse">insert_warehouse</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, ctx);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_insert_warehouse"></a>

## Function `insert_warehouse`

Adds <code>Warehouse</code> to <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> and returns it's ID

Function transparently wraps <code>Warehouse</code> in <code>Inventory</code>, therefore, the
returned ID is that of the <code>Inventory</code> not the <code>Warehouse</code>.


<a name="@Panics_13"></a>

###### Panics


Panics if transaction sender is not listing admin.


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_insert_warehouse">insert_warehouse</a>&lt;T: store, key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse_Warehouse">warehouse::Warehouse</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_insert_warehouse">insert_warehouse</a>&lt;T: key + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    <a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>: Warehouse&lt;T&gt;,
    ctx: &<b>mut</b> TxContext,
): ID {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    // We are asserting that the caller is the <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a> admin in
    // the call `add_inventory`

    <b>let</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a> = <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_from_warehouse">inventory::from_warehouse</a>(<a href="warehouse.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_warehouse">warehouse</a>, ctx);
    <b>let</b> inventory_id = <a href="_id">object::id</a>(&<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_add_inventory">add_inventory</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>, ctx);
    inventory_id
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_on"></a>

## Function `sale_on`

Set market's live status to <code><b>true</b></code> therefore making the NFT sale live.
To be called by the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> admin.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_on">sale_on</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_on">sale_on</a>(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    venue_id: ID,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_set_live">venue::set_live</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue_mut">borrow_venue_mut</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id), <b>true</b>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_off"></a>

## Function `sale_off`

Set market's live status to <code><b>false</b></code> therefore pausing or stopping the
NFT sale. To be called by the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> admin.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_off">sale_off</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_off">sale_off</a>(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    venue_id: ID,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_set_live">venue::set_live</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue_mut">borrow_venue_mut</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id), <b>false</b>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_on_delegated"></a>

## Function `sale_on_delegated`

Set market's live status to <code><b>true</b></code> therefore making the NFT sale live.
To be called by the <code>Marketplace</code> admin.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_on_delegated">sale_on_delegated</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_on_delegated">sale_on_delegated</a>(
    <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &Marketplace,
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    venue_id: ID,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_marketplace_match">assert_listing_marketplace_match</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    mkt::assert_version(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>);
    mkt::assert_marketplace_admin(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>, ctx);

    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_set_live">venue::set_live</a>(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue_mut">borrow_venue_mut</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id),
        <b>true</b>,
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_off_delegated"></a>

## Function `sale_off_delegated`

Set market's live status to <code><b>false</b></code> therefore pausing or stopping the
NFT sale. To be called by the <code>Marketplace</code> admin.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_off_delegated">sale_off_delegated</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_sale_off_delegated">sale_off_delegated</a>(
    <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &Marketplace,
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    venue_id: ID,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_marketplace_match">assert_listing_marketplace_match</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    mkt::assert_version(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>);
    mkt::assert_marketplace_admin(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>, ctx);

    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_set_live">venue::set_live</a>(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue_mut">borrow_venue_mut</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id),
        <b>false</b>,
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_collect_proceeds"></a>

## Function `collect_proceeds`

Collect proceeds and fees from standalone listing

Requires that caller is listing admin in order to protect against
rugpulls.


<a name="@Panics_14"></a>

###### Panics


Panics if <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> was attached to the <code>Marketplace</code>.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_collect_proceeds">collect_proceeds</a>&lt;FT&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_collect_proceeds">collect_proceeds</a>&lt;FT&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);

    <b>assert</b>!(
        <a href="_is_none">option::is_none</a>(&<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.marketplace_id),
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EActionExclusiveToStandaloneListing">EActionExclusiveToStandaloneListing</a>,
    );

    <b>let</b> receiver = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.receiver;

    <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_collect_without_fees">proceeds::collect_without_fees</a>&lt;FT&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_proceeds_mut">borrow_proceeds_mut</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>),
        receiver,
        ctx,
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_receiver"></a>

## Function `receiver`

Get the Listing's <code>receiver</code> address


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_receiver">receiver</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_receiver">receiver</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>): <b>address</b> {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.receiver
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin"></a>

## Function `admin`

Get the Listing's <code>admin</code> address


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin">admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin">admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>): <b>address</b> {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.admin
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_custom_fee"></a>

## Function `contains_custom_fee`



<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_custom_fee">contains_custom_fee</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_custom_fee">contains_custom_fee</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>): bool {
    !obox::is_empty(&<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.custom_fee)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_custom_fee"></a>

## Function `custom_fee`



<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_custom_fee">custom_fee</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>): &<a href="_ObjectBox">object_box::ObjectBox</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_custom_fee">custom_fee</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>): &ObjectBox {
    &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.custom_fee
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_proceeds"></a>

## Function `borrow_proceeds`

Borrow the Listing's <code>Proceeds</code>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_proceeds">borrow_proceeds</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>): &<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">proceeds::Proceeds</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_proceeds">borrow_proceeds</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>): &Proceeds {
    &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_proceeds_mut"></a>

## Function `borrow_proceeds_mut`

Mutably borrow the Listing's <code>Proceeds</code>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_proceeds_mut">borrow_proceeds_mut</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>): &<b>mut</b> <a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds_Proceeds">proceeds::Proceeds</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_proceeds_mut">borrow_proceeds_mut</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>): &<b>mut</b> Proceeds {
    &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.<a href="proceeds.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_proceeds">proceeds</a>
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_venue"></a>

## Function `contains_venue`

Returns whether <code>Venue</code> with given ID exists


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_venue">contains_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_venue">contains_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>, venue_id: ID): bool {
    <a href="_contains">object_table::contains</a>(&<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.venues, venue_id)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue"></a>

## Function `borrow_venue`

Borrow the listing's <code>Venue</code>


<a name="@Panics_15"></a>

###### Panics


Panics if <code>Venue</code> does not exist.


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue">borrow_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>): &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue">borrow_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>, venue_id: ID): &Venue {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_venue">assert_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id);
    <a href="_borrow">object_table::borrow</a>(&<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.venues, venue_id)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue_mut"></a>

## Function `borrow_venue_mut`

Mutably borrow the listing's <code>Venue</code>


<a name="@Panics_16"></a>

###### Panics


Panics if <code>Venue</code> does not exist.


<pre><code><b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue_mut">borrow_venue_mut</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>): &<b>mut</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue_mut">borrow_venue_mut</a>(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    venue_id: ID,
): &<b>mut</b> Venue {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_venue">assert_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id);
    <a href="_borrow_mut">object_table::borrow_mut</a>(&<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.venues, venue_id)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_venue_internal_mut"></a>

## Function `venue_internal_mut`

Mutably borrow the listing's <code>Venue</code>

<code>Venue</code> and inventories are unprotected therefore only market modules
registered on a <code>Venue</code> can gain mutable access to it.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_venue_internal_mut">venue_internal_mut</a>&lt;Market: store, MarketKey: <b>copy</b>, drop, store&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, key: MarketKey, venue_id: <a href="_ID">object::ID</a>): &<b>mut</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_venue_internal_mut">venue_internal_mut</a>&lt;Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    key: MarketKey,
    venue_id: ID,
): &<b>mut</b> Venue {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_venue_mut">borrow_venue_mut</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_market">venue::assert_market</a>&lt;Market, MarketKey&gt;(key, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);

    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_market_internal_mut"></a>

## Function `market_internal_mut`

Mutably borrow the Listing's <code>Market</code>

<code>Market</code> is unprotected therefore only market modules registered
on a <code>Venue</code> can gain mutable access to it.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_market_internal_mut">market_internal_mut</a>&lt;Market: store, MarketKey: <b>copy</b>, drop, store&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, key: MarketKey, venue_id: <a href="_ID">object::ID</a>): &<b>mut</b> Market
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_market_internal_mut">market_internal_mut</a>&lt;Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    key: MarketKey,
    venue_id: ID,
): &<b>mut</b> Market {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a> =
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_venue_internal_mut">venue_internal_mut</a>&lt;Market, MarketKey&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, key, venue_id);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_borrow_market_mut">venue::borrow_market_mut</a>(key, <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_remove_venue"></a>

## Function `remove_venue`

Remove venue from <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>


<a name="@Panics_17"></a>

###### Panics


Panics if the <code>Venue</code> did not exist or delegated witness did not match
the market being removed.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_remove_venue">remove_venue</a>&lt;Market: store, MarketKey: <b>copy</b>, drop, store&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, key: MarketKey, venue_id: <a href="_ID">object::ID</a>): <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_Venue">venue::Venue</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_remove_venue">remove_venue</a>&lt;Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    key: MarketKey,
    venue_id: ID,
): Venue {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <b>let</b> <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a> = <a href="_remove">object_table::remove</a>(&<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.venues, venue_id);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue_assert_market">venue::assert_market</a>&lt;Market, MarketKey&gt;(key, &<a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>);
    <a href="venue.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_venue">venue</a>
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_inventory"></a>

## Function `contains_inventory`

Returns whether <code>Inventory</code> with given ID exists


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_inventory">contains_inventory</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_inventory">contains_inventory</a>&lt;T&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    inventory_id: ID,
): bool {
    <a href="_contains_with_type">object_bag::contains_with_type</a>&lt;ID, Inventory&lt;T&gt;&gt;(
        &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.inventories,
        inventory_id,
    )
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_inventory"></a>

## Function `borrow_inventory`

Borrow the listing's <code>Inventory</code>


<a name="@Panics_18"></a>

###### Panics


Panics if <code>Inventory</code> does not exist.


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_inventory">borrow_inventory</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>): &<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_inventory">borrow_inventory</a>&lt;T&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    inventory_id: ID,
): &Inventory&lt;T&gt; {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_inventory">assert_inventory</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id);
    <a href="_borrow">object_bag::borrow</a>(&<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.inventories, inventory_id)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_inventory_mut"></a>

## Function `borrow_inventory_mut`

Mutably borrow the listing's <code>Inventory</code>


<a name="@Panics_19"></a>

###### Panics


Panics if <code>Inventory</code> does not exist.


<pre><code><b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_inventory_mut">borrow_inventory_mut</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>): &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_inventory_mut">borrow_inventory_mut</a>&lt;T&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    inventory_id: ID,
): &<b>mut</b> Inventory&lt;T&gt; {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_inventory">assert_inventory</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id);
    <a href="_borrow_mut">object_bag::borrow_mut</a>(&<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.inventories, inventory_id)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_internal_mut"></a>

## Function `inventory_internal_mut`

Mutably borrow an <code>Inventory</code>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_internal_mut">inventory_internal_mut</a>&lt;T, Market: store, MarketKey: <b>copy</b>, drop, store&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, key: MarketKey, venue_id: <a href="_ID">object::ID</a>, inventory_id: <a href="_ID">object::ID</a>): &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_internal_mut">inventory_internal_mut</a>&lt;T, Market: store, MarketKey: <b>copy</b> + drop + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    key: MarketKey,
    venue_id: ID,
    inventory_id: ID,
): &<b>mut</b> Inventory&lt;T&gt; {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_venue_internal_mut">venue_internal_mut</a>&lt;Market, MarketKey&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, key, venue_id);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_inventory_mut">borrow_inventory_mut</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_supply"></a>

## Function `supply`

Returns how many NFTs can be withdrawn

Returns none if the supply is uncapped


<a name="@Panics_20"></a>

###### Panics


Panics if <code>Warehouse</code> or <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> with the ID does not exist


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_supply">supply</a>&lt;T: store, key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>): <a href="_Option">option::Option</a>&lt;u64&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_supply">supply</a>&lt;T: key + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    inventory_id: ID,
): Option&lt;u64&gt; {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_inventory">assert_inventory</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id);

    <b>let</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_inventory">borrow_inventory</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id);
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_supply">inventory::supply</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_admin_mut"></a>

## Function `inventory_admin_mut`

Mutably borrow an <code>Inventory</code>

This call is protected and only the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> administrator can call it


<a name="@Panics_21"></a>

###### Panics


Panics if transaction sender is not an admin or inventory does not exist.


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_admin_mut">inventory_admin_mut</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): &<b>mut</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_Inventory">inventory::Inventory</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_admin_mut">inventory_admin_mut</a>&lt;T&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    inventory_id: ID,
    ctx: &<b>mut</b> TxContext,
): &<b>mut</b> Inventory&lt;T&gt; {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);

    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_borrow_inventory_mut">borrow_inventory_mut</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft"></a>

## Function `admin_redeem_nft`

Redeem NFT from <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code>

This call is protected and only the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> administrator can call
it. Used for business situations when launch strategy is changed during
launches.


<a name="@Panics_22"></a>

###### Panics


Panics if transaction sender is not admin, inventory or NFT does not exist.


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft">admin_redeem_nft</a>&lt;T: store, key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft">admin_redeem_nft</a>&lt;T: key + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    inventory_id: ID,
    ctx: &<b>mut</b> TxContext,
): T {
    <b>let</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_admin_mut">inventory_admin_mut</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id, ctx);
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft">inventory::redeem_nft</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_and_transfer"></a>

## Function `admin_redeem_nft_and_transfer`

Redeem NFT from <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> and send to address

This call is protected and only the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> administrator can call
it. Used for business situations when launch strategy is changed during
launches.


<a name="@Panics_23"></a>

###### Panics


Panics if transaction sender is not admin, inventory or NFT does not exist.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_and_transfer">admin_redeem_nft_and_transfer</a>&lt;T: store, key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>, receiver: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_and_transfer">admin_redeem_nft_and_transfer</a>&lt;T: key + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    inventory_id: ID,
    receiver: <b>address</b>,
    ctx: &<b>mut</b> TxContext
) {
    <b>let</b> nft = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft">admin_redeem_nft</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id, ctx);
    <a href="_public_transfer">transfer::public_transfer</a>(nft, receiver);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_to_kiosk"></a>

## Function `admin_redeem_nft_to_kiosk`

Redeem NFT from <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> and airdrop to <code>Kiosk</code>

This call is protected and only the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> administrator can call
it. Used for business situations when launch strategy is changed during
launches.


<a name="@Panics_24"></a>

###### Panics


Panics if transaction sender is not admin, inventory or NFT does not exist.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_to_kiosk">admin_redeem_nft_to_kiosk</a>&lt;T: store, key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>, receiver: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_to_kiosk">admin_redeem_nft_to_kiosk</a>&lt;T: key + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    inventory_id: ID,
    receiver: &<b>mut</b> Kiosk,
    ctx: &<b>mut</b> TxContext
) {
    <b>let</b> nft = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft">admin_redeem_nft</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id, ctx);
    <a href="_deposit">ob_kiosk::deposit</a>(receiver, nft, ctx);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_to_new_kiosk"></a>

## Function `admin_redeem_nft_to_new_kiosk`

Redeem NFT from <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> and airdrop to new <code>Kiosk</code>

This call is protected and only the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> administrator can call
it. Used for business situations when launch strategy is changed during
launches.


<a name="@Panics_25"></a>

###### Panics


Panics if transaction sender is not admin, inventory or NFT does not exist.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_to_new_kiosk">admin_redeem_nft_to_new_kiosk</a>&lt;T: store, key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>, receiver: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_to_new_kiosk">admin_redeem_nft_to_new_kiosk</a>&lt;T: key + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    inventory_id: ID,
    receiver: <b>address</b>,
    ctx: &<b>mut</b> TxContext
) {
    <b>let</b> nft = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft">admin_redeem_nft</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id, ctx);
    <b>let</b> (<a href="">kiosk</a>, _) = <a href="_new_for_address">ob_kiosk::new_for_address</a>(receiver, ctx);
    <a href="_deposit">ob_kiosk::deposit</a>(&<b>mut</b> <a href="">kiosk</a>, nft, ctx);
    <a href="_public_share_object">transfer::public_share_object</a>(<a href="">kiosk</a>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id"></a>

## Function `admin_redeem_nft_with_id`

Redeem NFT from <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> with ID

This call is protected and only the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> administrator can call
it. Used for business situations when launch strategy is changed during
launches.


<a name="@Panics_26"></a>

###### Panics


Panics if transaction sender is not admin, inventory or NFT does not exist.


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id">admin_redeem_nft_with_id</a>&lt;T: store, key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id">admin_redeem_nft_with_id</a>&lt;T: key + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    inventory_id: ID,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
): T {
    <b>let</b> <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a> = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_inventory_admin_mut">inventory_admin_mut</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id, ctx);
    <a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory_redeem_nft_with_id">inventory::redeem_nft_with_id</a>(<a href="inventory.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_inventory">inventory</a>, nft_id)
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id_and_transfer"></a>

## Function `admin_redeem_nft_with_id_and_transfer`

Redeem NFT from <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> with ID and send to address

This call is protected and only the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> administrator can call
it. Used for business situations when launch strategy is changed during
launches.


<a name="@Panics_27"></a>

###### Panics


Panics if transaction sender is not admin, inventory or NFT does not exist.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id_and_transfer">admin_redeem_nft_with_id_and_transfer</a>&lt;T: store, key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>, nft_id: <a href="_ID">object::ID</a>, receiver: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id_and_transfer">admin_redeem_nft_with_id_and_transfer</a>&lt;T: key + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    inventory_id: ID,
    nft_id: ID,
    receiver: <b>address</b>,
    ctx: &<b>mut</b> TxContext
) {
    <b>let</b> nft = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id">admin_redeem_nft_with_id</a>&lt;T&gt;(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id, nft_id, ctx,
    );
    <a href="_public_transfer">transfer::public_transfer</a>(nft, receiver);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id_to_kiosk"></a>

## Function `admin_redeem_nft_with_id_to_kiosk`

Redeem NFT from <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> and airdrop to <code>Kiosk</code>

This call is protected and only the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> administrator can call
it. Used for business situations when launch strategy is changed during
launches.


<a name="@Panics_28"></a>

###### Panics


Panics if transaction sender is not admin, inventory or NFT does not exist.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id_to_kiosk">admin_redeem_nft_with_id_to_kiosk</a>&lt;T: store, key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>, nft_id: <a href="_ID">object::ID</a>, receiver: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id_to_kiosk">admin_redeem_nft_with_id_to_kiosk</a>&lt;T: key + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    inventory_id: ID,
    nft_id: ID,
    receiver: &<b>mut</b> Kiosk,
    ctx: &<b>mut</b> TxContext
) {
    <b>let</b> nft = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id">admin_redeem_nft_with_id</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id, nft_id, ctx);
    <a href="_deposit">ob_kiosk::deposit</a>(receiver, nft, ctx);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id_to_new_kiosk"></a>

## Function `admin_redeem_nft_with_id_to_new_kiosk`

Redeem NFT from <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> and airdrop to new <code>Kiosk</code>

This call is protected and only the <code><a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a></code> administrator can call
it. Used for business situations when launch strategy is changed during
launches.


<a name="@Panics_29"></a>

###### Panics


Panics if transaction sender is not admin, inventory or NFT does not exist.


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id_to_new_kiosk">admin_redeem_nft_with_id_to_new_kiosk</a>&lt;T: store, key&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>, nft_id: <a href="_ID">object::ID</a>, receiver: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id_to_new_kiosk">admin_redeem_nft_with_id_to_new_kiosk</a>&lt;T: key + store&gt;(
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    inventory_id: ID,
    nft_id: ID,
    receiver: <b>address</b>,
    ctx: &<b>mut</b> TxContext
) {
    <b>let</b> nft = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_admin_redeem_nft_with_id">admin_redeem_nft_with_id</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id, nft_id, ctx);
    <b>let</b> (<a href="">kiosk</a>, _) = <a href="_new_for_address">ob_kiosk::new_for_address</a>(receiver, ctx);
    <a href="_deposit">ob_kiosk::deposit</a>(&<b>mut</b> <a href="">kiosk</a>, nft, ctx);
    <a href="_public_share_object">transfer::public_share_object</a>(<a href="">kiosk</a>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_marketplace_match"></a>

## Function `assert_listing_marketplace_match`



<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_marketplace_match">assert_listing_marketplace_match</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_marketplace_match">assert_listing_marketplace_match</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &Marketplace, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>) {
    <b>assert</b>!(
        <a href="_is_some">option::is_some</a>&lt;TypedID&lt;Marketplace&gt;&gt;(&<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.marketplace_id), <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EMarketplaceListingMismatch">EMarketplaceListingMismatch</a>
    );

    <b>assert</b>!(
        <a href="_id">object::id</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>) == *<a href="_as_id">typed_id::as_id</a>(
            <a href="_borrow">option::borrow</a>&lt;TypedID&lt;Marketplace&gt;&gt;(&<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.marketplace_id)
        ),
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EMarketplaceListingMismatch">EMarketplaceListingMismatch</a>,
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin"></a>

## Function `assert_listing_admin`



<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>, ctx: &<b>mut</b> TxContext) {
    <b>assert</b>!(
        <a href="_sender">tx_context::sender</a>(ctx) == <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.admin, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EWrongAdmin">EWrongAdmin</a>,
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_correct_admin"></a>

## Function `assert_correct_admin`



<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_correct_admin">assert_correct_admin</a>(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace_Marketplace">marketplace::Marketplace</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_correct_admin">assert_correct_admin</a>(
    <a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>: &Marketplace,
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> sender = <a href="_sender">tx_context::sender</a>(ctx);
    <b>let</b> is_listing_admin = sender == <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.admin;
    <b>let</b> is_market_admin = sender == mkt::admin(<a href="marketplace.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_marketplace">marketplace</a>);

    <b>assert</b>!(
        is_listing_admin || is_market_admin,
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EWrongListingOrMarketplaceAdmin">EWrongListingOrMarketplaceAdmin</a>,
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_default_fee"></a>

## Function `assert_default_fee`



<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_default_fee">assert_default_fee</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_default_fee">assert_default_fee</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>) {
    <b>assert</b>!(
        !obox::is_empty(&<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.custom_fee),
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EHasCustomFeePolicy">EHasCustomFeePolicy</a>,
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_venue"></a>

## Function `assert_venue`



<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_venue">assert_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, venue_id: <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_venue">assert_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>, venue_id: ID) {
    <b>assert</b>!(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_venue">contains_venue</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, venue_id), <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EUndefinedVenue">EUndefinedVenue</a>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_inventory"></a>

## Function `assert_inventory`



<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_inventory">assert_inventory</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, inventory_id: <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_inventory">assert_inventory</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>, inventory_id: ID) {
    // Inventory can be either `Warehouse`
    <b>assert</b>!(
        <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_contains_inventory">contains_inventory</a>&lt;T&gt;(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, inventory_id), <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EUndefinedInventory">EUndefinedInventory</a>,
    );
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version"></a>

## Function `assert_version`



<pre><code><b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_version">assert_version</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>) {
    <b>assert</b>!(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.version == <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_VERSION">VERSION</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_EWrongVersion">EWrongVersion</a>);
}
</code></pre>



</details>

<a name="0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_migrate"></a>

## Function `migrate`



<pre><code>entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_migrate">migrate</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">listing::Listing</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>entry <b>fun</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_migrate">migrate</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>: &<b>mut</b> <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_Listing">Listing</a>, ctx: &<b>mut</b> TxContext) {
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_assert_listing_admin">assert_listing_admin</a>(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>, ctx);

    <b>assert</b>!(<a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.version &lt; <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_VERSION">VERSION</a>, <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_ENotUpgraded">ENotUpgraded</a>);
    <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing">listing</a>.version = <a href="listing.md#0xc74531639fadfb02d30f05f37de4cf1e1149ed8d23658edd089004830068180b_listing_VERSION">VERSION</a>;
}
</code></pre>



</details>
