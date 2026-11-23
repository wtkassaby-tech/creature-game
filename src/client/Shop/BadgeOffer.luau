--!strict
-- The one unprompted Gems offer tied to progress: after the first badge, once, a small card says
-- what Gems are and opens the shop's Gems tab. It waits until the battle and dialogue screens are
-- gone (never in battle, never over the badge card itself), shows once per session, never on join
-- (the first state of a session is not a gain) and only while the shop's Robux switch is on. A tap
-- on Later, or twelve seconds, closes it. Looks only: the server grants nothing here.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientState = require(script.Parent.Parent.State.ClientState)
local Kit = require(script.Parent.Parent.UI.Kit)
local ShopOffers = require(ReplicatedStorage.shared.ShopOffers)
local StoreFlags = require(script.Parent.StoreFlags)

local BadgeOffer = {}

local SHOW_SECONDS = 12
local COVERING: { string } = { "Battle", "Giant", "Dialogue", "StarterPick" }

function BadgeOffer.start(playerGui: Instance, openGems: () -> ())
	local gui = Kit.screen(playerGui, "GemOffer", 14, true)
	local card = Kit.panel(gui, UDim2.fromOffset(400, 84), UDim2.new(0.5, 0, 1, -16))
	card.AnchorPoint = Vector2.new(0.5, 1)
	local text = Kit.label(card, "", UDim2.new(1, -20, 0, 30), UDim2.fromOffset(10, 6), 18)
	text.TextWrapped = true
	local see = Kit.button(card, "See", Kit.COLOURS.good, function()
		gui.Enabled = false
		openGems()
	end)
	see.Size = UDim2.new(0.46, 0, 0, 36)
	see.Position = UDim2.new(0.03, 0, 1, -42)
	local later = Kit.button(card, "Later", Kit.COLOURS.neutral, function()
		gui.Enabled = false
	end)
	later.Size = UDim2.new(0.46, 0, 0, 36)
	later.Position = UDim2.new(0.51, 0, 1, -42)

	local shownThisSession = false
	local previous: number? = nil
	local pending = false

	local function covered(): boolean
		for _, name in COVERING do
			local screen = playerGui:FindFirstChild(name)
			if screen and screen:IsA("ScreenGui") and screen.Enabled then
				return true
			end
		end
		return false
	end

	-- Waits for the screens to clear, then shows the card once.
	local function showWhenClear()
		if pending or shownThisSession then
			return
		end
		pending = true
		task.spawn(function()
			-- Gives up after a while: the moment has passed and a card out of nowhere is worse.
			local waited = 0
			while covered() and waited < 120 do
				task.wait(1)
				waited += 1
			end
			pending = false
			local state = ClientState.get()
			local flags = StoreFlags.get()
			if waited >= 120 or not state or not (flags and flags.Open) or shownThisSession then
				return
			end
			shownThisSession = true
			text.Text = ShopOffers.badgeLine(state.Gems)
			gui.Enabled = true
			Kit.pop(card)
			task.delay(SHOW_SECONDS, function()
				gui.Enabled = false
			end)
		end)
	end

	ClientState.onChanged(function(state)
		local before = previous
		previous = state.Badges
		if ShopOffers.firstBadgeJustEarned(before, state.Badges) then
			showWhenClear()
		end
	end)
	-- The card never stays over a fight that starts.
	for _, name in { "Battle", "Giant" } do
		task.spawn(function()
			local screen = playerGui:WaitForChild(name)
			if screen:IsA("ScreenGui") then
				screen:GetPropertyChangedSignal("Enabled"):Connect(function()
					if screen.Enabled then
						gui.Enabled = false
					end
				end)
			end
		end)
	end
end

return BadgeOffer
