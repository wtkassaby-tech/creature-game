# Creature tech: building part-based creatures in Roblox

Date: 16 November 2026

Status: research, nothing decided

## Summary

- **Rigid MeshParts on Motor6D joints, not skinned meshes.** A mesh's `MeshId` cannot be changed by scripts, AI generators do not output skinned parts, and Roblox still calls Motor6D "appropriate for non-avatar mechanical rigs". Chunky low-poly parts with ball-shaped joint ends hide the seams.
- **One animation set per body plan is feasible** because Roblox matches animation channels to joints by part name. Keep every creature on a plan to the same part names and joint tree, and keep limb animation rotation-only so limb length does not matter.
- **Drive animation from code (`Motor6D.Transform`), not uploaded animation assets.** It needs no asset ownership, Claude Code can write and unit-test it, and it adapts to mixed proportions. Roblox's own performance guide recommends `Transform` for procedural animation.
- **Colour at runtime is easy; texture maps are not.** `MeshPart.Color`, `Material`, `TextureID`, `SurfaceAppearance.Color` and the emissive strength and tint are script-writable. SurfaceAppearance maps are plugin-only. Design parts as flat-colour meshes, with an optional pattern texture.
- **ViewportFrame icons work but must be rationed.** No shadows or post-processing, Neon and Glass at lowest quality, and DevForum reports lag from as few as 10 to 20 live viewports. Render static, show only visible cells, and animate only the selected creature.
- **Studio can now generate a model already split into named parts** (up to eight, `GenerateModelAsync` with a custom schema, early preview since about June 2026). This is the most promising route to 24 species with matching style and scale, and it is unproven for our use.
- **EditableMesh and EditableImage are not needed for launch.** Limits are 20,000 triangles and 1024 x 1024 pixels, client memory budgets are strict, they do not replicate, and there is no way to render a viewport into an image.
- **What could not be checked:** `create.roblox.com`, `devforum.roblox.com`, `en.help.roblox.com`, `docs.meshy.ai` and `chrishecker.com` are blocked in this session, and the web search budget ran out before the searches on Dragon Adventures, Axie, Meshy and many-NPC benchmarks. Roblox docs were read from Roblox's own public GitHub copy instead; DevForum claims are search snippets only.

## How to read the sources

Confidence labels: **sourced** (page opened), **snippet** (search result text only), **inference** (my reasoning).

Docs were opened from Roblox's official docs repository. `GH:` below stands for `https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/`. The same pages live at `https://create.roblox.com/docs/...` (append `.md`), which should be re-read once that host is allowed.

## 1. Assembling a modular creature

| Finding | Source | Confidence |
| --- | --- | --- |
| `MeshPart.MeshId` and `MeshContent` cannot be written by scripts, because collision geometry "cannot be recomputed in real time". A part is made by cloning a prepared MeshPart, or with `AssetService:CreateMeshPartAsync` (yields), or by `ApplyMesh` from another MeshPart | `GH:reference/engine/classes/MeshPart.yaml`, `GH:reference/engine/classes/AssetService.yaml` | sourced |
| `Motor6D` is not deprecated. Player R15 avatars now spawn with `AnimationConstraint` instead (Avatar Joint Upgrade, on by default in new experiences), but "Motor6D remains appropriate for non-avatar mechanical rigs" | `GH:reference/engine/classes/Motor6D.yaml`, `GH:reference/engine/classes/AnimationConstraint.yaml` | sourced |
| Animations bind by name: `Motor6D.ChildName` and `ParentName` mirror the names of `Part1` and `Part0`, and "a rig's part names must line up with the names authored in its animations" | `GH:reference/engine/classes/Motor6D.yaml` | sourced |
| `RigidConstraint` fixes two Attachments or Bones together and is the accessory-style join. It is not animated | `GH:reference/engine/classes/RigidConstraint.yaml` | sourced |
| A Bone is an Attachment subclass that drives skinned vertices; `Bone.Transform` can be set by script like `Motor6D.Transform`. The page does not say whether separate MeshParts can share one skeleton | `GH:reference/engine/classes/Bone.yaml` | sourced |
| Skinned MeshParts in a Model with no Humanoid are grouped into spatial FastClusters; moving them forces rebuilds, and "size and scale changes rebuild FastClusters" | `GH:performance-optimization/improve.md` | sourced |
| Mixing skinned and jointed parts has caused errors for developers (several Motor6Ds from several meshes onto one mesh; welded parts not following a skinned mesh) | https://devforum.roblox.com/t/skinned-meshparts-are-live/831011 | snippet |
| Mesh import limits: 20,000 triangles per mesh, 4 bone influences per vertex | `GH:art/modeling/specifications.md` | sourced |

