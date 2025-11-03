--!SerializeField
local prefabToSpawn : GameObject = nil

scene.PlayerJoined:Connect(function(scene, player)
    player.CharacterChanged:Connect(function(player, character)
        -- character variables
        local newObject = Object.Instantiate(prefabToSpawn)
        local newObjectTran = newObject.transform
        newObjectTran.parent = character.transform
        newObjectTran.localPosition = Vector3.new(0,0,0)
        newObjectTran.localEulerAngles = Vector3.new(0,0,0)
        newObjectTran.localScale = Vector3.new(1,1,1)
        if(player == client.localPlayer)then
            newObject.tag = "localPlayer"
        end
    end)
end)