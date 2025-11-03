--!SerializeField
local FireWorks : GameObject = nil
--!SerializeField
local Button : GameObject = nil

local shootEventServer = Event.new("ShootEventServer")
local shootEventClient = Event.new("ShootEventClient")


function Client()

    if(client.localPlayer.name == "HighriseCreate")then
        --Admin
    else
        --User
        Button.gameObject:SetActive(false)
    end

    Button.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
        shootEventServer:FireServer()
    end)

    shootEventClient:Connect(function()
        FireWorks.gameObject:GetComponent(ParticleSystem):Play()
        FireWorks.gameObject:GetComponent(AudioSource):Play()
    end)

end

function Server()
    shootEventServer:Connect(function()
        shootEventClient:FireAllClients()
    end)
end

if server then
    Server()
else
    Client()
end