--!strict
-- The daily tasks: three easy and three harder, the same every day (approval pack 3). What
-- each pays comes from EconomyConfig; this file says only what is counted. Data only.

export type Counts = "WinBattle" | "Tame" | "Breed" | "WinWild" | "GiantRematch" | "TamerRematch"
export type Task = {
	id: string,
	hard: boolean,
	goal: string, -- the short text on screen
	counts: Counts,
	count: number,
}

local DailyTasks: { Task } = {
	{ id = "win_three", hard = false, goal = "Win 3 battles", counts = "WinBattle", count = 3 },
	{ id = "tame_one", hard = false, goal = "Tame a creature", counts = "Tame", count = 1 },
	{ id = "breed_one", hard = false, goal = "Breed once", counts = "Breed", count = 1 },
	{
		id = "wild_thirty",
		hard = true,
		goal = "Win 30 wild battles",
		counts = "WinWild",
		count = 30,
	},
	{
		id = "giant_again",
		hard = true,
		goal = "Win a giant rematch",
		counts = "GiantRematch",
		count = 1,
	},
	{
		id = "tamers_five",
		hard = true,
		goal = "Win 5 tamer rematches",
		counts = "TamerRematch",
		count = 5,
	},
}

return DailyTasks
