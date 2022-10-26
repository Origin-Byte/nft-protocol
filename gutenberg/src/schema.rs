//! Module containing the core logic to parse the `config.yaml` file into a
//! struct `Schema`, acting as an intermediate data structure, to write
//! the associated Move module and dump into a default or custom folder defined
//! by the caller.
use crate::prelude::*;

/// Struct that acts as an intermediate data structure representing the yaml
/// configuration of the NFT collection.
pub struct Schema {
    pub collection: Collection,
    pub nft_type: NftType,
    pub launchpad: Launchpad,
}

/// Contains the metadata fields of the collection
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
pub struct Launchpad {
    /// Enum field containing the MarketType and its corresponding
    /// config parameters such as price and whitelisting
    pub market_type: MarketType,
}

impl Collection {
    /// Logic responsible for parsing the `Collection` dictionary present
    /// in `config.yaml` and dump it into a `Collection` struct
    pub fn from_yaml(yaml: &Value) -> Result<Self, GutenError> {
        let collection = serde_yaml::to_value(&yaml["Collection"])?;

        if collection.is_null() {
            return Err(err::miss("Collection"));
        }

        let tag_binding = serde_yaml::to_value(&yaml["Collection"]["tags"])?;

        let tags: Vec<String> = tag_binding
            .as_sequence()
            .ok_or_else(|| err::miss("tags"))?
            .into_iter()
            .map(|tag| {
                let tag_n = tag
                    .as_str()
                    .ok_or_else(|| err::format("tags"))?
                    .to_string();

                Ok(tag_n)
            })
            .collect::<Result<Vec<String>, GutenError>>()?;

        let collection = Collection {
            name: Schema::get_field(
                &yaml,
                "Collection",
                "name",
                FieldType::StrLit,
            )?,
            description: Schema::get_field(
                &yaml,
                "Collection",
                "description",
                FieldType::StrLit,
            )?,
            symbol: Schema::get_field(
                &yaml,
                "Collection",
                "symbol",
                FieldType::StrLit,
            )?,
            max_supply: Schema::get_field(
                &yaml,
                "Collection",
                "max_supply",
                FieldType::Number,
            )?,
            receiver: Schema::get_field(
                &yaml,
                "Collection",
                "receiver",
                FieldType::StrLit,
            )?,
            royalty_fee_bps: Schema::get_field(
                &yaml,
                "Collection",
                "royalty_fee_bps",
                FieldType::Number,
            )?,
            tags,
            data: Schema::get_field(
                &yaml,
                "Collection",
                "data",
                FieldType::StrLit,
            )?,
            is_mutable: Schema::get_field(
                &yaml,
                "Collection",
                "is_mutable",
                FieldType::Bool,
            )?,
        };

        Ok(collection)
    }
}

impl Launchpad {
    /// Logic responsible for parsing the `Launchpad` dictionary present
    /// in `config.yaml` and dump it into a `Launchpad` struct
    pub fn from_yaml(yaml: &Value) -> Result<Self, GutenError> {
        let launchpad = serde_yaml::to_value(&yaml["Launchpad"])?;

        if launchpad.is_null() {
            return Err(err::miss("Launchpad"));
        }

        let price_binding = serde_yaml::to_value(&yaml["Launchpad"]["prices"])?;
        let wl_binding =
            serde_yaml::to_value(&yaml["Launchpad"]["whitelists"])?;

        if !price_binding.is_sequence() {
            if price_binding.is_null() {
                return Err(err::miss("prices"));
            }
            return Err(err::format("prices"));
        }

        if !wl_binding.is_sequence() {
            if price_binding.is_null() {
                return Err(err::miss("whitelists"));
            }
            return Err(err::format("whitelists"));
        }

        let prices_vec = price_binding
            .as_sequence()
            .ok_or_else(|| err::miss("prices"))?;

        let wl_vec = wl_binding
            .as_sequence()
            .ok_or_else(|| err::miss("whitelists"))?;

        let market_vec = prices_vec
            .iter()
            .zip(wl_vec)
            .map(|(price, whitelist)| {
                let price =
                    price.as_u64().ok_or_else(|| err::format("prices"))?;
                let whitelist = whitelist
                    .as_bool()
                    .ok_or_else(|| err::miss("whitelists"))?;

                Ok(FixedPrice::new(price, whitelist))
            })
            .collect::<Result<Vec<FixedPrice>, GutenError>>()?;

        let launchpad = Launchpad {
            market_type: MarketType::FixedPriceMarket { sales: market_vec },
        };

        Ok(launchpad)
    }
}

impl Schema {
    /// Higher level method responsible for parsing `config.yaml` and
    /// dump it into a `Schema` struct
    pub fn from_yaml(yaml: &Value) -> Result<Self, GutenError> {
        let nft_type_str = serde_yaml::to_value(&yaml["NftType"])?
            .as_str()
            .ok_or_else(|| err::miss("NftType"))?
            .to_string();

        let nft_type = NftType::from_str(nft_type_str.as_str())
            .unwrap_or_else(|_| panic!("Unsupported NftType provided."));

        let schema = Schema {
            collection: Collection::from_yaml(yaml)?,
            nft_type,
            launchpad: Launchpad::from_yaml(yaml)?,
        };

        Ok(schema)
    }

