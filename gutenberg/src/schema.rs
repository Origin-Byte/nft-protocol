extern crate strfmt;
use crate::types::*;
use crate::err::{self, GutenError};
// use anyhow::{Context, Result};

use std::collections::HashMap;
use std::io::prelude::*;
use std::str::FromStr;
use std::fs::File;
use std::fs;

use strfmt::strfmt;
use serde_yaml::Value;

pub struct Schema {
    pub collection: Collection,
    pub nft_type: NftType,
    pub launchpad: Launchpad,
}

pub struct Collection {
    pub name: Box<str>,
    pub description: Box<str>,
    pub symbol: Box<str>,
    pub max_supply: Box<str>,
    pub receiver: Box<str>,
    pub tags: Vec<String>,
    pub royalty_fee_bps: Box<str>,
    pub is_mutable: Box<str>,
    pub data: Box<str>,
}

pub struct Launchpad {
    pub market_type: MarketType,
}

impl Collection {
    pub fn from_yaml(yaml: &Value) -> Result<Self, Box<dyn std::error::Error>> {
        let tag_binding = serde_yaml::to_value(&yaml["Collection"]["tags"])?;

        let tags: Vec<String> = tag_binding
            .as_sequence()
            .ok_or_else(|| {err::miss("tags")})?
            .into_iter()
            .map(|tag| {
                let tag_n = tag
                    .as_str()
                    .ok_or_else(|| err::format("tags"))?
                    .to_string();

                Ok(tag_n)
            })
            .collect::<Result<Vec<String>, GutenError>>()?;

        let collection = Collection {
            name: get(&yaml, "Collection", "name", FieldType::StrLit)?,
            description: get(
                &yaml, "Collection", "description", FieldType::StrLit
            )?,
            symbol: get(&yaml, "Collection", "symbol", FieldType::StrLit)?,
            max_supply: get(
                &yaml, "Collection", "max_supply", FieldType::Number
            )?,
            receiver: get(&yaml, "Collection", "receiver", FieldType::StrLit)?,
            royalty_fee_bps: get(
                &yaml, "Collection", "royalty_fee_bps", FieldType::Number
            )?,
            tags,
            data: get(&yaml, "Collection", "data", FieldType::StrLit)?,
            is_mutable: get(&yaml, "Collection", "is_mutable", FieldType::Bool)?,
        };

        Ok(collection)
    }
}

impl Launchpad {
    pub fn from_yaml(yaml: &Value) -> Result<Self, GutenError> {
        let price_binding = serde_yaml::to_value(&yaml["Launchpad"]["prices"])?;
        let wl_binding = serde_yaml::to_value(&yaml["Launchpad"]["whitelists"])?;

        if !price_binding.is_sequence() {
            if price_binding.is_null() {
                return Err(err::miss("prices"))
            }
            return Err(err::format("prices"))

        }

        if !wl_binding.is_sequence() {
            if price_binding.is_null() {
                return Err(err::miss("whitelists"))
            }
            return Err(err::format("whitelists"))
        }

        let prices_vec = price_binding
            .as_sequence()
            .ok_or_else(|| {err::miss("prices")})?;

        let wl_vec = wl_binding
            .as_sequence()
            .ok_or_else(|| {err::miss("whitelists")})?;

        let market_vec = prices_vec
            .iter()
            .zip(wl_vec)
            .map(|mkt| {
                let price = mkt.0
                    .as_u64()
                    .ok_or_else(|| {err::miss("whitelists")})?;
                let whitelist = mkt.1
                    .as_bool()
                    .ok_or_else(|| {err::miss("whitelists")})?;
                
                Ok(FixedPrice::new(price,whitelist))
            })
            .collect::<Result<Vec<FixedPrice>, GutenError>>()?;


        let launchpad = Launchpad {
            market_type: MarketType::FixedPriceMarket { sales: market_vec },
        };

        Ok(launchpad)
    }
}

impl Schema {
    pub fn from_yaml(yaml: &Value) -> Result<Self, Box<dyn std::error::Error>> {
        let nft_type_str = serde_yaml::to_value(&yaml["NftType"])?
            .as_str()
            .ok_or_else(|| err::miss("NftType"))?
            .to_string();

        let nft_type = NftType::from_str(nft_type_str.as_str())
            .unwrap_or_else(|_| 
                panic!("Unsupported NftType provided.")
            );

        let schema = Schema {
            collection: Collection::from_yaml(yaml)?,
            nft_type,
            launchpad: Launchpad::from_yaml(yaml)?,
        };

        Ok(schema)
    }

    pub fn write_tags(&self) -> Box<str> {
        let tags_vec = &self.collection.tags;

        tags_vec
            .into_iter()
            .map(|tag| {
                format!(
                    "        vector::push_back(&mut tags, b\"{}\");",
                    tag
                )})
            .fold("".to_string(), |acc, x, | acc + "\n" + &x)
            .into_boxed_str()
    }

    pub fn write_whitelists(whitelists: &mut Vec<bool>) -> Result<Box<str>, GutenError> {
        let define_whitelists = if whitelists.len() == 1 {
            "let whitelisting = ".to_string() 
                + &whitelists.pop()
                    // This is expected not to result in an error since 
                    // the field whitelists has already been validated
                    .ok_or_else(|| GutenError::UnexpectedErrror)?
                    .to_string() 
                + ";"
        } else {
            let mut loc = "let whitelisting = vector::empty();\n".to_string();
    
            for _w in whitelists.clone() {
                loc = loc 
                    + "        vector::push_back(&mut whitelisting, " 
                    + &whitelists.pop()
                        // This is expected not to result in an error since 
                        // the field whitelists has already been validated
                        .ok_or_else(|| GutenError::UnexpectedErrror)?
                        .to_string() 
                    + ");\n"
            }
            loc
        };
        
        Ok(define_whitelists.into_boxed_str())
    }

