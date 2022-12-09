use thiserror::Error;

#[derive(Error, Debug)]
pub enum GutenError {
    #[error("Sale outlet parameters must have the same length")]
    MismatchedOutletParams,
    #[error("Parsing error has occured")]
    SerdeYaml(#[from] serde_yaml::Error),
    #[error("An IO error has occured")]
    IoError(#[from] std::io::Error),
}
