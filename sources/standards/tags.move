/// Module of NFT and Collection Tags.
///
/// This module functions as a helper module for setting up NFT collection tags.
/// Adding strings manually is prone to fat-finger error, among other manual errors,
/// therefore this module provides a standardized way of injecting Tags to a collection
///
/// Tags allows wallets to organize the NFT display based on categories, such as
/// Art, Collectibles, Profile Pictures, among others.
///
/// We cannot enforce a maximum number of categories chosen because the Sui's
/// Display does not allow for such constraint to be added. This constriant should
/// rather be enforced on the client side by clipping the vector field.
module nft_protocol::tags {
    use std::string::{Self, String};

    public fun art(): String {
        string::utf8(b"Art")
    }

    public fun profile_picture(): String {
        string::utf8(b"ProfilePicture")
    }

    /// An example of a collectible would be digital Baseball cards
    public fun collectible(): String {
        string::utf8(b"Collectible")
    }

    public fun game_asset(): String {
        string::utf8(b"GameAsset")
    }

    /// A tokenised asset is a real world asset represented on-chian,
    /// i.e. insurance policies, loan contracts, etc.
    public fun tokenised_asset(): String {
        string::utf8(b"TokenisedAsset")
    }

    /// Tickers are what's called the abbreviation used to uniquely identify
    /// publicly traded assets, i.e. Tesla trades as $TSLA and Amazon as $AMZN.
    /// Crypto asset tickers themselves can be minted and sold as NFTs.
    public fun symbol(): String {
        string::utf8(b"Ticker")
    }

    public fun domain_name(): String {
        string::utf8(b"DomainName")
    }

    public fun music(): String {
        string::utf8(b"Music")
    }

    public fun video(): String {
        string::utf8(b"Video")
    }

    public fun ticket(): String {
        string::utf8(b"Ticket")
    }

    public fun license(): String {
        string::utf8(b"License")
    }
}
