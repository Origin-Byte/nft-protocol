pub mod err;
pub mod prelude;
pub mod schema;
pub mod types;

use crate::err::*;
use crate::prelude::*;
use crate::schema::*;

use gumdrop::Options;

#[derive(Debug, Options)]
struct Opt {
    #[options(help = "print help message")]
    help: bool,
    #[options(help = "output file path, stdout if not present")]
    path: Option<PathBuf>,
    #[options(help = "configuration file", default = "config.yaml")]
    config: PathBuf,
}

fn main() -> Result<(), GutenError> {
    let opt = Opt::parse_args_default_or_exit();

    let f = std::fs::File::open(opt.config)?;

    let yaml: serde_yaml::Value = serde_yaml::from_reader(f)?;

    let schema = Schema::from_yaml(&yaml)?;

    schema.write_move(opt.path)?;

    Ok(())
}
