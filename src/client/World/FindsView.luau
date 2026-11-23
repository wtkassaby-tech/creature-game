--!strict
-- Finds in side areas and dead ends on the device (approval pack 7, docs/plans/14_FINDS_AND_
-- REWARDS.md): a hold-to-search prompt at each cache, gathering spot, note and cairn, a small card
-- for what a search gave, and a journal (a button, and a panel listing each biome's finds, the
-- pages read and the keepsakes). Sightings need nothing here: they are the rustle spot's own prompt.
--
-- The device only shows and asks. A prompt sends the find's id and nothing else; the server checks
-- where the character stands, the limits and the carry room, and the answer is the card. Which
-- prompts are on comes from the saved state the server sent (claimed finds, spots used today, the
-- badges held); the server decides again on every request. Not yet run in Studio.

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Biomes = require(ReplicatedStorage.content.Biomes)
local Bus = require(script.Parent.Parent.Net.Bus)
local ClientState = require(script.Parent.Parent.State.ClientState)
local EconomyConfig = require(ReplicatedStorage.config.EconomyConfig)
local Finds = require(ReplicatedStorage.shared.Finds)
local FindsConfig = require(ReplicatedStorage.config.FindsConfig)
local Ground = require(ReplicatedStorage.shared.Ground)
local Kit = require(script.Parent.Parent.UI.Kit)
local Layout = require(ReplicatedStorage.shared.Layout)
local Net = require(ReplicatedStorage.net.generated.Client)
local Particles = require(script.Parent.Parent.Fx.Particles)
local Registry = require(ReplicatedStorage.content.Finds)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)
local Tamers = require(ReplicatedStorage.content.Tamers)
local WorldTypes = require(ReplicatedStorage.shared.WorldTypes)

local FindsView = {}

local ACTION: { [string]: string } =
	{ Cache = "Search", Gather = "Gather", Note = "Read", Cairn = "Add a stone" }

local CARD_SECONDS = 4.5
local GLINT_COLOUR = Color3.fromRGB(255, 232, 150)

-- What something is called on the card: an item's shop name, or a material's own name.
local function nameOf(item: string): string
	local items: { [string]: { name: string }? } = EconomyConfig.ITEMS :: any
	local found = items[item]
	return if found then found.name else item
end

local function set(list: { string }): { [string]: boolean }
	local map: { [string]: boolean } = {}
	for _, id in list do
		map[id] = true
	end
	return map
end

-- The prompts ------------------------------------------------------------------------------

type Spot = {
	find: WorldTypes.Find,
	part: Part,
	prompt: ProximityPrompt,
	glint: ParticleEmitter?,
}

-- Where a find stands in the world, with the ground's own height under it.
local function placeOf(
	find: WorldTypes.Find,
	world: Layout.World,
	grounds: { [number]: Ground.Ground }
): Vector3?
	local map = world.maps[find.biome]
	if not map then
		return nil
	end
	local point = Finds.point(map, find)
	if not point then
		return nil
	end
	local ground = grounds[find.biome]
	if not ground then
		local biome: WorldTypes.Biome? = nil
		for _, each in Biomes do
			if each.number == find.biome then
				biome = each
			end
		end
		ground = Ground.new(if biome then biome.map else nil, { x = map.hub.x, z = map.hub.z })
		grounds[find.biome] = ground
	end
	return Vector3.new(point.x, Ground.heightAt(ground, point.x, point.z), point.z)
end

local function makeSpot(parent: Instance, find: WorldTypes.Find, at: Vector3): Spot
	local part = Instance.new("Part")
	part.Name = find.id
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.Position = at + Vector3.new(0, 2, 0)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = ACTION[find.kind] or "Search"
	prompt.ObjectText = find.name
	prompt.HoldDuration = FindsConfig.HOLD_SECONDS
	prompt.MaxActivationDistance = FindsConfig.PROMPT_DISTANCE
	prompt.RequiresLineOfSight = false
	prompt.Enabled = false
	prompt:SetAttribute("PromptKind", "Find")
	prompt:SetAttribute("PromptId", find.id)
	prompt.Parent = part
	-- Caches, notes and cairns glint faintly when near (looks only); a hidden one gives no hint.
	local glint: ParticleEmitter? = nil
	if find.kind ~= "Gather" and not find.hidden then
		local emitter = Particles.emitter(part, "sparkle", GLINT_COLOUR, 0.5)
		emitter.Rate = 2
		glint = emitter
	end
	part.Parent = parent
	return { find = find, part = part, prompt = prompt, glint = glint }
end

-- Whether a find's prompt should be on, from the saved state alone.
local function isOn(
	find: WorldTypes.Find,
	state: Snapshot.State,
	today: { [string]: boolean },
	claimed: { [string]: boolean }
): boolean
	if find.pending or find.kind == "Sighting" then
		return false
	end
	if find.biome > state.Badges + 1 then
		return false
	end
	if find.kind == "Gather" then
		return Finds.opensWith(find, state.Badges) and not today[find.id]
	end
	return not claimed[find.id]