**Reading of this (inference).** Skinned meshes would give smooth joints, but each part would have to be rigged and weighted by hand in Blender, AI tools do not produce them, and joining skeletons across separately made parts is not documented. Rigid parts on Motor6D joints are cheaper to make, can be generated, and suit the chunky look the brief already asks for. Use `Motor6D` for joints that move and nothing else: a creature needs no `RigidConstraint` or weld if every part is jointed to the torso.

**Scaling**

| Finding | Source | Confidence |
| --- | --- | --- |
| `Model:ScaleTo(n)` scales around the model pivot, scales "all geometric properties of descendant Instances" (sizes, joint lengths, particle sizes, sound distances), and is absolute, so repeated calls do not drift | `GH:reference/engine/classes/Model.yaml` | sourced |
| "The scale factor of a model will be applied to joint offsets" of animations played on an AnimationController in that model, so a scaled creature's animation offsets scale with it | same | sourced |
| The page does not list Attachments, Motor6D or Bones by name among scaled properties | same | sourced (gap) |
| Setting `MeshPart.Size` directly rescales one part but does not move its Attachments | Roblox behaviour as I know it; not re-read this session | inference |

Use both: the assembler sets each part's `Size` and multiplies its attachment offsets itself (per-part scale), then calls `ScaleTo` once on the finished model for whole-creature size. Do all scaling at build time, never during play.

## 2. Animation

| Finding | Source | Confidence |
| --- | --- | --- |
| `AnimationController` plus a child `Animator` animates a model without a Humanoid. A Humanoid "comes with a significant computation cost" and static NPCs do not need one | `GH:reference/engine/classes/AnimationController.yaml`, `GH:performance-optimization/improve.md` | sourced |
| `Motor6D.Transform` is the recommended property for custom animation, set in `RunService.PreSimulation`. With an Animator present it is overwritten each frame, so procedural offsets must be applied after the Animator, in `PreSimulation` | `GH:reference/engine/classes/Motor6D.yaml` | sourced |
| "For procedural animation, update `Motor6D.Transform` rather than `C0` and `C1`" | `GH:performance-optimization/improve.md` | sourced |
| Animators outside a player character replicate only if created and played on the server; "NPC animations that run on the server need to be simulated on the server", so run NPC animation on the client where possible | `GH:reference/engine/classes/Animator.yaml`, `GH:performance-optimization/improve.md` | sourced |
| `Animator.PreferLodEnabled` (default true) lets the engine lower animation rate with distance; `EvaluationThrottled` reports when a pose was reused | `GH:reference/engine/classes/Animator.yaml` | sourced |
| `Animator:LoadAnimation` needs the Animator in the Workspace and creates a new track each call | same | sourced |
| `IKControl` needs a Humanoid or AnimationController with an Animator; the chain can be Motor6D parts or Bones; types are Transform, Position, Rotation, LookAt; `SmoothTime` defaults to 0.05 | `GH:reference/engine/classes/IKControl.yaml`, `GH:animation/inverse-kinematics.md` | sourced |
| Animation assets must be owned by the experience owner, and group-owned animations often fail with "sanitized ID" errors | https://devforum.roblox.com/t/failed-to-load-animation-with-sanitized-id-when-loading-group-owned-animations/3550557 | snippet |
| `AssetService:CreateAssetAsync` uploads Model, Plugin, Mesh, Image and Audio from plugins. Animation is not in the list, so Claude Code cannot publish animation assets through it | `GH:reference/engine/classes/AssetService.yaml` | sourced |

