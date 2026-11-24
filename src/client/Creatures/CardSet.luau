--!strict
-- The cards on the Creatures screen: one per creature, in the team row or the stable grid, plus
-- dashed cards for team places not yet filled. A card is built once per creature and only
-- refreshed after that (it skips the work when nothing it shows has changed); a creature moving
-- between the team and the stable gets a card of the other size. Looks only.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreatureCard = require(script.Parent.CreatureCard)
local Profile = require(ReplicatedStorage.shared.Profile)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)

local CardSet = {}

CardSet.MAX_TEAM = 6 -- the most the server ever allows (ProfileConfig.MAX_TEAM_SIZE)
CardSet.GAP = 8 -- between team cards, in pixels

export type Set = {
	sync: (state: Snapshot.State, isParent: (id: string) -> boolean) -> (),
	select: (id: string?) -> (),
	frameOf: (id: string) -> GuiObject?,
}

function CardSet.new(teamRow: Frame, stable: Frame, onTap: (id: string) -> ()): Set
	local cards: { [string]: CreatureCard.Card } = {}
	local emptySlots: { Frame } = {}
	local emptyKey = ""
	local selected: string? = nil

	local function cardFor(
		view: Snapshot.CreatureView,
		kind: CreatureCard.Kind
	): (CreatureCard.Card, boolean)
		local existing = cards[view.Id]
		if existing and existing.kind == kind then
			return existing, false
		end
		if existing then
			existing.destroy()
		end
		local made = CreatureCard.new(if kind == "team" then teamRow else stable, kind, view, onTap)
		cards[view.Id] = made
		return made, true
	end

	return {
		sync = function(state: Snapshot.State, isParent: (id: string) -> boolean)
			local places: { [string]: number } = {}
			for place, id in state.Team do
				places[id] = place
			end
			local slots = math.clamp(
				math.max(Profile.teamSize(state.Badges), #state.Team),
				1,
				CardSet.MAX_TEAM
			)
			local width = UDim2.new(1 / slots, -math.ceil(CardSet.GAP * (slots - 1) / slots), 1, 0)
			local present: { [string]: boolean } = {}
			local boxOrder = 0
			for _, view in state.Creatures do
				present[view.Id] = true
				local place = places[view.Id]
				local kind: CreatureCard.Kind = if place then "team" else "box"
				local card, fresh = cardFor(view, kind)
				if fresh then
					card.setSelected(selected == view.Id)
				end
				card.refresh(view, place, isParent(view.Id))
				if place then
					card.frame.LayoutOrder = place
					card.frame.Size = width
				else
					boxOrder += 1
					card.frame.LayoutOrder = boxOrder
				end
			end
			for id, card in cards do
				if not present[id] then
					card.destroy()
					cards[id] = nil
				end
			end
			-- Dashed cards for the team places not yet filled.
			local key = `{slots}:{#state.Team}`
			if key ~= emptyKey then
				emptyKey = key
				for _, slot in emptySlots do
					slot:Destroy()
				end
				emptySlots = {}
				for place = #state.Team + 1, slots do
					local made = CreatureCard.empty(teamRow, place)
					made.LayoutOrder = place
					table.insert(emptySlots, made)
				end
			end
			for _, slot in emptySlots do
				slot.Size = width
			end
		end,
		select = function(id: string?)
			selected = id
			for cardId, card in cards do
				card.setSelected(cardId == id)
			end
		end,
		frameOf = function(id: string): GuiObject?
			local card = cards[id]
			return if card then card.frame else nil
		end,
	}
end

return CardSet
