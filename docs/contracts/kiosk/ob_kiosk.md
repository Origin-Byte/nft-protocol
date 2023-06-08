
<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk"></a>

# Module `0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::ob_kiosk`

We publish our extension to <code>sui::kiosk::Kiosk</code> object.
We extend the functionality of the base object with the aim to provide
better client experience and royalty enforcement.
This module closely co-operates with <code>ob_transfer_request</code> module.

When working with this module, you use the base type in your function
signatures but call functions in this module to access the functionality.
We hide the <code>sui::kiosk::KioskOwnerCap</code> type, it cannot be accessed.

Differences over the base object:
- Once a OB <code>Kiosk</code> is owned by a user address, it can never change owner.
This mitigates royalty enforcement avoidance by trading <code>KioskOwnerCap</code>s.
- Authorization with <code><a href="_sender">tx_context::sender</a></code> rather than an <code>OwnerCap</code>.
This means one less object to keep track of.
- Permissionless deposits configuration.
This means deposits can be made without the owner signature.
- NFTs can be optionally always live in <code>Kiosk</code>, hence creating an option
for a bullet proof royalty enforcement.
While the base type attempts to replicate this functionality, due to the
necessity of using <code>KioskOwnerCap</code> for deposits, it is not possible to
use it in context of trading where seller is the one matching the trade.
- NFTs can be listed for a specific entity, be it a smart contract or a user.
Only allowed entities (by the owner) can withdraw NFTs.
- There is no <code>sui::kiosk::PurchaseCap</code> for exclusive listings.
We provide a unified interface for exclusive and non-exclusive listing.
Also, once less object to keep track of.
- We don't have functionality to list NFTs within the <code>Kiosk</code> itself.
Rather, clients are encouraged to use the liquidity layer.
- Permissionless <code>Kiosk</code> needs to signer, apps don't have to wrap both
the <code>KioskOwnerCap</code> and the <code>Kiosk</code> in a smart contract.


