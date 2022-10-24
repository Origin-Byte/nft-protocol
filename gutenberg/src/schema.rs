extern crate strfmt;
use crate::types::*;

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
    pub name: String,
    pub description: String,
    pub symbol: String,
    pub max_supply: String,
    pub receiver: String,
    pub tags: Vec<String>,
    pub royalty_fee_bps: String,
    pub is_mutable: String,
    pub data: String,
}

pub struct Launchpad {
    pub market_type: MarketType,
}

impl Collection {
    pub fn from_yaml(yaml: &Value) -> Result<Self, Box<dyn std::error::Error>> {
        let tag_binding = serde_yaml::to_value(&yaml["Collection"]["tags"])?;
        let tags_vec = tag_binding.as_sequence().unwrap();

        let mut tags = Vec::new();

        for tag_v in tags_vec {
            let tag = tag_v.as_str().unwrap().to_string();
            tags.push(tag);
        }

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
            tags: tags,
            data: get(&yaml, "Collection", "data", FieldType::StrLit)?,
            is_mutable: get(&yaml, "Collection", "is_mutable", FieldType::Bool)?,
        };

        Ok(collection)
    }
}

impl Launchpad {
    pub fn from_yaml(yaml: &Value) -> Result<Self, Box<dyn std::error::Error>> {
        let price_binding = serde_yaml::to_value(&yaml["Launchpad"]["prices"])?;
        let wl_binding = serde_yaml::to_value(&yaml["Launchpad"]["whitelists"])?;

        let prices_vec = price_binding.as_sequence().unwrap();
        let wl_vec = wl_binding.as_sequence().unwrap();

        let market_vec = prices_vec
            .iter()
            .zip(wl_vec)
            .map(|mkt| FixedPrice::new(
                mkt.0.as_u64().unwrap(), mkt.1.as_bool().unwrap()
            ))
            .collect();

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
            .unwrap()
            .to_string();

        let nft_type = NftType::from_str(nft_type_str.as_str()).unwrap();

        let schema = Schema {
            collection: Collection::from_yaml(yaml)?,
            nft_type,
            launchpad: Launchpad::from_yaml(yaml)?,
        };

        Ok(schema)
    }

    pub fn write_move(&self) -> Result<(), Box<dyn std::error::Error>> {
        let file_path = "templates/template.txt";

        let fmt = fs::read_to_string(file_path)
            .expect("Should have been able to read the file");

        let mut vars = HashMap::new();
        vars.insert("name".to_string(), self.collection.name.clone());
        vars.insert("nft_type".to_string(), self.nft_type.nft_type().clone());
        vars.insert("description".to_string(), self.collection.description.clone());
        vars.insert("max_supply".to_string(), self.collection.max_supply.clone());
        vars.insert("symbol".to_string(), self.collection.symbol.clone());
        vars.insert("receiver".to_string(), self.collection.receiver.clone());
        vars.insert(
            "royalty_fee_bps".to_string(),
           self.collection.royalty_fee_bps.clone(),
        );
        vars.insert("extra_data".to_string(), self.collection.data.clone());
        vars.insert("is_mutable".to_string(), self.collection.is_mutable.clone());

        let module_name = self.collection.name.to_lowercase().replace(" ", "_");
        let witness = self.collection.name.to_uppercase().replace(" ", "");

        let tags_vec = self.collection.tags.clone();

        let mut tags: String = "".to_string();

        for tag_v in tags_vec {
            let tag = format!(
                "        vector::push_back(&mut tags, b\"{}\");",
                tag_v
            );

            tags = [tags, tag].join("\n").to_string();
        }

        vars.insert("module_name".to_string(), module_name.clone());
        vars.insert("witness".to_string(), witness.clone());
        vars.insert("tags".to_string(), tags.clone());

        let (mut prices, mut whitelists) = match &self.launchpad.market_type {
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
        };

        let define_whitelists = if whitelists.len() == 1 {
            "let whitelisting = ".to_string() 
                + &whitelists.pop().unwrap().to_string() 
                + ";"
        } else {
            let mut loc = "let whitelisting = vector::empty();".to_string();

            for _w in whitelists.clone() {
                loc = loc 
                    + "vector::push_back(" 
                    + &whitelists.pop().unwrap().to_string() 
                    + ");"
            }
            loc
        };

        let sale_type = if prices.len() == 1 {
            "create_single_market".to_string()
        } else {
            "create_multi_market".to_string()
        };


        let define_prices = if prices.len() == 1 {
            "let pricing = ".to_string() 
                + &prices.pop().unwrap().to_string() 
                + ";"
        } else {
            let mut loc = "let pricing = vector::empty();".to_string();

            for _p in prices.clone() {
                loc = loc 
                    + "vector::push_back(" 
                    + &prices.pop().unwrap().to_string() 
                    + ");"
            }
            loc
        };

        vars.insert(
            "market_type".to_string(),
            self.launchpad.market_type.to_string().clone(),
        );
        vars.insert(
            "market_module".to_string(),
            self.launchpad.market_type.market_module().clone(),
        );

        vars.insert("sale_type".to_string(), sale_type.clone());
        vars.insert("is_embedded".to_string(), self.nft_type.is_embedded().clone());

        vars.insert("define_prices".to_string(), define_prices.clone());
        vars.insert("define_whitelists".to_string(), define_whitelists.clone());

        let mut f = File::create("my_nfts.move")?;
        f.write_all(strfmt(&fmt, &vars).unwrap().as_bytes())?;

        Ok(())
    }
}

pub fn get(
    data: &serde_yaml::Value,
    category: &str,
    field: &str,
    field_type: FieldType,
) -> Result<String, Box<dyn std::error::Error>> {
    let value = serde_yaml::to_value(&data[category][field])?;

    let result = match field_type {
        FieldType::StrLit => value.as_str().unwrap().to_string(),
        FieldType::Number => value.as_u64().unwrap().to_string(),
        FieldType::Bool => value.as_bool().unwrap().to_string(),
    };

    Ok(result)
}
