# Creature part specification

Status: version 1, written 16 November 2026 for the art test (`ART_TEST.md`). Every number here is a [Default] that the art test may change. The Assembler (`src/client/Assembler/Assembler.luau`), the fit maths (`src/shared/AssemblyMath.luau`) and the species data type (`SpeciesDef` in `src/shared/Types.luau`) already use these names; if this file and the code disagree, fix the one that is wrong and say so in `PROGRESS.md`.

The validator `tools/studio/ValidateParts.luau` checks every rule below that code can check. Rule numbers (R01 to R15) match its output and the checklist in section 14.

## 1. What a part is

A creature is built from five **templates** per species. A template is a prepared `MeshPart`, stored in Studio, cloned at runtime by the Assembler. Scripts cannot change a MeshPart's mesh, so every part a creature can ever wear must exist as a template.

The Assembler joins six clones to a torso with six `Motor6D` joints (head, two front limbs, two legs, tail). Parts from different species mix freely **within one body plan**. Parts never mix across plans (a Quad head does not go on a Biped torso), because their rest poses differ.

## 2. Body plans and rig

Launch has two plans (`DECISIONS.md`, 16 Nov 2026): **Quad** (four-legged) and **Biped** (two-legged). Winged and Serpent come later and need their own sections.

Both plans use the same template names and the same six joints, so the Assembler is one code path. Only the sockets' positions and the parts' rest poses differ.

| Plan | What the front limbs are | Rest pose |
| --- | --- | --- |
| Quad | Front legs. They reach the ground like the hind legs | Body horizontal, long axis along Z. All four limbs hang straight down |
| Biped | Arms. They hang at the sides and never reach the ground | Body upright, long axis along Y. Arms hang straight down, legs straight down |

Where a Biped's FrontLimb is called an arm in this file, the template is still named `FrontLimb`, the slot is still `FrontLimbs` and the joints are still `FrontLimbL` and `FrontLimbR`.

## 3. Axes and facing

Roblox part axes, used for every template and for the creature as a whole:

