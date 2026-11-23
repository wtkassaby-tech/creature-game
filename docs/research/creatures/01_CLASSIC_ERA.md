# Creature design research 01: the classic era (Generations 1 and 2)

Why the first two generations of Pokémon designs (Ken Sugimori's art direction, 1996 to 1999) became iconic, turned into principles for our own cozy clay-toy creatures (low-poly, chunky parts, flat colours; brief section 12). We take the reasoning, never the creatures: every species stays original (CLAUDE.md hard rule 2).

Sources are mostly second-hand designer interviews, design blogs and fan discussion, so claims about *why* fans love a design are informed opinion. Nostalgia also counts: some of the first 151's fame comes from being first.

## 1. Constraints made the designs strong

The original designs began as tiny black-and-white Game Boy sprites (Sugimori: early on, none had any colour). A sprite of about 56 by 56 pixels cannot carry fine detail, so every design had to read from its **outline and one or two big shapes**.

**Principle:** design for the smallest view first. For us that is the creature icon in the party strip on a phone, a ViewportFrame of about 60 pixels, and a creature seen across a field. If a design only works in a close-up, it is not finished.

## 2. Silhouette readability

The standard test is to fill the creature in solid black and check you can still name it. The classic designs pass because each has one or two **protrusions that are unique to it**: a distinctive ear shape, a tail with a clear end, a shell, a flame, a bulb on the back. The body underneath is often a plain bean, ball or pear.

Silhouettes fail when every protrusion is the same size, when features sit inside the outline instead of breaking it, or when ten creatures share one outline (analysts note many Game Boy sprites did, which hurt memorability).

**Principle:** each species owns at least one outline feature nobody else in its biome has. Because our creatures are bred from parts, the feature should sit on a part slot (head, tail, back) so a hybrid inherits a recognisable chunk of each parent's outline.

## 3. Shape language

The common character-design vocabulary, which the classic designs follow closely:

| Shape | Reads as | Typical use |
| --- | --- | --- |
| Circle, oval, bean | friendly, soft, safe, young | first stages, starters, healers, companions |
| Square, block, wide base | sturdy, reliable, heavy, calm | tanks, defenders, the "big gentle" creature |
| Triangle, spike, point | danger, speed, tension, edge | attackers, rivals, final stages, villain creatures |

Classic lines often move along this scale as they evolve: a round first stage, a more angular middle, a final form that is big and square or sharp and spiky. One shape should dominate; the others are accents. A round creature with one triangle (an ear, a horn) reads as "cute with attitude", which is exactly the tone the series sells.

**Principle:** choose the dominant shape before anything else, and match it to the creature's battle role and temperament.

## 4. Limited palettes and colour blocking

Generation 1 designs usually have **one main colour with one lighter or darker accent**. About forty of them share a pale belly. Where the screen could not show colour, designers used high-contrast details (stripes, tips, patches) that read even in greyscale. Generation 2 had more colour (four per sprite, one transparent) and its designs often use three or four main colours, which some analysts find less iconic.

The best palettes use colour in **large blocks that follow the shape**: a body colour, a belly colour, and one accent on the signature feature (ear tips, tail end, a stripe). The accent often marks the gimmick.

**Principle:** two main colours plus one accent; a third main colour needs a reason. This also suits our runtime colouring, where colour variants and gem tiers are applied on top of the mesh: a design that is two blocks plus an accent recolours cleanly.

## 5. One memorable gimmick

The designs that stuck have one idea you can say in a sentence: a creature that stores lightning in its cheeks, a lizard whose tail flame shows its life, a turtle with a cannon shell, a seed that grows on its back. Pikachu's designer, Atsuko Nishida, has said the cheek idea came from watching squirrels store food. The gimmick usually links **how it looks** to **what it does in battle** and to **a small piece of lore**.

Sugimori adds a twist: designs need a small imperfection to be remembered. He keeps something "uncool" on a design that is too cool, or something cheerful on one that is too dark, and he has said that a face detail fans asked him to remove stayed because it made the face memorable. Perfectly polished designs are forgettable.

**Principle:** write the gimmick as one sentence before modelling. Then add one charming flaw: a lopsided ear, a stubby tail, freckles, a too-big paw.

## 6. Animal plus object or concept

The strongest classic designs are **a familiar animal bent towards one other idea**: an animal plus an element, a plant, an object or a myth. Analysts describe Generation 1 as taking an animal's most notable feature and pushing it until it felt otherworldly. Players recognise the animal at once (so the creature feels alive and readable), and the second idea makes it new.

Generation 2 leaned further towards plausible animals and plants that fit an ecosystem. Pure objects with a face are the most criticised group (section 11).

**Principle:** start from an animal, add exactly one twist, and make sure the twist is legible at icon size.

## 7. Faces and expression

- **Eyes carry the personality.** Generation 1 used a small set of eye styles: friendly round eyes, cute large anime eyes, narrow "mystical" eyes and angry brow-heavy eyes. The limited set made the generation feel like one family. Generation 2's most common eye was a dark oval with one highlight, and angry eyes were saved for aggressive creatures.
- **Placement:** cute faces put large eyes low and wide on a big head, with a small mouth and small or no nose. This is the "baby schema" studied since Konrad Lorenz; experiments show that a round face, high forehead, big eyes and a small nose and mouth raise perceived cuteness and the urge to care for it.
- **Mouths:** small and simple for cute creatures (a dot, a "w", a tiny open smile); wide, toothy or fanged for fierce ones. A single visible fang on a cute face is a classic "cute with attitude" accent.
- **Hands and feet:** Generation 1 reused three-claw hands; Generation 2 moved to soft nubs, which read cuter and suit clay.

**Principle:** pick an eye style per temperament and reuse a small house set across all species, so our roster looks like one world.

## 8. Proportion and chibi-ness

First stages are drawn with big heads (often half the height or more), short limbs, round bodies and big eyes. Final stages lengthen limbs, shrink the head relative to the body, sharpen the eyes and add mass. Generation 2's baby forms, which came with breeding, are simpler and rounder versions of their parents.

**Principle:** proportion is our main lever for age and power. Our part-based scaling should push head-to-body ratio and limb length per stage, so a young creature looks young even before its parts change.

## 9. Starters are built to be loved

Starters are the first creature a player owns and the one they spend most time with. Classic starters share a pattern: a round, chibi first stage with its element shown on the body (a flame, a leaf, water), a friendly face, and a promise of power. Fans praise final forms that pay off that promise and criticise lines that lose the charm after stage one. Critics also warn that starters made too round and simple (for easy toys) become bland.

**Principle:** every starter must be cute at stage one, show its element on its body, and have a final form that keeps one feature of the baby so the player still recognises their friend.

## 10. Evolution lines and legendaries

Classic lines escalate **cute, then cool, then powerful**: size grows, the dominant shape shifts from circle towards square or triangle, eyes narrow, and the gimmick grows (the seed becomes a flower, the tail flame becomes wings of fire). The silhouette keeps one constant feature across all stages.

Generation 1 legendaries were mostly "strong and rare" and looked fairly ordinary. Generation 2 gave them myths, places and story events, and set the pattern since. A legendary feels special through **story, setting and scarcity first**, design second: an unusual body plan, a colour no common creature uses, a calm or regal face, and an encounter that is an event.

**Principle:** legendaries (our giants and rare story creatures) get lore, a unique place in the story and a body plan or palette the common roster never uses.

## 11. Common failures

- **Too busy.** The commonest complaint about later designs: extra spikes, belts, panels, competing colours, all of which vanish at icon size. Legendaries draw it most. Sugimori said in 2013 he wanted to return to the first games' simplicity.
- **Object with a face.** A plain object (an ice cream, a bin bag, a key ring) with eyes added is the most criticised kind, often called lazy. Fans accept objects when the concept is obvious and fits a type (a ghost lamp, an electric magnet) or is blended with a real creature.
- **Lazy concept.** A real animal with almost no twist, or a design whose meaning depends on lore most players never read.
- **Too cool.** Sugimori warns that a design pushed too far towards cool stops being memorable.
- **Humanoid.** Very human-shaped designs are among the least liked in fan discussion.
- **Final forms that lose the baby.** Players feel the creature they loved is gone.

## 12. Younger and older players

Younger children respond to round shapes, big eyes, bright simple colours and a gimmick they can explain and draw. A 2002 *Science* letter (Balmford et al.) found eight-year-olds identified about 78% of Pokémon from cards but only about 53% of common wildlife: simple, distinct designs are very learnable. Older players lean towards cool final forms, dragons, dark and mythic designs, rarity and strength. The classic answer serves both inside one line: cute first stage, cool final stage, and Sugimori's "balance" touches so neither extreme wins.

## Rules we take from this

- [ ] **Icon test:** the creature is recognisable as a solid black shape at about 60 pixels.
- [ ] **One owned outline feature** per species, on a part slot so it survives breeding.
- [ ] **One dominant shape** (circle, square or triangle) matched to role and temperament.
- [ ] **Two main colours plus one accent**, in large blocks; the accent marks the gimmick.
- [ ] **One-sentence gimmick** that links look, battle role and a little lore.
- [ ] **One charming flaw** so the design is remembered, not just polished.
- [ ] **Animal plus one twist**; no plain object with a face.
- [ ] **A small house set of eye styles** reused across the roster; eyes low and large for cute, narrow for fierce.
- [ ] **Proportion shows stage:** big head and short limbs young, longer limbs and smaller head when evolved.
- [ ] **Evolution keeps one constant feature** from the first stage to the last.
- [ ] **Starters:** cute at stage one, element visible on the body, final form pays off the promise.
- [ ] **Legendaries and giants:** story, place and scarcity first; a body plan or palette the common roster never uses.
- [ ] **Cut detail until it hurts**, then cut one more piece. Chunky clay forms, no greebles.
- [ ] **Never copy:** no creature, name or signature feature taken from any existing game.

## Sources

- Siliconera, "Pokémon designer on balancing cool or cute Pokémon by adding uncool or uncute features": https://www.siliconera.com/pokmon-designer-on-balancing-cool-or-cute-pokmon-by-adding-uncool-or-uncute-features/
- Nintendo Life, "Ken Sugimori wants Pokémon designs to be as memorable as possible" (2018): https://www.nintendolife.com/news/2018/07/ken_sugimori_wants_pokemon_designs_to_be_as_memorable_as_possible
- Nintendo Life, "Pokémon art director would like to simplify the next generation" (2013): https://www.nintendolife.com/news/2013/11/pokemon_art_director_would_like_to_simplify_the_next_generation_of_the_franchise
- Pokémon.com, "Creator profile: the creators of Pikachu": https://www.pokemon.com/uk/pokemon-news/creator-profile-the-creators-of-pikachu
- Kotaku, "Pikachu wasn't based on a mouse but a squirrel": https://kotaku.com/pikachu-wasnt-based-on-a-mouse-but-a-squirrel-1825738117
- Bulbapedia, Ken Sugimori: https://bulbapedia.bulbagarden.net/wiki/Ken_Sugimori
- Game Developer, "Evolution of Pokémon designs: Gen 1": https://www.gamedeveloper.com/design/evolution-of-pokemon-designs-gen-1
- Game Developer, "Evolution of Pokémon designs: Gen 2": https://www.gamedeveloper.com/design/evolution-of-pokemon-designs-gen-2
- Smogon, "The evolution of Pokémon art over the years": https://www.smogon.com/articles/pokemon-art-through-ages
- GamerBraves, "How the Gen 1 Pokémon designs made a great first impression": https://gamerbraves.substack.com/p/gamerbraves-newsletter-vol-83-how
- Gizmodo, "Why have starter Pokémon gotten cuter?": https://gizmodo.com/why-have-starter-pokemon-gotten-cuter-1848603714
- Kotaku, "Pokémon designs aren't getting worse": https://kotaku.com/pokemon-designs-arent-getting-worse-they-may-be-gettin-5969098
- Serebii forums, "Why are Pokémon based on inanimate objects or human-like the least liked?": https://forums.serebii.net/threads/why-are-pokemon-based-on-inanimate-objects-or-look-human-like-the-least-liked.654056/
- TheGamer, "Worst Pokémon based on objects": https://www.thegamer.com/worst-pokemon-based-on-objects-vanillite/
- Creative Bloq, "How shape can make or break your character art": https://www.creativebloq.com/art/digital-art/how-shape-can-make-or-break-your-character-art
- CG Wire, "Character shape language": https://blog.cg-wire.com/character-shape-language/
- Glocker et al., "Baby schema in infant faces induces cuteness perception and motivation for caretaking in adults" (2009): https://pmc.ncbi.nlm.nih.gov/articles/PMC3260535
- Balmford et al., "Why conservationists should heed Pokémon", *Science* 295 (2002), summary: https://eepro.naaee.org/research/eeresearch/why-conservationists-should-heed-pokemon
