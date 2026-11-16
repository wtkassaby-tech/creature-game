# Art test procedure

Status: ready to run, 16 November 2026. Written for Ayrton and a Claude Code session driving Roblox Studio through the Studio MCP on his laptop.

**The question:** do AI-generated creature parts split cleanly, and do parts from two species fit together when mixed? Everything visual in the game waits on this answer (`MASTER_PLAN.md` risk 1).

**What gets built:** two four-legged species and one two-legged species, as parts to `PART_SPEC.md`; a validator run on each; all 32 mixes of the two four-legged species on a contact sheet; static animation poses on all of them; screenshots; a verdict.

**Total time:** about 3 to 4 hours if the first generation approach works; add 1 to 2 hours per fallback tried. Ayrton is needed for about 1 hour of that, in short bursts (marked **DECISION**). Claude does the rest.

## What the golf project already taught us (use it)

From `docs/art-test/GENERATED_ASSETS.md` and `docs/DECISIONS.md` in the golf game, 12 to 13 November 2026:

- `generate_mesh` is strong on chunky, rounded objects at 900 to 4,500 triangles and weak on long thin ones (a golf club failed twice). Tails and thin limbs are the riskiest parts here.
- About a quarter of jobs failed the first time ("Rate limit exceeded", "Unable to generate Model", "unable to trigger"). The same prompt worked on retry. Running **two jobs at a time** worked; more failed.
- Some prompts were rejected by moderation; rewording fixed it.
- Output size is unpredictable (a putter head came out 1.2 studs wide). Always measure and rescale in code.
- The generator ignores "flat" and bakes soft shading into the texture. Colours drift from the prompt. (We clear the texture here, so this matters less.)
- Whole creatures came out facing -Z natively. Sync generations return no model id; read mesh ids from the inserted model.
- One creature came out too close to a well-known design and was rejected. Every species needs a likeness check.
- No charge or quota prompt appeared for 13 mesh generations. **If a charge or quota prompt appears now, stop and tell Ayrton.**
- The Studio MCP cannot open a file, publish a place or save a place from Studio's menus; `save_place` exists. Verified tool names from the golf work: `list_roblox_studios`, `get_studio_state`, `generate_mesh`, `insert_asset`, `execute_luau` (Edit, Server, Client), `search_game_tree`, `inspect_instance`, `screen_capture`, `start_stop_play`, `get_console_output`, `save_place`.

Anything below marked **(to verify in Studio)** has not been confirmed.

## Step 1. Prepare (about 30 to 45 minutes; Ayrton and Claude)

1. **Ayrton:** open the latest Roblox Studio and sign in with the account that will own the game. Generated meshes become assets on that account.
2. **Ayrton:** in Studio, Assistant, then Manage MCP Servers, turn on "Enable Studio as MCP server", and use Quick connect for Claude Code. A green indicator means it is connected.
3. **Ayrton:** File, New, Baseplate. Save it as `CreatureArtTest.rbxl` somewhere outside the repo folder.
4. **Claude:** call `list_roblox_studios`, note the `studio_id` (every call needs it), then `get_studio_state`. Tell Ayrton which place you are touching.
5. **Claude:** in the repo, run `rokit install` and `lune run check`. It must pass before you start, so a failure later is not blamed on art. (This is the baseline: the local gate may show failures from files other agents are mid-way through; note them, do not fix them.)
6. **Claude:** get the game code into the test place, so the real Assembler and `AssemblyMath` can be used in step 7. Preferred: `rojo serve` in `creature-game/`, then Ayrton installs the plugin (`rojo plugin install`, then restart Studio) and clicks Connect. Fallback: the golf project's approach, a small loader script run through `execute_luau` that creates the scripts from the file tree (golf `docs/DECISIONS.md`, "Syncing the repo into an open Studio place"). After syncing, check with `search_game_tree` that these exist: `ReplicatedStorage.shared.AssemblyMath`, `ReplicatedStorage.shared.Types`, `ReplicatedStorage.content.Species`, `StarterPlayer.StarterPlayerScripts.client.Assembler.Assembler`.
7. **Claude:** create the part folders with `execute_luau` (Edit):

```lua
local RS = game:GetService("ReplicatedStorage")
local root = RS:FindFirstChild("CreatureParts") or Instance.new("Folder")
root.Name = "CreatureParts"
root.Parent = RS
for _, name in { "ExampleQuadA", "ExampleQuadB", "ExampleBiped" } do
	local f = root:FindFirstChild(name) or Instance.new("Folder")
	f.Name = name
	f.Parent = root
end
return "ok"
```