**Can one animation set drive every creature? (inference)** Yes, per body plan, under three rules. First, every creature on the plan has the same part names and the same joint tree, which is what Roblox matches on. Second, limbs, head and tail are animated by rotation only; a rotation looks right on a short leg and a long leg, while a position offset would not. Third, the torso's bob height is multiplied by the creature's leg length, which only code-driven animation can do.

**Uploaded animations against code-driven animation**

| | Uploaded animation assets | Code-driven (`Motor6D.Transform`) |
| --- | --- | --- |
| Who makes them | A person in the Animation Editor, per body plan | Claude Code, as Luau data in `src/shared/` |
| Fits mixed proportions | Rotation keys yes, position keys no | Yes; clips can read leg length and tail length |
| Ownership and loading risk | Must be owned by the experience owner | None |
| Testable under Lune | No | Yes (pure functions of time) |
| Engine distance throttling | Yes (`PreferLodEnabled`) | We must write our own |
| Cost | Engine-side, cheap | About 6 to 10 property writes per creature per frame in Luau |

Recommendation: code-driven clips for launch (idle, walk, attack lunge, hit flinch, faint, celebrate, plus slither and flap), with `IKControl` held back as a later polish item for feet on slopes. Sub-task counts are small: a battle shows 2 to 6 creatures. The world may show 20 to 30, which needs the throttle described in section 9.

**Prior art.** Spore's system stores animation in a body-independent form and applies it through an IK solver at runtime; the authors note that learning which motions generalise "takes weeks" (Hecker and others, SIGGRAPH 2008, https://doi.org/10.1145/1360612.1360626, snippet). That is the high-cost end. Our fixed body plans avoid nearly all of it.

## 3. Colour, materials and effects at runtime

| Property | Script-writable at runtime? | Source | Confidence |
| --- | --- | --- | --- |
| `MeshPart.Color`, `Material`, `Transparency`, `Reflectance` | Yes | Standard BasePart properties; not re-read this session | inference |
| `MeshPart.TextureID` / `TextureContent` | Yes ("the texture can" be changed at runtime though the mesh cannot) | `GH:reference/engine/classes/MeshPart.yaml` | sourced |
| `MeshPart.MeshId` / `MeshContent` | No | same | sourced |
| `MeshPart.DoubleSided`, `RenderFidelity` | Yes | same | sourced |
| `SurfaceAppearance.Color` (tints the colour map) | Yes | `GH:reference/engine/classes/SurfaceAppearance.yaml` | sourced |
| `SurfaceAppearance.EmissiveStrength`, `EmissiveTint` | Yes | same | sourced |
| `SurfaceAppearance` colour, normal, metalness, roughness and emissive-mask maps | No (plugin security). "Most SurfaceAppearance properties cannot be modified by scripts" | same | sourced |
| New SurfaceAppearance built at runtime | Yes, `AssetService:CreateSurfaceAppearanceAsync`; maps cannot be swapped after creation | `GH:reference/engine/classes/AssetService.yaml` | sourced |
| `MaterialVariant` maps | No (plugin security); `EmissiveStrength`, `EmissiveTint`, `StudsPerTile` yes | `GH:reference/engine/classes/MaterialVariant.yaml` | sourced |
| `Highlight` | Yes, but only 255 show at once, disabled ones still count, extras are "silently ignored" | `GH:reference/engine/classes/Highlight.yaml` | sourced |

- Roblox's performance guide recommends exactly our plan: "a single tintable texture with `SurfaceAppearance.Color` instead of separate textures per color" (`GH:performance-optimization/improve.md`, sourced).
- Tinting multiplies, so it only works on light or greyscale textures. A mesh generated with a baked full-colour texture cannot be cleanly recoloured (inference).
- A MeshPart texture with transparent areas lets the part's `Color` show through, which gives "runtime base colour plus fixed markings" from one texture. I believe this is standard behaviour but could not re-check it; it is prototype item 3 (inference).
- Whether `SurfaceAppearance.AlphaMode` has a tint-mask mode could not be confirmed; the docs page read did not mention one (sourced gap).
- Whether parts with different `Color` still share a draw call is not stated. The guide says identical meshes batch when texture or material match (sourced); colour is unverified.
- Gem tiers (inference): untextured or tintable parts switch `Material` (for example Glass, Ice, Foil, Neon), raise `Reflectance`, and add emissive tint, a ParticleEmitter and at most one Highlight on the active battler. Keep Highlights for the one or two creatures in focus, never the whole crowd.
- ParticleEmitter changes "can have a large performance impact" and particles "don't batch well" (`GH:performance-optimization/improve.md`, sourced). One emitter per rare creature, not one per part.

