use thiserror::Error;
use std::fmt::Display;

#[derive(Error, Debug)]
pub enum GutenError {
    #[error("A field seems to be missing")]
    MissingField,
    #[error("A field seems to have the wrong format")]
    WrongFormat,
    #[error("Parsing error has occured")]
    SerdeYaml(serde_yaml::Error),
    #[error("An IO error has occured")]
    IoError(std::io::Error),
    #[error("An unexpected error has occurred")]
    UnexpectedErrror,
}

pub fn miss(msg: impl Display) -> GutenError {
    println!("[MissingField] {}", msg);

    GutenError::MissingField
}

pub fn format<'a>(msg: impl Display + PartialEq<&'a str>) -> GutenError {

    if (msg == "prices") | (msg == "whitelists") {
        let example = if msg =="prices" {"100" } else {"true"};

        println!(
            "[WrongFormat] Consider representing the field `{}` as an array \
            (e.g. [{}]) instead of a number (e.g. {})",
            msg,
            example,
            example,
        );
    } else {
        println!("[WrongFormat] The field `{}` has the wrong format", msg);
    }

    GutenError::WrongFormat
}

impl From<serde_yaml::Error> for GutenError {
    fn from(e: serde_yaml::Error) -> Self {
        GutenError::SerdeYaml(e)
    }
}
impl From<std::io::Error> for GutenError {
    fn from(e: std::io::Error) -> Self {
        GutenError::IoError(e)
    }
}