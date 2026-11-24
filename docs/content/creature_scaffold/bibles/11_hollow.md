# Creature design bible 11: The Hollow

Sources: 00_ROSTER_PLAN (section 11 and the mythic tier), 00_BREEDING_STANDARD, the loved-creature research (Pokemon polls, Roblox hits), and 13_WORLD_DESIGN (the Hollow is the crater's east half, "Old Hearth" camp, tear-lit sky preset). The eras synthesis file does not exist yet, so nothing here depends on it.

The Hollow is the centre of the world and the last biome. Ten species, one per type, so it is the whole type chart in one place. Its creatures are the Firstling's oldest kin: statues that woke up. This is the most "designed" biome of the eleven, and it must still read as the same cozy clay-toy game.

## 1. Visual identity

**Idea in one line:** a temple garden after the festival, with the lamps still lit and the statues quietly alive.

**Palette (flat blocks, matte clay):**

| Role | Name | Hex | Use |
| --- | --- | --- | --- |
| Base 1 | Weathered stone | #D9D2C3 | Main body colour on most species |
| Base 2 | Warm ruin grey | #A89F94 | Second colour, carved shadow, undersides |
| Accent (metal) | Gold leaf | #E3B341 | Trim, one feature per species at most |
| Accent (metal) | Temple bronze | #9C6B3A | Censers, grates, claws |
| Light | Violet ember | #B58AD6 | Eye glow, tear-lit rim, petals |
| Life | Petal rose | #E8A0B4 | Drifting petals, cheeks, blush |
| Life | Ivy green | #6F8F5A | Moss and ivy, Leaf species only |

The Hollow is the only biome whose base is near-neutral. That is deliberate: neutral stone makes the one glass patch pop.

**The glass patch rule (the biome's signature).** Every species carries exactly one inset "patch" of opaque coloured glass in its type's colour, with a dark leading line round it, painted bright, not glowing (the Meshy rule). The patch sits on a different part on different species, so the ten patches are not all on the chest. Glow comes from Neon and effects in Roblox, never from the mesh. This is the one place a player sees all ten type colours together.

**Materials:** carved pale stone, mosaic tile, faded tapestry cloth, aged bronze, a little gold leaf, ivy. All matte clay with a light chisel-line grain. Nothing see-through, nothing floating, nothing thin.

**Shape language:** blocky and fitted, built from joined stones, with rounded corners and no sharp points. Arches, steps and fluting repeat. Symmetry is allowed (statues are formal), but every species needs one asymmetric break (a chipped ear, a drooping banner) so it feels alive, not sterile.

**Motifs:** arches, mosaic tessellation, stitched seams (an echo of the Firstling's patchwork), hearth and fire, petals, banners, and worn-smooth surfaces where hands have rubbed them.

## 2. Target mix

| Mood | Count | Species | Why |
| --- | --- | --- | --- |
| Cool | 4 | Tesserine, Embergrate, Bannerwing, Fountcoil | Cool designs outnumber cute ones in the global top 40, and the last biome should hold what players most want to show off. Tile and hearth surfaces also take gem-tier effects well. |
| Majestic | 3 | Mossaltar, Tapestrel, Rimedove | The biome is a sacred place; a bulky altar ox, a living tapestry and a carved dove sell that. Majestic is the evidence's strongest "legendary feel" class. |
| Creepy-cute | 2 | Censerling, Riftling | The ghostly-but-lovable class does well in the polls (Gengar, Mimikyu). Riftling is the story's warning sign and must be unsettling and lovable at once. |
| Cute | 1 | Sphinxling | One soft anchor so the biome is not all gravitas, and a friendly first Hollow catch. |

Why not more cute: the late-game audience is attached and wants to show off, and the Hollow's identity is stone and solemnity. Why not fewer: the cute one is what stops the "grim temple" risk (section 7).

## 3. Archetypes from the loved evidence that fit here

Principles only; no existing creature is copied.

1. **Canine, feline and dragon-like bodies make up about half the favourites.** The Hollow's Quads (ox, sphinx cub, pangolin) and its giant hound cover this. Keep at least one clearly cat- or dog-shaped silhouette near the front (Sphinxling is the cat).
2. **One signature feature grown into the body.** Altar back, tile scales, hearth belly, banner wings, fountain neck. The feature is the body, not an accessory.
3. **Two or three colours plus one accent.** Stone, ruin grey, plus a gold or glass accent. The glass patch is the accent.
4. **A personality or story hook per creature.** "Forgot its own riddle", "tells the first story across its body". One readable line each.
5. **One readable mood.** Sleepy, proud, fussy, wistful; never mixed.
6. **Rarity visible on Roblox through glow, size and outline.** Gem tiers are effects on these same meshes (tint, sparkle, rim highlight). Stone and tile give broad surfaces for sheen.

## 4. The rare-look colour rule (shiny-style)

Rule: **the stone goes to dusk, the metal goes to gold, the glass goes to its complement.** The rare look swaps the neutral body to deep dusk stone (#6E6A82, a cool violet-grey), turns bronze trim to bright gold leaf (#E3B341), and shifts the glass patch to the complement of its type colour. A pale stone creature becomes a dark one with a bright patch, which reads at phone distance. It is applied through the runtime tint on the colour blocks, so it needs no extra meshes. It is a separate axis from rarity tiers, so a rare-look Amber Tesserine can exist.

## 5. The giant: Hearthwarden

**Concept:** a colossal ruin hound built from fitted stone blocks, the old guard of the hearth, with ten glass insets down its flank (one per type) that read like a stained-glass window you can fight. Warm and sad, not scary: it has waited a very long time for someone to come home.

**Fight tell:** its type changes each phase, and **the glass inset for the next type lights a turn ahead** (the roster plan's idea, which needs a small giant-rule change flagged for Ayrton). The tell is one bright pane, the hound shifting its weight toward that side, and one low pulse of the matching colour through its eyes. Players learn to read the window, then pick a counter from a 6v6 team. No randomness: the lesson is "read, then switch".

## 6. Mascot candidate

**Tesserine** (Crystal pangolin with mosaic-tile scales; already marked a gem showcase). It is the clearest "one signature feature grown into the body" in the biome; mosaic tile is broad, simple surface that takes gem-tier sparkle best; a pangolin is cute and cool at once; and its tessellation hints at the Firstling's patchwork, so it carries the story. Fallback: Sphinxling, if the mascot should be friendlier, since it is the cuddlier first catch.

## 7. Three risks to avoid

1. **Too grey and too solemn.** A stone biome can feel dead after ten colourful ones. Counter: petals, ember light, one cute species, and a bright glass patch on every creature, with warm expressions.
2. **Looking like the Firstling, or like Arceus, by accident.** Gold rings, white horse bodies and a divine pale look sit on the roster plan's avoid list. Counter: no Hollow species is white or horse-shaped, none wears a halo, and the Firstling stays a small multicoloured patchwork cub.
3. **Ten look-alikes.** One neutral base plus one patch can blur together. Counter: each species gets a distinct silhouette and a different body part for its patch; check by squinting at a silhouette sheet and by greyscale, where no two should match.
