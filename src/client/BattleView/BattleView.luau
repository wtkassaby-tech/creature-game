--!strict
-- The battle screen: both creatures' health, the four moves with the damage each would do, and
-- the lasso, items, switch and run. It only shows what the server sent and sends the player's
-- one choice a turn; the server decides everything.
-- The creatures stand in the world (BattleStage) with the camera behind the player's own; this
-- screen is kept slim so they are what the player looks at.
-- Over 400 lines: it is one screen, kept whole so its layout reads top to bottom. The move
-- buttons, the hit effects and the result panel live in their own modules beside this one.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Coach = require(ReplicatedStorage.shared.Coach)
local ClientState = require(script.Parent.Parent.State.ClientState)
local MovementLock = require(script.Parent.Parent.UI.MovementLock)
local BattleFx = require(script.Parent.BattleFx)
local BattleStage = require(script.Parent.BattleStage)
local Portrait = require(script.Parent.Parent.Creatures.Portrait)
local Kit = require(script.Parent.Parent.UI.Kit)
local MoveButton = require(script.Parent.MoveButton)
local Moves = require(ReplicatedStorage.content.Moves)
local ResultPanel = require(script.Parent.ResultPanel)
local Sfx = require(script.Parent.Parent.Audio.Sfx)
local TypeChart = require(ReplicatedStorage.shared.TypeChart)
local Types = require(ReplicatedStorage.shared.Types)
local LassoView = require(script.Parent.Parent.Lasso.LassoView)
local Bus = require(script.Parent.Parent.Net.Bus)
local Net = require(ReplicatedStorage.net.generated.Client)

-- The pause between the things that happen in a turn. Slow battles are the commonest complaint
-- about games of this kind, so there is a fast setting, and a tap anywhere hurries the turn
-- being shown.
local EVENT_SECONDS = 0.7
local FAST_EVENT_SECONDS = 0.35
local HURRIED_EVENT_SECONDS = 0.12

type Fighter = {
	name: string,
	element: Types.Element,
	size: number,
	level: number,
	hp: number,
	maxHp: number,
	moves: { string },
	poisoned: boolean?,
}
type Model = {
	battleId: number,
	wild: boolean,
	kind: string, -- Wild, Tamer, Rival or Friendly: the coach only speaks in the first rival bout
	foeRarity: string, -- the first foe's rarity, for the lasso coach
	teamBefore: number?, -- how many were on the team before this battle, for the catch card
	strongTold: boolean, -- the coach has already praised a strong hit this battle
	caughtFoe: Fighter?, -- the creature that was caught, for the "New friend" card
	sides: { { Fighter } }, -- 1 = yours, 2 = theirs
	active: { number },
	tempo: { number },
	nextTurn: number,
	previews: { number },
	waiting: boolean, -- a choice has been sent and the server has not answered yet
	over: boolean,
	caught: boolean,
	outcome: number?, -- set when the last turn has been shown
	rewards: ResultPanel.Rewards?, -- may arrive before the last turn has been shown
}

local BattleView = {}

local OUTCOME_KIND: { [number]: ResultPanel.Kind } = { [0] = "Draw", [1] = "Won", [2] = "Lost" }

