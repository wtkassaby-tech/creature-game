--!strict
-- Installs the placeholder species and moves into the content registries for a test run.
-- Tests call install() once at the top; nothing here ships in the game.

local Moves = require("../../src/content/Moves")
local PlaceholderMoves = require("./PlaceholderMoves")
local PlaceholderSpecies = require("./PlaceholderSpecies")
local Species = require("../../src/content/Species")

local Placeholders = {}

Placeholders.NAMES = { "Mossback", "Dartlet", "Brindle" }

function Placeholders.install()
	for name, def in PlaceholderSpecies do
		Species[name] = def
	end
	for name, def in PlaceholderMoves do
		Moves[name] = def
	end
end

return Placeholders