    /// Higher level method responsible for generating Move code from the
    /// struct `Schema` and dump it into a default folder
    /// `../sources/examples/<module_name>.move` or custom folder defined by
    /// the caller.
    pub fn write_move(
        &self,
        output_opt: Option<PathBuf>,
    ) -> Result<(), GutenError> {
        let file_path = "templates/template.move";

        let fmt = fs::read_to_string(file_path)
            .expect("Should have been able to read the file");

        let nft_type = self.nft_type.nft_type().into_boxed_str();
        let market_type = self.launchpad.market_type.market_type();
        let is_embedded = self.nft_type.is_embedded();
        let is_embedded_str = is_embedded.to_string().into_boxed_str();
        let market_module = &self.launchpad.market_type.market_module();

        let module_name = self
            .collection
            .name
            .to_lowercase()
            .replace(" ", "_")
            .into_boxed_str();

        let witness = self
            .collection
            .name
            .to_uppercase()
            .replace(" ", "")
            .into_boxed_str();

        let tags = self.write_tags();

        let (mut prices, mut whitelists) = self.get_sale_outlets();

        let sale_type = if prices.len() == 1 {
            "create_single_market"
        } else {
            "create_multi_market"
        }
        .to_string()
        .into_boxed_str();

        let define_whitelists = Schema::write_whitelists(&mut whitelists)?;
        let define_prices = Schema::write_prices(&mut prices)?;

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
        vars.insert("market_module", &market_module);
        vars.insert("market_module_imports", &market_module_imports);
        vars.insert("slingshot_import", &slingshot_import);
        vars.insert("sale_type", &sale_type);
        vars.insert("is_embedded", &is_embedded_str);
        vars.insert("define_prices", &define_prices);
        vars.insert("define_whitelists", &define_whitelists);
        vars.insert("mint_function", &mint_func);

        let vars: HashMap<String, String> = vars
            .into_iter()
            .map(|(k, v)| (k.to_string(), v.to_string()))
            .collect();

        let mut output = PathBuf::new();

        if output_opt.is_none() {
            output.push(format!(
                "../sources/examples/{}.move",
                &module_name.to_string()
            ));
        } else {
            // This can be safely unwrapped since we make sure there is Some()
            output.push(output_opt.unwrap());

            // Create directories if they do not exist
            let path = output.as_path();
            if let Some(p) = path.parent() {
                fs::create_dir_all(p)?
            };
        }

        let mut f = File::create(output)?;

        f.write_all(
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
            .into_iter()
            .map(|tag| {
                format!("        vector::push_back(&mut tags, b\"{}\");", tag)
            })
            .fold("".to_string(), |acc, x| acc + "\n" + &x)
            .into_boxed_str()
    }

    pub fn get_sale_outlets(&self) -> (Vec<u64>, Vec<bool>) {
        match &self.launchpad.market_type {
            MarketType::FixedPriceMarket { sales } => {
                let prices: Vec<u64> = sales.iter().map(|m| m.price).collect();

                let whitelists: Vec<bool> =
                    sales.iter().map(|m| m.whitelist).collect();

                (prices, whitelists)
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
        whitelists: &mut Vec<bool>,
    ) -> Result<Box<str>, GutenError> {
        let define_whitelists = if whitelists.len() == 1 {
            "let whitelisting = ".to_string()
                + &whitelists
                    .pop()
                    // This is expected not to result in an error since
                    // the field whitelists has already been validated
                    .ok_or_else(|| GutenError::UnexpectedErrror)?
                    .to_string()
                + ";"
        } else {
            let mut loc = "let whitelisting = vector::empty();\n".to_string();

            for w in whitelists.drain(..) {
                loc = loc
                    + "        vector::push_back(&mut whitelisting, "
                    + &w.to_string()
                    + ");\n"
            }
            loc
        };

        Ok(define_whitelists.into_boxed_str())
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
    pub fn write_prices(prices: &mut Vec<u64>) -> Result<Box<str>, GutenError> {
        let define_prices = if prices.len() == 1 {
            "let pricing = ".to_string()
                + &prices
                    .pop()
                    // This is expected not to result in an error since
                    // the field whitelists has already been validated
                    .ok_or_else(|| GutenError::UnexpectedErrror)?
                    .to_string()
                + ";"
        } else {
            let mut loc = "let pricing = vector::empty();\n".to_string();

            for p in prices.drain(..) {
                loc = loc
                    + "        vector::push_back(&mut pricing, "
                    + &p.to_string()
                    + ");\n"
            }
            loc.to_string()
        };

        Ok(define_prices.into_boxed_str())
    }

    /// Associated function that parses a field from the `config.yaml` and returns
    /// the value in `Box<str>` format wrapped in `Result`.
    pub fn get_field(
        data: &serde_yaml::Value,
        category: &str,
        field: &str,
        field_type: FieldType,
    ) -> Result<Box<str>, GutenError> {
        let value = serde_yaml::to_value(&data[category][field])?;

        if value.is_null() {
            return Err(err::miss(field));
        }

        let result = match field_type {
            FieldType::StrLit => value
                .as_str()
                .ok_or_else(|| err::format(field))?
                .to_string(),
            FieldType::Number => value
                .as_u64()
                .ok_or_else(|| err::format(field))?
                .to_string(),
            FieldType::Bool => value
                .as_bool()
                .ok_or_else(|| err::format(field))?
                .to_string(),
        };

        Ok(result.into_boxed_str())
    }
}
