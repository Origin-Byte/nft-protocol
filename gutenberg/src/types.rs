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
    /// Writes Move code for an entry function meant to be called by
    /// the Creators to mint NFTs. Depending on the NFTtype the function
    /// parameters change, therefore pattern match the NFT type.
    pub fn mint_func(&self, witness: &str) -> Box<str> {
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
        };
        func.into_boxed_str()
    }
}

pub enum SalesType {
    SingleMarket,
    MultiMarket,
}

#[derive(Debug, Deserialize)]
pub struct Markets {
    markets: Vec<MarketType>,
}

#[derive(Debug, Deserialize)]
#[serde(tag = "market_type", rename_all = "snake_case")]
pub enum MarketType {
    FixedPrice { price: u64, whitelist: bool },
    Auction { reserve_price: u64, whitelist: bool },
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

    pub fn init_market(&self) -> Box<str> {
        match self {
            MarketType::FixedPrice { price, whitelist } => format!(
                "fixed_price::init_market<SUI>(
                        &mut slot,
                        {whitelist},
                        {price},
                        ctx,
                    );",
                whitelist = whitelist,
                price = price,
            )
            .into_boxed_str(),
            MarketType::Auction {
                reserve_price,
                whitelist,
            } => format!(
                "dutch_auction::init_market<SUI>(
                        &mut slot,
                        {whitelist},
                        {reserve_price},
                        ctx,
                    );",
                whitelist = whitelist,
                reserve_price = reserve_price,
            )
            .into_boxed_str(),
        }
        .into()
    }
}
