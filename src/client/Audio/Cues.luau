--!strict
-- Sounds for moments that no screen plays itself: a battle or giant starting, a level up, a win
-- over a giant, an egg hatching, a quest handed in, a badge, a purchase and a find. Each listens
-- to the server's message through the Bus, so the screens that show them stay untouched. Sounds
-- only; nothing here decides anything in play. The music ducks under a win or loss jingle.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AudioConfig = require(ReplicatedStorage.config.AudioConfig)
local Bus = require(script.Parent.Parent.Net.Bus)
local Music = require(script.Parent.Music)
local Net = require(ReplicatedStorage.net.generated.Client)
local Sfx = require(script.Parent.Sfx)

local Cues = {}

local SUCCESS: { [string]: boolean } = { Found = true, Gathered = true, Read = true, Built = true }

function Cues.start()
	Bus.listen(Net.BattleStarted, function()
		Sfx.play("battleStart")
	end)
	Bus.listen(Net.GiantStarted, function()
		Sfx.play("giantStart")
	end)

	-- A won battle: the result panel plays the win jingle; the music ducks under it, and a level
	-- up follows once the jingle has had its moment.
	Bus.listen(Net.BattleRewards, function(value)
		Music.duck()
		for _, member in value.Members do
			if member.LevelsGained > 0 then
				task.delay(AudioConfig.LEVEL_UP_DELAY, function()
					Sfx.play("levelUp")
				end)
				break
			end
		end
	end)

	-- A giant fight ends with its own message; the giant screen has no win or lose sound.
	Bus.listen(Net.GiantTurn, function(value)
		if value.Finished then
			Music.duck()
			Sfx.play(if value.Won then "win" else "lose")
		end
	end)

	Bus.listen(Net.Hatched, function()
		Sfx.play("hatch")
	end)
	Bus.listen(Net.QuestUpdate, function(value)
		if value.Change == "Done" then
			Sfx.play("questDone")
		end
	end)
	Bus.listen(Net.BuyResult, function(value)
		if value.Ok then
			Sfx.play("buy")
		end
	end)
	Bus.listen(Net.SearchResult, function(value)
		if value.Outcome == "Read" or value.SetDone then
			Sfx.play("journal") -- a note written into the journal
		elseif SUCCESS[value.Outcome] then
			Sfx.play("find")
		end
	end)

	-- A new badge shows up as a higher count in the saved state (the first state is not a gain).
	local badges: number? = nil
	Bus.listen(Net.PlayerState, function(value)
		local before = badges
		badges = value.Badges
		if before and value.Badges > before then
			task.delay(AudioConfig.BADGE_DELAY, function()
				Sfx.play("badge")
			end)
		end
	end)
end

return Cues
