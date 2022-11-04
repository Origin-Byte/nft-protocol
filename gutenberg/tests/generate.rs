//! Integration tests directly check the generated examples in the parent directory

use gutenberg::schema::Schema;
use std::fs::File;

#[test]
fn multi_sales() {
    let config = File::open("./examples/multi_sales.yaml").unwrap();
    let expected =
        std::fs::read_to_string("../sources/examples/multi_sales.move")
            .unwrap();

    assert_equal(config, expected);
}

#[test]
fn collectible() {
    let config = File::open("./examples/collectibles.yaml").unwrap();
    let expected =
        std::fs::read_to_string("../sources/examples/collectibles.move")
            .unwrap();

    assert_equal(config, expected);
}

fn assert_equal(config: File, expected: String) {
    let yaml: serde_yaml::Value = serde_yaml::from_reader(config).unwrap();
    let schema = Schema::from_yaml(&yaml).unwrap();

    let mut output = Vec::new();
    schema.write_move(&mut output).unwrap();
    let output = String::from_utf8(output).unwrap();

    pretty_assertions::assert_eq!(output, expected);
}
