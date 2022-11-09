## Specifications

We want NFTs to be able to tap into the following use cases:

1. Royalty enforcement:
   1. The creators should determine the level of freedom users get to enjoy with their NFTs. Users can make educated choices based on whether the given collection is too restrictive in terms of ownership transfers for them. However, creators must be given a mechanism to enforce royalties strongly should they wish to.
   2. Royalty cannot be bypassed, therefore the module that generates the `RoyaltyReceipt` (or any different mechanism for checking royalty) cannot rely on an untrusted oracle to get the execution price of a sale. Therefore, we believe a Whitelist implementation will always be required, regardless of the implementation details of the `Safe`.
2. Markets:
   1. Concurrently list an NFT for trading in different markets (for primitives that can handle race conditions with no significant UX deterioration)
      1. Be able to trade concurrently in auctions where the execution price is unknown (NFTs must be auctionable)
      2. Be able to list an NFT for sale at a determined price set by the seller
   2. Exclusively list an NFT for trading in a market (for primitives that cannot handle race conditions without significantly impairing the UX)
      1. Be able to trade exclusively in a given order-book where the execution price is unknown
      2. Be able to interact with more bespoke trading primitives (e.g. NFT lotteries)
3. Fast Minting + P2P Transfers:
   1. Be able to mint NFTs via burner wallets (For riskier mints, the collector may be interacting with a UI that is malicious, and therefore he/she uses a burner wallet to sign transactions that may have some malicious intent. Therefore burner wallets limit the maximum exposure to a malicious transaction).
   2. Be able to move assets if a given wallet is compromised
4. Gaming/Defi Interactions:
   1. Games can immutably interact with NFTs in a low-latency environment
   2. Games can mutably interact with NFTs in a low-latency environment

## 1. Royalty Enforcement

In our previous proposals we defined a type `Nft<phantom> has key`, which would remove polymorphic transfers entirely and therefore provide the foundational platform for NFT Creators to be guaranteed royalty enforcement.
As part of our proposal, we have conjectured that there is no way for the module that defines the royalty calculation logic to identity if it is interacting with a benign or malicious oracle, to get the input execution price, which the royalty calculation relies on.

To counter this conjecture, we have introduced the concept of Whitelisting, which gives the freedom for **NFT Creators** to decide which Market modules they trust, and therefore allow their NFT collections to be traded in those.
Proactively monitoring market and P2P transfer modules is most likely going to be a collective effort from the ecosystem and therefore we allow NFT creators to tap into any whitelist curated by the community.
Whilst anyone can create their own whitelists, it is likely that the Creator’s community will coalesce in a hand few of them.

With the introduction of dynamic field objects, programmability of `key`-only objects was restricted in ways that invalidate the use of `Nft<phantom> has key` in our proposal.
There are two ways to deal with it:

- Allow for polymorphic transfers on `Nft<phantom> has key, store` and accept some degree of royalty leak;
- Guarantee that NFTs always live in the `Safe` and therefore we can indirectly constrain polymorphic transfers by enforcing transferability only via whitelisted smart contracts

The second option guarantees the desired level of enforceability.
However, it means that NFTs will always live under the ownership of a shared object (if we assume the `Safe` cannot be a turned into a Single Writer Object, which we can relax this assumption later and explore the unlocked design space).

The important aspects to preserve in our opinion is to guarantee broadcast transactions for the initial mint, as well as to guarantee that in-game UX is not degraded if one has to rely on full-consensus transactions (More on this in part 4).

## 2. Market (Liquidity Layer)

**Price Spoofing**

It’s important to note that not all trading mechanisms have a pre-determined execution price, as is the case of Auction and Order books.
In general, royalties are calculated as follows:

$$
R = P * r
$$

Where $P$ is the execution price and $r$ is the royalty percentage.
There may be however more bespoke royalty calculations such as progressive royalties (i.e. similar to progressive tax regimes).

As we have mentioned previously, there is no way for the module that computes the royalty equation to be sure that $P$, which comes from the oracle, is the correct execution price.
Therefore $P$ can only come from whitelisted trading contracts which the NFT Creator is sure is not spoofing the trade price.
If we consider a proof or Royalty payment, such as the `RoyaltyReceipt`, we mustn’t mint any sort of receipt based on client input, because we cannot guarantee that they are honest when stating how much an NFT is being sold for.
Similarly, if we trust market contracts, they might not be honest.
Although socially, it’s easier to control market contracts, any solution in which a party to the trade can spoof the price to avoid paying the full royalty amount cannot be called a strong royalty enforcement scheme.

**Transfer Caps and Exclusive Listing**

In our proposal we rely on the use of `TransferCap` and `ExclusiveTransferCap` to delegate transferability to the buyer, in order to settle the trade.

