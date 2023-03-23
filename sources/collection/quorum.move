module nft_protocol::quorum {
    use std::type_name::{Self, TypeName};
    use std::vector;
    use std::option;

    use sui::event;
    use sui::transfer;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_field as df;
    use sui::dynamic_object_field as dof;

    use nft_protocol::witness;
    use nft_protocol::mint_cap::{Self, MintCap};
    use nft_protocol::utils::{Self, Marker};
    use nft_protocol::witness::Witness as DelegatedWitness;

    const ENOT_AN_ADMIN: u64 = 1;
    const ENOT_A_MEMBER: u64 = 2;
    const ENOT_AN_ADMIN_NOR_MEMBER: u64 = 3;

    struct Quorum<phantom F> has key, store {
        id: UID,
        // TODO: Ideally move to TableSet
        admins: vector<address>,
        members: vector<address>,
        extendable: bool,
        admin_count: u64
    }

    struct ReturnReceipt<phantom F, phantom T: key> {}

    struct VotingBooth<phantom F> has store {
        // TODO: make this TableSet
        signatures: vector<address>,
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
        extendable: bool,
        ctx: &mut TxContext,
    ): Quorum<F> {
        let id = object::new(ctx);

        event::emit(CreateQuorumEvent {
            quorum_id: object::uid_to_inner(&id),
            type_name: type_name::get<F>(),
        });

        let admin_count = vector::length(&admins);

        Quorum { id, admins, members, extendable, admin_count }
    }

    public fun init_quorum<F>(
        witness: &F,
        admins: vector<address>,
        members: vector<address>,
        extendable: bool,
        ctx: &mut TxContext,
    ) {
        let quorum = create(witness, admins, members, extendable, ctx);
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
            extendable: false,
            admin_count: 1,
        }
    }

    // === Administrative Functions ===

    // public fun vote_remove_admin<F>(
    //     self: &mut Quorum<F>,
    //     admin_to_remove: address,
    //     ctx: &mut TxContext,
    // ): Quorum<F> {

    // }

    public fun vote_add_admin<F>(
        quorum: &mut Quorum<F>,
        new_admin: address,
        ctx: &mut TxContext,
    ) {
        assert_admin(quorum, ctx);

        let voting_booth_exists = df::exists_(
            &mut quorum.id, AddAdmin { admin: new_admin}
        );

        if (voting_booth_exists) {
            let voting_booth = df::borrow_mut(
                &mut quorum.id, AddAdmin { admin: new_admin }
            );

            sign<F>(voting_booth, ctx);
        } else {
            let sig = tx_context::sender(ctx);

            let voting_booth = VotingBooth<F> {
                signatures: vector::singleton(sig),
            };

            df::add(
                &mut quorum.id, AddAdmin { admin: new_admin}, voting_booth
            );
        }


    }

    // TODO: As it stands this is not safe to be public because
    // it has no admin check
    fun sign<F>(
        booth: &mut VotingBooth<F>,
        ctx: &mut TxContext,
    ) {
        vector::push_back(&mut booth.signatures, tx_context::sender(ctx))
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

    // === MintCap Functions ===

    public fun insert_mint_cap<F>(
        quorum: &mut Quorum<F>,
        mint_cap: MintCap<F>,
        admin_only: bool,
        ctx: &mut TxContext,
    ) {
        assert_admin<F>(quorum, ctx);
        insert_mint_cap_(quorum, mint_cap, admin_only);
    }

    public fun borrow_mint_cap<F, C>(
        quorum: &mut Quorum<F>,
        ctx: &mut TxContext,
    ): (MintCap<C>, ReturnReceipt<F, MintCap<C>>) {
        assert_member_or_admin(quorum, ctx);
        let cap = dof::remove(&mut quorum.id, type_name::get<MintCap<C>>());

        let receipt = ReturnReceipt {};

        (cap, receipt)
    }

    public fun return_mint_cap<F, C>(
        quorum: &mut Quorum<F>,
        mint_cap: MintCap<C>,
        receipt: ReturnReceipt<F, MintCap<C>>,
        ctx: &mut TxContext,
    ) {
        return_mint_cap_(quorum, mint_cap, ctx);
        burn_receipt(receipt);
    }

    fun return_mint_cap_<F, C>(
        quorum: &mut Quorum<F>,
        mint_cap: MintCap<C>,
        ctx: &mut TxContext,
    ) {
        let is_admin_field = df::exists_(
            &mut quorum.id, AdminField {type_name: type_name::get<MintCap<C>>()}
        );

        if (is_admin_field) {
            assert_admin(quorum, ctx);

            let field = df::borrow_mut(
                &mut quorum.id, AdminField {type_name: type_name::get<MintCap<C>>()}
            );

            option::fill(field, mint_cap);
        } else {
            assert_member(quorum, ctx);

            // Fails if Member field does not exist either
            let field = df::borrow_mut(
                &mut quorum.id, MemberField {type_name: type_name::get<MintCap<C>>()}
            );

            option::fill(field, mint_cap);
        }
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

    fun burn_receipt<F, T: key + store>(
        receipt: ReturnReceipt<F, T>
    ) {
        ReturnReceipt {} = receipt;
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
}
