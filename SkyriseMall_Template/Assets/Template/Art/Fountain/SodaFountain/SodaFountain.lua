--!SerializeField
local Particle1 : GameObject = nil
--!SerializeField
local Particle2 : GameObject = nil
--!SerializeField
local Particle3 : GameObject = nil

local particles = {Particle1,Particle2,Particle3}

function PlayRandomParticle()
    local roll = math.random(1,3)
    if (roll == 1) then Particle1:GetComponent(ParticleSystem):Play() end
    if (roll == 2) then Particle2:GetComponent(ParticleSystem):Play() end
    if (roll == 3) then Particle3:GetComponent(ParticleSystem):Play() end
    self.gameObject:GetComponent(AudioSource):Play()
end

self.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
    PlayRandomParticle()
end)