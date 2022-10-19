use crate::types::*;
use serde_yaml::Value;
use std::collections::HashMap;
use std::fs;
use std::str::FromStr;

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
    pub tags: Tags,
    pub royalty_fee_bps: String,
    pub is_mutable: String,
    pub data: String,
}

pub struct Launchpad {
    pub market_type: MarketType,
}

pub struct Tags {
    pub tags: Vec<String>,
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
            description: get(&yaml, "Collection", "description", FieldType::StrLit)?,
            symbol: get(&yaml, "Collection", "symbol", FieldType::StrLit)?,
            max_supply: get(&yaml, "Collection", "max_supply", FieldType::Number)?,
            receiver: get(&yaml, "Collection", "receiver", FieldType::StrLit)?,
            royalty_fee_bps: get(&yaml, "Collection", "royalty_fee_bps", FieldType::Number)?,
            tags: Tags { tags: tags },
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
            .map(|mkt| FixedPrice::new(mkt.0.as_u64().unwrap(), mkt.1.as_bool().unwrap()))
            .collect();

        let launchpad = Launchpad {
            market_type: MarketType::FixedPriceMarket { sales: market_vec },
        };

        Ok(launchpad)
    }
}

impl Schema {
    pub fn from_yaml(yaml: &Value) -> Result<Self, Box<dyn std::error::Error>> {
        let nft_type_str = serde_yaml::to_value(yaml["NftType"])?
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

    pub fn write_move(&self) {
        let file_path = "templates/template.txt";

        let fmt = fs::read_to_string(file_path).expect("Should have been able to read the file");

        let mut vars = HashMap::new();
        vars.insert("name".to_string(), self.collection.name);
        vars.insert("nft_type".to_string(), self.nft_type.nft_type());
        vars.insert("description".to_string(), self.collection.description);
        vars.insert("max_supply".to_string(), self.collection.max_supply);
        vars.insert("symbol".to_string(), self.collection.symbol);
        vars.insert("receiver".to_string(), self.collection.receiver);
        vars.insert(
            "royalty_fee_bps".to_string(),
            self.collection.royalty_fee_bps,
        );
        vars.insert("extra_data".to_string(), self.collection.data);
        vars.insert("is_mutable".to_string(), self.collection.is_mutable);

        // vars.insert("module_name".to_string(), module_name);
        // vars.insert("witness".to_string(), witness);
        // vars.insert("tags".to_string(), tags.to_string());

        self.launchpad.market_type

        let prices_binding = serde_yaml::to_value(&data["Launchpad"]["prices"])?;
        let prices_vec = price_binding.as_sequence().unwrap();
        // {define_whitelists}
        // {define_prices}

        vars.insert(
            "market_type".to_string(),
            self.launchpad.market_type.to_string(),
        );
        vars.insert(
            "market_module".to_string(),
            self.launchpad.market_type.market_module(),
        );

        vars.insert("sale_type".to_string(), sale_type);
        vars.insert("is_embedded".to_string(), is_embedded);

        let mut f = File::create("my_nfts.move")?;
        f.write_all(strfmt(&fmt, &vars).unwrap().as_bytes())?;
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
