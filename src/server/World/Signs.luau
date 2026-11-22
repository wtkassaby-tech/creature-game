--!strict
-- Town arches and signposts, with their words painted on cream boards in the kit's pixel font
-- (docs/plans/08_GREENWOOD_MAP.md section 5). The posts block the way; the boards do not.

local Props = require(script.Parent.Props)

local Signs = {}

local TIMBER = Props.rgb(120, 84, 56)
local CREAM = Props.rgb(244, 232, 208)
local ROOF = Props.rgb(96, 150, 84)

-- The other way round: an arrow on the far side of a board points the opposite way.
local function mirrored(text: string): string
	local swapped = string.gsub(text, "←", "<<left>>")
	swapped = string.gsub(swapped, "→", "←")
	swapped = string.gsub(swapped, "<<left>>", "→")
	return swapped
end

local PAINTED_ARCH_TALL = 23 -- wide enough at this height for the street to pass between its posts
local PAINTED_BOARD_HALF = 1.35 -- from the middle of its hanging board to just clear of a face

-- A town arch facing `faces` (out of town): two timber posts 18 apart, a crossbeam with a small
-- green roof, and a cream board reading `outside` to arrivals and `inside` to those leaving.
-- A flower box sits at each foot.
function Signs.arch(parent: Instance, foot: Vector3, faces: number, outside: string, inside: string)
	local folder = Instance.new("Folder")
	folder.Name = "Arch"
	folder.Parent = parent
	local out = Props.facing(faces)
	local base = CFrame.lookAt(foot, foot + out)
	-- The painted arch if there is one: shingled roof, ivy posts and its own hanging board. Our
	-- words go on a cream board over that one, and unseen posts do the blocking.
	local painted = Props.model("VillageArch")
	if painted then
		local stood = Props.stand(folder, painted, foot, PAINTED_ARCH_TALL, out)
		local reach = stood.Size.X * 0.4
		for _, side in { -reach, reach } do
			local post = Props.part(
				folder,
				Vector3.new(3, PAINTED_ARCH_TALL * 0.8, 3),
				base * CFrame.new(side, PAINTED_ARCH_TALL * 0.4, 0),
				TIMBER
			)
			post.Name = "ArchPost"
			post.Transparency = 1
			post.CanCollide = true
		end
		-- The words are written straight on to the hanging board, one side each: an unseen
		-- sheet just clear of each of its faces carries them.
		for _, side in { -1, 1 } do
			local words = Props.part(
				folder,
				Vector3.new(stood.Size.X * 0.33, PAINTED_ARCH_TALL * 0.115, 0.1),
				base * CFrame.new(0, PAINTED_ARCH_TALL * 0.57, side * PAINTED_BOARD_HALF),
				CREAM
			)
			words.Name = "ArchBoard"
			words.Transparency = 1
			-- "Route A · Clover Lane" reads as two lines on the board.
			if side == -1 then
				Props.text(words, Enum.NormalId.Front, (string.gsub(outside, " · ", "\n")))
			else
				Props.text(words, Enum.NormalId.Back, (string.gsub(inside, " · ", "\n")))
			end
		end
		return
	end
	for _, side in { -9, 9 } do
		local post =
			Props.part(folder, Vector3.new(2, 14, 2), base * CFrame.new(side, 7, 0), TIMBER)
		post.Name = "ArchPost"
		post.CanCollide = true
		Props.lump(
			folder,
			Vector3.new(3.4, 1.6, 2.4),
			(base * CFrame.new(side, 0.6, -2.2)).Position,
			Props.rgb(110, 84, 60)
		)
		for bloom = -1, 1 do
			Props.lump(
				folder,
				Vector3.one * 0.9,
				(base * CFrame.new(side + bloom, 1.5, -2.2)).Position,
				if bloom == 0 then Props.rgb(240, 130, 150) else Props.rgb(250, 220, 90)
			)
		end
	end
	Props.part(folder, Vector3.new(22, 2, 2), base * CFrame.new(0, 14, 0), TIMBER)
	for _, side in { -1, 1 } do
		local roof = Instance.new("WedgePart")
		roof.Anchored = true
		roof.CanCollide = false
		roof.Size = Vector3.new(23, 2, 2)
		roof.Color = ROOF
		roof.Material = Enum.Material.SmoothPlastic
		roof.CFrame = base
			* CFrame.new(0, 16, side * 1)
			* CFrame.Angles(0, if side == -1 then 0 else math.rad(180), 0)
		roof.Parent = folder
	end
	local board = Props.part(folder, Vector3.new(12, 3, 0.5), base * CFrame.new(0, 11.5, 0), CREAM)
	board.Name = "ArchBoard"
	-- The board's front (-Z) looks out of town, at arrivals.
	Props.text(board, Enum.NormalId.Front, outside)
	Props.text(board, Enum.NormalId.Back, inside)
end

-- A signpost whose arrow boards point along `faces`, one board a line, read from either side.
-- The painted Signpost is used for the post when there is one; the words go on thin boards of
-- our own in front of it (its own boards are blank).
function Signs.signpost(parent: Instance, foot: Vector3, faces: number, lines: { string })
	local folder = Instance.new("Folder")
	folder.Name = "Signpost"
	folder.Parent = parent
	local point = Props.facing(faces)
	-- The boards run along `point`; their broad faces look to either side of it.
	-- `side` is chosen so that the frame's +X runs along `point`.
	local side = Vector3.new(point.Z, 0, -point.X)
	local base = CFrame.lookAt(foot, foot + side)
	local painted = Props.model("Signpost")
	if painted then
		local made = Props.stand(folder, painted, foot, 7.5, side)
		made.CanCollide = true
	else
		local post =
			Props.part(folder, Vector3.new(0.8, 7, 0.8), base * CFrame.new(0, 3.5, 0), TIMBER)
		post.CanCollide = true
		Props.lump(
			folder,
			Vector3.new(1.2, 0.8, 1.2),
			(base * CFrame.new(0, 7.1, 0)).Position,
			TIMBER
		)
	end
	for index, line in lines do
		local height = 6.2 - (index - 1) * 1.7
		local width = math.clamp(#line * 0.28, 4, 8)
		-- In the board's own frame +X runs along `point`, so the arrow's tip is at +X.
		local frame = base * CFrame.new(width / 2 - 0.6, height, 0)
		local board = Props.part(folder, Vector3.new(width, 1.4, 0.3), frame, CREAM)
		board.Name = "SignBoard"
		if painted then
			board.Transparency = 0.05
		end
		local tip = Instance.new("WedgePart")
		tip.Anchored = true
		tip.CanCollide = false
		tip.Size = Vector3.new(0.3, 1.4, 1)
		tip.Color = CREAM
		tip.Material = Enum.Material.SmoothPlastic
		tip.CFrame = frame * CFrame.new(width / 2 + 0.5, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
		tip.Parent = folder
		-- Front looks along `side`: someone standing there sees `point` on their left.
		Props.text(board, Enum.NormalId.Front, line)
		Props.text(board, Enum.NormalId.Back, mirrored(line))
	end
end

return Signs
