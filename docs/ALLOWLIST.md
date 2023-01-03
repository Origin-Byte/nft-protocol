The `nft_protocol::transfer_allowlist` module is a set of functions for
implementing and managing a allowlist for NFT (non-fungible token) transfers.
The transfer allowlist is used to authorize which contracts are allowed to
transfer NFTs of a particular collection.
This allows collection creators to have control over which contracts can
transfer NFTs that belong to their collection.

For example, if a collection creator wants to enforce royalties on NFT
transfers, they can create a transfer allowlist and add only contracts that are
capable of paying royalties to the allowlist.
Or they can join existing allowlists that only contain audited contracts.
Collection creators can also use the transfer allowlist for other purposes, such
as limiting NFT transfers to certain parties or for complying with legal or
regulatory requirements.

The `nft_protocol::transfer_allowlist` module includes functions for creating
and managing a allowlist, adding and removing collections from a allowlist,
and checking whether a contract is authorized to transfer a particular NFT.

In addition to the features previously described, the
`nft_protocol::transfer_allowlist` module allows collection creators to join
multiple allowlists and for anyone to create their own allowlist and invite
creators to join.
This allows for a flexible and customizable approach to managing NFT transfers.

Collection creators can join multiple allowlists, which allows them to have
their collections included in multiple sets of authorized contracts.
This can be useful if a collection creator wants to allow different groups of
contracts to transfer their NFTs, or if they want to enforce different rules for
different groups of contracts.
For example, a collection creator could create one allowlist for contracts that
pay royalties and another allowlist for contracts that are part of a particular
network or ecosystem.

This allows for a decentralized and open approach to managing NFT transfers,
where different organizations or groups can create and manage their own
allowlists according to their own rules and criteria.
For example, a decentralized autonomous organization (DAO) could create a
allowlist and invite collection creators to join, allowing the DAO to manage
which contracts are authorized to transfer NFTs from the collections on the
allowlist.
