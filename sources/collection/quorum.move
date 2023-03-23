module nft_protocol::quorum {
    use std::type_name::{Self, TypeName};
    use std::vector;
    use std::option;

    use sui::event;
    use sui::math;
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_field as df;
    use sui::dynamic_object_field as dof;

    use nft_protocol::mint_cap::MintCap;

    const ENOT_AN_ADMIN: u64 = 1;
    const ENOT_A_MEMBER: u64 = 2;
    const ENOT_AN_ADMIN_NOR_MEMBER: u64 = 3;
    const EMIN_ADMIN_COUNT_IS_ONE: u64 = 4;
    const EADDRESS_IS_NOT_ADMIN: u64 = 5;
    const EQUORUM_EXTENSION_MISMATCH: u64 = 6;

    struct Quorum<phantom F> has key, store {
        id: UID,
        // TODO: Ideally move to TableSet
        admins: vector<address>,
        members: vector<address>,
        admin_count: u64
    }

    struct ReturnReceipt<phantom F, phantom T: key> {}

    struct ExtensionToken<phantom F> has store {
        quorum_id: ID,
    }

    struct Signatures<phantom F> has store, copy, drop {
        // TODO: make this TableSet
        list: vector<address>,
    }

    // === Dynamic Field keys ===

    struct AdminField has store, copy, drop {
        type_name: TypeName,
    }

    struct MemberField has store, copy, drop {
        type_name: TypeName,
    }

    struct AddAdmin has store, copy, drop {
        admin: address,
    }

    struct RemoveAdmin has store, copy, drop {
        admin: address,
    }

    // === Events ===

    struct CreateQuorumEvent has copy, drop {
        quorum_id: ID,
        type_name: TypeName,
    }

    // === Init Functions ===

    public fun create<F>(
        _witness: &F,
        admins: vector<address>,
        members: vector<address>,
        ctx: &mut TxContext,
    ): Quorum<F> {
        let id = object::new(ctx);

        event::emit(CreateQuorumEvent {
            quorum_id: object::uid_to_inner(&id),
            type_name: type_name::get<F>(),
        });

        let admin_count = vector::length(&admins);

        Quorum { id, admins, members, admin_count }
    }

    public fun create_for_extension<F>(
        _witness: &F,
        admins: vector<address>,
        members: vector<address>,
        ctx: &mut TxContext,
    ): (Quorum<F>, ExtensionToken<F>) {
        let id = object::new(ctx);

        event::emit(CreateQuorumEvent {
            quorum_id: object::uid_to_inner(&id),
            type_name: type_name::get<F>(),
        });

        let admin_count = vector::length(&admins);

        let extension_token = ExtensionToken { quorum_id: object::uid_to_inner(&id) };
        let quorum = Quorum { id, admins, members, admin_count };

        (quorum, extension_token)
    }

    public fun init_quorum<F>(
        witness: &F,
        admins: vector<address>,
        members: vector<address>,
        ctx: &mut TxContext,
    ) {
        let quorum = create(witness, admins, members, ctx);
        transfer::share_object(quorum);
    }

    public fun singleton<F>(
        _witness: &F,
        admin: address,
        ctx: &mut TxContext,
    ): Quorum<F> {
        let id = object::new(ctx);

        event::emit(CreateQuorumEvent {
            quorum_id: object::uid_to_inner(&id),
            type_name: type_name::get<F>(),
        });

        Quorum {
            id,
            admins: vector[admin],
            members: vector::empty(),
            admin_count: 1,
        }
    }

    // === Admin Functions ===

    public entry fun vote_add_admin<F>(
        quorum: &mut Quorum<F>,
        new_admin: address,
        ctx: &mut TxContext,
    ) {
        let (vote_count, threshold) = vote(quorum, AddAdmin { admin: new_admin}, ctx);

        if (vote_count >= threshold) {
            df::remove<AddAdmin, Signatures<F>>(&mut quorum.id, AddAdmin { admin: new_admin});
            vector::push_back(&mut quorum.admins, new_admin);
            quorum.admin_count = quorum.admin_count + 1;
        };
    }

    public entry fun vote_remove_admin<F>(
        quorum: &mut Quorum<F>,
        old_admin: address,
        ctx: &mut TxContext,
    ) {
        assert!(quorum.admin_count > 1, EMIN_ADMIN_COUNT_IS_ONE);

        let (vote_count, threshold) = vote(quorum, RemoveAdmin { admin: old_admin}, ctx);

        if (vote_count >= threshold) {
            df::remove<RemoveAdmin, Signatures<F>>(&mut quorum.id, RemoveAdmin { admin: old_admin});

            let (exists_, i) = vector::index_of(&quorum.members, &old_admin);
            assert!(exists_, EADDRESS_IS_NOT_ADMIN);

            if (exists_) {
                vector::remove(&mut quorum.admins, i);
            };

            quorum.admin_count = quorum.admin_count - 1;
        };
    }

    public fun add_admin_with_extension<F>(
        quorum: &mut Quorum<F>,
        ext_token: &ExtensionToken<F>,
        new_admin: address,
    ) {
        assert_extension_token(quorum, ext_token);

        vector::push_back(&mut quorum.admins, new_admin);
        quorum.admin_count = quorum.admin_count + 1;
    }

    public fun remove_admin_with_extension<F>(
        quorum: &mut Quorum<F>,
        ext_token: &ExtensionToken<F>,
        old_admin: address,
    ) {
        assert_extension_token(quorum, ext_token);

        let (exists_, i) = vector::index_of(&quorum.members, &old_admin);
        assert!(exists_, EADDRESS_IS_NOT_ADMIN);

        if (exists_) {
            vector::remove(&mut quorum.admins, i);
        };

        quorum.admin_count = quorum.admin_count - 1;
    }

    public fun vote<F, Field: copy + drop + store>(
        quorum: &mut Quorum<F>,
        field: Field,
        ctx: &mut TxContext,
    ): (u64, u64) {
        assert_admin(quorum, ctx);

        let signatures_exist = df::exists_(
            &mut quorum.id, field
        );

        let vote_count: u64;
        let threshold: u64;

        if (signatures_exist) {
            let sigs = df::borrow_mut(
                &mut quorum.id, field
            );

            sign<F>(sigs, ctx);

            vote_count = vector::length(&sigs.list);
            threshold = calc_voting_threshold(quorum.admin_count);

        } else {
            let sig = tx_context::sender(ctx);

            let voting_booth = Signatures<F> {
                list: vector::singleton(sig),
            };

            df::add(
                &mut quorum.id, field, voting_booth
            );

            vote_count = 1;
            threshold = calc_voting_threshold(quorum.admin_count);
        };

        (vote_count, threshold)
    }

    // TODO: As it stands this is not safe to be public because
    // it has no admin check
    fun sign<F>(
        sigs: &mut Signatures<F>,
        ctx: &mut TxContext,
    ) {
        vector::push_back(&mut sigs.list, tx_context::sender(ctx))
    }

    // TODO: allow for extensions to chance the majority rule
    fun calc_voting_threshold(
        admin_count: u64,
    ): u64 {
        let threshold: u64;

        if (admin_count == 1) {
            threshold = 1;
        } else {
            threshold = math::divide_and_round_up(admin_count, 2);

            if (admin_count % 2 == 0) {
                threshold = threshold + 1;
            }
        };

        threshold
    }

    public fun add_member<F>(
        quorum: &mut Quorum<F>,
        member: address,
        ctx: &mut TxContext,
    ) {
        assert_admin<F>(quorum, ctx);

        vector::push_back(&mut quorum.members, member);
    }

    public fun remove_member<F>(
        quorum: &mut Quorum<F>,
        member: address,
        ctx: &mut TxContext,
    ) {
        assert_admin<F>(quorum, ctx);

        let (exists_, i) = vector::index_of(&quorum.members, &member);
        if (exists_) {
            vector::remove(&mut quorum.members, i);
        }
    }

    // === MintCap Helper Functions ===

    public fun insert_mint_cap<F, C>(
        quorum: &mut Quorum<F>,
        mint_cap: MintCap<C>,
        admin_only: bool,
        ctx: &mut TxContext,
    ) {
        insert_cap(quorum, mint_cap, admin_only, ctx);
    }

    public fun borrow_mint_cap<F, C>(
        quorum: &mut Quorum<F>,
        ctx: &mut TxContext,
    ): (MintCap<C>, ReturnReceipt<F, MintCap<C>>) {
        borrow_cap(quorum, ctx)
    }

    public fun return_mint_cap<F, C>(
        quorum: &mut Quorum<F>,
        mint_cap: MintCap<C>,
        receipt: ReturnReceipt<F, MintCap<C>>,
        ctx: &mut TxContext,
    ) {
        return_cap(quorum, mint_cap, receipt, ctx)
    }

    fun insert_mint_cap_<F, C>(
        quorum: &mut Quorum<F>,
        mint_cap: MintCap<C>,
        admin_only: bool,
    ) {
        if (admin_only) {
            df::add(
                &mut quorum.id,
                AdminField {type_name: type_name::get<MintCap<C>>()},
                option::some(mint_cap),
            );
        } else {
            df::add(
                &mut quorum.id,
                MemberField {type_name: type_name::get<MintCap<C>>()},
                option::some(mint_cap),
            );
        }
    }

    // === Object Functions ===

    public fun insert_cap<F, T: key + store>(
        quorum: &mut Quorum<F>,
        cap_object: T,
        admin_only: bool,
        ctx: &mut TxContext,
    ) {
        assert_admin<F>(quorum, ctx);
        insert_cap_(quorum, cap_object, admin_only);
    }

    public fun borrow_cap<F, T: key + store>(
        quorum: &mut Quorum<F>,
        ctx: &mut TxContext,
    ): (T, ReturnReceipt<F, T>) {
        assert_member_or_admin(quorum, ctx);
        let cap = dof::remove(&mut quorum.id, type_name::get<T>());

        let receipt = ReturnReceipt {};

        (cap, receipt)
    }

    public fun return_cap<F, T: key + store>(
        quorum: &mut Quorum<F>,
        cap_object: T,
        receipt: ReturnReceipt<F, T>,
        ctx: &mut TxContext,
    ) {
        return_cap_(quorum, cap_object, ctx);
        burn_receipt(receipt);
    }

    fun return_cap_<F, T: key + store>(
        quorum: &mut Quorum<F>,
        cap_object: T,
        ctx: &mut TxContext,
    ) {
        let is_admin_field = df::exists_(
            &mut quorum.id, AdminField {type_name: type_name::get<T>()}
        );

        if (is_admin_field) {
            assert_admin(quorum, ctx);

            let field = df::borrow_mut(
                &mut quorum.id, AdminField {type_name: type_name::get<T>()}
            );

            option::fill(field, cap_object);
        } else {
            assert_member(quorum, ctx);

            // Fails if Member field does not exist either
            let field = df::borrow_mut(
                &mut quorum.id, MemberField {type_name: type_name::get<T>()}
            );

            option::fill(field, cap_object);
        }
    }

    fun insert_cap_<F, T: key + store>(
        quorum: &mut Quorum<F>,
        cap_object: T,
        admin_only: bool,
    ) {
        if (admin_only) {
            df::add(
                &mut quorum.id,
                AdminField {type_name: type_name::get<T>()},
                option::some(cap_object),
            );
        } else {
            df::add(
                &mut quorum.id,
                MemberField {type_name: type_name::get<T>()},
                option::some(cap_object),
            );
        }
    }

    fun burn_receipt<F, T: key + store>(
        receipt: ReturnReceipt<F, T>
    ) {
        ReturnReceipt {} = receipt;
    }

    fun uid_mut<F>(
        quorum: &mut Quorum<F>,
        ext_token: &ExtensionToken<F>,
    ): &mut UID {
        assert_extension_token(quorum, ext_token);

        &mut quorum.id
    }

    public fun assert_admin<F>(quorum: &Quorum<F>, ctx: &TxContext) {
        assert!(vector::contains(&quorum.admins, &tx_context::sender(ctx)), ENOT_AN_ADMIN);
    }

    public fun assert_member<F>(quorum: &Quorum<F>, ctx: &TxContext) {
        assert!(vector::contains(&quorum.members, &tx_context::sender(ctx)), ENOT_A_MEMBER);
    }

    public fun assert_member_or_admin<F>(quorum: &Quorum<F>, ctx: &TxContext) {
        assert!(
            vector::contains(&quorum.admins, &tx_context::sender(ctx))
                || vector::contains(&quorum.members, &tx_context::sender(ctx)),
            ENOT_AN_ADMIN_NOR_MEMBER);
    }

    public fun assert_extension_token<F>(quorum: &Quorum<F>, ext_token: &ExtensionToken<F>) {
        assert!(object::id(quorum) == ext_token.quorum_id, EQUORUM_EXTENSION_MISMATCH);
    }
}
