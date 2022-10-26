pub mod err;
pub mod prelude;
pub mod schema;
pub mod types;

use crate::err::*;
use crate::prelude::*;
use crate::schema::*;

#[derive(Debug, StructOpt)]
struct Opt {
    /// Output file path, stdout if not present
    #[structopt(parse(from_os_str))]
    path: Option<PathBuf>,
}

fn main() -> Result<(), GutenError> {
    let opt = Opt::from_args();

    let f = std::fs::File::open("config.yaml")?;

    let yaml: serde_yaml::Value = serde_yaml::from_reader(f)?;

    let schema = Schema::from_yaml(&yaml)?;

    schema.write_move(opt.path)?;

    Ok(())
}
