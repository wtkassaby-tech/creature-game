--!strict
-- Test fixtures: moves for the placeholder species. NOT game content.

local RealMoves = require("../../src/content/Moves")

local Moves: { [string]: RealMoves.MoveDef } = {
	-- Mossback
	Headbutt = { element = "Sand", power = 55 },
	["Moss Spit"] = { element = "Leaf", power = 50 },
	["Root Guard"] = { element = "Leaf", power = 40 },
	Stomp = { element = "Sand", power = 60 },
	Brace = { element = "Leaf", power = 35 },
	["Tail Sweep"] = { element = "Leaf", power = 45 },
	-- Dartlet
	Nip = { element = "Leaf", power = 40 },
	["Leaf Dart"] = { element = "Leaf", power = 55 },
	Sidestep = { element = "Storm", power = 35 },
	["Quick Jab"] = { element = "Storm", power = 45 },
	Dash = { element = "Storm", power = 50 },
	Feint = { element = "Leaf", power = 35 },
	-- Brindle
	Bite = { element = "Sand", power = 55 },
	Howl = { element = "Storm", power = 40 },
	["Shake Off"] = { element = "Water", power = 40 },
	Claw = { element = "Sand", power = 50 },
	Pounce = { element = "Sand", power = 55 },
	Lash = { element = "Water", power = 45 },
}

return Moves
