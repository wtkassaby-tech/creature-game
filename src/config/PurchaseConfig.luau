--!strict
-- Everything sold for Robux (docs/plans/05_PURCHASES.md, docs/plans/16_MONETISATION.md).
--
-- Roblox ids are 0 until the place is published and each pass and developer product is created
-- on the Creator Hub: set them then. An id of 0 means "not for sale": the server never prompts for
-- it and never matches a receipt to it. Robux prices here are DISPLAY HINTS only: the real price
-- is read at runtime with MarketplaceService:GetProductInfoAsync, and the server never uses a
-- price from the device or from this file to grant anything.
--
-- Every value is a [Default] unless the plan says otherwise.

export type PassId = "BiggerStable" | "QuickHatch" | "SecondNest" | "Supporter" | "LassoPass"
export type ProductId =
	"Gems49"
	| "Gems99"
	| "Gems249"
	| "Gems499"
	| "Gems999"
	| "Gems1999"
	| "StarterPack"

export type PassDef = {
	id: number, -- Roblox game pass id; 0 = not created yet
	name: string,
	robuxHint: number,
	stableRoom: number, -- added to StableCapacity once, when the pass is first applied
	pens: number, -- added to Pens once, never above ProfileConfig.MAX_PENS
	hatchFactor: number, -- hatch time multiplier for a new egg (1 = unchanged)
	stableAnywhere: boolean, -- the stable can be opened away from a hub
	lassoBoost: boolean, -- raises the wild catch chance (see LASSO_PASS_*)
	title: string?, -- a title shown by the player's name
	note: string?, -- a line the shop must show with the pass
}
export type ProductDef = {
	id: number, -- Roblox developer product id; 0 = not created yet
	kind: "Gems" | "Starter",
	gems: number, -- Gems granted
	robuxHint: number,
}

local PurchaseConfig = {}

-- FIELD SATCHEL is not for sale: it opens the stable anywhere, but no server stable action needs a
-- hub today, so it would do nothing. To bring it back, add "FieldSatchel" to PassId and PASS_IDS and
-- a PASSES entry (stableAnywhere = true, robuxHint 199), and gate the stable action with
-- PassEffects.mayUseStable. The code path (PassEffects.stableAnywhere) is kept.
local PASS_IDS: { PassId } =
	{ "BiggerStable", "QuickHatch", "SecondNest", "Supporter", "LassoPass" }
PurchaseConfig.PASS_IDS = PASS_IDS

PurchaseConfig.PASSES = {
	BiggerStable = {
		id = 0,
		name = "Bigger Stable",
		robuxHint = 199,
		stableRoom = 30,
		pens = 0,
		hatchFactor = 1,
		stableAnywhere = false,
		lassoBoost = false,
	},
	QuickHatch = {
		id = 0,
		name = "Quick Hatch",
		robuxHint = 299,
		stableRoom = 0,
		pens = 0,
		hatchFactor = 0.5,
		stableAnywhere = false,
		lassoBoost = false,
	},
	SecondNest = {
		id = 0,
		name = "Second Nest",
		robuxHint = 399,
		stableRoom = 0,
		pens = 1,
		hatchFactor = 1,
		stableAnywhere = false,
		lassoBoost = false,
	},
	Supporter = {
		id = 0,
		name = "Supporter",
		robuxHint = 399,
		stableRoom = 10,
		pens = 0,
		hatchFactor = 1,
		stableAnywhere = false,
		lassoBoost = false,
		title = "Supporter",
	},
	LassoPass = {
		id = 0,
		name = "Lasso Pass",
		robuxHint = 349, -- [Default] placeholder; Ayrton has not set a price
		stableRoom = 0,
		pens = 0,
		hatchFactor = 1,
		stableAnywhere = false,
		lassoBoost = true,
		note = "Raises the catch chance of common and uncommon wild creatures. It has no effect, and is not offered, where paid random items are restricted. It never affects gem-tier creatures or giants.",
	},
} :: {
	BiggerStable: PassDef,
	QuickHatch: PassDef,
	SecondNest: PassDef,
	Supporter: PassDef,
	LassoPass: PassDef,
}

