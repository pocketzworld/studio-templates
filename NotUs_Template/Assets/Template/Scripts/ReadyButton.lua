--!SerializeField
local offMesh : GameObject = nil
--!SerializeField
local anim : Animator = nil


function resetButtonGraphic()
    offMesh:SetActive(true)
    anim:SetTrigger("Click")
end
function self:Start()
    local audioPlayer = self.gameObject:GetComponent(AudioSource)
    self.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
        offMesh:SetActive(false)
        anim:SetTrigger("Click")
        audioPlayer:Play()
    end)
end