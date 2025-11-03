--!Type(Client)

function self:Update()
    self.transform.eulerAngles = Vector3.new(0, Time.time * -45, 0)
end