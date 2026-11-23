--!strict
-- Every sound the game plays on purpose: the music tracks, the short sound effects and the
-- numbers that balance them. Ids are Roblox's own licensed sounds (docs/ASSETS.md lists each one
-- with its creator). Ambient beds stay in ClimateConfig, one per climate preset. All values are
-- [Default]s to tune by ear. Volumes are 0 to 1; a track's volume is before the Music group's
-- volume (MASTER_MUSIC), which is what a settings screen would change.

local JingleConfig = require("./JingleConfig")

local AudioConfig = {}

export type Track = { soundId: string, volume: number }
export type SfxDef = { id: string, volume: number, speed: number, jingle: string? }

-- Music, one looping track per mood. APM Music tracks from Roblox's licensed library.
local MUSIC: { [string]: Track } = {
	-- "Down In The Valley": warm, slow acoustic guitar and ukulele; nostalgic and sleepy.
	town = { soundId = "rbxassetid://9042458184", volume = 0.2 },
	-- "Happy Daze (b)": an easy, happy-go-lucky folk track for walking the roads.
	route = { soundId = "rbxassetid://1839993539", volume = 0.2 },
	-- "Playing it Straight (c)": plucky pizzicato strings and mallets; lively but light.
	battle = { soundId = "rbxassetid://9039543444", volume = 0.26 },
	-- "Imminent Closure (Underscore C)": a rousing orchestral build for a giant.
	giant = { soundId = "rbxassetid://9046506025", volume = 0.3 },
}
AudioConfig.MUSIC = MUSIC

AudioConfig.MASTER_MUSIC = 1 -- the Music group's volume; a settings screen sets this, 0 mutes
AudioConfig.MUSIC_FADE_TIME = 1.6 -- seconds: the time constant of a crossfade between tracks
AudioConfig.BATTLE_FADE_TIME = 0.5 -- a quicker one into and out of a battle
AudioConfig.DUCK_FACTOR = 0.12 -- music volume factor while a win or loss jingle plays
AudioConfig.DUCK_SECONDS = 5

-- Town or route: standing within half a town's square plus ENTER_MARGIN studs of its centre is
-- "town"; it stays town until LEAVE_MARGIN studs, so a step on the edge does not flip the track.
AudioConfig.TOWN_ENTER_MARGIN = 16
AudioConfig.TOWN_LEAVE_MARGIN = 40
AudioConfig.ZONE_INTERVAL = 0.5 -- seconds between reading where the player is

