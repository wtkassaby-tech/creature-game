--!strict
-- The giant fight screen: the giant's health and phase, what it will do next turn (the heart of
-- the fight: big attacks are announced, and the right type stops them), the player's creature,
-- and the moves, items and switch. It shows what the server sent and sends one choice a turn.
-- TODO(art): the giant and creatures are named, not drawn. Not yet seen in Studio.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bus = require(script.Parent.Parent.Net.Bus)
local ClientState = require(script.Parent.Parent.State.ClientState)
local Kit = require(script.Parent.Parent.UI.Kit)
local Net = require(ReplicatedStorage.net.generated.Client)

type Fighter = { name: string, level: number, hp: number, maxHp: number, moves: { string } }
type Model = {
	battleId: number,
	team: { Fighter },
	active: number,
	nextTurn: number,
	itemsLeft: number,
	waiting: boolean,
	over: boolean,
	rewards: { string },
	won: boolean?,
}

local GiantView = {}

local MAX_LOG_LINES = 3

function GiantView.start(playerGui: Instance)
	local gui = Kit.screen(playerGui, "Giant", 11)
	local model: Model? = nil

	local boss = Kit.panel(gui, UDim2.new(0.94, 0, 0, 80), UDim2.new(0.03, 0, 0.06, 0))
	local bossName = Kit.label(boss, "", UDim2.new(1, -20, 0, 28), UDim2.new(0, 10, 0, 6), 24)
	local bossHealth =
		Kit.bar(boss, UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 40), Kit.COLOURS.bad)
	local intent = Kit.panel(
		gui,
		UDim2.new(0.94, 0, 0, 64),
		UDim2.new(0.03, 0, 0.06, 90),
		Kit.COLOURS.panelLight
	)
	local intentText = Kit.label(intent, "", UDim2.new(1, -20, 1, -8), UDim2.new(0, 10, 0, 4))
	intentText.TextWrapped = true
	local logText = Kit.label(gui, "", UDim2.new(0.94, 0, 0, 66), UDim2.new(0.03, 0, 0.36, 0), 18)
	logText.TextWrapped = true
	logText.TextYAlignment = Enum.TextYAlignment.Top
	logText.TextStrokeTransparency = 0.4

	local mine = Kit.panel(gui, UDim2.new(0.5, 0, 0, 62), UDim2.new(0.47, 0, 0.5, 0))
	local myName = Kit.label(mine, "", UDim2.new(1, -20, 0, 26), UDim2.new(0, 10, 0, 4))
	local myHealth =
		Kit.bar(mine, UDim2.new(1, -20, 0, 16), UDim2.new(0, 10, 0, 36), Kit.COLOURS.good)

	local actions = Kit.panel(gui, UDim2.new(0.94, 0, 0.3, 0), UDim2.new(0.03, 0, 0.66, 0))
	local moves = Instance.new("Frame")
	moves.Size = UDim2.new(0.7, -12, 1, -16)
	moves.Position = UDim2.new(0, 8, 0, 8)
	moves.BackgroundTransparency = 1
	moves.Parent = actions
	local moveGrid = Instance.new("UIGridLayout")
	moveGrid.CellSize = UDim2.new(0.5, -4, 0.5, -4)
	moveGrid.CellPadding = UDim2.fromOffset(8, 8)
	moveGrid.Parent = moves
	local side = Instance.new("Frame")
	side.Size = UDim2.new(0.3, -12, 1, -16)
	side.Position = UDim2.new(0.7, 4, 0, 8)
	side.BackgroundTransparency = 1
	side.Parent = actions
	local sideList = Instance.new("UIGridLayout")
	sideList.CellSize = UDim2.new(1, 0, 0.333, -6)
	sideList.CellPadding = UDim2.fromOffset(0, 8)
	sideList.Parent = side

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

	local done =
		Kit.panel(gui, UDim2.new(0.6, 0, 0.3, 0), UDim2.new(0.2, 0, 0.2, 0), Kit.COLOURS.panelLight)
	done.Visible = false
	done.ZIndex = 8
	local doneText = Kit.label(done, "", UDim2.new(1, -24, 0.6, 0), UDim2.new(0, 12, 0, 8), 26)
	doneText.TextWrapped = true
	doneText.ZIndex = 9
	local close = Kit.button(done, "Continue", Kit.COLOURS.accent, function()
		gui.Enabled = false
		done.Visible = false
		model = nil
	end)
	close.Size = UDim2.new(0.5, 0, 0.26, 0)
	close.Position = UDim2.new(0.25, 0, 0.68, 0)
	close.ZIndex = 9

	local previews: { number } = {}
	local refresh: () -> ()

	local function send(
		kind: "Move" | "Switch" | "Item",
		index: number,
		item: ("Tonic" | "GreatTonic" | "Revive")?
	)
		local current = model
		if not current or current.waiting or current.over then
			return
		end
		current.waiting = true
		picker.Visible = false
		Net.GiantAction.Fire({
			BattleId = current.battleId,
			Turn = current.nextTurn,
			Kind = kind,
			Index = index,
			Item = item,
		})
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
		local back = Kit.button(picker, "Back", Kit.COLOURS.bad, function()
			picker.Visible = false
		end)
		back.Size = UDim2.new(1, 0, 0, 40)
		back.ZIndex = 6
		picker.Visible = true
	end

	local moveButtons: { TextButton } = {}
	for index = 1, 4 do
		moveButtons[index] = Kit.button(moves, "", Kit.COLOURS.accent, function()
			send("Move", index, nil)
		end)
	end
	local itemsButton = Kit.button(side, "Items", Kit.COLOURS.good, function()
		local current = model
		local state = ClientState.get()
		if not current or not state then
			return
		end
		local fallen: number? = nil
		for index, fighter in current.team do
			if fighter.hp <= 0 and not fallen then
				fallen = index
			end
		end
		local options = {}
		local function offer(
			item: "Tonic" | "GreatTonic" | "Revive",
			label: string,
			target: number?
		)
			local count = state.Items[item] or 0
			if count > 0 and target then
				table.insert(options, {
					text = `{label} x{count}`,
					pick = function()
						send("Item", target, item)
					end,
				})
			end
		end
		offer("Tonic", "Field Tonic", current.active)
		offer("GreatTonic", "Deep Tonic", current.active)
		offer("Revive", "Rally Root", fallen)
		choose(options)
	end)
	Kit.button(side, "Switch", Kit.COLOURS.panelLight, function()
		local current = model
		if not current then
			return
		end
		local options = {}
		for index, fighter in current.team do
			if index ~= current.active and fighter.hp > 0 then
				table.insert(options, {
					text = `{fighter.name} Lv {fighter.level}  {fighter.hp}/{fighter.maxHp}`,
					pick = function()
						send("Switch", index, nil)
					end,
				})
			end
		end
		choose(options)
	end)

	Kit.button(side, "Give up", Kit.COLOURS.bad, function()
		local current = model
		if current and not current.over then
			-- The horn stays spent; the server just ends the fight.
			Net.LeaveGiant.Fire({ BattleId = current.battleId })
			gui.Enabled = false
			model = nil
		end
	end)

	local function showEnd(current: Model)
		if current.won == nil then
			return
		end
		local lines = {
			if current.won then "The giant falls!" else "Your team is beaten. The horn is spent.",
		}
		for _, line in current.rewards do
			table.insert(lines, line)
		end
		doneText.Text = table.concat(lines, "\n")
		done.Visible = true
	end

	refresh = function()
		local current = model
		if not current then
			return
		end
		local me = current.team[current.active]
		if me then
			myName.Text = `{me.name}  Lv {me.level}   {me.hp}/{me.maxHp}`
			local share = me.hp / math.max(1, me.maxHp)
			myHealth.set(share, Kit.healthColour(share))
		end
		local open = not current.waiting and not current.over
		for index, button in moveButtons do
			local move = if me then me.moves[index] else nil
			button.Visible = move ~= nil
			button.BackgroundTransparency = if open then 0 else 0.5
			if move then
				button.Text = if previews[index] then `{move}\n{previews[index]} dmg` else move
			end
		end
		itemsButton.Text = `Items ({current.itemsLeft} left)`
		actions.Visible = not current.over
	end

	local logLines: { string } = {}
	local giantName = ""
	local function show(view: any)
		local current = model
		if not current then
			return
		end
		for index, hp in view.TeamHp do
			if current.team[index] then
				current.team[index].hp = hp
			end
		end
		current.active = view.Active
		current.nextTurn = view.Turn + 1
		current.itemsLeft = view.ItemsLeft
		current.waiting = false
		previews = view.Previews
		for _, line in view.Lines do
			table.insert(logLines, line)
		end
		while #logLines > MAX_LOG_LINES do
			table.remove(logLines, 1)
		end
		logText.Text = table.concat(logLines, "\n")
		bossName.Text = `{giantName}   {view.BossHp}/{view.BossMaxHp}   {view.Phase}`
		bossHealth.set(view.BossHp / math.max(1, view.BossMaxHp))
		local warning = view.Intent.Kind ~= "Attack"
		local weak = if warning and #view.Intent.WeakTypes > 0
			then `  Stop it with: {table.concat(view.Intent.WeakTypes, ", ")}`
			else ""
		intentText.Text =
			`Next: {view.Intent.Text}{weak}{if view.Intent.Enraged then "  (ENRAGED)" else ""}`
		intent.BackgroundColor3 = if warning then Kit.COLOURS.warn else Kit.COLOURS.panelLight
		intentText.TextColor3 = if warning then Color3.fromRGB(40, 30, 0) else Kit.COLOURS.text
		if view.Finished then
			current.over = true
			current.won = view.Won
			showEnd(current)
		end
		refresh()
	end

	Bus.listen(Net.GiantStarted, function(value)
		local team: { Fighter } = {}
		for _, c in value.Yours do
			table.insert(
				team,
				{ name = c.Torso, level = c.Level, hp = c.Hp, maxHp = c.MaxHp, moves = c.Moves }
			)
		end
		model = {
			battleId = value.View.BattleId,
			team = team,
			active = 1,
			nextTurn = 1,
			itemsLeft = value.View.ItemsLeft,
			waiting = false,
			over = false,
			rewards = {},
			won = nil,
		}
		giantName = `{value.Name}  Lv {value.Level}`
		logLines = {}
		done.Visible, picker.Visible = false, false
		gui.Enabled = true
		show(value.View)
	end)

	Bus.listen(Net.GiantTurn, function(value)
		local current = model
		if current and current.battleId == value.BattleId then
			show(value)
		end
	end)

	Bus.listen(Net.BattleRefused, function(value)
		local current = model
		if current and gui.Enabled and not current.over then
			current.waiting = false
			logText.Text = value.Reason
			refresh()
		end
	end)

	Bus.listen(Net.BattleRewards, function(value)
		local current = model
		if not current or current.battleId ~= value.BattleId then
			return
		end
		table.insert(current.rewards, `+{value.Coins} coins`)
		for _, member in value.Members do
			if member.LevelsGained > 0 then
				table.insert(current.rewards, `Level {member.Level}!`)
			end
		end
		showEnd(current)
	end)
end

return GiantView
