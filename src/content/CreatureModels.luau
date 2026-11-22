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
	-- Dust Canyon
	Duneskit = {
		mesh = "rbxassetid://96012957016164",
		texture = "rbxassetid://96531496946685",
		size = { 2.78, 6, 5.7 },
	},
	Thatchling = {
		mesh = "rbxassetid://130507681027192",
		texture = "rbxassetid://113419826150254",
		size = { 4.85, 7, 3.3 },
	},
	Wadibuck = {
		mesh = "rbxassetid://131450818451720",
		texture = "rbxassetid://77170353510199",
		size = { 3.41, 7, 5.13 },
	},
	Spurlet = {
		mesh = "rbxassetid://77670204494847",
		texture = "rbxassetid://120064062249068",
		size = { 3.06, 5, 5.39 },
	},
	Spirecap = {
		mesh = "rbxassetid://124373840906518",
		texture = "rbxassetid://127647793761402",
		size = { 5.66, 6.5, 7 },
	},
	Cairnback = {
		mesh = "rbxassetid://82902934798690",
		texture = "rbxassetid://100508861737593",
		size = { 4.95, 6, 6.15 },
	},
	Whirlgrit = {
		mesh = "rbxassetid://132116005977696",
		texture = "rbxassetid://88773151107356",
		size = { 4.35, 5.26, 5 },
	},
	Flintknap = {
		mesh = "rbxassetid://122638617134798",
		texture = "rbxassetid://119657784227242",
		size = { 5.78, 7, 4.55 },
	},
	-- Greenwood's giant
	Hollowbough = {
		mesh = "rbxassetid://122657283771846",
		texture = "rbxassetid://117761252952703",
		size = { 8.31, 12, 8.48 },
	},
	-- Tide Flats
	Runnelfin = {
		mesh = "rbxassetid://71730391961022",
		texture = "rbxassetid://128111653342334",
		size = { 4, 5.99, 4.94 },
	},
	Hullock = {
		mesh = "rbxassetid://81622553424635",
		texture = "rbxassetid://117057963405964",
		size = { 4.5, 5.74, 9.6 },
	},
	Lanternell = {
		mesh = "rbxassetid://115453843318026",
		texture = "rbxassetid://125804188854344",
		size = { 3.72, 8, 2.74 },
	},
	Cocklemole = {
		mesh = "rbxassetid://132241773203326",
		texture = "rbxassetid://105326939190153",
		size = { 4.06, 5, 4.05 },
	},
	Clapshell = {
		mesh = "rbxassetid://123047837392569",
		texture = "rbxassetid://114558048918523",
		size = { 5.62, 6, 4.84 },
	},
	Glissot = {
		mesh = "rbxassetid://101123377513492",
		texture = "rbxassetid://124113147819843",
		size = { 4.29, 5, 4.2 },
	},
	-- Tide Flats: the last two, and its giant
	Gulpmaw = {
		mesh = "rbxassetid://133125823460412",
		texture = "rbxassetid://120615190804188",
		size = { 4.5, 4.19, 3.46 },
	},
	Moatkeep = {
		mesh = "rbxassetid://108284213071133",
		texture = "rbxassetid://90051137718974",
		size = { 5, 4.05, 3.03 },
	},
	Carrackon = {
		mesh = "rbxassetid://92543915503643",
		texture = "rbxassetid://121888063897348",
		size = { 9.46, 8.03, 12 },
	},
	-- Dust Canyon's giant
	Mesalith = {
		mesh = "rbxassetid://103954756558850",
		texture = "rbxassetid://129360628977500",
		size = { 7.48, 12, 6.82 },
	},
	-- The Mire, and its giant
	Bogbellow = {
		mesh = "rbxassetid://132556268634999",
		texture = "rbxassetid://96022600637161",
		size = { 4.31, 4.95, 7 },
	},
	Fenwhisk = {
		mesh = "rbxassetid://128116311293978",
		texture = "rbxassetid://72407552202501",
		size = { 2.7, 5.5, 3.22 },
	},
	Keelsnap = {
		mesh = "rbxassetid://136549620543220",
		texture = "rbxassetid://103108120391008",
		size = { 3.82, 4.43, 4.5 },
	},
	Lilyshade = {
		mesh = "rbxassetid://77054853861528",
		texture = "rbxassetid://93152035154442",
		size = { 4.49, 6.24, 4.5 },
	},
	Mistrel = {
		mesh = "rbxassetid://75690339947754",
		texture = "rbxassetid://88859080025253",
		size = { 4, 4.56, 6.32 },
	},
	Skipslick = {
		mesh = "rbxassetid://97780803103581",
		texture = "rbxassetid://115907363812644",
		size = { 3.92, 6.5, 3.79 },
	},
	Sloughback = {
		mesh = "rbxassetid://96775885247781",
		texture = "rbxassetid://109042001255363",
		size = { 7.79, 8, 13.8 },
	},
	Bulbroth = {
		mesh = "rbxassetid://88037621374668",
		texture = "rbxassetid://135303179888714",
		size = { 4.34, 5.09, 4 },
	},
	Snaggar = {
		mesh = "rbxassetid://120434234434736",
		texture = "rbxassetid://70819400297950",
		size = { 3.3, 3.5, 6.35 },
	},
}

return CreatureModels