An exclusive listing, achieved via `ExclusiveTransferCap`, is helpful in fast-paced trading algorithms where the tx sender does not know in advance whose NFT they are buying, as discussed in depth [here](https://github.com/MystenLabs/sui/pull/4887#discussion_r984862924).
In our opinion, any implementation of the safe must enable exclusive listing.

Another interesting use case for exclusive listing is lending.
An exclusively listed NFT can be only withdrawn from a safe with the appropriate and unique transfer cap.
By depositing an NFT to the borrower’s safe and minting such a transfer cap for the lender, we guarantee that the borrower cannot move the NFT out of the safe, nor sell it.
The lender can _at any point_ claw it back.

### Event-based Approach

Our current understanding is that an Event-based approach to listing has been proposed as a way to resolve the lingering `TransferCaps` problem.

That is, a safe implementation which is based on solely emitting an event, ie. it differs from Originbyte’s proposal, or the Sam’s initial [RFC](https://github.com/MystenLabs/sui/pull/4887), in that it does not create a [transfer cap](https://github.com/Origin-Byte/nft-protocol/pull/48/files#diff-f68ac7246e29135ec825b983e3d3fc3e9c33f602e582fca3a0946bdb66511afaR55) object.
It is our understanding that it relies on off-chain services to monitor these events.
If someone wanted to create an on-chain trading contract, they would need to bridge the safe with that contract off-chain.
The safe owner would list their NFT for sale by upfront stating the price of the NFT and enabling anyone who pays it to get the NFT.

In Originbyte’s proposal of the liquidity layer, the above functionality is done by a dedicated bidding contract.

**The stickiness of lingering references**

One of the critiques of transfer caps is what we refer to lingering references, that is after a user bought an NFT that was listed in multiple places, it’s not delisted in the same tx and off-chain automation is necessary to clean up the state.
In fact, this is a fundamental problem that is also present in the event-based proposal because the event-based proposal still requires some sort of references to be invalidated as we describe below.

The reason why an event-based proposal for safe does not necessarily alleviate the complexity of lingering references to withdrawn NFTs can be illustrated with a minimal example:

1. A seller lists their NFT thereby generating an event
2. Service running an order book hears the event and sends a tx which creates an appropriate on-chain state in an order book contract. Ie. the contract is now aware of an NFT being listed in the given safe.
3. Service running an auction house hears the event and does the same.
4. A buyer buys an NFT via an order book.
5. There exists effectively an equivalent to a lingering TC in the auction house.

**Alternative event based approaches**

By removing the concept of `TransferCap`s in favor of a purely event-based proposal, ie. the safe _only_ emits events when an NFT is listed, we lose some important properties:
auctions and exclusive listing (although can be patched on).
This argument is based on the hypothetical Safe entry functions discussed during the Sui Builder House:

- `list(Safe, Safe, Price)`
- `buy(Safe, Safe, Payer)`

The challenge with this implementation is that it requires the execution price of a sale to be known at list time.
This is not the case for a myriad of trading regimes and therefore would limit the market applications that could be built.

We propose an alternative event-based approach, which eliminates transfer caps, via accounting logic in the `Safe` itself.
As mentioned above, having a fixed price is inflexible.
Therefore, we need the trading contracts to come to the `Safe` and just take an NFT out.
From this follows that we need a way to give contracts permissions to transfer NFTs (hence an alternative to `TransferCap`s.)
When a user lists an NFT for sale, what they're effectively doing is telling the `Safe` via some API: "This particular contract can come and claim the NFT at any point."
There are some points to discuss when comparing this implementation to the `TransferCap` one.
The ones marked with **equivalence** are common things in both design worth pointing out.
The ones marked with **con** are perceived disadvantages of not having `TransferCap`s, **pro** vice-versa.

- **Equivalence**. Enables a pattern where off-chain services can listen to `Safe` events and create necessary blockchain state themselves so that the client (e.g. a wallet) doesn't have to know how to integrate with a specific trading contract.
  Shifts complexity from wallets to the smart contract developer.
- **Con**. Exclusive listing requires implementation in a trading contract.
  Assume we could do it via some flag on `Safe`.
  Since there are no objects, there is nothing to reclaim.
  Therefore, to prove that an exclusively listed NFT was de-listed from the source contract, we need logic in the source contract to authorize the de-listing.
  This is fragile, because if a user exclusively lists an NFT for a contract which doesn't implement de-listing logic, it's stuck.
  Also, it puts more complexity on the trading contracts.
- **Equivalence**. Lingering references are still there as shown above.
- **Equivalence**. The client must be reasonable to avoid off-chain service that listens to `Safe` events about this listing.
  They must batch a tx which *(i)* marks NFT for sale in a particular contract and *(ii)* run specific endpoint in a smart contract.
- **Con**. Have to have additional complexity for whitelisting contracts which can withdraw NFTs.
  Authorization by witness is not enough in all use cases, so it would need additionally an `Option<UID>` or something like that.
  Because of contracts which (as is common pattern on e.g. Solana) enable anyone to start their own *copy* of a marketplace.
  E.g. an OB implementation smart contract could host multiple OBs if it has `public fun create()` endpoint.
- **Pro**. In some cases, the client might allocate slightly less memory.
  `TransferCap` has a `id: UID` and an extra bool which could be saved (other fields will need to be stored in the target contract anyway.)

## 3. Fast Minting + P2P transfers

**Fast Minting**

One of the use cases we would like NFTs to guarantee is the ability to fast mint via broadcast transactions, however this is no longer possible if we restrict NFTs to always live inside the `Safe` layer, assuming `Safe`s are always share objects.
If we relax this assumption and allow for `Safe`s to be a Single Writer Object (SWO), we could mint an NFT, transfer its ownership to a newly made `Safe` and transfer `Safe` to the user.
Only after mint time, we make `Safe` shared and issue an `OwnerCap` to the owner.

**Minting with Burner Wallet**

Since, the mint transaction does not charge any royalties, by making `tx_context::sender(ctx)` optionally different from the `recipient` in `transfer<T: key>(obj: T, recipient: address)` we can enable the minting transaction to be signed by the burner wallet, whilst the NFT is received by the `recipient` wallet.
This is extremely helpful in that it limits the risk exposure to malicious transactions to the number of assets owned by the burner wallet.

**Salvage NFTs from a compromised wallet**

If a user keypair gets compromised there should be some failsafe in order to:

1. Stop further NFTs and other Assets from being stollen (stanch the bleeding)
2. Transfer ownership of all NFTs to a `Safe` of a given backup keypair (remediate the problem)

We propose the introduction of a fields `owner: address` and `backup: Option<address>` to the Safe, and restrict polymorphic transfer of `OwnerCap` for added security.
While it can make it inconvenient, the transfer of `OwnerCap` can only be made by collecting two signatures, the `owner` and `backup` signature.
Furthermore, both `owner` and `backup` addresses can call the function `freeze_safe()` which stops the Safe from emitting `TransferCap`s or from listing assets for a given `resolution_time` (e.g. 1 week).
The purpose of this function is to stanch the bleeding in case one of the keypairs gets compromised.
Then, the following functions are exposed:

- `unfreeze_safe()` will unfreeze the safe once it has collected signature from both `owner` and `backup` address
- `rescue_assets()` to move the assets to a safe with a new `owner` and `backup` address.

The reason why both signatures must be collected is because either the `owner` keypair and the `backup` keypair can be compromised individually, but compromising both keypairs at the same time is exponentially harder, assuming the user takes appropriate security measures (i.e. stores keypairs in different locations).

Yet, it is important to allow the `owner` keypair to be able to freeze the assets.
Presumably, the `owner` keypair will most likely be a hot wallet whilst the `backup` keypair a cold wallet.
Allowing the freezing to occur only with the backup wallet is dangerous, because by the time the user finds out about the compromised keypair, it will have to physically commute to the location of the cold wallet.
Therefore the user should be able to call`freeze_safe()` with the `owner` keypair and send a signature later with the backup keypair within the `resolution_time` defined (which should give enough human time to act).

## 3. Gaming Interactions

In general we see two NFT usage patterns in games:

1. A game checks if player has given NFT and it renders it in the game if so (Immutable interaction)
2. A game checks if player has given NFT, renders it in the game if so and mutates the gaming asset according to event occurring in the game (Mutable interaction)

We call these Mutable and Immutable Interactions.
We will also call Market Interactions, whenever a given NFT has `TrasnferCap`s issued or is being listed by the `Safe`.

Immutable interactions can occur in parallel to Market interactions.
This can be achieved by:

- having the game periodically perform an ownership test at each game checkpoint (i.e. when loading a newly rendered scene)
- having the game listen to sale events and stop rendering the NFT as soon as it gets transferred to a new owner, and as soon as a new game checkpoint starts

Mutable interactions on the other hand, cannot occur simultaneously with Market interactions, because this would lead to race conditions between the Trading of the NFT and its mutation.
(i.e. imagine buying a newly made car and right before the car is handed over to you the previous owner crashes it; or say a sword of a game being sold at a high price because it has no damage, but right before transferring the sword to the new owner the old owner would damage the sword in an opened gaming session).

To achieve Mutable interactions we propose:

- When a player starts playing a game, a gaming session is initiated and the safe will emit a `MutabilityCap` for the NFT that will be mutated.
- When mutations occur in-game the game server will register them in a log and will commit those changes all batched in one transaction at the end of the gaming session. During the gaming session, the NFT will be locked in the safe, because the MutCap will not allow the NFT to be sold, whilst it exists.
