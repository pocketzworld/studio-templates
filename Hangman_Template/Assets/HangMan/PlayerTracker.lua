--!SerializeField
local LeaderboardUI : GameObject = nil

local getMyScoreRequest = Event.new("getMyScoreRequest")
local getMyScoreEvent = Event.new("getMyScoreEvent")
local updateLeaderboardEvent = Event.new("UpdateLeaderboardEvent")
local updateLeaderboardRequest = Event.new("UpdateLeaderboardRequest")

local getTokenRequest = Event.new("GetTokenRequest")
local incrementTokenRequest = Event.new("IncrementTokenRequest")

local playerStatUI = nil

players = {} -- a table variable to store current players  and info
activePlayers = 0

local function TrackPlayers(game, characterCallback)
    game.PlayerConnected:Connect(function(player) -- When a player joins a scene add them to the players table
        activePlayers = activePlayers + 1
        players[player] = {
            player = player,
            Score = IntValue.new("PlayerScore" .. tostring(player.id), 0),
            Tokens = IntValue.new("PlayerTokens" .. tostring(player.id), 0)
        }
        -- Each player is a `Key` in the table, with the values `player` and `score`

        player.CharacterChanged:Connect(function(player, character) 
            local playerinfo = players[player] -- After the player's character is instantiated store their info from the player table (`player`,`score`)
            if (character == nil) then
                return --If no character instantiated return
            end 

            if characterCallback then -- If there is a character callback provided call it with a reference to the player info
                characterCallback(playerinfo)
            end
        end)
    end)

    game.PlayerDisconnected:Connect(function(player) -- Remove player from the current table if they disconnect
        activePlayers = activePlayers - 1
        players[player] = nil
    end)
end

function GetTokens(player)
    return players[player].Tokens.value
end

function IncrementTokens(amount)
    incrementTokenRequest:FireServer(amount)
end

function PromtTokenPurchase()

    print(tostring(Payments))
    Payments:PromptPurchase("rapidfire-token", function(paid)
        if paid then
            -- Player has purchased the product, server PurchaseHandler will be called soon
            -- Do not give the product here, as the server may not have processed the purchase yet
            print("(Client) Purchase successful!")
        else
            -- Purchase failed, player closed the purchase dialog or something went wrong
            print("(Client) Purchase failed!" .. tostring(paid))
        end
    end)
end

--[[
    Client
]]
function self:ClientAwake()

    local leaderboardScript = LeaderboardUI:GetComponent(SimpleLeaderboard)
    playerStatUI = self.gameObject:GetComponent("PlayerStatGui")

    getTokenRequest:FireServer()
    getMyScoreRequest:FireServer()

    updateLeaderboardRequest:FireServer()
    updateLeaderboardEvent:Connect(function(newPlayers)
        leaderboardScript.UpdateLeaderBoard(newPlayers)
    end)

    getMyScoreEvent:Connect(function(score)
        leaderboardScript.UpdateMyScore(score)
    end)

    -- Track players on Client with a callback
    function OnCharacterInstantiate(playerinfo)
        local player = playerinfo.player

        -- Handle the player's score changing
        playerinfo.Tokens.Changed:Connect(function(newVal, oldVal)
            if player ~= client.localPlayer then
                return
            end
            playerStatUI.SetRapid(newVal)
        end)
    end

    TrackPlayers(client, OnCharacterInstantiate)
end

--[[
    Server
]]

local topScoreTable = {}

function IncrementTokensServer(player, amount)
    local newAmount = players[player].Tokens.value + amount
    Storage.SetPlayerValue(player, "Tokens", newAmount)
    players[player].Tokens.value = newAmount
end

