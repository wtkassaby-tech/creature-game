# Meshy pilot: three creatures

Date: 23 November 2026. For: Ayrton. Goal: find out whether Meshy can give us creatures that (1) look better and have more personality than the current models, and (2) come apart into parts, so breeding can visibly mix two parents. Three creatures only; we decide after seeing them in Studio.

## The three

| Creature | Why it is in the pilot |
| --- | --- |
| **Sloshcalf** (four-legged, Water starter) | Breeding test, parent A |
| **Spadesnout** (four-legged, Sand starter) | Breeding test, parent B: same body plan as Sloshcalf, so their heads, legs and tails can swap |
| **Mossmitt** (two-legged, Leaf starter) | Quality test on a two-legged creature |

## What to do, step by step

1. **Sign up for Meshy Pro** (monthly is fine for a pilot). Paid plans keep the models private and yours; do not use free-plan outputs in the game.
2. **Make a picture first** for each creature: Meshy's Text to Image (or any image tool you like), using the prompts below. Keep generating until one looks cute, original and clearly the creature described. You want a clean, plain background, the whole body in view, facing three-quarters toward the camera.
   - If Meshy offers multi-view (front, side, back), use it: the 3D comes out much more on-model.
3. **Image to 3D** from that picture, with these settings:
   - Style: stylised / cartoon (not realistic).
   - **Topology: Smart Topology, low poly, about 3,000 triangles for the whole creature** (phones).
   - **Part segmentation: on.** (This is the key test.)
   - Texture: on, with the clay colours from the picture. Matte clay body, no metallic or glossy finish (only the eyes are glossy cartoon eyes with white highlights).
   - Pose: neutral standing. Four-legged: back level, all four legs straight down, tail out behind (not curled over the back), head forward. Two-legged: upright, arms hanging at the sides, legs straight down.
4. **Check before exporting:** it reads as the creature at a glance; the face is clear; no clothes or held objects; the parts look like head, body, legs, tail (and arms for Mossmitt), not random chunks.
5. **Export as GLB** (with textures). Also export FBX if it is offered.
6. **Save the files here**, one folder per creature:
   `C:\Users\will\Documents\creature-game\art\meshy\Sloshcalf\`, `...\Spadesnout\`, `...\Mossmitt\`.
   Put the picture you used in the same folder. Then tell me, and I will import them into Studio, check the parts, joints and triangle counts, and put them beside the current models.

## Prompts

Art style (owner decision, 24 November 2026): clay bodies with cartoon eyes. Meshy's text box takes 800 characters at most, so each prompt below is a complete short prompt: the style line, then the creature. Paste it whole; do not add to it. Every length was counted by script (Unicode characters).

Style line (the start of every prompt):

> Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face.

**Sloshcalf** (gentle worrier, Water), short prompt, 781 characters:
> Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Four-legged: level loaf body, short stubby straight legs with gaps, round head on a short neck in a collar. A small calf with smooth blue-teal clay skin and a cream belly, soft worried eyebrows and a shy smile, small round horns, a little leaf sprout on its head. On its back a clear round water bubble painted glassy, holding a tiny pond and two little orange fish. Short tail with a water-drop tuft. Parts separate, plain at joints. No clothing, no held objects. Three-quarter front view, full body, white background. No text, no base.

**Spadesnout** (fiercely proud, Sand), short prompt, 794 characters:
> Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Four-legged: level loaf body, four short straight legs with gaps, round head on a short neck in a collar. A digging creature with warm sandy-orange clay fur and a cream belly, a wide flat spade-shaped snout like a little shovel with a smudge of mud on its nose, confident half-closed eyes and a smug grin, a proud puffed-out chest. Strong front paws with blunt digging claws. Short club tail with a pebble pattern. Parts separate, plain at joints. No clothing, no held objects. Three-quarter front view, full body, white background. No text, no base.

**Mossmitt** (cheerful show-off, Leaf), short prompt, 745 characters:
> Claymation creature for a Pokémon-inspired Roblox game: matte hand-sculpted plasticine with thumbprint texture, chunky rounded shape, big glossy cartoon eyes with white highlights, expressive face. Matte body; only eyes, glass and water shine. Two-legged: round pear body, big round head in a collar, short sturdy legs, small low tail. A small creature with a round mossy green body and a warm brown face, bright eyes, a big beaming grin, a little clover on top of its head. Oversized puffy mitten hands made of moss, held clear of the body, arms down. A tiny moss tuft tail. Stands like a proud little boxer. Parts separate, plain at joints. No clothing, no held objects. Three-quarter front view, full body, white background. No text, no base.

## What happens after

- If the parts come out clean, I build the part pipeline: Sloshcalf x Spadesnout babies will mix heads, legs and tails on screen, which is the game's signature that is missing today.
- If the models are better but the parts are messy, we try Tripo's segmentation on the same three before deciding.
- Either way, the 36-creature roster is converted in batches, with each new creature's personality quirk (`docs/content/CREATURE_PERSONALITY.md`) designed in from the picture stage.
