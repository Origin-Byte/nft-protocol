module nft_protocol::template {
    use sui::transfer;
    use sui::dynamic_field as df;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use nft_protocol::utils;
    use nft_protocol::nft::{Self, Nft};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::mint_cap::{Self, RegulatedMintCap, UnregulatedMintCap};

    use nft_protocol::loose_mint_cap::{Self, LooseMintCap};

    /// `Template` supply is unregulated
    ///
    /// Create an `Template` using `template::new_regulated` to create a
    /// regulated `Template`.
    const EUNREGULATED_ARCHETYPE: u64 = 1;

    /// `Template` supply is regulated
    ///
    /// Create an `Template` using `template::new_unregulated` to create an
    /// unregulated `Template`.
    const EREGULATED_ARCHETYPE: u64 = 2;

    /// `Template` object
    struct Template<phantom C> has key, store {
        id: UID,
        template: Nft<C>,
    }

    /// Create `Template` with unregulated supply
    ///
    /// Does not require that collection itself is unregulated as `Template`
    /// supply is independently regulated.
    public fun new_unregulated<C>(
        template: Nft<C>,
        ctx: &mut TxContext,
    ): Template<C> {
        Template<C> {
            id: object::new(ctx),
            template,
        }
    }

    /// Create `Template` with unregulated supply and transfer to transaction
    /// sender
    ///
    /// Does not require that collection itself is unregulated as `Template`
    /// supply is independently regulated.
    public entry fun create_unregulated<C>(
        template: Nft<C>,
        ctx: &mut TxContext
    ) {
        let template = new_unregulated(template, ctx);
        transfer::transfer(template, tx_context::sender(ctx));
    }

    /// Create `Template` with unregulated supply
    ///
    /// Does not require that collection itself is regulated as `Template`
    /// supply is independently regulated.
    public fun new_regulated<C>(
        template: Nft<C>,
        supply: u64,
        ctx: &mut TxContext,
    ): Template<C> {
        let template = new_unregulated(template, ctx);

        let supply = supply::new(supply, false);
        df::add(
            &mut template.id,
            utils::marker<Supply>(),
            supply,
        );

        template
    }

    /// Create `Template` with regulated supply and transfer to transaction
    /// sender
    ///
    /// Does not require that collection itself is regulated as `Template`
    /// supply is independently regulated.
    public entry fun create_regulated<C>(
        template: Nft<C>,
        supply: u64,
        ctx: &mut TxContext,
    ) {
        let template = new_regulated(template, supply, ctx);
        transfer::transfer(template, tx_context::sender(ctx));
    }

    /// Returns whether `Template` has a regulated supply
    public fun is_regulated<C>(template: &Template<C>): bool {
        df::exists_with_type<utils::Marker<Supply>, Supply>(
            &template.id, utils::marker<Supply>()
        )
    }

    /// Returns the `Template` `Nft`
    public fun borrow_template<C>(template: &Template<C>): &Nft<C> {
        &template.template
    }

    /// Returns the `Template` supply
    ///
    /// #### Panics
    ///
    /// Panics if `Template` supply is unregulated
    public fun borrow_supply<C>(template: &Template<C>): &Supply {
        assert_regulated(template);
        df::borrow(
            &template.id,
            utils::marker<Supply>(),
        )
    }

    /// Returns the `Template` supply
    ///
    /// #### Panics
    ///
    /// Panics if `Template` supply is unregulated
    fun borrow_supply_mut<C>(template: &mut Template<C>): &mut Supply {
        assert_regulated(template);
        df::borrow_mut(
            &mut template.id,
            utils::marker<Supply>(),
        )
    }

    /// Freeze `Template` supply
    public entry fun freeze_supply<C>(template: &mut Template<C>) {
        let supply = borrow_supply_mut(template);
        supply::freeze_supply(supply);
    }

    /// Delegates template minting rights while maintaining `Collection` and
    /// `Template` level supply invariants.
    ///
    /// The argument of `RegulatedMintCap` implies that supply is at least
    /// controlled at the `Collection` level.
    ///
    /// #### Panics
    ///
    /// Panics if `Template` supply is exceeded if `Template` is regulated.
    public fun delegate_regulated<C>(
        mint_cap: RegulatedMintCap<C>,
        template: &mut Template<C>,
        ctx: &mut TxContext,
    ): LooseMintCap<C> {
        if (is_regulated(template)) {
            let supply = borrow_supply_mut(template);
            supply::increment(
                supply,
                supply::supply(mint_cap::borrow_supply(&mint_cap))
            );
        };

        let template_id = object::id(template);
        let nft = borrow_template(template);

        loose_mint_cap::from_regulated(
            mint_cap,
            template_id,
            *nft::name(nft),
            *nft::url(nft),
            ctx,
        )
    }

    /// Delegates template minting rights while maintaining `Collection` and
    /// `Template` level supply invariants.
    ///
    /// The argument of `RegulatedMintCap` implies that supply is unregulated
    /// at the `Collection` level.
    public fun delegate_unregulated<C>(
        mint_cap: UnregulatedMintCap<C>,
        template: &mut Template<C>,
        ctx: &mut TxContext,
    ): LooseMintCap<C> {
        let template_id = object::id(template);
        let nft = borrow_template(template);
        let name = *nft::name(nft);
        let url = *nft::url(nft);

        if (is_regulated(template)) {
            let supply = supply::supply(borrow_supply(template));
            let mint_cap = mint_cap::from_unregulated(
                mint_cap, supply, ctx,
            );
            loose_mint_cap::from_regulated(
                mint_cap, template_id, name, url, ctx,
            )
        } else {
            loose_mint_cap::from_unregulated(
                mint_cap, template_id, name, url, ctx,
            )
        }
    }

    // === Assertions ===

    /// Asserts that `Template` has a regulated supply
    public fun assert_regulated<C>(template: &Template<C>) {
        assert!(is_regulated(template), EUNREGULATED_ARCHETYPE);
    }

    /// Asserts that `Template` has a regulated supply
    public fun assert_unregulated<C>(template: &Template<C>) {
        assert!(!is_regulated(template), EREGULATED_ARCHETYPE);
    }
}
