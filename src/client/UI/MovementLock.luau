--!strict
-- Stops the player's character walking while a screen is open (a battle, a giant fight).
-- PlayerModule is Roblox's own movement controller. Screens are counted, so walking comes back
-- only when the last one closes.

local Players = game:GetService("Players")

local MovementLock = {}

local holders = 0

function MovementLock.whileOpen(gui: ScreenGui)
	task.spawn(function()
		local player = Players.LocalPlayer
		local module = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 10)
		if not module or not module:IsA("ModuleScript") then
			return
		end
		local controls = (require :: any)(module):GetControls()
		local held = false
		local function changed()
			if gui.Enabled and not held then
				held = true
				holders += 1
				controls:Disable()
			elseif not gui.Enabled and held then
				held = false
				holders -= 1
				if holders == 0 then
					controls:Enable()
				end
			end
		end
		gui:GetPropertyChangedSignal("Enabled"):Connect(changed)
		changed()
	end)
end

return MovementLock
