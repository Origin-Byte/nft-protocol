use std::str::FromStr;

#[derive(Debug)]
pub enum NftType {
    Unique,
    Collectibles,
    CNft,
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
    pub fn get_nft_module(&self) -> String {
        let nft_module = match self {
            NftType::Unique => "unique_nft",
            NftType::Collectibles => "collectibles",
            NftType::CNft => "c_nft",
        };
        nft_module.to_string()
    }
}

pub enum SalesType {
    SingleMarket, // create_single_market
    MultiMarket,
}

pub enum MarketType {
    FixedPriceMarket,
}
