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
   - Texture: on, with the clay colours from the picture. No metallic or glossy finish.
   - Pose: neutral standing. Four-legged: back level, all four legs straight down, tail out behind (not curled over the back), head forward. Two-legged: upright, arms hanging at the sides, legs straight down.
4. **Check before exporting:** it reads as the creature at a glance; the face is clear; no clothes or held objects; the parts look like head, body, legs, tail (and arms for Mossmitt), not random chunks.
5. **Export as GLB** (with textures). Also export FBX if it is offered.
6. **Save the files here**, one folder per creature:
   `C:\Users\will\Documents\creature-game\art\meshy\Sloshcalf\`, `...\Spadesnout\`, `...\Mossmitt\`.
   Put the picture you used in the same folder. Then tell me, and I will import them into Studio, check the parts, joints and triangle counts, and put them beside the current models.

## Prompts

Use this style text at the start of every prompt:

> cozy handmade clay toy creature, soft matte plasticine, chunky rounded proportions, big friendly eyes, simple flat colours, original creature design, no clothing, no held objects, full body, plain white background, three-quarter view

**Sloshcalf** (gentle worrier, Water):
> a small four-legged calf creature with smooth blue-teal clay skin and a cream belly, a clear round water bubble on its back with a tiny pond and two little orange fish inside, short stubby legs, small round horns, soft worried eyebrows and a shy smile, a little leaf sprout on its head, a short tail with a water-drop tuft

**Spadesnout** (fiercely proud, Sand):
> a four-legged digging creature with warm sandy-orange clay fur and a cream belly, a wide flat spade-shaped snout like a little shovel, strong front paws with blunt digging claws, a proud puffed-out chest, confident half-closed eyes and a smug grin, a short club tail with a pebble pattern, a smudge of mud on its nose

**Mossmitt** (cheerful show-off, Leaf):
> a small two-legged creature with a round mossy green body and a warm brown face, oversized puffy mitten hands made of moss, a little clover on top of its head, a big beaming grin and bright eyes, short sturdy legs, a tiny moss tuft tail, standing like a proud little boxer

## What happens after

- If the parts come out clean, I build the part pipeline: Sloshcalf x Spadesnout babies will mix heads, legs and tails on screen, which is the game's signature that is missing today.
- If the models are better but the parts are messy, we try Tripo's segmentation on the same three before deciding.
- Either way, the 36-creature roster is converted in batches, with each new creature's personality quirk (`docs/content/CREATURE_PERSONALITY.md`) designed in from the picture stage.
