--!strict
-- Real Robux prices, read at runtime from Roblox (MarketplaceService:GetProductInfoAsync with
-- Enum.InfoType.GamePass for a pass and Enum.InfoType.Product for a developer product, whose
-- result has PriceInRobux). The numbers in PurchaseConfig are only display hints and are never
-- shown as a price. A price is fetched once per id, off the main thread, and cached; until it
-- arrives (or if the call fails) the screens show no price rather than a guess. Display only:
-- the price Roblox charges is the one in its own prompt.

local MarketplaceService = game:GetService("MarketplaceService")

local Prices = {}

-- id -> price in Robux (false while a read is in flight or after it failed)
local cache: { [number]: number | boolean } = {}
local waiting: { () -> () } = {}

-- Reads the price of `id` if it is not known, then calls `onReady` (once it has changed). Ids
-- below 1 (not created yet) are never asked for.
function Prices.request(kind: "Pass" | "Product", id: number, onReady: () -> ())
	if id < 1 or cache[id] ~= nil then
		return
	end
	cache[id] = false
	table.insert(waiting, onReady)
	task.spawn(function()
		local infoType = if kind == "Pass" then Enum.InfoType.GamePass else Enum.InfoType.Product
		local ok, info = pcall(function()
			return MarketplaceService:GetProductInfoAsync(id, infoType)
		end)
		if ok and typeof(info) == "table" then
			local price = (info :: { [string]: any }).PriceInRobux
			if typeof(price) == "number" and price >= 0 then
				cache[id] = price
				for _, each in waiting do
					task.spawn(each)
				end
			end
		end
	end)
end

-- The price in Robux, or nil if not known (yet).
function Prices.get(id: number): number?
	local value = cache[id]
	return if typeof(value) == "number" then value else nil
end

-- "R$ 99" style text for a button, or "" while unknown.
function Prices.text(id: number): string
	local price = Prices.get(id)
	return if price then `{price} Robux` else ""
end

return Prices
