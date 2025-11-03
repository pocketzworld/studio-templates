--!SerializeField
local plrMngr : GameObject = nil
--!SerializeField
local DoorOpen : GameObject = nil
--!SerializeField
local DoorShut : GameObject = nil

local closeDoorRequest = Event.new("CloseDoorRequest")
local openDoorRequest = Event.new("OpenDoorRequest")
local DoorState = IntValue.new("DoorState")

local playerManagerScript = nil

function self:ClientAwake()
    DoorState.Changed:Connect(function(newVal, oldVal)
        if(newVal == 0)then
            DoorOpen:SetActive(false)
            DoorShut:SetActive(true)
        else
            DoorOpen:SetActive(true)
            DoorShut:SetActive(false)
        end
    end)
end

function self:ClientStart()
    playerManagerScript = plrMngr:GetComponent("PlayerManager")
    playerManagerScript.gameState.Changed:Connect(function(newVal, oldVal)
        if(newVal == 1)then
            --OPEN DOORS GAME STARTED
            openDoorRequest:FireServer()
        elseif(newVal == 2)then
            --CLOSE DOORS VOTING IN PROGRESS
            closeDoorRequest:FireServer()
        elseif(newVal == 0)then
            --CLOSE DOORS VOTING IN PROGRESS
            closeDoorRequest:FireServer()
        end
    end)

    DoorOpen:GetComponent(TapHandler).Tapped:Connect(function()
        if(playerManagerScript.clientImposter == client.localPlayer)then
            closeDoorRequest:FireServer()
        end
    end)
    DoorShut:GetComponent(TapHandler).Tapped:Connect(function()
        if(playerManagerScript.clientImposter == client.localPlayer)then
            openDoorRequest:FireServer()
        end
    end)
end

function self:ServerAwake()
    openDoorRequest:Connect(function()
        DoorState.value = 1
    end)
    closeDoorRequest:Connect(function()
        DoorState.value = 0
    end)
end