## 4. EditableMesh and EditableImage (late 2026)

| Finding | Source | Confidence |
| --- | --- | --- |
| Off by default in published games; turn on "Enable Mesh / Image APIs" in the Creator Dashboard or Studio security settings | `GH:reference/engine/classes/EditableMesh.yaml`, `EditableImage.yaml` | sourced |
| Only assets owned by or shared with the experience owner (or the player, client side) can be loaded | same | sourced |
| EditableMesh limits: 60,000 vertices, 20,000 triangles. EditableImage limit: 1024 x 1024 | same | sourced |
| "Strict client-side memory budgets"; creation returns nil when the budget is spent. Server, Studio and plugins have no set limit | same, and `GH:reference/engine/classes/AssetService.yaml` | sourced |
| Developers report hitting the client budget after about 8 editable meshes | https://devforum.roblox.com/t/how-much-editablemesh-you-can-create/3982856 | snippet |
| A finished mesh can be frozen with `CreateDataModelContentAsync` and the editable destroyed, which frees budget | `GH:reference/engine/classes/EditableMesh.yaml` | sourced |
| EditableMesh has bone and skin-weight methods (`AddBone`, `SetVertexBones`, `SetVertexBoneWeights`) but no method to combine two meshes; `MergeVertices` works inside one mesh | same | sourced |
| EditableImages "don't currently replicate from server to client"; only one EditableImage updates per display frame | `GH:reference/engine/classes/AssetService.yaml`, `EditableImage.yaml` | sourced |
| No documented way to render a 3D model or ViewportFrame into an EditableImage. `CaptureService` takes whole-screen screenshots for sharing, not icons | `GH:reference/engine/classes/EditableImage.yaml`, `CaptureService.yaml` | sourced |

Verdict (inference): they do not help with icons, and merging parts into one skinned mesh on each client would cost memory budget per creature and a lot of code. Skip both for launch. One later use is worth noting: generating pattern textures (spots, stripes) on the client from a seed.

## 5. ViewportFrame icons

| Finding | Source | Confidence |
| --- | --- | --- |
| "No shadows or post-processing effects are rendered." Neon and Glass render at the lowest quality. Environment lighting is off by default, so metalness maps "may look different" | `GH:reference/engine/classes/ViewportFrame.yaml` | sourced |
| Lighting is set per frame with `Ambient`, `LightColor`, `LightDirection` | same | sourced |
| A `WorldModel` inside a viewport allows animation and raycasts but no physics. "Only create WorldModels when you want to show them" and delete unused ones | `GH:reference/engine/classes/WorldModel.yaml` | sourced |
| A viewport redraws only when its children, camera or own properties change | https://devforum.roblox.com/t/how-to-render-viewports/1844422 | snippet |
| Idle WorldModels cost physics step time even off-screen; a 300-item inventory "pays for all 300" | https://devforum.roblox.com/t/emptyidle-worldmodels-unconditionally-consume-physics-step-time-causing-significant-fps-drops-at-scale/4818531 | snippet |
| Lag reported with as few as 10 viewports; advice of "not more than 20"; low-end phones can crash from memory | https://devforum.roblox.com/t/performance-issues-with-lots-of-viewportframes-mostly-occurring-on-low-end-devices/958962 and https://devforum.roblox.com/t/make-it-possible-for-developers-to-snapshot-viewportframes/2663038 | snippet |
| There is no API to snapshot a viewport to an image (open feature request) | same | snippet |
| Highlights, particles, beams and trails do not render inside a ViewportFrame | My knowledge of the engine; the docs pages read do not say | inference, unverified |

Icon approach that follows (inference):

