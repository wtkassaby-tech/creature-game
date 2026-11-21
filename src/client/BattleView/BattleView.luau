--!strict
-- The battle screen: both creatures' health, the four moves with the damage each would do, and
-- the lasso, items, switch and run. It only shows what the server sent and sends the player's
-- one choice a turn; the server decides everything.
-- TODO(art): creatures are named, not drawn, until the part meshes exist. Not yet seen in Studio.
-- A little over 400 lines: it is one screen, kept whole so its layout reads top to bottom.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientState = require(script.Parent.Parent.State.ClientState)
local Kit = require(script.Parent.Parent.UI.Kit)
local LassoView = require(script.Parent.Parent.Lasso.LassoView)
local Bus = require(script.Parent.Parent.Net.Bus)
local Net = require(ReplicatedStorage.net.generated.Client)

local EVENT_SECONDS = 0.55 -- pause between the things that happen in a turn

type Fighter = { name: string, level: number, hp: number, maxHp: number, moves: { string } }
type Model = {
	battleId: number,
	wild: boolean,
	sides: { { Fighter } }, -- 1 = yours, 2 = theirs
	active: { number },
	tempo: { number },
	nextTurn: number,
	previews: { number },
	waiting: boolean, -- a choice has been sent and the server has not answered yet
	over: boolean,
	caught: boolean,
	outcome: number?, -- set when the last turn has been shown
	rewards: { string }, -- lines for the end panel; may arrive before the last turn is shown
}

local BattleView = {}

local OUTCOME_TEXT: { [number]: string } =
	{ [0] = "A draw", [1] = "You won!", [2] = "The battle is over" }

