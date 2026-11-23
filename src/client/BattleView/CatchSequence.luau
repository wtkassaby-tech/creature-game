--!strict
-- The catch as a little scene, shown after the timing bar: the camera eases onto the foe, the
-- rope flies out and drops over it, the foe is held and the rope tugs a few times with a hush
-- between, then the payoff: a gold burst and a jingle for a catch, a slip and a shake for a miss,
-- a snap and a bound away for a flight.
-- Display only. The server decided the result before this plays; the result is known on arrival
-- and this only delays showing it. Every wait here shortens when the player taps (hurried) or
-- chooses fast speed, and every step stops by itself if the battle has closed.

local BattleFx = require(script.Parent.BattleFx)
local BattleStage = require(script.Parent.BattleStage)
local Kit = require(script.Parent.Parent.UI.Kit)
local LassoFx = require(script.Parent.Parent.Fx.LassoFx)
local MoveFx = require(script.Parent.Parent.Fx.MoveFx)
local Sfx = require(script.Parent.Parent.Audio.Sfx)

local CatchSequence = {}

export type Deps = {
	stage: BattleStage.Stage,
	moveFx: MoveFx.Fx,
	fx: BattleFx.Fx,
	say: (text: string) -> (), -- the battle's text box
	pace: () -> number, -- 1 normal, less when fast or hurried
	hurried: () -> boolean,
	open: () -> boolean, -- false once the battle has closed or another has begun
}

export type View = {
	play: (outcome: string, zones: number, line: string) -> (),
	clear: () -> (),
}

local FOE = 2
local TUGS_FOR_A_CATCH = 3

function CatchSequence.new(deps: Deps): View
	local stage, moveFx = deps.stage, deps.moveFx
	local rope = LassoFx.new(stage, deps.pace)

	local function pause(seconds: number)
		task.wait(math.max(0.03, seconds * deps.pace()))
	end

	local function tugs(outcome: string, zones: number): number
		if deps.hurried() then
			return 1
		elseif outcome == "Caught" then
			return TUGS_FOR_A_CATCH
		elseif outcome == "Missed" then
			return if zones >= 2 then 2 else 1 -- a near miss wobbles twice
		end
		return 1
	end

	local function play(outcome: string, zones: number, line: string)
		deps.say("The lasso flies!")
		stage.focus(FOE, 0.55 * deps.pace())
		rope.throw(1, FOE, 1.0)
		if not deps.open() then
			return
		end
		-- Held: a little smaller, and a hush.
		stage.squeeze(FOE, 0.88, 0.15 * deps.pace())
		moveFx.dust(FOE)
		pause(0.25)
		for count = 1, tugs(outcome, zones) do
			if not deps.open() then
				return
			end
			deps.say(string.rep(". ", count))
			rope.tug(0.3)
			stage.tug(FOE)
			moveFx.dust(FOE)
			stage.shake(0.12)
			pause(0.3)
		end
		if not deps.open() then
			return
		end
		if outcome == "Caught" then
			rope.tighten(0.2)
			stage.squeeze(FOE, 0.06, 0.35 * deps.pace())
			moveFx.caught(FOE)
			Sfx.play("caught")
			deps.fx.callout("GOT IT!", Kit.COLOURS.gold)
			deps.say(line)
			pause(0.35)
			rope.fadeOut(0.3)
			rope.clear()
			pause(0.15)
		elseif outcome == "Missed" then
			stage.squeeze(FOE, 1, 0.2 * deps.pace())
			rope.release("slip", 0.4)
			stage.tug(FOE) -- it shakes the loop off
			deps.say(line)
			rope.clear()
			stage.refocus(0.5 * deps.pace())
			pause(0.4)
		else
			rope.release("snap", 0.35)
			stage.bound(FOE)
			deps.say(line)
			rope.clear()
			pause(0.6)
		end
	end

	return { play = play, clear = rope.clear }
end

return CatchSequence
