--!SerializeField
local bloodPart : GameObject = nil
--!SerializeField
local Corpse : GameObject = nil
--!SerializeField
local ImposterIndicator : GameObject = nil
--!SerializeField
local VoteIndicator : GameObject = nil
--!SerializeField
local liveMask : LayerMask = nil
--!SerializeField
local imposterMask : LayerMask = nil
--!SerializeField
local liveMaskVis : LayerMask = nil
--!SerializeField
local ghostMask : LayerMask = nil
--!SerializeField
local ghostMaskVis : LayerMask = nil
--!SerializeField
local readyButton : GameObject = nil
--!SerializeField
local voteSound : AudioClip = nil
--!SerializeField
local meetingSound : AudioClip = nil
--!SerializeField
local taskMngr : GameObject = nil
--!SerializeField
local myCam : GameObject = nil

--!SerializeField
local InProgressUI : GameObject = nil
--!SerializeField
local InLobbyUI : GameObject = nil
--!SerializeField
local TimerBar : GameObject = nil

taskMngrScript = nil

local readyPressed = false

gameState = IntValue.new("GameState")
local readyRequest = Event.new("ReadyRequest")

playerResetEvent = Event.new("PlayerResetEvent")
local serverResetRequest = Event.new("ServerResetRequest")


local setImposterEvent = Event.new("SetImposterEvent")

local meetingRequest = Event.new("MeetingRequest")
local meetingEvent = Event.new("MeetingEvent")
local endMeetingEvent = Event.new("EndMeetingEvent")

local endGameImposterEvent = Event.new("EndGameImposterEvent")


local killPlayerReq = Event.new("KillPlayerReq")
local killPlayerEvent = Event.new("KillPlayerEvent")

local votePlayerReq = Event.new("VotePlayerReq")
local votePlayerEvent = Event.new("VotePlayerEvent")

local fetchTimerReq = Event.new("FetchTimerReq")
local fetchTimerEvent = Event.new("FetchTimerEvent")

local CharacterController = require("PlayerCharacterController")


local livingClientPlayers = {}
local connectedClientPlayers = {}
clientImposter = nil

local killButtons = {}
local VoteButtons = {}

local general = nil

local audioPlayer = nil

local gameTotalTime = 300
local gameCurrentTimeClient = gameTotalTime


