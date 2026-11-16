--!strict
-- Every move in the game, by name. Parts bring moves (see each species file);
-- this table says what each move does. Data only.

local Types = require("../shared/Types")

export type MoveDef = { element: Types.Element, power: number }

local Moves: { [string]: MoveDef } = {}

return Moves
