The `nft_protocol::transfer_whitelist` module is a set of functions for
implementing and managing a whitelist for NFT (non-fungible token) transfers.
The transfer whitelist is used to authorize which contracts are allowed to
transfer NFTs of a particular collection.
This allows collection creators to have control over which contracts can
transfer NFTs that belong to their collection.

For example, if a collection creator wants to enforce royalties on NFT
transfers, they can create a transfer whitelist and add only contracts that are
capable of paying royalties to the whitelist.
Or they can join existing whitelists that only contain audited contracts.
Collection creators can also use the transfer whitelist for other purposes, such
as limiting NFT transfers to certain parties or for complying with legal or
regulatory requirements.

The `nft_protocol::transfer_whitelist` module includes functions for creating
and managing a whitelist, adding and removing collections from a whitelist,
and checking whether a contract is authorized to transfer a particular NFT.

In addition to the features previously described, the
`nft_protocol::transfer_whitelist` module allows collection creators to join
multiple whitelists and for anyone to create their own whitelist and invite
creators to join.
This allows for a flexible and customizable approach to managing NFT transfers.

Collection creators can join multiple whitelists, which allows them to have
their collections included in multiple sets of authorized contracts.
This can be useful if a collection creator wants to allow different groups of
contracts to transfer their NFTs, or if they want to enforce different rules for
different groups of contracts.
For example, a collection creator could create one whitelist for contracts that
pay royalties and another whitelist for contracts that are part of a particular
network or ecosystem.

This allows for a decentralized and open approach to managing NFT transfers,
where different organizations or groups can create and manage their own
whitelists according to their own rules and criteria.
For example, a decentralized autonomous organization (DAO) could create a
whitelist and invite collection creators to join, allowing the DAO to manage
which contracts are authorized to transfer NFTs from the collections on the
whitelist.