    pub fn write_prices(prices: &mut Vec<u64>) -> Result<Box<str>, GutenError> {
        let define_prices = if prices.len() == 1 {
            "let pricing = ".to_string() 
                + &prices.pop()
                    // This is expected not to result in an error since 
                    // the field whitelists has already been validated
                    .ok_or_else(|| GutenError::UnexpectedErrror)?
                    .to_string()
                + ";"
        } else {
            let mut loc = "let pricing = vector::empty();\n".to_string();

            for _p in prices.clone() {
                loc = loc 
                    + "        vector::push_back(&mut pricing, " 
                    + &prices.pop()
                        // This is expected not to result in an error since 
                        // the field whitelists has already been validated
                        .ok_or_else(|| GutenError::UnexpectedErrror)?
                        .to_string() 
                    + ");\n"
            }
            loc.to_string()
        };
        
        Ok(define_prices.into_boxed_str())
    }

    pub fn get_sale_outlets(&self) -> (Vec<u64>, Vec<bool>) {
        match &self.launchpad.market_type {
            MarketType::FixedPriceMarket { sales } => {
                let prices: Vec<u64> = sales
                    .iter()
                    .map(|m| m.price)
                    .collect();

                let whitelists: Vec<bool> = sales
                    .iter()
                    .map(|m| m.whitelist)
                    .collect();

                (prices, whitelists)
            }
        }
    }

    pub fn write_move(&self) -> Result<(), Box<dyn std::error::Error>> {
        let file_path = "templates/template.txt";

        let fmt = fs::read_to_string(file_path)
            .expect("Should have been able to read the file");

        let nft_type = self.nft_type.nft_type().into_boxed_str();
        let market_type = self.launchpad.market_type.market_type();
        let is_embedded = self.nft_type.is_embedded();
        let is_embedded_str = is_embedded.to_string().into_boxed_str();
        let market_module = &self.launchpad.market_type.market_module();

        let module_name = self
            .collection
            .name
            .to_lowercase()
            .replace(" ", "_")
            .into_boxed_str();

        let witness = self
            .collection
            .name
            .to_uppercase()
            .replace(" ", "")
            .into_boxed_str();
        
        let tags = self.write_tags();

        let (mut prices, mut whitelists) = self.get_sale_outlets();
    
        let define_whitelists = Schema::write_whitelists(&mut whitelists)?;
        let define_prices = Schema::write_prices(&mut prices)?;
    
        let sale_type = if prices.len() == 1 {
            "create_single_market"
        } else {
            "create_multi_market"
        }.to_string().into_boxed_str();

        let market_module_imports = if is_embedded {
            format!("::{{Self, {}}}", market_type)
        } else {
            "".to_string()
        }.into_boxed_str();

        let slingshot_import = if is_embedded {
            "use nft_protocol::slingshot::Slingshot;"
        } else {
            ""
        }.to_string().into_boxed_str();

        let mint_func = self.nft_type.mint_func(
            &witness, &self.launchpad.market_type.market_type(),
        );

        let mut vars = HashMap::new();

        vars.insert("name", &self.collection.name);
        vars.insert("nft_type", &nft_type);
        vars.insert("description", &self.collection.description);
        vars.insert("max_supply", &self.collection.max_supply);
        vars.insert("symbol", &self.collection.symbol);
        vars.insert("receiver", &self.collection.receiver);
        vars.insert("royalty_fee_bps",&self.collection.royalty_fee_bps);
        vars.insert("extra_data", &self.collection.data);
        vars.insert("is_mutable", &self.collection.is_mutable);
        vars.insert("module_name", &module_name);
        vars.insert("witness", &witness);
        vars.insert("tags", &tags);
        vars.insert("market_type", &market_type);
        vars.insert("market_module", &market_module);
        vars.insert("market_module_imports", &market_module_imports,);
        vars.insert("slingshot_import", &slingshot_import);
        vars.insert("sale_type", &sale_type);
        vars.insert("is_embedded", &is_embedded_str);
        vars.insert("define_prices", &define_prices);
        vars.insert("define_whitelists", &define_whitelists);
        vars.insert("mint_function", &mint_func);

        let vars: HashMap<String, String> = vars
            .into_iter()
            .map(|(k, v)| (k.to_string(), v.to_string()))
            .collect();

        let path = format!(
            "../sources/examples/{}.move",
            &module_name.to_string()
        );

        let mut f = File::create(path)?;
        f.write_all(strfmt(&fmt, &vars)
            // This is expected not to result in an error since we
            // have explicitly handled all error cases
            .unwrap_or_else(|_| 
                panic!("This error is not expected and should not occur.")
            )
            .as_bytes())?;

        Ok(())
    }
}

pub fn get(
    data: &serde_yaml::Value,
    category: &str,
    field: &str,
    field_type: FieldType,
) -> Result<Box<str>, GutenError> {
    let value = serde_yaml::to_value(&data[category][field])?;

    let result = match field_type {
        FieldType::StrLit => value
            .as_str()
            .ok_or_else(|| err::format(field))?
            .to_string(),
        FieldType::Number => value
            .as_u64()
            .ok_or_else(|| err::format(field))?
            .to_string(),
        FieldType::Bool => value
            .as_bool()
            .ok_or_else(|| err::format(field))?
            .to_string(),
    };

    Ok(result.into_boxed_str())
}
