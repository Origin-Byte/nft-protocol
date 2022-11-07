//! Module containing the core logic to parse the `config.yaml` file into a
//! struct `Schema`, acting as an intermediate data structure, to write
//! the associated Move module and dump into a default or custom folder defined
//! by the caller.
use crate::prelude::*;

use serde::Deserialize;
use std::fmt::Write;

/// Struct that acts as an intermediate data structure representing the yaml
/// configuration of the NFT collection.
#[derive(Deserialize)]
#[serde(rename_all = "PascalCase")]
pub struct Schema {
    pub collection: Collection,
    pub nft_type: NftType,
    pub launchpad: Launchpad,
}

/// Contains the metadata fields of the collection
#[derive(Deserialize)]
pub struct Collection {
    /// The name of the collection
    pub name: Box<str>,
    /// The description of the collection
    pub description: Box<str>,
    /// The symbol/ticker of the collection
    pub symbol: Box<str>,
    /// The total supply of the collection
    pub max_supply: Box<str>,
    /// Address that receives the sale and royalty proceeds
    pub receiver: Box<str>,
    /// A set of strings that categorize the domain in which the NFT operates
    pub tags: Vec<String>,
    /// The royalty fees creators accumulate on the sale of NFTs
    pub royalty_fee_bps: Box<str>,
    /// A configuration field that dictates whether NFTs are mutable
    pub is_mutable: Box<str>,
    /// Field for extra data
    pub data: Box<str>,
}

/// Contains the market configurations of the launchpad
#[derive(Deserialize)]
pub struct Launchpad {
    /// Enum field containing the MarketType and its corresponding
    /// config parameters such as price and whitelisting
    #[serde(flatten)]
    pub market_type: MarketType,
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

        let nft_type = self.nft_type.nft_type().into_boxed_str();
        let market_type = self.launchpad.market_type.market_type();
        let is_embedded = self.nft_type.is_embedded();
        let is_embedded_str = is_embedded.to_string().into_boxed_str();
        let market_module = &self.launchpad.market_type.market_module();
        let module_name = self.module_name();

        let witness = self
            .collection
            .name
            .to_uppercase()
            .replace(' ', "")
            .into_boxed_str();

        let tags = self.write_tags();

        let (prices, whitelists) = self.get_sale_outlets()?;

        let define_whitelists = Schema::write_whitelists(whitelists)?;
        let define_prices = Schema::write_prices(prices)?;

        let market_module_imports = if is_embedded {
            format!("::{{Self, {}}}", market_type)
        } else {
            "".to_string()
        }
        .into_boxed_str();

        let slingshot_import = if is_embedded {
            "use nft_protocol::slingshot::Slingshot;"
        } else {
            ""
        }
        .to_string()
        .into_boxed_str();

        let mint_func = self
            .nft_type
            .mint_func(&witness, &self.launchpad.market_type.market_type());

        let mut vars = HashMap::new();

        vars.insert("name", &self.collection.name);
        vars.insert("nft_type", &nft_type);
        vars.insert("description", &self.collection.description);
        vars.insert("max_supply", &self.collection.max_supply);
        vars.insert("symbol", &self.collection.symbol);
        vars.insert("receiver", &self.collection.receiver);
        vars.insert("royalty_fee_bps", &self.collection.royalty_fee_bps);
        vars.insert("extra_data", &self.collection.data);
        vars.insert("is_mutable", &self.collection.is_mutable);
        vars.insert("module_name", &module_name);
        vars.insert("witness", &witness);
        vars.insert("tags", &tags);
        vars.insert("market_type", &market_type);
        vars.insert("market_module", market_module);
        vars.insert("market_module_imports", &market_module_imports);
        vars.insert("slingshot_import", &slingshot_import);
        vars.insert("is_embedded", &is_embedded_str);
        vars.insert("define_prices", &define_prices);
        vars.insert("define_whitelists", &define_whitelists);
        vars.insert("mint_function", &mint_func);

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
        let tags_vec = &self.collection.tags;

        tags_vec
            .iter()
            .map(|tag| {
                format!("        vector::push_back(&mut tags, b\"{}\");", tag)
            })
            .fold("".to_string(), |acc, x| acc + "\n" + &x)
            .into_boxed_str()
    }

    pub fn get_sale_outlets(
        &self,
    ) -> Result<(Vec<u64>, Vec<bool>), GutenError> {
        match &self.launchpad.market_type {
            MarketType::FixedPrice { prices, whitelists } => {
                if prices.len() != whitelists.len() {
                    return Err(GutenError::MismatchedOutletParams);
                }

                Ok((prices.clone(), whitelists.clone()))
            }
        }
    }

    /// Associated function that generates Move code to declare and
    /// push whitelisting values to a Move vector structure.
    ///
    /// It will write the following code if there is only one value in
    /// the whitelist yaml array:
    ///
    ///`let whitelisting = <BOOL_VALUE>;`
    ///
    /// If there are multiple values it means its a launchpad sale
    /// with multiple sales and therefore the function signature will
    /// expect a vector instead, so it writes:
    ///
    /// ```text
    /// let whitelisting = vector::empty();
    /// vector::push_back(&mut whitelisting, <BOOL_VALUE>);
    /// vector::push_back(&mut whitelisting, <BOOL_VALUE>);
    /// vector::push_back(&mut whitelisting, <BOOL_VALUE>);
    /// vector::push_back(&mut whitelisting, <BOOL_VALUE>);
    /// ...
    /// ```
    pub fn write_whitelists(
        whitelists: Vec<bool>,
    ) -> Result<Box<str>, GutenError> {
        let mut loc = "let whitelisting = vector::empty();\n".to_string();

        for w in whitelists {
            loc.write_fmt(format_args!(
                "        vector::push_back(&mut whitelisting, {w});\n"
            ))
            .unwrap();
        }

        Ok(loc.into_boxed_str())
    }

    /// Associated funciton that generates Move code to declare and
    /// push price values to a Move vector structure.
    ///
    /// It will write the following code if there is only one value in
    /// the price yaml array:
    ///
    ///`let pricing = <U64_VALUE>;`
    ///
    /// If there are multiple values it means its a launchpad sale
    /// with multiple sales and therefore the function signature will
    /// expect a vector instead, so it writes:
    ///
    /// ```text
    /// let pricing = vector::empty();
    /// vector::push_back(&mut whitelisting, <U64_VALUE>);
    /// vector::push_back(&mut whitelisting, <U64_VALUE>);
    /// vector::push_back(&mut whitelisting, <U64_VALUE>);
    /// vector::push_back(&mut whitelisting, <U64_VALUE>);
    /// ...
    /// ```
    pub fn write_prices(prices: Vec<u64>) -> Result<Box<str>, GutenError> {
        let mut loc = "let pricing = vector::empty();\n".to_string();

        for p in prices {
            loc.write_fmt(format_args!(
                "        vector::push_back(&mut pricing, {p});\n"
            ))
            .unwrap();
        }

        Ok(loc.into_boxed_str())
    }
}