-  [Struct `VersionDfKey`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VersionDfKey)
-  [Struct `Witness`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_Witness)
-  [Resource `OwnerToken`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OwnerToken)
-  [Struct `NftRef`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef)
-  [Struct `DepositSetting`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSetting)
-  [Struct `NftRefsDfKey`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey)
-  [Struct `KioskOwnerCapDfKey`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_KioskOwnerCapDfKey)
-  [Struct `DepositSettingDfKey`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSettingDfKey)
-  [Struct `AuthTransferRequestDfKey`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_AuthTransferRequestDfKey)
-  [Struct `OB_KIOSK`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OB_KIOSK)
-  [Constants](#@Constants_0)
-  [Function `new`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new)
-  [Function `create_for_sender`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_for_sender)
-  [Function `init_for_sender`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init_for_sender)
-  [Function `new_for_address`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_for_address)
-  [Function `create_for_address`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_for_address)
-  [Function `init_for_address`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init_for_address)
-  [Function `new_permissionless`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_permissionless)
-  [Function `create_permissionless`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_permissionless)
-  [Function `init_permissionless`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init_permissionless)
-  [Function `set_permissionless_to_permissioned`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_permissionless_to_permissioned)
-  [Function `deposit`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit)
-  [Function `deposit_batch`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit_batch)
-  [Function `auth_transfer`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_auth_transfer)
-  [Function `auth_exclusive_transfer`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_auth_exclusive_transfer)
-  [Function `p2p_transfer`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_p2p_transfer)
-  [Function `p2p_transfer_and_create_target_kiosk`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_p2p_transfer_and_create_target_kiosk)
-  [Function `transfer_delegated`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_delegated)
-  [Function `transfer_signed`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_signed)
-  [Function `transfer_locked_nft`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_locked_nft)
-  [Function `withdraw_nft`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_withdraw_nft)
-  [Function `withdraw_nft_signed`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_withdraw_nft_signed)
-  [Function `transfer_between_owned`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_between_owned)
-  [Function `install_extension`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_install_extension)
-  [Function `uninstall_extension`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_uninstall_extension)
-  [Function `register_nft`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_register_nft)
-  [Function `transfer_nft_`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_nft_)
-  [Function `withdraw_nft_`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_withdraw_nft_)
-  [Function `get_nft`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_get_nft)
-  [Function `new_`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_)
-  [Function `set_transfer_request_auth`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_transfer_request_auth)
-  [Function `set_transfer_request_auth_`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_transfer_request_auth_)
-  [Function `get_transfer_request_auth`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_get_transfer_request_auth)
-  [Function `get_transfer_request_auth_`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_get_transfer_request_auth_)
-  [Function `delist_nft_as_owner`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_delist_nft_as_owner)
-  [Function `remove_auth_transfer_as_owner`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_remove_auth_transfer_as_owner)
-  [Function `remove_auth_transfer`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_remove_auth_transfer)
-  [Function `restrict_deposits`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_restrict_deposits)
-  [Function `enable_any_deposit`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_enable_any_deposit)
-  [Function `disable_deposits_of_collection`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_disable_deposits_of_collection)
-  [Function `enable_deposits_of_collection`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_enable_deposits_of_collection)
-  [Function `borrow_nft_mut`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_borrow_nft_mut)
-  [Function `return_nft`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_return_nft)
-  [Function `is_ob_kiosk`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_is_ob_kiosk)
-  [Function `can_deposit`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_can_deposit)
-  [Function `can_deposit_permissionlessly`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_can_deposit_permissionlessly)
-  [Function `assert_nft_type`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_nft_type)
-  [Function `assert_can_deposit`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_can_deposit)
-  [Function `assert_can_deposit_permissionlessly`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_can_deposit_permissionlessly)
-  [Function `assert_owner_address`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_owner_address)
-  [Function `assert_permission`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission)
-  [Function `assert_has_nft`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_has_nft)
-  [Function `assert_missing_ref`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_missing_ref)
-  [Function `assert_not_exclusively_listed`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_not_exclusively_listed)
-  [Function `assert_not_listed`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_not_listed)
-  [Function `assert_is_ob_kiosk`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_is_ob_kiosk)
-  [Function `assert_kiosk_id`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_kiosk_id)
-  [Function `assert_ref_not_exclusively_listed`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_exclusively_listed)
-  [Function `assert_ref_not_listed`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_listed)
-  [Function `check_entity_and_pop_ref`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_check_entity_and_pop_ref)
-  [Function `deposit_setting_mut`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit_setting_mut)
-  [Function `nft_refs_mut`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_nft_refs_mut)
-  [Function `pop_cap`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_pop_cap)
-  [Function `set_cap`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_cap)
-  [Function `init`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init)
-  [Function `assert_version`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version)
-  [Function `migrate`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_migrate)
-  [Function `migrate_as_pub`](#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_migrate_as_pub)


<pre><code><b>use</b> <a href="">0x1::option</a>;
<b>use</b> <a href="">0x1::string</a>;
<b>use</b> <a href="">0x1::type_name</a>;
<b>use</b> <a href="">0x2::coin</a>;
<b>use</b> <a href="">0x2::display</a>;
<b>use</b> <a href="">0x2::dynamic_field</a>;
<b>use</b> <a href="">0x2::kiosk</a>;
<b>use</b> <a href="">0x2::object</a>;
<b>use</b> <a href="">0x2::package</a>;
<b>use</b> <a href="">0x2::sui</a>;
<b>use</b> <a href="">0x2::table</a>;
<b>use</b> <a href="">0x2::transfer</a>;
<b>use</b> <a href="">0x2::transfer_policy</a>;
<b>use</b> <a href="">0x2::tx_context</a>;
<b>use</b> <a href="">0x2::vec_set</a>;
<b>use</b> <a href="init.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_kiosk">0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b::kiosk</a>;
<b>use</b> <a href="">0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::borrow_request</a>;
<b>use</b> <a href="">0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::request</a>;
<b>use</b> <a href="">0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::transfer_request</a>;
<b>use</b> <a href="">0xe2c7a6843cb13d9549a9d2dc1c266b572ead0b4b9f090e7c3c46de2714102b43::withdraw_request</a>;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VersionDfKey"></a>

## Struct `VersionDfKey`



<pre><code><b>struct</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VersionDfKey">VersionDfKey</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_Witness"></a>

## Struct `Witness`

In the context of Originbyte, we use this type to prove module access.
Only this module can instantiate this type.


<pre><code><b>struct</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_Witness">Witness</a> <b>has</b> drop
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

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OwnerToken"></a>

## Resource `OwnerToken`

Only OB kiosks owned by actual users (not permissionless) have this
honorary token.

Is created when a kiosk is assigned to a user.
It cannot be transferred and has no meaning in the context of on-chain
logic.
It serves purely as a discovery mechanism for off-chain clients.
They get query objects with filter by this type, owned by a specific
address.


<pre><code><b>struct</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OwnerToken">OwnerToken</a> <b>has</b> key
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
<code><a href="">kiosk</a>: <a href="_ID">object::ID</a></code>
</dt>
<dd>

</dd>
<dt>
<code>owner: <b>address</b></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef"></a>

## Struct `NftRef`

Inner accounting type.
Stored under <code><a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey">NftRefsDfKey</a></code> as a dynamic field.

Holds info about NFT listing which is used to determine if an entity
is allowed to redeem the NFT.


<pre><code><b>struct</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>auths: <a href="_VecSet">vec_set::VecSet</a>&lt;<b>address</b>&gt;</code>
</dt>
<dd>
 Entities which can use their <code>&UID</code> to redeem the NFT.

 We use address to be more versatile since <code>ID</code> can be converted to
 address.
 This way we support signers to be auths.
</dd>
<dt>
<code>is_exclusively_listed: bool</code>
</dt>
<dd>
 If set to true, then <code>listed_with</code> must have length of 1 and
 listed_for must be "none".
</dd>
</dl>


</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSetting"></a>

## Struct `DepositSetting`

Configures how deposits without owner signing are limited
Stored under <code><a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSettingDfKey">DepositSettingDfKey</a></code> as a dynamic field.


<pre><code><b>struct</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSetting">DepositSetting</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>enable_any_deposit: bool</code>
</dt>
<dd>
 Enables depositing any collection, bypassing enabled deposits
</dd>
<dt>
<code>collections_with_enabled_deposits: <a href="_VecSet">vec_set::VecSet</a>&lt;<a href="_TypeName">type_name::TypeName</a>&gt;</code>
</dt>
<dd>
 Collections which can be deposited into the <code>Kiosk</code>
</dd>
</dl>


</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey"></a>

## Struct `NftRefsDfKey`

For <code>Kiosk::id</code> value <code>Table&lt;ID, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a>&gt;</code>


<pre><code><b>struct</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey">NftRefsDfKey</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_KioskOwnerCapDfKey"></a>

## Struct `KioskOwnerCapDfKey`

For <code>Kiosk::id</code> value <code>KioskOwnerCap</code>


<pre><code><b>struct</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_KioskOwnerCapDfKey">KioskOwnerCapDfKey</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSettingDfKey"></a>

## Struct `DepositSettingDfKey`

For <code>Kiosk::id</code> value <code><a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSetting">DepositSetting</a></code>


<pre><code><b>struct</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSettingDfKey">DepositSettingDfKey</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_AuthTransferRequestDfKey"></a>

## Struct `AuthTransferRequestDfKey`

For <code>TransferRequest::metadata</code> value <code>TypeName</code>


<pre><code><b>struct</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_AuthTransferRequestDfKey">AuthTransferRequestDfKey</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OB_KIOSK"></a>

## Struct `OB_KIOSK`



<pre><code><b>struct</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OB_KIOSK">OB_KIOSK</a> <b>has</b> drop
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


<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENotAuthorized"></a>

The transfer is not authorized for the given entity


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENotAuthorized">ENotAuthorized</a>: u64 = 8;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENotOwner"></a>

Trying to withdraw profits and sender is not owner


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENotOwner">ENotOwner</a>: u64 = 7;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENotUpgraded"></a>



<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENotUpgraded">ENotUpgraded</a>: u64 = 999;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EWrongVersion"></a>



<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EWrongVersion">EWrongVersion</a>: u64 = 1000;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VERSION"></a>



<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VERSION">VERSION</a>: u64 = 1;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ECannotDeposit"></a>

Permissionless deposits are not enabled and sender is not the owner


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ECannotDeposit">ECannotDeposit</a>: u64 = 11;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ECannotUninstallWithCurrentBookeeping"></a>

You're trying to uninstall the OriginByte extension but there are still
entries in the <code>NftRefs</code> table


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ECannotUninstallWithCurrentBookeeping">ECannotUninstallWithCurrentBookeeping</a>: u64 = 14;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EIncorrectKioskId"></a>

The ID provided does not match the Kiosk


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EIncorrectKioskId">EIncorrectKioskId</a>: u64 = 6;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EIncorrectOwnerToken"></a>

The token provided does not correspond to the Kiosk


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EIncorrectOwnerToken">EIncorrectOwnerToken</a>: u64 = 13;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EKioskNotOriginByteVersion"></a>

The provided Kiosk is not an OriginByte extension


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EKioskNotOriginByteVersion">EKioskNotOriginByteVersion</a>: u64 = 5;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EKioskNotPermissionless"></a>

Error for operations which demand that the kiosk owner is set to
<code><a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_PermissionlessAddr">PermissionlessAddr</a></code>


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EKioskNotPermissionless">EKioskNotPermissionless</a>: u64 = 9;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EMissingNft"></a>

Trying to access an NFT that is not in the kiosk


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EMissingNft">EMissingNft</a>: u64 = 1;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENftAlreadyExclusivelyListed"></a>

NFT is already listed exclusively


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENftAlreadyExclusivelyListed">ENftAlreadyExclusivelyListed</a>: u64 = 2;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENftAlreadyListed"></a>

NFT is already listed


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENftAlreadyListed">ENftAlreadyListed</a>: u64 = 3;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENftIsListedInBaseKiosk"></a>

To register an NFT in the OB extension, it cannot be already listed in the
base Kiosk


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENftIsListedInBaseKiosk">ENftIsListedInBaseKiosk</a>: u64 = 12;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENftTypeMismatch"></a>

The NFT type does not match the desired type


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENftTypeMismatch">ENftTypeMismatch</a>: u64 = 10;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EPermissionlessDepositsDisabled"></a>

Trying to withdraw profits and sender is not owner


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EPermissionlessDepositsDisabled">EPermissionlessDepositsDisabled</a>: u64 = 4;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_PermissionlessAddr"></a>

If the owner of the kiosk is set to this address, all methods which
would normally verify that the owner is the signer are permissionless.

This is useful for wrapping kiosk functionality in a smart contract.
Create a new permissionless kiosk with <code>new_permissionless</code>.


<pre><code><b>const</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_PermissionlessAddr">PermissionlessAddr</a>: <b>address</b> = b;
</code></pre>



<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new"></a>

## Function `new`

Creates a new Kiosk in the OB ecosystem.
By default, all deposits are allowed permissionlessly.

The scope of deposits can be controlled with
- <code>restrict_deposits</code> to allow only owner to deposit;
- <code>enable_any_deposit</code> to again set deposits to be permissionless;
- <code>disable_deposits_of_collection</code> to prevent specific collection to
deposit (ignored if all deposits enabled)
- <code>enable_deposits_of_collection</code> to again specific collection to deposit
(useful in conjunction with restricting all deposits)

Note that those collections which have restricted deposits will NOT be
allowed to be transferred to the kiosk even on trades.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new">new</a>(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (<a href="_Kiosk">kiosk::Kiosk</a>, <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new">new</a>(ctx: &<b>mut</b> TxContext): (Kiosk, ID) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_for_address">new_for_address</a>(<a href="_sender">tx_context::sender</a>(ctx), ctx)
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_for_sender"></a>

## Function `create_for_sender`

Calls <code>new</code> and shares the kiosk


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_for_sender">create_for_sender</a>(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (<a href="_ID">object::ID</a>, <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_for_sender">create_for_sender</a>(ctx: &<b>mut</b> TxContext): (ID, ID) {
    <b>let</b> (<a href="">kiosk</a>, token_id) = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new">new</a>(ctx);
    <b>let</b> kiosk_id = <a href="_id">object::id</a>(&<a href="">kiosk</a>);

    public_share_object(<a href="">kiosk</a>);
    (kiosk_id, token_id)
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init_for_sender"></a>

## Function `init_for_sender`



<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init_for_sender">init_for_sender</a>(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init_for_sender">init_for_sender</a>(ctx: &<b>mut</b> TxContext) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_for_sender">create_for_sender</a>(ctx);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_for_address"></a>

## Function `new_for_address`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_for_address">new_for_address</a>(owner: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (<a href="_Kiosk">kiosk::Kiosk</a>, <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_for_address">new_for_address</a>(owner: <b>address</b>, ctx: &<b>mut</b> TxContext): (Kiosk, ID) {
    <b>let</b> <a href="">kiosk</a> = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_">new_</a>(owner, ctx);

    <b>let</b> token_uid = <a href="_new">object::new</a>(ctx);
    <b>let</b> token_id = <a href="_uid_to_inner">object::uid_to_inner</a>(&token_uid);

    <a href="">transfer</a>(
        <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OwnerToken">OwnerToken</a> {
            id: token_uid,
            <a href="">kiosk</a>: <a href="_id">object::id</a>(&<a href="">kiosk</a>),
            owner,
        },
        owner,
    );

    (<a href="">kiosk</a>, token_id)
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_for_address"></a>

## Function `create_for_address`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_for_address">create_for_address</a>(owner: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (<a href="_ID">object::ID</a>, <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_for_address">create_for_address</a>(owner: <b>address</b>, ctx: &<b>mut</b> TxContext): (ID, ID) {
    <b>let</b> (<a href="">kiosk</a>, token_id) = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_for_address">new_for_address</a>(owner, ctx);
    <b>let</b> kiosk_id = <a href="_id">object::id</a>(&<a href="">kiosk</a>);

    public_share_object(<a href="">kiosk</a>);
    (kiosk_id, token_id)
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init_for_address"></a>

## Function `init_for_address`



<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init_for_address">init_for_address</a>(owner: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init_for_address">init_for_address</a>(owner: <b>address</b>, ctx: &<b>mut</b> TxContext) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_for_address">create_for_address</a>(owner, ctx);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_permissionless"></a>

## Function `new_permissionless`

All functions which would normally verify that the owner is the signer
are callable.
This means that the kiosk MUST be wrapped.
Otherwise, anyone could call those functions.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_permissionless">new_permissionless</a>(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Kiosk">kiosk::Kiosk</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_permissionless">new_permissionless</a>(ctx: &<b>mut</b> TxContext): Kiosk {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_">new_</a>(<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_PermissionlessAddr">PermissionlessAddr</a>, ctx)
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_permissionless"></a>

## Function `create_permissionless`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_permissionless">create_permissionless</a>(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_ID">object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_permissionless">create_permissionless</a>(ctx: &<b>mut</b> TxContext): ID {
    <b>let</b> <a href="">kiosk</a> = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_permissionless">new_permissionless</a>(ctx);
    <b>let</b> kiosk_id = <a href="_id">object::id</a>(&<a href="">kiosk</a>);

    public_share_object(<a href="">kiosk</a>);
    kiosk_id
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init_permissionless"></a>

## Function `init_permissionless`



<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init_permissionless">init_permissionless</a>(ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init_permissionless">init_permissionless</a>(ctx: &<b>mut</b> TxContext) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_create_permissionless">create_permissionless</a>(ctx);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_permissionless_to_permissioned"></a>

## Function `set_permissionless_to_permissioned`

Changes the owner of a kiosk to the given address.
This is only possible if the kiosk is currently permissionless.
Ie. the old owner is <code><a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_PermissionlessAddr">PermissionlessAddr</a></code>.

Note that we don't support changing ownership of a kiosk that's not
permissionless.
The address that is set as the owner of the kiosk is the address that
will remain the owner forever.


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_permissionless_to_permissioned">set_permissionless_to_permissioned</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, user: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_permissionless_to_permissioned">set_permissionless_to_permissioned</a>(
    self: &<b>mut</b> Kiosk, user: <b>address</b>, ctx: &<b>mut</b> TxContext
) {
    <b>assert</b>!(<a href="_owner">kiosk::owner</a>(self) == <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_PermissionlessAddr">PermissionlessAddr</a>, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EKioskNotPermissionless">EKioskNotPermissionless</a>);
    <b>let</b> cap = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_pop_cap">pop_cap</a>(self);
    <a href="_set_owner_custom">kiosk::set_owner_custom</a>(self, &cap, user);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_cap">set_cap</a>(self, cap);

    <a href="">transfer</a>(<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OwnerToken">OwnerToken</a> {
        id: <a href="_new">object::new</a>(ctx),
        <a href="">kiosk</a>: <a href="_id">object::id</a>(self),
        owner: user,
    }, user);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit"></a>

## Function `deposit`

Always works if the sender is the owner.
Fails if permissionless deposits are not enabled for <code>T</code>.
See <code><a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSetting">DepositSetting</a></code>.


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit">deposit</a>&lt;T: store, key&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft: T, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit">deposit</a>&lt;T: key + store&gt;(
    self: &<b>mut</b> Kiosk, nft: T, ctx: &<b>mut</b> TxContext,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_can_deposit">assert_can_deposit</a>&lt;T&gt;(self, ctx);

    // inner accounting
    <b>let</b> nft_id = <a href="_id">object::id</a>(&nft);
    <b>let</b> refs = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_nft_refs_mut">nft_refs_mut</a>(self);
    <a href="_add">table::add</a>(refs, nft_id, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a> {
        auths: <a href="_empty">vec_set::empty</a>(),
        is_exclusively_listed: <b>false</b>,
    });

    // place underlying NFT <b>to</b> <a href="">kiosk</a>
    <b>let</b> cap = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_pop_cap">pop_cap</a>(self);
    <a href="_place">kiosk::place</a>(self, &cap, nft);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_cap">set_cap</a>(self, cap);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit_batch"></a>

## Function `deposit_batch`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit_batch">deposit_batch</a>&lt;T: store, key&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nfts: <a href="">vector</a>&lt;T&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit_batch">deposit_batch</a>&lt;T: key + store&gt;(
    self: &<b>mut</b> Kiosk, nfts: <a href="">vector</a>&lt;T&gt;, ctx: &<b>mut</b> TxContext,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_can_deposit">assert_can_deposit</a>&lt;T&gt;(self, ctx);

    <b>let</b> cap = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_pop_cap">pop_cap</a>(self);
    <b>let</b> len = <a href="_length">vector::length</a>(&nfts);

    <b>while</b> (len &gt; 0) {
        <b>let</b> nft = <a href="_pop_back">vector::pop_back</a>(&<b>mut</b> nfts);

        // inner accounting
        <b>let</b> nft_id = <a href="_id">object::id</a>(&nft);
        <b>let</b> refs = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_nft_refs_mut">nft_refs_mut</a>(self);
        <a href="_add">table::add</a>(refs, nft_id, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a> {
            auths: <a href="_empty">vec_set::empty</a>(),
            is_exclusively_listed: <b>false</b>,
        });

        // place underlying NFT <b>to</b> <a href="">kiosk</a>
        <a href="_place">kiosk::place</a>(self, &cap, nft);

        len = len - 1;
    };

    <a href="_destroy_empty">vector::destroy_empty</a>(nfts);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_cap">set_cap</a>(self, cap);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_auth_transfer"></a>

## Function `auth_transfer`

Authorizes given entity to take given NFT out.
The entity must prove with their <code>&UID</code> in <code>transfer_delegated</code> or
must be the signer in <code>transfer_signed</code>.

Use the <code><a href="_id_to_address">object::id_to_address</a></code> to authorize entities which only live
on chain.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_auth_transfer">auth_transfer</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, entity: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_auth_transfer">auth_transfer</a>(
    self: &<b>mut</b> Kiosk,
    nft_id: ID,
    entity: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission">assert_permission</a>(self, ctx);

    <b>let</b> refs = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_nft_refs_mut">nft_refs_mut</a>(self);
    <b>let</b> ref = <a href="_borrow_mut">table::borrow_mut</a>(refs, nft_id);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_exclusively_listed">assert_ref_not_exclusively_listed</a>(ref);
    <a href="_insert">vec_set::insert</a>(&<b>mut</b> ref.auths, entity);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_auth_exclusive_transfer"></a>

## Function `auth_exclusive_transfer`

Authorizes ONLY given entity to take given NFT out.
No one else (including the owner) can perform a transfer.

The entity must prove with their <code>&UID</code> in <code>transfer_delegated</code>.

Only the given entity can then delist their listing.
This is a dangerous action to be used only with audited contracts
because the NFT is locked until given entity agrees to release it.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_auth_exclusive_transfer">auth_exclusive_transfer</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, entity_id: &<a href="_UID">object::UID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_auth_exclusive_transfer">auth_exclusive_transfer</a>(
    self: &<b>mut</b> Kiosk,
    nft_id: ID,
    entity_id: &UID,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission">assert_permission</a>(self, ctx);

    <b>let</b> refs = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_nft_refs_mut">nft_refs_mut</a>(self);
    <b>let</b> ref = <a href="_borrow_mut">table::borrow_mut</a>(refs, nft_id);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_listed">assert_ref_not_listed</a>(ref);
    <a href="_insert">vec_set::insert</a>(&<b>mut</b> ref.auths, uid_to_address(entity_id));
    ref.is_exclusively_listed = <b>true</b>;
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_p2p_transfer"></a>

## Function `p2p_transfer`

This function is exposed only to the client side, therefore
if allows NFT owners to perform transfers from Kiosk to Kiosk without
having to pay royalties.

This will always work if the signer is the owner of the kiosk.


<pre><code>entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_p2p_transfer">p2p_transfer</a>&lt;T: store, key&gt;(source: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, target: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_p2p_transfer">p2p_transfer</a>&lt;T: key + store&gt;(
    source: &<b>mut</b> Kiosk,
    target: &<b>mut</b> Kiosk,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(source));
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission">assert_permission</a>(source, ctx);

    <b>let</b> refs = df::borrow_mut(ext(source), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey">NftRefsDfKey</a> {});
    <b>let</b> ref = <a href="_remove">table::remove</a>(refs, nft_id);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_exclusively_listed">assert_ref_not_exclusively_listed</a>(&ref);

    <b>let</b> cap = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_pop_cap">pop_cap</a>(source);
    <b>let</b> nft = <a href="_take">kiosk::take</a>&lt;T&gt;(source, &cap, nft_id);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_cap">set_cap</a>(source, cap);

    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit">deposit</a>(target, nft, ctx);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_p2p_transfer_and_create_target_kiosk"></a>

## Function `p2p_transfer_and_create_target_kiosk`



<pre><code>entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_p2p_transfer_and_create_target_kiosk">p2p_transfer_and_create_target_kiosk</a>&lt;T: store, key&gt;(source: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, target: <b>address</b>, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (<a href="_ID">object::ID</a>, <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_p2p_transfer_and_create_target_kiosk">p2p_transfer_and_create_target_kiosk</a>&lt;T: key + store&gt;(
    source: &<b>mut</b> Kiosk,
    target: <b>address</b>,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
): (ID, ID) {
    // Version is asserted in `p2p_transfer`
    // Permission is asserted in `p2p_transfer`

    <b>let</b> (target_kiosk, target_token) = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_for_address">new_for_address</a>(target, ctx);
    <b>let</b> target_kiosk_id = <a href="_id">object::id</a>(&target_kiosk);

    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_p2p_transfer">p2p_transfer</a>&lt;T&gt;(source, &<b>mut</b> target_kiosk, nft_id, ctx);
    public_share_object(target_kiosk);

    (target_kiosk_id, target_token)
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_delegated"></a>

## Function `transfer_delegated`

Can be called by an entity that has been authorized by the owner to
withdraw given NFT.

Returns a builder to the calling entity.
The entity then populates it with trade information of which fungible
tokens were paid.

The builder then _must_ be transformed into a hot potato <code>TransferRequest</code>
which is then used by logic that has access to <code>TransferPolicy</code>.

Can only be called on kiosks in the OB ecosystem.

We adhere to the deposit rules of the target kiosk.
If we didn't, it'd be pointless to even have them since a spammer
could simply simulate a transfer and select any target.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_delegated">transfer_delegated</a>&lt;T: store, key&gt;(source: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, target: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, entity_id: &<a href="_UID">object::UID</a>, price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_delegated">transfer_delegated</a>&lt;T: key + store&gt;(
    source: &<b>mut</b> Kiosk,
    target: &<b>mut</b> Kiosk,
    nft_id: ID,
    entity_id: &UID,
    price: u64,
    ctx: &<b>mut</b> TxContext,
): TransferRequest&lt;T&gt; {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(source));

    <b>let</b> (nft, req) = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_nft_">transfer_nft_</a>(source, nft_id, uid_to_address(entity_id), price, ctx);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit">deposit</a>(target, nft, ctx);
    req
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_signed"></a>

## Function `transfer_signed`

Similar to <code>transfer_delegated</code> but instead of proving origin with
<code>&UID</code> we check that the entity is the signer.

This will always work if the signer is the owner of the kiosk.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_signed">transfer_signed</a>&lt;T: store, key&gt;(source: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, target: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_signed">transfer_signed</a>&lt;T: key + store&gt;(
    source: &<b>mut</b> Kiosk,
    target: &<b>mut</b> Kiosk,
    nft_id: ID,
    price: u64,
    ctx: &<b>mut</b> TxContext,
): TransferRequest&lt;T&gt; {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(source));

    <b>let</b> (nft, req) = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_nft_">transfer_nft_</a>(source, nft_id, sender(ctx), price, ctx);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit">deposit</a>(target, nft, ctx);
    req
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_locked_nft"></a>

## Function `transfer_locked_nft`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_locked_nft">transfer_locked_nft</a>&lt;T: store, key&gt;(source: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, target: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, entity_id: &<a href="_UID">object::UID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_locked_nft">transfer_locked_nft</a>&lt;T: key + store&gt;(
    source: &<b>mut</b> Kiosk,
    target: &<b>mut</b> Kiosk,
    nft_id: ID,
    entity_id: &UID,
    ctx: &<b>mut</b> TxContext,
): TransferRequest&lt;T&gt; {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(source));

    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_check_entity_and_pop_ref">check_entity_and_pop_ref</a>(source, uid_to_address(entity_id), nft_id, ctx);

    <b>let</b> cap = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_pop_cap">pop_cap</a>(source);
    <a href="_list">kiosk::list</a>&lt;T&gt;(source, &cap, nft_id, 0);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_cap">set_cap</a>(source, cap);

    <b>let</b> (nft, req) = <a href="_purchase">kiosk::purchase</a>&lt;T&gt;(source, nft_id, <a href="_zero">coin::zero</a>(ctx));
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit">deposit</a>(target, nft, ctx);

    <b>let</b> req = <a href="_from_sui">transfer_request::from_sui</a>&lt;T&gt;(req, nft_id, uid_to_address(entity_id), ctx);

    req
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_withdraw_nft"></a>

## Function `withdraw_nft`

We allow withdrawing NFTs for some use cases.
If an NFT leaves our kiosk ecosystem, we can no longer guarantee
royalty enforcement.
Therefore, creators might not allow entities which enable withdrawing
NFTs to trade their collection.

You almost certainly want to use <code>transfer_delegated</code>.

Handy for migrations.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_withdraw_nft">withdraw_nft</a>&lt;T: store, key&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, entity_id: &<a href="_UID">object::UID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (T, <a href="_WithdrawRequest">withdraw_request::WithdrawRequest</a>&lt;T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_withdraw_nft">withdraw_nft</a>&lt;T: key + store&gt;(
    self: &<b>mut</b> Kiosk,
    nft_id: ID,
    entity_id: &UID,
    ctx: &<b>mut</b> TxContext,
): (T, WithdrawRequest&lt;T&gt;) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));

    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_withdraw_nft_">withdraw_nft_</a>(self, nft_id, uid_to_address(entity_id), ctx)
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_withdraw_nft_signed"></a>

## Function `withdraw_nft_signed`

Similar to <code>withdraw_nft</code> but the entity is a signer instead of UID.
The owner can always initiate a withdraw.

A withdraw can be prevented with an allowlist.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_withdraw_nft_signed">withdraw_nft_signed</a>&lt;T: store, key&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (T, <a href="_WithdrawRequest">withdraw_request::WithdrawRequest</a>&lt;T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_withdraw_nft_signed">withdraw_nft_signed</a>&lt;T: key + store&gt;(
    self: &<b>mut</b> Kiosk,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
): (T, WithdrawRequest&lt;T&gt;) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));

    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_withdraw_nft_">withdraw_nft_</a>(self, nft_id, sender(ctx), ctx)
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_between_owned"></a>

## Function `transfer_between_owned`

If both kiosks are owned by the same user, then we allow free transfer.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_between_owned">transfer_between_owned</a>&lt;T: store, key&gt;(source: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, target: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_between_owned">transfer_between_owned</a>&lt;T: key + store&gt;(
    source: &<b>mut</b> Kiosk,
    target: &<b>mut</b> Kiosk,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(source));
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission">assert_permission</a>(source, ctx);
    // could result in a royalty free trading by everyone wrapping over our
    // <a href="">kiosk</a>
    <b>assert</b>!(<a href="_owner">kiosk::owner</a>(source) != <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_PermissionlessAddr">PermissionlessAddr</a>, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENotAuthorized">ENotAuthorized</a>);
    // both kiosks are owned by the same user
    <b>assert</b>!(<a href="_owner">kiosk::owner</a>(source) == <a href="_owner">kiosk::owner</a>(target), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENotOwner">ENotOwner</a>);

    <b>let</b> refs = df::borrow_mut(ext(source), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey">NftRefsDfKey</a> {});
    <b>let</b> ref = <a href="_remove">table::remove</a>(refs, nft_id);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_exclusively_listed">assert_ref_not_exclusively_listed</a>(&ref);

    <b>let</b> cap = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_pop_cap">pop_cap</a>(source);
    <b>let</b> nft = <a href="_take">kiosk::take</a>&lt;T&gt;(source, &cap, nft_id);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_cap">set_cap</a>(source, cap);

    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit">deposit</a>(target, nft, ctx);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_install_extension"></a>

## Function `install_extension`



<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_install_extension">install_extension</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, kiosk_cap: <a href="_KioskOwnerCap">kiosk::KioskOwnerCap</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_install_extension">install_extension</a>(
    self: &<b>mut</b> Kiosk,
    kiosk_cap: KioskOwnerCap,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> kiosk_ext = ext(self);

    df::add(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VersionDfKey">VersionDfKey</a> {}, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VERSION">VERSION</a>);
    df::add(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_KioskOwnerCapDfKey">KioskOwnerCapDfKey</a> {}, kiosk_cap);
    df::add(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey">NftRefsDfKey</a> {}, <a href="_new">table::new</a>&lt;ID, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a>&gt;(ctx));
    df::add(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSettingDfKey">DepositSettingDfKey</a> {}, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSetting">DepositSetting</a> {
        enable_any_deposit: <b>true</b>,
        collections_with_enabled_deposits: <a href="_empty">vec_set::empty</a>(),
    });

    <a href="">transfer</a>(<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OwnerToken">OwnerToken</a> {
        id: <a href="_new">object::new</a>(ctx),
        <a href="">kiosk</a>: <a href="_id">object::id</a>(self),
        owner: sender(ctx),
    }, sender(ctx));
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_uninstall_extension"></a>

## Function `uninstall_extension`



<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_uninstall_extension">uninstall_extension</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, owner_token: <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OwnerToken">ob_kiosk::OwnerToken</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_uninstall_extension">uninstall_extension</a>(
    self: &<b>mut</b> Kiosk,
    owner_token: <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OwnerToken">OwnerToken</a>,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));
    <b>assert</b>!(owner_token.<a href="">kiosk</a> == <a href="_id">object::id</a>(self), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EIncorrectOwnerToken">EIncorrectOwnerToken</a>);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_owner_address">assert_owner_address</a>(self, sender(ctx));

    <b>let</b> kiosk_ext = ext(self);

    <b>let</b> refs = df::borrow(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey">NftRefsDfKey</a> {});
    <b>assert</b>!(<a href="_is_empty">table::is_empty</a>&lt;ID, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a>&gt;(refs), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ECannotUninstallWithCurrentBookeeping">ECannotUninstallWithCurrentBookeeping</a>);

    <b>let</b> owner_cap = df::remove&lt;<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_KioskOwnerCapDfKey">KioskOwnerCapDfKey</a>, KioskOwnerCap&gt;(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_KioskOwnerCapDfKey">KioskOwnerCapDfKey</a> {});

    // They should only be able <b>to</b> remove the vevrsion <b>if</b> they completely
    // remove the NftRefs so it's safe <b>to</b> discard Version
    df::remove&lt;<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VersionDfKey">VersionDfKey</a>, u64&gt;(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VersionDfKey">VersionDfKey</a> {});

    <b>let</b> refs = df::remove&lt;<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey">NftRefsDfKey</a>, Table&lt;ID, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a>&gt;&gt;(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey">NftRefsDfKey</a> {});
    <a href="_destroy_empty">table::destroy_empty</a>(refs);
    df::remove&lt;<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSettingDfKey">DepositSettingDfKey</a>, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSetting">DepositSetting</a>&gt;(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSettingDfKey">DepositSettingDfKey</a> {});

    <b>let</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OwnerToken">OwnerToken</a> { id, <a href="">kiosk</a>: _, owner: _} = owner_token;
    <a href="_delete">object::delete</a>(id);

    public_transfer(owner_cap, sender(ctx));
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_register_nft"></a>

## Function `register_nft`



<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_register_nft">register_nft</a>&lt;T: key&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_register_nft">register_nft</a>&lt;T: key&gt;(
    self: &<b>mut</b> Kiosk,
    nft_id: ID,
    ctx: &<b>mut</b> TxContext,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission">assert_permission</a>(self, ctx);

    // Assert that Kiosk <b>has</b> NFT
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_has_nft">assert_has_nft</a>(self, nft_id);
    <b>assert</b>!(!<a href="_is_listed">kiosk::is_listed</a>(self, nft_id), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENftIsListedInBaseKiosk">ENftIsListedInBaseKiosk</a>);

    // Assert that Kiosk <b>has</b> no <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a>, which means the NFT was
    // placed in the Kiosk before installing the OB extension
    <b>let</b> refs = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_nft_refs_mut">nft_refs_mut</a>(self);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_missing_ref">assert_missing_ref</a>(refs, nft_id);

    <a href="_add">table::add</a>(refs, nft_id, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a> {
        auths: <a href="_empty">vec_set::empty</a>(),
        is_exclusively_listed: <b>false</b>,
    });
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_nft_"></a>

## Function `transfer_nft_`

After authorization that the call is permitted, gets the NFT.


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_nft_">transfer_nft_</a>&lt;T: store, key&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, originator: <b>address</b>, price: u64, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (T, <a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_transfer_nft_">transfer_nft_</a>&lt;T: key + store&gt;(
    self: &<b>mut</b> Kiosk,
    nft_id: ID,
    originator: <b>address</b>,
    price: u64,
    ctx: &<b>mut</b> TxContext,
): (T, TransferRequest&lt;T&gt;) {
    <b>let</b> nft = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_get_nft">get_nft</a>(self, nft_id, originator, ctx);

    (nft, <a href="_new">transfer_request::new</a>(nft_id, originator, <a href="_id">object::id</a>(self), price, ctx))
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_withdraw_nft_"></a>

## Function `withdraw_nft_`

After authorization that the call is permitted, gets the NFT.


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_withdraw_nft_">withdraw_nft_</a>&lt;T: store, key&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, originator: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): (T, <a href="_WithdrawRequest">withdraw_request::WithdrawRequest</a>&lt;T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_withdraw_nft_">withdraw_nft_</a>&lt;T: key + store&gt;(
    self: &<b>mut</b> Kiosk,
    nft_id: ID,
    originator: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
): (T, WithdrawRequest&lt;T&gt;) {
    <b>let</b> nft = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_get_nft">get_nft</a>(self, nft_id, originator, ctx);

    (nft, <a href="_new">withdraw_request::new</a>(originator, ctx))
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_get_nft"></a>

## Function `get_nft`



<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_get_nft">get_nft</a>&lt;T: store, key&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, originator: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_get_nft">get_nft</a>&lt;T: key + store&gt;(
    self: &<b>mut</b> Kiosk,
    nft_id: ID,
    originator: <b>address</b>,
    ctx: &<b>mut</b> TxContext,
): T {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_check_entity_and_pop_ref">check_entity_and_pop_ref</a>(self, originator, nft_id, ctx);

    <b>let</b> cap = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_pop_cap">pop_cap</a>(self);
    <b>let</b> nft = <a href="_take">kiosk::take</a>&lt;T&gt;(self, &cap, nft_id);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_cap">set_cap</a>(self, cap);

    nft
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_"></a>

## Function `new_`



<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_">new_</a>(owner: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_Kiosk">kiosk::Kiosk</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_new_">new_</a>(owner: <b>address</b>, ctx: &<b>mut</b> TxContext): Kiosk {
    <b>let</b> (<a href="">kiosk</a>, kiosk_cap) = <a href="_new">kiosk::new</a>(ctx);
    <a href="_set_owner_custom">kiosk::set_owner_custom</a>(&<b>mut</b> <a href="">kiosk</a>, &kiosk_cap, owner);
    <b>let</b> kiosk_ext = ext(&<b>mut</b> <a href="">kiosk</a>);

    df::add(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VersionDfKey">VersionDfKey</a> {}, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VERSION">VERSION</a>);
    df::add(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_KioskOwnerCapDfKey">KioskOwnerCapDfKey</a> {}, kiosk_cap);
    df::add(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey">NftRefsDfKey</a> {}, <a href="_new">table::new</a>&lt;ID, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a>&gt;(ctx));
    df::add(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSettingDfKey">DepositSettingDfKey</a> {}, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSetting">DepositSetting</a> {
        enable_any_deposit: <b>true</b>,
        collections_with_enabled_deposits: <a href="_empty">vec_set::empty</a>(),
    });

    <a href="">kiosk</a>
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_transfer_request_auth"></a>

## Function `set_transfer_request_auth`

Proves access to given type <code>Auth</code>.
Useful in conjunction with witness-like types.
Trading contracts proves themselves with <code>Auth</code> instead of UID.
This makes it easier to implement allowlists since we can globally
allow a contract to trade.
Allowlist could also be implemented with a UID but that would require
that the trading contracts maintain a global object.
In some cases this is doable, in other it's inconvenient.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_transfer_request_auth">set_transfer_request_auth</a>&lt;T, Auth&gt;(req: &<b>mut</b> <a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;, _auth: &Auth)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_transfer_request_auth">set_transfer_request_auth</a>&lt;T, Auth&gt;(
    req: &<b>mut</b> TransferRequest&lt;T&gt;, _auth: &Auth,
) {
    <b>let</b> metadata = <a href="_metadata_mut">transfer_request::metadata_mut</a>(req);
    df::add(metadata, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_AuthTransferRequestDfKey">AuthTransferRequestDfKey</a> {}, <a href="_get">type_name::get</a>&lt;Auth&gt;());
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_transfer_request_auth_"></a>

## Function `set_transfer_request_auth_`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_transfer_request_auth_">set_transfer_request_auth_</a>&lt;T, P, Auth&gt;(req: &<b>mut</b> <a href="_RequestBody">request::RequestBody</a>&lt;<a href="_WithNft">request::WithNft</a>&lt;T, P&gt;&gt;, _auth: &Auth)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_transfer_request_auth_">set_transfer_request_auth_</a>&lt;T, P, Auth&gt;(
    req: &<b>mut</b> RequestBody&lt;WithNft&lt;T, P&gt;&gt;, _auth: &Auth,
) {
    <b>let</b> metadata = <a href="_metadata_mut">request::metadata_mut</a>(req);
    df::add(metadata, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_AuthTransferRequestDfKey">AuthTransferRequestDfKey</a> {}, <a href="_get">type_name::get</a>&lt;Auth&gt;());
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_get_transfer_request_auth"></a>

## Function `get_transfer_request_auth`

What's the authority that created this request?


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_get_transfer_request_auth">get_transfer_request_auth</a>&lt;T&gt;(req: &<a href="_TransferRequest">transfer_request::TransferRequest</a>&lt;T&gt;): &<a href="_TypeName">type_name::TypeName</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_get_transfer_request_auth">get_transfer_request_auth</a>&lt;T&gt;(req: &TransferRequest&lt;T&gt;): &TypeName {
    <b>let</b> metadata = <a href="_metadata">transfer_request::metadata</a>(req);
    df::borrow(metadata, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_AuthTransferRequestDfKey">AuthTransferRequestDfKey</a> {})
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_get_transfer_request_auth_"></a>

## Function `get_transfer_request_auth_`

What's the authority that created this request?


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_get_transfer_request_auth_">get_transfer_request_auth_</a>&lt;T, P&gt;(req: &<a href="_RequestBody">request::RequestBody</a>&lt;<a href="_WithNft">request::WithNft</a>&lt;T, P&gt;&gt;): &<a href="_TypeName">type_name::TypeName</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_get_transfer_request_auth_">get_transfer_request_auth_</a>&lt;T, P&gt;(
    req: &RequestBody&lt;WithNft&lt;T, P&gt;&gt;,
): &TypeName {
    <b>let</b> metadata = <a href="_metadata">request::metadata</a>(req);
    df::borrow(metadata, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_AuthTransferRequestDfKey">AuthTransferRequestDfKey</a> {})
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_delist_nft_as_owner"></a>

## Function `delist_nft_as_owner`

Removes _all_ entities from access to the NFT.
Cannot be performed if the NFT is exclusively listed.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_delist_nft_as_owner">delist_nft_as_owner</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_delist_nft_as_owner">delist_nft_as_owner</a>(
    self: &<b>mut</b> Kiosk, nft_id: ID, ctx: &<b>mut</b> TxContext,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission">assert_permission</a>(self, ctx);

    <b>let</b> refs = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_nft_refs_mut">nft_refs_mut</a>(self);
    <b>let</b> ref = <a href="_borrow_mut">table::borrow_mut</a>(refs, nft_id);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_exclusively_listed">assert_ref_not_exclusively_listed</a>(ref);
    ref.auths = <a href="_empty">vec_set::empty</a>();
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_remove_auth_transfer_as_owner"></a>

## Function `remove_auth_transfer_as_owner`

Removes a specific NFT from access to the NFT.
Cannot be performed if the NFT is exclusively listed.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_remove_auth_transfer_as_owner">remove_auth_transfer_as_owner</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, entity: <b>address</b>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_remove_auth_transfer_as_owner">remove_auth_transfer_as_owner</a>(
    self: &<b>mut</b> Kiosk, nft_id: ID, entity: <b>address</b>, ctx: &<b>mut</b> TxContext,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission">assert_permission</a>(self, ctx);

    <b>let</b> refs = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_nft_refs_mut">nft_refs_mut</a>(self);
    <b>let</b> ref = <a href="_borrow_mut">table::borrow_mut</a>(refs, nft_id);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_exclusively_listed">assert_ref_not_exclusively_listed</a>(ref);
    <a href="_remove">vec_set::remove</a>(&<b>mut</b> ref.auths, &entity);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_remove_auth_transfer"></a>

## Function `remove_auth_transfer`

This is the only path to delist an exclusively listed NFT.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_remove_auth_transfer">remove_auth_transfer</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, entity: &<a href="_UID">object::UID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_remove_auth_transfer">remove_auth_transfer</a>(
    self: &<b>mut</b> Kiosk, nft_id: ID, entity: &UID,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));

    <b>let</b> entity = uid_to_address(entity);

    <b>let</b> refs = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_nft_refs_mut">nft_refs_mut</a>(self);
    <b>let</b> ref = <a href="_borrow_mut">table::borrow_mut</a>(refs, nft_id);
    <a href="_remove">vec_set::remove</a>(&<b>mut</b> ref.auths, &entity);
    ref.is_exclusively_listed = <b>false</b>; // no-op <b>if</b> it wasn't
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_restrict_deposits"></a>

## Function `restrict_deposits`

Only owner or allowlisted collections can deposit.


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_restrict_deposits">restrict_deposits</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_restrict_deposits">restrict_deposits</a>(
    self: &<b>mut</b> Kiosk, ctx: &<b>mut</b> TxContext,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission">assert_permission</a>(self, ctx);

    <b>let</b> settings = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit_setting_mut">deposit_setting_mut</a>(self);
    settings.enable_any_deposit = <b>false</b>;
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_enable_any_deposit"></a>

## Function `enable_any_deposit`

No restriction on deposits.


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_enable_any_deposit">enable_any_deposit</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_enable_any_deposit">enable_any_deposit</a>(
    self: &<b>mut</b> Kiosk, ctx: &<b>mut</b> TxContext,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission">assert_permission</a>(self, ctx);

    <b>let</b> settings = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit_setting_mut">deposit_setting_mut</a>(self);
    settings.enable_any_deposit = <b>true</b>;
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_disable_deposits_of_collection"></a>

## Function `disable_deposits_of_collection`

The owner can restrict deposits into the <code>Kiosk</code> from given
collection.

However, if the flag <code>DepositSetting::enable_any_deposit</code> is set to
true, then it takes precedence.


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_disable_deposits_of_collection">disable_deposits_of_collection</a>&lt;C&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_disable_deposits_of_collection">disable_deposits_of_collection</a>&lt;C&gt;(
    self: &<b>mut</b> Kiosk, ctx: &<b>mut</b> TxContext,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission">assert_permission</a>(self, ctx);

    <b>let</b> settings = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit_setting_mut">deposit_setting_mut</a>(self);
    <b>let</b> col_type = <a href="_get">type_name::get</a>&lt;C&gt;();
    <a href="_remove">vec_set::remove</a>(&<b>mut</b> settings.collections_with_enabled_deposits, &col_type);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_enable_deposits_of_collection"></a>

## Function `enable_deposits_of_collection`

The owner can enable deposits into the <code>Kiosk</code> from given
collection.

However, if the flag <code>Kiosk::enable_any_deposit</code> is set to
true, then it takes precedence anyway.


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_enable_deposits_of_collection">enable_deposits_of_collection</a>&lt;C&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_enable_deposits_of_collection">enable_deposits_of_collection</a>&lt;C&gt;(
    self: &<b>mut</b> Kiosk, ctx: &<b>mut</b> TxContext,
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission">assert_permission</a>(self, ctx);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));

    <b>let</b> settings = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit_setting_mut">deposit_setting_mut</a>(self);
    <b>let</b> col_type = <a href="_get">type_name::get</a>&lt;C&gt;();
    <a href="_insert">vec_set::insert</a>(&<b>mut</b> settings.collections_with_enabled_deposits, col_type);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_borrow_nft_mut"></a>

## Function `borrow_nft_mut`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_borrow_nft_mut">borrow_nft_mut</a>&lt;T: store, key&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>, field: <a href="_Option">option::Option</a>&lt;<a href="_TypeName">type_name::TypeName</a>&gt;, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): <a href="_BorrowRequest">borrow_request::BorrowRequest</a>&lt;<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_Witness">ob_kiosk::Witness</a>, T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_borrow_nft_mut">borrow_nft_mut</a>&lt;T: key + store&gt;(
    self: &<b>mut</b> Kiosk,
    nft_id: ID,
    field: Option&lt;TypeName&gt;,
    ctx: &<b>mut</b> TxContext,
): BorrowRequest&lt;<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_Witness">Witness</a>, T&gt; {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_not_listed">assert_not_listed</a>(self, nft_id);

    <b>let</b> cap = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_pop_cap">pop_cap</a>(self);
    <b>let</b> (nft, promise) = <a href="_borrow_val">kiosk::borrow_val</a>(self, &cap, nft_id);
    // <b>let</b> nft = <a href="_take">kiosk::take</a>&lt;T&gt;(self, &cap, nft_id);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_cap">set_cap</a>(self, cap);

    <a href="_new">borrow_request::new</a>(<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_Witness">Witness</a> {}, nft, sender(ctx), field, promise, ctx)
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_return_nft"></a>

## Function `return_nft`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_return_nft">return_nft</a>&lt;OTW: drop, T: store, key&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, borrowed_nft: <a href="_BorrowRequest">borrow_request::BorrowRequest</a>&lt;<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_Witness">ob_kiosk::Witness</a>, T&gt;, policy: &<a href="_Policy">request::Policy</a>&lt;<a href="_WithNft">request::WithNft</a>&lt;T, <a href="_BORROW_REQ">borrow_request::BORROW_REQ</a>&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_return_nft">return_nft</a>&lt;OTW: drop, T: key + store&gt;(
    self: &<b>mut</b> Kiosk,
    borrowed_nft: BorrowRequest&lt;<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_Witness">Witness</a>, T&gt;,
    policy: &Policy&lt;WithNft&lt;T, BORROW_REQ&gt;&gt;
) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(ext(self));

    <b>let</b> (nft, promise) = <a href="_confirm">borrow_request::confirm</a>(<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_Witness">Witness</a> {}, borrowed_nft, policy);

    <b>let</b> cap = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_pop_cap">pop_cap</a>(self);
    <a href="_return_val">kiosk::return_val</a>(self, nft, promise);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_cap">set_cap</a>(self, cap);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_is_ob_kiosk"></a>

## Function `is_ob_kiosk`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_is_ob_kiosk">is_ob_kiosk</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_is_ob_kiosk">is_ob_kiosk</a>(self: &<b>mut</b> Kiosk): bool {
    df::exists_(ext(self), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey">NftRefsDfKey</a> {})
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_can_deposit"></a>

## Function `can_deposit`

Either sender is owner or permissionless deposits of <code>T</code> enabled.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_can_deposit">can_deposit</a>&lt;T&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_can_deposit">can_deposit</a>&lt;T&gt;(self: &<b>mut</b> Kiosk, ctx: &<b>mut</b> TxContext): bool {
    sender(ctx) == <a href="_owner">kiosk::owner</a>(self) || <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_can_deposit_permissionlessly">can_deposit_permissionlessly</a>&lt;T&gt;(self)
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_can_deposit_permissionlessly"></a>

## Function `can_deposit_permissionlessly`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_can_deposit_permissionlessly">can_deposit_permissionlessly</a>&lt;T&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_can_deposit_permissionlessly">can_deposit_permissionlessly</a>&lt;T&gt;(self: &<b>mut</b> Kiosk): bool {
    <b>if</b> (<a href="_owner">kiosk::owner</a>(self) == <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_PermissionlessAddr">PermissionlessAddr</a>) {
        <b>return</b> <b>true</b>
    };

    <b>let</b> settings = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit_setting_mut">deposit_setting_mut</a>(self);
    settings.enable_any_deposit ||
        <a href="_contains">vec_set::contains</a>(
            &settings.collections_with_enabled_deposits,
            &<a href="_get">type_name::get</a>&lt;T&gt;(),
        )
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_nft_type"></a>

## Function `assert_nft_type`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_nft_type">assert_nft_type</a>&lt;T: store, key&gt;(self: &<a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_nft_type">assert_nft_type</a>&lt;T: key + store&gt;(self: &Kiosk, nft_id: ID) {
    <b>assert</b>!(<a href="_has_item_with_type">kiosk::has_item_with_type</a>&lt;T&gt;(self, nft_id), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENftTypeMismatch">ENftTypeMismatch</a>);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_can_deposit"></a>

## Function `assert_can_deposit`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_can_deposit">assert_can_deposit</a>&lt;T&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_can_deposit">assert_can_deposit</a>&lt;T&gt;(self: &<b>mut</b> Kiosk, ctx: &<b>mut</b> TxContext) {
    <b>assert</b>!(<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_can_deposit">can_deposit</a>&lt;T&gt;(self, ctx), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ECannotDeposit">ECannotDeposit</a>);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_can_deposit_permissionlessly"></a>

## Function `assert_can_deposit_permissionlessly`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_can_deposit_permissionlessly">assert_can_deposit_permissionlessly</a>&lt;T&gt;(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_can_deposit_permissionlessly">assert_can_deposit_permissionlessly</a>&lt;T&gt;(self: &<b>mut</b> Kiosk) {
    <b>assert</b>!(<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_can_deposit_permissionlessly">can_deposit_permissionlessly</a>&lt;T&gt;(self), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EPermissionlessDepositsDisabled">EPermissionlessDepositsDisabled</a>);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_owner_address"></a>

## Function `assert_owner_address`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_owner_address">assert_owner_address</a>(self: &<a href="_Kiosk">kiosk::Kiosk</a>, owner: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_owner_address">assert_owner_address</a>(self: &Kiosk, owner: <b>address</b>) {
    <b>assert</b>!(<a href="_owner">kiosk::owner</a>(self) == owner, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENotOwner">ENotOwner</a>);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission"></a>

## Function `assert_permission`

Either the kiosk is permissionless, or the sender is the owner.


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission">assert_permission</a>(self: &<a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission">assert_permission</a>(self: &Kiosk, ctx: &<b>mut</b> TxContext) {
    <b>let</b> owner = <a href="_owner">kiosk::owner</a>(self);
    <b>assert</b>!(owner == <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_PermissionlessAddr">PermissionlessAddr</a> || owner == sender(ctx), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENotOwner">ENotOwner</a>);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_has_nft"></a>

## Function `assert_has_nft`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_has_nft">assert_has_nft</a>(self: &<a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_has_nft">assert_has_nft</a>(self: &Kiosk, nft_id: ID) {
    <b>assert</b>!(<a href="_has_item">kiosk::has_item</a>(self, nft_id), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EMissingNft">EMissingNft</a>)
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_missing_ref"></a>

## Function `assert_missing_ref`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_missing_ref">assert_missing_ref</a>(refs: &<a href="_Table">table::Table</a>&lt;<a href="_ID">object::ID</a>, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">ob_kiosk::NftRef</a>&gt;, nft_id: <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_missing_ref">assert_missing_ref</a>(refs: &Table&lt;ID, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a>&gt;, nft_id: ID) {
    <b>assert</b>!(!<a href="_contains">table::contains</a>(refs, nft_id), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EMissingNft">EMissingNft</a>)
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_not_exclusively_listed"></a>

## Function `assert_not_exclusively_listed`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_not_exclusively_listed">assert_not_exclusively_listed</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_not_exclusively_listed">assert_not_exclusively_listed</a>(
    self: &<b>mut</b> Kiosk, nft_id: ID
) {
    <b>let</b> refs = df::borrow(ext(self), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey">NftRefsDfKey</a> {});
    <b>let</b> ref = <a href="_borrow">table::borrow</a>(refs, nft_id);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_exclusively_listed">assert_ref_not_exclusively_listed</a>(ref);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_not_listed"></a>

## Function `assert_not_listed`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_not_listed">assert_not_listed</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, nft_id: <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_not_listed">assert_not_listed</a>(self: &<b>mut</b> Kiosk, nft_id: ID) {
    <b>let</b> refs = df::borrow(ext(self), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey">NftRefsDfKey</a> {});
    <b>let</b> ref = <a href="_borrow">table::borrow</a>(refs, nft_id);
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_listed">assert_ref_not_listed</a>(ref);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_is_ob_kiosk"></a>

## Function `assert_is_ob_kiosk`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_is_ob_kiosk">assert_is_ob_kiosk</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_is_ob_kiosk">assert_is_ob_kiosk</a>(self: &<b>mut</b> Kiosk) {
    <b>assert</b>!(<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_is_ob_kiosk">is_ob_kiosk</a>(self), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EKioskNotOriginByteVersion">EKioskNotOriginByteVersion</a>);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_kiosk_id"></a>

## Function `assert_kiosk_id`



<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_kiosk_id">assert_kiosk_id</a>(self: &<a href="_Kiosk">kiosk::Kiosk</a>, id: <a href="_ID">object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_kiosk_id">assert_kiosk_id</a>(self: &Kiosk, id: ID) {
    <b>assert</b>!(<a href="_id">object::id</a>(self) == id, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EIncorrectKioskId">EIncorrectKioskId</a>);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_exclusively_listed"></a>

## Function `assert_ref_not_exclusively_listed`



<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_exclusively_listed">assert_ref_not_exclusively_listed</a>(ref: &<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">ob_kiosk::NftRef</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_exclusively_listed">assert_ref_not_exclusively_listed</a>(ref: &<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a>) {
    <b>assert</b>!(!ref.is_exclusively_listed, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENftAlreadyExclusivelyListed">ENftAlreadyExclusivelyListed</a>);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_listed"></a>

## Function `assert_ref_not_listed`



<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_listed">assert_ref_not_listed</a>(ref: &<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">ob_kiosk::NftRef</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_ref_not_listed">assert_ref_not_listed</a>(ref: &<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a>) {
    <b>assert</b>!(<a href="_size">vec_set::size</a>(&ref.auths) == 0, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENftAlreadyListed">ENftAlreadyListed</a>);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_check_entity_and_pop_ref"></a>

## Function `check_entity_and_pop_ref`



<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_check_entity_and_pop_ref">check_entity_and_pop_ref</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, entity: <b>address</b>, nft_id: <a href="_ID">object::ID</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_check_entity_and_pop_ref">check_entity_and_pop_ref</a>(
    self: &<b>mut</b> Kiosk, entity: <b>address</b>, nft_id: ID, ctx: &<b>mut</b> TxContext
) {
    <b>let</b> refs = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_nft_refs_mut">nft_refs_mut</a>(self);
    // NFT is being transferred - destroy the ref
    <b>let</b> ref: <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a> = <a href="_remove">table::remove</a>(refs, nft_id);
    // sender is signer
    // OR
    // entity MUST be included in the map
    <b>assert</b>!(
        sender(ctx) == <a href="_owner">kiosk::owner</a>(self) || <a href="_contains">vec_set::contains</a>(&ref.auths, &entity),
        <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENotAuthorized">ENotAuthorized</a>,
    );
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit_setting_mut"></a>

## Function `deposit_setting_mut`



<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit_setting_mut">deposit_setting_mut</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>): &<b>mut</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSetting">ob_kiosk::DepositSetting</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_deposit_setting_mut">deposit_setting_mut</a>(self: &<b>mut</b> Kiosk): &<b>mut</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSetting">DepositSetting</a> {
    df::borrow_mut(ext(self), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_DepositSettingDfKey">DepositSettingDfKey</a> {})
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_nft_refs_mut"></a>

## Function `nft_refs_mut`



<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_nft_refs_mut">nft_refs_mut</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>): &<b>mut</b> <a href="_Table">table::Table</a>&lt;<a href="_ID">object::ID</a>, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">ob_kiosk::NftRef</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_nft_refs_mut">nft_refs_mut</a>(self: &<b>mut</b> Kiosk): &<b>mut</b> Table&lt;ID, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRef">NftRef</a>&gt; {
    df::borrow_mut(ext(self), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_NftRefsDfKey">NftRefsDfKey</a> {})
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_pop_cap"></a>

## Function `pop_cap`



<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_pop_cap">pop_cap</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>): <a href="_KioskOwnerCap">kiosk::KioskOwnerCap</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_pop_cap">pop_cap</a>(self: &<b>mut</b> Kiosk): <a href="_KioskOwnerCap">kiosk::KioskOwnerCap</a> {
    df::remove(ext(self), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_KioskOwnerCapDfKey">KioskOwnerCapDfKey</a> {})
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_cap"></a>

## Function `set_cap`



<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_cap">set_cap</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, cap: <a href="_KioskOwnerCap">kiosk::KioskOwnerCap</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_set_cap">set_cap</a>(self: &<b>mut</b> Kiosk, cap: <a href="_KioskOwnerCap">kiosk::KioskOwnerCap</a>) {
    df::add(ext(self), <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_KioskOwnerCapDfKey">KioskOwnerCapDfKey</a> {}, cap);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init"></a>

## Function `init`



<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init">init</a>(otw: <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OB_KIOSK">ob_kiosk::OB_KIOSK</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_init">init</a>(otw: <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OB_KIOSK">OB_KIOSK</a>, ctx: &<b>mut</b> TxContext) {
    <b>let</b> publisher = <a href="_claim">package::claim</a>(otw, ctx);
    <b>let</b> <a href="">display</a> = <a href="_new">display::new</a>&lt;<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_OwnerToken">OwnerToken</a>&gt;(&publisher, ctx);

    <a href="_add">display::add</a>(&<b>mut</b> <a href="">display</a>, utf8(b"name"), utf8(b"Originbyte Kiosk"));
    <a href="_add">display::add</a>(&<b>mut</b> <a href="">display</a>, utf8(b"link"), utf8(b"https://docs.originbyte.io"));
    <a href="_add">display::add</a>(&<b>mut</b> <a href="">display</a>, utf8(b"owner"), utf8(b"{owner}"));
    <a href="_add">display::add</a>(&<b>mut</b> <a href="">display</a>, utf8(b"<a href="">kiosk</a>"), utf8(b"{<a href="">kiosk</a>}"));
    <a href="_add">display::add</a>(
        &<b>mut</b> <a href="">display</a>,
        utf8(b"description"),
        utf8(b"Stores NFTs, manages listings, sales and more!"),
    );

    <a href="_update_version">display::update_version</a>(&<b>mut</b> <a href="">display</a>);
    public_transfer(<a href="">display</a>, <a href="_sender">tx_context::sender</a>(ctx));
    <a href="_burn_publisher">package::burn_publisher</a>(publisher);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version"></a>

## Function `assert_version`



<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(kiosk_uid: &<a href="_UID">object::UID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_version">assert_version</a>(kiosk_uid: &UID) {
    <b>let</b> version = df::borrow&lt;<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VersionDfKey">VersionDfKey</a>, u64&gt;(kiosk_uid, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VersionDfKey">VersionDfKey</a> {});

    <b>assert</b>!(*version == <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VERSION">VERSION</a>, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_EWrongVersion">EWrongVersion</a>);
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_migrate"></a>

## Function `migrate`



<pre><code>entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_migrate">migrate</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, ctx: &<b>mut</b> <a href="_TxContext">tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_migrate">migrate</a>(self: &<b>mut</b> Kiosk, ctx: &<b>mut</b> TxContext) {
    <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_assert_permission">assert_permission</a>(self, ctx);
    <b>let</b> kiosk_ext = ext(self);

    <b>let</b> version = df::borrow_mut&lt;<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VersionDfKey">VersionDfKey</a>, u64&gt;(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VersionDfKey">VersionDfKey</a> {});

    <b>assert</b>!(*version &lt; <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VERSION">VERSION</a>, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENotUpgraded">ENotUpgraded</a>);
    *version = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VERSION">VERSION</a>;
}
</code></pre>



</details>

<a name="0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_migrate_as_pub"></a>

## Function `migrate_as_pub`



<pre><code>entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_migrate_as_pub">migrate_as_pub</a>(self: &<b>mut</b> <a href="_Kiosk">kiosk::Kiosk</a>, pub: &<a href="_Publisher">package::Publisher</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code>entry <b>fun</b> <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_migrate_as_pub">migrate_as_pub</a>(self: &<b>mut</b> Kiosk, pub: &Publisher) {
    <b>assert</b>!(<a href="_from_package">package::from_package</a>&lt;KIOSK&gt;(pub), 0);

    <b>let</b> kiosk_ext = ext(self);
    <b>let</b> version = df::borrow_mut&lt;<a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VersionDfKey">VersionDfKey</a>, u64&gt;(kiosk_ext, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VersionDfKey">VersionDfKey</a> {});

    <b>assert</b>!(*version &lt; <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VERSION">VERSION</a>, <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_ENotUpgraded">ENotUpgraded</a>);
    *version = <a href="ob_kiosk.md#0x95a441d389b07437d00dd07e0b6f05f513d7659b13fd7c5d3923c7d9d847199b_ob_kiosk_VERSION">VERSION</a>;
}
</code></pre>



</details>
