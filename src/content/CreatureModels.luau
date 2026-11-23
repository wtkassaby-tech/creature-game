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
		-- 23 Nov 2026 redo: haystack-bodied thatch creature with a face (the old one was a palm tree)
		mesh = "rbxassetid://139410396275314",
		texture = "rbxassetid://129598052800229",
		size = { 4.07, 4.44, 4 },
	},
	Wadibuck = {
		mesh = "rbxassetid://131450818451720",
		texture = "rbxassetid://77170353510199",
		size = { 3.41, 7, 5.13 },
	},
	Spurlet = {
		-- 23 Nov 2026 redo: leafy succulent rosette creature with no shell (the old one was close to a famous grass turtle)
		mesh = "rbxassetid://106649610435296",
		texture = "rbxassetid://71140872435325",
		size = { 3.1, 2.78, 2.9 },
	},
	Spirecap = {
		mesh = "rbxassetid://124373840906518",
		texture = "rbxassetid://127647793761402",
		size = { 5.66, 6.5, 7 },
	},
	Cairnback = {
		-- 23 Nov 2026 redo: four-legged stack of trail stones with a sleepy face and a crooked top stone
		mesh = "rbxassetid://139455715729959",
		texture = "rbxassetid://127290225338770",
		size = { 3.28, 5, 3.28 },
	},
	Whirlgrit = {
		-- 23 Nov 2026 redo: striped spinning-top desert dancer with ribbon arms (the old one wore a sun hat and goggles)
		mesh = "rbxassetid://115048866390529",
		texture = "rbxassetid://106320611931314",
		size = { 4.3, 3.94, 3.2 },
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
		-- 23 Nov 2026 redo: green shore ox nested in an upturned boat hull (the old one looked like a famous block-game cow)
		mesh = "rbxassetid://123809206086440",
		texture = "rbxassetid://83841087007573",
		size = { 4.5, 4.78, 6.22 },
	},
	Lanternell = {
		-- 23 Nov 2026 redo: teal jelly-headed rock-pool creature on a coral base (the old one was a lighthouse on legs)
		mesh = "rbxassetid://122569941986148",
		texture = "rbxassetid://72681631507445",
		size = { 4.2, 6.8, 4.2 },
	},
	Cocklemole = {
		-- 23 Nov 2026 redo: beach mole with its own ribbed cockle shell grown on (the old one wore a hard hat)
		mesh = "rbxassetid://103264314100215",
		texture = "rbxassetid://70439315755447",
		size = { 3.19, 5, 3.16 },
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
		-- 23 Nov 2026 redo: round sand golem with a bumpy turret crown and rosy cheeks (the old one was a faceless sandcastle)
		mesh = "rbxassetid://96767009651781",
		texture = "rbxassetid://116039619309667",
		size = { 5.04, 6, 3.98 },
	},
	Carrackon = {
		mesh = "rbxassetid://92543915503643",
		texture = "rbxassetid://121888063897348",
		size = { 9.46, 8.03, 12 },
	},
	-- Dust Canyon's giant
	Mesalith = {
		-- 23 Nov 2026 redo: wide rock-shelled mesa tortoise giant (the old one was a smiling carrot)
		mesh = "rbxassetid://104362802661172",
		texture = "rbxassetid://128657627268515",
		size = { 9, 9.8, 13.4 },
	},
	-- The Mire, and its giant
	Bogbellow = {
		mesh = "rbxassetid://132556268634999",
		texture = "rbxassetid://96022600637161",
		size = { 4.31, 4.95, 7 },
	},
	Fenwhisk = {
		-- 23 Nov 2026 redo: slinky purple marsh weasel with a cattail tail, floppy ear and cheeky tongue (the old one held a flag)
		mesh = "rbxassetid://77334223120192",
		texture = "rbxassetid://121778977250184",
		size = { 2.32, 3.7, 5.5 },
	},
	Keelsnap = {
		-- 23 Nov 2026 redo: mud-brown hook-beaked snapper with a mossy shell and one tooth (the old one wore boxing gloves)
		mesh = "rbxassetid://119810185465230",
		texture = "rbxassetid://111183115780925",
		size = { 3.63, 4.4, 4.35 },
	},
	Lilyshade = {
		-- 23 Nov 2026 redo: violet marsh sprite hooded by a pink lily bud (the old one was blue with a lily pad)
		mesh = "rbxassetid://136488364615257",
		texture = "rbxassetid://119160765700160",
		size = { 4.5, 5.43, 4.5 },
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
