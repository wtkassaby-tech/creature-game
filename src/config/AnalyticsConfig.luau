--!strict
-- What the game reports to Roblox's analytics, and the limits it keeps to. Roblox allows 10
-- currencies, 100 item names and 100 custom event names per game, and 120 + 20 x players
-- requests a minute (create.roblox.com/docs/production/analytics/event-types).

local AnalyticsConfig = {}

-- The first step of the first-session funnel, before any story beat. Each beat of chapter 1
-- is the next step, in order.
AnalyticsConfig.FIRST_STEP_NAME = "Joined for the first time"
AnalyticsConfig.ONBOARDING_CHAPTER = 1

-- Requests a minute this server lets itself send: a floor, plus a share for each player here.
-- Both sit well under Roblox's own limit, so a burst is dropped by us and never by them.
AnalyticsConfig.REQUESTS_A_MINUTE = 80
AnalyticsConfig.REQUESTS_A_MINUTE_PER_PLAYER = 12

return AnalyticsConfig
