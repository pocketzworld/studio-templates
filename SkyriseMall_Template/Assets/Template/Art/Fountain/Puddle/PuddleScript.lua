--!SerializeField
local particle : ParticleSystem = nil

function self:OnTriggerEnter(other : Collider)
    particle:GetComponent(ParticleSystem):Play()
    self.gameObject:GetComponent(AudioSource):Play()
end