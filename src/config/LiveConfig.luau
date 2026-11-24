--!strict
-- Switches that can be flipped from the Creator Hub's Configs page while the game is running,
-- with no new release: an emergency brake for each part of the game that hands out or takes
-- value. The key names here are the keys to create on that page, each as a boolean.
-- A key that is missing, or is not a boolean, counts as its default below.
--
-- What has no switch, on purpose: battles and their rewards, catching, quests and the story,
-- eggs hatching, gifts that were waiting for room, and healing. Switching those off would stop
-- the game itself; if one of them goes wrong the answer is a fixed release, not a switch.
-- A giant fight already under way when giants are switched off is played to its end.

export type Key =
	"shop_open"
	| "breeding_open"
	| "giants_open"
	| "daily_rewards_open"
	| "release_open"
	| "purchases_open"
	| "trading_open"
	| "pvp_open"
	| "chance_display"

export type Values = {
	shop_open: boolean, -- buying with coins, crafting, stable room
	breeding_open: boolean, -- starting a new breed (eggs already in pens still hatch)
	giants_open: boolean, -- starting a giant fight
	daily_rewards_open: boolean, -- claiming a daily task
	release_open: boolean, -- releasing a creature for coins, candy and materials
	purchases_open: boolean, -- Robux prompts, Gem spending and the Gem shop; a receipt that arrives while off waits (NotProcessedYet) and is granted later
	trading_open: boolean,
	pvp_open: boolean,
	-- The live catch chance is shown on every throw. While off, the Lasso Pass and Gem lassos are
	-- treated as restricted (not offered, no effect): a paid chance must never be hidden.
	chance_display: boolean,
}

local LiveConfig = {}

local KEYS: { Key } = {
	"shop_open",
	"breeding_open",
	"giants_open",
	"daily_rewards_open",
	"release_open",
	"purchases_open",
	"trading_open",
	"pvp_open",
	"chance_display",
}
LiveConfig.KEYS = KEYS

local DEFAULTS: Values = {
	shop_open = true,
	breeding_open = true,
	giants_open = true,
	daily_rewards_open = true,
	release_open = true,
	purchases_open = true, -- every product id is 0 (not for sale) until the place is published
	trading_open = false,
	pvp_open = false,
	chance_display = true,
}
LiveConfig.DEFAULTS = DEFAULTS

-- Parts of the game whose code does not exist yet. A live value can never switch these on:
-- take a key off this list in the same release that ships its feature.
local NOT_BUILT: { Key } = { "trading_open", "pvp_open" }
LiveConfig.NOT_BUILT = NOT_BUILT

-- What a player is told when something is switched off.
LiveConfig.CLOSED_TEXT = "Closed for a moment while we fix something. Nothing of yours is lost."

-- Seconds to wait before asking Roblox for the live values again after a failure: the first
-- tries are quick, then once a minute for as long as it takes.
local RETRY_SECONDS: { number } = { 5, 15, 60 }
LiveConfig.RETRY_SECONDS = RETRY_SECONDS

return LiveConfig
