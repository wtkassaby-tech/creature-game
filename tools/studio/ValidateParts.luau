--!strict
-- ValidateParts: checks one or more creature part folders against docs/PART_SPEC.md.
--
-- NOT part of the game. It is never synced by Rojo. Run it inside Roblox Studio, either:
--   * from the Studio MCP: read this file, change SPECIES_NAMES below, and pass the whole text to
--     `execute_luau` with datamodel_type = Edit; or
--   * from the command bar in Studio: paste the whole file after changing SPECIES_NAMES.
-- It reads ReplicatedStorage.CreatureParts.<Species> and prints (and returns) one PASS, WARN or FAIL line
-- per rule, then the measured numbers ready to paste into the species data file.
-- The only change it makes is the optional gauge folder in Workspace (SHOW_GAUGES), which it deletes first.
--
-- Rule numbers (R01 and so on) match the checklist in docs/PART_SPEC.md section 14.
-- The numbers below are copied from the spec; if the spec changes, change them here too.

local SPECIES_NAMES: { string } = { "ExampleQuadA", "ExampleQuadB", "ExampleBiped" } -- edit this line
local SHOW_GAUGES = false -- true: lay out copies in Workspace with translucent radius spheres, for a screenshot

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetService = game:GetService("AssetService")

-- Spec numbers ---------------------------------------------------------------------------------------

local TEMPLATES: { string } = { "Head", "Torso", "FrontLimb", "Leg", "Tail" }
local LIMB_TEMPLATES: { string } = { "Head", "FrontLimb", "Leg", "Tail" }

-- Which torso socket(s) each template plugs into, and the SpeciesDef slot it belongs to.
local SOCKETS: { { template: string, slot: string, sockets: { string } } } = {
	{ template = "Head", slot = "Head", sockets = { "HeadSocket" } },
	{
		template = "FrontLimb",
		slot = "FrontLimbs",
		sockets = { "FrontLimbSocketL", "FrontLimbSocketR" },
	},
	{ template = "Leg", slot = "Legs", sockets = { "LegSocketL", "LegSocketR" } },
	{ template = "Tail", slot = "Tail", sockets = { "TailSocket" } },
}

-- Direction, in the part's own axes, from the part's centre towards its ball end.
local BALL_DIRECTION: { [string]: { [string]: Vector3 } } = {
	Quad = {
		Head = Vector3.new(0, 0, 1),
		FrontLimb = Vector3.new(0, 1, 0),
		Leg = Vector3.new(0, 1, 0),
		Tail = Vector3.new(0, 0, -1),
	},
	Biped = {
		Head = Vector3.new(0, -1, 0),
		FrontLimb = Vector3.new(0, 1, 0),
		Leg = Vector3.new(0, 1, 0),
		Tail = Vector3.new(0, 0, -1),
	},
}

local OPTIONAL_ATTACHMENTS: { [string]: { string } } = {
	Torso = { "GroundPoint" },
	Head = { "EyeLine", "MouthPoint" },
	Leg = { "FootPoint" },
}

local TRIANGLES: { [string]: { min: number, max: number } } = {
	Torso = { min = 600, max = 900 },
	Head = { min = 600, max = 900 },
	FrontLimb = { min = 200, max = 350 },
	Leg = { min = 200, max = 350 },
	Tail = { min = 200, max = 350 },
}
local TRIANGLE_HARD_FACTOR = 1.25 -- above max x this is a FAIL; between max and this is a WARN
local CREATURE_TRIANGLES_MAX = 3000
local CREATURE_TRIANGLES_HARD = 3600

local TORSO_LENGTH_RANGE = { min = 3, max = 10 } -- studs
local LEG_LENGTH_RANGE = { min = 1.5, max = 4.5 }
local DIMENSION_RANGE = { min = 0.3, max = 12 } -- every part dimension, studs
local SOCKET_RADIUS_FRACTION = { min = 0.06, max = 0.30 } -- of torsoLength
local FRONT_LIMB_TO_LEG_QUAD = { min = 0.85, max = 1.15 }

local TOLERANCE_POSITION = 0.02 -- studs, for pivots and mirrored sockets
local TOLERANCE_ANGLE = 0.5 -- degrees, for attachment orientation
local RADIUS_MIRROR_TOLERANCE = 0.01 -- fraction

-- Assembler scale clamp. Read from shared/AssemblyMath when the project is synced into the place.
local SCALE_MIN = 0.6
local SCALE_MAX = 1.6

-- Reporting -------------------------------------------------------------------------------------------

type Report = { lines: { string }, passes: number, warns: number, fails: number }

