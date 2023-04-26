// #[test_only]
// module launchpad_v2::test_crypto {
//     use std::option::some;
//     use std::type_name;
//     use std::hash;

//     use sui::test_scenario::{Scenario, ctx};
//     use sui::sui::SUI;

//     use launchpad_v2::launchpad::{Self, Listing, LaunchCap};
//     use launchpad_v2::venue::{Self, Venue};
//     use launchpad_v2::fixed_bid::{Self, Witness as FixedBidWit};
//     use launchpad_v2::warehouse::{Witness as WarehouseWit};
//     use launchpad_v2::pseudorand_redeem::{Witness as PseudoRandomWit};
//     use launchpad_v2::schedule;
//     use sui::test_random;

//     use nft_protocol::utils_supply::Self as supply;


//     /// We're creating an ECDSA keypair using the secp256k1  elliptic curve.
//     /// An ECDSA keypair consists of a private key and a public key.
//     /// The private key is a randomly generated 256-bit number,
//     /// while the public key is a point on the elliptic curve
//     /// derived from the private key.
//     #[test_only]
//     public fun create_ecdsa_k1_keypair(seed: vector<u8>) {
//         // The SECP256K1_ORDER array represents the order of the secp256k1
//         // elliptic curve, which is the number of points on the curve.
//         // It's a very large prime number with 256 bits, which means it has
//         // 77 decimal digits. This number is used in the process of generating
//         // a valid private key, as the private key must be a random integer
//         // between 1 and this order.
//         let secp256k1 = vector[
//             115, 219, 92, 62, 209, 242, 245, 87, 25, 220, 202, 215, 108, 39, 233, 111,
//             116, 19, 99, 31, 220, 143, 222, 80, 121, 195, 47, 237, 10, 176, 51, 255,
//         ];

//         let generator = test_random::new(seed);
//         // Generating a 32 byte-array (i.e. 256 bits)
//         let private_key_bytes = test_random::next_bytes(&mut generator, 32);

//         let private_key_hash = hash::sha3_256(copy private_key_bytes);

//         let big_endian = copy private_key_hash;

//         big_endian % n


//         // Calculate the public key by using the private key hash
//         // to derive the x-coordinate and then calculating the y-coordinate:

//     }
// }
