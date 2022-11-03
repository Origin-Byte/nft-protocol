use gutenberg::err::*;
use gutenberg::prelude::*;
use gutenberg::schema::*;

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

    let f = std::fs::File::open("config.yaml")?;
    let schema = serde_yaml::from_reader::<_, Schema>(f)?;

    let output = opt.path.unwrap_or_else(|| {
        PathBuf::from_str(&format!(
            "../sources/examples/{}.move",
            &schema.module_name().to_string()
        ))
        .unwrap()
    });

    match output.parent() {
        Some(p) => fs::create_dir_all(p)?,
        None => {}
    }

    let mut f = File::create(output)?;
    schema.write_move(&mut f)?;

    Ok(())
}
