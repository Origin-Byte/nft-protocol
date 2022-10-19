use std::str::FromStr;

#[derive(Debug)]
pub enum NftType {
    Unique,
    Collectibles,
    CNft,
}

#[derive(Debug)]
pub enum FieldType {
    StrLit,
    Bool,
    Number,
}

impl FromStr for NftType {
    type Err = ();

    fn from_str(input: &str) -> Result<NftType, Self::Err> {
        match input {
            "Unique" => Ok(NftType::Unique),
            "Collectible" => Ok(NftType::Collectibles),
            "Bat" => Ok(NftType::CNft),
            _ => Err(()),
        }
    }
}

impl NftType {
    pub fn nft_module(&self) -> String {
        let nft_module = match self {
            NftType::Unique => "unique_nft",
            NftType::Collectibles => "collectibles",
            NftType::CNft => "c_nft",
        };
        nft_module.to_string()
    }

    pub fn nft_type(&self) -> String {
        let nft_type = match self {
            NftType::Unique => "unique",
            NftType::Collectibles => "collectibles",
            NftType::CNft => "c_nft",
        };
        nft_type.to_string()
    }

    pub fn is_embedded(&self) -> bool {
        let is_embedded = match self {
            NftType::Unique => true,
            NftType::Collectibles => false,
            NftType::CNft => false,
        };
        is_embedded
    }
}

pub enum SalesType {
    SingleMarket, // create_single_market
    MultiMarket,
}

pub enum MarketType {
    FixedPriceMarket { sales: Vec<FixedPrice> },
}

impl MarketType {
    pub fn to_string(&self) -> String {
        "FixedPriceMarket".to_string()
    }

    pub fn market_module(&self) -> String {
        "fixed_price".to_string()
    }
}

pub struct FixedPrice {
    price: u64,
    whitelist: bool,
}

impl FixedPrice {
    pub fn new(price: u64, whitelist: bool) -> Self {
        FixedPrice {
            price: price,
            whitelist: whitelist,
        }
    }
}
