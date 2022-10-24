extern crate strfmt;

pub mod schema;
pub mod types;

use crate::schema::*;
use crate::types::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let f = std::fs::File::open("config.yaml")?;
    let yaml: serde_yaml::Value = serde_yaml::from_reader(f)?;

    let schema = Schema::from_yaml(&yaml)?;

    schema.write_move()?;

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