local function newReport(): Report
	return { lines = {}, passes = 0, warns = 0, fails = 0 }
end

local function record(report: Report, status: string, id: string, text: string)
	table.insert(report.lines, string.format("%-4s %-4s %s", status, id, text))
	if status == "FAIL" then
		report.fails += 1
	elseif status == "WARN" then
		report.warns += 1
	else
		report.passes += 1
	end
end

-- One line per rule: PASS when there are no problems, otherwise `severity` ("FAIL" or "WARN") with the problems listed.
local function finish(
	report: Report,
	id: string,
	severity: string,
	description: string,
	problems: { string }
)
	if #problems == 0 then
		record(report, "PASS", id, description)
	else
		record(report, severity, id, description .. " -> " .. table.concat(problems, "; "))
	end
end

local function fmt(n: number): string
	return string.format("%.3f", n)
end

-- Helpers -----------------------------------------------------------------------------------------------

local function getAttachment(parent: Instance, name: string): Attachment?
	local child = parent:FindFirstChild(name)
	if child and child:IsA("Attachment") then
		return child
	end
	return nil
end

local function getRadius(attachment: Attachment): number?
	local value = attachment:GetAttribute("Radius")
	if type(value) == "number" and value > 0 and value == value then
		return value
	end
	return nil
end

local function absVector(v: Vector3): Vector3
	return Vector3.new(math.abs(v.X), math.abs(v.Y), math.abs(v.Z))
end

local function isFinite(v: Vector3): boolean
	return v.X == v.X and v.Y == v.Y and v.Z == v.Z and v.Magnitude < math.huge
end

-- Triangle count. Returns nil when it cannot be measured here.
-- TO VERIFY IN STUDIO: AssetService:CreateEditableMeshAsync(part.MeshContent) and EditableMesh:GetFaces().
-- It can fail when the Mesh and Image APIs are off, or the mesh is not owned by the place owner.
-- Fallback: the rule reports "not measured" as a WARN; read the figure from the generator's result or Studio's
-- render stats and record it in the results table by hand.
local function countTriangles(part: MeshPart): number?
	local ok, result = pcall(function(): number
		local assetService = AssetService :: any
		local mesh = assetService:CreateEditableMeshAsync((part :: any).MeshContent)
		local faces = mesh:GetFaces()
		local count = #faces
		mesh:Destroy()
		return count
	end)
	if ok and type(result) == "number" then
		return result
	end
	return nil
end

-- Per-species validation ----------------------------------------------------------------------------------

type Measured = {
	plan: string,
	torsoLength: number,
	socketRadius: { Head: number, FrontLimbs: number, Legs: number, Tail: number },
	plugRadius: { Head: number, FrontLimbs: number, Legs: number, Tail: number },
	length: { Head: number, Torso: number, FrontLimbs: number, Legs: number, Tail: number },
	triangles: { [string]: number },
	volumeProxy: number,
}

