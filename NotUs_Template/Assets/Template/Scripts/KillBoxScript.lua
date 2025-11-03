--!SerializeField
local tapper : GameObject = nil
myPlayer = nil
playerManager = nil

function self:Start()
    tapper:GetComponent(TapHandler).Tapped:Connect(function()
        playerManager.SendServerKillRequest(myPlayer, false)
    end)
end