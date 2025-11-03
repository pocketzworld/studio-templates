--!SerializeField
local One : GameObject = nil
--!SerializeField
local Two : GameObject = nil
--!SerializeField
local Three : GameObject = nil
--!SerializeField
local Four : GameObject = nil
--!SerializeField
local Five : GameObject = nil
--!SerializeField
local Six : GameObject = nil
--!SerializeField
local Seven : GameObject = nil
--!SerializeField
local Eight : GameObject = nil
--!SerializeField
local Nine : GameObject = nil

--!SerializeField
local Indicator : GameObject = nil

--!SerializeField
local TaskManager : GameObject = nil
--!SerializeField
local playrManager : GameObject = nil
--!SerializeField
local completeSound : AudioClip = nil
--!SerializeField
local interactSound : AudioClip = nil
--!SerializeField
local errorSound : AudioClip = nil

local taskCompleteRequest = Event.new("TaskCompleteRequest")
local taskCompleteEvent = Event.new("TaskCompleteEvent")

enabled = true


function self:ClientStart()

    local aA : Vector3 = Vector3.new(0,0,0)
    local aB : Vector3 = Vector3.new(-.005,0,0)
    local aC : Vector3 = Vector3.new(-.01,0,0)
    local bA : Vector3 = Vector3.new(0,-.005,0)
    local bB : Vector3 = Vector3.new(-.005,-.005,0)
    local bC : Vector3 = Vector3.new(-.01,-.005,0)
    local cA : Vector3 = Vector3.new(0,-.01,0)
    local cB : Vector3 = Vector3.new(-.005,-.01,0)
    local cC : Vector3 = Vector3.new(-.01,-.01,0)

    local Positions = {aA,aB,aC,bA,bB,bC,cA,cB,cC}
    local tempPositions = {aA,aB,aC,bA,bB,bC,cA,cB,cC}

    local Tiles = {One,Two,Three,
                Four,Five,Six,
                Seven,Eight,Nine}

    local PressedTiles = {}

    local TaskManagerScript = TaskManager:GetComponent("TaskMaster")
    local playerManagerScript = playrManager:GetComponent("PlayerManager")

    local audioPlayer = self:GetComponent(AudioSource)

    function Complete(player)
        if((client.localPlayer.name == player.name))then
            print("Numbers TASK Completed by " .. player.name)
            --ResetTiles()
            TaskManagerScript.UpdateTaskCount()
            Indicator:SetActive(false)
            enabled = false
            audioPlayer:PlayOneShot(completeSound, 2)
        end
    end

    function ResetTiles()
        enabled = true
        for key,tile in PressedTiles do
            tile:GetComponent("KeyPadToggle").ResetKey()
        end
        PressedTiles = {}
        RandomizeAll()
        Indicator:SetActive(true)
    end

    function CheckOrder(numberTile)
        if(enabled)then
            audioPlayer:PlayOneShot(interactSound, 0.5)
            table.insert(PressedTiles, numberTile)
            for i = 1, #PressedTiles do
                if PressedTiles[i] ~= Tiles[i] then
                    -- Wrong Order!!
                    ResetTiles()
                    audioPlayer:PlayOneShot(errorSound)
                end
            end
            if(#PressedTiles == #Tiles)then
                -- Finished!!
                taskCompleteRequest:FireServer(player)
            end
        end
    end

    function Randomize(Tile)
        local newPos = math.random(1,#tempPositions)
        Tile.transform.localPosition = tempPositions[newPos]
        table.remove(tempPositions, newPos)
    end

    function RandomizeAll()
        tempPositions = {}
        for key,tile in Positions do
            table.insert(tempPositions,tile)
        end
        for key,tile in Tiles do
            Randomize(tile)
        end
    end

    taskCompleteEvent:Connect(function(player)
        Complete(player)
    end)

    playerManagerScript.gameState.Changed:Connect(function(newVal, oldVal)
        if(newVal == 0) then
            ResetTiles()
        end
    end)

    RandomizeAll()
end

function self:ServerStart()
    taskCompleteRequest:Connect(function(player)
        taskCompleteEvent:FireAllClients(player)
    end)
end