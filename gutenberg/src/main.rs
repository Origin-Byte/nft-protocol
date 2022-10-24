extern crate strfmt;

pub mod schema;
pub mod types;
pub mod err;

use crate::schema::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let f = std::fs::File::open("config.yaml")?;
    let yaml: serde_yaml::Value = serde_yaml::from_reader(f)?;

    let schema = Schema::from_yaml(&yaml)?;

    schema.write_move()?;

    Ok(())
}
