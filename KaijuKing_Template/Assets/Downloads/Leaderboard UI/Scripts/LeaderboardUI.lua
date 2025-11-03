--!Type(UI)

--!Bind
local _localname : UILabel = nil -- Do not touch this line
--!Bind
local _localscore : UILabel = nil -- Do not touch this line

--!Bind
local _content : VisualElement = nil -- Do not touch this line
--!Bind
local _ranklist : UIScrollView = nil -- Do not touch this line

--!Bind
local _closeButton : VisualElement = nil -- Do not touch this line

--!Bind
local leaderboard_container : VisualElement = nil -- Do not touch this line

-- Change this to the number of players you want to display
local maxPlayers = 15

local uiManger = require("UIManager")

function ToggleLeaderboardUI(isVisible)
  leaderboard_container:EnableInClassList("hidden", not isVisible) -- Hide the UI
end

-- Register a callback to close the ranking UI
_closeButton:RegisterPressCallback(function()
  ToggleLeaderboardUI(false)
  uiManger.leaderBoardIsVisible = false
end, true, true, true)

-- Function to get the suffix of a position
function GetPositionSuffix(position)
  if position == 1 then
    return "1st"
  elseif position == 2 then
    return "2nd"
  elseif position == 3 then
    return "3rd"
  else
    return position .. "th"
  end
end

-- Function to update the local player
function UpdateLocalPlayer(score: number)
  local player = client.localPlayer
  
  _localname:SetPrelocalizedText(player.name) -- Set the name of the local player

  local scoreText = (score > 999 and string.format("%.2fk", score / 1000) or tostring(score))
  _localscore:SetPrelocalizedText(scoreText) -- Set the score of the local player

  -- Note: When passing the "score" make sure you convert it to a string
end

-- Function to update the leaderboard
function UpdateLeaderboard(iTopScores)
  -- Clear the previous leaderboard entries
  _ranklist:Clear()

  -- Get the number of players to display
  local playersCount = #iTopScores

  -- Clamp the number of players to display
  if playersCount > maxPlayers then playersCount = maxPlayers end -- Ensure only max entries are displayed

  -- Loop through the players and add them to the leaderboard
  for i = 1, playersCount do

    -- Create a new rank item
    local _rankItem = VisualElement.new()
    _rankItem:AddToClassList("rank-item")

    -- Get the player entry
    local entry = iTopScores[i]

    local name = entry.playerName -- Get the name of the player
    local score = entry.playerScore -- Get the score of the player

    -- Create the rank, name, and score labels
    local _rankLabel = UILabel.new()
    _rankLabel:SetPrelocalizedText(GetPositionSuffix(i))
    _rankLabel:AddToClassList("rank-label")

    -- Set the name and score of the player
    local _nameLabel = UILabel.new()
    _nameLabel:SetPrelocalizedText(name)
    _nameLabel:AddToClassList("name-label")

    -- Set the score of the player
    local _scoreLabel = UILabel.new()
    local scoreText = (score > 999 and string.format("%.2fk", score / 1000) or tostring(score))
    _scoreLabel:SetPrelocalizedText(scoreText)
    _scoreLabel:AddToClassList("score-label")

    -- Add the rank, name, and score labels to the rank item
    _rankItem:Add(_rankLabel)
    _rankItem:Add(_nameLabel)
    _rankItem:Add(_scoreLabel)

    -- Add the rank item to the leaderboard
    _ranklist:Add(_rankItem)
  end
end

-- Hardcoded players, replace this with your own data
-- Make sure the players have a "name" and "score" field
-- Otherwise, you will need to modify the code to match your data

-- Debugging purposes
local cooldown = 5 -- Update every 5 seconds
local timer = 0 -- Timer to keep track of the time

-- Call the function to update the leaderboard
-- Note: This function can be called from another script
UpdateLocalPlayer(5)
--UpdateLeaderboard(players)