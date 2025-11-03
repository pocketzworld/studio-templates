--!SerializeField
local Ripples : GameObject = nil

local isOn = true

function ToggleParticles()
    if(isOn)then
        self.gameObject:GetComponent(ParticleSystem):Stop()
        self.gameObject:GetComponent(AudioSource):Stop()
        Ripples.gameObject:GetComponent(ParticleSystem):Stop()
        isOn = false
    else
        self.gameObject:GetComponent(ParticleSystem):Play()
        self.gameObject:GetComponent(AudioSource):Play()
        Ripples.gameObject:GetComponent(ParticleSystem):Play()
        isOn = true
    end
end

self.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
    ToggleParticles()
end)