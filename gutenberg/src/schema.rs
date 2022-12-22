//! Module containing the core logic to parse the `config.yaml` file into a
//! struct `Schema`, acting as an intermediate data structure, to write
//! the associated Move module and dump into a default or custom folder defined
//! by the caller.
use crate::err::GutenError;
use crate::types::{MarketType, Markets, NftType, Tag};

use serde::Deserialize;
use strfmt::strfmt;

use std::collections::HashMap;
use std::fmt::Write;
use std::fs;

/// Struct that acts as an intermediate data structure representing the yaml
/// configuration of the NFT collection.
#[derive(Debug, Deserialize)]
#[serde(rename_all = "PascalCase")]
pub struct Schema {
    pub collection: Collection,
    pub nft_type: NftType,
    pub launchpad: Launchpad,
}

/// Contains the metadata fields of the collection
#[derive(Debug, Deserialize)]
pub struct Collection {
    /// The name of the collection
    pub name: Box<str>,
    /// The description of the collection
    pub description: Box<str>,
    /// The symbol/ticker of the collection
    pub symbol: Box<str>,
    /// A set of strings that categorize the domain in which the NFT operates
    pub tags: Vec<Tag>,
    /// The royalty fees creators accumulate on the sale of NFTs
    pub royalty_fee_bps: Box<str>,
    /// Field for extra data
    pub url: Box<str>,
}

/// Contains the market configurations of the launchpad
#[derive(Debug, Deserialize)]
pub struct Launchpad {
    pub admin: Box<str>,
    pub receiver: Box<str>,
    /// Enum field containing the MarketType and its corresponding
    /// config parameters such as price and whitelisting
    #[serde(flatten)]
    pub markets: Markets,
}

impl Schema {
    pub fn module_name(&self) -> Box<str> {
        self.collection
            .name
            .to_lowercase()
            .replace(' ', "_")
            .into_boxed_str()
    }

    /// Higher level method responsible for generating Move code from the
    /// struct `Schema` and dump it into a default folder
    /// `../sources/examples/<module_name>.move` or custom folder defined by
    /// the caller.
    pub fn write_move<W: std::io::Write>(
        &self,
        mut output: W,
    ) -> Result<(), GutenError> {
        let file_path = "templates/template.move";

        let fmt = fs::read_to_string(file_path)
            .expect("Should have been able to read the file");

        // let nft_type = self.nft_type.nft_type().into_boxed_str();
        // let market_type = self.launchpad.market_type.market_type();
        // let is_embedded = self.nft_type.is_embedded();
        // let is_embedded_str = is_embedded.to_string().into_boxed_str();
        // let market_module = &self.launchpad.market_type.market_module();
        let module_name = self.module_name();

        let witness = self
            .collection
            .name
            .to_uppercase()
            .replace(' ', "")
            .into_boxed_str();

        let tags = self.write_tags();

        let init_launchpad = self.init_launchpad();

        let mut vars = HashMap::new();

        vars.insert("module_name", &module_name);
        vars.insert("witness", &witness);
        vars.insert("name", &self.collection.name);
        vars.insert("description", &self.collection.description);
        vars.insert("url", &self.collection.url);
        vars.insert("symbol", &self.collection.symbol);
        vars.insert("royalty_fee_bps", &self.collection.royalty_fee_bps);
        vars.insert("tags", &tags);
        vars.insert("launchpad_modules", &launchpad_modules);
        vars.insert("launchpad", &launchpad);

        let vars: HashMap<String, String> = vars
            .into_iter()
            .map(|(k, v)| (k.to_string(), v.to_string()))
            .collect();

        output.write_all(
            strfmt(&fmt, &vars)
                // This is expected not to result in an error since we
                // have explicitly handled all error cases
                .unwrap_or_else(|_| {
                    panic!("This error is not expected and should not occur.")
                })
                .as_bytes(),
        )?;

        Ok(())
    }

    /// Generates Move code to push tags to a Move `vector` structure
    pub fn write_tags(&self) -> Box<str> {
        let mut out = String::from("let tags = tags::empty(ctx);\n");

        for tag in self.collection.tags.iter() {
            out.write_fmt(format_args!(
                "        tags::add_tag(&mut tags, tags::{}());\n",
                tag.to_string()
            ))
            .unwrap();
        }

        out.push_str(
            "        tags::add_collection_tag_domain(&mut collection, &mut mint_cap, tags);"
        );

        out.into_boxed_str()
    }

    pub fn init_launchpad(&self) -> Box<str> {
        format!(
            "let launchpad = launchpad::new(
                {admin},
                {receiver},
                false,
                flat_fee::new(0, ctx),
                ctx,
            );

            let slot = slot::new(
                &launchpad,
                {admin},
                {receiver},
                ctx,
            );",
            admin = self.launchpad.admin,
            receiver = self.launchpad.receiver,
        )
        .into_boxed_str()
    }

    // /// Associated function that generates Move code to declare and push market
    // /// specific data.
    // pub fn write_define_market_arguments(&self) -> Box<str> {
    //     let mut out = String::new();

    //     match &self.launchpad.market_type {
    //         MarketType::FixedPrice {}
    //     }

    //     match &self.launchpad.market_type {
    //         MarketType::FixedPrice { whitelists, .. }
    //         | MarketType::Auction { whitelists, .. } => {
    //             out.write_str("let whitelist = vector::empty();\n").unwrap();
    //             for w in whitelists {
    //                 out.write_fmt(format_args!(
    //                     "        vector::push_back(&mut whitelist, {w});\n"
    //                 ))
    //                 .unwrap();
    //             }
    //         }
    //     }

    //     match &self.launchpad.market_type {
    //         MarketType::FixedPrice { prices, .. } => {
    //             out.write_str("\n        let prices = vector::empty();\n")
    //                 .unwrap();
    //             for p in prices {
    //                 out.write_fmt(format_args!(
    //                     "        vector::push_back(&mut prices, {p});\n"
    //                 ))
    //                 .unwrap();
    //             }
    //         }
    //         MarketType::Auction { reserve_prices, .. } => {
    //             out.write_str(
    //                 "\n        let reserve_prices = vector::empty();\n",
    //             )
    //             .unwrap();
    //             for p in reserve_prices {
    //                 out.write_fmt(format_args!(
    //                     "        vector::push_back(&mut reserve_prices, {p});\n"
    //                 ))
    //                 .unwrap();
    //             }
    //         }
    //     };

    //     out.into_boxed_str()
    // }

    // /// Associated function that generates Move code to declare pass market
    // /// specific arguments to the `create_market` function.
    // pub fn write_market_arguments(&self) -> Box<str> {
    //     match self.launchpad.market_type {
    //         MarketType::FixedPrice { .. } => "whitelist, prices,",
    //         MarketType::Auction { .. } => "whitelist, reserve_prices,",
    //     }
    //     .into()
    // }
}
