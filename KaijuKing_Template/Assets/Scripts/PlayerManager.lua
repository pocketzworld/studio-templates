--!SerializeField
local EnergyOrb : GameObject = nil
--!SerializeField
local LightningEffect : GameObject = nil
--!SerializeField
local Camera : GameObject = nil

addEnergyRequest = Event.new("AddEnergyRequest")
destroyPlayerRequest = Event.new("DestroyPlayerRequest")
destroyPlayerEvent = Event.new("DestroyPlayerEvent")

strikeKaijuReq = Event.new("StrikeKaijuReq")
strikeKaijuEvent = Event.new("StrikeKaijuEvent")


local getMyScoreRequest = Event.new("getMyScoreRequest")

local updateLeaderboardEvent = Event.new("UpdateLeaderboardEvent")
local updateLeaderboardRequest = Event.new("UpdateLeaderboardRequest")

local getTokenRequest = Event.new("GetTokenRequest")

local uiManager = require("UIManager")

respawnRadius = 35 -- Max distance from the center to respawn after being destroyed

players = {}
playerPowers = {}
kingKaiju = nil

local function TrackPlayers(game, characterCallback)
    scene.PlayerJoined:Connect(function(scene, player)
        players[player] = {
            player = player,
            Power = IntValue.new("power" .. tostring(player.id), 0),
            Score = IntValue.new("PlayerScore" .. tostring(player.id), 0),
            Tokens = IntValue.new("PlayerTokens" .. tostring(player.id), 0)
        }

        player.CharacterChanged:Connect(function(player, character) 
            local playerinfo = players[player]
            if (character == nil) then
                return
            end 

            if characterCallback then
                characterCallback(playerinfo)
            end
        end)
    end)

    game.PlayerDisconnected:Connect(function(player)
        players[player] = nil
        playerPowers[player] = nil
    end)
end

local function findMaxKey(tbl)
    local maxKey = nil
    local maxValue = -math.huge -- Start with negative infinity as initial maximum value

    for key, value in pairs(tbl) do
        if value > maxValue then
            maxValue = value
            maxKey = key
        elseif value == maxValue then
            maxValue = value
            maxKey = nil
        end
    end

    return maxKey
end

function GetTokens(player)
    return players[player].Tokens.value
end

