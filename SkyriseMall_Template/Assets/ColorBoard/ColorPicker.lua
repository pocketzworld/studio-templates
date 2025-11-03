--!SerializeField
local Color : string = "o"
--!SerializeField
local Spawner : GameObject = nil
--!SerializeField
local anim : Animator = nil
--!SerializeField
local hasAnim : boolean = true

local As = Spawner:GetComponent(AudioSource)

self.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
    Spawner:GetComponent("LightBoardSpawner").selectColor(Color)
    As.pitch = 1
    As:Play()
    if(hasAnim)then anim:SetTrigger("Interact") end
end)