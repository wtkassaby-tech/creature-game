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
	Carer = {
		mesh = "rbxassetid://112826814903729",
		texture = "rbxassetid://94022202139377",
		size = { 2.65, 5.36, 3 },
	},
	GirlTamer = {
		mesh = "rbxassetid://90600276834758",
		texture = "rbxassetid://93305984311114",
		size = { 3.38, 6, 2.31 },
	},
	Grandmother = {
		mesh = "rbxassetid://75980247652960",
		texture = "rbxassetid://89782871390988",
		size = { 3.11, 6.19, 3 },
	},
	-- The designed Greenwood map (docs/plans/08_GREENWOOD_MAP.md)
	Waystation = {
		mesh = "rbxassetid://79958116604409",
		texture = "rbxassetid://75876234590042",
		size = { 19.99, 37.59, 20 },
	},
	Gatehouse = {
		mesh = "rbxassetid://87056659357964",
		texture = "rbxassetid://94264757221587",
		size = { 26.78, 19.64, 14 },
	},
	-- A golden oak with a round, rooted trunk (the first try had a square one).
	AncientTree = {
		mesh = "rbxassetid://114095487046982",
		texture = "rbxassetid://114156806187872",
		size = { 56, 64, 52.3 },
	},
	VillageArch = {
		mesh = "rbxassetid://115744713494140",
		texture = "rbxassetid://78919905690989",
		size = { 15.9, 14.9, 6 },
	},
	CottageBlue = {
		mesh = "rbxassetid://113914046494128",
		texture = "rbxassetid://115412098124800",
		size = { 21.7, 20, 16 },
	},
	CottageMoss = {
		mesh = "rbxassetid://120930615629458",
		texture = "rbxassetid://130020925359678",
		size = { 21.4, 20, 21.3 },
	},
	AppleCart = {
		mesh = "rbxassetid://136748752214368",
		texture = "rbxassetid://78945263935849",
		size = { 7.8, 9, 5.6 },
	},
	WashingLine = {
		mesh = "rbxassetid://117208821191074",
		texture = "rbxassetid://113408208477191",
		size = { 10.6, 8, 1.6 },
	},
	Barrels = {
		mesh = "rbxassetid://97123620414873",
		texture = "rbxassetid://118437046884539",
		size = { 8, 6.7, 5.5 },
	},
	AppleTree = {
		mesh = "rbxassetid://134795896466827",
		texture = "rbxassetid://128101296679369",
		size = { 14, 16, 12.3 },
	},
	Birch = {
		mesh = "rbxassetid://91570444640112",
		texture = "rbxassetid://135994710117643",
		size = { 10, 11.48, 8.88 },
	},
	GrassTuft = {
		mesh = "rbxassetid://105548972928950",
		texture = "rbxassetid://85032178948082",
		size = { 3.88, 2.46, 4 },
	},
	Reeds = {
		mesh = "rbxassetid://96689505875971",
		texture = "rbxassetid://82923739034964",
		size = { 4, 6.97, 3.41 },
	},
	FenceSection = {
		mesh = "rbxassetid://103110993203016",
		texture = "rbxassetid://74200621045872",
		size = { 7.12, 2.94, 1 },
	},
	Signpost = {
		mesh = "rbxassetid://96883465317972",
		texture = "rbxassetid://105933815528333",
		size = { 2.58, 3.28, 1.5 },
	},
	Footbridge = {
		mesh = "rbxassetid://75910119902251",
		texture = "rbxassetid://101658257024988",
		size = { 9.07, 6, 10.43 },
	},
	NoticeBoard = {
		mesh = "rbxassetid://84774353474635",
		texture = "rbxassetid://80236184522266",
		size = { 5.44, 5.36, 2 },
	},
	Bench = {
		mesh = "rbxassetid://79383549176918",
		texture = "rbxassetid://105141889591859",
		size = { 5.6, 3.84, 3 },
	},
	Stall = {
		mesh = "rbxassetid://126971401304048",
		texture = "rbxassetid://120047194234084",
		size = { 9.48, 10, 7.46 },
	},
}

return PropModels
