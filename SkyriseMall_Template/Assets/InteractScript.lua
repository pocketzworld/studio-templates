--!SerializeField
local HasAnimation : boolean = false
--!SerializeField
local HasAudio : boolean = false
--!SerializeField
local HasParticle : boolean = false
--!SerializeField
local particle : GameObject = nil

self.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
    if (HasAnimation) then self.gameObject:GetComponent(Animator):SetTrigger("Interact") end
    if (HasAudio) then self.gameObject:GetComponent(AudioSource):Play() end
    if (HasParticle) then particle.gameObject:GetComponent(ParticleSystem):Play() end
end)