- Static by default: build the icon model once, set the camera once, never touch it again. No WorldModel, no animation.
- Virtual scrolling: a pool of about 24 to 30 viewport cells, reused as the list scrolls. Empty the cells when the menu closes.
- One animated preview: only the selected creature gets a WorldModel and the idle clip.
- Rarity in icons is shown with 2D UI (frame colour, gradient, sparkle image), because 3D effects will not show.
- A cheaper icon model: the same meshes, no hitbox, no effects.
- Camera fit: compute the model's bounding box and back the camera off by a fixed formula so every body plan fills the frame equally.

This keeps the [Locked] "icons are automatic" decision. It only limits how many are live at once.

## 6. AI asset generation

| Finding | Source | Confidence |
| --- | --- | --- |
| Studio Assistant `/generate_mesh` makes a textured mesh from a text prompt or a reference image (not both). Max triangles is optional, default 10,000; lower gives "more faceted and low-poly generations" | `GH:assistant/guide.md` | sourced |
| Segmented generation: Assistant proposes a parts plan, you can edit the part names, and "each generated model can have up to eight parts". `/segment_mesh` splits an existing MeshPart, up to five part names per run; "early preview, and results depend on the topology of the input mesh" | same | sourced |
| API: `GenerationService:GenerateModelAsync` takes `TextPrompt` and/or `Image`, `Size` (approximate), `MaxTriangles`, `GenerateTextures` (default true), and a schema: `PredefinedSchema` (`Car5`, `Body1`) or `SchemaDefinition` with a `Groups` list of part names. Returns a Model matching the schema | `GH:reference/engine/classes/GenerationService.yaml` | sourced |
| `SegmentMeshAsync` is Studio-only and needs edit permission on the mesh. `GenerateMeshAsync` is being retired | same | sourced |
| The segmented-parts preview was announced on the DevForum; custom part names date from about 11 June 2026; users asked for more segments and raised triangle-count concerns | https://devforum.roblox.com/t/early-preview-generate-3d-models-segmented-into-multiple-parts/4678458 | snippet |
| Cube "4D" generation (schemas for multi-part working objects) entered open beta on 4 February 2026 | https://techcrunch.com/2026/02/04/robloxs-4d-creation-feature-is-now-available-in-open-beta/ | snippet |
| Rate limits: 5 mesh generations per minute per experience in the 2025 beta; 50 procedural models per rolling 24 hours. No current number for `GenerateModelAsync` | `docs/research/ART_PIPELINE.md` (earlier research); `GH:assistant/guide.md` | sourced (older) / sourced |
| Roblox's Terms treat AI outputs as the user's content, Roblox claims no ownership of new IP in them, and "Outputs may not be unique" | https://en.help.roblox.com/hc/en-us/articles/115004647846-Roblox-Terms-of-Use | snippet (host blocked) |
| Meshy: free plan is CC BY 4.0 (attribution), paid plans give private commercial use; text-to-3D costs about 20 to 30 credits per mesh; does not target Roblox triangle budgets by default | `docs/research/ART_PIPELINE.md` (earlier research, from docs.meshy.ai) | sourced earlier, not re-checked |
| Tripo has a `face_limit` setting; Hunyuan3D's minimum face count (40,000) is far above our budget | `docs/research/ART_TOOLS_2.md` (earlier research) | sourced earlier |

**What the owner's golf art test already showed** (`docs/art-test/GENERATED_ASSETS.md`, sourced, 12 November 2026): Studio's generator is good at chunky rounded objects at 900 to 2,000 triangles (tree, critter, chest), fails on long thin shapes (a golf club came out as a lollipop), returns unpredictable sizes (a putter head came out 1.2 studs wide), and once produced a creature too close to a well-known design, which was rejected. Each of these matters here: wings, tails and serpent bodies are long and thin; sizes must be normalised in code; every species needs a likeness check.

**Keeping separately made parts consistent (inference)**

1. Generate each species as one whole creature with a parts schema (Head, Torso, FrontLimbL, FrontLimbR, LegL, LegR, Tail), so one generation fixes style and scale for all its parts.
2. Use one fixed style sentence in every prompt and a reference image of the first approved species.
3. Normalise in code afterwards: measure each part's bounding box, set pivots and attachments by rule, and store the measurements, so no part depends on the generator's sizing.
4. Prefer `GenerateTextures = false` or a light, low-contrast texture, so colour comes from the game, which also hides style drift between species.
5. A person approves every species on a contact sheet before it enters the game.

