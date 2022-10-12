fn main() -> Result<(), Box<dyn std::error::Error>> {
    let f = std::fs::File::open("config.yaml")?;
    let data: serde_yaml::Value = serde_yaml::from_reader(f)?;

    println!("Read YAML string: {:?}", data);

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
        .unwrap();

    let receiver = serde_yaml::to_value(&data["Collection"]["receiver"])?
        .as_str()
        .unwrap()
        .to_string();

    let royalty_fee_bps = serde_yaml::to_value(&data["Collection"]["royalty_fee_bps"])?
        .as_u64()
        .unwrap();

    let extra_data = serde_yaml::to_value(&data["Collection"]["data"])?
        .as_str()
        .unwrap()
        .to_string();

    let is_mutable = serde_yaml::to_value(&data["Collection"]["is_mutable"])?
        .as_bool()
        .unwrap();

    let tags = serde_yaml::to_value(&data["Collection"]["tags"])?
        .as_sequence()
        .unwrap();

    println!("{:?}", module_name);
    println!("{:?}", witness);
    println!("{:?}", description);
    println!("{:?}", symbol);
    println!("{:?}", max_supply);
    println!("{:?}", receiver);
    println!("{:?}", royalty_fee_bps);
    println!("{:?}", extra_data);
    println!("{:?}", is_mutable);
    println!("{:?}", tags);

    let nft_type = serde_yaml::to_value(&data["NftType"])?
        .as_str()
        .unwrap()
        .to_string();

    println!("{:?}", nft_type);

    Ok(())
}
