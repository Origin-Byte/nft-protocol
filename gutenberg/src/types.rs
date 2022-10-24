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
            "Collectibles" => Ok(NftType::Collectibles),
            "CNft" => Ok(NftType::CNft),
            _ => {
                println!("The NftType provided is not supported");
                
                Err(())
            }
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
            NftType::Unique => "unique_nft",
            NftType::Collectibles => "collectibles",
            NftType::CNft => "c_nft",
        };
        nft_type.to_string()
    }

    pub fn is_embedded(&self) -> bool {
        match self {
            NftType::Unique => true,
            NftType::Collectibles => false,
            NftType::CNft => false,
        }
    }

    pub fn mint_func(&self, witness: &str, market_type: &str,) -> Box<str> {
        // TODO: Need to add support for unregulated collections
        let func = match self {
            NftType::Unique => format!(
                "public entry fun mint_nft(\n        \
                    name: vector<u8>,\n        \
                    description: vector<u8>,\n        \
                    url: vector<u8>,\n        \
                    attribute_keys: vector<vector<u8>>,\n        \
                    attribute_values: vector<vector<u8>>,\n        \
                    mint_authority: &mut MintAuthority<{}>,\n        \
                    sale_index: u64,\n        \
                    launchpad: &mut Slingshot<{}, {}>,\n        \
                    ctx: &mut TxContext,\n    \
                ) {{\n        \
                    unique_nft::mint_regulated_nft(\n            \
                        name,\n            \
                        description,\n            \
                        url,\n            \
                        attribute_keys,\n            \
                        attribute_values,\n            \
                        mint_authority,\n            \
                        sale_index,\n            \
                        launchpad,\n            \
                        ctx,\n        \
                    );\n    \
                }}",
                witness, witness, market_type
            ),
            NftType::Collectibles => format!(
                "public entry fun mint_nft<T>(\n        \
                    name: vector<u8>,\n        \
                    description: vector<u8>,\n        \
                    url: vector<u8>,\n        \
                    attribute_keys: vector<vector<u8>>,\n        \
                    attribute_values: vector<vector<u8>>,\n        \
                    max_supply: u64,\n        \
                    mint: &mut MintAuthority<{}>,\n        \
                    ctx: &mut TxContext,\n    \
                ) {{\n        \
                    collectibles::mint_regulated_nft_data(\n            \
                        name,\n            \
                        description,\n            \
                        url,\n            \
                        attribute_keys,\n            \
                        attribute_values,\n            \
                        max_supply,\n            \
                        mint,\n            \
                        ctx,\n        \
                    );\n    \
                }}",
                witness,
            ),
            NftType::CNft => format!(
                "public entry fun mint_nft(\n        \
                    name: vector<u8>,\n        \
                    description: vector<u8>,\n        \
                    url: vector<u8>,\n        \
                    attribute_keys: vector<vector<u8>>,\n        \
                    attribute_values: vector<vector<u8>>,\n        \
                    max_supply: u64,\n        \
                    mint: &mut MintAuthority<{}>,\n        \
                    ctx: &mut TxContext,\n    \
                ) {{\n        \
                    c_nft::mint_regulated_nft_data<{}, c_nft::Data>(\n            \
                        name,\n            \
                        description,\n            \
                        url,\n            \
                        attribute_keys,\n            \
                        attribute_values,\n            \
                        max_supply,\n            \
                        mint,\n            \
                        ctx,\n        \
                    );\n    \
                }}",
                witness, witness
            ),
        };
        func.into_boxed_str()
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
    pub fn market_type(&self) -> Box<str> {
        "FixedPriceMarket".to_string().into_boxed_str()
    }

    pub fn market_module(&self) -> Box<str> {
        "fixed_price".to_string().into_boxed_str()
    }
}

pub struct FixedPrice {
    pub price: u64,
    pub whitelist: bool,
}

impl FixedPrice {
    pub fn new(price: u64, whitelist: bool) -> Self {
        FixedPrice {
            price,
            whitelist,
        }
    }
}