## 7. How other games do it

| Game | What is known | Confidence |
| --- | --- | --- |
| Spore | Body-independent animation data, specialised at runtime through IK (SIGGRAPH 2008 paper) | snippet |
| No Man's Sky | A small set of skeleton "blueprints" based on Earth animals; parts and proportions vary per blueprint; Grant Duncan noted how few skeleton types nature uses (GDC 2015, "How I Learned to Love Procedural Art", https://gdcvault.com/play/1021935/Do-Artists-Dream-of-Electric) | snippet |
| Creatures of Sonaria | Players "pick, paint, and maybe mutate"; mutations are cosmetic overlays; "material palettes" exist. No technical write-up found | snippet; pipeline unknown |
| Dragon Adventures, Axie-style part swapping | Not researched: the search budget ran out. From memory, Axie uses six swappable parts on one fixed 2D skeleton per body, which is the same idea as our body plans | unverified |

The shared lesson (inference): every shipped system limits itself to a few fixed skeletons and varies parts and proportions on top. The brief's four body plans are the right shape. No source found describes a Roblox game that breeds 3D parts across species, so we should expect to solve this ourselves.

## 8. Replication, data and performance

| Finding | Source | Confidence |
| --- | --- | --- |
| "Creating and destroying large instance hierarchies ... at runtime can be very network intensive"; let clients create visuals locally | `GH:performance-optimization/improve.md` | sourced |
| Instances created by client scripts are exempt from streaming out, so the client must remove them itself | `GH:workspace/streaming/index.md` | sourced |
| Streaming defaults: min radius 64, target radius 1024; `Opportunistic` stream-out is recommended to avoid out-of-memory crashes | same | sourced |
| Draw calls matter more than triangles. Meshes with the same mesh content and matching texture or material share a draw call | `GH:performance-optimization/improve.md` | sourced |
| Anchor what does not need physics; set `CanCollide`, `CanTouch`, `CanQuery` false where unused; Box collision fidelity uses least memory | same | sourced |
| `RenderFidelity` Automatic drops detail at 250 and 500 studs | `GH:reference/engine/classes/MeshPart.yaml` | sourced |
| Pooling NPC models helps when they respawn often | `GH:performance-optimization/improve.md` | sourced |
| No official triangle or creature-count target for mobile was found, and no benchmark of many Motor6D creatures | search | not verified |

Design that follows (inference): the server never builds creature models. It sends a compact record through Blink (species index per slot, colour and pattern indexes, size, rarity, level: roughly 20 to 30 bytes) and the client assembles, pools and culls. Wild creatures in the world are server data plus a position; the client shows only those near the player.

## 9. Recommended technical approach

### Rig per body plan

Root part is always `Torso`. All joints are `Motor6D` with `Part0 = Torso` (serpent excepted). One `AnimationController` is not needed if animation is code-driven.

| Plan | Parts (exact names) | Joints | Notes |
| --- | --- | --- | --- |
| Quad | Torso, Head, FrontLimbL, FrontLimbR, LegL, LegR, Tail | 6 | Limbs are single pieces, no knees |
| Biped | Torso, Head, FrontLimbL, FrontLimbR, LegL, LegR, Tail | 6 | Same names as quad; torso is upright, sockets differ |
| Winged | Torso, Head, WingL, WingR, LegL, LegR, Tail (optional) | 5 or 6 | Wings fill the front-limb sockets. Needs a decision: the brief lists "tail or wings" as one slot |
| Serpent | Head, Torso (3 to 5 copies of one segment mesh, chained), Tail, optional fin pair | 5 to 8 | Segments reuse one mesh, so they batch; slither is a sine wave down the chain |

### Part specification

