use indoc::indoc;

pub fn template() {
    let testing = formatdoc! {"
    module nft_protocol::{module_name} {{
        use sui::tx_context::{{Self, TxContext}};
        use sui::object::ID;
    
        use std::vector;
        use std::option;
        
        use nft_protocol::collection::Collection;
        use nft_protocol::std_collection::{{Self, StdMeta}};
        use nft_protocol::slingshot::Slingshot;
        use nft_protocol::cap::Limited;
        use nft_protocol::fixed_price::{Self, Market};
        use nft_protocol::unique_nft;
    
        struct TEMPLATE has drop {}
    
        fun init(_witness: TEMPLATE, ctx: &mut TxContext) {
            let receiver = @0xA;
    
            std_collection::mint_and_transfer<TEMPLATE>(
                b"name",
                b"description",
                b"symbol",
                option::some(100), // max_supply
                receiver, // Royalty receiver
                vector::singleton(b"Art"), // tags
                100, // royalty_fee_bps
                false, // is_mutable
                b"Some extra data",
                tx_context::sender(ctx), // recipient
                ctx,
            );
        }
    
        public entry fun create_launchpad(
            collection_id: ID,
            receiver: address,
            ctx: &mut TxContext
            ) {
            fixed_price::create_single_market(
                collection_id, // this should not be here and instead be part of the witness?
                tx_context::sender(ctx), // admin
                receiver,
                true, // is_embedded
                false, // whitelist
                100, // price
                ctx,
            );
        }
    
        public entry fun mint_nft(
            index: u64,
            name: vector<u8>,
            description: vector<u8>,
            url: vector<u8>,
            attribute_keys: vector<vector<u8>>,
            attribute_values: vector<vector<u8>>,
            collection: &mut Collection<SUIMARINES, StdMeta, Limited>,
            sale_index: u64,
            launchpad: &mut Slingshot<SUIMARINES, Market>,
            ctx: &mut TxContext,
        ) {
            unique_nft::launchpad_mint_limited_collection_nft(
                index,
                name,
                description,
                url,
                attribute_keys,
                attribute_values,
                collection,
                sale_index,
                launchpad,
                ctx,
            );
        }
    }
    
        ",
        url = "http://localhost:8080",
        mime = "application/json",
    };
}
