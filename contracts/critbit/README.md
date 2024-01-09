<a href="https://originbyte.io/">
    <h1><img src="./assets/logo.svg" alt="OriginByte" width="50%"></h1>
</a>

Origin-Byte is an ecosystem of tools, standards, and smart contracts designed to make life easier for Web3 Game Developers and NFT creators.
From simple artwork to complex gaming assets, we want to help you reach the public, and provide on-chain market infrastructure.

# Critbit

A critical bit (critbit) tree is a compact binary prefix tree,
similar to a binary search tree, that stores a prefix-free set of
bitstrings, like n-bit integers or variable-length 0-terminated byte
strings.

Critbit trees support fast insertion, deletion and iteration operations
as they do not need to be rebalanced.

## References

- [Bernstein 2006](https://cr.yp.to/critbit.html)
- [Langley 2008](https://www.imperialviolet.org/2008/09/29/critbit-trees.html)
- [Langley 2012](https://github.com/agl/critbit)
- [Tcler's Wiki 2021](https://wiki.tcl-lang.org/page/critbit)

## Implementation

This package re-exports
[Deepbook's critbit implementation](https://github.com/MystenLabs/sui/tree/main/crates/sui-framework/packages/deepbook)
which uses a dynamic-field backed structure to allow large tree structures
that don't exceed Sui's object size limit.
