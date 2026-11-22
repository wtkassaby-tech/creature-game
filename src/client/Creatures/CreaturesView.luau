--!strict
-- The creatures screen: everything the player owns, who is on the team, eggs in their pens,
-- and three things to do with a creature: put it on or take it off the team, breed it with
-- another, or release it. Also a small bar that is always on screen (coins, Prism Candy, and
-- the button that opens this screen). The server checks and decides every request.
-- TODO(art): a first cut, not yet seen in Studio; creatures are named, not drawn.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Breeding = require(ReplicatedStorage.shared.Breeding)
local Bus = require(script.Parent.Parent.Net.Bus)
local ClientState = require(script.Parent.Parent.State.ClientState)
local DailyTasks = require(ReplicatedStorage.content.DailyTasks)
local Economy = require(ReplicatedStorage.shared.Economy)
local Kit = require(script.Parent.Parent.UI.Kit)
local Net = require(ReplicatedStorage.net.generated.Client)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)
local Types = require(ReplicatedStorage.shared.Types)

local CreaturesView = {}

local taskGoals: { [string]: string } = {}
for _, task in DailyTasks do
	taskGoals[task.id] = task.goal
end

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

local function clock(seconds: number): string
	local left = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", left // 60, left % 60)
end

function CreaturesView.start(playerGui: Instance)
	-- The bar that is always there.
	local hud = Kit.screen(playerGui, "Hud", 2)
	hud.Enabled = true
	local bar = Kit.panel(hud, UDim2.fromOffset(330, 44), UDim2.new(1, -340, 0, 10))
	local wallet = Kit.label(bar, "", UDim2.new(1, -130, 1, -8), UDim2.fromOffset(10, 4))
	local notice = Kit.label(hud, "", UDim2.new(0.6, 0, 0, 28), UDim2.new(0.2, 0, 0, 62), 20)
	notice.TextXAlignment = Enum.TextXAlignment.Center
	notice.TextStrokeTransparency = 0.3

	local gui = Kit.screen(playerGui, "Creatures", 6)
	-- What the button does is set further down, once the list can be rebuilt.
	local open = Kit.button(bar, "Creatures", Kit.COLOURS.accent, function() end)
	open.Size = UDim2.new(0, 110, 1, -8)
	open.Position = UDim2.new(1, -116, 0, 4)

	local root = Kit.panel(gui, UDim2.fromScale(0.86, 0.84), UDim2.fromScale(0.07, 0.1))
	local title = Kit.label(root, "", UDim2.new(1, -120, 0, 30), UDim2.fromOffset(14, 8), 24)
	local close = Kit.button(root, "Close", Kit.COLOURS.bad, function()
		gui.Enabled = false
	end)
	close.Size = UDim2.fromOffset(90, 32)
	close.Position = UDim2.new(1, -104, 0, 8)
	local eggs = Kit.label(root, "", UDim2.new(1, -28, 0, 22), UDim2.fromOffset(14, 42), 18)
	eggs.TextColor3 = Kit.COLOURS.textDim

	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.new(1, -28, 1, -176)
	list.Position = UDim2.fromOffset(14, 70)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 6
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new()
	list.Parent = root
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = list

	-- The breeding strip at the bottom: the two chosen parents, what it costs, and the odds.
	local breed =
		Kit.panel(root, UDim2.new(1, -28, 0, 92), UDim2.new(0, 14, 1, -100), Kit.COLOURS.panelLight)
	local breedText = Kit.label(
		breed,
		"Pick two creatures to breed",
		UDim2.new(1, -150, 1, -8),
		UDim2.fromOffset(10, 4),
		18
	)
	breedText.TextWrapped = true
	local parents: { string } = {}
	local breedButton = Kit.button(breed, "Breed", Kit.COLOURS.good, function()
		if #parents == 2 then
			Net.RequestBreed.Fire({
				ParentA = parents[1],
				ParentB = parents[2],
				CharmSlot = nil,
				CharmFavour = nil,
			})
		end
	end)
	breedButton.Size = UDim2.fromOffset(120, 44)
	breedButton.Position = UDim2.new(1, -130, 0, 8)
	local clearButton = Kit.button(breed, "Clear", Kit.COLOURS.panel, function() end)
	clearButton.Size = UDim2.fromOffset(120, 30)
	clearButton.Position = UDim2.new(1, -130, 0, 56)

	local confirmRelease: string? = nil
	local rebuild: () -> ()

	local function say(text: string)
		notice.Text = text
		task.delay(4, function()
			if notice.Text == text then
				notice.Text = ""
			end
		end)
	end

	local function showBreeding(state: Snapshot.State)
		local chosen: { Types.Creature } = {}
		for _, id in parents do
			for _, view in state.Creatures do
				if view.Id == id then
					table.insert(chosen, record(view))
				end
			end
		end
		breedButton.Visible = #chosen == 2
		if #chosen == 0 then
			breedText.Text = "Pick two creatures to breed"
		elseif #chosen == 1 then
			breedText.Text = `{chosen[1].parts.Torso.species} and... pick a second creature`
		else
			local a, b = chosen[1], chosen[2]
			local ok, why = Breeding.canBreed(a, b, os.time())
			if not ok then
				breedButton.Visible = false
				breedText.Text = why or "Those two cannot breed"
				return
			end
			local candy: { string } = {}
			for _, need in Breeding.candyCost(a, b) do
				table.insert(candy, `{need.amount} {need.element}`)
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
			breedText.Text = `{a.parts.Torso.species} + {b.parts.Torso.species}\n`
				.. `Cost: {Breeding.cost(a, b)} coins, candy: {table.concat(candy, " + ")}\n`
				.. `Child: {table.concat(odds, ", ")}`
		end
	end

	rebuild = function()
		local state = ClientState.get()
		if not state then
			return
		end
		wallet.Text = `{state.Coins} coins   {math.floor(state.Candy.Prism)} Prism`
		if not gui.Enabled then
			return
		end
		title.Text = `Creatures {#state.Creatures}/{state.StableCapacity}   Team {#state.Team}`
		local eggLines: { string } = {}
		for _, egg in state.Eggs do
			local left = egg.HatchAt - os.time()
			table.insert(eggLines, if left > 0 then `egg {clock(left)}` else "egg ready")
		end
		eggs.Text = `Pens {#state.Eggs}/{state.Pens}: {if #eggLines > 0
			then table.concat(eggLines, ", ")
			else "empty"}` .. `   Candy: Leaf {math.floor(state.Candy.Leaf)}, Sand {math.floor(
			state.Candy.Sand
		)}, Water {math.floor(state.Candy.Water)}`

		for _, child in list:GetChildren() do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
		-- Today's tasks come first (they appear with the first badge).
		for _, task in state.Daily do
			local goal = taskGoals[task.Id] or task.Id
			local row = Kit.panel(list, UDim2.new(1, -8, 0, 40), UDim2.new(), Kit.COLOURS.panel)
			local text =
				`{if task.Hard then "Hard task" else "Daily task"}: {goal}  {task.Progress}/{task.Count}`
			Kit.label(row, text, UDim2.new(0.74, 0, 1, -8), UDim2.fromOffset(10, 4))
			if task.Claimed then
				local done =
					Kit.label(row, "Claimed", UDim2.new(0.2, 0, 1, -8), UDim2.new(0.78, 0, 0, 4))
				done.TextColor3 = Kit.COLOURS.textDim
			elseif task.Progress >= task.Count then
				local claim = Kit.button(row, "Claim", Kit.COLOURS.good, function()
					Net.ClaimDailyTask.Fire({ TaskId = task.Id })
				end)
				claim.Size = UDim2.new(0.2, 0, 1, -8)
				claim.Position = UDim2.new(0.78, 0, 0, 4)
			end
		end
		for _, view in state.Creatures do
			local onTeam = table.find(state.Team, view.Id)
			local row =
				Kit.panel(list, UDim2.new(1, -8, 0, 46), UDim2.new(), Kit.COLOURS.panelLight)
			local health = if view.Hurt >= 1
				then "fainted"
				else `{math.floor((1 - view.Hurt) * 100 + 0.5)}% health`
			local text =
				`{if onTeam then `[{onTeam}] ` else ""}{view.Torso.Species}  Lv {view.Level}  {view.Rarity}  {health}`
			local name = Kit.label(row, text, UDim2.new(0.4, 0, 1, -8), UDim2.fromOffset(10, 4))
			if view.Hurt > 0 then
				name.TextColor3 = Kit.healthColour(1 - view.Hurt)
				-- Treat with what fits: a Rally Root if it has fainted, otherwise a tonic.
				local item: ("Tonic" | "GreatTonic" | "Revive")? = nil
				if view.Hurt >= 1 then
					item = if (state.Items.Revive or 0) > 0 then "Revive" else nil
				elseif (state.Items.Tonic or 0) > 0 then
					item = "Tonic"
				elseif (state.Items.GreatTonic or 0) > 0 then
					item = "GreatTonic"
				end
				if item then
					local chosenItem: "Tonic" | "GreatTonic" | "Revive" = item
					local treat = Kit.button(
						row,
						if item == "Revive" then "Rally Root" else "Tonic",
						Kit.COLOURS.good,
						function()
							Net.TreatCreature.Fire({ Item = chosenItem, CreatureId = view.Id })
						end
					)
					treat.Size = UDim2.new(0.1, 0, 1, -10)
					treat.Position = UDim2.new(0.41, 0, 0, 5)
				end
			end

			local team = Kit.button(
				row,
				if onTeam then "Off team" else "To team",
				Kit.COLOURS.accent,
				function()
					local ids = table.clone(state.Team)
					if onTeam then
						table.remove(ids, onTeam)
					else
						table.insert(ids, view.Id)
					end
					if #ids >= 1 and #ids <= 6 then
						Net.SetTeam.Fire({ Ids = ids })
					end
				end
			)
			team.Size = UDim2.new(0.15, 0, 1, -10)
			team.Position = UDim2.new(0.52, 0, 0, 5)

			local chosen = table.find(parents, view.Id)
			local pick = Kit.button(
				row,
				if chosen then "Chosen" else "Breed",
				if chosen then Kit.COLOURS.good else Kit.COLOURS.panel,
				function()
					if chosen then
						table.remove(parents, chosen)
					elseif #parents < 2 then
						table.insert(parents, view.Id)
					end
					rebuild()
				end
			)
			pick.Size = UDim2.new(0.14, 0, 1, -10)
			pick.Position = UDim2.new(0.68, 0, 0, 5)

			-- Releasing asks twice: the first tap arms the button, the second releases.
			local armed = confirmRelease == view.Id
			local release = Kit.button(
				row,
				if armed then "Sure?" else "Release",
				Kit.COLOURS.bad,
				function()
					if armed then
						confirmRelease = nil
						Net.ReleaseCreature.Fire({ Id = view.Id })
					else
						confirmRelease = view.Id
						rebuild()
					end
				end
			)
			release.Size = UDim2.new(0.15, 0, 1, -10)
			release.Position = UDim2.new(0.83, 0, 0, 5)
		end
		showBreeding(state)
	end

	clearButton.Activated:Connect(function()
		parents = {}
		rebuild()
	end)
	-- Open and fill in one step: as two separate handlers the list was filled before the screen
	-- opened, so it came up empty (first Studio run).
	open.Activated:Connect(function()
		gui.Enabled = not gui.Enabled
		confirmRelease = nil
		rebuild()
	end)

	ClientState.onChanged(function()
		rebuild()
	end)
	Bus.listen(Net.BreedResult, function(value)
		if value.Ok then
			parents = {}
			say(`An egg! It hatches in {clock(value.HatchAt - os.time())}`)
		else
			say(value.Reason)
		end
		rebuild()
	end)
	Bus.listen(Net.ReleaseResult, function(value)
		say(
			if value.Ok
				then `Released: +{value.Coins} coins, +{value.Candy} {value.Element or ""} candy`
				else value.Reason
		)
	end)
	Bus.listen(Net.Hatched, function(value)
		say(`{#value.Ids} egg{if #value.Ids > 1 then "s" else ""} hatched!`)
	end)
	Bus.listen(Net.Notice, function(value)
		say(value.Text)
	end)
	Bus.listen(Net.BattleRefused, function(value)
		say(value.Reason)
	end)

	-- Egg timers tick while the screen is open.
	task.spawn(function()
		while true do
			task.wait(1)
			if gui.Enabled then
				local state = ClientState.get()
				if state and #state.Eggs > 0 then
					rebuild()
				end
			end
		end
	end)
end

return CreaturesView
