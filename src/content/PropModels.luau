--!strict
-- The painted models the test map is dressed with: buildings, trees, a well, lamp posts and
-- villagers. Each is a mesh and its texture by Roblox asset id, its natural size in studs, and
-- how far to turn it so that its front faces forward. Data only.
--
-- Made with Roblox Studio's own model generator from our own descriptions (23 November 2026;
-- docs/ASSETS.md). A piece that is missing here is drawn from plain shapes instead.

export type ModelDef = { mesh: string, texture: string, size: { number }, turn: number? }

local PropModels: { [string]: ModelDef } = {
	Cottage = {
		mesh = "rbxassetid://105859660087670",
		texture = "rbxassetid://124884087801310",
		size = { 24.33, 24, 25.33 },
	},
	Shop = {
		mesh = "rbxassetid://96179285099777",
		texture = "rbxassetid://100434776495779",
		size = { 20.7, 24, 15.48 },
	},
	Healer = {
		mesh = "rbxassetid://74623159680022",
		texture = "rbxassetid://87263992781262",
		size = { 16.52, 24, 17.24 },
	},
	Tree = {
		mesh = "rbxassetid://131082052776945",
		texture = "rbxassetid://118458605368938",
		size = { 14, 15.54, 13.51 },
	},
	Pine = {
		mesh = "rbxassetid://121341856762501",
		texture = "rbxassetid://117320179366546",
		size = { 12, 18.44, 10.92 },
	},
	Bush = {
		mesh = "rbxassetid://87032599633128",
		texture = "rbxassetid://136271338465195",
		size = { 3.44, 4, 3.24 },
	},
	Lamp = {
		mesh = "rbxassetid://94441050764075",
		texture = "rbxassetid://93835114123895",
		size = { 3, 6.36, 1.15 },
	},
	Well = {
		mesh = "rbxassetid://129373922855631",
		texture = "rbxassetid://135195250053253",
		size = { 8, 7.34, 5.47 },
	},
	Shopkeeper = {
		mesh = "rbxassetid://134263196449900",
		texture = "rbxassetid://96842098965665",
		size = { 3.97, 5.66, 3 },
	},
	Mentor = {
		mesh = "rbxassetid://106872875421838",
		texture = "rbxassetid://105434983893855",
		size = { 3.13, 4.5, 3 },
	},
	Tamer = {
		mesh = "rbxassetid://127463043210030",
		texture = "rbxassetid://108483295166572",
		size = { 3.18, 5.3, 3 },
	},
	Rival = {
		mesh = "rbxassetid://125405426806362",
		texture = "rbxassetid://80001629612418",
		size = { 2.66, 6, 2.73 },
	},
}

return PropModels