function BattleView.start(playerGui: Instance)
	local gui = Kit.screen(playerGui, "Battle", 10)
	local model: Model? = nil

	-- The two creature cards.
	local function card(position: UDim2): (TextLabel, Kit.Bar, Kit.Bar)
		local panel = Kit.panel(gui, UDim2.new(0.44, 0, 0, 74), position)
		local name = Kit.label(panel, "", UDim2.new(1, -20, 0, 26), UDim2.new(0, 10, 0, 6))
		local health =
			Kit.bar(panel, UDim2.new(1, -20, 0, 16), UDim2.new(0, 10, 0, 36), Kit.COLOURS.good)
		local tempo =
			Kit.bar(panel, UDim2.new(1, -20, 0, 6), UDim2.new(0, 10, 0, 58), Kit.COLOURS.tempo)
		return name, health, tempo
	end
	local foeName, foeHealth, foeTempo = card(UDim2.new(0.03, 0, 0.08, 0))
	local myName, myHealth, myTempo = card(UDim2.new(0.53, 0, 0.42, 0))
	local message = Kit.label(gui, "", UDim2.new(0.94, 0, 0, 30), UDim2.new(0.03, 0, 0.56, 0), 24)
	message.TextStrokeTransparency = 0.4

	-- The bottom panel: moves on the left, everything else on the right.
	local actions = Kit.panel(gui, UDim2.new(0.94, 0, 0.3, 0), UDim2.new(0.03, 0, 0.66, 0))
	local moves = Instance.new("Frame")
	moves.Size = UDim2.new(0.64, -12, 1, -16)
	moves.Position = UDim2.new(0, 8, 0, 8)
	moves.BackgroundTransparency = 1
	moves.Parent = actions
	local moveGrid = Instance.new("UIGridLayout")
	moveGrid.CellSize = UDim2.new(0.5, -4, 0.5, -4)
	moveGrid.CellPadding = UDim2.fromOffset(8, 8)
	moveGrid.Parent = moves
	local side = Instance.new("Frame")
	side.Size = UDim2.new(0.36, -12, 1, -16)
	side.Position = UDim2.new(0.64, 4, 0, 8)
	side.BackgroundTransparency = 1
	side.Parent = actions
	local sideGrid = Instance.new("UIGridLayout")
	sideGrid.CellSize = UDim2.new(0.5, -4, 0.5, -4)
	sideGrid.CellPadding = UDim2.fromOffset(8, 8)
	sideGrid.Parent = side

	-- A list of choices over the bottom panel (which lasso, which item, who to switch to).
	local picker = Kit.panel(
		gui,
		UDim2.new(0.6, 0, 0.5, 0),
		UDim2.new(0.2, 0, 0.14, 0),
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
		picker.Visible = true
	end

	local function held(item: string): number
		local state = ClientState.get()
		return if state then state.Items[item] or 0 else 0
	end

	local moveButtons: { TextButton } = {}
	for index = 1, 4 do
		moveButtons[index] = Kit.button(moves, "", Kit.COLOURS.accent, function()
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

	local lassoButton = Kit.button(side, "Lasso", Kit.COLOURS.lasso, function()
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
		choose(options)
	end)
	Kit.button(side, "Items", Kit.COLOURS.good, function()
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
		choose(options)
	end)
	Kit.button(side, "Switch", Kit.COLOURS.panelLight, function()
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
	local runButton = Kit.button(side, "Run", Kit.COLOURS.bad, function()
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
	local done =
		Kit.panel(gui, UDim2.new(0.6, 0, 0.3, 0), UDim2.new(0.2, 0, 0.2, 0), Kit.COLOURS.panelLight)
	done.Visible = false
	done.ZIndex = 8
	local doneText = Kit.label(done, "", UDim2.new(1, -24, 0.6, 0), UDim2.new(0, 12, 0, 8), 26)
	doneText.TextWrapped = true
	doneText.ZIndex = 9
	local closeButton = Kit.button(done, "Continue", Kit.COLOURS.accent, function()
		gui.Enabled = false
		done.Visible = false
		model = nil
	end)
	closeButton.Size = UDim2.new(0.5, 0, 0.26, 0)
	closeButton.Position = UDim2.new(0.25, 0, 0.68, 0)
	closeButton.ZIndex = 9

	-- The end panel appears once the last turn has been shown; rewards join it when they arrive.
	local function showEnd(current: Model)
		if current.outcome == nil then
			return
		end
		local lines = {
			if current.caught
				then "Caught!"
				else OUTCOME_TEXT[current.outcome] or "The battle is over",
		}
		for _, line in current.rewards do
			table.insert(lines, line)
		end
		doneText.Text = table.concat(lines, "\n")
		done.Visible = true
	end

	local function showCard(
		name: TextLabel,
		health: Kit.Bar,
		tempo: Kit.Bar,
		fighter: Fighter,
		tempoShare: number
	)
		name.Text = `{fighter.name}  Lv {fighter.level}   {fighter.hp}/{fighter.maxHp}`
		local share = fighter.hp / math.max(1, fighter.maxHp)
		health.set(share, Kit.healthColour(share))
		tempo.set(tempoShare)
	end

	refresh = function()
		local current = model
		if not current then
			return
		end
		local mine, foe = current.sides[1][current.active[1]], current.sides[2][current.active[2]]
		if mine then
			showCard(myName, myHealth, myTempo, mine, current.tempo[1] / 100)
		end
		if foe then
			showCard(foeName, foeHealth, foeTempo, foe, current.tempo[2] / 100)
		end
		local open = not current.waiting and not current.over
		for index, button in moveButtons do
			local move = if mine then mine.moves[index] else nil
			button.Visible = move ~= nil
			button.Active = open
			button.BackgroundTransparency = if open then 0 else 0.5
			if move then
				local preview = current.previews[index]
				button.Text = if preview then `{move}\n{preview} dmg` else move
			end
		end
		lassoButton.Visible = current.wild
		runButton.Visible = current.wild
		actions.Visible = not current.over
	end

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
			table.insert(
				made,
				{ name = c.Torso, level = c.Level, hp = c.Hp, maxHp = c.MaxHp, moves = c.Moves }
			)
		end
		return made
	end

	Bus.listen(Net.BattleStarted, function(value)
		model = {
			battleId = value.BattleId,
			wild = value.Kind == "Wild",
			sides = { fighters(value.Yours), fighters(value.Theirs) },
			active = { firstStanding(value.Yours), firstStanding(value.Theirs) },
			tempo = { 0, 0 },
			nextTurn = 1,
			previews = value.Previews,
			waiting = false,
			over = false,
			caught = false,
			outcome = nil,
			rewards = {},
		}
		message.Text = if value.Kind == "Wild"
			then `A wild {value.Theirs[1].Torso} appears!`
			else "The battle begins!"
		done.Visible, picker.Visible = false, false
		lasso.finish()
		gui.Enabled = true
		refresh()
	end)

	Bus.listen(Net.BattleTurn, function(value)
		local current = model
		if not current or current.battleId ~= value.BattleId then
			return
		end
		-- Play the turn back one thing at a time.
		for _, event in value.Events do
			local actor = event.Side
			local other = if actor == 1 then 2 else 1
			local who = current.sides[actor][current.active[actor]]
			if event.Kind == "Move" or event.Kind == "FollowUp" then
				local struck = current.sides[other][current.active[other]]
				if struck then
					struck.hp = event.TargetHp
				end
				message.Text =
					`{if who then who.name else "It"} used {event.Move or "a move"}: {event.Damage} damage`
			elseif event.Kind == "Switch" then
				current.active[actor] = event.Slot
				local entered = current.sides[actor][event.Slot]
				message.Text = `{if entered then entered.name else "A creature"} steps in`
			elseif event.Kind == "Faint" then
				local fallen = current.sides[actor][event.Slot]
				if fallen then
					fallen.hp = 0
					message.Text = `{fallen.name} fainted`
				end
			elseif event.Kind == "Poisoned" then
				local victim = current.sides[actor][event.Slot]
				message.Text = `{if victim then victim.name else "It"} is poisoned!`
			elseif event.Kind == "Poison" then
				local victim = current.sides[actor][event.Slot]
				if victim then
					victim.hp = event.TargetHp
					message.Text = `{victim.name} is hurt by poison`
				end
			elseif event.Kind == "Cured" then
				local victim = current.sides[actor][event.Slot]
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
				end
			end
			refresh()
			task.wait(EVENT_SECONDS)
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
		table.insert(
			current.rewards,
			`+{value.Coins} coins{if value.Material ~= "" then ", 1 " .. value.Material else ""}`
		)
		for _, member in value.Members do
			if member.LevelsGained > 0 then
				table.insert(current.rewards, `Level {member.Level}!`)
			end
		end
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
		message.Text = if value.Outcome == "Caught"
			then "Caught!"
			elseif value.Outcome == "Fled" then "It broke free and fled!"
			else "It slipped the rope!"
		local current = model
		if current and value.Outcome == "Caught" then
			current.caught = true
		end
	end)
end

return BattleView
