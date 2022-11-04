//! Integration tests directly check the generated examples in the parent directory

use gutenberg::schema::Schema;
use std::fs::{self, File};

/// Check that all examples have correct schema
#[test]
fn example_schema() {
    fs::read_dir("./examples")
        .unwrap()
        .map(Result::unwrap)
        .map(|dir| {
            let config = File::open(dir.path()).unwrap();
            assert_schema(config);
        })
        .collect::<()>()
}

#[test]
fn multi_sales() {
    let config = File::open("./examples/multi_sales.yaml").unwrap();
    let expected =
        fs::read_to_string("../sources/examples/multi_sales.move").unwrap();

    assert_equal(config, expected);
}

#[test]
fn collectible() {
    let config = File::open("./examples/collectibles.yaml").unwrap();
    let expected =
        fs::read_to_string("../sources/examples/collectibles.move").unwrap();

    assert_equal(config, expected);
}

/// Asserts that the config file has correct schema
fn assert_schema(config: File) -> Schema {
    serde_yaml::from_reader::<_, Schema>(config).unwrap()
}

/// Asserts that the generated file matches the expected output
fn assert_equal(config: File, expected: String) {
    let mut output = Vec::new();
    assert_schema(config).write_move(&mut output).unwrap();
    let output = String::from_utf8(output).unwrap();

    pretty_assertions::assert_eq!(output, expected);
}
