--!strict
-- The latest saved state the server sent (PlayerState), for the screens to read. Display only:
-- nothing here is ever sent back to the server.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Snapshot = require(ReplicatedStorage.shared.Snapshot)

local ClientState = {}

local current: Snapshot.State? = nil
local listeners: { (state: Snapshot.State) -> () } = {}

function ClientState.get(): Snapshot.State?
	return current
end

function ClientState.set(state: Snapshot.State)
	current = state
	for _, listener in listeners do
		task.spawn(listener, state)
	end
end

-- Calls `listener` with every new state. Returns a function that stops it.
function ClientState.onChanged(listener: (state: Snapshot.State) -> ()): () -> ()
	table.insert(listeners, listener)
	return function()
		local index = table.find(listeners, listener)
		if index then
			table.remove(listeners, index)
		end
	end
end

return ClientState