function self:ClientAwake()
    audioPlayer = self.gameObject:GetComponent(AudioSource)

    CharacterController.options.tapMask = ghostMask

    scene.PlayerJoined:Connect(function(scene, player)
        player.CharacterChanged:Connect(function(player, character)
            -- character variables
            connectedClientPlayers[player] = player
            --GAME HAS NOT STARTED YET
            if(gameState.value == 0)then
                livingClientPlayers[player] = player
                if(player == client.localPlayer)then
                    --I JOINED in LOBBY
                    myCam:GetComponent(Camera).cullingMask = liveMaskVis
                end
            else
                --GAME IN PROGRESS
                player.character.renderLayer = LayerMask.NameToLayer("Ghost")
                if(player == client.localPlayer)then
                    --I JOINED Mid Game
                    myCam:GetComponent(Camera).cullingMask = ghostMaskVis
                    fetchTimerReq:FireServer()
                end
            end
        end)
    end)
    client.PlayerDisconnected:Connect(function(player)
		livingClientPlayers[player] = nil
		connectedClientPlayers[player] = nil
	end)

    fetchTimerEvent:Connect(function(player, timer)
        if(player == client.localPlayer)then
            gameCurrentTimeClient = timer
        end
    end)

    --Locally Spawn a Kill Indicator over all the Characters
    function SpawnImposterPrefabs(player)
        local newObject = Object.Instantiate(ImposterIndicator)
        local newObjectTran = newObject.transform
        newObjectTran.parent = player.character.transform
        newObjectTran.localPosition = Vector3.new(0,0,0)
        newObjectTran.localEulerAngles = Vector3.new(0,0,0)
        newObjectTran.localScale = Vector3.new(1,1,1)
        newObject:GetComponent("KillBoxScript").myPlayer = player
        newObject:GetComponent("KillBoxScript").playerManager = self.gameObject:GetComponent("PlayerManager")
        killButtons[newObject] = newObject
    end

    --Locally Spawn a Vote Indicator over all the Characters
    function SpawnVotePrefabs(player)
        local newObject = Object.Instantiate(VoteIndicator)
        local newObjectTran = newObject.transform
        newObjectTran.parent = player.character.transform
        newObjectTran.localPosition = Vector3.new(0,0,0)
        newObjectTran.localEulerAngles = Vector3.new(0,0,0)
        newObjectTran.localScale = Vector3.new(1,1,1)
        newObject:GetComponent("VoteBoxScript").myPlayer = player
        newObject:GetComponent("VoteBoxScript").playerManager = self.gameObject:GetComponent("PlayerManager")
        VoteButtons[newObject] = newObject
    end

    --Send the Server a Kill Request for a specific Player
    function SendServerKillRequest(victim, viaVote)
        killPlayerReq:FireServer(victim, viaVote)
    end

    --Send the Server a Vote Request for a specific Player
    function SendServerVoteRequest(victim)
        --Remove all vote indicators
        for k, v in pairs(VoteButtons) do
            VoteButtons[k] = nil
            Object.Destroy(k)
        end
        votePlayerReq:FireServer(victim)
        audioPlayer:PlayOneShot(voteSound)
    end

    --Locally Kill a player killed by the Server
    killPlayerEvent:Connect(function(victim, viaVote)

        --Kill Particle
        livingClientPlayers[victim] = nil
        local newObject = Object.Instantiate(bloodPart)
        local newObjectTran = newObject.transform
        newObjectTran.parent = victim.character.transform
        newObjectTran.localPosition = Vector3.new(0,2,0)
        newObjectTran.parent = nil

        --Corpse
        if(viaVote == false)then
            local newCorpse = Object.Instantiate(Corpse)
            local newCorpseTran = newCorpse.transform
            newCorpseTran.parent = victim.character.transform
            newCorpseTran.localPosition = Vector3.new(0,0,0)
            newCorpseTran.parent = nil
            newCorpse:GetComponent("MeetingButtonScript").playerManagerScript = self.gameObject:GetComponent("PlayerManager")
            newCorpse = nil
        end

        --[[
        --      LOCALLY DIED
        --]]
        if(victim == client.localPlayer)then
            CharacterController.options.tapMask = ghostMask
            myCam:GetComponent(Camera).cullingMask = ghostMaskVis
        end


        --Remove and Reset Kill Indicators
        for k, v in pairs(killButtons) do
            killButtons[k] = nil
            Object.Destroy(k)
        end
        if(client.localPlayer == clientImposter)then
            -- I am the Imposter
            for k, v in pairs(livingClientPlayers) do
                if(v ~= client.localPlayer)then
                    SpawnImposterPrefabs(k)
                end
            end
        end

        --Object.Destroy(victim.character.gameObject)
        victim.character.renderLayer = LayerMask.NameToLayer("Ghost")
    end)

    --Send a request to Server to call a Meeting
    function CallMeeting(isCorpse)
        meetingRequest:FireServer()
    end

    --locally handle a Meeting Event after the Server calls a Meeting
    meetingEvent:Connect(function()
        audioPlayer:PlayOneShot(meetingSound)
        --Spawn Vote Indicators over each Character and Teleport players
        for k, v in pairs(livingClientPlayers) do
            v.character.gameObject:SetActive(false)
            v.character.transform.position = Vector3.new(0,0,0)
            v.character.gameObject:SetActive(true)
            SpawnVotePrefabs(k)
        end
        --Remove all kill indicators to be replaced by vote indicators
        for k, v in pairs(killButtons) do
            killButtons[k] = nil
            Object.Destroy(k)
        end

        --REMOVE EVIDENCE
        for index, value in ipairs(GameObject.FindGameObjectsWithTag("Respawn")) do
            Object.Destroy(value.gameObject)
        end
    end)

    --locally handle the Server ending a Meeting
    endMeetingEvent:Connect(function(Imposter, victim, noVotes)
        --Remove all vote indicators
        for k, v in pairs(VoteButtons) do
            VoteButtons[k] = nil
            Object.Destroy(k)
        end

        if(noVotes == false)then
            Chat:DisplayTextMessage(general, client.localPlayer, "Game: " .. victim.name .. " has been voted out!! The game continues.")
        else
            Chat:DisplayTextMessage(general, client.localPlayer, "Game: No one has been voted out... The game continues.")
        end

        -- Give the Imposter their Kill Indicators back
        if(client.localPlayer == Imposter)then
            -- I am the Imposter
            for k, v in pairs(livingClientPlayers) do
                if(v ~= client.localPlayer)then
                    SpawnImposterPrefabs(k)
                end
            end

            --make sure there was a winner to the vote
            if(noVotes == false)then
                --KIll the supposed Imposter
                SendServerKillRequest(victim, true)
            end
        end
    end)

    gameState.Changed:Connect(function(newVal, oldVal)
        if(newVal == 0) then -- IN LOBBY
            InProgressUI:SetActive(false)
            InLobbyUI:SetActive(true)
        else -- IN GAME
            InProgressUI:SetActive(true)
            InLobbyUI:SetActive(false)
            if(newVal == 2)then
                --Voting
                Chat:DisplayTextMessage(general, client.localPlayer, "Game: Emergency Meeting!! Discuss with the other crewmates and Vote for who you think the imposter is!")
            end
        end
    end)
