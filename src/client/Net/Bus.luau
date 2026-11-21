--!strict
-- Lets more than one screen hear the same message from the server. Each message in
-- src/net/Net.blink takes a single listener, so the first screen to ask registers that one
-- listener here, and every screen that asks is called with each message as it arrives.

local Bus = {}

type Event<T> = { On: (listener: (value: T) -> ()) -> () -> () }

local listeners: { [any]: { (value: any) -> () } } = {}

-- Calls `callback` with every message of this kind, for as long as the game runs.
function Bus.listen<T>(event: Event<T>, callback: (value: T) -> ())
	local list = listeners[event]
	if not list then
		local made: { (value: any) -> () } = {}
		listeners[event] = made
		list = made
		event.On(function(value: T)
			for _, each in made do
				task.spawn(each, value)
			end
		end)
	end
	table.insert(list :: { (value: any) -> () }, callback)
end

return Bus
