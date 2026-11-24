--!strict
-- What the server said the shop may show (the PurchaseFlags message), kept for the screens, and
-- a way to be told when it changes. Display only: the server checks again on every request.
-- Nothing is known until the first message arrives, so every Robux button stays hidden until then.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Bus = require(script.Parent.Parent.Net.Bus)
local Net = require(ReplicatedStorage.net.generated.Client)
local ShopOffers = require(ReplicatedStorage.shared.ShopOffers)

local StoreFlags = {}

local current: ShopOffers.Flags? = nil
local listeners: { () -> () } = {}
local started = false

-- Starts listening (once).
function StoreFlags.start()
	if started then
		return
	end
	started = true
	Bus.listen(Net.PurchaseFlags, function(value)
		current = {
			Open = value.Open,
			PaidRandomRestricted = value.PaidRandomRestricted,
			TradingAllowed = value.TradingAllowed,
			LassoBoost = value.LassoBoost,
		}
		for _, each in listeners do
			task.spawn(each)
		end
	end)
end

function StoreFlags.get(): ShopOffers.Flags?
	return current
end

-- Calls `listener` whenever the flags change. Returns a function that stops it.
function StoreFlags.onChanged(listener: () -> ()): () -> ()
	table.insert(listeners, listener)
	return function()
		local index = table.find(listeners, listener)
		if index then
			table.remove(listeners, index)
		end
	end
end

-- True while a battle (wild, tamer, gate or giant) screen is up: nothing is offered then.
function StoreFlags.inBattle(playerGui: Instance): boolean
	for _, name in { "Battle", "Giant" } do
		local screen = playerGui:FindFirstChild(name)
		if screen and screen:IsA("ScreenGui") and screen.Enabled then
			return true
		end
	end
	return false
end

return StoreFlags