local function validateSpecies(name: string): (Report, Measured?)
	local report = newReport()
	local root = ReplicatedStorage:FindFirstChild("CreatureParts")
	local folder = if root then root:FindFirstChild(name) else nil

	-- R01
	if not folder or not folder:IsA("Folder") then
		record(
			report,
			"FAIL",
			"R01",
			"ReplicatedStorage.CreatureParts." .. name .. " must exist and be a Folder"
		)
		return report, nil
	end
	local plan = folder:GetAttribute("BodyPlan")
	if plan ~= "Quad" and plan ~= "Biped" then
		record(
			report,
			"FAIL",
			"R01",
			'folder needs a string attribute BodyPlan of "Quad" or "Biped" (found '
				.. tostring(plan)
				.. ")"
		)
		return report, nil
	end
	record(report, "PASS", "R01", "species folder found, BodyPlan = " .. plan)
	local planName: string = plan :: string
	local ballDirection = BALL_DIRECTION[planName]

	-- R02: exactly the five templates, nothing else
	local problems: { string } = {}
	local parts: { [string]: MeshPart } = {}
	for _, templateName in TEMPLATES do
		local child = folder:FindFirstChild(templateName)
		if not child then
			table.insert(problems, "missing " .. templateName)
		elseif not child:IsA("MeshPart") then
			table.insert(
				problems,
				templateName .. " is a " .. child.ClassName .. ", not a MeshPart"
			)
		else
			parts[templateName] = child
		end
	end
	for _, child in folder:GetChildren() do
		if not table.find(TEMPLATES, child.Name) then
			table.insert(
				problems,
				"unexpected child " .. child.Name .. " (" .. child.ClassName .. ")"
			)
		end
	end
	finish(
		report,
		"R02",
		"FAIL",
		"folder holds exactly Head, Torso, FrontLimb, Leg, Tail as MeshParts",
		problems
	)
	local torso = parts.Torso
	if not torso or not parts.Head or not parts.FrontLimb or not parts.Leg or not parts.Tail then
		return report, nil
	end

	-- R03: mesh present, no texture, flat material, nothing but attachments inside
	problems = {}
	for templateName, part in parts do
		if part.MeshId == "" then
			table.insert(problems, templateName .. " has no MeshId")
		end
		if part.TextureID ~= "" then
			table.insert(
				problems,
				templateName .. " has a TextureID (clear it: colour is applied at runtime)"
			)
		end
		if part.Material ~= Enum.Material.SmoothPlastic then
			table.insert(
				problems,
				templateName .. " Material is " .. part.Material.Name .. ", expected SmoothPlastic"
			)
		end
		for _, descendant in part:GetDescendants() do
			if not descendant:IsA("Attachment") then
				table.insert(
					problems,
					templateName .. " contains " .. descendant.ClassName .. " " .. descendant.Name
				)
			end
		end
	end
	finish(
		report,
		"R03",
		"FAIL",
		"mesh set, no texture, SmoothPlastic, only Attachments inside",
		problems
	)

	-- R04: no scripts anywhere (belt and braces on top of R03)
	problems = {}
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("LuaSourceContainer") then
			table.insert(problems, descendant:GetFullName())
		end
	end
	finish(report, "R04", "FAIL", "no scripts inside the species folder", problems)

	-- R05: required attachments present, no unknown ones
	problems = {}
	local allowedOnTorso: { string } = {
		"HeadSocket",
		"FrontLimbSocketL",
		"FrontLimbSocketR",
		"LegSocketL",
		"LegSocketR",
		"TailSocket",
	}
	for _, extra in OPTIONAL_ATTACHMENTS.Torso do
		table.insert(allowedOnTorso, extra)
	end
	for _, socketName in allowedOnTorso do
		if socketName ~= "GroundPoint" and not getAttachment(torso, socketName) then
			table.insert(problems, "Torso missing " .. socketName)
		end
	end
	for _, child in torso:GetChildren() do
		if child:IsA("Attachment") and not table.find(allowedOnTorso, child.Name) then
			table.insert(problems, "Torso has unknown attachment " .. child.Name)
		end
	end
	for _, templateName in LIMB_TEMPLATES do
		local part = parts[templateName]
		local plugCount = 0
		local allowed: { string } = { "Plug" }
		local extras: { string } = OPTIONAL_ATTACHMENTS[templateName] or {}
		for _, extra in extras do
			table.insert(allowed, extra)
		end
		for _, child in part:GetChildren() do
			if child.Name == "Plug" then
				plugCount += 1
			end
			if child:IsA("Attachment") and not table.find(allowed, child.Name) then
				table.insert(problems, templateName .. " has unknown attachment " .. child.Name)
			end
		end
		if plugCount ~= 1 or not getAttachment(part, "Plug") then
			table.insert(
				problems,
				templateName
					.. " needs exactly one Attachment named Plug (found "
					.. plugCount
					.. ")"
			)
		end
	end
	finish(
		report,
		"R05",
		"FAIL",
		"torso has the six sockets; every other part has exactly one Plug; no unknown attachments",
		problems
	)

	-- Stop early if the structure is broken: later rules would only produce noise.
	if report.fails > 0 then
		return report, nil
	end

	-- R06: Radius attributes
	problems = {}
	local socketRadiusByName: { [string]: number } = {}
	for _, entry in SOCKETS do
		for _, socketName in entry.sockets do
			local attachment = getAttachment(torso, socketName) :: Attachment
			local radius = getRadius(attachment)
			if radius then
				socketRadiusByName[socketName] = radius
			else
				table.insert(problems, socketName .. " needs a number attribute Radius > 0")
			end
		end
	end
	local plugRadiusByTemplate: { [string]: number } = {}
	for _, templateName in LIMB_TEMPLATES do
		local plug = getAttachment(parts[templateName], "Plug") :: Attachment
		local radius = getRadius(plug)
		if radius then
			plugRadiusByTemplate[templateName] = radius
		else
			table.insert(problems, templateName .. ".Plug needs a number attribute Radius > 0")
		end
	end
	for _, pair in { { "FrontLimbSocketL", "FrontLimbSocketR" }, { "LegSocketL", "LegSocketR" } } do
		local a, b = socketRadiusByName[pair[1]], socketRadiusByName[pair[2]]
		if a and b and math.abs(a - b) > RADIUS_MIRROR_TOLERANCE * math.max(a, b) then
			table.insert(
				problems,
				pair[1]
					.. " and "
					.. pair[2]
					.. " Radius differ ("
					.. fmt(a)
					.. " vs "
					.. fmt(b)
					.. ")"
			)
		end
	end
	finish(
		report,
		"R06",
		"FAIL",
		"every socket and plug has a Radius attribute; left and right radii match",
		problems
	)
	if report.fails > 0 then
		return report, nil
	end

	-- R07: attachment orientations are identity (the part keeps its authored pose in the torso's frame)
	problems = {}
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("Attachment") and descendant.Orientation.Magnitude > TOLERANCE_ANGLE then
			table.insert(
				problems,
				(if descendant.Parent then descendant.Parent.Name else "?")
					.. "."
					.. descendant.Name
					.. " Orientation = "
					.. tostring(descendant.Orientation)
			)
		end
	end
	finish(report, "R07", "FAIL", "all attachments have zero orientation", problems)

	-- R08: pivots. Torso at its centre; every other part at its Plug.
	problems = {}
	if torso.PivotOffset.Position.Magnitude > TOLERANCE_POSITION then
		table.insert(
			problems,
			"Torso PivotOffset should be zero, is " .. tostring(torso.PivotOffset.Position)
		)
	end
	for _, templateName in LIMB_TEMPLATES do
		local part = parts[templateName]
		local plug = getAttachment(part, "Plug") :: Attachment
		if (part.PivotOffset.Position - plug.Position).Magnitude > TOLERANCE_POSITION then
			table.insert(
				problems,
				templateName
					.. " PivotOffset "
					.. tostring(part.PivotOffset.Position)
					.. " is not at Plug "
					.. tostring(plug.Position)
			)
		end
		local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 =
			part.PivotOffset:GetComponents()
		local rotationOff = math.abs(r00 - 1)
			+ math.abs(r11 - 1)
			+ math.abs(r22 - 1)
			+ math.abs(r01)
			+ math.abs(r02)
			+ math.abs(r10)
			+ math.abs(r12)
			+ math.abs(r20)
			+ math.abs(r21)
		if rotationOff > 0.01 then
			table.insert(problems, templateName .. " PivotOffset has a rotation")
		end
	end
	finish(
		report,
		"R08",
		"FAIL",
		"pivot at the ball-end centre (Plug) on every part; torso pivot at its centre",
		problems
	)

	-- R09: sizes in range, finite
	problems = {}
	for templateName, part in parts do
		local size = part.Size
		if not isFinite(size) then
			table.insert(problems, templateName .. " Size is not finite")
		end
		for _, dimension in { size.X, size.Y, size.Z } do
			if dimension < DIMENSION_RANGE.min or dimension > DIMENSION_RANGE.max then
				table.insert(
					problems,
					templateName
						.. " dimension "
						.. fmt(dimension)
						.. " outside "
						.. DIMENSION_RANGE.min
						.. " to "
						.. DIMENSION_RANGE.max
				)
			end
		end
	end
	local torsoLength = if planName == "Quad" then torso.Size.Z else torso.Size.Y
	if torsoLength < TORSO_LENGTH_RANGE.min or torsoLength > TORSO_LENGTH_RANGE.max then
		table.insert(
			problems,
			"torsoLength "
				.. fmt(torsoLength)
				.. " outside "
				.. TORSO_LENGTH_RANGE.min
				.. " to "
				.. TORSO_LENGTH_RANGE.max
		)
	end
	finish(report, "R09", "FAIL", "part dimensions and torso length in range", problems)

	-- R10: plug position (ball end on the correct face, on the symmetry plane), radius fits inside the part, lengths
	problems = {}
	local lengths: { [string]: number } = { Torso = torsoLength }
	for _, templateName in LIMB_TEMPLATES do
		local part = parts[templateName]
		local plug = getAttachment(part, "Plug") :: Attachment
		local radius = plugRadiusByTemplate[templateName]
		local direction = ballDirection[templateName]
		local halfAlong = absVector(direction):Dot(part.Size) / 2
		local along = plug.Position:Dot(direction)
		local expected = halfAlong - radius
		local tolerance = math.max(0.2 * radius, 0.05)
		if math.abs(along - expected) > tolerance then
			table.insert(
				problems,
				string.format(
					"%s Plug is %.2f along %s, expected about %.2f (ball end should touch that face)",
					templateName,
					along,
					tostring(direction),
					expected
				)
			)
		end
		local lateral = plug.Position - direction * along
		local lateralLimit = 0.15 * math.max(part.Size.X, part.Size.Y, part.Size.Z)
		if lateral.Magnitude > lateralLimit then
			table.insert(
				problems,
				templateName .. " Plug is off the part's axis by " .. fmt(lateral.Magnitude)
			)
		end
		if math.abs(plug.Position.X) > 0.02 * part.Size.X + TOLERANCE_POSITION then
			table.insert(
				problems,
				templateName
					.. " Plug is off the left-right centre line (X = "
					.. fmt(plug.Position.X)
					.. ")"
			)
		end
		local crossSection: number = 0
		if direction.Y ~= 0 then
			crossSection = math.min(part.Size.X, part.Size.Z)
		elseif direction.Z ~= 0 then
			crossSection = math.min(part.Size.X, part.Size.Y)
		end
		if radius > 0.55 * crossSection then
			table.insert(
				problems,
				string.format(
					"%s plug radius %.2f is more than half its narrowest width %.2f",
					templateName,
					radius,
					crossSection
				)
			)
		end
		lengths[templateName] = along + halfAlong
	end
	finish(
		report,
		"R10",
		"FAIL",
		"Plug sits at the ball end, on the centre line, ball fits inside the part",
		problems
	)

	-- R11: torso sockets: inside the torso, mirrored, in the right places, radius sensible
	problems = {}
	local half = torso.Size / 2
	local function socketPosition(socketName: string): Vector3
		return (getAttachment(torso, socketName) :: Attachment).Position
	end
	for socketName, radius in socketRadiusByName do
		local position = socketPosition(socketName)
		if
			math.abs(position.X) > half.X
			or math.abs(position.Y) > half.Y
			or math.abs(position.Z) > half.Z
		then
			table.insert(problems, socketName .. " lies outside the torso box")
		end
		local fraction = radius / torsoLength
		if fraction < SOCKET_RADIUS_FRACTION.min or fraction > SOCKET_RADIUS_FRACTION.max then
			table.insert(
				problems,
				string.format(
					"%s radius is %.0f%% of torsoLength, expected %.0f%% to %.0f%%",
					socketName,
					fraction * 100,
					SOCKET_RADIUS_FRACTION.min * 100,
					SOCKET_RADIUS_FRACTION.max * 100
				)
			)
		end
	end
	for _, pair in { { "FrontLimbSocketL", "FrontLimbSocketR" }, { "LegSocketL", "LegSocketR" } } do
		local l, r = socketPosition(pair[1]), socketPosition(pair[2])
		if l.X >= 0 or r.X <= 0 then
			table.insert(
				problems,
				pair[1]
					.. " must have X < 0 and "
					.. pair[2]
					.. " X > 0 (creature faces -Z, its left is -X)"
			)
		end
		if
			math.abs(l.X + r.X) > TOLERANCE_POSITION
			or math.abs(l.Y - r.Y) > TOLERANCE_POSITION
			or math.abs(l.Z - r.Z) > TOLERANCE_POSITION
		then
			table.insert(problems, pair[1] .. " and " .. pair[2] .. " are not mirror images")
		end
	end
	for _, centred in { "HeadSocket", "TailSocket" } do
		if math.abs(socketPosition(centred).X) > TOLERANCE_POSITION then
			table.insert(problems, centred .. " must be on X = 0")
		end
	end
	local head, tail = socketPosition("HeadSocket"), socketPosition("TailSocket")
	local frontLimb, leg = socketPosition("FrontLimbSocketL"), socketPosition("LegSocketL")
	if planName == "Quad" then
		if head.Z >= 0 then
			table.insert(problems, "Quad HeadSocket must be at the front (Z < 0)")
		end
		if tail.Z <= 0 then
			table.insert(problems, "Quad TailSocket must be at the back (Z > 0)")
		end
		if frontLimb.Z >= leg.Z then
			table.insert(problems, "Quad FrontLimbSocket must be in front of LegSocket (smaller Z)")
		end
		if frontLimb.Y > 0.1 * torso.Size.Y or leg.Y > 0.1 * torso.Size.Y then
			table.insert(
				problems,
				"Quad limb sockets should be on the underside (Y at or below the centre line)"
			)
		end
	else
		if head.Y <= 0 then
			table.insert(problems, "Biped HeadSocket must be at the top (Y > 0)")
		end
		if leg.Y >= 0 then
			table.insert(problems, "Biped LegSocket must be below the centre (Y < 0)")
		end
		if frontLimb.Y <= leg.Y then
			table.insert(problems, "Biped FrontLimbSocket (arms) must be above LegSocket")
		end
		if tail.Z <= 0 then
			table.insert(problems, "Biped TailSocket must be at the back (Z > 0)")
		end
	end
	finish(
		report,
		"R11",
		"FAIL",
		"torso sockets inside the box, mirrored, correctly placed, radius 6 to 30 percent of torso length",
		problems
	)

	-- R12: physics flags
	problems = {}
	for templateName, part in parts do
		if part.CanCollide or part.CanTouch or part.CanQuery then
			table.insert(
				problems,
				templateName .. " must have CanCollide, CanTouch and CanQuery false"
			)
		end
		if not part.Massless then
			table.insert(problems, templateName .. " must be Massless")
		end
		if not part.Anchored then
			table.insert(
				problems,
				templateName .. " template must be Anchored (the Assembler un-anchors its clones)"
			)
		end
		if part.CollisionFidelity ~= Enum.CollisionFidelity.Box then
			table.insert(problems, templateName .. " CollisionFidelity should be Box")
		end
		if templateName ~= "Torso" and templateName ~= "Head" and part.CastShadow then
			table.insert(problems, templateName .. " should have CastShadow off")
		end
	end
	finish(
		report,
		"R12",
		"FAIL",
		"physics: no collide, touch or query; Massless; Anchored template; Box fidelity; limb shadows off",
		problems
	)

	-- R13: front limb length against leg length
	problems = {}
	local ratio = lengths.FrontLimb / lengths.Leg
	if planName == "Quad" then
		if ratio < FRONT_LIMB_TO_LEG_QUAD.min or ratio > FRONT_LIMB_TO_LEG_QUAD.max then
			table.insert(
				problems,
				string.format(
					"FrontLimb is %.2f x Leg length; Quad front limbs must reach the ground (%.2f to %.2f)",
					ratio,
					FRONT_LIMB_TO_LEG_QUAD.min,
					FRONT_LIMB_TO_LEG_QUAD.max
				)
			)
		end
	elseif ratio > 1 then
		table.insert(
			problems,
			string.format(
				"FrontLimb (arm) is %.2f x Leg length; Biped arms should not be longer than legs",
				ratio
			)
		)
	end
	if lengths.Leg < LEG_LENGTH_RANGE.min or lengths.Leg > LEG_LENGTH_RANGE.max then
		table.insert(
			problems,
			"Leg length "
				.. fmt(lengths.Leg)
				.. " outside "
				.. LEG_LENGTH_RANGE.min
				.. " to "
				.. LEG_LENGTH_RANGE.max
		)
	end
	finish(report, "R13", "WARN", "limb lengths in proportion", problems)

	-- R14: triangle budgets
	problems = {}
	local notMeasured: { string } = {}
	local triangles: { [string]: number } = {}
	for templateName, part in parts do
		local count = countTriangles(part)
		local budget = TRIANGLES[templateName]
		if count == nil then
			table.insert(notMeasured, templateName)
		else
			triangles[templateName] = count
			if count > budget.max * TRIANGLE_HARD_FACTOR then
				table.insert(
					problems,
					string.format(
						"%s has %d triangles, hard limit %d",
						templateName,
						count,
						math.floor(budget.max * TRIANGLE_HARD_FACTOR)
					)
				)
			elseif count > budget.max then
				table.insert(
					problems,
					string.format(
						"%s has %d triangles, budget %d (WARN only)",
						templateName,
						count,
						budget.max
					)
				)
			elseif count < budget.min then
				table.insert(
					problems,
					string.format(
						"%s has only %d triangles, budget starts at %d (WARN only; may look faceted)",
						templateName,
						count,
						budget.min
					)
				)
			end
		end
	end
	if #notMeasured > 0 then
		record(
			report,
			"WARN",
			"R14",
			"triangles NOT MEASURED for "
				.. table.concat(notMeasured, ", ")
				.. " (enable Mesh and Image APIs, or count by hand; see PART_SPEC section 8)"
		)
	else
		local total = triangles.Head
			+ triangles.Torso
			+ 2 * triangles.FrontLimb
			+ 2 * triangles.Leg
			+ triangles.Tail
		if total > CREATURE_TRIANGLES_HARD then
			table.insert(
				problems,
				string.format(
					"whole creature is %d triangles, hard limit %d",
					total,
					CREATURE_TRIANGLES_HARD
				)
			)
			finish(report, "R14", "FAIL", "triangle budgets", problems)
		elseif #problems > 0 or total > CREATURE_TRIANGLES_MAX then
			if total > CREATURE_TRIANGLES_MAX then
				table.insert(
					problems,
					string.format(
						"whole creature is %d triangles, budget %d",
						total,
						CREATURE_TRIANGLES_MAX
					)
				)
			end
			-- A part over its hard limit is a FAIL; anything else is a WARN.
			local isFail = false
			for _, problem in problems do
				if string.find(problem, "hard limit", 1, true) then
					isFail = true
				end
			end
			finish(report, "R14", if isFail then "FAIL" else "WARN", "triangle budgets", problems)
		else
			record(
				report,
				"PASS",
				"R14",
				string.format(
					"triangle budgets (whole creature %d of %d)",
					total,
					CREATURE_TRIANGLES_MAX
				)
			)
		end
	end

	local measured: Measured = {
		plan = planName,
		torsoLength = torsoLength,
		socketRadius = {
			Head = socketRadiusByName.HeadSocket,
			FrontLimbs = socketRadiusByName.FrontLimbSocketL,
			Legs = socketRadiusByName.LegSocketL,
			Tail = socketRadiusByName.TailSocket,
		},
		plugRadius = {
			Head = plugRadiusByTemplate.Head,
			FrontLimbs = plugRadiusByTemplate.FrontLimb,
			Legs = plugRadiusByTemplate.Leg,
			Tail = plugRadiusByTemplate.Tail,
		},
		length = {
			Head = lengths.Head,
			Torso = lengths.Torso,
			FrontLimbs = lengths.FrontLimb,
			Legs = lengths.Leg,
			Tail = lengths.Tail,
		},
		triangles = triangles,
		volumeProxy = torso.Size.X * torso.Size.Y * torso.Size.Z,
	}
	return report, measured
end

-- Cross-species fit table -------------------------------------------------------------------------------------

local function fitTable(measuredBySpecies: { [string]: Measured }, names: { string }): { string }
	local lines: { string } = {}
	local slots: { string } = { "Head", "FrontLimbs", "Legs", "Tail" }
	local clamped = 0
	local total = 0
	for _, torsoName in names do
		for _, donorName in names do
			local torsoData, donorData = measuredBySpecies[torsoName], measuredBySpecies[donorName]
			if
				torsoData
				and donorData
				and torsoData.plan == donorData.plan
				and torsoName ~= donorName
			then
				local cells: { string } = {}
				for _, slot in slots do
					local socket = (torsoData.socketRadius :: any)[slot] :: number
					local plug = (donorData.plugRadius :: any)[slot] :: number
					local raw = socket / plug
					total += 1
					local mark = ""
					if raw < SCALE_MIN or raw > SCALE_MAX then
						clamped += 1
						mark = "*"
					end
					table.insert(cells, string.format("%s %.2f%s", slot, raw, mark))
				end
				table.insert(
					lines,
					string.format(
						"  torso %s <- donor %s : %s",
						torsoName,
						donorName,
						table.concat(cells, ", ")
					)
				)
			end
		end
	end
	table.insert(
		lines,
		string.format(
			"  (* = outside %.2f to %.2f, so the Assembler clamps it and the ball will not fit exactly) %d of %d cells clamped",
			SCALE_MIN,
			SCALE_MAX,
			clamped,
			total
		)
	)
	return lines
end

-- Gauges ---------------------------------------------------------------------------------------------------------

local function buildGauges(names: { string })
	local old = workspace:FindFirstChild("PartGauges")
	if old then
		old:Destroy()
	end
	local gauges = Instance.new("Folder")
	gauges.Name = "PartGauges"
	local root = ReplicatedStorage:FindFirstChild("CreatureParts")
	if not root then
		gauges.Parent = workspace
		return
	end
	local column = 0
	for _, name in names do
		local species = root:FindFirstChild(name)
		if species then
			local row = 0
			for _, templateName in TEMPLATES do
				local template = species:FindFirstChild(templateName)
				if template and template:IsA("MeshPart") then
					local clone = template:Clone()
					clone.Anchored = true
					clone:PivotTo(CFrame.new(column * 14, 6 + row * 0, row * 12))
					clone.Parent = gauges
					for _, attachment in clone:GetChildren() do
						local radius = if attachment:IsA("Attachment")
							then getRadius(attachment)
							else nil
						if attachment:IsA("Attachment") and radius then
							local ball = Instance.new("Part")
							ball.Shape = Enum.PartType.Ball
							ball.Size = Vector3.one * radius * 2
							ball.Anchored = true
							ball.CanCollide = false
							ball.CanQuery = false
							ball.Transparency = 0.6
							ball.Color = if attachment.Name == "Plug"
								then Color3.fromRGB(255, 80, 80)
								else Color3.fromRGB(80, 160, 255)
							ball.Name = name
								.. "_"
								.. templateName
								.. "_"
								.. attachment.Name
								.. "_gauge"
							ball.CFrame = CFrame.new(attachment.WorldPosition)
							ball.Parent = gauges
						end
					end
					row += 1
				end
			end
			column += 1
		end
	end
	gauges.Parent = workspace
end

-- Main ---------------------------------------------------------------------------------------------------------------

do
	-- Use the project's own clamp when the code is synced into this place.
	local sharedFolder = ReplicatedStorage:FindFirstChild("shared")
	local moduleScript = if sharedFolder then sharedFolder:FindFirstChild("AssemblyMath") else nil
	if moduleScript and moduleScript:IsA("ModuleScript") then
		local ok, result = pcall(function(): any
			return (require :: any)(moduleScript)
		end)
		if
			ok
			and type(result) == "table"
			and type(result.SCALE_MIN) == "number"
			and type(result.SCALE_MAX) == "number"
		then
			SCALE_MIN = result.SCALE_MIN
			SCALE_MAX = result.SCALE_MAX
		end
	end
end

local output: { string } = {}
local measuredBySpecies: { [string]: Measured } = {}
local totalFails = 0

for _, name in SPECIES_NAMES do
	table.insert(output, "=== " .. name .. " ===")
	local report, measured = validateSpecies(name)
	for _, line in report.lines do
		table.insert(output, line)
	end
	totalFails += report.fails
	local verdict = if report.fails == 0 then "PASS" else "FAIL"
	table.insert(
		output,
		string.format(
			"%s  %s: %d passed, %d warnings, %d failed",
			verdict,
			name,
			report.passes,
			report.warns,
			report.fails
		)
	)
	if measured then
		measuredBySpecies[name] = measured
		table.insert(output, "")
		table.insert(
			output,
			"-- Measured numbers for "
				.. name
				.. " (paste into its SpeciesDef; weight comes from the roster, not from here)"
		)
		table.insert(output, string.format("torsoLength = %.2f,", measured.torsoLength))
		table.insert(
			output,
			string.format(
				"socketRadius = { Torso = 0, Head = %.2f, FrontLimbs = %.2f, Legs = %.2f, Tail = %.2f },",
				measured.socketRadius.Head,
				measured.socketRadius.FrontLimbs,
				measured.socketRadius.Legs,
				measured.socketRadius.Tail
			)
		)
		table.insert(output, "-- parts[slot].plugRadius and parts[slot].length:")
		table.insert(
			output,
			string.format(
				"--   Head       plugRadius = %.2f, length = %.2f",
				measured.plugRadius.Head,
				measured.length.Head
			)
		)
		table.insert(
			output,
			string.format("--   Torso      plugRadius = 0,    length = %.2f", measured.length.Torso)
		)
		table.insert(
			output,
			string.format(
				"--   FrontLimbs plugRadius = %.2f, length = %.2f",
				measured.plugRadius.FrontLimbs,
				measured.length.FrontLimbs
			)
		)
		table.insert(
			output,
			string.format(
				"--   Legs       plugRadius = %.2f, length = %.2f",
				measured.plugRadius.Legs,
				measured.length.Legs
			)
		)
		table.insert(
			output,
			string.format(
				"--   Tail       plugRadius = %.2f, length = %.2f",
				measured.plugRadius.Tail,
				measured.length.Tail
			)
		)
		table.insert(
			output,
			string.format(
				"-- weight check: torso box volume %.1f studs^3 (use only to sanity-check the roster's weight ordering)",
				measured.volumeProxy
			)
		)
		if next(measured.triangles) then
			local parts: { string } = {}
			for _, templateName in TEMPLATES do
				table.insert(
					parts,
					templateName .. " " .. tostring(measured.triangles[templateName])
				)
			end
			table.insert(output, "-- triangles: " .. table.concat(parts, ", "))
		end
	end
	table.insert(output, "")
end

if #SPECIES_NAMES > 1 then
	table.insert(
		output,
		"=== Fit scales (socket radius / plug radius) for every same-plan pair ==="
	)
	for _, line in fitTable(measuredBySpecies, SPECIES_NAMES) do
		table.insert(output, line)
	end
	table.insert(output, "")
end

if SHOW_GAUGES then
	buildGauges(SPECIES_NAMES)
	table.insert(output, "Gauges built in Workspace.PartGauges (delete the folder when finished).")
end

table.insert(
	output,
	if totalFails == 0
		then "RESULT: PASS (no failed rules)"
		else string.format("RESULT: FAIL (%d failed rules)", totalFails)
)
local text = table.concat(output, "\n")
print(text)
return text
