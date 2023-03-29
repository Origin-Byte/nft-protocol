module nft_protocol::ob_kiosk {
    use nft_protocol::transfer_policy::{Self, TransferRequestBuilder};
    use std::type_name::{Self, TypeName};
    use sui::dynamic_field::{Self as df};
    use sui::kiosk::{Self, Kiosk, uid_mut as ext};
    use sui::object::{Self, ID, UID};
    use sui::table::{Self, Table};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};

    // === Errors ===

    /// Trying to access an NFT that is not in the kiosk.
    const EMissingNft: u64 = 1;
    /// NFT is already listed exclusively
    const ENftAlreadyExclusivelyListed: u64 = 2;
    /// NFT is already listed
    const ENftAlreadyListed: u64 = 3;
    /// Trying to withdraw profits and sender is not owner.
    const EPermissionlessDepositsDisabled: u64 = 4;
    /// The provided Kiosk is not an OriginByte extension
    const EKioskNotOriginByteVersion: u64 = 5;
    /// The ID provided does not match the Kiosk
    const EIncorrectKioskId: u64 = 6;
    /// Trying to withdraw profits and sender is not owner.
    const ENotOwner: u64 = 7;

    // === Structs ===

    /// Custom `OwnerCap` for Originbyte kiosk.
    /// The actual `KioskOwnerCap` is stored under `KioskOwnerCapDfKey` as a
    /// dynamic field.
    struct OwnerCap has key {
        id: UID,
        kiosk: ID,
    }

    /// Inner accounting type.
    /// Stored under `NftRefsDfKey` as a dynamic field.
    ///
    /// Holds info about NFT listing which is used to determine if an entity
    /// is allowed to redeem the NFT.
    struct NftRef has store, drop {
        // TODO: Consider using address instead of ID
        /// Entities which can use their `&UID` to redeem the NFT.
        auths: VecSet<ID>,
        /// If set to true, then `listed_with` must have length of 1 and
        /// listed_for must be "none".
        is_exclusively_listed: bool,
    }

    /// Configures how deposits without owner cap are limited
    /// Stored under `DepositSettingDfKey` as a dynamic field.
    struct DepositSetting has store, drop {
        /// Enables depositing any collection, bypassing enabled deposits
        enable_any_deposit: bool,
        /// Collections which can be deposited into the `Safe`
        collections_with_enabled_deposits: VecSet<TypeName>,
    }

    // === Dynamic field keys ===

    /// For value `Table<ID, NftRef>`
    struct NftRefsDfKey has store, copy, drop {}
    /// For value `KioskOwnerCap`
    struct KioskOwnerCapDfKey has store, copy, drop {}
    /// For value `DepositSetting`
    struct DepositSettingDfKey has store, copy, drop {}

    // === Instantiators ===

    public fun create_for_sender(ctx: &mut TxContext) {
        let owner_cap = create_kiosk(ctx);
        transfer::transfer(owner_cap, tx_context::sender(ctx));
    }

    public fun create_kiosk(ctx: &mut TxContext): OwnerCap {
        let (kiosk, owner_cap) = new(ctx);
        transfer::public_share_object(kiosk);
        owner_cap
    }

    public fun new_for_sender(ctx: &mut TxContext): Kiosk {
        let (kiosk, owner_cap) = new(ctx);
        transfer::transfer(owner_cap, tx_context::sender(ctx));
        kiosk
    }

    public fun new(ctx: &mut TxContext): (Kiosk, OwnerCap) {
        let (kiosk, kiosk_cap) = kiosk::new(ctx);

        let kiosk_ext = ext(&mut kiosk);
        df::add(kiosk_ext, NftRefsDfKey {}, table::new<ID, NftRef>(ctx));
        df::add(kiosk_ext, KioskOwnerCapDfKey {}, kiosk_cap);
        df::add(kiosk_ext, DepositSettingDfKey {}, DepositSetting {
            enable_any_deposit: true,
            collections_with_enabled_deposits: vec_set::empty(),
        });

        let owner_cap = OwnerCap {
            id: object::new(ctx),
            kiosk: object::id(&kiosk),
        };

        (kiosk, owner_cap)
    }

    // === Deposit to the Kiosk ===

    public fun deposit<T: key + store>(self: &mut Kiosk, nft: T) {
        assert_can_deposit<T>(self);
        deposit_(self, nft);
    }

    public fun deposit_as_owner<T: key + store>(
        self: &mut Kiosk, cap: &OwnerCap, nft: T,
    ) {
        assert_owner_cap(self, cap);
        deposit_(self, nft);
    }

    fun deposit_<T: key + store>(self: &mut Kiosk, nft: T) {
        // inner accounting
        let nft_id = object::id(&nft);
        let refs = nft_refs_mut(self);
        table::add(refs, nft_id, NftRef {
            auths: vec_set::empty(),
            is_exclusively_listed: false,
        });

        // underlying NFT place to kiosk
        let cap = pop_cap(self);
        kiosk::place(self, &cap, nft);
        set_cap(self, cap);
    }

    // === Withdraw from the Kiosk ===

    public fun auth_transfer(
        self: &mut Kiosk,
        owner_cap: &OwnerCap,
        nft_id: ID,
        entity_id: ID,
    ) {
        assert_owner_cap(self, owner_cap);

        let refs = nft_refs_mut(self);
        let ref = table::borrow_mut(refs, nft_id);
        assert_ref_not_exclusively_listed(ref);
        vec_set::insert(&mut ref.auths, entity_id);
    }

    public fun auth_exclusive_transfer(
        self: &mut Kiosk,
        owner_cap: &OwnerCap,
        nft_id: ID,
        entity_id: &UID,
    ) {
        assert_owner_cap(self, owner_cap);

        let refs = nft_refs_mut(self);
        let ref = table::borrow_mut(refs, nft_id);
        assert_not_listed(ref);
        vec_set::insert(&mut ref.auths, object::uid_to_inner(entity_id));
        ref.is_exclusively_listed = true;
    }

    /// We allow withdrawing NFTs for some use cases.
    /// If an NFT leaves our kiosk ecosystem, we can no longer guarantee
    /// royalty enforcement.
    /// Therefore, creators might not allow entities which enable withdrawing
    /// NFTs to trade their collection.
    ///
    /// You almost certainly want to use `transfer_delegated`.
    public fun withdraw_nft<T: key + store>(
        self: &mut Kiosk,
        nft_id: ID,
        entity_id: &UID,
    ): (T, TransferRequestBuilder<T>) {
        let originator = object::uid_to_inner(entity_id);
        check_entity_and_pop_ref(self, originator, nft_id);

        let cap = pop_cap(self);
        let nft = kiosk::take<T>(self, &cap, nft_id);
        set_cap(self, cap);

        (nft, transfer_policy::builder(originator))
    }

    /// Can be called by an entity that has been authorized by the owner to
    /// withdraw given NFT.
    ///
    /// Returns a builder to the calling entity.
    /// The entity then populates it with trade information of which fungible
    /// tokens were paid.
    ///
    /// The builder then _must_ be transformed into a hot potato `TransferRequest`
    /// which is then used by logic that has access to `TransferPolicy`.
    ///
    /// Can only be called on kiosks in the OB ecosystem.
    ///
    /// We adhere to the deposit rules of the target kiosk.
    /// If we didn't, it'd be pointless to even have them since a spammer
    /// could simply simulate a transfer and select any target.
    public fun transfer_delegated<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        entity_id: &UID,
    ): TransferRequestBuilder<T> {
        let (nft, builder) = withdraw_nft(source, nft_id, entity_id);
        deposit(target, nft);
        builder
    }

    /// Can initiate transfer without firstly authorizing any particular entity.
    ///
    /// Note that the same rules for transfer apply for the owner.
    /// The originator of the transfer is the user's owner cap ID.
    /// A collection creator can still disable transfers as owner.
    ///
    /// Can only be called on kiosks in the OB ecosystem.
    ///
    /// We adhere to the deposit rules of the target kiosk.
    /// If we didn't, it'd be pointless to even have them since a spammer
    /// could simply simulate a transfer and select any target.
    public fun transfer_as_owner<T: key + store>(
        source: &mut Kiosk,
        target: &mut Kiosk,
        nft_id: ID,
        owner_cap: &OwnerCap,
    ): TransferRequestBuilder<T> {
        assert_owner_cap(source, owner_cap);

        let refs = df::borrow_mut(ext(source), NftRefsDfKey {});
        let ref = table::remove(refs, nft_id);
        assert_ref_not_exclusively_listed(&ref);

        let cap = pop_cap(source);
        let nft = kiosk::take<T>(source, &cap, nft_id);
        set_cap(source, cap);

        deposit(target, nft);

        transfer_policy::builder(object::id(owner_cap))
    }

    // === Configure deposit settings ===

    /// Only owner or allowlisted collections can deposit.
    public entry fun restrict_deposits(
        self: &mut Kiosk,
        owner_cap: &OwnerCap,
    ) {
        assert_owner_cap(self, owner_cap);
        let settings = deposit_setting_mut(self);
        settings.enable_any_deposit = false;
    }

    /// No restriction on deposits.
    public entry fun enable_any_deposit(
        self: &mut Kiosk,
        owner_cap: &OwnerCap,
    ) {
        assert_owner_cap(self, owner_cap);
        let settings = deposit_setting_mut(self);
        settings.enable_any_deposit = true;
    }

    /// The owner can restrict deposits into the `Kiosk` from given
    /// collection.
    ///
    /// However, if the flag `DepositSetting::enable_any_deposit` is set to
    /// true, then it takes precedence.
    public entry fun disable_deposits_of_collection<C>(
        self: &mut Kiosk,
        owner_cap: &OwnerCap,
    ) {
        assert_owner_cap(self, owner_cap);
        let settings = deposit_setting_mut(self);
        let col_type = type_name::get<C>();
        vec_set::remove(&mut settings.collections_with_enabled_deposits, &col_type);
    }

    /// The owner can enable deposits into the `Kiosk` from given
    /// collection.
    ///
    /// However, if the flag `Kiosk::enable_any_deposit` is set to
    /// true, then it takes precedence anyway.
    public entry fun enable_deposits_of_collection<C>(
        self: &mut Kiosk,
        owner_cap: &OwnerCap,
    ) {
        assert_owner_cap(self, owner_cap);
        let settings = deposit_setting_mut(self);
        let col_type = type_name::get<C>();
        vec_set::insert(&mut settings.collections_with_enabled_deposits, col_type);
    }

    // === Assertions and getters ===

    public fun owner_cap_kiosk(cap: &OwnerCap): ID { cap.kiosk }

    public fun is_ob_kiosk(self: &mut Kiosk): bool {
        df::exists_(ext(self), NftRefsDfKey {})
    }

    public fun assert_can_deposit<T>(self: &mut Kiosk) {
        let settings = deposit_setting_mut(self);

        if (!settings.enable_any_deposit) {
            assert!(
                vec_set::contains(
                    &settings.collections_with_enabled_deposits,
                    &type_name::get<T>(),
                ),
                EPermissionlessDepositsDisabled,
            );
        }
    }

    public fun assert_owner_cap(self: &Kiosk, cap: &OwnerCap) {
        assert!(object::id(self) == cap.kiosk, ENotOwner);
    }

    public fun assert_has_nft(self: &Kiosk, nft_id: ID) {
        assert!(kiosk::has_item(self, nft_id), EMissingNft)
    }

    public fun assert_not_exclusively_listed<I: key + store>(
        self: &mut Kiosk, nft_id: ID
    ) {
        let refs = df::borrow(ext(self), NftRefsDfKey {});
        let ref = table::borrow(refs, nft_id);
        assert_ref_not_exclusively_listed(ref);
    }

    public fun assert_is_ob_kiosk(self: &mut Kiosk) {
        assert!(is_ob_kiosk(self), EKioskNotOriginByteVersion);
    }

    public fun assert_kiosk_id(self: &Kiosk, id: ID) {
        assert!(object::id(self) == id, EIncorrectKioskId);
    }

    fun assert_ref_not_exclusively_listed(ref: &NftRef) {
        assert!(!ref.is_exclusively_listed, ENftAlreadyExclusivelyListed);
    }

    fun assert_not_listed(ref: &NftRef) {
        assert!(vec_set::size(&ref.auths) == 0, ENftAlreadyListed);
    }

    fun check_entity_and_pop_ref(self: &mut Kiosk, entity_id: ID, nft_id: ID) {
        let refs = nft_refs_mut(self);
        // NFT is being transferred - destroy the ref
        let ref: NftRef = table::remove(refs, nft_id);
        // aborts if entity is not included in the map
        vec_set::contains(&ref.auths, &entity_id);
    }

    fun deposit_setting_mut(self: &mut Kiosk): &mut DepositSetting {
        df::borrow_mut(ext(self), DepositSettingDfKey {})
    }

    fun nft_refs_mut(self: &mut Kiosk): &mut Table<ID, NftRef> {
        df::borrow_mut(ext(self), NftRefsDfKey {})
    }

    fun pop_cap(self: &mut Kiosk): kiosk::KioskOwnerCap {
        df::remove(ext(self), KioskOwnerCapDfKey {})
    }

    fun set_cap(self: &mut Kiosk, cap: kiosk::KioskOwnerCap) {
        df::add(ext(self), KioskOwnerCapDfKey {}, cap);
    }
}
