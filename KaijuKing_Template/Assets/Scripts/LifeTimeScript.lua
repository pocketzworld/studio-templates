--!SerializeField
local lifeTime : number = 5

local currentLife = lifeTime

function self:Update()
    if currentLife > 0 then
        currentLife = currentLife - Time.deltaTime
    else
        Object.Destroy(self.gameObject)
    end
end