end

function self:ClientStart()
    taskMngrScript = taskMngr:GetComponent("TaskMaster")

    --Tap Handler for the Ready Button
    readyButton:GetComponent(TapHandler).Tapped:Connect(function()
        if(readyPressed == false and gameState.value == 0)then
            readyRequest:FireServer()
            readyPressed = true
        end
    end)

    --Connect to the Set Imposter Event from Server to spawn Kill Indicators if I am the Imposter----------------------
    setImposterEvent:Connect(function(Imposter)
        --Set the Local Impostor
        clientImposter = Imposter
        local localPlayerCount = 0
        if(client.localPlayer == Imposter)then
            -- I am the Imposter
            --Start Message
            Chat:DisplayTextMessage(general, client.localPlayer, "Game: You are the Imposter! Kill the crew before they complete all the tasks!")
            CharacterController.options.tapMask = imposterMask

            for k, v in pairs(livingClientPlayers) do
                if(v ~= client.localPlayer)then
                    SpawnImposterPrefabs(k)
                end
                localPlayerCount = localPlayerCount + 1
            end
            taskMngrScript.SetTotals(localPlayerCount*5)
        else
            -- I am a Crew Memeber
            Chat:DisplayTextMessage(general, client.localPlayer, "Game: You are a Crew Member. Complete all the taks... before you are killed!")
            --enable Tasks
            CharacterController.options.tapMask = liveMask
        end
    end)

    --CLIENT RESET ------------------------------------------------------
    function ClientReset(winner)
        gameCurrentTimeClient = gameTotalTime
        myCam:GetComponent(Camera).cullingMask = liveMaskVis
        if(winner == "Imposter")then
            Chat:DisplayTextMessage(general, client.localPlayer, "Game: The Imposter WINS!")
            Chat:DisplayTextMessage(general, client.localPlayer, "Lobby: Chat enabled")
        else
            Chat:DisplayTextMessage(general, client.localPlayer, "Game: The CREW WINS!")
            Chat:DisplayTextMessage(general, client.localPlayer, "Lobby: Chat enabled")
        end

        readyButton:GetComponent("ReadyButton").resetButtonGraphic()

        taskMngrScript.ResetTasks()
        clientImposter = nil
        CharacterController.options.tapMask = ghostMask
        for k, v in pairs(connectedClientPlayers) do
            livingClientPlayers[k] = k
            k.character.renderLayer = 6
            v.character.gameObject:SetActive(false)
            v.character.transform.position = Vector3.new(0,0,0)
            v.character.gameObject:SetActive(true)
            print(livingClientPlayers[k].name .. " is alive")
        end

        local Corpses = GameObject.FindGameObjectsWithTag("Respawn")
        for k, v in pairs(Corpses) do
            Corpses[k] = nil
            Object.Destroy(v)
        end
        
        for k, v in pairs(VoteButtons) do
            VoteButtons[k] = nil
            Object.Destroy(k)
        end
        VoteButtons = {}
        for k, v in pairs(killButtons) do
            killButtons[k] = nil
            Object.Destroy(k)
        end
        killButtons = {}
        readyPressed = false
    end

    taskMngrScript.taskResetEvent:Connect(function()
        if(clientImposter == client.localPlayer)then
            serverResetRequest:FireServer()
        end
    end)
    playerResetEvent:Connect(function(winner)ClientReset(winner)end)

    ---------------------------------CHAT---------------------------------
    Chat.PlayerJoinedChannel:Connect(function(channelInfo, player)
		if player == client.localPlayer then
			general = channelInfo
			Chat:SetDefaultChannel(general)
		end
	end)

    Chat.TextMessageReceivedHandler:Connect(function(channelInfo, player, message)
        if(gameState.value ~= 1 or channelInfo.name == "ghostChannel")then
            Chat:DisplayTextMessage(channelInfo, player, message)
        end
	end)
    ---------------------------------CHAT---------------------------------
