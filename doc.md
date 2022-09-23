# Pico riichi

## Names

- picojong
- shojong
- miniriichi
- pocket riichi

## Algorithms to write

Goal: calculate progression (as shanten?) and optimize towards a win, given everyone's discards, overall game point difference, doras, fast vs slow hand, whether to call or not.

To debug we should display this info for the current player (and when holding B for all players):

- Shanten
- % of tiles that will contribute to hand progressing
- What tile to discard

Let's break it down

### Calculating potential hands

Make a list of hands with complete melds from the current hand (non-overlapping). Based on the remaining pseudo-melds (protoruns: ryanmen, kanchan, penchan; or pairs: toitsu) or singles, calculate the ukeire of all the non-overlapping possibilities for melds

### Calculating shanten

- Calculate separate shanten for chiitoitsu, kokushi musou (13 orphans), and normal hands (1 pair + 4 meld), take the minimum of those 3 numbers.

So there is this old manual to program riichi in C written in Japanese, https://web.archive.org/web/20190401072440/http://cmj3.web.fc2.com/#syanten. It prescribes 2 different approaches. 1 more naive, which is used by the web-based Riichi trainer that many use [ShantenCalculator.js](https://github.com/Euophrys/Riichi-Trainer/blob/develop/src/scripts/ShantenCalculator.js), and the other is faster but relies on a HUGE precomputed hashtable (>7MB .dat file). This newer [cpp library](https://github.com/tomohxx/shanten-number) seems to use a similar approach, backed by [math I can't understand](https://tomohxx.github.io/mahjong-algorithm-book/ssrf/#_4). Given the limited space of pico8 we can only do the naive approach anyway, and maybe the calculation time can actually just be part of the "thinking time" we usually fake for the CPU (altho it will hang the single thread)...

General approach of the naive method:

1. Remove a pair (atama), if any
2. Remove all completed melds (mentsu), e.g. a straight () or a triplet (koutsu)/quad (kantsu), if any
3. Remove all possible melds/protoruns (taatsu), e.g. penchan/kanchan/ryanmen/toitsu, if any

Finally calculate with the formula:

```
 shanten = 8 - (#mentsu * 2) - #taatsu - #pair (max 1)
```

The reason you start with 8 is that even in the worst case hand (all singles, no terminals or honors), with 13 tiles we can assume any 5 of the tiles as the start of their own blocks (a la the 5 block theory: 1 pair + 4 melds), so any 13 tile hand is always only 8 tiles away. In reality shanten max is 7 since chiitoitsu starts with 7, but the function to calculate that is separate.

The mentsu count is multiplied by 2 because each mentsu contains the 1 tile that is already counted as the initial 5 blocks + 2 other tiles. Those 2 other tiles therefore reduced shanten by 2. Another way to explain this: let's say you start with 8-shanten hand, then you draw two tiles successfully to make a mentsu. You now have a 6-shanten hand.

Our data structure for calling may mean that player.hands can become smaller, so the shanten calculation function should accept a smaller hand as input, and we can subtract the number of called melds from the result: shanten = 8 - (#mentsu _ 2) - #taatsu - #pair - (#calledMelds _ 2)

### Is a hand winning or not (used for current player too)

Given a list of yaku, evaluate the current hand to them. If it satisfies the yaku with the 14th tile being the drawn wall tile OR the most recent player's discard

Times to check:

- Draw
- After kan (todo: we need to change the current turn logic to support turn changing, skipping players after pon/kan)
- After discard

First check: is it a complete hand

- 4 melds, 1 pair
- 7 pairs
- 13 orphans

If it's 4melds + 1pair (normal hand) it needs to satisfy a yaku. Iterate through the list of yaku, which should be encoded by the rules. Rule examples:

- Riichi: player.riichi flag is true and players.melds is 0
- Yakuhai: player.melds contains the wind of the round/player wind, or dragon tile
- Tanyao: no 1, 9 in string, must have a digit (no honors)
- Iipeikou: 2 identical sequences, players.melds is 0

If the hand qualifies for 1 or more yaku, then it's a winning hand, trigger pauseForWin.

### Can I chii, pon, or kan?

After every discard, pause the game if a player can call. For every player, see if any of them have 2 or 3 of the discard in their hand, set canPon/canKan for that player, including the current, showing the buttons. For the next player, see if any of them have 2 tiles before, sandwiching, or after this tile. If so, set canChii for that player, including the current, showing the buttons.

We need to set a pause flag in the UI for prompting calls. pauseForCall. It suspends the progression of CPU discard logic, and is set after every discard. This pause flag will trigger CPU call logic (call if advances shanten and preserves yaku or ~~potential yaku~~?)

After every discard, also check if any player has a winning hand

### Should I riichi?

How does the CPU know if they should riichi or not? Riichi prompt always happens on draw, so should be run along the discard logic (since the discard is a part of the riichi call). As always pick the discard that results in the most ukeire for the hand.

### How to factor in value of potential melds via yaku, dora

E.g. if i have winds and dragons, how does the algo factor in that some winds don't contribute to yaku

---

# Appendix

### English translation of Shanten calculation algorithm

[Link](https://tomohxx.github.io/mahjong-algorithm-book/ssrf/#_4)

Shanten number is defined as "the minimum number of tiles needed to achieve tenpai state". It's quite difficult to calculate this number (tn: why?), so instead we'll calculate a new concept: "replacement number". Replacement number is defined as "the minimum number of tiles needed to win the hand". The relation between Shanten (S(h)) and Replacement (T(h)) is shown in the formula below:

```
S(h) = T(h) - 1
```

...
