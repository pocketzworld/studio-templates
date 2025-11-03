--!SerializeField
local Spawner : GameObject = nil

self.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
    Spawner:GetComponent("LightBoardSpawner").ClearBoard()
end)