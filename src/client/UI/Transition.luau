--!strict
-- Screen transitions: a cream wipe into a battle and a fade to black for travel and waking at the
-- healer. Looks only. Each takes `onCovered`, called once when the screen is fully covered, so
-- the caller swaps scenes behind the cover. The cover never blocks input, and `onCovered` always
-- runs: if a transition is already playing, the new one skips its animation and calls it at once
-- (so tweens never stack).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Kit = require(script.Parent.Kit)

local Transition = {}

local BARS = 6
local WIPE_IN = 0.24 -- bars sweep across
local WIPE_HOLD = 0.02
local WIPE_OUT = 0.24 -- about 0.5 s in all
local FADE_IN = 0.22
local FADE_HOLD = 0.06
local FADE_OUT = 0.3

local gui: ScreenGui? = nil
local bars: { Frame } = {}
local fadeFrame: Frame? = nil
local busy = false
local tweens: { Tween } = {}

local function build(): ScreenGui?
	if gui and gui.Parent then
		return gui
	end
	local player = Players.LocalPlayer
	if not player then
		return nil
	end
	local made = Kit.screen(player:WaitForChild("PlayerGui"), "Transition", 100)
	made.Enabled = false
	bars = {}
	for index = 1, BARS do
		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(0, 0, 1 / BARS, 1) -- 1 px extra so no seam shows between bars
		bar.Position = UDim2.fromScale(0, (index - 1) / BARS)
		bar.AnchorPoint = Vector2.new(0, 0)
		bar.BackgroundColor3 = Kit.COLOURS.panel
		bar.BorderSizePixel = 0
		bar.Parent = made
		-- Ink edge on the leading side of each bar, the handheld border.
		local edge = Instance.new("Frame")
		edge.Size = UDim2.new(0, 6, 1, 0)
		edge.BackgroundColor3 = Kit.COLOURS.outline
		edge.BorderSizePixel = 0
		edge.Parent = bar
		table.insert(bars, bar)
	end
	local fade = Instance.new("Frame")
	fade.Size = UDim2.fromScale(1, 1)
	fade.BackgroundColor3 = Color3.new(0, 0, 0)
	fade.BackgroundTransparency = 1
	fade.BorderSizePixel = 0
	fade.Parent = made
	fadeFrame = fade
	gui = made
	return made
end

local function play(target: Instance, info: TweenInfo, goal: { [string]: any })
	local tween = TweenService:Create(target, info, goal)
	table.insert(tweens, tween)
	tween:Play()
end

local function cancelAll()
	for _, tween in tweens do
		tween:Cancel()
	end
	table.clear(tweens)
end

-- Odd bars enter from the left and even bars from the right, then leave the way they came
-- on the far side, so the wipe closes and opens in one sweep.
function Transition.intoBattle(onCovered: () -> ())
	local screen = build()
	if busy or not screen then
		onCovered()
		return
	end
	busy = true
	screen.Enabled = true
	for index, bar in bars do
		local fromLeft = index % 2 == 1
		bar.AnchorPoint = Vector2.new(if fromLeft then 0 else 1, 0)
		bar.Position = UDim2.fromScale(if fromLeft then 0 else 1, (index - 1) / BARS)
		bar.Size = UDim2.new(0, 0, 1 / BARS, 1)
		bar.Visible = true
		local edge = bar:FindFirstChildOfClass("Frame")
		if edge then
			edge.Position = if fromLeft then UDim2.new(1, -6, 0, 0) else UDim2.fromOffset(0, 0)
		end
		play(
			bar,
			TweenInfo.new(
				WIPE_IN,
				Enum.EasingStyle.Quad,
				Enum.EasingDirection.In,
				0,
				false,
				(index - 1) * 0.012
			),
			{ Size = UDim2.new(1, 0, 1 / BARS, 1) }
		)
	end
	task.delay(WIPE_IN + BARS * 0.012 + WIPE_HOLD, function()
		onCovered()
		for index, bar in bars do
			local fromLeft = index % 2 == 1
			-- Keep each bar pinned to the side it left from by flipping its anchor to the far
			-- side, then shrinking: the bars exit on the opposite edge.
			bar.AnchorPoint = Vector2.new(if fromLeft then 1 else 0, 0)
			bar.Position = UDim2.fromScale(if fromLeft then 1 else 0, (index - 1) / BARS)
			local edge = bar:FindFirstChildOfClass("Frame")
			if edge then
				edge.Position = if fromLeft then UDim2.fromOffset(0, 0) else UDim2.new(1, -6, 0, 0)
			end
			play(
				bar,
				TweenInfo.new(
					WIPE_OUT,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out,
					0,
					false,
					(index - 1) * 0.012
				),
				{ Size = UDim2.new(0, 0, 1 / BARS, 1) }
			)
		end
		task.delay(WIPE_OUT + BARS * 0.012, function()
			cancelAll()
			screen.Enabled = false
			busy = false
		end)
	end)
end

-- Fade to black, call `onCovered`, fade back.
function Transition.fade(onCovered: () -> ())
	local screen = build()
	local fade = fadeFrame
	if busy or not screen or not fade then
		onCovered()
		return
	end
	busy = true
	screen.Enabled = true
	for _, bar in bars do
		bar.Visible = false
	end
	fade.BackgroundTransparency = 1
	play(fade, TweenInfo.new(FADE_IN, Enum.EasingStyle.Quad), { BackgroundTransparency = 0 })
	task.delay(FADE_IN, function()
		onCovered()
		task.delay(FADE_HOLD, function()
			play(
				fade,
				TweenInfo.new(FADE_OUT, Enum.EasingStyle.Quad),
				{ BackgroundTransparency = 1 }
			)
			task.delay(FADE_OUT, function()
				cancelAll()
				screen.Enabled = false
				busy = false
			end)
		end)
	end)
end

return Transition
