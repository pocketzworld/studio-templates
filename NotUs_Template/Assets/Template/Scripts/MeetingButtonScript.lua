--!SerializeField
local playrManager : GameObject = nil
--!SerializeField
local isCorpse : boolean = nil

playerManagerScript = nil

function self:Start()
    if(playrManager == nil)then playrManager = GameObject.Find("PlayerManager") end
    if(playerManagerScript == nil)then playerManagerScript = playrManager:GetComponent("PlayerManager") end

    self.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
        if(playerManagerScript)then
            playerManagerScript.CallMeeting(isCorpse)
        end
    end)
end