--!strict
-- The breeding strip under the stable: which creatures are picked as parents, what the egg
-- would cost and the odds of each rarity. It shows only while a parent is picked. Two picks make
-- a pair; the Breed button appears when the shared rules say the pair can breed. The server
-- checks and decides everything (including close relatives, which the client cannot see).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Breeding = require(ReplicatedStorage.shared.Breeding)
local Economy = require(ReplicatedStorage.shared.Economy)
local Kit = require(script.Parent.Parent.UI.Kit)
local Net = require(ReplicatedStorage.net.generated.Client)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)
local Types = require(ReplicatedStorage.shared.Types)

local BreedStrip = {}

export type Strip = {
	frame: Frame,
	has: (id: string) -> boolean,
	toggle: (id: string) -> (),
	clear: () -> (),
	-- Sets the text and buttons; returns whether the strip is showing.
	update: (state: Snapshot.State) -> boolean,
}

BreedStrip.HEIGHT = 60

-- The creature record the shared rules expect, rebuilt from what the server sent for display.
-- (Parents are not sent: the server alone checks that two creatures are not close relatives.)
local function record(view: Snapshot.CreatureView): Types.Creature
	local function part(p: Snapshot.PartView): Types.Part
		return { species = p.Species, quality = p.Quality }
	end
	return {
		id = view.Id,
		bodyPlan = view.BodyPlan,
		parts = {
			Head = part(view.Head),
			Torso = part(view.Torso),
			FrontLimbs = part(view.FrontLimbs),
			Legs = part(view.Legs),
			Tail = part(view.Tail),
		},
		size = view.Size,
		colour = { shown = view.Colour, carried = view.CarriedColour },
		rarity = view.Rarity,
		level = view.Level,
		xp = view.Xp,
		generation = view.Generation,
		parents = nil,
		breedCount = view.BreedCount,
		breedReadyAt = view.BreedReadyAt,
		originBiome = view.OriginBiome,
		isGiant = view.IsGiant,
		bound = view.Bound,
		serial = view.Serial,
		hurt = if view.Hurt > 0 then view.Hurt else nil,
	}
end

function BreedStrip.new(parent: Instance, onChange: () -> ()): Strip
	local parents: { string } = {}
	local frame = Kit.panel(
		parent,
		UDim2.new(1, 0, 0, BreedStrip.HEIGHT),
		UDim2.new(0, 0, 1, -BreedStrip.HEIGHT),
		Kit.COLOURS.panelLight
	)
	frame.Visible = false
	local text = Kit.label(frame, "", UDim2.new(1, -196, 1, -8), UDim2.fromOffset(10, 4), 16)
	text.TextWrapped = true
	local breedButton = Kit.button(frame, "Breed", Kit.COLOURS.good, function()
		if #parents == 2 then
			Net.RequestBreed.Fire({
				ParentA = parents[1],
				ParentB = parents[2],
				CharmSlot = nil,
				CharmFavour = nil,
			})
		end
	end)
	breedButton.Size = UDim2.fromOffset(100, 44)
	breedButton.Position = UDim2.new(1, -182, 0.5, -22)
	local clearButton = Kit.button(frame, "Clear", Kit.COLOURS.panel, function()
		table.clear(parents)
		onChange()
	end)
	clearButton.Size = UDim2.fromOffset(70, 44)
	clearButton.Position = UDim2.new(1, -78, 0.5, -22)

	local function describe(state: Snapshot.State, chosen: { Types.Creature })
		breedButton.Visible = #chosen == 2
		if #chosen == 1 then
			text.Text = `{chosen[1].parts.Torso.species} and... pick a second creature`
			return
		end
		local a, b = chosen[1], chosen[2]
		local ok, why = Breeding.canBreed(a, b, os.time())
		if not ok then
			breedButton.Visible = false
			text.Text = why or "Those two cannot breed"
			return
		end
		local candy: { string } = {}
		-- Prism Candy covers whatever typed candy is missing (Economy.candyPayment); say so,
		-- or the cost reads as out of reach when it is not.
		local fromPrism = 0
		for _, need in Breeding.candyCost(a, b) do
			table.insert(candy, `{need.amount} {need.element}`)
			local have = math.floor((state.Candy :: any)[need.element] or 0)
			fromPrism += math.max(0, need.amount - have)
		end
		if fromPrism > 0 then
			table.insert(candy, `({fromPrism} paid in Prism)`)
		end
		for _, need in Breeding.giantCandyCost(a, b) do
			local have = state.Items[Economy.giantCandyKey(need.species)] or 0
			table.insert(candy, `{need.amount} {need.species} Giant Candy (you have {have})`)
		end
		local odds: { string } = {}
		local chances = Breeding.rarityOdds(a, b)
		for _, rarity in { "Common", "Uncommon", "Gem", "Ruby", "Diamond" } do
			local chance = (chances :: { [string]: number? })[rarity]
			if chance and chance > 0 then
				table.insert(odds, `{rarity} {math.floor(chance * 100 + 0.5)}%`)
			end
		end
		text.Text = `{a.parts.Torso.species} + {b.parts.Torso.species}\n`
			.. `Cost: {Breeding.cost(a, b)} coins, candy: {table.concat(candy, " + ")}\n`
			.. `Child: {table.concat(odds, ", ")}`
	end

	return {
		frame = frame,
		has = function(id: string): boolean
			return table.find(parents, id) ~= nil
		end,
		toggle = function(id: string)
			local at = table.find(parents, id)
			if at then
				table.remove(parents, at)
			elseif #parents < 2 then
				table.insert(parents, id)
			end
			onChange()
		end,
		clear = function()
			table.clear(parents)
		end,
		update = function(state: Snapshot.State): boolean
			local chosen: { Types.Creature } = {}
			local kept: { string } = {}
			for _, id in parents do
				for _, view in state.Creatures do
					if view.Id == id then
						table.insert(chosen, record(view))
						table.insert(kept, id)
					end
				end
			end
			parents = kept -- a parent that has been released drops out
			frame.Visible = #chosen > 0
			if #chosen > 0 then
				describe(state, chosen)
			end
			return #chosen > 0
		end,
	}
end

return BreedStrip
