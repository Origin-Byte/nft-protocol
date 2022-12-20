//! Module containing enums that facilitate the generation of Move
//! code. Fields in the yaml file, such as `NftType`, are represented via a
//! String but should match to a value in a given Enum. Such Enums represent
//! the type of NFTs available or the type of Markets available on our
//! OriginByte protocol.
use serde::Deserialize;

/// Enum representing the NFT types currently available in the protocol
#[derive(Debug, Deserialize)]
pub enum NftType {
    // TODO: Need to add support for Soulbound
    Classic,
    // TODO: To be added back
    // Collectible,
    // CNft,
}

#[derive(Debug, Deserialize)]
pub enum Tag {
    Art,
    ProfilePicture,
    Collectible,
    GameAsset,
    TokenisedAsset,
    Ticker,
    DomainName,
    Music,
    Video,
    Ticket,
    License,
}

impl Tag {
    pub fn to_string(&self) -> String {
        let tag = match self {
            Tag::Art => "art",
            Tag::ProfilePicture => "profile_picture",
            Tag::Collectible => "collectible",
            Tag::GameAsset => "game_asset",
            Tag::TokenisedAsset => "tokenised_asset",
            Tag::Ticker => "ticker",
            Tag::DomainName => "domain_name",
            Tag::Music => "music",
            Tag::Video => "video",
            Tag::Ticket => "ticket",
            Tag::License => "license",
        };

        tag.to_string()
    }
}

impl NftType {
    // pub fn nft_module(&self) -> String {
    //     let nft_module = match self {
    //         NftType::Classic => "unique_nft",
    //         NftType::Collectible => "collectible",
    //         NftType::CNft => "c_nft",
    //     };
    //     nft_module.to_string()
    // }

    // pub fn nft_type(&self) -> String {
    //     let nft_type = match self {
    //         NftType::Unique => "unique_nft",
    //         NftType::Collectible => "collectible",
    //         NftType::CNft => "c_nft",
    //     };
    //     nft_type.to_string()
    // }

    pub fn is_embedded(&self) -> bool {
        match self {
            NftType::Classic => true,
            // NftType::Collectible => false,
            // NftType::CNft => false,
        }
    }

    /// Writes Move code for an entry function meant to be called by
    /// the Creators to mint NFTs. Depending on the NFTtype the function
    /// parameters change, therefore pattern match the NFT type.
    pub fn mint_func(&self, witness: &str) -> Box<str> {
        // TODO: Need to add support for unregulated collections
        let func = match self {
            NftType::Classic => format!(
                "public entry fun mint_nft(\n        \
                    name: String,\n        \
                    description: String,\n        \
                    url: vector<u8>,\n        \
                    attribute_keys: vector<String>,\n        \
                    attribute_values: vector<String>,\n        \
                    mint_cap: &mut MintCap<{witness}>,
                    slot: &mut Slot,
                    market_id: ID,
                    ctx: &mut TxContext,
                ) {{
                    let nft = nft::new<{witness}>(tx_context::sender(ctx), ctx);

                    collection::increment_supply(mint_cap, 1);

                    display::add_display_domain(
                        &mut nft,
                        name,
                        description,
                        ctx,
                    );

                    display::add_url_domain(
                        &mut nft,
                        url::new_unsafe_from_bytes(url),
                        ctx,
                    );

                    display::add_attributes_domain_from_vec(
                        &mut nft,
                        attribute_keys,
                        attribute_values,
                        ctx,
                    );

                    slot::add_nft(slot, market_id, nft, ctx);
                }}",
                witness = witness,
            ),
            // NftType::Collectible => format!(
            //     "public entry fun prepare_mint(\n        \
            //         name: vector<u8>,\n        \
            //         description: vector<u8>,\n        \
            //         url: vector<u8>,\n        \
            //         attribute_keys: vector<vector<u8>>,\n        \
            //         attribute_values: vector<vector<u8>>,\n        \
            //         max_supply: u64,\n        \
            //         mint: &mut MintAuthority<{witness}>,\n        \
            //         sale_outlet: u64,\n        \
            //         launchpad: &mut Slingshot<{witness}, {market_type}>,\n        \
            //         ctx: &mut TxContext,\n    \
            //     ) {{\n        \
            //         collectible::prepare_launchpad_mint<{witness}, {market_type}>(\n            \
            //             name,\n            \
            //             description,\n            \
            //             url,\n            \
            //             attribute_keys,\n            \
            //             attribute_values,\n            \
            //             max_supply,\n            \
            //             mint,\n            \
            //             sale_outlet,\n            \
            //             launchpad,\n            \
            //             ctx,\n        \
            //         );\n    \
            //     }}",
            //     witness = witness,
            //     market_type = market_type,
            // ),
            // NftType::CNft => format!(
            //     "public entry fun prepare_mint(\n        \
            //         name: vector<u8>,\n        \
            //         description: vector<u8>,\n        \
            //         url: vector<u8>,\n        \
            //         attribute_keys: vector<vector<u8>>,\n        \
            //         attribute_values: vector<vector<u8>>,\n        \
            //         max_supply: u64,\n        \
            //         mint: &mut MintAuthority<{witness}>,\n        \
            //         sale_outlet: u64,\n        \
            //         launchpad: &mut Slingshot<{witness}, {market_type}>,\n        \
            //         ctx: &mut TxContext,\n    \
            //     ) {{\n        \
            //         c_nft::prepare_launchpad_mint<{witness}, {market_type}, c_nft::Data>(\n            \
            //             name,\n            \
            //             description,\n            \
            //             url,\n            \
            //             attribute_keys,\n            \
            //             attribute_values,\n            \
            //             max_supply,\n            \
            //             mint,\n            \
            //             sale_outlet,\n            \
            //             launchpad,\n            \
            //             ctx,\n        \
            //         );\n    \
            //     }}",
            //     witness = witness,
            //     market_type = market_type,
            // ),
        };
        func.into_boxed_str()
    }
}

pub enum SalesType {
    SingleMarket,
    MultiMarket,
}

#[derive(Debug, Deserialize)]
#[serde(tag = "market_type", rename_all = "snake_case")]
pub enum MarketType {
    FixedPrice {
        prices: Vec<u64>,
        whitelists: Vec<bool>,
    },
    Auction {
        reserve_prices: Vec<u64>,
        whitelists: Vec<bool>,
    },
}

impl MarketType {
    pub fn market_type(&self) -> Box<str> {
        match self {
            MarketType::FixedPrice { .. } => "FixedPriceMarket",
            MarketType::Auction { .. } => "DutchAuctionMarket",
        }
        .into()
    }

    pub fn market_module(&self) -> Box<str> {
        match self {
            MarketType::FixedPrice { .. } => "fixed_price",
            MarketType::Auction { .. } => "dutch_auction",
        }
        .into()
    }
}