| Item | Rule |
| --- | --- |
| Axes | Creature faces -Z (Roblox forward), up is +Y |
| Pivot | At the part's joint centre (the centre of its ball end), not the mesh centre. Torso pivot at its centre |
| Joint ends | Every limb, head, tail and wing ends in a rounded ball that sits inside the torso; the torso is closed (no holes). Overlap hides seams at any angle |
| Torso attachments | `HeadSocket`, `FrontLimbSocketL`, `FrontLimbSocketR`, `LegSocketL`, `LegSocketR`, `TailSocket`, `GroundPoint`, each with a `Radius` attribute |
| Other parts | One `Plug` attachment at the pivot with a `Radius` attribute; legs also carry `FootPoint`; heads carry `EyeLine`, `MouthPoint` (for move effects) |
| Left and right | Limbs are modelled symmetric so one mesh serves both sides (Roblox cannot mirror a mesh). 5 meshes per species instead of 7 |
| Scale convention | Parts are stored at the size they have on their own species. Each species records `TorsoLength`. Part scale on a child = (child torso socket radius / part plug radius), which equals the brief's ratio formula when species are well proportioned, clamped to a range (start at 0.6 to 1.6) |
| Triangle budget | Torso 600 to 900, Head 600 to 900, each limb 200 to 350, Tail 200 to 350, Wing 300 to 450. Whole creature under about 3,000. Giants may use 2x |
| Texture | None, or one 256 x 256 pattern texture with transparent base. No SurfaceAppearance on common creatures |
| Physics | `CanCollide`, `CanTouch`, `CanQuery` false; Box collision; `Massless`; `CastShadow` off on limbs. One invisible hitbox part per creature |
| Metadata | Stored in `src/shared/Species/`: mesh id, measured size, plug radius, hip height, weight, stats, moves |

The budgets are my inference from the golf art test (good results at 900 to 2,000 triangles) and Roblox's "draw calls matter more than triangles"; there is no official mobile figure.

### Assembler algorithm (client, `src/client/Assembler/`)

1. Read the creature record; look up each slot's part definition.
2. Clone the part templates from `ReplicatedStorage.CreatureParts` (prepared MeshParts with attachments baked in). Cloning avoids the yield of `CreateMeshPartAsync` and the "MeshId cannot be set" rule.
3. Scale each non-torso part: factor = torso socket radius / part plug radius, clamped; set `Size` and multiply its attachment offsets by the same factor.
4. Create one Motor6D per part: `C0` = the torso socket's CFrame, `C1` = the part's plug CFrame. Name parts exactly as the plan's table.
5. Set ride height: torso `GroundPoint` to floor distance = scaled leg `FootPoint` length (longest leg wins).
6. Apply colour, material and pattern per part; add rarity effects.
7. Add the hitbox, set `PrimaryPart`, then `ScaleTo` for overall size.
8. Return the model with a handle (joint list, leg length, cleanup). Models go back to a pool keyed by the creature's part list.

The pure maths (scale factors, clamps, ride height, weight) lives in `src/shared/` and is unit-tested; the same module serves the breeding formula in brief section 7.

### Animation

- Clips are Luau tables or functions in `src/shared/`: for each joint name, a rotation as a function of time (sines and short keyframe lists), plus a torso offset scaled by leg length.
- One client loop on `PreSimulation` writes `Motor6D.Transform` for every visible creature.
- Throttle: full rate within about 60 studs, half rate to 150, frozen in idle pose beyond; cap animated creatures at a set number on low-end devices.
- Battle moves reuse a small set of clips (lunge, cast, flinch, faint) plus effects at `MouthPoint`.

### Icons

As listed in section 5: static viewport per visible cell, pooled, virtual scrolling, one animated preview, 2D rarity frames.

### Art pipeline for about 24 species (about 120 part meshes)

