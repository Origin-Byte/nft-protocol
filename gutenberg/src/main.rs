use std::fs;
extern crate strfmt;
use std::collections::HashMap;
use std::fs::File;
use std::io::prelude::*;
use strfmt::strfmt;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let f = std::fs::File::open("config.yaml")?;
    let data: serde_yaml::Value = serde_yaml::from_reader(f)?;

    // println!("Read YAML string: {:?}", data);

    let name = serde_yaml::to_value(&data["Collection"]["name"])?
        .as_str()
        .unwrap()
        .to_string();

    let module_name = serde_yaml::to_value(&data["Collection"]["name"])?
        .as_str()
        .unwrap()
        .to_string()
        .to_lowercase()
        .replace(" ", "_");

    let witness = serde_yaml::to_value(&data["Collection"]["name"])?
        .as_str()
        .unwrap()
        .to_string()
        .to_uppercase()
        .replace(" ", "");

    let description = serde_yaml::to_value(&data["Collection"]["description"])?
        .as_str()
        .unwrap()
        .to_string();

    let symbol = serde_yaml::to_value(&data["Collection"]["symbol"])?
        .as_str()
        .unwrap()
        .to_string();

    let max_supply = serde_yaml::to_value(&data["Collection"]["max_supply"])?
        .as_u64()
        .unwrap()
        .to_string();

    let receiver = serde_yaml::to_value(&data["Collection"]["receiver"])?
        .as_str()
        .unwrap()
        .to_string();

    let royalty_fee_bps = serde_yaml::to_value(&data["Collection"]["royalty_fee_bps"])?
        .as_u64()
        .unwrap()
        .to_string();

    let extra_data = serde_yaml::to_value(&data["Collection"]["data"])?
        .as_str()
        .unwrap()
        .to_string();

    let is_mutable = serde_yaml::to_value(&data["Collection"]["is_mutable"])?
        .as_bool()
        .unwrap()
        .to_string();

    let tag_binding = serde_yaml::to_value(&data["Collection"]["tags"])?;
    let tags_vec = tag_binding.as_sequence().unwrap();

    let mut tags: String = "".to_string();

    for tag_v in tags_vec {
        let tag_str = tag_v.as_str().unwrap().to_string();
        let tag = format!("        vector::push_back(&mut tags, b\"{}\");", tag_str);

        tags = [tags, tag].join("\n").to_string();
    }

    let nft_type = serde_yaml::to_value(&data["NftType"])?
        .as_str()
        .unwrap()
        .to_string();

    let market_module = serde_yaml::to_value(&data["Launchpad"]["market_type"])?
        .as_str()
        .unwrap()
        .to_string();

    let market_type = "FixedPriceMarket".to_string();
    let sale_type = "create_single_market".to_string();
    let is_embedded = "true".to_string();

    let sale_price = serde_yaml::to_value(&data["Launchpad"]["price"])?
        .as_u64()
        .unwrap()
        .to_string();

    let whitelist = serde_yaml::to_value(&data["Launchpad"]["whitelist"])?
        .as_bool()
        .unwrap()
        .to_string();

    let file_path = "templates/template.txt";

    let fmt = fs::read_to_string(file_path).expect("Should have been able to read the file");

    let mut vars = HashMap::new();
    vars.insert("name".to_string(), name);
    vars.insert("module_name".to_string(), module_name);
    vars.insert("witness".to_string(), witness);
    vars.insert("nft_type".to_string(), nft_type);
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
    vars.insert("whitelist".to_string(), whitelist);
    vars.insert("sale_price".to_string(), sale_price);

    let mut f = File::create("my_nfts.move")?;
    f.write_all(strfmt(&fmt, &vars).unwrap().as_bytes())?;

    Ok(())
}
