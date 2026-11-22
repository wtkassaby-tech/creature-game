--!strict
-- Today's tasks, as compact rows at the top of the creatures list (they appear with the first
-- badge). Rebuilt only when a task's progress or claimed state changes. The server pays out.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DailyTasks = require(ReplicatedStorage.content.DailyTasks)
local Kit = require(script.Parent.Parent.UI.Kit)
local Net = require(ReplicatedStorage.net.generated.Client)
local Snapshot = require(ReplicatedStorage.shared.Snapshot)

local DailyRows = {}

export type Rows = { update: (daily: { Snapshot.DailyView }) -> () }

local taskGoals: { [string]: string } = {}
for _, task in DailyTasks do
	taskGoals[task.id] = task.goal
end

function DailyRows.new(parent: Instance, order: number): Rows
	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromScale(1, 0)
	holder.AutomaticSize = Enum.AutomaticSize.Y
	holder.BackgroundTransparency = 1
	holder.LayoutOrder = order
	holder.Parent = parent
	local stack = Instance.new("UIListLayout")
	stack.Padding = UDim.new(0, 6)
	stack.SortOrder = Enum.SortOrder.LayoutOrder
	stack.Parent = holder

	local lastKey = ""
	return {
		update = function(daily: { Snapshot.DailyView })
			local parts: { string } = {}
			for _, task in daily do
				table.insert(parts, `{task.Id}:{task.Progress}:{task.Claimed}`)
			end
			local key = table.concat(parts, ",")
			if key == lastKey then
				return
			end
			lastKey = key
			for _, child in holder:GetChildren() do
				if child:IsA("Frame") then
					child:Destroy()
				end
			end
			for index, task in daily do
				local row =
					Kit.panel(holder, UDim2.new(1, 0, 0, 52), UDim2.new(), Kit.COLOURS.panel)
				row.LayoutOrder = index
				local goal = taskGoals[task.Id] or task.Id
				local text =
					`{if task.Hard then "Hard task" else "Daily task"}: {goal}  {task.Progress}/{task.Count}`
				Kit.label(row, text, UDim2.new(0.72, 0, 1, -8), UDim2.fromOffset(10, 4))
				if task.Claimed then
					local done = Kit.label(
						row,
						"Claimed",
						UDim2.new(0.2, 0, 1, -8),
						UDim2.new(0.78, 0, 0, 4)
					)
					done.TextColor3 = Kit.COLOURS.textDim
				elseif task.Progress >= task.Count then
					local claim = Kit.button(row, "Claim", Kit.COLOURS.good, function()
						Net.ClaimDailyTask.Fire({ TaskId = task.Id })
					end)
					claim.Size = UDim2.new(0.2, 0, 1, -8)
					claim.Position = UDim2.new(0.78, 0, 0, 4)
				end
			end
		end,
	}
end

return DailyRows
