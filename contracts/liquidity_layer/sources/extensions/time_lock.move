module liquidity_layer::time_lock {
    use std::ascii::String;
    use std::option::{Self, Option};
    use std::type_name;
    use std::vector;

    use sui::transfer_policy::TransferPolicy;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::event;
    use sui::package::{Self, Publisher};
    use sui::kiosk::{Self, Kiosk};
    use sui::object::{Self, ID, UID};
    use sui::transfer::share_object;
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_field as df;

    use ob_permissions::witness::{Self, Witness as DelegatedWitness};
    use ob_kiosk::ob_kiosk;
    use ob_request::transfer_request::{Self, TransferRequest};

    use liquidity_layer::trading;
    use liquidity_layer::liquidity_layer::LIQUIDITY_LAYER;
    use liquidity_layer::orderbook::{Self, Orderbook, WitnessProtectedActions};

    use critbit::critbit_u64::{Self as critbit, CritbitTree};

    // === Errors ===


    // === Structs ===

    struct TimeLock has store {
        start_time: u64,
        actions: WitnessProtectedActions,
    }

    // === Instantiators ===

    /// Create a new `Orderbook<T, FT>` and immediately share it
    ///
    /// #### Panics
    ///
    /// Panics if `TransferPolicy<T>` is not an OriginByte policy.
    public entry fun init_orderbook<T: key + store, FT>(
        publisher: &Publisher,
        transfer_policy: &TransferPolicy<T>,
        buy_nft: bool,
        create_ask: bool,
        create_bid: bool,
        start_time: u64,
        ctx: &mut TxContext,
    ) {
        create<T, FT>(
            witness::from_publisher(publisher),
            transfer_policy,
            buy_nft,
            create_ask,
            create_bid,
            start_time,
            ctx,
        );
    }

    /// Create a new `Orderbook<T, FT>` and immediately share it, returning
    /// it's ID
    ///
    /// #### Panics
    ///
    /// Panics if `TransferPolicy<T>` is not an OriginByte policy.
    public fun create<T: key + store, FT>(
        witness: DelegatedWitness<T>,
        transfer_policy: &TransferPolicy<T>,
        buy_nft: bool,
        create_ask: bool,
        create_bid: bool,
        start_time: u64,
        ctx: &mut TxContext,
    ): ID {
        let orderbook = new<T, FT>(
            witness, transfer_policy, buy_nft, create_ask, create_bid, start_time, ctx,
        );
        let orderbook_id = object::id(&orderbook);
        share_object(orderbook);
        orderbook_id
    }

    /// Create a new `Orderbook<T, FT>`
    ///
    /// To implement specific logic in your smart contract, you can toggle the
    /// protection on specific actions. That will make them only accessible via
    /// witness protected methods.
    ///
    /// #### Panics
    ///
    /// Panics if `TransferPolicy<T>` is not an OriginByte policy.
    public fun new<T: key + store, FT>(
        _witness: DelegatedWitness<T>,
        transfer_policy: &TransferPolicy<T>,
        buy_nft: bool,
        create_ask: bool,
        create_bid: bool,
        start_time: u64,
        ctx: &mut TxContext
    ): Orderbook<T, FT> {

        let ob = orderbook::new(
            _witness,
            transfer_policy,
            true,
            true,
            true,
            // start_time,
            ctx,
        );




    }


}