function BattleView.start(playerGui: Instance)
	local gui = Kit.screen(playerGui, "Battle", 10)
	-- No walking during a battle: in the first Studio run a long-grass battle followed the
	-- player all the way back to town.
	MovementLock.whileOpen(gui)
	local model: Model? = nil

	local fx = BattleFx.new(gui)
	local stage = BattleStage.new()
	local staged: { number } = { 0, 0 } -- which team place is standing on each pad
	local fast = false -- the speed the player chose, kept for this visit only
	local hurried = false -- a tap during a turn: finish showing it quickly

	-- A tap anywhere that is not a button hurries the turn being shown. Made first, so every
	-- button sits above it.
	local hurry = Instance.new("TextButton")
	hurry.Size = UDim2.fromScale(1, 1)
	hurry.BackgroundTransparency = 1
	hurry.Text = ""
	hurry.ZIndex = 0
	hurry.Parent = gui
	hurry.Activated:Connect(function()
		hurried = true
	end)

	-- The two creature plates, slim and see-through: name and level, a small chip in the colour
	-- of the type, the health bar with its numbers under it, and the tempo meter.
	type Card = {
		panel: Frame,
		name: TextLabel,
		chip: TextLabel,
		numbers: TextLabel,
		health: Kit.Bar,
		tempo: Kit.Bar,
		species: string?, -- whose cutout is behind the text now
		cutout: ViewportFrame?,
	}
	local function card(position: UDim2): Card
		local panel = Kit.panel(gui, UDim2.new(0.3, 0, 0, 72), position)
		panel.ClipsDescendants = true -- the cutout behind the text runs off the plate's edge
		local name = Kit.label(panel, "", UDim2.new(1, -90, 0, 24), UDim2.fromOffset(12, 5), 24)
		local chip = Kit.label(panel, "", UDim2.fromOffset(66, 18), UDim2.new(1, -76, 0, 8), 13)
		chip.TextXAlignment = Enum.TextXAlignment.Center
		chip.TextColor3 = Kit.COLOURS.white
		chip.BackgroundTransparency = 0
		local chipCorner = Instance.new("UICorner")
		chipCorner.CornerRadius = UDim.new(0.5, 0)
		chipCorner.Parent = chip
		local tag = Kit.label(panel, "HP", UDim2.fromOffset(24, 12), UDim2.fromOffset(12, 34), 12)
		tag.TextColor3 = Kit.COLOURS.gold
		local health =
			Kit.bar(panel, UDim2.new(1, -50, 0, 10), UDim2.fromOffset(38, 35), Kit.COLOURS.good)
		local tempo =
			Kit.bar(panel, UDim2.new(0.45, 0, 0, 5), UDim2.fromOffset(12, 56), Kit.COLOURS.tempo)
		local numbers =
			Kit.label(panel, "", UDim2.new(0.5, -12, 0, 16), UDim2.new(0.5, 0, 0, 50), 14)
		numbers.TextXAlignment = Enum.TextXAlignment.Right
		numbers.TextColor3 = Kit.COLOURS.textDim
		return {
			panel = panel,
			name = name,
			chip = chip,
			numbers = numbers,
			health = health,
			tempo = tempo,
			species = nil,
			cutout = nil,
		}
	end
	-- 1 = yours (left, beside your creature), 2 = theirs (upper right, beside theirs), matching
	-- the sides in the model and where the camera puts the two creatures.
	local cards: { Card } = { card(UDim2.fromScale(0.03, 0.3)), card(UDim2.fromScale(0.67, 0.2)) }
	-- The bottom of the screen, as in the old handheld games: a text box that says what is
	-- happening, with the menu beside it (FIGHT, LASSO, ITEMS, SWITCH, RUN). FIGHT swaps both for
	-- the four moves.
	local box = Kit.panel(gui, UDim2.fromScale(0.56, 0.26), UDim2.fromScale(0.02, 0.72))
	box.ClipsDescendants = true
	local boxCutout: ViewportFrame? = nil
	local boxSpecies: string? = nil
	local message = Kit.label(box, "", UDim2.new(1, -32, 1, -20), UDim2.fromOffset(16, 10), 22)
	message.TextWrapped = true
	message.TextYAlignment = Enum.TextYAlignment.Top
	Kit.pixel(message, 22)
	local menu = Kit.panel(gui, UDim2.fromScale(0.38, 0.26), UDim2.fromScale(0.6, 0.72))
	local side = Instance.new("Frame")
	side.Size = UDim2.new(1, -16, 1, -16)
	side.Position = UDim2.fromOffset(8, 8)
	side.BackgroundTransparency = 1
	side.Parent = menu
	local sideGrid = Instance.new("UIGridLayout")
	sideGrid.CellSize = UDim2.new(0.333, -6, 0.5, -4)
	sideGrid.CellPadding = UDim2.fromOffset(8, 8)
	sideGrid.SortOrder = Enum.SortOrder.LayoutOrder
	sideGrid.Parent = side
	local actions = Kit.panel(gui, UDim2.fromScale(0.96, 0.26), UDim2.fromScale(0.02, 0.72))
	actions.Visible = false
	local moves = Instance.new("Frame")
	moves.Size = UDim2.new(0.84, -12, 1, -16)
	moves.Position = UDim2.fromOffset(8, 8)
	moves.BackgroundTransparency = 1
	moves.Parent = actions
	local moveGrid = Instance.new("UIGridLayout")
	moveGrid.CellSize = UDim2.new(0.5, -4, 0.5, -4)
	moveGrid.CellPadding = UDim2.fromOffset(8, 8)
	moveGrid.Parent = moves
	local choosingMove = false -- FIGHT was pressed: the four moves are showing

	-- A list of choices over the bottom panel (which lasso, which item, who to switch to).
	local picker = Kit.panel(
		gui,
		UDim2.fromScale(0.6, 0.5),
		UDim2.fromScale(0.2, 0.14),
		Kit.COLOURS.panelLight
	)
	picker.Visible = false
	picker.ZIndex = 5
	local pickerList = Instance.new("UIListLayout")
	pickerList.Padding = UDim.new(0, 6)
	pickerList.Parent = picker
	local pickerPad = Instance.new("UIPadding")
	pickerPad.PaddingTop, pickerPad.PaddingLeft, pickerPad.PaddingRight =
		UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 8)
	pickerPad.Parent = picker

	local lasso = LassoView.new(gui)
	local refresh: () -> ()

	local function send(make: (current: Model) -> ())
		local current = model
		if not current or current.waiting or current.over then
			return
		end
		current.waiting = true
		picker.Visible = false
		make(current)
		refresh()
	end

	local function choose(options: { { text: string, pick: () -> () } })
		for _, child in picker:GetChildren() do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		for _, option in options do
			local button = Kit.button(picker, option.text, Kit.COLOURS.panel, option.pick)
			button.Size = UDim2.new(1, 0, 0, 44)
			button.ZIndex = 6
		end
		local close = Kit.button(picker, "Back", Kit.COLOURS.bad, function()
			picker.Visible = false
		end)
		close.Size = UDim2.new(1, 0, 0, 40)
		close.ZIndex = 6
		-- Only as tall as its rows, and sitting just above the bottom panels, so the two
		-- creatures stay in view behind it.
		local tall = 16 + #options * 50 + 46
		picker.Size = UDim2.new(0.44, 0, 0, tall)
		picker.Position = UDim2.new(0.28, 0, 0.68, -tall)
		picker.Visible = true
	end

	local function held(item: string): number
		local state = ClientState.get()
		return if state then state.Items[item] or 0 else 0
	end

	local moveButtons: { MoveButton.View } = {}
	for index = 1, 4 do
		moveButtons[index] = MoveButton.new(moves, function()
			send(function(current)
				Net.BattleAction.Fire({
					BattleId = current.battleId,
					Turn = current.nextTurn,
					Kind = "Move",
					Index = index,
				})
			end)
		end)
	end

	local refreshMenu: () -> ()
	local fightButton = Kit.button(side, "FIGHT", Kit.COLOURS.bad, function()
		choosingMove = true
		refreshMenu()
	end)
	fightButton.LayoutOrder = 1
	local backButton = Kit.button(actions, "BACK", Kit.COLOURS.panelLight, function()
		choosingMove = false
		refreshMenu()
	end)
	backButton.Size = UDim2.new(0.16, -4, 1, -16)
	backButton.Position = UDim2.new(0.84, 0, 0, 8)

	local lassoButton: TextButton
	-- The coach's gentle nudge: LASSO swells and settles slowly while the foe is tired.
	local lassoScale = Instance.new("UIScale")
	local pulse = TweenService:Create(
		lassoScale,
		TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Scale = 1.06 }
	)
	local pulsing = false
	local function setPulse(on: boolean)
		if on == pulsing then
			return
		end
		pulsing = on
		if on then
			pulse:Play()
		else
			pulse:Cancel()
			lassoScale.Scale = 1
		end
	end
	lassoButton = Kit.button(side, "LASSO", Kit.COLOURS.lasso, function()
		local options = {}
		for _, tier in { "Basic", "Braided", "Gilded" } do
			if held(tier) > 0 then
				table.insert(options, {
					text = `{tier} lasso x{held(tier)}`,
					pick = function()
						send(function(current)
							Net.ThrowLasso.Fire({
								BattleId = current.battleId,
								Turn = current.nextTurn,
								Tier = tier :: any,
							})
						end)
					end,
				})
			end
		end
		if #options == 1 then
			options[1].pick() -- one kind of lasso: nothing to choose, so throw it
		elseif #options == 0 then
			choose({ { text = "No lassos left. The shop sells them.", pick = function() end } })
		else
			choose(options)
		end
	end)
	lassoButton.LayoutOrder = 2
	lassoScale.Parent = lassoButton
	local itemsButton = Kit.button(side, "ITEMS", Kit.COLOURS.good, function()
		local current = model
		if not current then
			return
		end
		local options = {}
		local function offer(item: string, label: string, target: number?)
			if held(item) > 0 and target then
				table.insert(options, {
					text = `{label} x{held(item)}`,
					pick = function()
						send(function(now)
							Net.UseItem.Fire({
								BattleId = now.battleId,
								Turn = now.nextTurn,
								Item = item :: any,
								Target = target,
							})
						end)
					end,
				})
			end
		end
		local fallen: number? = nil
		for index, fighter in current.sides[1] do
			if fighter.hp <= 0 and not fallen then
				fallen = index
			end
		end
		offer("Tonic", "Field Tonic", current.active[1])
		offer("GreatTonic", "Deep Tonic", current.active[1])
		offer("Revive", "Rally Root", fallen)
		local poisoned = current.sides[1][current.active[1]]
		if poisoned and poisoned.poisoned then
			offer("Cure", "Clearwater Drops", current.active[1])
		end
		choose(options)
	end)
	itemsButton.LayoutOrder = 3
	local switchButton = Kit.button(side, "SWITCH", Kit.COLOURS.accent, function()
		local current = model
		if not current then
			return
		end
		local options = {}
		for index, fighter in current.sides[1] do
			if index ~= current.active[1] and fighter.hp > 0 then
				table.insert(options, {
					text = `{fighter.name} Lv {fighter.level}  {fighter.hp}/{fighter.maxHp}`,
					pick = function()
						send(function(now)
							Net.BattleAction.Fire({
								BattleId = now.battleId,
								Turn = now.nextTurn,
								Kind = "Switch",
								Index = index,
							})
						end)
					end,
				})
			end
		end
		choose(options)
	end)
	switchButton.LayoutOrder = 4
	local runButton = Kit.button(side, "RUN", Kit.COLOURS.panelLight, function()
		send(function(current)
			Net.BattleAction.Fire({
				BattleId = current.battleId,
				Turn = current.nextTurn,
				Kind = "Run",
				Index = 0,
			})
		end)
	end)

	-- Shown when the battle ends.
	local result: ResultPanel.View
	result = ResultPanel.new(gui, function()
		gui.Enabled = false
		result.hide()
		stage.close()
		model = nil
	end)

	-- A small switch for battle speed, tucked under the wallet.
	local speed: TextButton
	speed = Kit.button(gui, "Speed: normal", Kit.COLOURS.panelLight, function()
		fast = not fast
		speed.Text = if fast then "Speed: fast" else "Speed: normal"
	end)
	speed.Size = UDim2.fromOffset(150, 44)
	speed.Position = UDim2.fromOffset(10, 10) -- top left: the quest tracker is hidden in a battle

	-- The end panel appears once the last turn has been shown; rewards join it when they arrive.
	local function showEnd(current: Model)
		if current.outcome == nil then
			return
		end
		local kind: ResultPanel.Kind = if current.caught
			then "Caught"
			else OUTCOME_KIND[current.outcome] or "Draw"
		local caught: ResultPanel.Caught? = nil
		local foe = current.caughtFoe
		if kind == "Caught" and foe then
			caught = {
				name = foe.name,
				element = foe.element,
				level = foe.level,
				placement = Coach.placementLine(current.teamBefore),
			}
		end
		result.show(kind, current.rewards, caught)
	end

	-- A flat, faded picture of a creature, set behind the text of a box that is about it.
	local function cutout(
		parent: Instance,
		fighter: Fighter,
		across: number,
		fade: number
	): ViewportFrame
		local picture = Portrait.new(
			parent,
			fighter.name,
			fighter.element,
			UDim2.fromOffset(across, across),
			UDim2.new(1, -across * 0.92, 0.5, -across * 0.5)
		)
		picture.ImageTransparency = fade
		picture.ZIndex = 0 -- behind everything else in the box
		return picture
	end

	local function showCard(shown: Card, fighter: Fighter, tempoShare: number)
		if shown.species ~= fighter.name then
			local old = shown.cutout
			if old then
				old:Destroy()
			end
			shown.species = fighter.name
			shown.cutout = cutout(shown.panel, fighter, 130, 0.5)
		end
		shown.name.Text = `{fighter.name}  Lv {fighter.level}`
		shown.chip.Text = fighter.element
		shown.chip.BackgroundColor3 = Kit.ELEMENT_COLOURS[fighter.element]
		shown.numbers.Text = `{fighter.hp} / {fighter.maxHp}`
		local share = fighter.hp / math.max(1, fighter.maxHp)
		shown.health.set(share, Kit.healthColour(share))
		shown.tempo.set(tempoShare)
	end

	-- The story beats the player has seen (display only; the server owns them).
	local function coachFlags(): { string }
		local state = ClientState.get()
		return if state then state.Flags else {}
	end

	refresh = function()
		local current = model
		if not current then
			return
		end
		local mine, foe = current.sides[1][current.active[1]], current.sides[2][current.active[2]]
		if mine then
			showCard(cards[1], mine, current.tempo[1] / 100)
			if boxSpecies ~= mine.name then
				if boxCutout then
					boxCutout:Destroy()
				end
				boxSpecies = mine.name
				boxCutout = cutout(box, mine, 230, 0.6)
			end
		end
		if foe then
			showCard(cards[2], foe, current.tempo[2] / 100)
		end
		-- Whoever is out now stands on the pad (a switch, or the next one in after a faint).
		for pad = 1, 2 do
			local fighter = if pad == 1 then mine else foe
			if fighter and fighter.hp > 0 and staged[pad] ~= current.active[pad] then
				staged[pad] = current.active[pad]
				stage.swap(
					pad,
					{ species = fighter.name, element = fighter.element, size = fighter.size }
				)
			end
		end
		local open = not current.waiting and not current.over
		for index, button in moveButtons do
			local move = if mine then mine.moves[index] else nil
			button.show(move, current.previews[index], if foe then foe.element else nil, open)
		end
		lassoButton.Visible = current.wild
		-- Three choices against a tamer fill one tall row; five against a wild creature take two.
		sideGrid.CellSize = if current.wild
			then UDim2.new(0.333, -6, 0.5, -4)
			else UDim2.new(0.333, -6, 1, 0)
		runButton.Visible = current.wild
		if not open then
			choosingMove = false -- a choice was made, or the battle ended
		end
		box.Visible = not current.over and not choosingMove
		menu.Visible = open and not choosingMove
		actions.Visible = open and choosingMove
		-- The coach, when it has something to say, takes the place of "What will X do?". It only
		-- shows words; no button is ever hidden or blocked by it.
		local flags = coachFlags()
		local line: string? = nil
		if open and not choosingMove and mine and foe then
			line = Coach.firstBattleLine(flags, current.kind, mine.moves, foe.element)
				or Coach.lassoLine(flags, current.wild, foe.hp, foe.maxHp)
		end
		if open and not choosingMove and mine then
			message.Text = line or `What will {mine.name} do?`
		end
		setPulse(
			open
				and not choosingMove
				and foe ~= nil
				and Coach.lassoNudge(flags, current.wild, foe.hp, foe.maxHp)
		)
	end

	refreshMenu = refresh

	-- A fainted creature does not lead: the battle opens with the first one still standing.
	local function firstStanding(list: { any }): number
		for index, c in list do
			if c.Hp > 0 then
				return index
			end
		end
		return 1
	end

	local function fighters(list: { any }): { Fighter }
		local made: { Fighter } = {}
		for _, c in list do
			table.insert(made, {
				name = c.Torso,
				element = c.Element,
				size = c.Size,
				level = c.Level,
				hp = c.Hp,
				maxHp = c.MaxHp,
				moves = c.Moves,
			})
		end
		return made
	end

	Bus.listen(Net.BattleStarted, function(value)
		local state = ClientState.get()
		model = {
			battleId = value.BattleId,
			wild = value.Kind == "Wild",
			kind = value.Kind :: string,
			foeRarity = value.Theirs[1].Rarity :: string,
			teamBefore = if state then #state.Team else nil,
			strongTold = false,
			caughtFoe = nil,
			sides = { fighters(value.Yours), fighters(value.Theirs) },
			active = { firstStanding(value.Yours), firstStanding(value.Theirs) },
			tempo = { 0, 0 },
			nextTurn = 1,
			previews = value.Previews,
			waiting = false,
			over = false,
			caught = false,
			outcome = nil,
			rewards = nil,
		}
		message.Text = if value.Kind == "Wild"
			then `A wild {value.Theirs[1].Torso} appears!`
			else "The battle begins!"
		picker.Visible = false
		result.hide()
		lasso.finish()
		gui.Enabled = true
		local current = model
		local mine = current and current.sides[1][current.active[1]]
		local foe = current and current.sides[2][current.active[2]]
		if current and mine and foe then
			staged = { current.active[1], current.active[2] }
			stage.open(
				{ species = mine.name, element = mine.element, size = mine.size },
				{ species = foe.name, element = foe.element, size = foe.size }
			)
		end
		refresh()
		Kit.pop(cards[1].panel)
		Kit.pop(cards[2].panel)
		fx.callout(if value.Kind == "Wild" then "WILD!" else "BATTLE!", Kit.COLOURS.gold)
		Sfx.play("swap")
	end)

	Bus.listen(Net.BattleTurn, function(value)
		local current = model
		if not current or current.battleId ~= value.BattleId then
			return
		end
		-- Play the turn back one thing at a time.
		hurried = false
		for _, event in value.Events do
			local actor = event.Side
			local other = if actor == 1 then 2 else 1
			local who = current.sides[actor][current.active[actor]]
			if event.Kind == "Move" or event.Kind == "FollowUp" then
				local struck = current.sides[other][current.active[other]]
				local def = if event.Move then Moves[event.Move] else nil
				local factor = if def and struck
					then TypeChart.multiplier(def.element, struck.element)
					else 1
				if struck then
					struck.hp = event.TargetHp
				end
				message.Text = `{if who then who.name else "It"} used {event.Move or "a move"}!`
				stage.lunge(actor)
				if event.Damage > 0 then
					local hurt = `-{event.Damage}`
					if factor > 1 then
						stage.hit(other, true)
						fx.rise(stage.point(other), hurt, Kit.COLOURS.gold, true)
						fx.callout("STRONG HIT!", Kit.COLOURS.gold)
						Sfx.play("strongHit")
						-- Praise the player's first strong hit in the first battle, once.
						local praise = if actor == 1 and not current.strongTold
							then Coach.strongHitLine(coachFlags(), current.kind)
							else nil
						if praise then
							current.strongTold = true
							message.Text = `{message.Text}\n{praise}`
						end
					elseif factor < 1 then
						stage.hit(other, false)
						fx.rise(stage.point(other), hurt, Kit.COLOURS.textDim, false)
						Sfx.play("weakHit")
					else
						stage.hit(other, false)
						fx.rise(stage.point(other), hurt, Kit.COLOURS.white, false)
						Sfx.play("hit")
					end
				end
			elseif event.Kind == "Switch" then
				current.active[actor] = event.Slot
				local entered = current.sides[actor][event.Slot]
				message.Text = `{if entered then entered.name else "A creature"} steps in`
				Kit.pop(cards[actor].panel)
				Sfx.play("swap")
			elseif event.Kind == "Faint" then
				local fallen = current.sides[actor][event.Slot]
				if fallen then
					fallen.hp = 0
					fallen.poisoned = false
					message.Text = `{fallen.name} fainted`
					stage.faint(actor)
					Sfx.play("faint")
				end
			elseif event.Kind == "Poisoned" then
				local victim = current.sides[actor][event.Slot]
				if victim then
					victim.poisoned = true
				end
				message.Text = `{if victim then victim.name else "It"} is poisoned!`
			elseif event.Kind == "Poison" then
				local victim = current.sides[actor][event.Slot]
				if victim then
					victim.hp = event.TargetHp
					message.Text = `{victim.name} is hurt by poison`
					fx.rise(stage.point(actor), "poison", Kit.ELEMENT_COLOURS.Toxic, false)
				end
			elseif event.Kind == "Cured" then
				local victim = current.sides[actor][event.Slot]
				if victim then
					victim.poisoned = false
				end
				message.Text = `{if victim then victim.name else "It"} shook off the poison`
			elseif event.Kind == "Endure" then
				local holding = current.sides[actor][event.Slot]
				if holding then
					holding.hp = event.TargetHp
					current.active[actor] = event.Slot
					message.Text = `{holding.name} holds on!`
				end
			elseif event.Kind == "Item" then
				local treated = current.sides[actor][event.Slot]
				if treated then
					treated.hp = event.TargetHp
					message.Text = `{treated.name} was treated`
					fx.rise(stage.point(actor), "healed", Kit.COLOURS.good, false)
					Sfx.play("confirm")
				end
			end
			refresh()
			task.wait(
				if hurried
					then HURRIED_EVENT_SECONDS
					elseif fast then FAST_EVENT_SECONDS
					else EVENT_SECONDS
			)
		end
		current.active = { value.YourActive, value.TheirActive }
		current.tempo = { value.YourTempo, value.TheirTempo }
		current.previews = value.Previews
		current.nextTurn = value.Turn + 1
		current.waiting = false
		if value.Finished then
			current.over = true
			current.outcome = value.Outcome
			showEnd(current)
		end
		refresh()
	end)

	Bus.listen(Net.BattleRefused, function(value)
		local current = model
		if current and gui.Enabled then
			current.waiting = false
			message.Text = value.Reason
			refresh()
		end
	end)

	Bus.listen(Net.BattleRewards, function(value)
		local current = model
		if not current or current.battleId ~= value.BattleId then
			return
		end
		local xp = 0
		local levels: { number } = {}
		for _, member in value.Members do
			xp = math.max(xp, member.Gained)
			if member.LevelsGained > 0 then
				table.insert(levels, member.Level)
			end
		end
		current.rewards =
			{ coins = value.Coins, xp = xp, material = value.Material, levels = levels }
		showEnd(current)
	end)

	Bus.listen(Net.LassoPattern, function(value)
		-- A sweep for another screen's battle (a giant capture) is not ours to play.
		local current = model
		if current and current.battleId == value.BattleId then
			message.Text = "Swing..."
			lasso.begin(value)
		end
	end)
	Bus.listen(Net.LassoResult, function(value)
		lasso.finish()
		if value.Outcome == "Caught" then
			fx.callout("GOT IT!", Kit.COLOURS.gold)
		end
		local current = model
		-- Only a Common creature is promised not to run off after a miss; others get the old line.
		local missed = "It slipped the rope!"
		if current and value.Outcome == "Missed" then
			missed = Coach.missLine(current.foeRarity) or missed
		end
		message.Text = if value.Outcome == "Caught"
			then "Caught!"
			elseif value.Outcome == "Fled" then "It broke free and fled!"
			else missed
		if current and value.Outcome == "Caught" then
			current.caught = true
			current.caughtFoe = current.sides[2][current.active[2]]
		end
	end)
end

return BattleView
