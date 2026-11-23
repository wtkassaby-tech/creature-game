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
		-- Low-detail (about 400 triangles), 23 November 2026: thousands of these line every
		-- edge, and the first version put millions of triangles on screen.
		mesh = "rbxassetid://84741546858434",
		texture = "rbxassetid://138040291921453",
		size = { 4, 2.73, 3.94 },
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
	-- Dust Canyon (docs/plans/09_DUST_CANYON_MAP.md section 5)
	CanyonArch = {
		mesh = "rbxassetid://94831036269192",
		texture = "rbxassetid://103313329721305",
		size = { 14.64, 13.98, 6 },
	},
	AdobeHouse = {
		mesh = "rbxassetid://103831095703014",
		texture = "rbxassetid://128467975113266",
		size = { 14.94, 18, 16.02 },
	},
	KilnCottage = {
		mesh = "rbxassetid://125710218368326",
		texture = "rbxassetid://112199485665997",
		size = { 16.78, 18.94, 18 },
	},
	TradingPost = {
		mesh = "rbxassetid://140614905092438",
		texture = "rbxassetid://131854734889369",
		size = { 21.8, 25.64, 20 },
	},
	BottleKiln = {
		mesh = "rbxassetid://101371434213151",
		texture = "rbxassetid://87856019932300",
		size = { 24.26, 27.18, 26 },
	},
	WindTower = {
		mesh = "rbxassetid://116582187331562",
		texture = "rbxassetid://130926373786313",
		size = { 16, 32.63, 15.26 },
	},
	StairGate = {
		mesh = "rbxassetid://111981237181169",
		texture = "rbxassetid://107639396503943",
		size = { 26.06, 20.75, 16 },
	},
	RockSpire = {
		mesh = "rbxassetid://116218017862560",
		texture = "rbxassetid://74366126244368",
		size = { 10, 20.89, 9.97 },
	},
	ScrubBush = {
		mesh = "rbxassetid://84961450488135",
		texture = "rbxassetid://127730714528766",
		size = { 4.05, 4, 3.94 },
	},
	DryTuft = {
		mesh = "rbxassetid://140594087130507",
		texture = "rbxassetid://90720783128319",
		size = { 2.64, 2.5, 2.61 },
	},
	CliffWall = {
		-- Low-detail (under 800 triangles), 23 November 2026: hundreds of these line the
		-- terraces and canyons.
		mesh = "rbxassetid://128084726086625",
		texture = "rbxassetid://86364971552660",
		size = { 22, 7.63, 7.94 },
	},
	Boulders = {
		-- Low-detail (about 400 triangles), 23 November 2026: thousands of these line every
		-- edge, and the first version put millions of triangles on screen.
		mesh = "rbxassetid://129301203865263",
		texture = "rbxassetid://85100410731112",
		size = { 5.74, 3.54, 5 },
	},
	-- Tide Flats (docs/plans/10_TIDE_FLATS_MAP.md section 5)
	HarbourArch = {
		mesh = "rbxassetid://137162945661276",
		texture = "rbxassetid://90217980784020",
		size = { 15.23, 14.02, 6 },
	},
	StiltHouse = {
		mesh = "rbxassetid://88643122021510",
		texture = "rbxassetid://117558381982189",
		size = { 17.02, 18.82, 18 },
	},
	NetLoft = {
		mesh = "rbxassetid://111152835943745",
		texture = "rbxassetid://131756071914431",
		size = { 20, 17.98, 13.75 },
	},
	Chandlery = {
		mesh = "rbxassetid://94560295444105",
		texture = "rbxassetid://130707199901239",
		size = { 24, 20.62, 17.4 },
	},
	LampTower = {
		mesh = "rbxassetid://74534541286638",
		texture = "rbxassetid://118012307125977",
		size = { 16, 27.96, 14.83 },
	},
	BreakwaterGate = {
		mesh = "rbxassetid://79397220878921",
		texture = "rbxassetid://84903643861992",
		size = { 36.34, 29.12, 16 },
	},
	OldLighthouse = {
		mesh = "rbxassetid://94349549838379",
		texture = "rbxassetid://96149118364646",
		size = { 18, 28.75, 17.77 },
	},
	ShipRibs = {
		mesh = "rbxassetid://131179034326921",
		texture = "rbxassetid://73895156668602",
		size = { 14.77, 21.65, 24 },
	},
	SeaCave = {
		mesh = "rbxassetid://132368323720467",
		texture = "rbxassetid://90314883818563",
		size = { 18.65, 15.89, 18 },
	},
	MarramTuft = {
		-- Low-detail, 23 November 2026: hundreds of these line Tide Flats.
		mesh = "rbxassetid://114948664116893",
		texture = "rbxassetid://113849133027278",
		size = { 2.95, 3.12, 3 },
	},
	-- Tide Flats, small pieces
	Kelp = {
		mesh = "rbxassetid://71966148332469",
		texture = "rbxassetid://109981186234431",
		size = { 4, 3.82, 3.97 },
	},
	SeaRocks = {
		-- Low-detail (about 400 triangles), 23 November 2026: thousands of these line every
		-- edge, and the first version put millions of triangles on screen.
		mesh = "rbxassetid://81091229103104",
		texture = "rbxassetid://109215229286720",
		size = { 4.4, 5, 4.31 },
	},
	Rowboat = {
		mesh = "rbxassetid://91466779554077",
		texture = "rbxassetid://111785511691000",
		size = { 2.88, 1.93, 5 },
	},
	-- Tide Flats' grey sea cliff piece (the SeaCliff edge style)
	SeaCliff = {
		mesh = "rbxassetid://116568389077803",
		texture = "rbxassetid://119424852006008",
		size = { 12.2, 12.08, 12 },
	},
	-- Terraces (plan 12): a grassy earth bank tiled along each Earth tier face (23 November 2026).
	EarthBank = {
		-- Low-detail (under 800 triangles), 23 November 2026: hundreds of these line the
		-- terraces and canyons.
		mesh = "rbxassetid://74756103378786",
		texture = "rbxassetid://113351444068796",
		size = { 6.35, 5, 4.2 },
	},
	-- Stairs and ramps between tiers (plan 12): low end at the model's front (-z).
	StoneSteps = {
		mesh = "rbxassetid://109683244653495",
		texture = "rbxassetid://70479128876101",
		size = { 6.94, 9, 10.12 },
	},
	EarthRamp = {
		mesh = "rbxassetid://124289960017648",
		texture = "rbxassetid://78248099068134",
		size = { 6.82, 8, 8.01 },
	},
	-- Far scenery and fill (plan 13 step 3, 23 November 2026): a snow-capped peak for the Crown
	-- and the north, a wooded hill for the highlands, a cloud for the halo, a dune with marram.
	SnowPeak = {
		mesh = "rbxassetid://108310861437157",
		texture = "rbxassetid://122914862632913",
		size = { 29.99, 19.89, 30 },
	},
	WoodedHill = {
		mesh = "rbxassetid://139407037486835",
		texture = "rbxassetid://96266392767644",
		size = { 40.2, 14.55, 40 },
	},
	Cloud = {
		mesh = "rbxassetid://74547756459832",
		texture = "rbxassetid://115762689237166",
		size = { 28.97, 17.01, 30 },
	},
	SandDune = {
		-- Low-detail, 23 November 2026: hundreds of these line Tide Flats.
		mesh = "rbxassetid://102879198803815",
		texture = "rbxassetid://109337496665521",
		size = { 13.43, 10, 13.5 },
	},
	-- A cheap dune for the fill's farthest blocks; the detailed SandDune stays near the paths.
	SandDuneLow = {
		mesh = "rbxassetid://134687502938843",
		texture = "rbxassetid://138064220553422",
		size = { 7.5, 2.97, 16 },
	},
}

return PropModels
