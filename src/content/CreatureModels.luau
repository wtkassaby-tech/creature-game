--!strict
-- The model each creature is shown with, where it has one: a mesh and its painted texture, by
-- Roblox asset id, the size it stands at for a creature of size 1 (studs), and how far to turn
-- it so that it faces forward. Data only.
--
-- These were made with Roblox Studio's own model generator from the "Look" written in each
-- species file (23 November 2026; docs/ASSETS.md), and are whole bodies. They are what a player
-- sees until the part meshes exist; a species without one here falls back to its toy sketch.

export type ModelDef = { mesh: string, texture: string, size: { number }, turn: number? }

local CreatureModels: { [string]: ModelDef } = {
	Sloshcalf = {
		mesh = "rbxassetid://88153719600532",
		texture = "rbxassetid://111085619870020",
		size = { 3.94, 6, 3.02 },
	},
	Mossmitt = {
		mesh = "rbxassetid://89558396491439",
		texture = "rbxassetid://86688736852693",
		size = { 4.14, 6, 3.67 },
	},
	Gorsling = {
		mesh = "rbxassetid://98325678775323",
		texture = "rbxassetid://103824289232581",
		size = { 3.54, 5.31, 7 },
	},
	Spadesnout = {
		mesh = "rbxassetid://87406395197801",
		texture = "rbxassetid://96292375578697",
		size = { 3.43, 5, 5.57 },
	},
	Stiltbark = {
		mesh = "rbxassetid://72042981596562",
		texture = "rbxassetid://96364171168815",
		size = { 2.96, 8, 4.45 },
	},
	Stumpwarden = {
		mesh = "rbxassetid://82809462188449",
		texture = "rbxassetid://81036931002515",
		size = { 4.3, 6, 4.1 },
	},
	Splashjack = {
		mesh = "rbxassetid://73107217783844",
		texture = "rbxassetid://126015982566927",
		size = { 4.16, 6, 5.78 },
	},
	Burlhorn = {
		mesh = "rbxassetid://71889220867841",
		texture = "rbxassetid://100242962567609",
		size = { 3.66, 5.5, 7.58 },
	},
}

return CreatureModels