- The creature **faces -Z** (Roblox's forward). Its tail points toward +Z. Up is +Y.
- With the creature facing -Z, its **right is +X and its left is -X**. So `...SocketL` sits at negative X and `...SocketR` at positive X.
- Every part is authored in the **torso's frame, in its rest pose**: a part's local axes equal the torso's axes when it is attached. Attachments carry **no rotation** (R07). A part that comes out of the generator turned 90 degrees fails R10; a mesh cannot be rotated inside its MeshPart, so it must be regenerated or fixed in a modelling tool.
- Rest-pose directions, from the ball end (the end that sits in the torso) toward the far tip:

| Template | Quad: far tip lies toward | Biped: far tip lies toward |
| --- | --- | --- |
| Head | -Z (the snout points forward) | +Y (the head sits on top; its face looks toward -Z) |
| FrontLimb | -Y (down) | -Y (down) |
| Leg | -Y (down; the foot's sole is the lowest point) | -Y (down) |
| Tail | +Z (backward) | +Z (backward; it may droop toward -Y but must stay mainly along +Z) |

So the **ball end is on the opposite side**: Quad Head ball end on its +Z face; Biped Head on its -Y face; FrontLimb and Leg on their +Y face; Tail on its -Z face. The validator's `BALL_DIRECTION` table encodes exactly this.

## 4. Names

| Thing | Name |
| --- | --- |
| Root folder | `ReplicatedStorage.CreatureParts` |
| Species folder | `ReplicatedStorage.CreatureParts.<Species>`, where `<Species>` equals the key in `src/content/Species` (PascalCase, no spaces) |
| Species folder attribute | `BodyPlan` (string, `"Quad"` or `"Biped"`), equal to `SpeciesDef.bodyPlan` |
| Templates (exactly five, all `MeshPart`) | `Head`, `Torso`, `FrontLimb`, `Leg`, `Tail` |
| Torso sockets (`Attachment`) | `HeadSocket`, `FrontLimbSocketL`, `FrontLimbSocketR`, `LegSocketL`, `LegSocketR`, `TailSocket` |
| Plug on every other template (`Attachment`, exactly one) | `Plug` |
| Optional attachments (not yet used by code) | Torso: `GroundPoint`. Head: `EyeLine`, `MouthPoint`. Leg: `FootPoint` |
| Parts in a built creature | `Torso`, `Head`, `FrontLimbL`, `FrontLimbR`, `LegL`, `LegR`, `Tail` |
| Joints in a built creature | `Motor6D`s inside the Torso, named like the part they move, `Part0 = Torso` |

Nothing else may sit in a species folder (R02). Joint and part names are what animation targets, so they must not change.

The slot names in data (`Head`, `FrontLimbs`, `Legs`, `Tail`, `Torso`) differ from the template names (`FrontLimb`, `Leg`) on purpose: a slot is a gene, a template is one mesh.

## 5. Pivot and the ball-end rule

**Ball end.** Every non-torso template has one end that sits inside the torso. That end must be a smooth, closed, rounded cap that is close to a sphere. It does the hiding: wherever a limb rotates at the joint, the ball turns inside the torso, so there is no gap and no visible cut face. The rest of the part is free-form, but it must not be wider near the joint than the ball (a limb that flares out right behind the ball shows its shoulder through the torso at some angles).

**Torso is closed.** The torso is a watertight shape with no holes and no open cut faces. The sockets sit just inside its surface (section 6).

**Pivot.** A MeshPart's `CFrame` is the centre of its bounding box and cannot be moved by script; `PivotOffset` moves the pivot. So:

- Torso: `PivotOffset` is zero. The torso's pivot is the centre of its bounding box. (`Assembler.place` measures the leg sockets' height from this centre.)
- Every other template: `PivotOffset` = `CFrame.new(Plug.Position)`, so the pivot is the **centre of the ball end** (R08). The `Plug` attachment has the same position, no rotation, and a `Radius` attribute.

**How the joint uses it.** `Motor6D.C0 = torso socket CFrame`, `Motor6D.C1 = part Plug CFrame`. The ball centre lands on the socket, and because both attachments have no rotation, the part keeps its authored orientation. Animation rotates the joint about the ball centre.

**Plug position by rule (R10).** Let `d` be the ball-end direction from section 3 and `R` the plug radius. The plug sits on the part's centre line, `halfSizeAlongD - R` from the centre along `d` (so the ball touches the bounding-box face), and at `X = 0` (so the part is left-right symmetric).

## 6. Attachments

All attachment positions are in the owning part's local space, in studs, at scale 1. Every socket and plug carries a number attribute **`Radius`** (studs, greater than 0). `S` = the torso's `Size`, `R` = that attachment's own radius.

### 6.1 Torso sockets, Quad

| Attachment | Position rule | `Radius` attribute |
| --- | --- | --- |
| `HeadSocket` | X = 0. Z = `-(S.Z/2 - 0.4R)` (front end, pushed inward). Y at the height where the neck leaves, normally within the middle third of the torso | Head's plug radius (own species) |
| `FrontLimbSocketL` / `R` | X = `-(S.X/2 - 1.0R)` / `+(S.X/2 - 1.0R)`. Y = `-(S.Y/2 - 0.4R)` (underside). Z between `-0.25 S.Z` and `-0.32 S.Z` | Front limb plug radius; L and R equal |
| `LegSocketL` / `R` | Same as the front limb sockets, but Z between `+0.25 S.Z` and `+0.32 S.Z` | Leg plug radius; L and R equal |
| `TailSocket` | X = 0. Z = `+(S.Z/2 - 0.4R)` (rear end). Y at the height where the tail leaves | Tail plug radius |
| `GroundPoint` (optional) | X = 0, Z = 0, Y = bottom face of the torso. Not used by code yet | none |

Torso length (`torsoLength`) is `S.Z`.

### 6.2 Torso sockets, Biped

| Attachment | Position rule | `Radius` attribute |
| --- | --- | --- |
| `HeadSocket` | X = 0. Y = `+(S.Y/2 - 0.4R)` (top). Z near the front-to-back centre, within `+/-0.1 S.Z` | Head's plug radius |
| `FrontLimbSocketL` / `R` (arms) | X = `-(S.X/2 - 0.4R)` / `+(S.X/2 - 0.4R)`. Y between `+0.15 S.Y` and `+0.30 S.Y`. Z within `+/-0.1 S.Z` | Arm plug radius; L and R equal |
| `LegSocketL` / `R` | X = `-max(1.1R, 0.2 S.X)` / `+max(1.1R, 0.2 S.X)`. Y = `-(S.Y/2 - 0.4R)` (underside). Z within `+/-0.1 S.Z` | Leg plug radius; L and R equal |
| `TailSocket` | X = 0. Z = `+(S.Z/2 - 0.4R)` (back). Y between `-0.45 S.Y` and `-0.20 S.Y` (low) | Tail plug radius |

Torso length (`torsoLength`) is `S.Y` (the upright height).

### 6.3 Plugs and optional attachments on the other templates

| Template | `Plug` position | `Plug.Radius` | Optional |
| --- | --- | --- | --- |
| Head | On the centre line at the ball end (rule in section 5) | Radius of the neck ball | `EyeLine` (between the eyes, at the front), `MouthPoint` (in front of the mouth). For later move effects |
| FrontLimb, Leg | On the centre line at the top (the +Y end) | Radius of the shoulder or hip ball | Leg: `FootPoint` at the middle of the sole (the lowest point) |
| Tail | On the centre line at the -Z end | Radius of the tail-base ball | none |

### 6.4 The radius rule, and why

For each slot, **a species' torso socket radius equals its own part's plug radius** (R14). A species' own parts then fit at scale 1.0, and the numbers in `SpeciesDef.socketRadius[slot]` and `SpeciesDef.parts[slot].plugRadius` come out equal for a pure species. A mixed creature scales the donor part by `socketRadius(torso species) / plugRadius(donor species)` (section 9).

`Radius` is the radius of the sphere that matches the ball end's rounded cap (section 12 says how to measure it). It must satisfy:

- the plug radius is no more than 55% of the part's narrowest width at the ball end (the ball fits inside the part, R10);
- the socket radius is between 6% and 30% of `torsoLength` (R11).

## 7. Left and right

Roblox cannot mirror a mesh, so **one mesh serves both sides**. The Assembler clones `FrontLimb` twice (`FrontLimbL`, `FrontLimbR`) and `Leg` twice with identical orientation.

So each of Head, FrontLimb, Leg and Tail must be **mirror-symmetric about its own YZ plane** (left half equals right half), and the Torso too. Consequences:

- Limbs hang straight down. They may bend toward or away from the camera (Z) but must **not** angle outward or inward (X), because the right limb would then angle the wrong way.
- Feet, claws and horns are symmetric about the limb's centre line.
- Head and Tail plugs sit at X = 0, and so do the head and tail sockets (R10, R11).
- Left and right sockets are mirror images with equal radii (R06, R11).
- A generator will often make a left limb and a right limb that differ slightly. Keep the left one, delete the right, and check the kept one by eye for symmetry.

## 8. Triangle budgets

| Part | Target range | Hard limit (FAIL above) |
| --- | --- | --- |
| Torso | 600 to 900 | 1,125 |
| Head | 600 to 900 | 1,125 |
| FrontLimb | 200 to 350 | 437 |
| Leg | 200 to 350 | 437 |
| Tail | 200 to 350 | 437 |
| **Whole creature** (Head + Torso + 2 FrontLimb + 2 Leg + Tail) | up to 3,000 | 3,600 |

Above target but under the hard limit is a WARN. Below the target range is a WARN (it may look faceted). Giants may use twice these figures. Wings (later) 300 to 450.

Why: the world budget is 300,000 triangles on screen on the baseline phone, so 30 creatures at 3,000 is 90,000. Draw calls matter more than triangles, so keep one mesh per part and no extra pieces.

**How the count is taken.** The validator calls `AssetService:CreateEditableMeshAsync(part.MeshContent)` and `EditableMesh:GetFaces()` (to verify in Studio). It needs the Mesh and Image APIs enabled for the place and a mesh the place owner can load. If it cannot count, R15 prints WARN "NOT MEASURED". Then use the cap you gave the generator, or Studio's wireframe view, and write the number into the results table by hand.

## 9. Scale convention and fitting

Templates are stored **at the size they have on their own species**, in studs, at scale 1. Nothing is pre-scaled to a common size. Each species records its measurements (section 12).

When a donor part goes on a torso:

```
scale = clamp(socketRadius[slot] of the torso's species / plugRadius of the donor's part, SCALE_MIN, SCALE_MAX)
```

`SCALE_MIN = 0.6` and `SCALE_MAX = 1.6` in `AssemblyMath`. The scale is **uniform**: size and attachment offsets are multiplied by the same number (`Assembler.scalePart`), so the whole donor part grows or shrinks, including its length. The ball end then matches the torso's socket exactly, as long as the ratio is inside the clamp. Outside it the ball is clamped and will not match; the validator prints this as a `*` in the fit table.

Rules for the roster that follow:

- Within one body plan, for each slot, the largest radius divided by the smallest should be at most 2.0, so every pairing sits well inside 0.6 to 1.6.
- A donor limb that grows by 1.6 or shrinks to 0.6 changes the creature's height. Ride height uses the leg's `length` times its scale (`AssemblyMath.rideHeight`), so the feet still reach the ground, but a Quad whose front limbs end at a different height from its legs will tilt. Hence R13: a Quad's front limb length is 0.85 to 1.15 times its leg length. Mixed pairs can still differ; the art test shows how bad.
- The whole-creature `size` gene (0.9 to 1.1) is applied last with `Model:ScaleTo`.

Size ranges (R09, R13), at scale 1: every part dimension 0.3 to 12 studs; `torsoLength` 3 to 10 studs (about 6 for a mid-sized species); leg length 1.5 to 4.5 studs.

## 10. Texture and colour

Colour is applied at runtime (`MeshPart.Color`, `Material`), so templates carry **no baked colour**:

- `TextureID` is empty (R03). No `SurfaceAppearance`, `Decal` or `Texture` inside (R03). Generate with textures off where the tool allows; otherwise clear `TextureID` after generation.
- The mesh has no vertex colours. To verify in Studio: if a generated mesh still shows colour with `TextureID` cleared, the colour is in the vertices, and the part fails the "no baked colour" check by eye (checklist V4).
- `Material = SmoothPlastic` on every template. Gem tiers change `Material` at runtime later.
- `Color` is a neutral light grey, such as `Color3.fromRGB(220, 220, 220)`. The Assembler overwrites it.
- Detail is **shape, not paint**: eyes, nostrils, mouth line, claws and toes are shallow bumps or dents big enough to read from the baseline phone's camera distance. A flat-colour creature must still read as a creature with a face. The art test judges this (ART_TEST step 9).
- An optional later pattern layer (one 256 x 256 texture with a transparent base, so `Color` shows through) is not part of version 1. Do not add textures to templates yet.

## 11. Physics

On every template (R12):

| Property | Value |
| --- | --- |
| `Anchored` | `true` (templates only; the Assembler sets clones to `false`) |
| `CanCollide`, `CanTouch`, `CanQuery` | `false` |
| `Massless` | `true` |
| `CollisionFidelity` | `Box` |
| `CastShadow` | `false` on Leg, FrontLimb and Tail; anything on Head and Torso |
| `Material` | `SmoothPlastic` |
| `Name` | exactly the template name |
| Children | only `Attachment`s; **no scripts, sounds, decals, welds or constraints** (R03, R04) |

Hit detection and lasso targets use one invisible hitbox per creature, added by the Assembler later, not these parts.

## 12. Numbers to measure and copy into the species data file

`ValidateParts.luau` prints these, ready to paste. All are in studs at scale 1.

| `SpeciesDef` field | How it is measured |
| --- | --- |
| `bodyPlan` | The `BodyPlan` attribute on the species folder |
| `torsoLength` | Quad: `Torso.Size.Z`. Biped: `Torso.Size.Y` |
| `socketRadius.Head` | `Radius` attribute of `Torso.HeadSocket` |
| `socketRadius.FrontLimbs` | `Radius` of `Torso.FrontLimbSocketL` (R must be equal, R06) |
| `socketRadius.Legs` | `Radius` of `Torso.LegSocketL` |
| `socketRadius.Tail` | `Radius` of `Torso.TailSocket` |
| `socketRadius.Torso` | Always 0 |
| `parts.<slot>.plugRadius` | `Radius` of that template's `Plug`. `Torso` is 0 |
| `parts.<slot>.length` | Distance from the Plug centre to the far tip, along the ball-end axis: `Plug.Position:Dot(d) + halfSizeAlong(d)`. For a Leg this is plug to the sole, which `rideHeight` uses. For the Torso it is `torsoLength` |
| `weight` | **Not measured from the mesh.** The roster sets it (a heavy, bulky species has a high number), and the fit factor uses it. The validator prints the torso box volume only so you can check that heavier species look bulkier |
| `parts.<slot>.stats`, `moves` | From the roster, not the mesh |

How to measure a **plug radius** (the one number that cannot be read off the bounding box): start from `0.5 x` the part's narrowest width at the ball end, build the gauge (`SHOW_GAUGES = true` in the validator, or a translucent sphere of diameter `2R` at the Plug), and adjust `R` until the sphere's surface follows the mesh's rounded end cap. Round to 0.05. Socket radii then copy from each species' own plug radii (section 6.4).

## 13. Normalising a raw generated part to this spec

Do this per template, after generation, with `execute_luau` in Edit mode. Keep the script in the session scratchpad; if it works, propose adding it as `tools/studio/NormaliseParts.luau`.

1. Copy the MeshPart into `ReplicatedStorage.CreatureParts.<Species>` and rename it to the template name. For limbs, keep the left one (`FrontLimbL`, `LegL`) as `FrontLimb`, `Leg`; delete the right one after comparing sizes (they should match within 5%).
2. Check the part is in the torso's frame: facing and rest direction as section 3 (the generator's whole-creature output faces -Z, so parts split from it normally keep that frame). If the far tip points the wrong way, stop: regenerate.
3. Clear colour: `TextureID = ""`, remove any `SurfaceAppearance`, set `Material = SmoothPlastic`, `Color = (220, 220, 220)`.
4. Rescale **uniformly** (never one axis) to the target size: choose the species' `torsoLength` first (3 to 10, about 6), scale the torso to it, then scale every part by the same factor so proportions from the generator are kept. Setting `MeshPart.Size = Size * k` scales the mesh uniformly.
5. Create the `Plug` (limbs) by the rule in section 5: position on the centre line at `halfAlong - R` toward the ball end, X = 0, no rotation, `Radius` = the measured `R`. Set `PivotOffset = CFrame.new(Plug.Position)`.
6. Create the torso sockets by the rules in section 6.1 or 6.2 with `Radius` equal to the matching part's plug radius.
7. Set the physics properties of section 11 and `CastShadow`.
8. Set the `BodyPlan` attribute on the species folder.
9. Run the validator. Fix every FAIL. Look at the WARNs.

