--!SerializeField
local energyOrb : GameObject = nil
--!SerializeField
local lightningPickup : GameObject = nil
--!SerializeField
local maxAmount : number = 10
--!SerializeField
local minAmount : number = 5
--!SerializeField
local spawnDistance : number = 15

--!SerializeField
local lightningChance : number = 10

activeOrbs = 0

function self:Update()
    if(activeOrbs <= minAmount)then -- If the active orbs are less than the minimum amount, then spawn more
        amountToSpawn = maxAmount - activeOrbs
        for i = 1, amountToSpawn do

            local lightningRoll = math.random(1,100)
            if lightningRoll <= lightningChance then
                --Spawn Lightning Orb
                local newOrb = Object.Instantiate(lightningPickup)
                local orbT = newOrb.transform
                local newPosX = math.random(-spawnDistance,spawnDistance)
                local newPosZ = math.random(-spawnDistance,spawnDistance)
                orbT.position = Vector3.new(newPosX, 0, newPosZ)
                local orbScript = newOrb:GetComponent("EnergyOrbScript")
                orbScript.SpawnerScript = self.gameObject:GetComponent("EnergySpawner")
                orbScript.Energy = math.random(1,10)
                orbScript.UpdateSize()
            else
                -- Spawn Energy Orb
                local newOrb = Object.Instantiate(energyOrb)
                local orbT = newOrb.transform
                local newPosX = math.random(-spawnDistance,spawnDistance)
                local newPosZ = math.random(-spawnDistance,spawnDistance)
                orbT.position = Vector3.new(newPosX, 0, newPosZ)
                local orbScript = newOrb:GetComponent("EnergyOrbScript")
                orbScript.SpawnerScript = self.gameObject:GetComponent("EnergySpawner")
                orbScript.Energy = math.random(1,10)
                orbScript.UpdateSize()
            end
        end
    end 
end