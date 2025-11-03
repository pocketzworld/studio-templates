--!Type(Client)

local startingHeight = self.transform.position.y

function self:Update()
    self.transform.eulerAngles = Vector3.new(0, (Time.time) * -10, 0)
    self.transform.position = Vector3.new(2.5, startingHeight + (math.sin(.25*Time.time)*-.5), 2.5)
end