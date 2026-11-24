# Approval pack 5: purchases

Date: 21 November 2026. For: Ayrton. Status: **draft, waiting for your answers. Nothing here is built.** The master plan called this "pack 4"; the giant capture pack took that number.

This pack covers everything that touches Robux: what is sold, for how much, and how a purchase is handled safely. It needs your yes before any of it is built, and Roblox's rules must be re-read just before launch (they changed several times in 2026).

## 1. What is already decided

- Sell convenience, capacity and looks. Never sell battle power, rarity, serial numbers, coins, or anything with a random result. (Brief section 11.)
- Coins are never sold. Breeding Candy and Giant Candy are never sold. Lassos, bait and breeding are paid with earned coins only, so catching and breeding stay free random outcomes. (Decisions log.)
- Gems buy time and capacity only: a shorter hatch timer, an extra pen, extra stable room. They never touch a roll. Pens stop at 4. (Approved in pack 3.)
- Because nothing random is sold, the paid-random-items rules (odds tables, the restricted-countries check) do not apply to anything in this pack. If that ever changes, those rules come first.

## 2. Proposed products at launch

Prices are placeholders for you to set. I have kept the list short on purpose: every product is one more thing to explain, test and support.

**Game passes (bought once, kept for ever)**

| Pass | What it does | Suggested price |
| --- | --- | --- |
| Bigger Stable | +30 stable room (60 instead of 30 to start with) | 199 Robux |
| Second Nest | +1 breeding pen (still inside the cap of 4) | 249 Robux |
| Quick Hatch | Eggs hatch in half the time | 299 Robux |

**Gems (bought in bundles, spent in the game)**

| Bundle | Gems | Suggested price |
| --- | --- | --- |
| Handful | 100 | 99 Robux |
| Pouch | 550 | 499 Robux |
| Chest | 1,200 | 999 Robux |

| What Gems buy | Cost |
| --- | --- |
| Finish one egg now | 1 Gem for each 3 minutes left, at least 5 |
| +10 stable room (after the coin expansions run out) | 150 Gems |
| +1 pen (up to the cap of 4) | 300 Gems |

**Looks (later, not at launch):** lasso skins, a trail or aura for the creature that is out, town-home decoration. Listed so you know where the list goes next; I would not build these before the soft launch.

**Small free Gems:** the brief says "small amounts from milestones". I suggest 20 Gems with each badge, so every player meets the shop once without paying.

## 3. Questions that are yours

1. **The list.** Is this the right launch list? Anything to add or remove?
2. **Prices.** Set them, or tell me a rule ("cheap", "match the leading games") and I will propose numbers with reasons.
3. **Quick Hatch and the economy.** Halving hatch time lets a paying player breed about twice as often when candy allows. Candy, not time, is the real limit on gem-tier creatures, so I think this is fair. If you would rather be stricter: 25% faster.
4. **Free Gems.** 20 with each badge: yes or no?
5. **Refunds and mistakes.** If a player says a purchase did not arrive, the only safe answer is a support tool that reads the purchase log (section 4) and grants it again by hand. Who answers those messages at launch?

## 4. How a purchase is handled

This follows the project's standing rules; nothing here is new design.

1. The player presses Buy; Roblox takes the payment and calls the server with a receipt.
2. The server looks the receipt's id up in the player's saved record. If it is already there, the purchase was granted before: say "done" and stop. This is what makes a repeated call harmless.
3. Otherwise, in one step: the Gems (or the pass's effect) are added and the receipt id is written into the record.
4. The server tells Roblox "done" only after that record has been saved. If the save fails, Roblox is told "not yet" and calls again later; step 2 then stops a double grant.
5. Every purchase is logged with the player, the product, the receipt id and the result.

What can go wrong, and the answer:

| Risk | Answer |
| --- | --- |
| Roblox calls twice for one payment | The receipt id is already in the record: nothing is granted again |
| The server stops between the grant and the save | Roblox was not told "done", so it calls again; the record has no receipt id, so it grants once |
| The player leaves during the purchase | The grant waits for their record to be loaded; Roblox keeps calling until it is |
| A device claims a purchase that never happened | Only Roblox's own call to the server grants anything; nothing a device sends can |
| A pass bought on the website, not in the game | The server asks Roblox whether the player owns each pass when they join |
| Gems spent twice from two requests at once | The spend checks and takes the Gems in one step with no pause, like every other spend in the game |

## 5. Testing

- Lune: the receipt rule (grant once, however many times the same receipt arrives), every Gem spend (not enough, exactly enough, the caps), pass effects on stable room, pens and hatch time.
- Studio: a test purchase of each product; the same receipt delivered twice; leaving during a purchase; a pass owned before joining.
- An independent exploit review of all of it before it goes live.

## 6. What you are approving

- [ ] The launch product list and prices in section 2 (or your changes).
- [ ] Answers to the five questions in section 3.
- [ ] The purchase handling in section 4.
