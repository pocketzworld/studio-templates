--!Type(UI)

--!Bind
local _RankingButton : VisualElement = nil

local uiManager = require("UIManager")

-- Register a callback for the ranking button
_RankingButton:RegisterPressCallback(function()
    uiManager.ToggleLeaderboard()
 end, true, true, true)