-- The Lasso Pass (owner decision, 23 November 2026: "a higher catch chance means more catches, not
-- better odds of a particular creature"): a wild throw's catch chance becomes
-- min(CAP, chance + BONUS). It applies only to a creature that never flees (LassoConfig
-- FLEE_AFTER_MISSES of 0: Common and Uncommon), so it never raises the odds of a gem-tier,
-- serial-numbered creature, and never to a giant. It needs the pass AND PolicyService saying paid
-- random items are not restricted. Decided once, when the throw begins, so the chance shown is the
-- chance rolled. Never lowers a chance. A creature caught with it is marked `paidAssist`.
-- The rarities it applies to (all of them never flee). Anything not listed is never boosted.
PurchaseConfig.LASSO_PASS_RARITIES = { Common = true, Uncommon = true } :: { [string]: boolean }
PurchaseConfig.LASSO_PASS_BONUS = 0.15
PurchaseConfig.LASSO_PASS_CAP = 0.97

local PRODUCT_IDS: { ProductId } =
	{ "Gems49", "Gems99", "Gems249", "Gems499", "Gems999", "Gems1999", "StarterPack" }
PurchaseConfig.PRODUCT_IDS = PRODUCT_IDS

-- Gem bundles from plan 16 (Robux to Gems), and the Starter Pack (once per account).
PurchaseConfig.PRODUCTS = {
	Gems49 = { id = 0, kind = "Gems", gems = 45, robuxHint = 49 },
	Gems99 = { id = 0, kind = "Gems", gems = 100, robuxHint = 99 },
	Gems249 = { id = 0, kind = "Gems", gems = 275, robuxHint = 249 },
	Gems499 = { id = 0, kind = "Gems", gems = 575, robuxHint = 499 },
	Gems999 = { id = 0, kind = "Gems", gems = 1200, robuxHint = 999 },
	Gems1999 = { id = 0, kind = "Gems", gems = 2500, robuxHint = 1999 },
	-- The Starter Pack: its Gems here; its room and cosmetic in STARTER_PACK below.
	StarterPack = { id = 0, kind = "Starter", gems = 150, robuxHint = 99 },
} :: {
	Gems49: ProductDef,
	Gems99: ProductDef,
	Gems249: ProductDef,
	Gems499: ProductDef,
	Gems999: ProductDef,
	Gems1999: ProductDef,
	StarterPack: ProductDef,
}

-- Starter Pack contents besides its Gems (PRODUCTS.StarterPack.gems). The cosmetic is a flag in
-- Profile.Purchases.perks until the wardrobe exists.
PurchaseConfig.STARTER_PACK = {
	stableRoom = 10,
	cosmeticPerk = "StarterCosmetic",
	onceKey = "StarterPack",
}

-- A balance never goes above this (the device is told Gems as a u32, and a bug that mints Gems
-- must stop long before that).
PurchaseConfig.MAX_GEMS = 100000000
-- One Gem change (a bundle, a spend) is never larger than this.
PurchaseConfig.MAX_GEM_CHANGE = 10000000

-- The receipt id is Roblox's own text; anything longer than this is not one.
PurchaseConfig.MAX_PURCHASE_ID_LENGTH = 100

-- Net.blink limits on PlayerState's Passes and Perks: names of 1 to 24 characters, 16 at most.
PurchaseConfig.BLINK_MAX_KEY = 24
PurchaseConfig.BLINK_MAX_MARKS = 16

-- Seconds between the same player's requests of each kind.
PurchaseConfig.PROMPT_COOLDOWN = 1
PurchaseConfig.GEM_BUY_COOLDOWN = 0.25
PurchaseConfig.FINISH_EGG_COOLDOWN = 0.5

-- Seconds to wait before asking PolicyService again after a failure (the last value repeats).
PurchaseConfig.POLICY_RETRY_SECONDS = { 5, 15, 60 } :: { number }
-- Tries to see a just-bought pass with UserOwnsGamePassAsync (it can lag a moment), and the wait.
PurchaseConfig.PASS_CHECK_TRIES = 4
PurchaseConfig.PASS_CHECK_WAIT = 1.5

return PurchaseConfig