end

-- The card ---------------------------------------------------------------------------------

local function describe(value: {
	FindId: string,
	Outcome: Finds.Outcome,
	Gains: { { Item: string, Count: number } },
	Prism: number,
	SetDone: boolean,
}): (string, { string })
	local find = Registry.byId[value.FindId]
	local lines: { string } = {}
	for _, gain in value.Gains do
		table.insert(lines, `{nameOf(gain.Item)} x{gain.Count}`)
	end
	if find and find.kind == "Note" and find.text then
		for _, line in find.text do
			table.insert(lines, line)
		end
	end
	if value.SetDone and find then
		local pages = Finds.setOf(find)
		table.insert(
			lines,
			`Journal complete! +{value.Prism} Prism Candy and a keepsake: {if pages
				then pages.keepsake.name
				else ""}`
		)
	end
	local outcome = value.Outcome
	if outcome == "Found" then
		return "Found something!", lines
	elseif outcome == "Gathered" then
		return "Gathered", lines
	elseif outcome == "Read" then
		return "A page for your journal", lines
	elseif outcome == "Built" then
		local keepsake = if find and find.keepsake then find.keepsake.name else "a keepsake"
		table.insert(lines, `You keep: {keepsake}`)
		return "You add a stone to the cairn", lines
	elseif outcome == "AlreadyFound" then
		return "Already found", lines
	elseif outcome == "Resting" then
		return "Come back tomorrow", { "It has been picked clean for today." }
	elseif outcome == "TooFar" then
		return "Stay a moment", { "Stand close to it, on the same level, and hold." }
	elseif outcome == "Full" then
		return "Your bag is too full", { "Make some room and come back: it will keep." }
	end
	return "Not open yet", { "There is nothing to find here yet." }
end

-- The journal -----------------------------------------------------------------------------

local function textRow(
	parent: Instance,
	text: string,
	size: number,
	colour: Color3?,
	order: number
): TextLabel
	local row = Instance.new("TextLabel")
	row.BackgroundTransparency = 1
	row.Size = UDim2.fromScale(1, 0)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.Text = text
	row.TextWrapped = true
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.TextYAlignment = Enum.TextYAlignment.Top
	row.Font = Kit.FONT
	row.TextSize = size
	row.TextColor3 = colour or Kit.COLOURS.text
	row.LayoutOrder = order
	row.Parent = parent
	return row
end

local function fillJournal(list: ScrollingFrame, state: Snapshot.State?)
	for _, child in list:GetChildren() do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end
	local claimed = if state then set(state.Finds) else {}
	local order = 0
	local function add(text: string, size: number, colour: Color3?): TextLabel
		order += 1
		return textRow(list, text, size, colour, order)
	end

	-- The keepsake shelf: each one shown by name once owned, and as a question mark until then.
	local owned = Finds.keepsakesOf(claimed)
	local ownedIds = set((function(): { string }
		local ids: { string } = {}
		for _, keepsake in owned do
			table.insert(ids, keepsake.id)
		end
		return ids
	end)())
	local names: { string } = {}
	local all: { WorldTypes.Keepsake } = {}
	for _, keepsake in Registry.keepsakes do
		table.insert(all, keepsake)
	end
	table.sort(all, function(a, b)
		return a.id < b.id
	end)
	for _, keepsake in all do
		table.insert(names, if ownedIds[keepsake.id] then keepsake.name else "?")
	end
	add(`Keepsakes ({#owned} of {#all})`, 20, Kit.COLOURS.gold)
	add(table.concat(names, "   "), 18, nil)

	local biomes: { WorldTypes.Biome } = {}
	for _, biome in Biomes do
		table.insert(biomes, biome)
	end
	table.sort(biomes, function(a, b)
		return a.number < b.number
	end)
	for _, biome in biomes do
		if not state or biome.number <= state.Badges + 1 then
			local found, total = Finds.progressOf(claimed, biome.number)
			add(`Finds in {biome.name}: {found} of {total}`, 20, Kit.COLOURS.accent)
			for _, find in Registry.list do
				if find.biome == biome.number and find.kind == "Note" and not find.pending then
					if claimed[find.id] and find.text then
						add(find.name, 17, Kit.COLOURS.textDim)
						add(table.concat(find.text, " "), 16, nil)
					else
						add("An unread page", 17, Kit.COLOURS.textDim)
					end
				end
			end
		end
	end
end

-- Starting it -------------------------------------------------------------------------------

