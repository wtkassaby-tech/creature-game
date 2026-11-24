--!strict
-- Short original jingles as data: each is a list of notes (semitones above the sample's own pitch,
-- length in beats) played by one instrument sample at different speeds (src/shared/Pitch,
-- src/client/Audio/Jingle). Tunes are our own; they copy no known melody. All [Default]s to tune
-- by ear. The semitone numbers use a major-ish scale: 0 2 4 5 7 9 11 12 (12 is an octave up).

local JingleConfig = {}

export type Note = { semitone: number, beats: number }
export type Jingle = { bpm: number, volume: number, notes: { Note } }

-- Pro Sound Effects "Violin String Pluck Single Notes Some Muted 17": a plucked, wood-like note.
-- Not yet heard in Studio; swap the id if it sounds wrong, nothing else changes.
JingleConfig.INSTRUMENT_ID = "rbxassetid://9126162371"
JingleConfig.INSTRUMENT_VOLUME = 0.4

local function n(semitone: number, beats: number): Note
	return { semitone = semitone, beats = beats }
end

local JINGLES: { [string]: Jingle } = {
	-- A soft climb that settles: the healer finishing.
	heal = { bpm = 132, volume = 0.9, notes = { n(0, 1), n(4, 1), n(7, 1), n(12, 1), n(11, 2) } },
	-- A little skip and a long note: the lasso holds.
	catch = {
		bpm = 150,
		volume = 1,
		notes = { n(2, 0.5), n(7, 0.5), n(5, 0.5), n(9, 0.5), n(14, 2.5) },
	},
	-- Quick and bright: picked something up.
	itemGet = { bpm = 170, volume = 0.8, notes = { n(4, 0.5), n(11, 0.5), n(9, 0.5), n(16, 1.5) } },
	-- A zigzag upward.
	levelUp = {
		bpm = 160,
		volume = 1,
		notes = { n(0, 0.5), n(4, 0.5), n(2, 0.5), n(7, 0.5), n(5, 0.5), n(12, 2) },
	},
	-- Broad and proud: a gym badge.
	badge = {
		bpm = 112,
		volume = 1,
		notes = { n(7, 1), n(12, 1), n(11, 0.5), n(14, 0.5), n(19, 3) },
	},
	-- A neat little resolve.
	questDone = {
		bpm = 150,
		volume = 0.9,
		notes = { n(0, 0.5), n(5, 0.5), n(9, 0.5), n(7, 0.5), n(12, 2) },
	},
	-- Sharp and short: a tamer has seen you.
	tamerSpotted = { bpm = 190, volume = 1, notes = { n(9, 0.5), n(9, 0.5), n(16, 1.5) } },
	-- Something written down: gentle, a low settle.
	journal = { bpm = 120, volume = 0.8, notes = { n(4, 0.5), n(0, 0.5), n(7, 2) } },
	-- Cracks, then bubbles up: an egg hatches.
	hatch = {
		bpm = 140,
		volume = 1,
		notes = { n(0, 0.5), n(3, 0.5), n(7, 0.5), n(10, 0.5), n(12, 0.5), n(19, 2.5) },
	},
}
JingleConfig.JINGLES = JINGLES

return JingleConfig
