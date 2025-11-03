--!Type(Module)

local statsScript = nil
local leaderboardScript = nil
leaderBoardIsVisible = true

function self:ClientAwake()
    statsScript = self.gameObject:GetComponent("LocalStatsUi")
    leaderboardScript = self.gameObject:GetComponent("LeaderboardUI")
end

function UpdateLeaderboard(players)
    leaderboardScript.UpdateLeaderboard(players)
end

function UpdateLocalPlayer(score)
    leaderboardScript.UpdateLocalPlayer(score)
end

function ToggleLeaderboard()
    local isVisible = not leaderBoardIsVisible
    leaderboardScript.ToggleLeaderboardUI(isVisible)
    leaderBoardIsVisible = isVisible
end

--function UpdateCash(cash)
--    statsScript.SetCashCount(cash)
--end

function UpdatePower(power)
    statsScript.SetPowerCount(power)
end

-------- Server --------

function self:ServerAwake()
end