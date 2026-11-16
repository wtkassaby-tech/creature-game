--!strict
-- Seeded random numbers that give the same sequence under Lune and in Roblox,
-- so a breed can be replayed from its seed in tests and in the breed log.
-- Park-Miller "minstd": every product stays below 2^53, so doubles are exact.

local MODULUS = 2147483647
local MULTIPLIER = 48271

export type Rng = {
	state: number,
}

local Rng = {}

function Rng.new(seed: number): Rng
	local state = math.floor(seed) % MODULUS
	if state <= 0 then
		state += MODULUS - 1
	end
	local rng = { state = state }
	-- The first few outputs of minstd are correlated with the seed; discard them.
	for _ = 1, 4 do
		Rng.next(rng)
	end
	return rng
end

-- A float in [0, 1).
function Rng.next(rng: Rng): number
	rng.state = (rng.state * MULTIPLIER) % MODULUS
	return (rng.state - 1) / (MODULUS - 1)
end

-- An integer in [low, high].
function Rng.int(rng: Rng, low: number, high: number): number
	return low + math.floor(Rng.next(rng) * (high - low + 1))
end

function Rng.chance(rng: Rng, probability: number): boolean
	return Rng.next(rng) < probability
end

function Rng.pick<T>(rng: Rng, list: { T }): T
	return list[Rng.int(rng, 1, #list)]
end

return Rng
