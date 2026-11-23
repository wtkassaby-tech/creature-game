# Plan 11: make it look built by a studio

Ayrton, 23 November 2026: "Game looks good but it could look more expensive, I want it to present as a game built by a studio." He pointed to a short video on particle effects whose advice is:

1. **LightEmission = 1**: particles blend additively and glow, even in shade.
2. **Size is a curve**: small at birth, peaking early, shrinking to nothing.
3. **Transparency fades in and out**, so a particle never pops on or off.

## Where we are

- **Lighting is done well.** Atmosphere, bloom, sun rays and a colour grade are set in `src/server/World/Dressing.luau`.
- **There is not one particle in the game.** A move is a lunge, a white flash and a shake. A catch, a faint and a level-up have no effect at all. The towns are still: no smoke from chimneys, no glow from the kiln, nothing drifting in the air.
- **Screens cut** instead of moving. Nothing transitions into a battle, and panels appear with a small pop at most.

A studio game reads as expensive mainly through **motion and light**. The art is there now, so this plan adds motion and light everywhere a player looks.

## Rules for every effect

- Follow the three rules above for every glowing effect. Smoke and dust are the exception: they keep `LightEmission` low so they stay soft.
- **Textures:** only the engine's own particle textures (`rbxasset://textures/particles/...`) or ones we make in Studio. No outside assets.
- **Original:** no recreated effects from another game.
- **Phones:**
  - Each effect is a short burst (`Emit(n)`), not a constant stream, unless it is ambience.
  - Ambience uses low `Rate` values, and each biome stays under a fixed budget (see package 2).
- **Looks only:** effects never decide anything, so all randomness in them uses `Random.new()` on the device. Everything shown still comes from the server's messages.
- **Clean-up:** every effect cleans up after itself (`Debris` or a `task.delay` destroy), and battle effects go when the battle closes.

## Package 1: battle effects (client, `src/client/Fx/` and `src/client/BattleView/BattleStage`, `BattleFx`, `BattleView`)

- **`src/client/Fx/Particles.luau`:** one place for presets built to the three rules. Each preset is a function that makes an emitter.
  - Presets: sparkle, glow puff, smoke puff, dust kick, droplets, leaf flutter, ember, toxic bubble, star burst, ring shockwave (a flat expanding disc), rising motes.
  - Each takes a colour.
- **A move effect per type.** Each one travels from the attacker to the target, then bursts on impact:
  - **Leaf:** spinning leaves.
  - **Water:** a droplet arc and a splash.
  - **Sand:** a grit spray and a dust cloud.
  - **Toxic:** bubbles and a purple puff.
  - Every other type in `TypeChart` gets a sensible effect as well: there are eleven biomes.
- **Hit strength:**
  - **STRONG:** a bigger burst, a short camera shake and a white flash on the screen edge.
  - **WEAK:** a small grey puff.
- **Faint:** the creature sinks into a soft dust puff with rising motes.
- **Switch:** a glow burst and a ring when a creature steps in.
- **Catch:** a burst of gold sparkles and a ring where the lasso closes, then rising stars.
- **Level-up:** a column of rising green and gold motes on the creature, timed with the "reached level" line.
- **Battle intro:** the camera opens wide on both creatures and settles behind the player's creature, about 0.8 s.
- **Idle:** both creatures breathe gently (a slow scale or bob) while waiting, so nothing stands frozen.

## Package 2: a living world (server-built ambience, `src/server/World/Ambience.luau`)

- **Chimney smoke:** soft, slow and grey, from every house model with a chimney. Positions are measured on each model and kept in a table.
- **The Cradle Kiln:** a warm glow (`PointLight`) and rising embers.
- **Lamps:** each street lamp gets a warm `PointLight` and a faint halo.
- **Drifting motes:** pollen and seed fluff over Greenwood's meadows, dust over Dust Canyon's wash, and spray and sea mist along Tide Flats' shore.
- **Water:** a slow sparkle on the harbour and the pools.
- **Budget:** each biome declares its ambience in its dressing sheet (`ambience` field), so later biomes get their own by adding data. A test counts the emitters and their combined `Rate`, and fails if a biome goes over budget.

## Package 3: movement on screen (`src/client/UI/Kit.luau`, `src/client/UI/Transition.luau`, `ResultPanel`, `StoryView`, Creatures screen)

- **Buttons:** a press squash (scale to 0.94 and back with a slight overshoot), and a lift on hover on desktop. One place in `Kit`, so every button gets it.
- **`Transition.luau`:**
  - Into a battle: a quick wipe in the cream handheld style, such as an iris close and open or bars sweeping across.
  - Travel and waking at the healer: a fade to black.
- **Panels:**
  - The dialogue box slides up.
  - The result panel drops in with a little bounce, and its ribbon gets a moving shine.
  - The Creatures screen slides in.
- **Timing:** nothing takes longer than 0.35 s, and nothing waits on an animation before taking input.

## Order and checks

The three packages touch different files and are built side by side. Each one:

1. passes `lune run check`;
2. is played in Studio, at desktop and phone size;
3. is judged from screenshots against the cream, clay-toy look.

Frame rate is checked in the busiest place, Tide Flats, before the packages are called done.