8. **Claude:** ask Ayrton to turn on the Mesh and Image APIs for this place (Game Settings, Security, "Enable Mesh / Image APIs", to verify the exact label). The validator needs them to count triangles. If it will not turn on, the validator prints "NOT MEASURED" and the count is taken by hand.
9. **Claude:** create `creature-game/docs/art-test/` for screenshots and, if absent, `creature-game/docs/ASSETS.md` (the assets register, same shape as the golf project's `GENERATED_ASSETS.md`: what, asset id, mesh id, prompt, triangle cap, verdict, licence note).
10. **DECISION (Ayrton, 5 minutes): the three creatures.** If `docs/content/GREENWOOD_ROSTER.md` exists, take two four-legged species with clearly different proportions (one stocky, one lean) and one two-legged species from it. If it does not, use the neutral examples below. Check the three concepts for **likeness**: none may resemble another game's creature. Write the pick in the results table.

Folder names: use the species names without spaces. The validator and contact sheet scripts use the placeholders `ExampleQuadA`, `ExampleQuadB`, `ExampleBiped`; replace them everywhere if you use real names.

## Step 2. Generate the parts (about 45 to 90 minutes)

### The style sentence (put it at the start of every prompt, never change it between species)

> Cute chunky low-poly toy creature, simple smooth rounded shapes, flat matte colour with no texture detail, thick short limbs, big simple eyes, clean silhouette, single creature, no text, no base.

### Example creatures (neutral stand-ins; the real roster is designed separately)

**Quad A, stocky ("ExampleQuadA"):**

> [style sentence] A stocky four-legged moss-green beast standing side-on with its head forward: a broad flat head with a blunt snout and two small round ears, a wide barrel body, four thick short legs with flat round feet, the front legs and back legs clearly apart from each other, a short stubby tail. The head, each leg and the tail end in a smooth rounded ball where they join the body, and the body is one closed smooth shape with no holes.

**Quad B, lean ("ExampleQuadB"), same plan, different proportions:**

> [style sentence] A lean long-legged four-legged runner standing side-on with its head forward: a small narrow head with a long snout and two tall pointed ears, a slim body, four long slender legs with small round feet, the front legs and back legs clearly apart, a long thin tail with a fluffy tip. The head, each leg and the tail end in a smooth rounded ball where they join the body, and the body is one closed smooth shape with no holes.

**Biped ("ExampleBiped"):**

> [style sentence] An upright two-legged round-bellied walker standing facing forward: a large rounded head with a short snout, a plump upright body, two short arms hanging straight down at its sides and clear of the body, two sturdy legs apart with broad flat feet, a thick tapering tail trailing behind close to the ground. The head, each arm, each leg and the tail end in a smooth rounded ball where they join the body, and the body is one closed smooth shape with no holes.

Triangle cap for the first try: **3,000** for each creature (the whole creature budget). If the tool reports a cap range, lower is fine; the golf results were good between 900 and 4,500.

### Approach 1 (try first): one whole creature, split into named parts by the generator

Use `generate_mesh` with segmentation on and these seven part names: `Head, Torso, FrontLimbL, FrontLimbR, LegL, LegR, Tail` (the tool allows up to eight parts; the golf project only used `segmentation none`, so the parameter names and values are **to verify in Studio**: read the tool's own description first). Ask for a **textured-off** result if the tool offers it.

1. Generate Quad A and the Biped, two jobs at a time (they are the hardest to get right). Each job takes about 1 to 3 minutes. Retry a failed job once with the same prompt before changing it.
2. Make up to **3 attempts per species**. Keep every attempt; note its asset id in `ASSETS.md` even if rejected.
3. For each attempt check, with `inspect_instance` and a `screen_capture`: seven separate MeshParts came back with sensible names; each part's far tip points the right way (spec section 3); limbs are separate pieces and not fused to the body; the head and tail are separate; ball ends look rounded; the torso looks closed.
4. When Quad A has an accepted attempt, generate Quad B the same way.
5. **DECISION (Ayrton, 10 minutes):** look at the screenshots of the candidates and pick one per species, or ask for more attempts. Pick on shape and silhouette, not colour.

Pass for this step: 3 of 3 species have a candidate whose seven parts separate cleanly. Record how many attempts each took.

### Approach 2 (fallback 1): generate the whole creature unsplit, then split it

Generate each species with `segmentation none` (proven in the golf project, 1,500 to 4,500 triangles). Then split it with Studio's `/segment_mesh` command: it works on one selected MeshPart, takes up to **five** part names per run, and is an "early preview" whose results depend on the mesh's topology. So run it twice per creature, for example first `Head, Tail, FrontLimbL, FrontLimbR, LegL`, then on the remainder `LegR, Torso`. `/segment_mesh` is an Assistant chat command, not a known MCP tool, so **Ayrton types it in the Assistant panel** while Claude watches the result with `search_game_tree` (to verify in Studio whether `GenerationService:SegmentMeshAsync` can be called from `execute_luau` instead).

Time: about 20 minutes per species.

### Approach 3 (fallback 2): generate each part on its own

Five generations per species (Head, Torso, FrontLimb, Leg, Tail), each with the style sentence plus a part prompt that insists on the ball end. Generation is by `generate_mesh` with `segmentation none`. Example part prompts for Quad A:

- Torso: "[style sentence] Only the body of a stocky four-legged beast, no head, no legs, no tail: a wide smooth closed barrel shape, moss green."
- Head: "[style sentence] Only the head of a stocky beast, no body: a broad flat head with a blunt snout and two small round ears, ending at the back in a smooth round ball shape where the neck would join."
- Leg: "[style sentence] Only one thick short leg of a stocky beast, standing straight down: a smooth round ball at the top, a thick tube, a flat round foot at the bottom."
- FrontLimb: same as Leg, with the words "front leg".
- Tail: "[style sentence] Only a short stubby tail, pointing straight back: a smooth round ball at the base, tapering to a rounded tip."

Parts from separate generations will not share a scale. The fix is in step 3 (uniform rescale against the torso, spec section 13). Selecting a plain Part of the target size before generating makes the tool fit the mesh to its bounding box (from the Studio MCP docs; to verify in Studio). Time: about 45 to 60 minutes per species, because there are five jobs and the style drifts between them.

### If all three approaches fail for a part type

Do not keep generating. Stop and record it (step 12). The next options are in the failure table: code-built parts, hand-fixed parts, or fewer slots. Paid tools (Meshy, Tripo) need Ayrton's explicit yes before anything is bought or an account is made.

## Step 3. Normalise each part to the spec (about 20 to 30 minutes per species)

Follow `PART_SPEC.md` section 13 exactly, using `execute_luau` in Edit mode. Claude writes a throwaway script for it, keeps it in the scratchpad, and shows Ayrton the result by screenshot. In short, per species: copy the parts in and rename them to the five template names (keep the left limb, delete the right); clear colour and texture; scale uniformly so the torso is about 6 studs long; create `Plug` attachments and set pivots; create the six torso sockets; set the physics flags; set `BodyPlan`.

The plug radius is the one judgement call. Build gauges (step 4 builds them with `SHOW_GAUGES = true`), take a screenshot, and adjust the radius until the gauge sphere follows the rounded end of the part. Torso socket radii copy the species' own plug radii.

Heavy lifting here is geometry arithmetic and looking at pictures; Ayrton's only job is to say "yes, the ball ends match" or "no" on the gauge screenshots.

## Step 4. Run the validator (about 10 to 20 minutes, repeating until clean)

1. Claude reads `creature-game/tools/studio/ValidateParts.luau`, edits the line `local SPECIES_NAMES` to the three species folder names, and runs the whole text with `execute_luau` (Edit). It prints one PASS, WARN or FAIL line per rule per species, then a block of measured numbers, then a fit table for every same-plan pair.
2. Fix every FAIL, then every WARN that is not a deliberate choice, and re-run. The validator never changes parts; the fixes are Claude's edits.
3. Set `SHOW_GAUGES = true`, run once, and take screenshots of the gauge layout (front, side, and from above). It builds `Workspace.PartGauges`: every template with translucent spheres at its attachments (red at plugs, blue at sockets). Look for checklist items V1, V2, V3, V5 (PART_SPEC section 14). Delete the folder afterwards.
4. Copy each species' measured block into its notes (the real species data file comes with the roster). The fit table is the first sign of trouble: any cell marked `*` is clamped and will not fit exactly.

Pass for this step: no FAIL in any species, and the checklist's visual items V1 to V5 ticked. If the validator itself misbehaves (a Roblox API call fails), treat it as a bug in the script: note the error line, fix the script, and say so in the report; the rest of the procedure does not depend on it.

## Step 5. Save and register (about 10 minutes)

1. `save_place`.
2. Write every generated asset id, mesh id, prompt and verdict into `docs/ASSETS.md` (hard rule: nothing enters the game without its record).
3. Export the three species folders for later use: right-click each folder in Studio, Save to File, to `creature-game/assets/parts/<Species>.rbxm` (Ayrton does this; the MCP cannot). Whether those files are committed or the place is the source of truth is decided at Gate A, not now.

## Step 6. Assemble the 32 mixes (about 15 minutes)

Two same-plan species A and B give 32 creatures: a torso from A or B (2), times each of Head, FrontLimbs, Legs and Tail from A or B (16). The script below builds all 32 with the real Assembler, lays them out 8 by 4, labels each (`T` torso, `H` head, `F` front limbs, `L` legs, `Tl` tail, with the letter of the donor species), and by default colours each part by its donor (A green, B orange) so you can see at a glance which part came from where.

Run it with `execute_luau` (Edit). It injects minimal species data built from the templates themselves, so it needs no roster yet.

```lua
--!nocheck
-- Contact sheet: builds all 32 mixes of two same-plan species in Workspace.ContactSheet.
-- Run with execute_luau, datamodel_type = Edit. Needs the project synced (Rojo) so Assembler and AssemblyMath exist.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local SPECIES_A = "ExampleQuadA"
local SPECIES_B = "ExampleQuadB"
local DONOR_COLOURS = true -- true: each part is coloured by the species it came from (A green, B orange)
local SPACING = 18

local TEMPLATE_OF: { [string]: string } =
	{ Head = "Head", FrontLimbs = "FrontLimb", Legs = "Leg", Tail = "Tail" }
local SOCKET_OF: { [string]: string } = {
	Head = "HeadSocket",
	FrontLimbs = "FrontLimbSocketL",
	Legs = "LegSocketL",
	Tail = "TailSocket",
}
local PLAN = ReplicatedStorage.CreatureParts[SPECIES_A]:GetAttribute("BodyPlan")
local BALL_DIRECTION: { [string]: Vector3 } = {
	Head = if PLAN == "Biped" then Vector3.new(0, -1, 0) else Vector3.new(0, 0, 1),
	FrontLimb = Vector3.new(0, 1, 0),
	Leg = Vector3.new(0, 1, 0),
	Tail = Vector3.new(0, 0, -1),
}

local Species = require(ReplicatedStorage.content.Species) :: any
local Assembler = require(StarterPlayer.StarterPlayerScripts.client.Assembler.Assembler) :: any

-- Builds the minimal SpeciesDef the assembler needs, straight from the templates' attributes and sizes.
local function defFromFolder(name: string): any
	local folder = ReplicatedStorage.CreatureParts[name]
	local torso = folder.Torso :: MeshPart
	local def: any = {
		name = name,
		bodyPlan = folder:GetAttribute("BodyPlan"),
		weight = 1,
		torsoLength = if folder:GetAttribute("BodyPlan") == "Quad"
			then torso.Size.Z
			else torso.Size.Y,
		socketRadius = { Torso = 0 },
		parts = { Torso = { stats = {}, moves = {}, plugRadius = 0, length = torso.Size.Z } },
	}
	for slot, template in TEMPLATE_OF do
		local part = folder[template] :: MeshPart
		local plug = part.Plug :: Attachment
		local dir = BALL_DIRECTION[template]
		local half = Vector3.new(math.abs(dir.X), math.abs(dir.Y), math.abs(dir.Z)):Dot(part.Size)
			/ 2
		def.socketRadius[slot] = (torso:FindFirstChild(SOCKET_OF[slot]) :: Attachment):GetAttribute(
			"Radius"
		)
		def.parts[slot] = {
			stats = {},
			moves = {},
			plugRadius = plug:GetAttribute("Radius"),
			length = plug.Position:Dot(dir) + half,
		}
	end
	return def
end
Species[SPECIES_A] = defFromFolder(SPECIES_A)
Species[SPECIES_B] = defFromFolder(SPECIES_B)

local old = workspace:FindFirstChild("ContactSheet")
if old then
	old:Destroy()
end
local sheet = Instance.new("Folder")
sheet.Name = "ContactSheet"
sheet.Parent = workspace

local COLOUR_OF: { [string]: Color3 } =
	{ [SPECIES_A] = Color3.fromRGB(96, 170, 72), [SPECIES_B] = Color3.fromRGB(235, 140, 50) }
local PART_SLOT: { [string]: string } = {
	Head = "Head",
	FrontLimbL = "FrontLimbs",
	FrontLimbR = "FrontLimbs",
	LegL = "Legs",
	LegR = "Legs",
	Tail = "Tail",
}

local index = 0
for _, torsoSpecies in { SPECIES_A, SPECIES_B } do
	for mask = 0, 15 do
		local function pick(bit: number): string
			return if bit32.band(bit32.rshift(mask, bit), 1) == 1 then SPECIES_B else SPECIES_A
		end
		local chosen: { [string]: string } = {
			Torso = torsoSpecies,
			Head = pick(0),
			FrontLimbs = pick(1),
			Legs = pick(2),
			Tail = pick(3),
		}
		local label = string.format(
			"%02d  T=%s H=%s F=%s L=%s Tl=%s",
			index + 1,
			if torsoSpecies == SPECIES_A then "A" else "B",
			if chosen.Head == SPECIES_A then "A" else "B",
			if chosen.FrontLimbs == SPECIES_A then "A" else "B",
			if chosen.Legs == SPECIES_A then "A" else "B",
			if chosen.Tail == SPECIES_A then "A" else "B"
		)
		local creature: any = {
			id = string.format("mix%02d", index + 1),
			bodyPlan = PLAN,
			parts = {},
			size = 1,
			colour = { shown = "Moss", carried = "Moss" },
		}
		for slot, speciesName in chosen do
			creature.parts[slot] = { species = speciesName, quality = 5 }
		end
		local model = Assembler.build(creature) :: Model
		local column, row = index % 8, math.floor(index / 8)
		Assembler.place(model, Vector3.new(column * SPACING, 0, row * SPACING * 1.3))
		for _, child in model:GetChildren() do
			if child:IsA("MeshPart") then
				child.Anchored = true
				if DONOR_COLOURS then
					local speciesName = if child.Name == "Torso"
						then torsoSpecies
						else chosen[PART_SLOT[child.Name]]
					child.Color = COLOUR_OF[speciesName]
				end
			end
		end
		local gui = Instance.new("BillboardGui")
		gui.Size = UDim2.fromOffset(200, 24)
		gui.StudsOffset = Vector3.new(0, 7, 0)
		gui.AlwaysOnTop = true
		local text = Instance.new("TextLabel")
		text.Size = UDim2.fromScale(1, 1)
		text.BackgroundTransparency = 1
		text.TextColor3 = Color3.new(1, 1, 1)
		text.TextStrokeTransparency = 0
		text.Text = label
		text.Parent = gui
		gui.Adornee = model.PrimaryPart
		gui.Parent = model.PrimaryPart
		model.Name = label
		model.Parent = sheet
		index += 1
	end
end
return string.format("built %d creatures in Workspace.ContactSheet", index)
```

If it errors on a path, the code was not synced as expected (step 1, item 6); fix that, not the script. If `Assembler.build` errors, read the message: it is usually a missing attachment, which the validator should have caught.

Then take the pictures (step 8). Also run it once with `DONOR_COLOURS = false` for the "real" look.

## Step 7. Biped assembly and stress test (about 15 minutes)

There is only one Biped, so there is nothing to mix it with. Two checks instead:

1. Build the Biped from its own parts: run the sheet script with `SPECIES_A` and `SPECIES_B` both set to `"ExampleBiped"` (all 32 results are the same creature; look at one). Take front and side screenshots at rest.
2. Stress the fit by imitating a mix with a very differently sized species. In Studio duplicate the `ExampleBiped` folder twice, as `ExampleBipedWide` and `ExampleBipedSlim`. In **Wide**, raise every `Plug` `Radius` attribute by 40% (the donor's ball is now bigger than the torso's socket, so its parts scale down to about 0.71). In **Slim**, lower every `Plug` `Radius` by 40% (the parts scale up to the 1.6 clamp). Leave the torso socket radii alone. Run the sheet script with `SPECIES_A = "ExampleBiped"` and `SPECIES_B = "ExampleBipedWide"`, then again with `"ExampleBipedSlim"`. The validator will WARN on R14 for these two duplicates; that is expected. Take screenshots of both sheets.

Pass: the Biped looks right at rest, and both stress builds show no gaps at the joints and no part floating or sinking (the stress builds may look odd in proportion; that is expected).

## Step 8. Check animation-readiness (about 20 minutes)

Animation here is code-driven rotation of the six joints (`Motor6D.Transform`), so what matters is that **limbs rotate about the ball without a gap, nothing detaches, and feet stay near the ground**. A static pose test shows all of that.

Run the pose script with `execute_luau` (Edit) once per pose: `walkA`, `walkB`, `lunge`, `flinch`, plus `rest`. It rotates each joint (limbs ±25° for the walk, 55° forward for the lunge, head and tail swings) and prints the lowest point of every creature. Take a screenshot of the whole sheet after each pose, and close-ups of at least four mixes (the ones that looked worst at rest) in `walkA` and `lunge`.

```lua
--!nocheck
-- Applies a named pose to every model in Workspace.ContactSheet and reports the lowest point of each model.
-- Change POSE and run again, with a screen_capture after each run. Run with execute_luau, datamodel_type = Edit.
local POSE = "walkA" -- rest | walkA | walkB | lunge | flinch

local function rot(x: number, y: number, z: number): CFrame
	return CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
end

-- Rotations only, in degrees, about each joint's ball centre. Limbs use pitch (x); head and tail may also yaw (y).
local POSES: { [string]: { [string]: CFrame } } = {
	rest = {},
	walkA = {
		LegL = rot(25, 0, 0),
		LegR = rot(-25, 0, 0),
		FrontLimbL = rot(-25, 0, 0),
		FrontLimbR = rot(25, 0, 0),
		Head = rot(-5, 0, 0),
		Tail = rot(0, 15, 0),
	},
	walkB = {
		LegL = rot(-25, 0, 0),
		LegR = rot(25, 0, 0),
		FrontLimbL = rot(25, 0, 0),
		FrontLimbR = rot(-25, 0, 0),
		Head = rot(5, 0, 0),
		Tail = rot(0, -15, 0),
	},
	lunge = {
		Head = rot(-25, 0, 0),
		FrontLimbL = rot(-55, 0, 0),
		FrontLimbR = rot(-55, 0, 0),
		LegL = rot(20, 0, 0),
		LegR = rot(20, 0, 0),
		Tail = rot(20, 0, 0),
	},
	flinch = {
		Head = rot(30, 0, 15),
		FrontLimbL = rot(20, 0, 0),
		FrontLimbR = rot(20, 0, 0),
		Tail = rot(0, 35, 0),
	},
}

local pose = POSES[POSE]
local sheet = workspace:FindFirstChild("ContactSheet")
if not sheet then
	return "no Workspace.ContactSheet; run the contact sheet script first"
end
local lines: { string } = {}
local worst = math.huge
for _, model in sheet:GetChildren() do
	if model:IsA("Model") then
		local torso = model.PrimaryPart :: BasePart
		for _, joint in torso:GetChildren() do
			if joint:IsA("Motor6D") then
				joint.Transform = pose[joint.Name] or CFrame.identity
			end
		end
		-- Lowest point of any part's oriented box corners, relative to the ground (Y = 0).
		local lowest = math.huge
		for _, part in model:GetChildren() do
			if part:IsA("BasePart") then
				local half = part.Size / 2
				for _, sx in { -1, 1 } do
					for _, sy in { -1, 1 } do
						for _, sz in { -1, 1 } do
							local corner = part.CFrame:PointToWorldSpace(
								Vector3.new(half.X * sx, half.Y * sy, half.Z * sz)
							)
							lowest = math.min(lowest, corner.Y)
						end
					end
				end
			end
		end
		worst = math.min(worst, lowest)
		table.insert(lines, string.format("%s  lowest point %.2f", model.Name, lowest))
	end
end
table.insert(
	lines,
	string.format(
		"POSE %s: lowest point over all mixes %.2f studs (below -0.3 means feet sink into the ground)",
		POSE,
		worst
	)
)
return table.concat(lines, "\n")
```

Pass marks for this step:

- no visible gap between a limb and the torso in any pose, on at least 90% of the mixes (a gap means the ball is too small for its socket, or the limb is wider than the ball just beyond it);
- the lowest point over all mixes in the walk poses is above -0.3 studs (feet do not sink into the ground), and in `rest` between -0.15 and +0.15 on the mixes whose front and hind limbs match in length (a Quad whose front limb is longer or shorter than its leg will tilt; note how many);
- the head, tail and limbs never poke through the torso's far side or through each other on a walk pose.

Foot sliding cannot be judged from still poses. It is judged at Gate A, when the walk cycle runs with the ground speed. For the art test only the optional live check in step 10 applies.

## Step 9. Screenshots (about 15 minutes)

Use `screen_capture`. Whether it accepts a camera position and target, and whether it can save to disk, are **to verify in Studio**; if it cannot save, Ayrton uses the operating system's screenshot tool and saves into `creature-game/docs/art-test/`. Set the camera yourself first with `execute_luau`: `workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable`, then set its `CFrame`.

Name them as listed. Capture them at phone aspect (Studio device emulator, or a window about 400 x 800 pixels) for the close-ups, at 16:9 for the sheets.

| File | What |
| --- | --- |
| `01_gen_<species>_attempt<n>.png` | Each generation attempt, all seven parts in the generated layout |
| `02_parts_<species>.png` | The five templates side by side, front and side |
| `03_gauges_<species>.png` | Gauge spheres on each template |
| `04_validator_<species>.txt` | The validator output text (copy it from the result) |
| `05_sheet_donors.png` | All 32 mixes, donor colours, three-quarter view from above |
| `05_sheet_rows_1.png` to `_4.png` | Each row of 8, closer |
| `06_sheet_plain.png` | All 32 mixes in one colour |
| `07_worst_<mixlabel>.png` | The four worst mixes close up, front and side |
| `08_pose_<pose>.png` | The sheet in each pose |
| `09_biped_rest.png`, `09_biped_stress.png` | Step 7 |
| `10_phone_<mixlabel>.png` | Two or three mixes at phone distance with a plain ground, to judge whether faces read |

## Step 10 (optional, 15 minutes). Live check in a playtest

Only if everything above passes and time allows. `start_stop_play`, then with `execute_luau` on the **Client** datamodel set a `RunService.PreSimulation` loop that writes the walk poses over a two-second sine for one mix, and take two or three captures. Always `start_stop_play` again to stop. Changes made during play are discarded when play stops.

## Step 11. Ayrton scores the 32 mixes (about 20 minutes; DECISION)

Ayrton looks at `05_sheet_*` and `06_sheet_plain` and scores each mix **Yes** (accept without hand fixes), **Fix** (would accept after a small fix; say which: bigger ball end, different proportions, and so on), or **No**. Use this grid (row 1: torso A; row 2: torso B; column = which of Head, FrontLimbs, Legs, Tail come from B, written as the letters of the label):

| Mix (label) | Score | Note |
| --- | --- | --- |
| 01 to 16 (torso A) | | |
| 17 to 32 (torso B) | | |

A mix is **accepted** if: no visible gaps or cut faces at any of the six joints; no part floating or sinking more than about 0.2 studs; all four feet near the ground (a leg that stops short or digs in is a No); proportions look like a toy creature you would collect, not a mistake; the face reads. Count the Yes scores. "Fix" does not count as accepted at Gate A ("without hand fixes") but is useful information.

## Step 12. Pass marks, results and what a failure means

### Pass marks (from `MASTER_PLAN.md` section 5.3)

| # | Mark | Source |
| --- | --- | --- |
| P1 | Two four-legged species and one two-legged species exist as parts that separate cleanly and have no FAIL from the validator | Art test gate |
| P2 | At least 26 of the 32 four-legged mixes accepted (80%) without hand fixes | Gate A (read early) |
| P3 | The two-legged species assembles at rest and under the step 7 stress test | Gate A |
| P4 | The animation pose checks (step 8) pass | Gate A (assembles and animates) |
| P5 | The thin parts (tails, limbs) came out usable in at least 3 of every 5 attempts across the generations | Research prototype test 8 |
| P6 | Each species needed no more than 3 attempts (Approach 1), or a fallback worked | Time, not a gate |

P2 to P4 are Gate A marks; reading them now lets us change course before the trip. P1 is the art test itself.

### Results table (fill it in)

| Item | Result | Evidence |
| --- | --- | --- |
| Date, Studio version, who drove | | |
| Quad A species, Quad B species, Biped species | | `ASSETS.md` |
| Approach that worked: 1, 2 or 3 (per species) | | |
| Attempts used per species | | `01_gen_*` |
| Parts usable first time (of 21 expected) | | |
| Thin parts usable: tails, limbs (of attempts) | | |
| Validator: FAILs at first run, FAILs at the end, WARNs left | | `04_validator_*` |
| Triangles: Quad A, Quad B, Biped (whole creature) | | |
| Fit table: cells clamped, of total | | `04_validator_*` |
| Mixes accepted: Yes / Fix / No (of 32) | | `05_*` |
| Worst mix and why | | `07_*` |
| Biped at rest and under stress | | `09_*` |
| Pose checks: gaps, lowest point, tilt | | `08_*` |
| Face reads from shape alone (Ayrton) | | `10_*` |
| Style matches between species (Ayrton) | | |
| Likeness check (Ayrton) | | |
| Time taken, total and per step | | |
| Verdict: PASS, PASS WITH FALLBACK, or FAIL | | |

### What each failure means for the plan

| What failed | Meaning | Next move (in order) |
| --- | --- | --- |
| Approach 1 gives merged or missing parts, or the wrong number of parts | The generator's segmentation is not reliable | Approach 2, then Approach 3. Record the failure mode (merged limbs, head fused to torso, tail dropped) so a better prompt can be written. P1 still passes if a fallback works, but the time per species goes up: re-plan the roster art budget (about 24 species) |
| Approach 3 also fails for one part type (usually tail or limbs) | The generator cannot make thin parts | `MASTER_PLAN.md` 5.3: code-built or hand-fixed parts for the thin pieces (a simple capsule or cone tail built as a mesh from code, or a hand-made mesh), keeping generated heads and torsos. Ayrton decides; any paid tool needs his yes |
| All approaches fail for most parts | Generated parts cannot be used | Fewer slots per creature (for example, one "Limbs" slot instead of FrontLimbs and Legs) or a hand-made part set. This changes the brief and breeding; stop and ask Ayrton before anything else |
| Parts split but ball ends are open or flat | The cut faces show at some angles | Enlarge the ball end by hand, or prompt "ball joint end" per part (Approach 3), or accept bigger overlap by raising socket radii. If the cut is visible from outside the torso it is a FAIL |
| Validator FAILs persist on pivots, plugs or sockets | Normalisation is wrong, not the art | Fix the normaliser; the spec is the reference. If the same rule fails for every species, the rule may be wrong: raise it with Ayrton rather than loosening it quietly |
| Triangles over budget | Parts too heavy for 30 creatures on a phone | Lower the generator's cap; decimate by hand; or raise the budget if the phone test later allows (Gate A) |
| Fewer than 26 of 32 accepted (P2) | Mixing looks wrong too often | Read the Fix and No notes. Common causes: radius spread between species too wide (tighten the roster to the 2.0 ratio of PART_SPEC section 9); ball ends too small (enlarge, since overlap hides seams); front limbs and legs of different lengths on a Quad (make a species' front limbs 0.85 to 1.15 times its legs); mixed styles. If it still fails: "less extreme size differences between species", then "fewer slots" (`MASTER_PLAN.md` Gate A). Do not build roster art on a failing system |
| Biped fails but Quad passes | The two-legged plan is harder (balance, arms, upright pose) | Launch with Quad only and move Biped to the first later update. Ayrton decides; `DECISIONS.md` marks two plans as "Ayrton to confirm" |
| Gaps appear only in animation poses | Ball radius too small for the joint's range | Raise plug and socket radii by 10 to 20%, or limit joint ranges in the animation data (for example 25 degrees for walk, 45 for attacks) |
| Feet sink or float on mixes | Ride height uses leg length only | Constrain the front limb length (R13); consider ride height from the lower of front and hind feet (a change to `AssemblyMath`, with a test) |
| Faces do not read with flat colour | Detail must come from shape only | Make eyes and mouths deeper geometry; or decide to add a pattern or face texture layer (research test 3: a texture with a transparent base so `Color` still shows through). Ayrton decides |
| Species A and B look like they came from different games | Style drift | Use the shared style sentence unchanged; generate from a reference image of the first approved species (the tool takes a prompt or an image, not both); re-roll the outlier |
| A species resembles another game's creature | Likeness | Reject and regenerate. Never use it, even for the test sheet that others will see |
| Mesh or API calls are throttled or charged | Quota | Stop and tell Ayrton; do not buy anything |

When finished: update `docs/PROGRESS.md` with the verdict and what Ayrton should look at, fill in the results table, commit the screenshots and `ASSETS.md`, and list any change the spec needs (anything you loosened or tightened, with the evidence).

## Where a human decision is needed

| Step | Decision | Who | Time |
| --- | --- | --- | --- |
| 1 | Studio sign-in, MCP on, Mesh APIs on, Rojo plugin installed | Ayrton | 15 min |
| 1.10 | Pick the three creatures, check likeness | Ayrton | 5 min |
| 2 | Pick the best candidate per species | Ayrton | 10 min |
| 2 | Run `/segment_mesh` in the Assistant panel (Approach 2 only) | Ayrton | 10 to 20 min |
| 3 | Confirm gauge spheres match the ball ends | Ayrton | 5 min |
| 5 | Save parts to files | Ayrton | 5 min |
| 11 | Score the 32 mixes | Ayrton | 20 min |
| 12 | Choose the next move after a failure; any spending | Ayrton | as needed |
