--!SerializeField
local playrManager : GameObject = nil
--!SerializeField
local outVent : GameObject = nil

local teleportRequest = Event.new("TeleportRequest")
local teleportEvent = Event.new("TeleportEvent")

function self:ClientStart()
    local playerManagerScript = playrManager:GetComponent("PlayerManager")
    self:GetComponent(TapHandler).Tapped:Connect(function()
        if(playerManagerScript.clientImposter == client.localPlayer)then
            --USE VENT
            teleportRequest:FireServer(outVent.transform.position)
        end
    end)

    teleportEvent:Connect(function(player, pos)
        --Locally Teleport
        player.character.gameObject:SetActive(false)
        player.character.transform.position = pos
        player.character.gameObject:SetActive(true)
    end)
end

function self:ServerAwake()
    teleportRequest:Connect(function(player, pos)
        --Server Teleport
        player.character.transform.position = pos
        teleportEvent:FireAllClients(player, pos)
    end)
end