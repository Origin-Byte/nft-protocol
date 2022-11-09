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
    Unique,
    Collectible,
    CNft,
}

impl NftType {
    pub fn nft_module(&self) -> String {
        let nft_module = match self {
            NftType::Unique => "unique_nft",
            NftType::Collectible => "collectible",
            NftType::CNft => "c_nft",
        };
        nft_module.to_string()
    }

    pub fn nft_type(&self) -> String {
        let nft_type = match self {
            NftType::Unique => "unique_nft",
            NftType::Collectible => "collectible",
            NftType::CNft => "c_nft",
        };
        nft_type.to_string()
    }

    pub fn is_embedded(&self) -> bool {
        match self {
            NftType::Unique => true,
            NftType::Collectible => false,
            NftType::CNft => false,
        }
    }

    /// Writes Move code for an entry function meant to be called by
    /// the Creators to mint NFTs. Depending on the NFTtype the function
    /// parameters change, therefore pattern match the NFT type.
    pub fn mint_func(&self, witness: &str, market_type: &str) -> Box<str> {
        // TODO: Need to add support for unregulated collections
        let func = match self {
            NftType::Unique => format!(
                "public entry fun prepare_mint(\n        \
                    name: vector<u8>,\n        \
                    description: vector<u8>,\n        \
                    url: vector<u8>,\n        \
                    attribute_keys: vector<vector<u8>>,\n        \
                    attribute_values: vector<vector<u8>>,\n        \
                    mint_authority: &mut MintAuthority<{witness}>,\n        \
                    sale_outlet: u64,\n        \
                    launchpad: &mut Slingshot<{witness}, {market_type}>,\n        \
                    ctx: &mut TxContext,\n    \
                ) {{\n        \
                    unique_nft::prepare_launchpad_mint<{witness}, {market_type}>(\n            \
                        name,\n            \
                        description,\n            \
                        url,\n            \
                        attribute_keys,\n            \
                        attribute_values,\n            \
                        mint_authority,\n            \
                        sale_outlet,\n            \
                        launchpad,\n            \
                        ctx,\n        \
                    );\n    \
                }}",
                witness = witness,
                market_type = market_type,
            ),
            NftType::Collectible => format!(
                "public entry fun prepare_mint(\n        \
                    name: vector<u8>,\n        \
                    description: vector<u8>,\n        \
                    url: vector<u8>,\n        \
                    attribute_keys: vector<vector<u8>>,\n        \
                    attribute_values: vector<vector<u8>>,\n        \
                    max_supply: u64,\n        \
                    mint: &mut MintAuthority<{witness}>,\n        \
                    sale_outlet: u64,\n        \
                    launchpad: &mut Slingshot<{witness}, {market_type}>,\n        \
                    ctx: &mut TxContext,\n    \
                ) {{\n        \
                    collectible::prepare_launchpad_mint<{witness}, {market_type}>(\n            \
                        name,\n            \
                        description,\n            \
                        url,\n            \
                        attribute_keys,\n            \
                        attribute_values,\n            \
                        max_supply,\n            \
                        mint,\n            \
                        sale_outlet,\n            \
                        launchpad,\n            \
                        ctx,\n        \
                    );\n    \
                }}",
                witness = witness,
                market_type = market_type,
            ),
            NftType::CNft => format!(
                "public entry fun prepare_mint(\n        \
                    name: vector<u8>,\n        \
                    description: vector<u8>,\n        \
                    url: vector<u8>,\n        \
                    attribute_keys: vector<vector<u8>>,\n        \
                    attribute_values: vector<vector<u8>>,\n        \
                    max_supply: u64,\n        \
                    mint: &mut MintAuthority<{witness}>,\n        \
                    sale_outlet: u64,\n        \
                    launchpad: &mut Slingshot<{witness}, {market_type}>,\n        \
                    ctx: &mut TxContext,\n    \
                ) {{\n        \
                    c_nft::prepare_launchpad_mint<{witness}, {market_type}, c_nft::Data>(\n            \
                        name,\n            \
                        description,\n            \
                        url,\n            \
                        attribute_keys,\n            \
                        attribute_values,\n            \
                        max_supply,\n            \
                        mint,\n            \
                        sale_outlet,\n            \
                        launchpad,\n            \
                        ctx,\n        \
                    );\n    \
                }}",
                witness = witness,
                market_type = market_type,
            ),
        };
        func.into_boxed_str()
    }
}

pub enum SalesType {
    SingleMarket,
    MultiMarket,
}

#[derive(Deserialize)]
#[serde(tag = "market_type", rename_all = "snake_case")]
pub enum MarketType {
    FixedPrice {
        prices: Vec<u64>,
        whitelists: Vec<bool>,
    },
}

impl MarketType {
    pub fn market_type(&self) -> Box<str> {
        match self {
            MarketType::FixedPrice { .. } => "FixedPriceMarket",
        }
        .into()
    }

    pub fn market_module(&self) -> Box<str> {
        match self {
            MarketType::FixedPrice { .. } => "fixed_price",
        }
        .into()
    }
}
