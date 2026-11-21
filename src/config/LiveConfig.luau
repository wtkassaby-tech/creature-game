--!strict
-- Switches that can be flipped from the Creator Hub's Configs page while the game is running,
-- with no new release: an emergency brake for each part of the game that hands out or takes
-- value. The key names here are the keys to create on that page, each as a boolean.
-- A key that is missing, or is not a boolean, counts as its default below.

export type Key =
	"shop_open"
	| "breeding_open"
	| "giants_open"
	| "daily_rewards_open"
	| "purchases_open"
	| "trading_open"
	| "pvp_open"

export type Values = {
	shop_open: boolean, -- buying with coins, crafting, stable room
	breeding_open: boolean, -- starting a new breed (eggs already in pens still hatch)
	giants_open: boolean, -- starting a giant fight
	daily_rewards_open: boolean, -- claiming a daily task
	purchases_open: boolean, -- the Gem shop and anything bought with Robux
	trading_open: boolean,
	pvp_open: boolean,
}

local LiveConfig = {}

local KEYS: { Key } = {
	"shop_open",
	"breeding_open",
	"giants_open",
	"daily_rewards_open",
	"purchases_open",
	"trading_open",
	"pvp_open",
}
LiveConfig.KEYS = KEYS

local DEFAULTS: Values = {
	shop_open = true,
	breeding_open = true,
	giants_open = true,
	daily_rewards_open = true,
	purchases_open = false,
	trading_open = false,
	pvp_open = false,
}
LiveConfig.DEFAULTS = DEFAULTS

-- Parts of the game whose code does not exist yet. A live value can never switch these on:
-- take a key off this list in the same release that ships its feature.
local NOT_BUILT: { Key } = { "purchases_open", "trading_open", "pvp_open" }
LiveConfig.NOT_BUILT = NOT_BUILT

-- What a player is told when something is switched off.
LiveConfig.CLOSED_TEXT = "Closed for a moment while we fix something. Nothing of yours is lost."

-- Seconds to wait before asking Roblox for the live values again after a failure: the first
-- tries are quick, then once a minute for as long as it takes.
local RETRY_SECONDS: { number } = { 5, 15, 60 }
LiveConfig.RETRY_SECONDS = RETRY_SECONDS

return LiveConfig
