--!strict
-- A biome's lair on the test map: the spur's slabs (generated biomes only), the giant's round
-- arena, the giant asleep in it with its Giant prompt, and the supply stall's keeper with a Shop
-- prompt and a counter. Split from TestMap.luau; every part name and prompt is as it was there.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Giants = require(ReplicatedStorage.content.Giants)
local Layout = require(ReplicatedStorage.shared.Layout)
local WorldConfig = require(ReplicatedStorage.config.WorldConfig)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local Markers = require(script.Parent.Markers)
local Props = require(script.Parent.Props)

local Lair = {}

local PATH = Color3.fromRGB(196, 178, 128)
local STONE = Color3.fromRGB(150, 150, 150)
local ARENA = Color3.fromRGB(120, 96, 66)
local WOOD = Color3.fromRGB(140, 105, 70)

local block, label, prompt = Markers.block, Markers.label, Markers.prompt
local at, slab, person = Markers.at, Markers.slab, Markers.person

function Lair.build(
	world: Instance,
	biome: WorldTypes.Biome,
	map: Layout.Map,
	dressing: WorldTypes.DressingSheet?
)
	if #map.lairSpur >= 2 then
		local arenaAt = map.lairSpur[#map.lairSpur]
		if not dressing then
			for index = 1, #map.lairSpur - 1 do
				slab(world, "LairSpur", map.lairSpur[index], map.lairSpur[index + 1], 24, PATH)
			end
		end
		local arena = block(
			world,
			biome.lair.id,
			Vector3.new(biome.lair.arenaSize, 0.6, biome.lair.arenaSize),
			at(arenaAt, 0.3),
			STONE
		)
		if dressing then
			-- A round clearing of bare earth, the giant's arena.
			arena.Shape = Enum.PartType.Cylinder
			arena.Size = Vector3.new(0.3, biome.lair.arenaSize, biome.lair.arenaSize)
			arena.CFrame = at(arenaAt, 0.2) * CFrame.Angles(0, 0, math.rad(90))
			arena.Color = ARENA
		end
		label(arena, biome.lair.name)
		local giant = Giants[biome.lair.giant]
		if giant then
			-- The giant sleeps in the middle of its arena; a Giant Horn wakes it.
			local sleeper = block(world, giant.id, Vector3.new(20, 40, 20), at(arenaAt, 20.6), WOOD)
			label(sleeper, `{giant.name} (Lv {giant.level})`)
			local body = Props.model(giant.name)
			if body then -- the giant itself, asleep, in place of the plain block
				sleeper.Transparency = 1
				local feet = Vector3.new(arenaAt.x, 0.4, arenaAt.z)
				Props.stand(world, body, feet, 40, Vector3.new(-1, 0, 1))
			end
			prompt(sleeper, "Giant", giant.id, "Blow the Giant Horn", giant.name, 40)
		end
		local stall = map.places[Layout.stallId(biome)]
		if stall then
			local join = map.lairSpur[1]
			local toward = Vector3.new(join.x, 0, join.z)
			-- The stall's name is the data's text before its first comma ("Shelf Stall").
			local stallName = string.match(biome.lair.supplyStall, "^([^,]+)") or "Stall"
			local keeper = person(world, stallName, stall, toward)
			prompt(
				keeper,
				"Shop",
				Layout.stallId(biome),
				"Shop",
				stallName,
				WorldConfig.TALK_RADIUS
			)
			if dressing then
				-- The stall's counter stands beside the keeper, off the lane.
				local down = Vector3.new(join.x - stall.x, 0, join.z - stall.z)
				local facing = if down.Magnitude > 1e-3 then down.Unit else Vector3.zAxis
				local side = Vector3.new(-facing.Z, 0, facing.X) * dressing.stall.side
				local foot = Vector3.new(stall.x, 0, stall.z) + side * 12
				local painted = Props.model("Stall")
				local counter = block(
					world,
					"StallCounter",
					Vector3.new(8, 4, 3),
					CFrame.lookAt(foot + Vector3.yAxis * 2, foot + Vector3.yAxis * 2 + facing),
					WOOD
				)
				if painted then
					counter.Transparency = 1
					Props.stand(world, painted, foot, 9, facing)
				else
					Props.part(
						world,
						Vector3.new(9, 0.6, 5),
						counter.CFrame * CFrame.new(0, 5, 0),
						Color3.fromRGB(96, 150, 84)
					)
				end
			end
		end
	end
end

return Lair
