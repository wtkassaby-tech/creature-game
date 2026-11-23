--!strict
-- Pure maths for playing one sampled note at many pitches: semitones to Sound.PlaybackSpeed, and
-- a list of notes (semitone offset, length in beats) to start times in seconds. No Roblox calls.

local Pitch = {}

export type Note = { semitone: number, beats: number }
export type Event = { start: number, speed: number, beats: number }

-- Playing a sample n semitones up is playing it 2^(n/12) times as fast (12 is one octave).
function Pitch.speed(semitones: number): number
	return 2 ^ (semitones / 12)
end

-- Where each note starts. A note begins when the one before it ends; `bpm` is beats per minute.
function Pitch.timeline(notes: { Note }, bpm: number): { Event }
	local events: { Event } = {}
	local secondsPerBeat = 60 / bpm
	local beat = 0
	for _, note in notes do
		table.insert(events, {
			start = beat * secondsPerBeat,
			speed = Pitch.speed(note.semitone),
			beats = note.beats,
		})
		beat += note.beats
	end
	return events
end

-- Seconds from the first note's start to the end of the last.
function Pitch.length(notes: { Note }, bpm: number): number
	local beats = 0
	for _, note in notes do
		beats += note.beats
	end
	return beats * 60 / bpm
end

export type CryNote = { start: number, speed: number }

local SPEED_MIN, SPEED_MAX = 0.25, 4

-- A creature's cry: `notes` short sounds `gap` seconds apart, the first at playback speed
-- `pitch` (1 is the sample's own) and each after it `rise` higher as a share, so a cry lifts a
-- little like a question or a chirp. At least one note.
function Pitch.cry(pitch: number, notes: number, gap: number, rise: number): { CryNote }
	local list: { CryNote } = {}
	for index = 1, math.max(1, math.floor(notes)) do
		table.insert(list, {
			start = (index - 1) * math.max(0, gap),
			speed = math.clamp(pitch * (1 + rise * (index - 1)), SPEED_MIN, SPEED_MAX),
		})
	end
	return list
end

return Pitch
