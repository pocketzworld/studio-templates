--!Type(UI)

--!Bind
local rapidAmount : UILabel = nil
--!Bind
local addButton : UIButton = nil

local Tracker = require("PlayerTracker")
local HangmanController = require("HangManController")

function SetRapid(role)
    rapidAmount:SetPrelocalizedText(role, true)
end
SetRapid(0)

addButton:RegisterPressCallback(function()
    Tracker.PromtTokenPurchase()
end, true, true, true)
