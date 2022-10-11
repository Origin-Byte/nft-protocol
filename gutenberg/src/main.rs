fn main() -> Result<(), Box<dyn std::error::Error>> {
    let f = std::fs::File::open("config.yaml")?;
    let data: serde_yaml::Value = serde_yaml::from_reader(f)?;

    println!("Read YAML string: {:?}", data);

    // data["foo"]["bar"]
    //     .as_str()
    //     .map(|s| s.to_string())
    //     .ok_or(anyhow!("Could not find key foo.bar in something.yaml"))

    let module_name = serde_yaml::to_string(&data["Collection"]["name"])?
        .to_lowercase()
        .replace(" ", "_");

    let witness = serde_yaml::to_string(&data["Collection"]["name"])?
        .to_uppercase()
        .replace(" ", "");

    let description = serde_yaml::to_string(&data["Collection"]["description"])?;
    let symbol = serde_yaml::to_string(&data["Collection"]["symbol"])?;

    let max_supply = serde_yaml::to_value(&data["Collection"]["max_supply"])?
        .as_u64()
        .unwrap();

    let receiver = serde_yaml::to_string(&data["Collection"]["receiver"])?;

    let royalty_fee_bps = serde_yaml::to_value(&data["Collection"]["royalty_fee_bps"])?
        .as_u64()
        .unwrap();

    let extra_data = serde_yaml::to_string(&data["Collection"]["data"])?;

    let is_mutable = serde_yaml::to_value(&data["Collection"]["is_mutable"])?
        .as_bool()
        .unwrap();

    // let binding = serde_yaml::to_value(&data["Collection"]["name"])?;
    // let new_name = binding.as_str().unwrap();

    println!("{:?}", module_name);
    println!("{:?}", witness);
    println!("{:?}", description);
    println!("{:?}", symbol);
    println!("{:?}", max_supply);
    println!("{:?}", receiver);
    println!("{:?}", is_mutable);
    // println!("{:?}", new_name);

    Ok(())
}

pub fn trim_newline(s: &mut String) {
    if s.ends_with('\n') {
        s.pop();
    }
}
