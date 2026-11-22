--!strict
-- The top line of the Creatures screen: the title with how many creatures are owned, then small
-- labelled chips for the egg pens and the three typed candies. Built once; `update` only sets
-- text, so the egg timers can tick through it every second.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CreatureCard = require(script.Parent.CreatureCard)
local Kit = require(script.Parent.Parent.UI.Kit)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)

local HeaderChips = {}

export type Header = { update: (state: Snapshot.State) -> () }

local function clock(seconds: number): string
	local left = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", left // 60, left % 60)
end

-- One chip: a cream pill, with a dot of the candy's colour when it has one.
local function chip(parent: Instance, width: number, order: number, dot: Color3?): TextLabel
	local box = Instance.new("Frame")
	box.Size = UDim2.fromOffset(width, 30)
	box.BackgroundColor3 = Kit.COLOURS.panelLight
	box.BorderSizePixel = 0
	box.LayoutOrder = order
	box.Parent = parent
	CreatureCard.rounded(box, 8)
	CreatureCard.stroke(box, Kit.COLOURS.outline, 2)
	if dot then
		local mark = Instance.new("Frame")
		mark.Size = UDim2.fromOffset(12, 12)
		mark.Position = UDim2.fromOffset(8, 9)
		mark.BackgroundColor3 = dot
		mark.BorderSizePixel = 0
		mark.Parent = box
		CreatureCard.rounded(mark, 6)
		CreatureCard.stroke(mark, Kit.COLOURS.outline, 1)
	end
	local inset = if dot then 26 else 10
	return Kit.label(box, "", UDim2.new(1, -inset - 6, 1, -6), UDim2.fromOffset(inset, 3), 18)
end

function HeaderChips.new(parent: Instance): Header
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -130, 0, 44)
	row.Position = UDim2.fromOffset(14, 4)
	row.BackgroundTransparency = 1
	row.Parent = parent
	local across = Instance.new("UIListLayout")
	across.FillDirection = Enum.FillDirection.Horizontal
	across.VerticalAlignment = Enum.VerticalAlignment.Center
	across.Padding = UDim.new(0, 6)
	across.SortOrder = Enum.SortOrder.LayoutOrder
	across.Parent = row

	local title = Kit.label(row, "", UDim2.fromOffset(160, 44), UDim2.new(), 24)
	title.LayoutOrder = 0
	local pens = chip(row, 220, 1, nil)
	local leaf = chip(row, 70, 2, Kit.ELEMENT_COLOURS.Leaf)
	local sand = chip(row, 70, 3, Kit.ELEMENT_COLOURS.Sand)
	local water = chip(row, 70, 4, Kit.ELEMENT_COLOURS.Water)

	return {
		update = function(state: Snapshot.State)
			title.Text = `Creatures {#state.Creatures}/{state.StableCapacity}`
			local eggLines: { string } = {}
			for _, egg in state.Eggs do
				local left = egg.HatchAt - os.time()
				table.insert(eggLines, if left > 0 then `egg {clock(left)}` else "egg ready")
			end
			pens.Text = `Pens {#state.Eggs}/{state.Pens}: {if #eggLines > 0
				then table.concat(eggLines, ", ")
				else "empty"}`
			leaf.Text = `Leaf {math.floor(state.Candy.Leaf)}`
			sand.Text = `Sand {math.floor(state.Candy.Sand)}`
			water.Text = `Water {math.floor(state.Candy.Water)}`
		end,
	}
end

return HeaderChips
