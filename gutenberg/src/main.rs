use std::fs;
extern crate strfmt;
use serde_yaml::Value;
use std::collections::HashMap;
use std::fs::File;
use std::io::prelude::*;
use std::str::FromStr;

use strfmt::strfmt;

pub mod schema;
pub mod types;

use crate::schema::*;
use crate::types::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let f = std::fs::File::open("config.yaml")?;
    let yaml: serde_yaml::Value = serde_yaml::from_reader(f)?;

    let schema = Schema::from_yaml(&yaml);

    // let name = get(&data, "Collection", "name", FieldType::StrLit)?;
    // let description = get(&data, "Collection", "description", FieldType::StrLit)?;
    // let symbol = get(&data, "Collection", "symbol", FieldType::StrLit)?;
    // let max_supply = get(&data, "Collection", "max_supply", FieldType::Number)?;
    // let receiver = get(&data, "Collection", "receiver", FieldType::StrLit)?;
    // let royalty_fee_bps = get(&data, "Collection", "royalty_fee_bps", FieldType::Number)?;
    // let extra_data = get(&data, "Collection", "data", FieldType::StrLit)?;
    // let is_mutable = get(&data, "Collection", "is_mutable", FieldType::Bool)?;

    let module_name = name.to_lowercase().replace(" ", "_");
    let witness = name.to_uppercase().replace(" ", "");

    let tag_binding = serde_yaml::to_value(&data["Collection"]["tags"])?;
    let tags_vec = tag_binding.as_sequence().unwrap();

    let mut tags: String = "".to_string();

    for tag_v in tags_vec {
        let tag_str = tag_v.as_str().unwrap().to_string();
        let tag = format!("        vector::push_back(&mut tags, b\"{}\");", tag_str);

        tags = [tags, tag].join("\n").to_string();
    }

    let nft_type_str = serde_yaml::to_value(&data["NftType"])?
        .as_str()
        .unwrap()
        .to_string();

    let nft_type = NftType::from_str(nft_type_str.as_str()).unwrap();
    let nft_module = nft_type.get_nft_module();

    let market_module = serde_yaml::to_value(&data["Launchpad"]["market_type"])?
        .as_str()
        .unwrap()
        .to_string();

    let market_type = "FixedPriceMarket".to_string();
    let sale_type = "create_single_market".to_string();
    let is_embedded = "true".to_string();

    let price_binding = serde_yaml::to_value(&data["Launchpad"]["prices"])?;
    let prices_vec = price_binding.as_sequence().unwrap();

    let mut prices = Vec::new();

    for price_v in prices_vec {
        let price = price_v.as_u64().unwrap();
        prices.push(price);
    }

    println!("{:?}", prices_vec);

    // let prices = serde_yaml::to_value(&data["Launchpad"]["price"])?
    //     .as_u64()
    //     .unwrap()
    //     .to_string();

    // let whitelist = serde_yaml::to_value(&data["Launchpad"]["whitelist"])?
    //     .as_bool()
    //     .unwrap()
    //     .to_string();

    let file_path = "templates/template.txt";

    let fmt = fs::read_to_string(file_path).expect("Should have been able to read the file");

    let mut vars = HashMap::new();
    vars.insert("name".to_string(), name);
    vars.insert("module_name".to_string(), module_name);
    vars.insert("witness".to_string(), witness);
    vars.insert("nft_type".to_string(), nft_module);
    vars.insert("description".to_string(), description);
    vars.insert("symbol".to_string(), symbol);
    vars.insert("max_supply".to_string(), max_supply);
    vars.insert("receiver".to_string(), receiver);
    vars.insert("royalty_fee_bps".to_string(), royalty_fee_bps);
    vars.insert("extra_data".to_string(), extra_data);
    vars.insert("is_mutable".to_string(), is_mutable);
    vars.insert("tags".to_string(), tags.to_string());

    vars.insert("market_type".to_string(), market_type);
    vars.insert("market_module".to_string(), market_module);
    vars.insert("sale_type".to_string(), sale_type);
    vars.insert("is_embedded".to_string(), is_embedded);
    // vars.insert("whitelist".to_string(), whitelist);
    // vars.insert("sale_price".to_string(), sale_price);

    let mut f = File::create("my_nfts.move")?;
    f.write_all(strfmt(&fmt, &vars).unwrap().as_bytes())?;

    Ok(())
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