## 14. Checklist: a part (and its species) must pass this

Run `ValidateParts.luau` first; then look at the visual items yourself.

| # | Check | How |
| --- | --- | --- |
| R01 | `CreatureParts.<Species>` folder exists, has `BodyPlan` = Quad or Biped | Validator |
| R02 | Exactly Head, Torso, FrontLimb, Leg, Tail, all MeshParts, nothing else | Validator |
| R03 | MeshId set; TextureID empty; SmoothPlastic; only Attachments inside | Validator |
| R04 | No scripts anywhere | Validator |
| R05 | Torso has the six sockets; every other part has exactly one Plug; no unknown attachments | Validator |
| R06 | Every socket and plug has a numeric `Radius`; left and right radii equal | Validator |
| R07 | All attachments have zero rotation | Validator |
| R08 | Torso pivot at its centre; other pivots at the Plug | Validator |
| R09 | Dimensions 0.3 to 12; torsoLength 3 to 10 | Validator |
| R10 | Plug on the ball-end face, on the centre line and X = 0; ball fits inside the part | Validator |
| R11 | Sockets inside the torso box, mirrored, placed by plan; radius 6% to 30% of torsoLength | Validator |
| R12 | Physics flags of section 11 | Validator |
| R13 | Limb lengths in proportion (WARN) | Validator |
| R14 | Own parts fit own torso at scale 1, within 5% (WARN) | Validator |
| R15 | Triangles within budget (WARN or FAIL) | Validator, or by hand if NOT MEASURED |
| V1 | The ball end is closed and round; no open cut face or hole anywhere | Look at the gauge screenshot from three angles |
| V2 | The torso is closed and has no holes | Look |
| V3 | Mirror symmetry of each part and the torso | Look from the front |
| V4 | No baked colour: with TextureID cleared the part is one flat colour | Look; vertex colour counts as baked |
| V5 | The gauge sphere follows the ball end (radius is right) | Gauge screenshot |
| V6 | Face and details read from shape alone | Look at the head at phone distance |
| V7 | Style matches the other species (same chunkiness, same edge softness) | Contact sheet |
| V8 | No likeness to another game's creature | Ayrton's check; see `ART_TEST.md` step 2 |
| V9 | Asset ids, prompt and licence recorded in `docs/ASSETS.md` | Check the register |

A species is accepted when R01 to R12 and R14 have no FAIL or WARN, R13 and R15 have no FAIL, and V1 to V9 are all ticked.

## 15. Not confirmed; check in Studio

- Whether `generate_mesh` takes custom part names for segmentation, and what it returns (a model with named MeshParts?). The golf project only used `segmentation none`.
- Whether `AssetService:CreateEditableMeshAsync(part.MeshContent)` and `GetFaces()` work in an `execute_luau` Edit run, and the setting that allows it.
- Whether `screen_capture` can take a camera position and target, and whether it can write a file.
- Whether `Attachment.Position` stays correct when `PivotOffset` is set after the attachments exist (it should: attachments are relative to the part's `CFrame`, not its pivot).
- Whether differently coloured clones of one template batch into one draw call (research test 7).
- The generator's handling of "textures off".