end


function self:ClientUpdate()
    if(gameState.value ~= 0 and gameCurrentTimeClient > 0)then
        gameCurrentTimeClient = gameCurrentTimeClient - Time.deltaTime
        TimerBar.transform.localScale = Vector3.new(gameCurrentTimeClient/gameTotalTime,1,1)
        print(tostring(gameCurrentTimeClient/gameTotalTime))
    end
end

local gameCurrentTime = gameTotalTime

local activeMeeting = false
local meetingTotalTime = 30
local meetingTimer = 0


local canKill = true
local killCoolDownTotal = 15
local killCoolDownCurrent = killCoolDownTotal


local canAlarm = true
local AlarmCoolDownTotal = 40 --Includes the meeting timer so 45 is 10sec after the 30sec meeting
local AlarmCooldownCurrent = AlarmCoolDownTotal

function self:ServerStart()
    local readyPlayerCount = 0

    local Players = {}
    local serverConnectedPlayers = {}
    local playerVotes = {}
    local Imposter = nil

    local livingPlayerCount = 0   

    ---------------------------------CHAT---------------------------------
    --Create the Default Channel (name, allowsText, allowsVoice)
    local ghostChannel = Chat:CreateChannel("ghostChannel", true, true)
    local generalChannel = Chat:CreateChannel("generalChannel", true, true)
    --Always add new players to general
    server.PlayerConnected:Connect(function(player)
        if(gameState.value == 0)then
            Chat:AddPlayerToChannel(generalChannel, player)
        else
            Chat:AddPlayerToChannel(ghostChannel, player)
        end
    end)
    ---------------------------------CHAT---------------------------------

    --Select a Random Player from the Players table
    function selectRandomPlayer()
        local count = 0
        local keys = {}
        for k, v in pairs(Players) do
            count = count + 1
            keys[count] = k
        end
        local index = math.random(count)
        return keys[index]
    end

    function ServerTeleportAll()
        --Teleport Players
        for k, v in pairs(Players) do
            v.character.transform.position = Vector3.new(0,0,0)
        end
    end

    function ServerStartGame()
        gameState.value = 1
        Imposter = selectRandomPlayer()
        print("Server: Imposter is " .. tostring(Imposter.name))
        setImposterEvent:FireAllClients(Imposter)
    end

    function ServerReset(winner)
        Players = serverConnectedPlayers
        canAlarm = true
        AlarmCooldownCurrent = AlarmCoolDownTotal
        canKill = true
        killCoolDownCurrent = killCoolDownTotal
        Imposter = nil
        readyPlayerCount = 0
        playerVotes = {}
        livingPlayerCount = 0
        for k, v in pairs(Players) do
            livingPlayerCount = livingPlayerCount + 1
            Chat:AddPlayerToChannel(generalChannel, v)
            Chat:RemovePlayerFromChannel(ghostChannel, v)
        end
        ServerTeleportAll()
        gameState.value = 0
        gameCurrentTime = gameTotalTime
        playerResetEvent:FireAllClients(winner)
    end

    --Log the player into Players when they Connect
    scene.PlayerJoined:Connect(function(scene, player)
        player.CharacterChanged:Connect(function(player, character)
            -- character variables
            serverConnectedPlayers[player] = player
            if(gameState.value == 0)then
                --GAME HAS NOT STARTED YET
                Players[player] = player
                livingPlayerCount = livingPlayerCount + 1
            end
        end)
    end)
    --Remove the player from Players when they Disconnect
    server.PlayerDisconnected:Connect(function(player)
        print("PlayerLeft")
        livingPlayerCount = livingPlayerCount - 1
		Players[player] = nil
		serverConnectedPlayers[player] = nil

        if(gameState.value ~= 0) then
            if(Imposter == player)then
                -- IMPOSTER IS DEAD
                print("SERVER: Crew Wins")
                ServerReset("Crew")
            else
                if(livingPlayerCount <= 1)then
                    --ALL PLAYERS ARE DEAD!
                    print("SERVER: Imposter Wins")
                    ServerReset("Imposter")
                end
            end
        end

	end)

    --playerHitReady
    readyRequest:Connect(function()
        readyPlayerCount = readyPlayerCount + 1
        --if(readyPlayerCount >= (livingPlayerCount/2) and livingPlayerCount >= 4)then
        if((readyPlayerCount >= (livingPlayerCount/2)) and livingPlayerCount > 1)then
            --At least half of the players are ready so Start!
            ServerStartGame()
        end
    end)

    --Kill a player then update all the Clients
    killPlayerReq:Connect(function(requester, victim, viaVote)
        if(canKill)then
            killPlayerEvent:FireAllClients(victim, viaVote)
            Chat:RemovePlayerFromChannel(generalChannel, victim)
            Chat:AddPlayerToChannel(ghostChannel, victim)

            if(Imposter == victim)then
                -- IMPOSTER IS DEAD
                print("SERVER: Crew Wins")
                ServerReset("Crew")
            else
                livingPlayerCount = livingPlayerCount - 1
                if(livingPlayerCount <= 1)then
                    --ALL PLAYERS ARE DEAD!
                    print("SERVER: Imposter Wins")
                    ServerReset("Imposter")
                end
            end

            canKill = false
        end
    end)

    --RESET FROM CLIENT --------------
    serverResetRequest:Connect(function()
        ServerReset("Crew")
    end)

    --Add a vote to a specific player
    votePlayerReq:Connect(function(requester, victim)
        if(playerVotes[victim] == nil)then
            playerVotes[victim] = 1
        else
            playerVotes[victim] = playerVotes[victim] + 1
        end
    end)

    --Send a Meeting to all Clients when the Button is pressed
    meetingRequest:Connect(function(player, isCorpse)
        if((activeMeeting == false and canAlarm) or (activeMeeting == false and isCorpse))then
            playerVotes = {}
            meetingTimer = meetingTotalTime
            activeMeeting = true

            --Teleport Players
            ServerTeleportAll()

            gameState.value = 2
            meetingEvent:FireAllClients()

            canAlarm = false
        end
    end)

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

    function EndMeeting()
        local votedPlayer = findMaxKey(playerVotes)
        activeMeeting = false
        if(votedPlayer)then
            print(votedPlayer.name .. " was voted out with " .. tostring(playerVotes[votedPlayer]) .. " votes")
            endMeetingEvent:FireAllClients(Imposter, votedPlayer, false)
        else
            --NO VOTES
            endMeetingEvent:FireAllClients(Imposter, votedPlayer, true)
            print("No one was voted out, the game continues...")
        end
        gameState.value = 1
    end

    fetchTimerReq:Connect(function(player)
        fetchTimerEvent:FireAllClients(player, gameCurrentTime)
    end)
end

function self:ServerUpdate()
    if(gameState.value ~= 0)then
        gameCurrentTime = gameCurrentTime - Time.deltaTime
        --print("Game Timer: " .. tostring(math.floor(gameCurrentTime)))
        if(gameCurrentTime <= 0)then
            -- Crew Wins Timer ran out
            print("SERVER: Crew Wins")
            ServerReset("Crew")
        end
    end
    if(activeMeeting)then
        meetingTimer = meetingTimer - Time.deltaTime
        if(meetingTimer <= 0)then
            EndMeeting()
        end
    end
    if(canKill == false)then
        killCoolDownCurrent = killCoolDownCurrent - Time.deltaTime
        --print(tostring(killCoolDownCurrent))
        if(killCoolDownCurrent <= 0)then
            canKill = true
            killCoolDownCurrent = killCoolDownTotal
        end
    end
    if(canAlarm == false)then
        AlarmCooldownCurrent = AlarmCooldownCurrent - Time.deltaTime
        --print(tostring(AlarmCooldownCurrent))
        if(AlarmCooldownCurrent <= 0)then
            canAlarm = true
            AlarmCooldownCurrent = AlarmCoolDownTotal
        end
    end
end