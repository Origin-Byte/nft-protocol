fn main() -> Result<(), Box<dyn std::error::Error>> {
    let f = std::fs::File::open("config_1.yaml")?;
    let data: serde_yaml::Value = serde_yaml::from_reader(f)?;

    println!("Read YAML string: {:?}", data);

    // data["foo"]["bar"]
    //     .as_str()
    //     .map(|s| s.to_string())
    //     .ok_or(anyhow!("Could not find key foo.bar in something.yaml"))

    Ok(())
}