-- Short sounds, one palette: soft wood blocks (presses, ticks), dull thumps (hits), a plucked
-- note for jingles. All from Roblox's licensed Pro Sound Effects library except the win sting
-- (APM). A def with `jingle` plays that tune from JingleConfig instead of its file; its `volume`
-- then scales the tune. Volumes sit under the music beds (0.2 to 0.3) and the ambience.
local WOOD_1 = "rbxassetid://9120917438" -- "Wood Impacts Soft Impacts On Temple Blocks 1", 0.6 s
local WOOD_5 = "rbxassetid://9120917794" -- "... Temple Blocks 5"
local WOOD_6 = "rbxassetid://9120917813" -- "... Temple Blocks 6"
local WOOD_7 = "rbxassetid://9120917861" -- "... Temple Blocks 7"
local WOOD_8 = "rbxassetid://9120917978" -- "... Temple Blocks 8"
local WOOD_DOUBLE = "rbxassetid://9119978223" -- "Temple Blocks Impact Some Double Hits 1", 1.3 s
local WOOD_DOUBLE_B = "rbxassetid://9119980170" -- "Temple Blocks Impact Some Double Hits 30"
local THUMP_BODY = "rbxassetid://9113487557" -- "Body Hit 7": a soft sneaker kick, 0.7 s
local THUMP_BODY_B = "rbxassetid://9113487341" -- "Body Hit 1": a sneaker kick, 1.1 s
local THUMP_BALL = "rbxassetid://9119323621" -- "Soccer Ball Kicks On Surfaces 1", 0.8 s
local THUMP_STATUE = "rbxassetid://9119603528" -- "Statue Hits 14": hammer on plaster, 1 s
local SWISH = "rbxassetid://9118001124" -- "Racquetball Racquet Swishes High Pitch 17", 0.7 s
local RUSTLE = "rbxassetid://9114518070" -- "Foliage Movement 2", 2 s
local STING_WIN = "rbxassetid://94590027038118" -- "Victorious Journey Sting" (APM)
local INSTRUMENT = JingleConfig.INSTRUMENT_ID
local SFX: { [string]: SfxDef } = {
	press = { id = WOOD_1, volume = 0.4, speed = 1 },
	confirm = { id = WOOD_6, volume = 0.4, speed = 1.35 },
	tick = { id = WOOD_5, volume = 0.16, speed = 1.9 }, -- dialogue typing
	hit = { id = THUMP_BODY, volume = 0.55, speed = 1.1 },
	strongHit = { id = THUMP_BODY_B, volume = 0.7, speed = 0.9 },
	weakHit = { id = THUMP_BALL, volume = 0.4, speed = 1.3 },
	faint = { id = THUMP_STATUE, volume = 0.5, speed = 0.6 },
	swap = { id = WOOD_7, volume = 0.4, speed = 0.8 },
	win = { id = STING_WIN, volume = 0.5, speed = 1 },
	lose = { id = THUMP_STATUE, volume = 0.4, speed = 0.45 },
	count = { id = WOOD_8, volume = 0.16, speed = 1.9 },
	-- The catch: a swish, a wooden knock, a low creak, then a jingle for a catch.
	throw = { id = SWISH, volume = 0.35, speed = 0.8 },
	cinch = { id = WOOD_1, volume = 0.5, speed = 1.6 },
	tug = { id = WOOD_7, volume = 0.4, speed = 0.55 },
	slip = { id = WOOD_DOUBLE_B, volume = 0.35, speed = 1.4 },
	caught = { id = INSTRUMENT, volume = 1, speed = 1, jingle = "catch" },
	-- Moments that had no sound (Audio/Cues hooks them to the server's messages).
	battleStart = { id = WOOD_DOUBLE, volume = 0.45, speed = 0.9 },
	giantStart = { id = WOOD_DOUBLE, volume = 0.55, speed = 0.55 },
	levelUp = { id = INSTRUMENT, volume = 1, speed = 1, jingle = "levelUp" },
	hatch = { id = INSTRUMENT, volume = 1, speed = 1, jingle = "hatch" },
	questDone = { id = INSTRUMENT, volume = 1, speed = 1, jingle = "questDone" },
	badge = { id = INSTRUMENT, volume = 1, speed = 1, jingle = "badge" },
	heal = { id = INSTRUMENT, volume = 1, speed = 1, jingle = "heal" },
	journal = { id = INSTRUMENT, volume = 1, speed = 1, jingle = "journal" },
	spotted = { id = INSTRUMENT, volume = 1, speed = 1, jingle = "tamerSpotted" }, -- the "!"
	buy = { id = WOOD_6, volume = 0.4, speed = 1.7 },
	find = { id = INSTRUMENT, volume = 1, speed = 1, jingle = "itemGet" },
	travel = { id = WOOD_DOUBLE, volume = 0.35, speed = 0.6 },
	grass = { id = RUSTLE, volume = 0.22, speed = 1.2 }, -- walking into tall grass
}
AudioConfig.SFX = SFX

-- A creature's cry: a few soft plucked notes (the jingle instrument) at the species' pitch and
-- note count (content/SpeciesQuirks). `rise` lifts each note a share above the one before;
-- `volume` is low so a cry sits under the music; `caughtDelay` lets the catch jingle go first;
-- `foeDelay` staggers the second creature's cry when a battle opens.
AudioConfig.CRY = {
	id = JingleConfig.INSTRUMENT_ID,
	volume = 0.2,
	rise = 0.07,
	entranceDelay = 0.35, -- seconds after a creature steps into a battle
	foeDelay = 0.6, -- extra, for the opponent, so the two cries do not pile up
	caughtDelay = 0.3, -- seconds after the New friend card shows
}

-- Seconds to wait before a cue that follows another sound (the win jingle, then the level up).
-- Throttles: the dialogue tick is at most this often, the grass rustle at most this often while
-- walking through a tall-grass patch.
AudioConfig.TICK_GAP = 0.045
AudioConfig.GRASS_GAP = 0.7
AudioConfig.LEVEL_UP_DELAY = 1.4
AudioConfig.BADGE_DELAY = 2.2

return AudioConfig
