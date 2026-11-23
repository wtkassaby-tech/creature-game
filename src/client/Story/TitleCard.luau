--!strict
-- The town's name, shown once to a new player before the mentor speaks.

local Players = game:GetService("Players")

local Kit = require(script.Parent.Parent.UI.Kit)

local TitleCard = {}

local TITLE_FADE_IN, TITLE_HOLD, TITLE_FADE_OUT = 0.5, 1.6, 0.6 -- under three seconds in all
local TITLE_WAIT_FOR_WORLD = 8 -- seconds, at most, for the character to appear first

-- The town's name as the player first sees it: a cream band across the screen, the way an old
-- handheld game names a town as you walk in. It waits for the player to be standing in the
-- world, so the name appears over the town and not over an empty sky. Any tap skips it.
function TitleCard.play(playerGui: Instance, onDone: () -> ())
	local gui = Kit.screen(playerGui, "Title", 40)
	local band = Instance.new("CanvasGroup")
	band.Size = UDim2.fromScale(1, 0.24)
	band.Position = UDim2.fromScale(0, 0.05)
	band.BackgroundColor3 = Kit.COLOURS.panel
	band.BorderSizePixel = 0
	band.GroupTransparency = 1
	band.Parent = gui
	for _, edge in { 0, 1 } do
		local line = Instance.new("Frame")
		line.AnchorPoint = Vector2.new(0, edge)
		line.Size = UDim2.new(1, 0, 0, 4)
		line.Position = UDim2.fromScale(0, edge)
		line.BackgroundColor3 = Kit.COLOURS.outline
		line.BorderSizePixel = 0
		line.Parent = band
	end
	local small =
		Kit.label(band, "Welcome to", UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.1), 18)
	small.TextXAlignment = Enum.TextXAlignment.Center
	small.TextColor3 = Kit.COLOURS.textDim
	local word =
		Kit.title(band, "THISTLEDOWN", UDim2.fromScale(0.9, 0.44), UDim2.fromScale(0.05, 0.3), 56)
	word.TextXAlignment = Enum.TextXAlignment.Center
	word.TextScaled = true
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = 72
	limit.Parent = word
	local under = Kit.label(
		band,
		"where the Greenwood begins",
		UDim2.fromScale(1, 0.2),
		UDim2.fromScale(0, 0.74),
		18
	)
	under.TextXAlignment = Enum.TextXAlignment.Center
	under.TextColor3 = Kit.COLOURS.textDim
	local skip = Instance.new("TextButton")
	skip.Size = UDim2.fromScale(1, 1)
	skip.BackgroundTransparency = 1
	skip.Text = ""
	skip.Parent = gui
	gui.Enabled = true
	local skipped = false
	skip.Activated:Connect(function()
		skipped = true
	end)
	local function fade(from: number, to: number, seconds: number)
		local steps = 20
		for step = 1, steps do
			if skipped then
				return
			end
			band.GroupTransparency = from + (to - from) * step / steps
			task.wait(seconds / steps)
		end
	end
	task.spawn(function()
		-- Wait (a few seconds at most) until the player's character stands in the town.
		local player = Players.LocalPlayer
		local waited = 0
		while waited < TITLE_WAIT_FOR_WORLD and not skipped do
			local character = player.Character
			if character and character:FindFirstChild("HumanoidRootPart") then
				break
			end
			waited += task.wait(0.1)
		end
		task.wait(0.4) -- the camera settles behind the player
		fade(1, 0, TITLE_FADE_IN)
		for _ = 1, math.floor(TITLE_HOLD / 0.05) do
			if skipped then
				break
			end
			task.wait(0.05)
		end
		fade(0, 1, TITLE_FADE_OUT)
		gui:Destroy()
		onDone()
	end)
end

return TitleCard
