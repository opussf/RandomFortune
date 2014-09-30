[![Build Status](https://travis-ci.org/opussf/RandomFortune.svg?branch=master)](https://travis-ci.org/opussf/RandomFortune)

# RandomFortune

WoW addon to post random quips of wisdom.

## The Reason
This addon lets you show your wisdom to your friends, guild mates, and anyone lucky enough to be around you by giving them bits of wisdpm to chew on.

## What it does
Posts a random message from your list to BattleNet, guild, and even just the /say channel.
Where it posts is configurable, as is how often it posts.

It will also try to include 6 *lucky numbers* if you choose.

## Feedback
I am always asked "What are the numbers for?" (or something similar).

## What to Solve
The fun of this addon was to modify the 'random' idea to make it not repeat recently posted sayings.
My solution was to record the last posted time, calculate a cutoff time, and choose up to a small limit of messages until a good one is found.
Calculating the cutoff time uses the rate, and the number of message known.
The small limit idea lets the addon continue to use the random number generator, but also keeps the addon from getting stuck by not finding a 'valid' message to post.