1. Write the part spec above into the repo and a Studio validation script (checks names, attachments, triangle count, pivot, size range).
2. For each species, write one prompt from a shared style sentence plus the species idea; generate the whole creature with a parts schema through the Studio MCP `generate_mesh` tool (or `GenerateModelAsync` from a plugin script), triangle cap about 3,000, textures off or light.
3. Fallback if segmentation is poor: generate each part alone with a "ball joint end" prompt, or generate whole and run `/segment_mesh`; last resort is Blender clean-up, or Meshy or Tripo on a paid plan (needs Ayrton's yes to spend).
4. A normalising script sets pivots, adds attachments by rule (for example the plug is the bounding-box face nearest the torso), measures radii and writes the species data file.
5. Render a contact sheet: every species alone, plus a grid of random two-species mixes. Ayrton approves or rejects each.
6. Record every asset id in an assets register, as the golf project does, and run the likeness check on each species.

Rough effort (inference): at three to five generations per accepted species, 24 species is about 100 generations, which fits inside a few sessions if the rate limit is still near 5 per minute.

## 10. Riskiest unknowns to prototype first (milestone 2)

| # | Unknown | Test | Pass mark |
| --- | --- | --- | --- |
| 1 | Does segmented generation give usable, closed parts with sensible splits? | Generate 2 quad species with the 7-name schema | Parts separate cleanly; cut faces are closed or hidden by overlap |
| 2 | Do mixed parts look right with socket-radius scaling? | Assemble all 32 mixes of 2 species; contact sheet | Ayrton accepts at least 80% without hand fixes |
| 3 | Runtime colour: does part `Color` show through a transparent pattern texture, and how do tints look? | One part, three approaches side by side | One approach gives clean recolours and markings |
| 4 | Code-driven animation quality on mixed proportions | Idle, walk and lunge on the 32 mixes | No foot sliding or parts detaching worse than a toy look allows |
| 5 | Mobile frame rate with 30 creatures in view | Device test on a low-end phone, with and without the throttle | 30 fps or better |
| 6 | Viewport icon cost | Team screen with 30 static icons and one animated | No visible hitch opening the screen on a low-end phone |
| 7 | Do differently coloured copies of a mesh still batch? | MicroProfiler draw-call count, 30 same-species creatures in 30 colours | Known either way; sets the crowd limit |
| 8 | Thin parts (wings, tails, serpent segments) from the generator | Generate 5 of each | At least 3 of 5 usable, else plan hand-made or coded parts |
| 9 | Gem-tier materials inside viewports | Glass, Neon and Foil parts in an icon | Tiers still readable, else rely on 2D frames |

## Recommendations for this game

1. **Section 12, 4: build creatures from rigid MeshParts on Motor6D joints, cloned from prepared templates.** Keep. It is the only route compatible with "MeshId cannot be set", AI-made parts and runtime mixing.
2. **Section 12: adopt the part specification in section 9 before any art is made**, especially ball-shaped joint ends, pivot at the joint, named sockets with a radius, and symmetric limbs. The brief already asks for a spec; this fills it in.
3. **Section 7: scale donor parts by socket radius, clamped, and keep the brief's weight formula for stats.** This refines the [Default] ratio formula so seams always fit. It does not change the [Locked] rule that proportions are scaled to look right.
4. **Section 12: animate from code with `Motor6D.Transform`, one clip set per body plan, rotation-only on limbs.** New [Default]. Avoids animation asset ownership problems and lets Claude Code build and test all of it.
5. **Section 4 (icons, [Locked]): keep live ViewportFrame icons, with limits:** static rendering, pooled visible cells only, one animated preview, rarity shown by 2D frames. No change to the locked decision.
6. **Section 12: colour by `MeshPart.Color` and `Material` on untextured or pattern-textured parts; gem tiers as material, emissive and one particle emitter.** Keep, and note that baked AI textures fight this, so generate with textures off or light.
7. **Section 12 ([Open] "must every asset be AI-generated"): answer "AI-first, not AI-only".** Try Studio's segmented generation first; allow coded or hand-fixed parts for wings, tails and serpent segments if test 8 fails. Any paid tool needs Ayrton's approval.
8. **Section 12: the server sends creature records, the client assembles, pools and culls.** Keep. Add a Blink struct for the compact record and a client-side cap on animated creatures.
9. **Section 4: settle the winged plan's slots.** The brief's "tail or wings" slot leaves the front-limb slot unclear on winged creatures. Suggested: wings take the front-limb sockets, tail optional. Needs Ayrton's decision; it changes a [Default] only.
10. **Section 13 (milestone 2): run the nine prototype tests in section 10 on two quad species before making any more art**, matching the brief's "build two species on one body plan first".
11. **Do not use EditableMesh or EditableImage at launch.** Revisit for seeded pattern textures after launch.
12. **Before relying on this file, re-read the blocked pages** (the DevForum segmentation thread, the Terms of Use AI clause, Meshy's licence) once those hosts are allowed.

None of these recommendations changes a [Locked] item or a line in `DECISIONS.md`.
