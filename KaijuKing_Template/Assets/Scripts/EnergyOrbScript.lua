--!SerializeField
local Timed : boolean = false
--!SerializeField
local Lightning : boolean = false
--!SerializeField
local Clip : AudioClip = nil
local timer = 10

local playerManagerScript = require("PlayerManager")
local gameAudio = require("GameAudio")
SpawnerScript = nil
Energy = 1

function UpdateSize()
    self.transform.localScale = Vector3.new(1 + Energy/10, 1 + Energy/10, 1 + Energy/10)
end

function self:Start()
    if(SpawnerScript)then SpawnerScript.activeOrbs = SpawnerScript.activeOrbs + 1 end -- Only change the Spawner Script's orb count if it is spawned by the spawner
    timer = math.random(5,10)
    UpdateSize()
end

function self:OnTriggerEnter(collider)
    colliderCharacter = collider.gameObject:GetComponent(Character)
    if(colliderCharacter == nil)then
        return
    end
    player = colliderCharacter.player -- Player Info
    if(client.localPlayer == player)then

        gameAudio.playSound(Clip)

        playerManagerScript.AddEnergy(Energy)
        if(SpawnerScript)then SpawnerScript.activeOrbs = SpawnerScript.activeOrbs - 1 end -- Only change the Spawner Script's orb count if it is spawned by the spawner

        if(Lightning)then
            playerManagerScript.StrikeKaiju(Energy)
        end

        Object.Destroy(self.gameObject)
    end
end

function self:Update()
    if(Timed)then
        if(timer > 0)then
            timer = timer - Time.deltaTime
        else
            --Timer Ended
            Object.Destroy(self.gameObject)
        end
    end
end