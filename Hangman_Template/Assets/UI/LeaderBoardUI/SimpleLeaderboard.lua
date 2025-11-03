--!Type(UI)


--!Bind
local entry1name : UILabel = nil
--!Bind
local entry1score : UILabel = nil

--!Bind
local entry2name : UILabel = nil
--!Bind
local entry2score : UILabel = nil

--!Bind
local entry3name : UILabel = nil
--!Bind
local entry3score : UILabel = nil

--!Bind
local entry4name : UILabel = nil
--!Bind
local entry4score : UILabel = nil

--!Bind
local entry5name : UILabel = nil
--!Bind
local entry5score : UILabel = nil
--!Bind
local leaderboardtitletext : UILabel = nil


--!Bind
local localName : UILabel = nil
--!Bind
local localScore : UILabel = nil

local Tracker = require("PlayerTracker")

local playerNames = {entry1name,entry2name,entry3name,entry4name,entry5name}
local playerScores = {entry1score,entry2score,entry3score,entry4score,entry5score}


leaderboardtitletext:SetPrelocalizedText("Leaderboard")

entry1name:SetPrelocalizedText("1. " .. " ")
entry1score:SetPrelocalizedText("0")

entry2name:SetPrelocalizedText("2. " .. " ")
entry2score:SetPrelocalizedText("0")

entry3name:SetPrelocalizedText("3. " .. " ")
entry3score:SetPrelocalizedText("0")

entry4name:SetPrelocalizedText("4. " .. " ")
entry4score:SetPrelocalizedText("0")

entry5name:SetPrelocalizedText("5. " .. " ")
entry5score:SetPrelocalizedText("0")

function UpdateMyScore(score)
    localName:SetPrelocalizedText(client.localPlayer.name .. ": ")
    localScore:SetPrelocalizedText(tostring(score))
end

function UpdateLeaderBoard(iTopScores)

    for i = 1, 5 do
        playerNames[i]:SetPrelocalizedText(tostring(i) .. ". ")
        playerScores[i]:SetPrelocalizedText("0")
    end

    -- Return the top scores
    for i, entry in ipairs(iTopScores) do
        print(entry.playerName .. ": " .. ", Score: " .. tostring(entry.playerScore))
        playerNames[i]:SetPrelocalizedText(tostring(i) .. ". " .. entry.playerName)
        playerScores[i]:SetPrelocalizedText(tostring(entry.playerScore))
    end

end