function PromtTokenPurchase()

    print(tostring(Payments))
    Payments:PromptPurchase("eel", function(paid)
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

--]]
function self:ClientAwake()

    -------- Scoring --------

    getTokenRequest:FireServer()
    getMyScoreRequest:FireServer()

    updateLeaderboardRequest:FireServer()
    updateLeaderboardEvent:Connect(function(iTopScores)
        print("Updating Leaderboard " .. tostring(#iTopScores))
        uiManager.UpdateLeaderboard(iTopScores)
    end)

    function OnCharacterInstantiate(playerinfo)
        local player = playerinfo.player
        local character = player.character

        --The function to run everytime someones power level changes to sync up scores and scales
        playerinfo.Power.Changed:Connect(function(powerLevel, oldVal)
            local newScale = 1 + (powerLevel * .01) -- Scale is always 1 + the power level factored by .01

            if player == client.localPlayer then uiManager.UpdatePower(powerLevel) end
        
            character.renderScale = Vector3.new(newScale, newScale, newScale)

            --Play the glowUp particle for the player getting energy
            character.gameObject:GetComponentInChildren(ParticleSystem).transform.localScale = Vector3.new(newScale, newScale, newScale) --adjust the scale of the particle effect to match the character scale
            character.gameObject:GetComponentInChildren(ParticleSystem):Play()

            --Check for King Kaiju, the p[layewr with the most power
            playerPowers[player] = powerLevel
            kingKaiju = findMaxKey(playerPowers)
            if(kingKaiju)then
                for player, power in pairs(playerPowers) do
                    if(player.character.gameObject.transform:GetChild(2):GetChild(0))then
                        player.character.gameObject.transform:GetChild(2):GetChild(0).gameObject:SetActive(false)
                    end
                end
                if(kingKaiju.character.gameObject.transform:GetChild(2):GetChild(0))then
                    kingKaiju.character.gameObject.transform:GetChild(2):GetChild(0).gameObject:SetActive(true)
                end
            end

        end)

        -- Local player score update
        playerinfo.Score.Changed:Connect(function(score, oldVal)
            if player == client.localPlayer then
                uiManager.UpdateLocalPlayer(score)
            end
        end)
    end

    -- Spawn an Energy Group with timed Orbs for everyone independantly when someone is destroyed
    function spawnEnergyGroup(amount, radius, playerPos)
        print("GROUP: " .. tostring(amount))
        for i = 1, amount do
            local newOrb = Object.Instantiate(EnergyOrb)
            local orbT = newOrb.transform
            local newPosX, newPosZ = playerPos.x + math.random(-radius,radius), playerPos.z + math.random(-radius,radius)
            orbT.position = Vector3.new(newPosX, 0, newPosZ)
    
            local orbScript = newOrb:GetComponent("EnergyOrbScript")
            orbScript.SpawnerScript = self.gameObject:GetComponent("EnergySpawner")
            orbScript.Energy = 1
            orbScript.UpdateSize()
        end
    end

    --AddEnergy() adds energy to which ever client calls the function
    function AddEnergy(amount)
        addEnergyRequest:FireServer(amount)
    end

    function StrikeKaiju(energy)
        if kingKaiju then
            -- Damage the King Kaiju
            strikeKaijuReq:FireServer(energy, kingKaiju)
        end
    end

    strikeKaijuEvent:Connect(function(kaiju)
        local newLightningEffect = Object.Instantiate(LightningEffect)
        local lightingT = newLightningEffect.transform
        lightingT.position = kaiju.character.transform.localPosition
        lightingT.parent = kaiju.character.transform
    end)

    TrackPlayers(client, OnCharacterInstantiate)
end

function self:ClientStart() --Moved the Destroy functions to Start since we need to use GetComponent on an outside object to reset the camera

    local CamScript = Camera:GetComponent(CameraController)

    --DestroyPlayer() destroy and respawn a player after they are beaten in a collision
    function DestroyPlayer(victim) -- We dont want destroy the one who calls it because that will be the winner of the collision, so we need to pass a paramater
        destroyPlayerRequest:FireServer(victim) -- Pass a paramater through the event
    end

    --Locally Destroy a player now that the server has sent the Event
    destroyPlayerEvent:Connect(function(victim, pos, tempPower)
        --Spawn a group of Orbs before moving the player
        local energyToSpawn = math.floor(tempPower/2) -- The amount of orbs to spawn when the player dies
        local groupPosition = victim.character.transform.position
        local groupRadius = energyToSpawn * .2
        spawnEnergyGroup(energyToSpawn, groupRadius, groupPosition)


        -- Dont actually Destroy the character, just disable, respawn, and reenable them with a reset power level
        victim.character.gameObject:SetActive(false)
        victim.character.transform.position = pos
        victim.character.gameObject:SetActive(true)

        --Play the glowUp particle for the player getting destroyed
        victim.character.gameObject:GetComponentInChildren(ParticleSystem):Play()

        --Center the Camera on the player after Respawn
        if(victim == client.localPlayer)then
            CamScript.CenterOn(pos)
        end 
    end)
end


--[[

    Server

--]]

local topScoreTable = {}


function UpdatePlayerScore(player)
    Storage.GetPlayerValue(player, "HighScore", function(value)
        if value == nil then value = 0 end
        players[player].Score.value = value
    end)
end

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
    local topScoresCount = math.min(numPlayers, 10)

    local topScores = {}
    local iTopScores = {}
    for i = 1, topScoresCount do
        topScores[sortableScores[i].playerName] = sortableScores[i]
        table.insert(iTopScores, sortableScores[i])
    end

    return topScores, iTopScores;
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


function self:ServerAwake()
    TrackPlayers(server)

    -- Fetch the top scores from storage
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

    addEnergyRequest:Connect(function(player, amount) -- Here the player is just the client that sent the request to the server, so when AddEnergy() is called it gives energy to whoever calls it
        local playerInfo = players[player]
        local playerPower = playerInfo.Power.value
        local playerPower = playerPower + amount
        playerInfo.Power.value = playerPower

        local scoreToAdd = amount * 10
        AddScoreServer(player, scoreToAdd)
    end)

    strikeKaijuReq:Connect(function(player, energy, kaiju)
        if kaiju == nil then return end
        local playerInfo = players[kaiju]
        local playerPower = playerInfo.Power.value
        playerPower = playerPower - energy * 5
        if playerPower <= 0 then
            playerPower = 0
        end
        playerInfo.Power.value = playerPower
        strikeKaijuEvent:FireAllClients(kaiju)

        AddScoreServer(kaiju, (energy * -10))
    end)

     -- The first paramater in the request is the player requesting it, the second is the custom paramater we included 
    destroyPlayerRequest:Connect(function(player, victim) -- Connect to a Destroy player request from a client, then send the event to all clients
        -- We need to randomize therespawn position or else someone could just sit in the middle and pin people
        local x, y, z = math.random(-respawnRadius,respawnRadius),0,math.random(-respawnRadius,respawnRadius)
        local pos = Vector3.new(x,y,z)
        victim.character.transform.position = pos

        local playerInfo = players[victim]
        local playerPower = 0
        local tempPower = playerInfo.Power.value -- Storing the power of the victim before setting it to zero so we can pass it down to the energy group spawner
        playerInfo.Power.value = playerPower

        destroyPlayerEvent:FireAllClients(victim, pos, tempPower)
    end)

    ---------------Token amd Scoring System----------------

    -- Register the PurchaseHandler function to be called when a purchase is made
    Payments.PurchaseHandler = ServerHandlePurchase

    getTokenRequest:Connect(function(player)
        Storage.GetPlayerValue(player, "Tokens", function(value)
            if value == nil then print("No Tokens for player"); return end
            players[player].Tokens.value = value
        end)
    end)

    getMyScoreRequest:Connect(function(player)
        UpdatePlayerScore(player)
    end)

    updateLeaderboardRequest:Connect(function(player)
        local topScores, iTopScores = SortScores()
        updateLeaderboardEvent:FireClient(player, iTopScores)
    end)
end

----------------- Server Purchase Handler -----------------
function IncrementTokensServer(player, amount)
    local newAmount = players[player].Tokens.value + amount
    Storage.SetPlayerValue(player, "Tokens", newAmount)
    players[player].Tokens.value = newAmount
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
    if productId == "eel" then
        itemToGive = "eel"
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