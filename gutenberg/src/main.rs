use gutenberg::prelude::*;

use gumdrop::Options;

use std::fs;
use std::path::PathBuf;

#[derive(Debug, Options)]
struct Opt {
    #[options(help = "print help message")]
    help: bool,
    #[options(free, help = "output file path, stdout if not present")]
    path: Option<PathBuf>,
    #[options(help = "configuration file", default = "config.yaml")]
    config: PathBuf,
}

fn main() -> Result<(), GutenError> {
    let opt = Opt::parse_args_default_or_exit();

    let f = fs::File::open(opt.config)?;

    let de = serde_yaml::Deserializer::from_reader(f);
    let schema: Schema = match serde_path_to_error::deserialize(de) {
        Ok(schema) => schema,
        Err(err) => todo!(),
    };

    let output = opt.path.unwrap_or_else(|| {
        PathBuf::from(&format!(
            "../examples/{}.move",
            &schema.module_name().to_string()
        ))
    });

    if let Some(p) = output.parent() {
        fs::create_dir_all(p)?;
    }

    let mut f = fs::File::create(output)?;
    if let Err(err) = schema.write_move(&mut f) {
        eprintln!("{err}");
    }

    Ok(())
}
