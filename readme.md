# Bounties 

Permissionless bounties for content creators. 

## What is Bounties?

I am happy to introduce the second iteration of my experimental permissionless bounties smart contract called Bounties.sol.

Bounties allow content creators to collect contributions from their audience in exchange for rewards. Here's how it works:
1. The creator publishes a list of reward tiers and a link to make a donation.
2. (Optional) The public make contributions towards the reward tiers of their choosing.
3. The creator checks which tiers have been reached and performs the pre-specified action.
4. The creator withdraws funds from the contract at their leisure
5. (Optional) The creator resets the scores associated with 

## Motivation
### Problem
Funding content creation is time consuming. Organizing relationships with sponsors and clients takes creator time and attention away from their work. While some creations lend themselves to being sold as NFTs, many creators' output does not fit well within existing NFT formats (1/1, 10k pfp, etc.). For these creators, sponsorship, advertising, and donations are more apt models. However too often, these creators become bogged down negotiating each financial relationship separately. Financing content like podcasts, essays, and Dune Dashboards is difficult, especially for independent creators.

### Goal
Creators need ways to create sustainable and recurring revenue streams that do not incur administrative overhead that gets in the way of the creative process. If we can find new revenue streams that enable independent creators to pay themselves salaries and support production costs, then we make it possible for more individuals and small teams to dedicate time to creating new and interesting projects, without *needing* to sign deals with publishers or hire in-house adveretising managers. 

### Purpose
The purpose of Bounties.sol is to allow content creators to state up-front what they are willing to do for a given contribution -- much like Kickstarter reward tiers -- then collect those funds permissionlessly on the blockchain. Bounties is an experiment aiming to enable content creators like myself to collect funds from their audience without negotiating each financial relationship independently. 

Bounties is an experiment in consensual permissionless sponsorship. I say what I am willing to do for a given sum of contributions, and if the money shows up, I do it.

The way one creator uses Bounties may differ greatly from another. This is an open ended experiment, so no matter what happens, we're learning something new!

## Risks
1. The greatest risk is that Bounties are simply *too* unopinionated for most people to find them useful. I intend to experiment with using Bounties myself, so I'm not terribly worried if no one else finds them useful right now. I'm learning as I go. 
2. The Bounties model depends on the creator's off-chain reputation. As a creator, I both state my reward tiers and fulfill the work without any on-chain guarantees. Some may see this as a drawback fit to be patched with clever smart contract affordances like escrows, multi-sigs, and proofs, I believe that reputation will nevertheless play an important role in creator appropriation of smart contracts. I prefer to start with simpler contracts that play out 
3. There can be bugs in my code and funds can be lost. I offer no warranty, guarantee, or assurances to anyone running or interacting with this code.