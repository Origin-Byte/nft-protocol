module nft_protocol::collection_core {
    use std::vector;
    use std::string::{Self, String};

    use sui::event;
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{TxContext};
    use sui::transfer;

    use nft_protocol::err;
    use nft_protocol::tags::{Self, Tags};
    use nft_protocol::supply::{Self, Supply};
    use nft_protocol::supply_policy::{Self, SupplyPolicy};

    // Removed fields:
    // /// Address that receives the mint price in Sui
    //     receiver: address,
    // /// Field determining the amount of royaly fees in basis points,
    //     /// charged in market transactions.
    //     /// TODO: It is likely that this field will change as we design
    //     /// the royalty enforcement standard
    //     royalty_fee_bps: u64,
    // // TODO: Should symbol be limited to x number of chars?
    //     symbol: String,
    // /// Determines if the NFT data is mutable. Once turned `false`
    //     /// it cannot be reversed.
    //     frozen: bool,
    //     /// Determines if the Collection data is mutable. Once turned `false`
    //     /// it cannot be reversed.
    //     is_mutable: bool,
    // creators: vector<Creator>,

    // TODO: Maybe CoreData should be itself a ObjectBag, allows for more modularity
    struct CoreData<D: store + drop> has key, store {
        id: UID,
        name: String,
        description: String,
        mint_authority: ID,
        bag: ObjectBag,
    }

    // NFT Corresponding to the Collection ticker
    // e.g. Degen Trash Pandas could be DTP
    struct Ticker has key, store {
        id: UID,
        // TODO: Need to create NftDomain collection
        nft: Nft<NftDomain>
    }

    struct RoyaltyPolicy has key, store {}

    // Object that keeps track of
    struct Registry has key, store {}

    // Object that defines the Mutability policy of the collection and
    // the NFTs themselves..
    struct MutPolicy has key, store {}

    // Object that defines the Supply policy for each NFT Type in a collection
    // Different NFTs in a collection can have different Market types. For instance,
    // a game collection could have two market types: `Character` and `Weapon`. It is
    // also likely that Creators will want to control supply at the sub-type level.
    // For instance: There can be `Character.Wizard` and `Character.Warrior` and each
    // sub-type can have its own supply.
    struct SupplyPolicy has key, store {
        id: UID,
        // TypeName here refeers to the MarketType of the NFT
        objects: ObjectTable<TypeName, Supply>,
    }
}