function self:ServerAwake()
    -- Track players on the server, with no callback
    TrackPlayers(server)

    -- Register the PurchaseHandler function to be called when a purchase is made
    Payments.PurchaseHandler = ServerHandlePurchase

    getTokenRequest:Connect(function(player)
        Storage.GetPlayerValue(player, "Tokens", function(value)
            if value == nil then print("No Tokens for player"); return end
            players[player].Tokens.value = value
        end)
    end)

    incrementTokenRequest:Connect(function(player, amount)
        IncrementTokensServer(player, amount)
    end)

    Storage.GetValue("TopScores", function(value)
        if value == nil then return end
        local HighScores = value
        for key, value in pairs(HighScores) do 

            topScoreTable[value.playerName] = {
                playerName = value.playerName,
                playerScore = value.playerScore
            }

        end
    end)

    function SortScores()
        -- Create a sortable list of players with score
        local sortableScores = {}
        for playerName, playerInfo in topScoreTable do
            table.insert(sortableScores, {playerName = playerInfo.playerName, playerScore = playerInfo.playerScore})
        end

        -- Sort the list by score in descending order
        table.sort(sortableScores, function(a, b)
            return a.playerScore > b.playerScore
        end)

        -- Extract the top scores (up to the number of players available)
        local numPlayers = #sortableScores
        local topScoresCount = math.min(numPlayers, 5)

        local topScores = {}
        local iTopScores = {}
        for i = 1, topScoresCount do
            topScores[sortableScores[i].playerName] = sortableScores[i]
            table.insert(iTopScores, sortableScores[i])
        end

        return topScores, iTopScores;
    end

    function is_table_equal(t1,t2,ignore_mt)
        local ty1 = type(t1)
        local ty2 = type(t2)
        if ty1 ~= ty2 then return false end
        -- non-table types can be directly compared
        if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
        -- as well as tables which have the metamethod __eq
        local mt = getmetatable(t1)
        if not ignore_mt and mt and mt.__eq then return t1 == t2 end
        for k1,v1 in pairs(t1) do
           local v2 = t2[k1]
           if v2 == nil or not is_table_equal(v1,v2) then return false end
        end
        for k2,v2 in pairs(t2) do
           local v1 = t1[k2]
           if v1 == nil or not is_table_equal(v1,v2) then return false end
        end
        return true
    end

    function UpdatePlayerScore(player)
        Storage.GetPlayerValue(player, "HighScore", function(value)
            if value == nil then value = 0 end
            players[player].Score.value = value
            getMyScoreEvent:FireClient(player, value)
        end)
    end

    function AddScoreServer(player, amount)
        local playerInfo = players[player]
    
        Storage.IncrementPlayerValue(player ,"HighScore", amount)
        
        Storage.GetPlayerValue(player, "HighScore", function(value)
            if value == nil then value = 0 end
    
            playerInfo.Score.value = value
    
            topScoreTable[player.name] = {
                playerName = player.name,
                playerScore = value
            }
            
            local topScores, iTopScores = SortScores()
    
            local leaderboardChanged = false
            Storage.UpdateValue("TopScores", function(newScores)
                leaderboardChanged = newScores == nil or not is_table_equal(newScores, topScores, false)
                return if leaderboardChanged then topScores else nil
            end,
            function()
                if(leaderboardChanged) then
                    updateLeaderboardEvent:FireAllClients(iTopScores)
                end
            end)
    
        end)
    
        UpdatePlayerScore(player)
    end

    getMyScoreRequest:Connect(function(player)
        AddScoreServer(player, 0)
    end)

    updateLeaderboardRequest:Connect(function(player)
        local topScores, iTopScores = SortScores()
        updateLeaderboardEvent:FireClient(player, iTopScores)
    end)
end


function PrintPurchasesForPlayer(player: Player)
    local limit = 100
    local productId = nil
    local cursorId = nil
    
    print("(Server) Getting purchases for player " .. tostring(player))
    Payments.GetPurchases(player, productId, limit, cursorId, function(purchases, nextCursorId, getPurchasesErr)
        if getPurchasesErr ~= PaymentsError.None then
            error("(Server) Failed to get player purchases: " .. getPurchasesErr)
            return
        end
        print("(Server) Player purchases:")
        for _, purchase in ipairs(purchases) do
            print("Purchase ID: " .. tostring(purchase.id))
            print("Product ID: " .. tostring(purchase.product_id))
            print("User ID: " .. tostring(purchase.user_id))
            print("Purchase Date: " .. tostring(purchase.purchase_date))
        end
    end)
end

function ServerHandlePurchase(purchase, player: Player)
    local productId = purchase.product_id
    print("(Server) Purchase made by player " .. tostring(player) .. " for product " .. tostring(productId))
    
    local itemToGive = nil
    if productId == "rapidfire-token" then
        itemToGive = "rapidfire-token"
    else
        Payments.AcknowledgePurchase(purchase, false) -- Reject the purchase, it will be retried at a later time and eventually refunded
        print("(Server) Purchase for unknown product ID: " .. productId)
        return
    end

    Payments.AcknowledgePurchase(purchase, true, function(ackErr: PaymentsError)
        if ackErr ~= PaymentsError.None then
            error("(Server) Something went wrong while acknowledging purchase: " .. ackErr)
            return
        end
        print("(Server) Purchase acknowledged")
        PrintPurchasesForPlayer(player)
        IncrementTokensServer(player, 5)
    end)
end
