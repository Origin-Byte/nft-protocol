pub mod err;
pub mod prelude;
pub mod schema;
pub mod types;

use crate::err::*;
use crate::schema::*;

fn main() -> Result<(), GutenError> {
    let f = std::fs::File::open("config.yaml")?;

    let yaml: serde_yaml::Value = serde_yaml::from_reader(f)?;

    let schema = Schema::from_yaml(&yaml)?;

    schema.write_move()?;

    Ok(())
}
