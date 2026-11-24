--!strict
-- Which painted person a name wears in the world, and which speaker names that gives a face to.
-- The world dresses a person from the name they are given (src/server/World/Dressing.luau): a
-- keyword in the name picks a fixed model, anything else is one of two tamers chosen by the
-- first number of a Random seeded from the name. This module repeats that rule, so dialogue can
-- show the same face as the person standing in the world. Keep `villager` and `seedFor` in step
-- with Dressing.villager and Markers.person. Pure: the Random is passed in as `coin`.

local PersonModel = {}

export type Person = {
	-- The full name a speaker's name is read from: "Hepzibah Marr", or an id such as "tamsin_rook".
	name: string,
	-- The name the world gives the person's block, which fixes their look. It differs from
	-- `name` for story battles, whose block is called "Name (battle_id)".
	worldName: string,
}

-- The seed Markers.person gives the Random that dresses a person.
function PersonModel.seedFor(worldName: string): number
	return #worldName * 131 + string.byte(worldName, 1) + string.byte(worldName, #worldName)
end

-- The model a person wears. `coin` is the first NextNumber() of Random.new(seedFor(worldName)).
function PersonModel.villager(worldName: string, coin: number): string
	local lower = string.lower(worldName)
	if string.find(lower, "mentor", 1, true) then
		return "Mentor"
	elseif string.find(lower, "rival", 1, true) then
		return "Rival"
	elseif string.find(lower, "healer", 1, true) then
		return "Carer"
	elseif string.find(lower, "breeder", 1, true) then
		return "Grandmother"
	elseif string.find(lower, "tuppence", 1, true) or string.find(lower, "_keeper", 1, true) then
		return "Shopkeeper"
	end
	return if coin < 0.5 then "Tamer" else "GirlTamer"
end

-- The words a speaker could be called by: the first and last word of the name ("Hepzibah Marr"
-- is spoken as "Hepzibah" or "Marr"), lower case. Words split on spaces and underscores.
function PersonModel.callNames(name: string): { string }
	local words: { string } = {}
	for word in string.gmatch(string.lower(name), "[^%s_]+") do
		table.insert(words, word)
	end
	if #words == 0 then
		return {}
	elseif #words == 1 then
		return { words[1] }
	end
	return { words[1], words[#words] }
end

-- Speaker name (lower case) to model, for every person given. A call name that two different
-- people share, who wear different models, is left out: better none than the wrong face.
function PersonModel.index(
	people: { Person },
	coinFor: (seed: number) -> number
): { [string]: string }
	local found: { [string]: string } = {}
	local clash: { [string]: boolean } = {}
	for _, person in people do
		local model =
			PersonModel.villager(person.worldName, coinFor(PersonModel.seedFor(person.worldName)))
		for _, call in PersonModel.callNames(person.name) do
			local before = found[call]
			if before and before ~= model then
				clash[call] = true
			end
			found[call] = model
		end
	end
	for call in clash do
		found[call] = nil
	end
	return found
end

return PersonModel