function FindsView.start(playerGui: Instance)
	local biomeList: { WorldTypes.Biome } = {}
	for _, biome in Biomes do
		table.insert(biomeList, biome)
	end
	local world = Layout.world(biomeList, Tamers.locals)
	local grounds: { [number]: Ground.Ground } = {}

	local folder = Instance.new("Folder")
	folder.Name = "FindPrompts"
	folder.Parent = workspace
	local spots: { Spot } = {}
	for _, find in Registry.list do
		if find.kind ~= "Sighting" and not find.pending then
			local at = placeOf(find, world, grounds)
			if at then
				table.insert(spots, makeSpot(folder, find, at))
			end
		end
	end

	local function refresh()
		local state = ClientState.get()
		if not state then
			return
		end
		local today = set(state.FindsToday)
		local claimed = set(state.Finds)
		for _, spot in spots do
			spot.prompt.Enabled = isOn(spot.find, state, today, claimed)
		end
	end
	ClientState.onChanged(refresh)
	refresh()

	-- Glints show only when the player is near.
	local sinceLook = 0
	RunService.Heartbeat:Connect(function(step)
		sinceLook += step
		if sinceLook < 0.5 then
			return
		end
		sinceLook = 0
		local character = Players.LocalPlayer.Character
		local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
		if not (root and root:IsA("BasePart")) then
			return
		end
		for _, spot in spots do
			local glint = spot.glint
			if glint then
				local flat = Vector3.new(
					spot.part.Position.X - root.Position.X,
					0,
					spot.part.Position.Z - root.Position.Z
				)
				glint.Enabled = spot.prompt.Enabled and flat.Magnitude <= FindsConfig.GLINT_DISTANCE
			end
		end
	end)

	-- Holding a prompt: send the find's id and nothing else.
	ProximityPromptService.PromptTriggered:Connect(function(prompt)
		if prompt:GetAttribute("PromptKind") ~= "Find" then
			return
		end
		local id = prompt:GetAttribute("PromptId")
		if typeof(id) == "string" then
			Net.Search.Fire({ FindId = id })
		end
	end)

	-- The card: what a search gave. It sits above the screens, like the notices.
	local cards = Kit.screen(playerGui, "FindCard", 48)
	cards.Enabled = true
	local card = Kit.panel(cards, UDim2.fromOffset(330, 0), UDim2.new(0.5, -165, 0, 104))
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.Visible = false
	local inner = Instance.new("Frame")
	inner.BackgroundTransparency = 1
	inner.Size = UDim2.fromScale(1, 0)
	inner.AutomaticSize = Enum.AutomaticSize.Y
	inner.Parent = card
	local stack = Instance.new("UIListLayout")
	stack.SortOrder = Enum.SortOrder.LayoutOrder
	stack.Padding = UDim.new(0, 4)
	stack.Parent = inner
	local padding = Instance.new("UIPadding")
	padding.PaddingTop, padding.PaddingBottom = UDim.new(0, 10), UDim.new(0, 10)
	padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 12), UDim.new(0, 12)
	padding.Parent = inner
	local shownAt = 0
	Bus.listen(Net.SearchResult, function(value)
		local title, lines = describe(value)
		for _, child in inner:GetChildren() do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end
		local head = textRow(inner, title, 20, Kit.COLOURS.gold, 1)
		head.Font = Kit.FONT_PIXEL
		for index, line in lines do
			textRow(inner, line, 16, nil, index + 1)
		end
		card.Visible = true
		Kit.pop(card)
		local mine = os.clock()
		shownAt = mine
		task.delay(CARD_SECONDS, function()
			if shownAt == mine then
				card.Visible = false
			end
		end)
	end)

	-- The journal: a button under the top bar, and a panel for the finds, pages and keepsakes.
	local hud = Kit.screen(playerGui, "FindsHud", 2)
	hud.Enabled = true
	local gui = Kit.screen(playerGui, "Journal", 7)
	local root = Kit.panel(gui, UDim2.fromScale(0.7, 0.9), UDim2.fromScale(0.15, 0.05))
	local title = Kit.label(root, "Journal", UDim2.new(1, -140, 0, 40), UDim2.fromOffset(14, 6), 26)
	title.TextXAlignment = Enum.TextXAlignment.Left
	local list = Instance.new("ScrollingFrame")
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 6
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Size = UDim2.new(1, -24, 1, -64)
	list.Position = UDim2.fromOffset(12, 52)
	list.Parent = root
	local rows = Instance.new("UIListLayout")
	rows.SortOrder = Enum.SortOrder.LayoutOrder
	rows.Padding = UDim.new(0, 6)
	rows.Parent = list
	Kit.roomForOutlines(list)
	local function close()
		gui.Enabled = false
	end
	local closeButton = Kit.button(root, "Close", Kit.COLOURS.bad, close)
	closeButton.Size = UDim2.fromOffset(96, 40)
	closeButton.Position = UDim2.new(1, -108, 0, 6)
	local open = Kit.button(hud, "Journal", Kit.COLOURS.gold, function()
		fillJournal(list, ClientState.get())
		gui.Enabled = true
		Kit.pop(root)
	end)
	open.Size = UDim2.fromOffset(116, 40)
	open.Position = UDim2.new(1, -126, 0, 68)
	ClientState.onChanged(function(state)
		if gui.Enabled then
			fillJournal(list, state)
		end
	end)
end

return FindsView
